From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net v2 0/3] UFO fixes
Date: Mon, 21 Oct 2013 23:14:26 +0200
Message-ID: <20131021211426.GB24158@order.stressinduktion.org>
References: <1382178557-14737-1-git-send-email-jiri@resnulli.us> <20131019.192147.1905247570882389108.davem@davemloft.net> <20131020032617.GA27787@order.stressinduktion.org> <20131021.162612.1795347771078720888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jiri@resnulli.us, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	jdmason@kudzu.us, yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49152 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443Ab3JUVO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 17:14:28 -0400
Content-Disposition: inline
In-Reply-To: <20131021.162612.1795347771078720888.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 21, 2013 at 04:26:12PM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sun, 20 Oct 2013 05:26:17 +0200
> 
> > Hi David!
> > 
> > On Sat, Oct 19, 2013 at 07:21:47PM -0400, David Miller wrote:
> >> From: Jiri Pirko <jiri@resnulli.us>
> >> Date: Sat, 19 Oct 2013 12:29:14 +0200
> >> 
> >> > Couple of patches fixing UFO functionality in different situations.
> >> > 
> >> > v1->v2:
> >> > - minor if{}else{} coding style adjustment suggested by Sergei Shtylyov
> >> 
> >> Series applied, thanks Jiri.
> > 
> > I would propose that the patches
> > 
> > "ip6_output: do skb ufo init for peeked non ufo skb as well"
> > (c547dbf55d5f8cf615ccc0e7265e98db27d3fb8b)
> > 
> > and
> > 
> > "ip_output: do skb ufo init for peeked non ufo skb as well"
> > (e93b7d748be887cd7639b113ba7d7ef792a7efb9)
> > 
> > should go to stable because they solve a possible memory corruption
> > from userspace.
> 
> I suppose... the reason I didn't automatically queue these up for -stable
> is that they are rather non-trivial.

This patch I proposed before is IMHO more simple. Would you consider
this a candidate for stable only? I would send a proper patch then.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6d56840..3565450 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1308,6 +1308,11 @@ static inline int skb_pagelen(const struct sk_buff *skb)
 	return len + skb_headlen(skb);
 }
 
+static inline bool skb_has_frags(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->nr_frags;
+}
+
 /**
  * __skb_fill_page_desc - initialise a paged fragment in an skb
  * @skb: buffer containing fragment to be initialised
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7d8357b..8dc3d8d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -836,7 +836,7 @@ static int __ip_append_data(struct sock *sk,
 		csummode = CHECKSUM_PARTIAL;
 
 	cork->length += length;
-	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
+	if (((length > mtu) || (skb && skb_has_frags(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a54c45c..ded4f6f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1227,7 +1227,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	skb = skb_peek_tail(&sk->sk_write_queue);
 	cork->length += length;
 	if (((length > mtu) ||
-	     (skb && skb_is_gso(skb))) &&
+	     (skb && skb_has_frags(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO)) {
 		err = ip6_ufo_append_data(sk, getfrag, from, length,

Greetings,

  Hannes
