From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 07/14] r8169: sync existing 8168 device hardware start
	sequences with vendor driver
Date: Fri, 10 Oct 2008 23:43:13 +0200
Message-ID: <20081010214313.GG27195@electric-eye.fr.zoreil.com>
References: <20081006071229.GA23039@electric-eye.fr.zoreil.com> <20081007222202.GA9393@electric-eye.fr.zoreil.com> <20081009190015.GB19721@electric-eye.fr.zoreil.com> <20081009.122026.239988133.davem@davemloft.net> <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamagallon@ono.com, greg@kroah.com, netdev@vger.kernel.org,
	bonbons@linux-vserver.org, ivecera@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	ishikawa <chiaki.ishikawa@ubin.jp>, Mark Lord <lkml@rtr.ca>,
	edward_hsu@realtek.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37922 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759970AbYJJVnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:43:47 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This part of the driver should be reasonably in line with Realtek's
8.006.00 driver.

I have left some bits related to jumbo frame and optional features
aside for now.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   75 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f929dba..f0f842d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2384,8 +2384,38 @@ static void rtl_ephy_init(void __iomem *ioaddr, struct ephy_info *e, int len)
 	}
 }
 
+static void rtl_disable_clock_request(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	int cap = tp->pcie_cap;
+
+	if (cap) {
+		u16 ctl;
+
+		pci_read_config_word(pdev, cap + PCI_EXP_LNKCTL, &ctl);
+		ctl &= ~PCI_EXP_LNKCTL_CLKREQ_EN;
+		pci_write_config_word(pdev, cap + PCI_EXP_LNKCTL, ctl);
+	}
+}
+
+#define R8168_CPCMD_QUIRK_MASK (\
+	EnableBist | \
+	Mac_dbgo_oe | \
+	Force_half_dup | \
+	Force_rxflow_en | \
+	Force_txflow_en | \
+	Cxpl_dbg_sel | \
+	ASF | \
+	PktCntrDisable | \
+	Mac_dbgo_sel)
+
 static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
 {
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
+
 	rtl_tx_performance_tweak(pdev,
 		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
 }
@@ -2393,25 +2423,70 @@ static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
 static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
 {
 	rtl_hw_start_8168bb(ioaddr, pdev);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
 }
 
 static void __rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
 {
+	RTL_W8(Config1, RTL_R8(Config1) | Speed_down);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	rtl_disable_clock_request(pdev);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
 static void rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
 {
+	static struct ephy_info e_info_8168cp[] = {
+		{ 0x01, 0,	0x0001 },
+		{ 0x02, 0x0800,	0x1000 },
+		{ 0x03, 0,	0x0042 },
+		{ 0x06, 0x0080,	0x0000 },
+		{ 0x07, 0,	0x2000 }
+	};
+
+	rtl_csi_access_enable(ioaddr);
+
+	rtl_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
+
 	__rtl_hw_start_8168cp(ioaddr, pdev);
 }
 
 static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
+	static struct ephy_info e_info_8168c_1[] = {
+		{ 0x02, 0x0800,	0x1000 },
+		{ 0x03, 0,	0x0002 },
+		{ 0x06, 0x0080,	0x0000 }
+	};
+
+	rtl_csi_access_enable(ioaddr);
+
+	RTL_W8(DBG_REG, 0x06 | FIX_NAK_1 | FIX_NAK_2);
+
+	rtl_ephy_init(ioaddr, e_info_8168c_1, ARRAY_SIZE(e_info_8168c_1));
+
 	__rtl_hw_start_8168cp(ioaddr, pdev);
 }
 
 static void rtl_hw_start_8168c_2(void __iomem *ioaddr, struct pci_dev *pdev)
 {
+	static struct ephy_info e_info_8168c_2[] = {
+		{ 0x01, 0,	0x0001 },
+		{ 0x03, 0x0400,	0x0220 }
+	};
+
+	rtl_csi_access_enable(ioaddr);
+
+	rtl_ephy_init(ioaddr, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
+
 	__rtl_hw_start_8168cp(ioaddr, pdev);
 }
 
-- 
1.5.3.3

