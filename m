From: Roland Dreier <roland@kernel.org>
Subject: [PATCH] cxgb3: Don't call cxgb_vlan_mode until q locks are initialized
Date: Mon, 30 Apr 2012 10:15:47 -0700
Message-ID: <1335806147-17310-1-git-send-email-roland@kernel.org>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>
To: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog102.obsmtp.com ([74.125.245.72]:34940 "HELO
	na3sys010aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753211Ab2D3RPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:15:53 -0400
Received: by pbcwz7 with SMTP id wz7so1749798pbc.16
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 10:15:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@purestorage.com>

The driver calls cxgb_vlan_mode() from init_one().  This calls into
synchronize_rx(), which locks all the q locks, but the q locks are not
initialized until cxgb_up() -> setup_sge_qsets().  So move the call to
cxgb_vlan_mode() into cxgb_up(), after the call to setup_sge_qsets().
We also move the body of these functions up higher to avoid having to
a forward declaration.

This was found because of the lockdep warning:

    INFO: trying to register non-static key.
    the code is fine but needs lockdep annotation.
    turning off the locking correctness validator.
    Pid: 323, comm: work_for_cpu Not tainted 3.4.0-rc5 #28
    Call Trace:
     [<ffffffff8106e767>] register_lock_class+0x108/0x2d0
     [<ffffffff8106ff42>] __lock_acquire+0xd3/0xd06
     [<ffffffff81070fd0>] lock_acquire+0xbf/0xfe
     [<ffffffff813862a6>] _raw_spin_lock_irq+0x36/0x45
     [<ffffffffa01e71aa>] cxgb_vlan_mode+0x96/0xcb [cxgb3]
     [<ffffffffa01f90eb>] init_one+0x8c4/0x980 [cxgb3]
     [<ffffffff811fcbf0>] local_pci_probe+0x3f/0x70
     [<ffffffff81042206>] do_work_for_cpu+0x10/0x22
     [<ffffffff810482de>] kthread+0xa1/0xa9
     [<ffffffff8138e234>] kernel_thread_helper+0x4/0x10

Contrary to what lockdep says, the code is not fine: we are locking an
uninitialized spinlock.

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c |   92 +++++++++++------------
 1 file changed, 46 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 63bfdd1..abb6ce7 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1150,6 +1150,48 @@ release_tpsram:
 }
 
 /**
+ * t3_synchronize_rx - wait for current Rx processing on a port to complete
+ * @adap: the adapter
+ * @p: the port
+ *
+ * Ensures that current Rx processing on any of the queues associated with
+ * the given port completes before returning.  We do this by acquiring and
+ * releasing the locks of the response queues associated with the port.
+ */
+static void t3_synchronize_rx(struct adapter *adap, const struct port_info *p)
+{
+	int i;
+
+	for (i = p->first_qset; i < p->first_qset + p->nqsets; i++) {
+		struct sge_rspq *q = &adap->sge.qs[i].rspq;
+
+		spin_lock_irq(&q->lock);
+		spin_unlock_irq(&q->lock);
+	}
+}
+
+static void cxgb_vlan_mode(struct net_device *dev, netdev_features_t features)
+{
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+
+	if (adapter->params.rev > 0) {
+		t3_set_vlan_accel(adapter, 1 << pi->port_id,
+				  features & NETIF_F_HW_VLAN_RX);
+	} else {
+		/* single control for all ports */
+		unsigned int i, have_vlans = features & NETIF_F_HW_VLAN_RX;
+
+		for_each_port(adapter, i)
+			have_vlans |=
+				adapter->port[i]->features & NETIF_F_HW_VLAN_RX;
+
+		t3_set_vlan_accel(adapter, 1, have_vlans);
+	}
+	t3_synchronize_rx(adapter, pi);
+}
+
+/**
  *	cxgb_up - enable the adapter
  *	@adapter: adapter being enabled
  *
@@ -1161,7 +1203,7 @@ release_tpsram:
  */
 static int cxgb_up(struct adapter *adap)
 {
-	int err;
+	int i, err;
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		err = t3_check_fw_version(adap);
@@ -1198,6 +1240,9 @@ static int cxgb_up(struct adapter *adap)
 		if (err)
 			goto out;
 
+		for_each_port(adap, i)
+			cxgb_vlan_mode(adap->port[i], adap->port[i]->features);
+
 		setup_rss(adap);
 		if (!(adap->flags & NAPI_INIT))
 			init_napi(adap);
@@ -2508,48 +2553,6 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
-/**
- * t3_synchronize_rx - wait for current Rx processing on a port to complete
- * @adap: the adapter
- * @p: the port
- *
- * Ensures that current Rx processing on any of the queues associated with
- * the given port completes before returning.  We do this by acquiring and
- * releasing the locks of the response queues associated with the port.
- */
-static void t3_synchronize_rx(struct adapter *adap, const struct port_info *p)
-{
-	int i;
-
-	for (i = p->first_qset; i < p->first_qset + p->nqsets; i++) {
-		struct sge_rspq *q = &adap->sge.qs[i].rspq;
-
-		spin_lock_irq(&q->lock);
-		spin_unlock_irq(&q->lock);
-	}
-}
-
-static void cxgb_vlan_mode(struct net_device *dev, netdev_features_t features)
-{
-	struct port_info *pi = netdev_priv(dev);
-	struct adapter *adapter = pi->adapter;
-
-	if (adapter->params.rev > 0) {
-		t3_set_vlan_accel(adapter, 1 << pi->port_id,
-				  features & NETIF_F_HW_VLAN_RX);
-	} else {
-		/* single control for all ports */
-		unsigned int i, have_vlans = features & NETIF_F_HW_VLAN_RX;
-
-		for_each_port(adapter, i)
-			have_vlans |=
-				adapter->port[i]->features & NETIF_F_HW_VLAN_RX;
-
-		t3_set_vlan_accel(adapter, 1, have_vlans);
-	}
-	t3_synchronize_rx(adapter, pi);
-}
-
 static netdev_features_t cxgb_fix_features(struct net_device *dev,
 	netdev_features_t features)
 {
@@ -3353,9 +3356,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 	err = sysfs_create_group(&adapter->port[0]->dev.kobj,
 				 &cxgb3_attr_group);
 
-	for_each_port(adapter, i)
-		cxgb_vlan_mode(adapter->port[i], adapter->port[i]->features);
-
 	print_port_info(adapter, ai);
 	return 0;
 
-- 
1.7.9.5
