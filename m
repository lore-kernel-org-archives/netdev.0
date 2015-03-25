From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Don't reduce hop limit for an interface
Date: Wed, 25 Mar 2015 16:28:44 +0100
Message-ID: <1427297324.2337285.245105105.48DCB26B@webmail.messagingengine.com>
References: <1427272141.10689.7.camel@takeit.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: ljungmark@modio.se, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:50006 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753833AbbCYP2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:28:44 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id B8CDF20A5F
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 11:28:41 -0400 (EDT)
In-Reply-To: <1427272141.10689.7.camel@takeit.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Mar 25, 2015, at 09:29, D. S. Ljungmark wrote:
> From 3ae93eb68a06ab2d9c984c6708dbc9e5f3bc8251 Mon Sep 17 00:00:00 2001
> From: "D.S. Ljungmark" <ljungmark@modio.se>
> Date: Wed, 25 Mar 2015 09:28:15 +0100
> Subject: [PATCH] ipv6: Don't reduce hop limit for an interface
> 
> A local route may have a lower hop_limit set than global routes do.
> 
> RFC 3756, Section 4.2.7, "Parameter Spoofing"
> 
> >   1.  The attacker includes a Current Hop Limit of one or another small
> >       number which the attacker knows will cause legitimate packets to
> >       be dropped before they reach their destination.
> 
> >   As an example, one possible approach to mitigate this threat is to
> >   ignore very small hop limits.  The nodes could implement a
> >   configurable minimum hop limit, and ignore attempts to set it below
> >   said limit.
> 
> Signed-off-by: D.S. Ljungmark <ljungmark@modio.se>
> ---
>  net/ipv6/ndisc.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 471ed24..14ecdaf 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1218,7 +1218,14 @@ static void ndisc_router_discovery(struct sk_buff
> *skb)
>  	if (rt)
>  		rt6_set_expires(rt, jiffies + (HZ * lifetime));
>  	if (ra_msg->icmph.icmp6_hop_limit) {
> -               in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
> +               /* Only set hop_limit on the interface if it is higher
> than
> +                * the current hop_limit.
> +                */
> +               if (in6_dev->cnf.hop_limit <
> ra_msg->icmph.icmp6_hop_limit) {
> +                       in6_dev->cnf.hop_limit =
> ra_msg->icmph.icmp6_hop_limit;
> +               } else {
> +                       ND_PRINTK(2, warn, "RA: Got route advertisement
> with lower hop_limit than current\n");
> +               }

I think this is the simplest solution to this problem and solves the
problem by default, thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
