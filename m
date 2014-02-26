From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: poll vhost_net only when tx notification is
 enabled
Date: Wed, 26 Feb 2014 13:16:45 +0200
Message-ID: <20140226111645.GC5236@redhat.com>
References: <530DB1C9.2060106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jason Wang <jasowang@redhat.com>,
	netdev@vger.kernel.org, KVM list <kvm@vger.kernel.org>,
	zhangjie14@huawei.com
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52844 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751311AbaBZLLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 06:11:43 -0500
Content-Disposition: inline
In-Reply-To: <530DB1C9.2060106@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please see MAINTAINERS and copy all relevant lists.

On Wed, Feb 26, 2014 at 05:20:09PM +0800, Qin Chuanyu wrote:
> guest kick host base on avail_ring flags value and get perfermance

typo

> improved, vhost_zerocopy_callback could do the same thing. As
> virtqueue_enable_cb need one more check after modifying the value of
> avail_ring flags, vhost also need do the same thing after
> vhost_enable_notify.
> 
> test result list as below:
> guest and host: suse11sp3, netperf, intel CPU 2.4GHz
> +------+----------+--------+----------+--------+--------+---------+
> |      |             old              |            new            |
> +------+----------+--------+----------+--------+--------+---------+
> | UDP  |  Gbit/s  |  PPS   |CPU idle% | Gbit/s |   PPS  |CPU idle%|
> | 256  | 0.74805  | 321309 |  87.16   | 0.77933| 334743 |  90.71  |
> | 512  |   1.42   | 328475 |  87.03   |  1.44  | 333550 |  90.43  |
> | 1024 |   2.79   | 334426 |  89.09   |  2.81  | 336986 |  89.55  |
> | 1460 |   3.71   | 316215 |  87.53   |  4.02  | 342325 |  89.58  |
> +------+----------+--------+----------+--------+--------+---------+
> 
> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>

It's an interesting optimization, thanks!
However, it looks like this might delay
updating used ring indefinitely if we are
unlucky. Some guests (e.g. windows)
tend to crash if this happens.

Maybe use a new flag for this?

It also looks like there are potential race conditions below.

> ---
>  drivers/vhost/net.c |   13 ++++++++++++-
>  1 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index a0fa5de..a90f51b 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -315,6 +315,10 @@ static void vhost_zerocopy_callback(struct
> ubuf_info *ubuf, bool success)
>  		VHOST_DMA_DONE_LEN : VHOST_DMA_FAILED_LEN;
>  	cnt = vhost_net_ubuf_put(ubufs);
> 
> +	/* make sure len has been updated because handle_tx would use it
> +	 * and used_flags should also been checked.
> +	 */
> +	smp_mb();
>  	/*
>  	 * Trigger polling thread if guest stopped submitting new buffers:
>  	 * in this case, the refcount after decrement will eventually reach 1.

this barrier is very suspect.

> @@ -322,7 +326,8 @@ static void vhost_zerocopy_callback(struct
> ubuf_info *ubuf, bool success)
>  	 * (the value 16 here is more or less arbitrary, it's tuned to trigger
>  	 * less than 10% of times).
>  	 */
> -	if (cnt <= 1 || !(cnt % 16))
> +	if ((!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
> +			&& (cnt <= 1 || !(cnt % 16)))
>  		vhost_poll_queue(&vq->poll);
> 
>  	rcu_read_unlock_bh();

looks like a potential race to me

> @@ -386,6 +391,12 @@ static void handle_tx(struct vhost_net *net)
>  				vhost_disable_notify(&net->dev, vq);
>  				continue;
>  			}
> +			/* there might skb been freed between last
> +			* vhost_zerocopy_signal_used and vhost_enable_notify,
> +			* so one more check is needed.
> +			*/
> +			if (zcopy)
> +				vhost_zerocopy_signal_used(net, vq);


>  			break;
>  		}
>  		if (in) {
> -- 
> 1.7.3.1.msysgit.0
> 
