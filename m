From: Joe Eykholt <jre@nuovasystems.com>
Subject: [PATCH 2/3] bonding:  Allow certain receives on inactive slave.
Date: Sun, 04 May 2008 20:00:28 -0700
Message-ID: <20080505030028.18871.21641.stgit@feynman.nuovasystems.com>
References: <20080505025801.18871.89526.stgit@feynman.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.nuovasystems.com ([67.91.200.194]:7776 "EHLO
	feynman.nuovasystems.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752362AbYEEDbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 23:31:34 -0400
Received: from feynman.nuovasystems.com (feynman.nuovasystems.com [127.0.0.1])
	by feynman.nuovasystems.com (8.14.2/8.14.2) with ESMTP id m4530Tqp018935
	for <netdev@vger.kernel.org>; Sun, 4 May 2008 20:00:29 -0700
In-Reply-To: <20080505025801.18871.89526.stgit@feynman.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bonding:  Allow certain receives on inactive slave.

Allow a packet_type that specifies the exact device to receive
even on an inactive slave devices.  This is important for some
L2 protocols such as LLDP and FCoE.  This can eventually be used
for the bonding special cases as well.

Signed-off-by: Joe Eykholt <jre@nuovasystems.com>
---
 net/core/dev.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)


diff --git a/net/core/dev.c b/net/core/dev.c
index 0335d24..ac5d8ac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2007,6 +2007,7 @@ int netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
+	struct net_device *null_or_orig;
 	int ret = NET_RX_DROP;
 	__be16 type;
 
@@ -2020,13 +2021,13 @@ int netif_receive_skb(struct sk_buff *skb)
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
@@ -2047,7 +2048,7 @@ int netif_receive_skb(struct sk_buff *skb)
 #endif
 
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (!ptype->dev || ptype->dev == skb->dev) {
+		if (ptype->dev == null_or_orig || ptype->dev == skb->dev) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
@@ -2072,7 +2073,7 @@ ncls:
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type &&
-		    (!ptype->dev || ptype->dev == skb->dev)) {
+		    (ptype->dev == null_or_orig || ptype->dev == skb->dev)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;


