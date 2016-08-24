From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4: Add support for ndo_get_vf_config
Date: Wed, 24 Aug 2016 12:20:34 +0530
Message-ID: <1472021434-8287-3-git-send-email-hariprasad@chelsio.com>
References: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:34651 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751972AbcHXGvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 02:51:44 -0400
In-Reply-To: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   10 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   77 ++++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |    2 +-
 3 files changed, 86 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index b20d345..2781658 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -788,6 +788,13 @@ struct uld_msix_info {
 	char desc[IFNAMSIZ + 10];
 };
 
+struct vf_info {
+	unsigned char vf_mac_addr[ETH_ALEN];
+	bool pf_set_mac;
+	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
+	u16 pf_qos;
+};
+
 struct adapter {
 	void __iomem *regs;
 	void __iomem *bar2;
@@ -821,6 +828,9 @@ struct adapter {
 	struct net_device *port[MAX_NPORTS];
 	u8 chan_map[NCHAN];                   /* channel -> port map */
 
+	struct vf_info *vfinfo;
+	u8 num_vfs;
+
 	u32 filter_mode;
 	unsigned int l2t_start;
 	unsigned int l2t_end;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 330e18a..9baab2c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3094,10 +3094,43 @@ static int dummy_open(struct net_device *dev)
 	return 0;
 }
 
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
@@ -3109,14 +3142,22 @@ static int cxgb_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
 
 	dev_info(pi->adapter->pdev_dev,
 		 "Setting MAC %pM on VF %d\n", mac, vf);
-	return t4_set_vf_mac_acl(adap, vf + 1, 1, mac);
+	ret = t4_set_vf_mac_acl(adap, vf + 1, 1, mac);
+	if (!ret)
+		ether_addr_copy(adap->vfinfo[vf].vf_mac_addr, mac);
+	return ret;
 }
 
 static int cxgb_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos)
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adap = pi->adapter;
+	int ret;
 
+	if (vf >= adap->num_vfs) {
+		dev_err(pi->adapter->pdev_dev, "Invalid VF %d\n", vf);
+		return -EINVAL;
+	}
 	if (vlan > 4095 || qos > 7) {
 		dev_err(pi->adapter->pdev_dev,
 			"Illegal vlan value %u qos %u\n", vlan, qos);
@@ -3129,7 +3170,27 @@ static int cxgb_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos)
 		 "The VF [%d] interface needs to brought down and up, "
 		 "if VF is already up and running, for VST to work\n", vf);
 	vlan |= qos << VLAN_PRIO_SHIFT;
-	return t4_set_vf_vlan_acl(adap, vf + 1, vlan);
+	ret = t4_set_vf_vlan_acl(adap, vf + 1, vlan);
+	if (!ret) {
+		adap->vfinfo[vf].pf_vlan = vlan & VLAN_VID_MASK;
+		adap->vfinfo[vf].pf_qos = qos;
+	}
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
+	ivi->vlan = adap->vfinfo[vf].pf_vlan;
+	ivi->qos = adap->vfinfo[vf].pf_qos;
+	return 0;
 }
 #endif
 
@@ -3280,6 +3341,7 @@ static const struct net_device_ops cxgb4_mgmt_netdev_ops = {
 	.ndo_open             = dummy_open,
 	.ndo_set_vf_mac       = cxgb_set_vf_mac,
 	.ndo_set_vf_vlan      = cxgb_set_vf_vlan,
+	.ndo_get_vf_config    = cxgb_get_vf_config,
 };
 #endif
 
@@ -5137,6 +5199,10 @@ static int cxgb4_iov_configure(struct pci_dev *pdev, int num_vfs)
 			unregister_netdev(adap->port[0]);
 			adap->port[0] = NULL;
 		}
+		/* free VF resources */
+		kfree(adap->vfinfo);
+		adap->vfinfo = NULL;
+		adap->num_vfs = 0;
 		return num_vfs;
 	}
 
@@ -5145,10 +5211,16 @@ static int cxgb4_iov_configure(struct pci_dev *pdev, int num_vfs)
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
@@ -5642,6 +5714,7 @@ static void remove_one(struct pci_dev *pdev)
 		if (adapter->port[0])
 			unregister_netdev(adapter->port[0]);
 		iounmap(adapter->regs);
+		kfree(adapter->vfinfo);
 		kfree(adapter);
 		pci_disable_sriov(pdev);
 		pci_release_regions(pdev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 210979c..f215aef 100644
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
