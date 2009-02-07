From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 17/26] igb: remove unnecessary adapter->hw calls when
	just hw-> will do.
Date: Sat, 07 Feb 2009 01:20:31 -0800
Message-ID: <20090207092031.15697.88279.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:55536
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755239AbZBGJUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:20:49 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There were several spots in the code making calls to adapter->hw when they
could have just been accessing hw-> directly.  I cleaned up the spots where
this was visibly apparent.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/igb/igb_main.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 2d169a4..e3f521c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1096,8 +1096,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	mmio_len = pci_resource_len(pdev, 0);
 
 	err = -EIO;
-	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
-	if (!adapter->hw.hw_addr)
+	hw->hw_addr = ioremap(mmio_start, mmio_len);
+	if (!hw->hw_addr)
 		goto err_ioremap;
 
 	netdev->netdev_ops = &igb_netdev_ops;
@@ -1357,9 +1357,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
-#ifdef CONFIG_IGB_DCA
 	struct e1000_hw *hw = &adapter->hw;
-#endif
 	int err;
 
 	/* flush_scheduled work may reschedule our watchdog task, so
@@ -1392,9 +1390,9 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	igb_free_queues(adapter);
 
-	iounmap(adapter->hw.hw_addr);
-	if (adapter->hw.flash_address)
-		iounmap(adapter->hw.flash_address);
+	iounmap(hw->hw_addr);
+	if (hw->flash_address)
+		iounmap(hw->flash_address);
 	pci_release_selected_regions(pdev, pci_select_bars(pdev,
 	                             IORESOURCE_MEM));
 
@@ -1784,7 +1782,7 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
 
 	rctl |= E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_RDMTS_HALF |
-		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
+		(hw->mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 
 	/*
 	 * enable stripping of CRC. It's unlikely this will break BMC
@@ -2176,15 +2174,16 @@ static void igb_clean_all_rx_rings(struct igb_adapter *adapter)
 static int igb_set_mac(struct net_device *netdev, void *p)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	memcpy(adapter->hw.mac.addr, addr->sa_data, netdev->addr_len);
+	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
-	adapter->hw.mac.ops.rar_set(&adapter->hw, adapter->hw.mac.addr, 0);
+	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
 
 	return 0;
 }
@@ -4140,7 +4139,7 @@ static void igb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 vfta, index;
 
-	if ((adapter->hw.mng_cookie.status &
+	if ((hw->mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	    (vid == adapter->mng_vlan_id))
 		return;

