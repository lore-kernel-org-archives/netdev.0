From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: [REGRESSION, PATCH] sky2 WOL fix
Date: Tue, 14 Feb 2012 09:25:02 +0100
Message-ID: <4F3A1A5E.9090803@t-online.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010001020305050508040602"
Cc: shemminger@vyatta.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, dilieto@lineone.net
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010001020305050508040602
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the regression introduced with 2.6.38 on my
system, the patch is safe as the reintroduced code is only
executed after the motherboard model is identified by dmi.

Probably the dmi_system_id list will grow, a hot candidate
is the ASUS P5LD2 motherboard, see Debian bug #647560

Nick: Try the patch with your system added to dmi_system_id need_legacy.
Feel free to send the output of dmidecode if you cannot do that yourself.

cu,
  Knut

--------------010001020305050508040602
Content-Type: text/x-patch;
 name="0001-Fix-an-old-sky2-WOL-regression.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-Fix-an-old-sky2-WOL-regression.patch"

>From f3a7086638b0ee1f9d9e9028a188d96646671088 Mon Sep 17 00:00:00 2001
From: Knut Petersen <Knut_Petersen@t-online.de>
Date: Tue, 14 Feb 2012 08:35:17 +0100
Subject: [PATCH] Fix an old sky2 WOL regression

Wake-On-Lan was broken for a few systems with commit
87b09f1f25cd1e01d7c50bf423c7fe33027d7511 more than a
year ago.

This commit fixes the regression for the AOpen i915GMm-HFS
motherboard. It reintroduces the old code, but that code is
only executed for those system included in a dmi_system_id
list. Currently there is only one entry in that list, but
it probably will grow.

Signed-off-by: Knut Petersen <Knut_Petersen@t-online.de>
---
 drivers/net/ethernet/marvell/sky2.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 760c2b1..02f5b44 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -44,6 +44,7 @@
 #include <linux/prefetch.h>
 #include <linux/debugfs.h>
 #include <linux/mii.h>
+#include <linux/dmi.h>
 
 #include <asm/irq.h>
 
@@ -807,6 +808,18 @@ static void sky2_phy_reinit(struct sky2_port *sky2)
 	spin_unlock_bh(&sky2->phy_lock);
 }
 
+/* A few systems do need PCI_Y2_PME_LEGACY for WOL, add them here */
+static const struct dmi_system_id need_legacy[] = {
+	{
+		.ident = "AOpen i915GMm-HFS",
+		.matches = {
+			DMI_MATCH(DMI_BOARD_VENDOR, "AOpen"),
+			DMI_MATCH(DMI_BOARD_NAME, "i915GMm-HFS"),
+		},
+	},
+	{ NULL }
+};
+
 /* Put device in state to listen for Wake On Lan */
 static void sky2_wol_init(struct sky2_port *sky2)
 {
@@ -814,6 +827,7 @@ static void sky2_wol_init(struct sky2_port *sky2)
 	unsigned port = sky2->port;
 	enum flow_control save_mode;
 	u16 ctrl;
+	u32 reg1;
 
 	/* Bring hardware out of reset */
 	sky2_write16(hw, B0_CTST, CS_RST_CLR);
@@ -867,6 +881,13 @@ static void sky2_wol_init(struct sky2_port *sky2)
 	/* Disable PiG firmware */
 	sky2_write16(hw, B0_CTST, Y2_HW_WOL_OFF);
 
+	/* set legacy pm bit on those systems that need it */
+	if (dmi_check_system(need_legacy)) {
+		reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+		reg1 |= PCI_Y2_PME_LEGACY;
+		sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+	} 
+
 	/* block receiver */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 	sky2_read32(hw, B0_CTST);
-- 
1.7.9


--------------010001020305050508040602--
