From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: 802.1q: make vlan_hwaccel_do_receive() return void
Date: Mon, 23 Aug 2010 07:31:58 +0800
Message-ID: <1282519918-10874-1-git-send-email-xiaosuo@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:40346 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab0HVXcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 19:32:43 -0400
Received: by pxi10 with SMTP id 10so2070040pxi.19
        for <netdev@vger.kernel.org>; Sun, 22 Aug 2010 16:32:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan_hwaccel_do_receive() always returns 0, so make it return void.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/if_vlan.h |    5 ++---
 net/8021q/vlan_core.c   |    3 +--
 net/core/dev.c          |    4 ++--
 3 files changed, 5 insertions(+), 7 deletions(-)
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 3d870fd..a523207 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -119,7 +119,7 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     u16 vlan_tci, int polling);
-extern int vlan_hwaccel_do_receive(struct sk_buff *skb);
+extern void vlan_hwaccel_do_receive(struct sk_buff *skb);
 extern gro_result_t
 vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 		 unsigned int vlan_tci, struct sk_buff *skb);
@@ -147,9 +147,8 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	return NET_XMIT_SUCCESS;
 }
 
-static inline int vlan_hwaccel_do_receive(struct sk_buff *skb)
+static inline void vlan_hwaccel_do_receive(struct sk_buff *skb)
 {
-	return 0;
 }
 
 static inline gro_result_t
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 01ddb04..07eeb5b 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -35,7 +35,7 @@ drop:
 }
 EXPORT_SYMBOL(__vlan_hwaccel_rx);
 
-int vlan_hwaccel_do_receive(struct sk_buff *skb)
+void vlan_hwaccel_do_receive(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct vlan_rx_stats     *rx_stats;
@@ -69,7 +69,6 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
 		break;
 	}
 	u64_stats_update_end(&rx_stats->syncp);
-	return 0;
 }
 
 struct net_device *vlan_dev_real_dev(const struct net_device *dev)
diff --git a/net/core/dev.c b/net/core/dev.c
index 7cd5237..d569f88 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2841,8 +2841,8 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (!netdev_tstamp_prequeue)
 		net_timestamp_check(skb);
 
-	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
-		return NET_RX_SUCCESS;
+	if (vlan_tx_tag_present(skb))
+		vlan_hwaccel_do_receive(skb);
 
 	/* if we've gotten here through NAPI, check netpoll */
 	if (netpoll_receive_skb(skb))
