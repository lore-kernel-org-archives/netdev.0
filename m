From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6] net: Potential null skb->dev dereference
Date: Fri, 19 Mar 2010 00:19:38 +0100
Message-ID: <1268954378.2894.201.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:65327 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622Ab0CRXTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 19:19:42 -0400
Received: by bwz1 with SMTP id 1so2553941bwz.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 16:19:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When doing "ifenslave -d bond0 eth0", there is chance to get NULL
dereference in netif_receive_skb(), because dev->master suddenly becomes
NULL after we tested it.

We should use ACCESS_ONCE() to avoid this (or rcu_dereference())

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    8 ++++----
 net/8021q/vlan_core.c     |    4 ++--
 net/core/dev.c            |    8 +++++---
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c79a88b..fa8b476 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2059,12 +2059,12 @@ static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
  * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
  * ARP on active-backup slaves with arp_validate enabled.
  */
-static inline int skb_bond_should_drop(struct sk_buff *skb)
+static inline int skb_bond_should_drop(struct sk_buff *skb,
+				       struct net_device *master)
 {
-	struct net_device *dev = skb->dev;
-	struct net_device *master = dev->master;
-
 	if (master) {
+		struct net_device *dev = skb->dev;
+
 		if (master->priv_flags & IFF_MASTER_ARPMON)
 			dev->last_rx = jiffies;
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index c0316e0..c584a0a 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -11,7 +11,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
-	if (skb_bond_should_drop(skb))
+	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
 		goto drop;
 
 	skb->skb_iif = skb->dev->ifindex;
@@ -83,7 +83,7 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 {
 	struct sk_buff *p;
 
-	if (skb_bond_should_drop(skb))
+	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
 		goto drop;
 
 	skb->skb_iif = skb->dev->ifindex;
diff --git a/net/core/dev.c b/net/core/dev.c
index bcc490c..59d4394 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2483,6 +2483,7 @@ int netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
+	struct net_device *master;
 	struct net_device *null_or_orig;
 	struct net_device *null_or_bond;
 	int ret = NET_RX_DROP;
@@ -2503,11 +2504,12 @@ int netif_receive_skb(struct sk_buff *skb)
 
 	null_or_orig = NULL;
 	orig_dev = skb->dev;
-	if (orig_dev->master) {
-		if (skb_bond_should_drop(skb))
+	master = ACCESS_ONCE(orig_dev->master);
+	if (master) {
+		if (skb_bond_should_drop(skb, master))
 			null_or_orig = orig_dev; /* deliver only exact match */
 		else
-			skb->dev = orig_dev->master;
+			skb->dev = master;
 	}
 
 	__get_cpu_var(netdev_rx_stat).total++;



