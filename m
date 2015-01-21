From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net v2] ipv4: try to cache dst_entries which would cause
 a redirect
Date: Wed, 21 Jan 2015 23:26:25 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501212144530.2701@ja.home.ssi.bg>
References: <c758eb2d861f2eeb981615c3297b19443d4061d6.1421837207.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Marcelo Leitner <mleitner@redhat.com>,
	Florian Westphal <fw@strlen.de>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35357 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751999AbbAUV1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 16:27:07 -0500
In-Reply-To: <c758eb2d861f2eeb981615c3297b19443d4061d6.1421837207.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 21 Jan 2015, Hannes Frederic Sowa wrote:

> Not caching dst_entries which cause redirects could be exploited by hosts
> on the same subnet, causing a severe DoS attack. This effect aggravated
> since commit f88649721268999 ("ipv4: fix dst race in sk_dst_get()").
> 
> Lookups causing redirects will be allocated with DST_NOCACHE set which
> will force dst_release to free them via RCU.  Unfortunately waiting for
> RCU grace period just takes too long, we can end up with >1M dst_entries
> waiting to be released and the system will run OOM. rcuos threads cannot
> catch up under high softirq load.
> 
> Attaching the flag to emit a redirect later on to the specific skb allows
> us to cache those dst_entries thus reducing the pressure on allocation
> and deallocation.
> 
> This issue was discovered by Marcelo Leitner.

	After more thinking and after checking all
ip_route_input places other issues popup :(

	Another place with non-trivial handling is
icmp_route_lookup(), only called by icmp_send(). We do
lookup and then revert it. ip_options_rcv_srr() too.
In this case we even can replace initial route (which
should be to local host, without redirect flag) with
new route (which can be with  IPSKB_DOREDIRECT).
So, for this case we do not wrongly leave some
IPSKB_DOREDIRECT flag.

	But in icmp_route_lookup() should we restore the
original IPSKB_DOREDIRECT bit when_skb_refdst is restored?
I.e. I'm not sure if some icmp_send() caller continues to
use the skb. For now I see only one place where we continue
to use skb after icmp_send: ip_rt_send_redirect(). But
it is after our check for RTCF_DOREDIRECT. Other places
free the skb.

	If we want to be pedantic, should we create some
helper functions and structure to save old state? For now
we are ok but using IPCB looks risky. For example:

struct ip_route_input_state {
	unsigned long	refdst;
	unsigned char	flags;
};

/* Save state and re-init skb for new route lookup */
static inline void
ip_route_input_state_save(struct sk_buff *skb,
			  struct ip_route_input_state *state)
{
	state->refdst = skb->_skb_refdst;
	state->flags = IPCB(skb)->flags;
	skb_dst_set(skb, NULL);
	IPCB(skb)->flags &= ~IPSKB_DOREDIRECT;
}

static inline void
ip_route_input_state_restore(struct sk_buff *skb,
			     struct ip_route_input_state *state)
{
	skb->_skb_refdst = state->refdst;
	IPCB(skb)->flags = state->flags;
}

static inline void
ip_route_input_state_drop(struct ip_route_input_state *state)
{
	refdst_drop(state->refdst);
}

>  	skb->priority = rt_tos2priority(iph->tos);
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 2000110..868c829 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1568,10 +1568,8 @@ static int __mkroute_input(struct sk_buff *skb,
>  	do_cache = res->fi && !itag;
>  	if (out_dev == in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &&
>  	    (IN_DEV_SHARED_MEDIA(out_dev) ||
> -	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res)))) {
> -		flags |= RTCF_DOREDIRECT;
> -		do_cache = false;
> -	}
> +	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
> +		IPCB(skb)->flags |= IPSKB_DOREDIRECT;

	Looks like accessing IPCB may not be safe for
ARP (NEIGH_CB is used) or other protocols, may be we have
to add skb->protocol == htons(ETH_P_IP) check here because
ip_route_input() can be called for different protocols.

Regards

--
Julian Anastasov <ja@ssi.bg>
