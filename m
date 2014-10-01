From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] udp: increment UDP_NO_PORTS when dropping unmatched multicasts
Date: Wed,  1 Oct 2014 08:19:21 -0700 (PDT)
Message-ID: <20141001151921.7131E29003A2@tardy>
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:31998 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbaJAPTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 11:19:25 -0400
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com [15.192.137.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id E0FAD3030
	for <netdev@vger.kernel.org>; Wed,  1 Oct 2014 15:19:24 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Rick Jones <rick.jones2@hp.com>

When there is absolutely no match for an incoming UDP multicast we
should increment a suitable UDP statistic in addition to the kfree_skb().
When there were some matches, we should not and simply call consume_skb().

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Noticed __udp4_lib_mcast_deliver showing-up in a perf dropped packet
profile on a system sitting on a network with a bunch of Windows boxes
sending what they are fond of sending.

Verified that UDP_MIB_NOPORTS increments when it was not before and hit
the system with a bit of netperf multicast UDP_RR but that is the extent
of the testing performed.

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd0db54..376e3d3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1656,6 +1656,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif = skb->dev->ifindex;
 	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
 	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
+	unsigned int inner_flushed = 0;
 
 	if (use_hash2) {
 		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
@@ -1694,8 +1695,12 @@ start_lookup:
 	 */
 	if (count) {
 		flush_stack(stack, count, skb, count - 1);
-	} else {
+	} else if (!inner_flushed) {
+		UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, 0);
 		kfree_skb(skb);
+	} else {
+		/* there were matches flushed in the for_each */
+		consume_skb(skb);
 	}
 	return 0;
 }
