From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] net: use pci_dev->revision, again
Date: Mon, 28 Feb 2011 21:36:43 +0300
Message-ID: <201102282136.44374.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, jie.yang@atheros.com,
	romieu@fr.zoreil.com, sorbica@icplus.com.tw,
	cooldavid@cooldavid.org, linville@tuxdriver.com,
	Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	e1000-devel@lists.sourceforge.net, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:56498 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752915Ab1B1SiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 13:38:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several more network drivers that read the device's revision ID
from the PCI configuration register were merged after the commit
44c10138fd4bbc4b6d6bff0873c24902f2a9da65 (PCI: Change all drivers
to use pci_device->revision), so it's time to do another pass of
conversion to using the 'revision' field of 'struct pci_dev'...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.

 drivers/net/atl1e/atl1e_main.c          |    2 +-
 drivers/net/atlx/atl2.c                 |    2 +-
 drivers/net/cnic.c                      |   14 +++++---------
 drivers/net/e1000e/ethtool.c            |    6 ++----
 drivers/net/igbvf/ethtool.c             |    6 ++----
 drivers/net/igbvf/netdev.c              |    3 +--
 drivers/net/ipg.c                       |    4 +---
 drivers/net/ixgbevf/ixgbevf_main.c      |    2 +-
 drivers/net/jme.c                       |    2 +-
 drivers/net/vxge/vxge-main.c            |   18 +-----------------
 drivers/net/wireless/iwlwifi/iwl-3945.c |    4 +---
 drivers/net/wireless/iwlwifi/iwl-agn.c  |    2 +-
 drivers/net/wireless/rtlwifi/pci.c      |    4 +---
 13 files changed, 19 insertions(+), 50 deletions(-)

Index: linux-2.6/drivers/net/atl1e/atl1e_main.c
===================================================================
--- linux-2.6.orig/drivers/net/atl1e/atl1e_main.c
+++ linux-2.6/drivers/net/atl1e/atl1e_main.c
@@ -547,8 +547,8 @@ static int __devinit atl1e_sw_init(struc
 	hw->device_id = pdev->device;
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_id = pdev->subsystem_device;
+	hw->revision_id  = pdev->revision;
 
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
 	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
 
 	phy_status_data = AT_READ_REG(hw, REG_PHY_STATUS);
Index: linux-2.6/drivers/net/atlx/atl2.c
===================================================================
--- linux-2.6.orig/drivers/net/atlx/atl2.c
+++ linux-2.6/drivers/net/atlx/atl2.c
@@ -93,8 +93,8 @@ static int __devinit atl2_sw_init(struct
 	hw->device_id = pdev->device;
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_id = pdev->subsystem_device;
+	hw->revision_id  = pdev->revision;
 
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
 	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
 
 	adapter->wol = 0;
Index: linux-2.6/drivers/net/cnic.c
===================================================================
--- linux-2.6.orig/drivers/net/cnic.c
+++ linux-2.6/drivers/net/cnic.c
@@ -5264,15 +5264,11 @@ static struct cnic_dev *init_bnx2_cnic(s
 
 	dev_hold(dev);
 	pci_dev_get(pdev);
-	if (pdev->device == PCI_DEVICE_ID_NX2_5709 ||
-	    pdev->device == PCI_DEVICE_ID_NX2_5709S) {
-		u8 rev;
-
-		pci_read_config_byte(pdev, PCI_REVISION_ID, &rev);
-		if (rev < 0x10) {
-			pci_dev_put(pdev);
-			goto cnic_err;
-		}
+	if ((pdev->device == PCI_DEVICE_ID_NX2_5709 ||
+	     pdev->device == PCI_DEVICE_ID_NX2_5709S) &&
+	    (pdev->revision < 0x10)) {
+		pci_dev_put(pdev);
+		goto cnic_err;
 	}
 	pci_dev_put(pdev);
 
Index: linux-2.6/drivers/net/e1000e/ethtool.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000e/ethtool.c
+++ linux-2.6/drivers/net/e1000e/ethtool.c
@@ -433,13 +433,11 @@ static void e1000_get_regs(struct net_de
 	struct e1000_hw *hw = &adapter->hw;
 	u32 *regs_buff = p;
 	u16 phy_data;
-	u8 revision_id;
 
 	memset(p, 0, E1000_REGS_LEN * sizeof(u32));
 
-	pci_read_config_byte(adapter->pdev, PCI_REVISION_ID, &revision_id);
-
-	regs->version = (1 << 24) | (revision_id << 16) | adapter->pdev->device;
+	regs->version = (1 << 24) | (adapter->pdev->revision << 16) |
+			adapter->pdev->device;
 
 	regs_buff[0]  = er32(CTRL);
 	regs_buff[1]  = er32(STATUS);
Index: linux-2.6/drivers/net/igbvf/ethtool.c
===================================================================
--- linux-2.6.orig/drivers/net/igbvf/ethtool.c
+++ linux-2.6/drivers/net/igbvf/ethtool.c
@@ -201,13 +201,11 @@ static void igbvf_get_regs(struct net_de
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 *regs_buff = p;
-	u8 revision_id;
 
 	memset(p, 0, IGBVF_REGS_LEN * sizeof(u32));
 
-	pci_read_config_byte(adapter->pdev, PCI_REVISION_ID, &revision_id);
-
-	regs->version = (1 << 24) | (revision_id << 16) | adapter->pdev->device;
+	regs->version = (1 << 24) | (adapter->pdev->revision << 16) |
+			adapter->pdev->device;
 
 	regs_buff[0] = er32(CTRL);
 	regs_buff[1] = er32(STATUS);
Index: linux-2.6/drivers/net/igbvf/netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/igbvf/netdev.c
+++ linux-2.6/drivers/net/igbvf/netdev.c
@@ -2699,8 +2699,7 @@ static int __devinit igbvf_probe(struct 
 	hw->device_id = pdev->device;
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_device_id = pdev->subsystem_device;
-
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
+	hw->revision_id = pdev->revision;
 
 	err = -EIO;
 	adapter->hw.hw_addr = ioremap(pci_resource_start(pdev, 0),
Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -2025,7 +2025,6 @@ static void ipg_init_mii(struct net_devi
 
 	if (phyaddr != 0x1f) {
 		u16 mii_phyctrl, mii_1000cr;
-		u8 revisionid = 0;
 
 		mii_1000cr  = mdio_read(dev, phyaddr, MII_CTRL1000);
 		mii_1000cr |= ADVERTISE_1000FULL | ADVERTISE_1000HALF |
@@ -2035,8 +2034,7 @@ static void ipg_init_mii(struct net_devi
 		mii_phyctrl = mdio_read(dev, phyaddr, MII_BMCR);
 
 		/* Set default phyparam */
-		pci_read_config_byte(sp->pdev, PCI_REVISION_ID, &revisionid);
-		ipg_set_phy_default_param(revisionid, dev, phyaddr);
+		ipg_set_phy_default_param(sp->pdev->revision, dev, phyaddr);
 
 		/* Reset PHY */
 		mii_phyctrl |= BMCR_RESET | BMCR_ANRESTART;
Index: linux-2.6/drivers/net/ixgbevf/ixgbevf_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgbevf/ixgbevf_main.c
+++ linux-2.6/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2216,7 +2216,7 @@ static int __devinit ixgbevf_sw_init(str
 
 	hw->vendor_id = pdev->vendor;
 	hw->device_id = pdev->device;
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
+	hw->revision_id = pdev->revision;
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_device_id = pdev->subsystem_device;
 
Index: linux-2.6/drivers/net/jme.c
===================================================================
--- linux-2.6.orig/drivers/net/jme.c
+++ linux-2.6/drivers/net/jme.c
@@ -2937,7 +2937,7 @@ jme_init_one(struct pci_dev *pdev,
 
 	jme_clear_pm(jme);
 	jme_set_phyfifoa(jme);
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &jme->rev);
+	jme->rev = pdev->revision;
 	if (!jme->fpgaver)
 		jme_phy_init(jme);
 	jme_phy_off(jme);
Index: linux-2.6/drivers/net/vxge/vxge-main.c
===================================================================
--- linux-2.6.orig/drivers/net/vxge/vxge-main.c
+++ linux-2.6/drivers/net/vxge/vxge-main.c
@@ -3264,19 +3264,6 @@ static const struct net_device_ops vxge_
 #endif
 };
 
-static int __devinit vxge_device_revision(struct vxgedev *vdev)
-{
-	int ret;
-	u8 revision;
-
-	ret = pci_read_config_byte(vdev->pdev, PCI_REVISION_ID, &revision);
-	if (ret)
-		return -EIO;
-
-	vdev->titan1 = (revision == VXGE_HW_TITAN1_PCI_REVISION);
-	return 0;
-}
-
 static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 					  struct vxge_config *config,
 					  int high_dma, int no_of_vpath,
@@ -3316,10 +3303,7 @@ static int __devinit vxge_device_registe
 	memcpy(&vdev->config, config, sizeof(struct vxge_config));
 	vdev->rx_csum = 1;	/* Enable Rx CSUM by default. */
 	vdev->rx_hwts = 0;
-
-	ret = vxge_device_revision(vdev);
-	if (ret < 0)
-		goto _out1;
+	vdev->titan1 = (vdev->pdev->revision == VXGE_HW_TITAN1_PCI_REVISION);
 
 	SET_NETDEV_DEV(ndev, &vdev->pdev->dev);
 
Index: linux-2.6/drivers/net/wireless/iwlwifi/iwl-3945.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ linux-2.6/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -898,13 +898,11 @@ static void iwl3945_nic_config(struct iw
 {
 	struct iwl3945_eeprom *eeprom = (struct iwl3945_eeprom *)priv->eeprom;
 	unsigned long flags;
-	u8 rev_id = 0;
+	u8 rev_id = priv->pci_dev->revision;
 
 	spin_lock_irqsave(&priv->lock, flags);
 
 	/* Determine HW type */
-	pci_read_config_byte(priv->pci_dev, PCI_REVISION_ID, &rev_id);
-
 	IWL_DEBUG_INFO(priv, "HW Revision ID = 0x%X\n", rev_id);
 
 	if (rev_id & PCI_CFG_REV_ID_BIT_RTP)
Index: linux-2.6/drivers/net/wireless/iwlwifi/iwl-agn.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ linux-2.6/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3905,7 +3905,7 @@ static void iwl_hw_detect(struct iwl_pri
 {
 	priv->hw_rev = _iwl_read32(priv, CSR_HW_REV);
 	priv->hw_wa_rev = _iwl_read32(priv, CSR_HW_REV_WA_REG);
-	pci_read_config_byte(priv->pci_dev, PCI_REVISION_ID, &priv->rev_id);
+	priv->rev_id = priv->pci_dev->revision;
 	IWL_DEBUG_INFO(priv, "HW Revision ID = 0x%X\n", priv->rev_id);
 }
 
Index: linux-2.6/drivers/net/wireless/rtlwifi/pci.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/rtlwifi/pci.c
+++ linux-2.6/drivers/net/wireless/rtlwifi/pci.c
@@ -1547,13 +1547,11 @@ static bool _rtl_pci_find_adapter(struct
 	struct pci_dev *bridge_pdev = pdev->bus->self;
 	u16 venderid;
 	u16 deviceid;
-	u8 revisionid;
 	u16 irqline;
 	u8 tmp;
 
 	venderid = pdev->vendor;
 	deviceid = pdev->device;
-	pci_read_config_byte(pdev, 0x8, &revisionid);
 	pci_read_config_word(pdev, 0x3C, &irqline);
 
 	if (deviceid == RTL_PCI_8192_DID ||
@@ -1564,7 +1562,7 @@ static bool _rtl_pci_find_adapter(struct
 	    deviceid == RTL_PCI_8173_DID ||
 	    deviceid == RTL_PCI_8172_DID ||
 	    deviceid == RTL_PCI_8171_DID) {
-		switch (revisionid) {
+		switch (pdev->revision) {
 		case RTL_PCI_REVISION_ID_8192PCIE:
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 				 ("8192 PCI-E is found - "
