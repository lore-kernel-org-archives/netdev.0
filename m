From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [RFC PATCH net-next] arp: Do not perturb drop profiles with ignored ARP packets
Date: Thu, 25 Sep 2014 10:55:28 -0700 (PDT)
Message-ID: <20140925175528.8DFF329004BA@tardy>
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:11227 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982AbaIYRzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 13:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Rick Jones <rick.jones2@hp.com>

We do not wish to disturb dropwatch or perf drop profiles with an ARP
we will ignore.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compile tested only after seeing arp_rcv in a perf top -G -e skb:kfree_skb

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1a9b99e..16acb59 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -953,10 +953,11 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 {
 	const struct arphdr *arp;
 
+	/* do not tweak dropwatch on an ARP we will ignore */
 	if (dev->flags & IFF_NOARP ||
 	    skb->pkt_type == PACKET_OTHERHOST ||
 	    skb->pkt_type == PACKET_LOOPBACK)
-		goto freeskb;
+		goto consumeskb;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb)
@@ -974,6 +975,9 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN, skb, dev, NULL, arp_process);
 
+consumeskb:
+	consume_skb(skb);
+	return 0;
 freeskb:
 	kfree_skb(skb);
 out_of_mem:
