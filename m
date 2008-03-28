From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] Net: Don't send ICMP_FRAG_NEEDED for GSO packets
Date: Fri, 28 Mar 2008 19:34:08 +1100
Message-ID: <200803281934.09308.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	John Heffner <jheffner@psc.edu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51762 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbYC1IeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 04:34:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9af3912ec9e30509b76cb376abb65a4d8af27df3 added a new check to
send ICMP fragmentation needed for large packets.

Unlike the check in ip_finish_output(), it doesn't check for GSO.  I
triggered this with the GSO TUN patches, so not sure if it needs to be
in 2.6.25 or not (do we otherwise forward GSO packets?).

Cc: John Heffner <jheffner@psc.edu>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 69b8317ff51c net/ipv4/ip_forward.c
--- a/net/ipv4/ip_forward.c	Fri Mar 28 14:04:48 2008 +1100
+++ b/net/ipv4/ip_forward.c	Fri Mar 28 19:18:15 2008 +1100
@@ -85,7 +85,7 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto sr_failed;
 
-	if (unlikely(skb->len > dst_mtu(&rt->u.dst) &&
+	if (unlikely(skb->len > dst_mtu(&rt->u.dst) && !skb_is_gso(skb) &&
 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
 		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
