From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 1/3] enic: Add SRIOV support
Date: Thu, 22 Sep 2011 06:44:33 -0700
Message-ID: <20110922134432.2145.35774.stgit@savbu-pc100.cisco.com>
References: <20110922134410.2145.72210.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-2.cisco.com ([173.36.130.13]:12959 "EHLO
	mtv-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab1IVNoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 09:44:34 -0400
In-Reply-To: <20110922134410.2145.72210.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support to enable SRIOV on enic devices. Enic SRIOV VF's are dynamic vnics and will use the same driver code as dynamic vnics.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |   11 ++++++
 drivers/net/ethernet/cisco/enic/enic_main.c |   48 ++++++++++++++++++++++++++-
 2 files changed, 57 insertions(+), 2 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index ce76d9a..13ff78e 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.24"
+#define DRV_VERSION		"2.1.1.28"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
@@ -49,6 +49,10 @@ struct enic_msix_entry {
 	void *devid;
 };
 
+/* priv_flags */
+#define ENIC_SRIOV_ENABLED		(1 << 0)
+
+/* enic port profile set flags */
 #define ENIC_PORT_REQUEST_APPLIED	(1 << 0)
 #define ENIC_SET_REQUEST		(1 << 1)
 #define ENIC_SET_NAME			(1 << 2)
@@ -83,11 +87,15 @@ struct enic {
 	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
 	u8 uc_addr[ENIC_UNICAST_PERFECT_FILTERS][ETH_ALEN];
 	unsigned int flags;
+	unsigned int priv_flags;
 	unsigned int mc_count;
 	unsigned int uc_count;
 	u32 port_mtu;
 	u32 rx_coalesce_usecs;
 	u32 tx_coalesce_usecs;
+#ifdef CONFIG_PCI_IOV
+	u32 num_vfs;
+#endif
 	struct enic_port_profile pp;
 
 	/* work queue cache line section */
@@ -120,5 +128,6 @@ static inline struct device *enic_get_dev(struct enic *enic)
 }
 
 void enic_reset_addr_lists(struct enic *enic);
+int enic_sriov_enabled(struct enic *enic);
 
 #endif /* _ENIC_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index c751c25..ad6580e 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -127,6 +127,11 @@ static int enic_is_dynamic(struct enic *enic)
 	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_DYN;
 }
 
+int enic_sriov_enabled(struct enic *enic)
+{
+	return (enic->priv_flags & ENIC_SRIOV_ENABLED) ? 1 : 0;
+}
+
 static inline unsigned int enic_cq_rq(struct enic *enic, unsigned int rq)
 {
 	return rq;
@@ -2240,6 +2245,9 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	int using_dac = 0;
 	unsigned int i;
 	int err;
+#ifdef CONFIG_PCI_IOV
+	int pos = 0;
+#endif
 
 	/* Allocate net device structure and initialize.  Private
 	 * instance data is initialized to zero.
@@ -2331,13 +2339,32 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}
 
+#ifdef CONFIG_PCI_IOV
+	/* Get number of subvnics */
+	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
+	if (pos) {
+		pci_read_config_word(pdev, pos + PCI_SRIOV_TOTAL_VF,
+			(u16 *)&enic->num_vfs);
+		if (enic->num_vfs) {
+			err = pci_enable_sriov(pdev, enic->num_vfs);
+			if (err) {
+				dev_err(dev, "SRIOV enable failed, aborting."
+					" pci_enable_sriov() returned %d\n",
+					err);
+				goto err_out_vnic_unregister;
+			}
+			enic->priv_flags |= ENIC_SRIOV_ENABLED;
+		}
+	}
+
+#endif
 	/* Issue device open to get device in known state
 	 */
 
 	err = enic_dev_open(enic);
 	if (err) {
 		dev_err(dev, "vNIC dev open failed, aborting\n");
-		goto err_out_vnic_unregister;
+		goto err_out_disable_sriov;
 	}
 
 	/* Setup devcmd lock
@@ -2404,6 +2431,12 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	enic->port_mtu = enic->config.mtu;
 	(void)enic_change_mtu(netdev, enic->port_mtu);
 
+#ifdef CONFIG_PCI_IOV
+	if (enic_is_dynamic(enic) && pdev->is_virtfn &&
+		is_zero_ether_addr(enic->mac_addr))
+		random_ether_addr(enic->mac_addr);
+#endif
+
 	err = enic_set_mac_addr(netdev, enic->mac_addr);
 	if (err) {
 		dev_err(dev, "Invalid MAC address, aborting\n");
@@ -2455,8 +2488,15 @@ err_out_dev_deinit:
 	enic_dev_deinit(enic);
 err_out_dev_close:
 	vnic_dev_close(enic->vdev);
+err_out_disable_sriov:
+#ifdef CONFIG_PCI_IOV
+	if (enic_sriov_enabled(enic)) {
+		pci_disable_sriov(pdev);
+		enic->priv_flags &= ~ENIC_SRIOV_ENABLED;
+	}
 err_out_vnic_unregister:
 	vnic_dev_unregister(enic->vdev);
+#endif
 err_out_iounmap:
 	enic_iounmap(enic);
 err_out_release_regions:
@@ -2482,6 +2522,12 @@ static void __devexit enic_remove(struct pci_dev *pdev)
 		unregister_netdev(netdev);
 		enic_dev_deinit(enic);
 		vnic_dev_close(enic->vdev);
+#ifdef CONFIG_PCI_IOV
+		if (enic_sriov_enabled(enic)) {
+			pci_disable_sriov(pdev);
+			enic->priv_flags &= ~ENIC_SRIOV_ENABLED;
+		}
+#endif
 		vnic_dev_unregister(enic->vdev);
 		enic_iounmap(enic);
 		pci_release_regions(pdev);
