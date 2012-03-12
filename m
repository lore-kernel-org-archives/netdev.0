From: Dor Laor <dlaor@redhat.com>
Subject: Re: [PATCH 2/2] vhost-net: add a spin_threshold parameter
Date: Mon, 12 Mar 2012 10:12:34 +0200
Message-ID: <4F5DAFF2.7030008@redhat.com>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com> <1329519726-25763-3-git-send-email-aliguori@us.ibm.com>
Reply-To: dlaor@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Tsirkin <mst@redhat.com>,
	Tom Lendacky <toml@us.ibm.com>,
	Cristian Viana <vianac@br.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Anthony Liguori <aliguori@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239Ab2CLIMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 04:12:41 -0400
In-Reply-To: <1329519726-25763-3-git-send-email-aliguori@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2012 01:02 AM, Anthony Liguori wrote:
> With workloads that are dominated by very high rates of small packets, we see
> considerable overhead in virtio notifications.
>
> The best strategy we've been able to come up with to deal with this is adaptive
> polling.  This patch simply adds the infrastructure needed to experiment with
> polling strategies.  It is not meant for inclusion.
>
> Here are the results with various polling values.  The spinning is not currently
> a net win due to the high mutex contention caused by the broadcast wakeup.  With
> a patch attempting to signal wakeup, we see up to 170+ transactions per second
> with TCP_RR 60 instance.

Do you really consider to add busy loop to the code? There would 
probably be another way to solve it.

One of the options we talked about it to add a ethtool-controllable knob 
in the guest to set the min/max time for wakeup.

>
> N  Baseline	Spin 0		Spin 1000	Spin 5000
>
> TCP_RR
>
> 1  9,639.66	10,164.06	9,825.43	9,827.45	101.95%
> 10 62,819.55	54,059.78	63,114.30	60,767.23	96.73%
> 30 84,715.60	131,241.86	120,922.38	89,776.39	105.97%
> 60 124,614.71	148,720.66	158,678.08	141,400.05	113.47%
>
> UDP_RR
>
> 1  9,652.50	10,343.72	9,493.95	9,569.54	99.14%
> 10 53,830.26	58,235.90	50,145.29	48,820.53	90.69%
> 30 89,471.01	97,634.53	95,108.34	91,263.65	102.00%
> 60 103,640.59	164,035.01	157,002.22	128,646.73	124.13%
>
> TCP_STREAM
> 1  2,622.63	2,610.71	2,688.49	2,678.61	102.13%
> 4  4,928.02	4,812.05	4,971.00	5,104.57	103.58%
>
> 1  5,639.89	5,751.28	5,819.81	5,593.62	99.18%
> 4  5,874.72	6,575.55	6,324.87	6,502.33	110.68%
>
> 1  6,257.42	7,655.22	7,610.52	7,424.74	118.65%
> 4  5,370.78	6,044.83	5,784.23	6,209.93	115.62%
>
> 1  6,346.63	7,267.44	7,567.39	7,677.93	120.98%
> 4  5,198.02	5,657.12	5,528.94	5,792.42	111.44%
>
> TCP_MAERTS
>
> 1  2,091.38	1,765.62	2,142.56	2,312.94	110.59%
> 4  5,319.52	5,619.49	5,544.50	5,645.81	106.13%
>
> 1  7,030.66	7,593.61	7,575.67	7,622.07	108.41%
> 4  9,040.53	7,275.84	7,322.07	6,681.34	73.90%
>
> 1  9,160.93	9,318.15	9,065.82	8,586.82	93.73%
> 4  9,372.49	8,875.63	8,959.03	9,056.07	96.62%
>
> 1  9,183.28	9,134.02	8,945.12	8,657.72	94.28%
> 4  9,377.17	8,877.52	8,959.54	9,071.53	96.74%
>
> Cc: Tom Lendacky<toml@us.ibm.com>
> Cc: Cristian Viana<vianac@br.ibm.com>
> Signed-off-by: Anthony Liguori<aliguori@us.ibm.com>
> ---
>   drivers/vhost/net.c |   14 ++++++++++++++
>   1 files changed, 14 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 47175cd..e9e5866 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -37,6 +37,10 @@ static int workers = 2;
>   module_param(workers, int, 0444);
>   MODULE_PARM_DESC(workers, "Set the number of worker threads");
>
> +static ulong spin_threshold = 0;
> +module_param(spin_threshold, ulong, 0444);
> +MODULE_PARM_DESC(spin_threshold, "The polling threshold for the tx queue");
> +
>   /* Max number of bytes transferred before requeueing the job.
>    * Using this limit prevents one virtqueue from starving others. */
>   #define VHOST_NET_WEIGHT 0x80000
> @@ -65,6 +69,7 @@ struct vhost_net {
>   	 * We only do this when socket buffer fills up.
>   	 * Protected by tx vq lock. */
>   	enum vhost_net_poll_state tx_poll_state;
> +	size_t spin_threshold;
>   };
>
>   static bool vhost_sock_zcopy(struct socket *sock)
> @@ -149,6 +154,7 @@ static void handle_tx(struct vhost_net *net)
>   	size_t hdr_size;
>   	struct socket *sock;
>   	struct vhost_ubuf_ref *uninitialized_var(ubufs);
> +	size_t spin_count;
>   	bool zcopy;
>
>   	/* TODO: check that we are running from vhost_worker? */
> @@ -172,6 +178,7 @@ static void handle_tx(struct vhost_net *net)
>   	hdr_size = vq->vhost_hlen;
>   	zcopy = vhost_sock_zcopy(sock);
>
> +	spin_count = 0;
>   	for (;;) {
>   		/* Release DMAs done buffers first */
>   		if (zcopy)
> @@ -205,9 +212,15 @@ static void handle_tx(struct vhost_net *net)
>   				set_bit(SOCK_ASYNC_NOSPACE,&sock->flags);
>   				break;
>   			}
> +			if (spin_count<  net->spin_threshold) {
> +				spin_count++;
> +				continue;
> +			}
>   			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
>   				vhost_disable_notify(&net->dev, vq);
>   				continue;
> +			} else {
> +				spin_count = 0;
>   			}
>   			break;
>   		}
> @@ -506,6 +519,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
>   		return -ENOMEM;
>
>   	dev =&n->dev;
> +	n->spin_threshold = spin_threshold;
>   	n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
>   	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
>   	r = vhost_dev_init(dev, n->vqs, workers, VHOST_NET_VQ_MAX);
