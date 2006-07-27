From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Thu, 27 Jul 2006 15:56:40 +0200
Message-ID: <m3zmevqhgn.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59883 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1751295AbWG0N4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 09:56:44 -0400
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

ip_output() ignores dev->hard_header_len if dev->hard_header
function == NULL. It's inconsistent with the rest of the kernel. With
some drivers it would mean instant panic, but we are usually saved by
existence of the "default" header space.

With some bad luck things like tun or IPsec may kill the box.

A similar problem may be present in psched_mtu().

Please apply.
I think it should then be applied to stable series as well.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b94d1ad..3ae64ba 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -234,8 +234,7 @@ extern int tc_classify(struct sk_buff *s
  */
 static inline unsigned psched_mtu(struct net_device *dev)
 {
-	unsigned mtu = dev->mtu;
-	return dev->hard_header ? mtu + dev->hard_header_len : mtu;
+	return dev->mtu + dev->hard_header_len;
 }
 
 #endif
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index cff9c3a..f5d9051 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -169,7 +169,7 @@ static inline int ip_finish_output2(stru
 	int hh_len = LL_RESERVED_SPACE(dev);
 
 	/* Be paranoid, rather than too clever. */
-	if (unlikely(skb_headroom(skb) < hh_len && dev->hard_header)) {
+	if (unlikely(skb_headroom(skb) < hh_len)) {
 		struct sk_buff *skb2;
 
 		skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
