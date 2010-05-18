From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 2/3] cxgb4: keep interrupts available when the ports are brought down
Date: Tue, 18 May 2010 13:07:12 -0700
Message-ID: <1274213233-26309-2-git-send-email-dm@chelsio.com>
References: <1274213233-26309-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11342 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758204Ab0ERUHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 16:07:17 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o4IK7EJN008159
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 13:07:14 -0700
In-Reply-To: <1274213233-26309-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PF driver needs to remain alert while its ports are down to service
requests or errors from virtual functions or FW so keep interrupts and
queues available when the ports are brought down.  The change makes
open_device_map unnecessary so remove it.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    1 -
 drivers/net/cxgb4/cxgb4_main.c |   49 ++++++++++++++++++----------------------
 2 files changed, 22 insertions(+), 28 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index d3a5c34..dd1770e 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -477,7 +477,6 @@ struct adapter {
 	struct pci_dev *pdev;
 	struct device *pdev_dev;
 	unsigned long registered_device_map;
-	unsigned long open_device_map;
 	unsigned long flags;
 
 	const char *name;
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 1f59971..87161ce 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2433,23 +2433,17 @@ EXPORT_SYMBOL(cxgb4_unregister_uld);
  */
 static int cxgb_up(struct adapter *adap)
 {
-	int err = 0;
+	int err;
 
-	if (!(adap->flags & FULL_INIT_DONE)) {
-		err = setup_sge_queues(adap);
-		if (err)
-			goto out;
-		err = setup_rss(adap);
-		if (err) {
-			t4_free_sge_resources(adap);
-			goto out;
-		}
-		if (adap->flags & USING_MSIX)
-			name_msix_vecs(adap);
-		adap->flags |= FULL_INIT_DONE;
-	}
+	err = setup_sge_queues(adap);
+	if (err)
+		goto out;
+	err = setup_rss(adap);
+	if (err)
+		goto freeq;
 
 	if (adap->flags & USING_MSIX) {
+		name_msix_vecs(adap);
 		err = request_irq(adap->msix_info[0].vec, t4_nondata_intr, 0,
 				  adap->msix_info[0].desc, adap);
 		if (err)
@@ -2470,11 +2464,14 @@ static int cxgb_up(struct adapter *adap)
 	enable_rx(adap);
 	t4_sge_start(adap);
 	t4_intr_enable(adap);
+	adap->flags |= FULL_INIT_DONE;
 	notify_ulds(adap, CXGB4_STATE_UP);
  out:
 	return err;
  irq_err:
 	dev_err(adap->pdev_dev, "request_irq failed, err %d\n", err);
+ freeq:
+	t4_free_sge_resources(adap);
 	goto out;
 }
 
@@ -2490,6 +2487,9 @@ static void cxgb_down(struct adapter *adapter)
 	} else
 		free_irq(adapter->pdev->irq, adapter);
 	quiesce_rx(adapter);
+	t4_sge_stop(adapter);
+	t4_free_sge_resources(adapter);
+	adapter->flags &= ~FULL_INIT_DONE;
 }
 
 /*
@@ -2501,11 +2501,13 @@ static int cxgb_open(struct net_device *dev)
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
 
-	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0)
-		return err;
+	if (!(adapter->flags & FULL_INIT_DONE)) {
+		err = cxgb_up(adapter);
+		if (err < 0)
+			return err;
+	}
 
 	dev->real_num_tx_queues = pi->nqsets;
-	set_bit(pi->tx_chan, &adapter->open_device_map);
 	link_start(dev);
 	netif_tx_start_all_queues(dev);
 	return 0;
@@ -2513,19 +2515,12 @@ static int cxgb_open(struct net_device *dev)
 
 static int cxgb_close(struct net_device *dev)
 {
-	int ret;
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
 
 	netif_tx_stop_all_queues(dev);
 	netif_carrier_off(dev);
-	ret = t4_enable_vi(adapter, 0, pi->viid, false, false);
-
-	clear_bit(pi->tx_chan, &adapter->open_device_map);
-
-	if (!adapter->open_device_map)
-		cxgb_down(adapter);
-	return 0;
+	return t4_enable_vi(adapter, 0, pi->viid, false, false);
 }
 
 static struct net_device_stats *cxgb_get_stats(struct net_device *dev)
@@ -3360,8 +3355,8 @@ static void __devexit remove_one(struct pci_dev *pdev)
 		if (adapter->debugfs_root)
 			debugfs_remove_recursive(adapter->debugfs_root);
 
-		t4_sge_stop(adapter);
-		t4_free_sge_resources(adapter);
+		if (adapter->flags & FULL_INIT_DONE)
+			cxgb_down(adapter);
 		t4_free_mem(adapter->l2t);
 		t4_free_mem(adapter->tids.tid_tab);
 		disable_msi(adapter);
-- 
1.5.4

