From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/5] net/core: Allow certain receives on inactive slave.
Date: Wed,  2 Jul 2008 18:22:01 -0700
Message-ID: <1215048127619-git-send-email-fubar@us.ibm.com>
References: <12150481222323-git-send-email-fubar@us.ibm.com>
 <12150481241992-git-send-email-fubar@us.ibm.com>
 <1215048125108-git-send-email-fubar@us.ibm.com>
 <12150481262025-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Joe Eykholt <jre@nuovasystems.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53404 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010AbYGCBWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 21:22:10 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m631M9A5011706
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:09 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m631M9eX111696
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:09 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m631M8kM004212
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:09 -0400
In-Reply-To: <12150481262025-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Eykholt <jre@nuovasystems.com>

Allow a packet_type that specifies the exact device to receive
even on an inactive bonding slave devices.  This is important for some
L2 protocols such as LLDP and FCoE.  This can eventually be used
for the bonding special cases as well.

Signed-off-by: Joe Eykholt <jre@nuovasystems.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 net/core/dev.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 78114f6..a949664 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2063,6 +2063,7 @@ int netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
+	struct net_device *null_or_orig;
 	int ret = NET_RX_DROP;
 	__be16 type;
 
@@ -2076,13 +2077,13 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (!skb->iif)
 		skb->iif = skb->dev->ifindex;
 
+	null_or_orig = NULL;
 	orig_dev = skb->dev;
 	if (orig_dev->master) {
-		if (skb_bond_should_drop(skb)) {
-			kfree_skb(skb);
-			return NET_RX_DROP;
-		}
-		skb->dev = orig_dev->master;
+		if (skb_bond_should_drop(skb))
+			null_or_orig = orig_dev; /* deliver only exact match */
+		else
+			skb->dev = orig_dev->master;
 	}
 
 	__get_cpu_var(netdev_rx_stat).total++;
@@ -2103,7 +2104,7 @@ int netif_receive_skb(struct sk_buff *skb)
 #endif
 
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (!ptype->dev || ptype->dev == skb->dev) {
+		if (ptype->dev == null_or_orig || ptype->dev == skb->dev) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
@@ -2128,7 +2129,7 @@ ncls:
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type &&
-		    (!ptype->dev || ptype->dev == skb->dev)) {
+		    (ptype->dev == null_or_orig || ptype->dev == skb->dev)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
-- 
1.5.2.4

