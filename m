From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] net: fix a double free issue for neighbour entry
Date: Wed, 20 May 2015 10:35:57 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1505201003150.1557@ja.home.ssi.bg>
References: <1432085113-25063-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, alexei@purestorage.com,
	joern@purestorage.com
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57202 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752486AbbETHgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2015 03:36:15 -0400
In-Reply-To: <1432085113-25063-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 20 May 2015, Ying Xue wrote:

> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -958,6 +958,9 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>  	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
>  		goto out_unlock_bh;
>  
> +	if (neigh->dead)
> +		goto out_unlock_bh;
> +

	Returning 0 in all cases is wrong. May be you can goto
to another new label where nud_state check can allow valid
address to be used. See my idea:

http://marc.info/?l=linux-netdev&m=142816363503402&w=2

	I.e. return 0 for NUD_STALE, drop skb and return 1
otherwise.

>  	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
>  		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
>  		    NEIGH_VAR(neigh->parms, APP_PROBES)) {
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index c65b93a..5889774 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -200,7 +200,7 @@ static inline int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
>  	rcu_read_lock_bh();
>  	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
>  	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
> -	if (unlikely(!neigh))
> +	if (unlikely(!neigh || !atomic_read(&neigh->refcnt)))

	You should forget about refcnt. kfree_rcu in neigh_destroy
will not free neigh while RCU readers are present. Still,
neigh_destroy runs in parallel with readers and I hope they can
use the stored address safely. I mean, neigh_event_send allowing 
neigh_resolve_output to use address in NUD_STALE state on dead=1
by returning 0 and reaching the dev_queue_xmit call.

	Still, another inefficiency remains: how can
__neigh_event_send indicate to ip_finish_output2 that
dead=1 entry is [to be] removed and new entry needs to
be created. It seems the ->output method returns code
but skb is freed in all cases. The result is that we
drop single skb in such condition. But such optimization
should not be part of this bugfix.

Regards

--
Julian Anastasov <ja@ssi.bg>
