From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC] net: neighbour: use source address of last enqueued
 packet for solicitation
Date: Mon, 9 Sep 2013 23:17:45 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1309092208460.1655@ja.ssi.bg>
References: <20130908193031.GC21070@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39678 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755752Ab3IIUN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:13:28 -0400
In-Reply-To: <20130908193031.GC21070@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 8 Sep 2013, Hannes Frederic Sowa wrote:

> Currently we always use the first member of the arp_queue to determine
> the sender ip address of the arp packet (or in case of IPv6 - source
> address of the ndisc packet). This skb is fixed as long as the queue is
> not drained by a complete purge because of a timeout or by a successful
> response.
> 
> If the first packet enqueued on the arp_queue is from a local application
> with a manually set source address and the to be discovered system
> does some kind of uRPF checks on the source address in the arp packet
> the resolving process hangs until a timeout and restarts. This hurts
> communication with the participating network node.
> 
> This could be mitigated a bit if we use the latest enqueued skb's
> source address for the resolving process, which is not as static as
> the arp_queue's head. This change of the source address could result in
> better recovery of a failed solicitation.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> I didn't find anything which could break because of this change, but
> please have a second look.

	arp_queue has packets only in NUD_INCOMPLETE state 
(mcast_solicit=3 secs by default). And __neigh_event_send()
now can keep many packets, 64KB from recent changes. So the
1st place is not guaranteed but now it is more difficult
to kick the first packet compared to the old limit of just
3 packets.

	The change can give chance for 2nd and 3th
probe if the 1st probe is not replied, so it should be
better to apply it:

Reviewed-by: Julian Anastasov <ja@ssi.bg>

	Still, I think such problems should be addressed
with conf/{DEV,all}/arp_announce=1 or 2.

>  net/core/neighbour.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 6072610..ca15f32 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -867,7 +867,7 @@ static void neigh_invalidate(struct neighbour *neigh)
>  static void neigh_probe(struct neighbour *neigh)
>  	__releases(neigh->lock)
>  {
> -	struct sk_buff *skb = skb_peek(&neigh->arp_queue);
> +	struct sk_buff *skb = skb_peek_tail(&neigh->arp_queue);
>  	/* keep skb alive even if arp_queue overflows */
>  	if (skb)
>  		skb = skb_copy(skb, GFP_ATOMIC);
> -- 
> 1.8.3.1

Regards

--
Julian Anastasov <ja@ssi.bg>
