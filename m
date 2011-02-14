From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH] pch_gbe: Fix the MAC Address load issue.
Date: Mon, 14 Feb 2011 17:51:54 +0900
Message-ID: <4D58ED2A.9050706@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Tomoya Morinaga <tomoya-linux@dsn.okisemi.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Ewe, Kok Howg" <kok.howg.ewe@intel.com>
To: ML netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the specification of hardware,
the processing at the time of driver starting was modified.

This device write automatically the MAC address read from serial ROM
into a MAC Adress1A/1B register at the time of power on reset.
However, when stable clock is not supplied,
the writing of MAC Adress1A/1B register may not be completed.
In this case, it is necessary to load MAC address to MAC Address1A/1B register
by the MAC Address1 load register.

This patch always does the above processing,
in order not to be dependent on system environment.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe.h      |    2 +-
 drivers/net/pch_gbe/pch_gbe_main.c |    7 +++++++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/pch_gbe/pch_gbe.h
index a0c26a9..e1e33c8 100644
--- a/drivers/net/pch_gbe/pch_gbe.h
+++ b/drivers/net/pch_gbe/pch_gbe.h
@@ -73,7 +73,7 @@ struct pch_gbe_regs {
 	struct pch_gbe_regs_mac_adr mac_adr[16];
 	u32 ADDR_MASK;
 	u32 MIIM;
-	u32 reserve2;
+	u32 MAC_ADDR_LOAD;
 	u32 RGMII_ST;
 	u32 RGMII_CTRL;
 	u32 reserve3[3];
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 8ec48ad..8bba091 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -89,6 +89,12 @@ static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
 static int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
 static void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg,
 			       int data);
+
+inline void pch_gbe_mac_load_mac_addr(struct pch_gbe_hw *hw)
+{
+	iowrite32(0x01, &hw->reg->MAC_ADDR_LOAD);
+}
+
 /**
  * pch_gbe_mac_read_mac_addr - Read MAC address
  * @hw:	            Pointer to the HW structure
@@ -2333,6 +2339,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	netdev->features = NETIF_F_HW_CSUM | NETIF_F_GRO;
 	pch_gbe_set_ethtool_ops(netdev);
 
+	pch_gbe_mac_load_mac_addr(&adapter->hw);
 	pch_gbe_mac_reset_hw(&adapter->hw);
 
 	/* setup the private structure */
-- 
1.6.2.5
