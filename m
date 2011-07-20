From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 13/47] chelsio: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:15 +0200
Message-ID: <1311173689-17419-14-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747Ab1GTOzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:17 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlan_grp and t1_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/chelsio/common.h |    2 --
 drivers/net/chelsio/cxgb2.c  |   39 +++++++++++++++++++++++++--------------
 drivers/net/chelsio/sge.c    |   18 ++++++++----------
 drivers/net/chelsio/sge.h    |    2 +-
 4 files changed, 34 insertions(+), 27 deletions(-)

diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index c26d863..5ccbed1 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -240,8 +240,6 @@ struct adapter {
 	struct work_struct ext_intr_handler_task;
 	struct adapter_params params;
 
-	struct vlan_group *vlan_grp;
-
 	/* Terminator modules. */
 	struct sge    *sge;
 	struct peespi *espi;
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index b422d83..3edbbc4 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -263,6 +263,8 @@ static int cxgb_open(struct net_device *dev)
 	if (!other_ports && adapter->params.stats_update_period)
 		schedule_mac_stats_update(adapter,
 					  adapter->params.stats_update_period);
+
+	t1_vlan_mode(adapter, dev->features);
 	return 0;
 }
 
@@ -849,19 +851,30 @@ static int t1_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-static void t1_vlan_rx_register(struct net_device *dev,
-				   struct vlan_group *grp)
+static u32 t1_fix_features(struct net_device *dev, u32 features)
 {
-	struct adapter *adapter = dev->ml_priv;
+	/*
+	 * Since there is no support for separate rx/tx vlan accel
+	 * enable/disable make sure tx flag is always in same state as rx.
+	 */
+	if (features & NETIF_F_HW_VLAN_RX)
+		features |= NETIF_F_HW_VLAN_TX;
+	else
+		features &= ~NETIF_F_HW_VLAN_TX;
 
-	spin_lock_irq(&adapter->async_lock);
-	adapter->vlan_grp = grp;
-	t1_set_vlan_accel(adapter, grp != NULL);
-	spin_unlock_irq(&adapter->async_lock);
+	return features;
 }
-#endif
 
+static int t1_set_features(struct net_device *dev, u32 features)
+{
+	u32 changed = dev->features ^ features;
+	struct adapter *adapter = dev->ml_priv;
+
+	if (changed & NETIF_F_HW_VLAN_RX)
+		t1_vlan_mode(adapter, features);
+
+	return 0;
+}
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void t1_netpoll(struct net_device *dev)
 {
@@ -955,9 +968,8 @@ static const struct net_device_ops cxgb_netdev_ops = {
 	.ndo_do_ioctl		= t1_ioctl,
 	.ndo_change_mtu		= t1_change_mtu,
 	.ndo_set_mac_address	= t1_set_mac_addr,
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-	.ndo_vlan_rx_register	= t1_vlan_rx_register,
-#endif
+	.ndo_fix_features	= t1_fix_features,
+	.ndo_set_features	= t1_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= t1_netpoll,
 #endif
@@ -1080,10 +1092,9 @@ static int __devinit init_one(struct pci_dev *pdev,
 		if (pci_using_dac)
 			netdev->features |= NETIF_F_HIGHDMA;
 		if (vlan_tso_capable(adapter)) {
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 			netdev->features |=
 				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
+			netdev->hw_features |= NETIF_F_HW_VLAN_RX;
 
 			/* T204: disable TSO */
 			if (!(is_T2(adapter)) || bi->port_number != 4) {
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 58380d2..e9a03ff 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -742,13 +742,14 @@ static inline void setup_ring_params(struct adapter *adapter, u64 addr,
 /*
  * Enable/disable VLAN acceleration.
  */
-void t1_set_vlan_accel(struct adapter *adapter, int on_off)
+void t1_vlan_mode(struct adapter *adapter, u32 features)
 {
 	struct sge *sge = adapter->sge;
 
-	sge->sge_control &= ~F_VLAN_XTRACT;
-	if (on_off)
+	if (features & NETIF_F_HW_VLAN_RX)
 		sge->sge_control |= F_VLAN_XTRACT;
+	else
+		sge->sge_control &= ~F_VLAN_XTRACT;
 	if (adapter->open_device_map) {
 		writel(sge->sge_control, adapter->regs + A_SG_CONTROL);
 		readl(adapter->regs + A_SG_CONTROL);   /* flush */
@@ -1397,12 +1398,11 @@ static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 	} else
 		skb_checksum_none_assert(skb);
 
-	if (unlikely(adapter->vlan_grp && p->vlan_valid)) {
+	if (p->vlan_valid) {
 		st->vlan_xtract++;
-		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
-					 ntohs(p->vlan));
-	} else
-		netif_receive_skb(skb);
+		__vlan_hwaccel_put_tag(skb, ntohs(p->vlan));
+	}
+	netif_receive_skb(skb);
 }
 
 /*
@@ -1875,13 +1875,11 @@ netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	cpl->iff = dev->if_port;
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 	if (vlan_tx_tag_present(skb)) {
 		cpl->vlan_valid = 1;
 		cpl->vlan = htons(vlan_tx_tag_get(skb));
 		st->vlan_insert++;
 	} else
-#endif
 		cpl->vlan_valid = 0;
 
 send:
diff --git a/drivers/net/chelsio/sge.h b/drivers/net/chelsio/sge.h
index 00cc37f..e03980b 100644
--- a/drivers/net/chelsio/sge.h
+++ b/drivers/net/chelsio/sge.h
@@ -79,7 +79,7 @@ irqreturn_t t1_interrupt(int irq, void *cookie);
 int t1_poll(struct napi_struct *, int);
 
 netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev);
-void t1_set_vlan_accel(struct adapter *adapter, int on_off);
+void t1_vlan_mode(struct adapter *adapter, u32 features);
 void t1_sge_start(struct sge *);
 void t1_sge_stop(struct sge *);
 int t1_sge_intr_error_handler(struct sge *);
-- 
1.7.6

