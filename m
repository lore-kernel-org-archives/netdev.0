From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC ipsec-next 2/2] xfrm: Add a device independent napi
 instance
Date: Thu, 26 Jan 2017 06:26:07 -0800
Message-ID: <1485440767.5145.126.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485413456-31197-1-git-send-email-steffen.klassert@secunet.com>
         <1485413456-31197-3-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34153 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752571AbdAZO0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 09:26:09 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so4751231pgj.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 06:26:09 -0800 (PST)
In-Reply-To: <1485413456-31197-3-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-26 at 07:50 +0100, Steffen Klassert wrote:
> This patch adds a napi instance for IPsec GRO.
> With this, we handle IPsec GRO with no impact
> on the generic networking code.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/xfrm/xfrm_input.c | 87 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 86 insertions(+), 1 deletion(-)
> 
> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index 6e3f025..c5fc12d 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -21,6 +21,90 @@
>  static DEFINE_SPINLOCK(xfrm_input_afinfo_lock);
>  static struct xfrm_input_afinfo __rcu *xfrm_input_afinfo[NPROTO];
>  
> +struct xfrm_napi {
> +	struct sk_buff_head	napi_skbs;
> +	struct napi_struct	napi;
> +};
> +
> +static struct xfrm_napi __percpu *napis;
> +
> +static void xfrm_gro_receive(struct sk_buff *skb)
> +{
> +	struct xfrm_napi *xnapi;
> +	struct net_device *dev = skb->dev;
> +
> +	if (!napis || skb_cloned(skb) || !(dev->features & NETIF_F_GRO)) {
> +		netif_rx(skb);
> +		return;
> +	}
> +
> +	xnapi = this_cpu_ptr(napis);
> +
> +	if (skb_queue_len(&xnapi->napi_skbs) > netdev_max_backlog) {
> +		atomic_long_inc(&dev->rx_dropped);
> +		kfree_skb(skb);
> +		return;
> +	}
> +
> +	__skb_queue_tail(&xnapi->napi_skbs, skb);
> +	if (skb_queue_len(&xnapi->napi_skbs) == 1)
> +		napi_schedule(&xnapi->napi);
> +}
> +
> +static int xfrm_gro_poll(struct napi_struct *napi, int budget)
> +{
> +	unsigned long flags;
> +	struct sk_buff *skb;
> +	int work_done = 0;
> +	struct xfrm_napi *xnapi = container_of(napi, struct xfrm_napi, napi);
> +
> +	while (work_done < budget) {
> +		skb = __skb_dequeue(&xnapi->napi_skbs);
> +		if (!skb)
> +			break;
> +		napi_gro_receive(napi, skb);
> +		work_done++;
> +	}
> +
> +	if (work_done < budget) {
> +		napi_gro_flush(napi, false);
> +
> +		if (likely(list_empty(&napi->poll_list))) {
> +			WARN_ON_ONCE(!test_and_clear_bit(NAPI_STATE_SCHED, &napi->state));
> +		} else {
> +			/* If n->poll_list is not empty, we need to mask irqs */
> +			local_irq_save(flags);
> +			__napi_complete(napi);
> +			local_irq_restore(flags);
> +		}
> +	}


The following should work and contain less copy/pasted code.

          if (work_done < budget)
               napi_complete(napi);


> +
> +	return work_done;
> +}
> +
> +static void xfrm_gro_init(void)
> +{
> +	int i;
> +
> +	/* Napi remains disabled if we can't alloc memory. */
> +	napis = alloc_percpu(struct xfrm_napi);

napis can be NULL here.

> +
> +	for_each_possible_cpu(i) {
> +		struct xfrm_napi *xnapi = per_cpu_ptr(napis, i);
> +
> +		__skb_queue_head_init(&xnapi->napi_skbs);
> +
> +		set_bit(NAPI_STATE_NO_BUSY_POLL, &xnapi->napi.state);
> +
> +		INIT_LIST_HEAD(&xnapi->napi.poll_list);
> +		xnapi->napi.poll = xfrm_gro_poll;
> +		xnapi->napi.weight = 64;
> +		xnapi->napi.gro_list = NULL;
> +		xnapi->napi.gro_count = 0;
> +		xnapi->napi.skb = NULL;
> +	}
> +}


Alternative would be to use a 

static struct net_device xfrm_napi_anchor_device;

and use gro_cell


I will present in next netdev conference a work based on NAPI,
and having less hand coded napi logic will help a lot.

Thanks.
