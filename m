From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] net: remove the unnecessary dance around
 skb_bond_should_drop
Date: Sat, 12 Feb 2011 11:46:06 +0100
Message-ID: <20110212104605.GA2786@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447Ab1BLKqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Feb 2011 05:46:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to check (master) twice and to drive in and out the header file.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |   11 -----------
 net/core/dev.c            |    6 +++---
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c7d7074..5a5baea 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2437,17 +2437,6 @@ static inline void netif_set_gso_max_size(struct net_device *dev,
 	dev->gso_max_size = size;
 }
 
-extern int __skb_bond_should_drop(struct sk_buff *skb,
-				  struct net_device *master);
-
-static inline int skb_bond_should_drop(struct sk_buff *skb,
-				       struct net_device *master)
-{
-	if (master)
-		return __skb_bond_should_drop(skb, master);
-	return 0;
-}
-
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
 static inline int dev_ethtool_get_settings(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 6392ea0..d874fd1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3105,7 +3105,8 @@ static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
  * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
  * ARP on active-backup slaves with arp_validate enabled.
  */
-int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
+static int __skb_bond_should_drop(struct sk_buff *skb,
+				  struct net_device *master)
 {
 	struct net_device *dev = skb->dev;
 
@@ -3139,7 +3140,6 @@ int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
 	}
 	return 0;
 }
-EXPORT_SYMBOL(__skb_bond_should_drop);
 
 static int __netif_receive_skb(struct sk_buff *skb)
 {
@@ -3177,7 +3177,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (skb->deliver_no_wcard)
 		null_or_orig = orig_dev;
 	else if (master) {
-		if (skb_bond_should_drop(skb, master)) {
+		if (__skb_bond_should_drop(skb, master)) {
 			skb->deliver_no_wcard = 1;
 			null_or_orig = orig_dev; /* deliver only exact match */
 		} else
-- 
1.7.3.4

