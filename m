From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Implement ndo_get_phys_port_id for mgmt dev
Date: Tue, 17 Jan 2017 14:09:38 +0530
Message-ID: <1484642378-7250-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, hariprasad@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:37141 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750900AbdAQIkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 03:40:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 27 +++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e95bb6a..668acfc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2583,6 +2583,19 @@ static int cxgb_get_vf_config(struct net_device *dev,
 	ether_addr_copy(ivi->mac, adap->vfinfo[vf].vf_mac_addr);
 	return 0;
 }
+
+static int cxgb_get_phys_port_id(struct net_device *dev,
+				 struct netdev_phys_item_id *ppid)
+{
+	struct port_info *pi = netdev_priv(dev);
+	unsigned int phy_port_id;
+
+	phy_port_id = pi->adapter->adap_idx * 10 + pi->port_id;
+	ppid->id_len = sizeof(phy_port_id);
+	memcpy(ppid->id, &phy_port_id, ppid->id_len);
+	return 0;
+}
+
 #endif
 
 static int cxgb_set_mac_addr(struct net_device *dev, void *p)
@@ -2762,6 +2775,7 @@ static const struct net_device_ops cxgb4_mgmt_netdev_ops = {
 	.ndo_open             = dummy_open,
 	.ndo_set_vf_mac       = cxgb_set_vf_mac,
 	.ndo_get_vf_config    = cxgb_get_vf_config,
+	.ndo_get_phys_port_id = cxgb_get_phys_port_id,
 };
 #endif
 
@@ -4523,6 +4537,7 @@ static int config_mgmt_dev(struct pci_dev *pdev)
 
 	pi = netdev_priv(netdev);
 	pi->adapter = adap;
+	pi->port_id = adap->pf % adap->params.nports;
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	adap->port[0] = netdev;
@@ -4612,6 +4627,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u32 whoami, pl_rev;
 	enum chip_type chip;
 	static int adap_idx = 1;
+	u32 v, port_vec;
 
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
 
@@ -4993,6 +5009,17 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	spin_lock_init(&adapter->mbox_lock);
 	INIT_LIST_HEAD(&adapter->mlist.list);
+
+	v = FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
+	    FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_PORTVEC);
+	err = t4_query_params(adapter, adapter->mbox, adapter->pf, 0, 1,
+			      &v, &port_vec);
+	if (err < 0) {
+		dev_err(adapter->pdev_dev, "Could not fetch port params\n");
+		goto free_adapter;
+	}
+
+	adapter->params.nports = hweight32(port_vec);
 	pci_set_drvdata(pdev, adapter);
 	return 0;
 
-- 
2.1.0
