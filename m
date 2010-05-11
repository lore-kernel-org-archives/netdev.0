From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 03/12] e1000e: initialize manageability (IPMI)
	pass-through in 82574/82583
Date: Mon, 10 May 2010 17:59:51 -0700
Message-ID: <20100511005949.30827.62576.stgit@localhost.localdomain>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:48270
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758052Ab0EKBAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:00:08 -0400
In-Reply-To: <20100511005801.30827.50808.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

82574/82583 uses different registers/bits to setup manageability filters
than all other parts supported by e1000e; set them accordingly for IPMI
pass-through.  Rename the function to better reflect what it does.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/defines.h |    5 ++++
 drivers/net/e1000e/hw.h      |    2 +
 drivers/net/e1000e/netdev.c  |   57 +++++++++++++++++++++++++++++++++++-------
 3 files changed, 55 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 7f760aa..227147f 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -138,6 +138,11 @@
 /* Enable MNG packets to host memory */
 #define E1000_MANC_EN_MNG2HOST   0x00200000
 
+#define E1000_MANC2H_PORT_623    0x00000020 /* Port 0x26f */
+#define E1000_MANC2H_PORT_664    0x00000040 /* Port 0x298 */
+#define E1000_MDEF_PORT_623      0x00000800 /* Port 0x26f */
+#define E1000_MDEF_PORT_664      0x00000400 /* Port 0x298 */
+
 /* Receive Control */
 #define E1000_RCTL_EN             0x00000002    /* enable */
 #define E1000_RCTL_SBP            0x00000004    /* store bad packet */
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 8bdcd5f..6f66c37 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -208,6 +208,8 @@ enum e1e_registers {
 
 	E1000_KMRNCTRLSTA = 0x00034, /* MAC-PHY interface - RW */
 	E1000_MANC2H    = 0x05860, /* Management Control To Host - RW */
+	E1000_MDEF_BASE = 0x05890, /* Management Decision Filters */
+#define E1000_MDEF(_n)   (E1000_MDEF_BASE + ((_n) * 4))
 	E1000_SW_FW_SYNC = 0x05B5C, /* Software-Firmware Synchronization - RW */
 	E1000_GCR	= 0x05B00, /* PCI-Ex Control */
 	E1000_GCR2      = 0x05B64, /* PCI-Ex Control #2 */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ab79bec..36473e6 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2526,10 +2526,10 @@ static void e1000_restore_vlan(struct e1000_adapter *adapter)
 	}
 }
 
-static void e1000_init_manageability(struct e1000_adapter *adapter)
+static void e1000_init_manageability_pt(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 manc, manc2h;
+	u32 manc, manc2h, mdef, i, j;
 
 	if (!(adapter->flags & FLAG_MNG_PT_ENABLED))
 		return;
@@ -2543,10 +2543,49 @@ static void e1000_init_manageability(struct e1000_adapter *adapter)
 	 */
 	manc |= E1000_MANC_EN_MNG2HOST;
 	manc2h = er32(MANC2H);
-#define E1000_MNG2HOST_PORT_623 (1 << 5)
-#define E1000_MNG2HOST_PORT_664 (1 << 6)
-	manc2h |= E1000_MNG2HOST_PORT_623;
-	manc2h |= E1000_MNG2HOST_PORT_664;
+
+	switch (hw->mac.type) {
+	default:
+		manc2h |= (E1000_MANC2H_PORT_623 | E1000_MANC2H_PORT_664);
+		break;
+	case e1000_82574:
+	case e1000_82583:
+		/*
+		 * Check if IPMI pass-through decision filter already exists;
+		 * if so, enable it.
+		 */
+		for (i = 0, j = 0; i < 8; i++) {
+			mdef = er32(MDEF(i));
+
+			/* Ignore filters with anything other than IPMI ports */
+			if (mdef & !(E1000_MDEF_PORT_623 | E1000_MDEF_PORT_664))
+				continue;
+
+			/* Enable this decision filter in MANC2H */
+			if (mdef)
+				manc2h |= (1 << i);
+
+			j |= mdef;
+		}
+
+		if (j == (E1000_MDEF_PORT_623 | E1000_MDEF_PORT_664))
+			break;
+
+		/* Create new decision filter in an empty filter */
+		for (i = 0, j = 0; i < 8; i++)
+			if (er32(MDEF(i)) == 0) {
+				ew32(MDEF(i), (E1000_MDEF_PORT_623 |
+					       E1000_MDEF_PORT_664));
+				manc2h |= (1 << 1);
+				j++;
+				break;
+			}
+
+		if (!j)
+			e_warn("Unable to create IPMI pass-through filter\n");
+		break;
+	}
+
 	ew32(MANC2H, manc2h);
 	ew32(MANC, manc);
 }
@@ -2961,7 +3000,7 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	e1000_set_multi(adapter->netdev);
 
 	e1000_restore_vlan(adapter);
-	e1000_init_manageability(adapter);
+	e1000_init_manageability_pt(adapter);
 
 	e1000_configure_tx(adapter);
 	e1000_setup_rctl(adapter);
@@ -5104,7 +5143,7 @@ static int __e1000_resume(struct pci_dev *pdev)
 
 	e1000e_reset(adapter);
 
-	e1000_init_manageability(adapter);
+	e1000_init_manageability_pt(adapter);
 
 	if (netif_running(netdev))
 		e1000e_up(adapter);
@@ -5305,7 +5344,7 @@ static void e1000_io_resume(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	e1000_init_manageability(adapter);
+	e1000_init_manageability_pt(adapter);
 
 	if (netif_running(netdev)) {
 		if (e1000e_up(adapter)) {

