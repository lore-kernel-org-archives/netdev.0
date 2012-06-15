From: Saurabh Mohan <saurabh.mohan@vyatta.com>
Subject: Re: [net-next PATCH 01/02] net/ipv4: VTI support rx-path hook in xfrm4_mode_tunnel.
Date: Thu, 14 Jun 2012 19:44:11 -0700 (PDT)
Message-ID: <766b5544-ace1-44b5-ac14-14d0e7702b4f@tahiti.vyatta.com>
References: <20120614092559.GU27795@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35422 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021Ab2FOCoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 22:44:11 -0400
In-Reply-To: <20120614092559.GU27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steffen See inline (@SM)

-Saurabh.

----- Original Message -----
From: "Steffen Klassert" <steffen.klassert@secunet.com>
To: "Saurabh" <saurabh.mohan@vyatta.com>
Cc: netdev@vger.kernel.org
Sent: Thursday, June 14, 2012 2:25:59 AM
Subject: Re: [net-next PATCH 01/02] net/ipv4: VTI support rx-path hook in xfrm4_mode_tunnel.

On Fri, Jun 08, 2012 at 10:32:46AM -0700, Saurabh wrote:
> 
> 
> Add hook for rx-path xfmr4_mode_tunnel for VTI tunnel module.
> 
> Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>
> Reviewed-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index e0a55df..04214c0 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -1475,6 +1475,8 @@ extern int xfrm4_output(struct sk_buff *skb);
>  extern int xfrm4_output_finish(struct sk_buff *skb);
>  extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
>  extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
> +extern int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler);
> +extern int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel *handler);
>  extern int xfrm6_extract_header(struct sk_buff *skb);
>  extern int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
>  extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
> diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
> index ed4bf11..4fc2944 100644
> --- a/net/ipv4/xfrm4_mode_tunnel.c
> +++ b/net/ipv4/xfrm4_mode_tunnel.c
> @@ -15,6 +15,68 @@
>  #include <net/ip.h>
>  #include <net/xfrm.h>
>  
> +/*
> + * Informational hook. The decap is still done here.
> + */
> +static struct xfrm_tunnel __rcu *rcv_notify_handlers __read_mostly;
> +static DEFINE_MUTEX(xfrm4_mode_tunnel_input_mutex);
> +
> +int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler)
> +{
> +	struct xfrm_tunnel __rcu **pprev;
> +	struct xfrm_tunnel *t;
> +
> +	int ret = -EEXIST;
> +	int priority = handler->priority;
> +
> +	mutex_lock(&xfrm4_mode_tunnel_input_mutex);
> +
> +	for (pprev = &rcv_notify_handlers;
> +		(t = rcu_dereference_protected(*pprev,
> +		lockdep_is_held(&xfrm4_mode_tunnel_input_mutex))) != NULL;
> +		pprev = &t->next) {
> +		if (t->priority > priority)
> +			break;
> +		if (t->priority == priority)
> +			goto err;
> +
> +	}
> +
> +	handler->next = *pprev;
> +	rcu_assign_pointer(*pprev, handler);
> +
> +	ret = 0;
> +
> +err:
> +	mutex_unlock(&xfrm4_mode_tunnel_input_mutex);
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(xfrm4_mode_tunnel_input_register);
> +
> +int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel *handler)
> +{
> +	struct xfrm_tunnel __rcu **pprev;
> +	struct xfrm_tunnel *t;
> +	int ret = -ENOENT;
> +
> +	mutex_lock(&xfrm4_mode_tunnel_input_mutex);
> +	for (pprev = &rcv_notify_handlers;
> +		(t = rcu_dereference_protected(*pprev,
> +		lockdep_is_held(&xfrm4_mode_tunnel_input_mutex))) != NULL;
> +		pprev = &t->next) {
> +		if (t == handler) {
> +			*pprev = handler->next;
> +			ret = 0;
> +			break;
> +		}
> +	}
> +	mutex_unlock(&xfrm4_mode_tunnel_input_mutex);
> +	synchronize_net();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(xfrm4_mode_tunnel_input_deregister);
> +
>  static inline void ipip_ecn_decapsulate(struct sk_buff *skb)
>  {
>  	struct iphdr *inner_iph = ipip_hdr(skb);
> @@ -64,8 +126,14 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
>  	return 0;
>  }
>  
> +#define for_each_input_rcu(head, handler)	\
> +	for (handler = rcu_dereference(head);	\
> +		handler != NULL;		\
> +		handler = rcu_dereference(handler->next))  \
> +
>  static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
>  {
> +	struct xfrm_tunnel *handler;
>  	int err = -EINVAL;
>  
>  	if (XFRM_MODE_SKB_CB(skb)->protocol != IPPROTO_IPIP)
> @@ -74,6 +142,10 @@ static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
>  	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
>  		goto out;
>  
> +	/* The handlers do not consume the skb. */
> +	for_each_input_rcu(rcv_notify_handlers, handler)
> +		handler->handler(skb);

I'm not sure if this is the right place to add your handler.
My understanding of an IPsec tunnel device would be to
receive the packet first and then do IPsec processing.
Here it happens the other way arround.

@SM: The intention is to get the packet post decrypt and post-esp-decap. Just like a GRE tunnel the rx-counters account for the payload and NOT the GRE header.

Why didn't you register a tunnel handler and call the
xfrm tunnel handler from that?

@SM: I did not want to repeat the work xfrm4_mode_tunnel already does. It does the decrypt and decap. Why repeat it..
All, vti tunnel module wants to do on the receive path is click the counters and change the input device to be the vti.

Reg
-Saurabh.
> +
>  	if (skb_cloned(skb) &&
>  	    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
>  		goto out;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
