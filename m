From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add support for ndo_get_vf_config
Date: Fri,  2 Sep 2016 19:13:53 +0530
Message-ID: <1472823833-6256-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nirranjan@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:39036 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751691AbcIBNoa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 09:44:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for ndo_get_vf_config, also fill the default mac address
that will be provided to the VF by firmware, in case user doesn't
provide one. So user can get the default MAC address address also
through ndo_get_vf_config.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    8 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   64 ++++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |    2 +-
 3 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 3f7b33a..4595569 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -788,6 +788,11 @@ struct uld_msix_info {
 	char desc[IFNAMSIZ + 10];
 };
 
+struct vf_info {
+	unsigned char vf_mac_addr[ETH_ALEN];
+	bool pf_set_mac;
+};
+
 struct adapter {
 	void __iomem *regs;
 	void __iomem *bar2;
@@ -821,6 +826,9 @@ struct adapter {
 	struct net_device *port[MAX_NPORTS];
 	u8 chan_map[NCHAN];                   /* channel -> port map */
 
+	struct vf_info *vfinfo;
+	u8 num_vfs;
+
 	u32 filter_mode;
 	unsigned int l2t_start;
 	unsigned int l2t_end;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 44019bd..44cc976 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3094,10 +3094,44 @@ static int dummy_open(struct net_device *dev)
 	return 0;
 }
 
+/* Fill MAC address that will be assigned by the FW */
+static void fill_vf_station_mac_addr(struct adapter *adap)
+{
+	unsigned int i;
+	u8 hw_addr[ETH_ALEN], macaddr[ETH_ALEN];
+	int err;
+	u8 *na;
+	u16 a, b;
+
+	err = t4_get_raw_vpd_params(adap, &adap->params.vpd);
+	if (!err) {
+		na = adap->params.vpd.na;
+		for (i = 0; i < ETH_ALEN; i++)
+			hw_addr[i] = (hex2val(na[2 * i + 0]) * 16 +
+				      hex2val(na[2 * i + 1]));
+		a = (hw_addr[0] << 8) | hw_addr[1];
+		b = (hw_addr[1] << 8) | hw_addr[2];
+		a ^= b;
+		a |= 0x0200;    /* locally assigned Ethernet MAC address */
+		a &= ~0x0100;   /* not a multicast Ethernet MAC address */
+		macaddr[0] = a >> 8;
+		macaddr[1] = a & 0xff;
+
+		for (i = 2; i < 5; i++)
+			macaddr[i] = hw_addr[i + 1];
+
+		for (i = 0; i < adap->num_vfs; i++) {
+			macaddr[5] = adap->pf * 16 + i;
+			ether_addr_copy(adap->vfinfo[i].vf_mac_addr, macaddr);
+		}
+	}
+}
+
 static int cxgb_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adap = pi->adapter;
+	int ret;
 
 	/* verify MAC addr is valid */
 	if (!is_valid_ether_addr(mac)) {
@@ -3109,7 +3143,23 @@ static int cxgb_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
 
 	dev_info(pi->adapter->pdev_dev,
 		 "Setting MAC %pM on VF %d\n", mac, vf);
-	return t4_set_vf_mac_acl(adap, vf + 1, 1, mac);
+	ret = t4_set_vf_mac_acl(adap, vf + 1, 1, mac);
+	if (!ret)
+		ether_addr_copy(adap->vfinfo[vf].vf_mac_addr, mac);
+	return ret;
+}
+
+static int cxgb_get_vf_config(struct net_device *dev,
+			      int vf, struct ifla_vf_info *ivi)
+{
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
+
+	if (vf >= adap->num_vfs)
+		return -EINVAL;
+	ivi->vf = vf;
+	ether_addr_copy(ivi->mac, adap->vfinfo[vf].vf_mac_addr);
+	return 0;
 }
 #endif
 
@@ -3259,6 +3309,7 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 static const struct net_device_ops cxgb4_mgmt_netdev_ops = {
 	.ndo_open             = dummy_open,
 	.ndo_set_vf_mac       = cxgb_set_vf_mac,
+	.ndo_get_vf_config    = cxgb_get_vf_config,
 };
 #endif
 
@@ -5116,6 +5167,10 @@ static int cxgb4_iov_configure(struct pci_dev *pdev, int num_vfs)
 			unregister_netdev(adap->port[0]);
 			adap->port[0] = NULL;
 		}
+		/* free VF resources */
+		kfree(adap->vfinfo);
+		adap->vfinfo = NULL;
+		adap->num_vfs = 0;
 		return num_vfs;
 	}
 
@@ -5124,10 +5179,16 @@ static int cxgb4_iov_configure(struct pci_dev *pdev, int num_vfs)
 		if (err)
 			return err;
 
+		adap->num_vfs = num_vfs;
 		err = config_mgmt_dev(pdev);
 		if (err)
 			return err;
 	}
+
+	adap->vfinfo = kcalloc(adap->num_vfs,
+			       sizeof(struct vf_info), GFP_KERNEL);
+	if (adap->vfinfo)
+		fill_vf_station_mac_addr(adap);
 	return num_vfs;
 }
 #endif
@@ -5621,6 +5682,7 @@ static void remove_one(struct pci_dev *pdev)
 		if (adapter->port[0])
 			unregister_netdev(adapter->port[0]);
 		iounmap(adapter->regs);
+		kfree(adapter->vfinfo);
 		kfree(adapter);
 		pci_disable_sriov(pdev);
 		pci_release_regions(pdev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index de451ee..15be5432 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2729,7 +2729,7 @@ int t4_get_raw_vpd_params(struct adapter *adapter, struct vpd_params *p)
 
 out:
 	vfree(vpd);
-	return ret;
+	return ret < 0 ? ret : 0;
 }
 
 /**
-- 
1.7.3
