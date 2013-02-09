From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] arp: fix possible crash in arp_rcv()
Date: Fri, 08 Feb 2013 20:48:21 -0800
Message-ID: <1360385301.6696.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:53017 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760649Ab3BIEsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 23:48:24 -0500
Received: by mail-da0-f49.google.com with SMTP id t11so2087221daj.8
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 20:48:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We should call skb_share_check() before pskb_may_pull(), or we
can crash in pskb_expand_head()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/arp.c |   21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 9547a273..ded146b 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -928,24 +928,25 @@ static void parp_redo(struct sk_buff *skb)
 static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct arphdr *arp;
+	const struct arphdr *arp;
+
+	if (dev->flags & IFF_NOARP ||
+	    skb->pkt_type == PACKET_OTHERHOST ||
+	    skb->pkt_type == PACKET_LOOPBACK)
+		goto freeskb;
+
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		goto out_of_mem;
 
 	/* ARP header, plus 2 device addresses, plus 2 IP addresses.  */
 	if (!pskb_may_pull(skb, arp_hdr_len(dev)))
 		goto freeskb;
 
 	arp = arp_hdr(skb);
-	if (arp->ar_hln != dev->addr_len ||
-	    dev->flags & IFF_NOARP ||
-	    skb->pkt_type == PACKET_OTHERHOST ||
-	    skb->pkt_type == PACKET_LOOPBACK ||
-	    arp->ar_pln != 4)
+	if (arp->ar_hln != dev->addr_len || arp->ar_pln != 4)
 		goto freeskb;
 
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (skb == NULL)
-		goto out_of_mem;
-
 	memset(NEIGH_CB(skb), 0, sizeof(struct neighbour_cb));
 
 	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN, skb, dev, NULL, arp_process);
