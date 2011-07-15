From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 13/21] jme: do vlan cleanup
Date: Fri, 15 Jul 2011 23:33:31 +0200
Message-ID: <1310765619-27827-14-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	cooldavid@cooldavid.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753065Ab1GOVeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:14 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill jme->vlgrp and jme_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/jme.c |   28 +++++-----------------------
 drivers/net/jme.h |    4 ----
 2 files changed, 5 insertions(+), 27 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 6b2a5e7..85a11e0 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1048,16 +1048,12 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, int idx)
 			skb_checksum_none_assert(skb);
 
 		if (rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_TAGON)) {
-			if (jme->vlgrp) {
-				jme->jme_vlan_rx(skb, jme->vlgrp,
-					le16_to_cpu(rxdesc->descwb.vlan));
-				NET_STAT(jme).rx_bytes += 4;
-			} else {
-				dev_kfree_skb(skb);
-			}
-		} else {
-			jme->jme_rx(skb);
+			u16 vid = le16_to_cpu(rxdesc->descwb.vlan);
+
+			__vlan_hwaccel_put_tag(skb, vid);
+			NET_STAT(jme).rx_bytes += 4;
 		}
+		jme->jme_rx(skb);
 
 		if ((rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_DEST)) ==
 		    cpu_to_le16(RXWBFLAG_DEST_MUL))
@@ -2282,16 +2278,6 @@ static inline void jme_resume_rx(struct jme_adapter *jme)
 }
 
 static void
-jme_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
-{
-	struct jme_adapter *jme = netdev_priv(netdev);
-
-	jme_pause_rx(jme);
-	jme->vlgrp = grp;
-	jme_resume_rx(jme);
-}
-
-static void
 jme_get_drvinfo(struct net_device *netdev,
 		     struct ethtool_drvinfo *info)
 {
@@ -2401,7 +2387,6 @@ jme_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecmd)
 	    test_bit(JME_FLAG_POLL, &jme->flags)) {
 		clear_bit(JME_FLAG_POLL, &jme->flags);
 		jme->jme_rx = netif_rx;
-		jme->jme_vlan_rx = vlan_hwaccel_rx;
 		dpi->cur		= PCC_P1;
 		dpi->attempt		= PCC_P1;
 		dpi->cnt		= 0;
@@ -2411,7 +2396,6 @@ jme_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecmd)
 		   !(test_bit(JME_FLAG_POLL, &jme->flags))) {
 		set_bit(JME_FLAG_POLL, &jme->flags);
 		jme->jme_rx = netif_receive_skb;
-		jme->jme_vlan_rx = vlan_hwaccel_receive_skb;
 		jme_interrupt_mode(jme);
 	}
 
@@ -2850,7 +2834,6 @@ static const struct net_device_ops jme_netdev_ops = {
 	.ndo_set_multicast_list	= jme_set_multi,
 	.ndo_change_mtu		= jme_change_mtu,
 	.ndo_tx_timeout		= jme_tx_timeout,
-	.ndo_vlan_rx_register	= jme_vlan_rx_register,
 	.ndo_fix_features       = jme_fix_features,
 	.ndo_set_features       = jme_set_features,
 };
@@ -2933,7 +2916,6 @@ jme_init_one(struct pci_dev *pdev,
 	jme->pdev = pdev;
 	jme->dev = netdev;
 	jme->jme_rx = netif_rx;
-	jme->jme_vlan_rx = vlan_hwaccel_rx;
 	jme->old_mtu = netdev->mtu = 1500;
 	jme->phylink = 0;
 	jme->tx_ring_size = 1 << 10;
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 1481a62..c1f8b89 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -451,7 +451,6 @@ struct jme_adapter {
 	u32			msg_enable;
 	struct ethtool_cmd	old_ecmd;
 	unsigned int		old_mtu;
-	struct vlan_group	*vlgrp;
 	struct dynpcc_info	dpi;
 	atomic_t		intr_sem;
 	atomic_t		link_changing;
@@ -459,9 +458,6 @@ struct jme_adapter {
 	atomic_t		rx_cleaning;
 	atomic_t		rx_empty;
 	int			(*jme_rx)(struct sk_buff *skb);
-	int			(*jme_vlan_rx)(struct sk_buff *skb,
-					  struct vlan_group *grp,
-					  unsigned short vlan_tag);
 	DECLARE_NAPI_STRUCT
 	DECLARE_NET_DEVICE_STATS
 };
-- 
1.7.6

