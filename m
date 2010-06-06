From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 07/10] tg3: Use devfn to determine function
 number
Date: Sat, 5 Jun 2010 20:24:36 -0700
Message-ID: <1275794679-11085-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4674 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933977Ab0FFDYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 23:24:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver sometimes needs to know which function number the current
device is.  This patch changes the code to use devfn over internal
register values.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   10 +++-------
 drivers/net/tg3.h |    4 +---
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2dcde13..1e1c341 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1085,13 +1085,9 @@ static int tg3_mdio_init(struct tg3 *tp)
 	struct phy_device *phydev;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
-		u32 funcnum, is_serdes;
+		u32 is_serdes;
 
-		funcnum = tr32(TG3_CPMU_STATUS) & TG3_CPMU_STATUS_PCIE_FUNC;
-		if (funcnum)
-			tp->phy_addr = 2;
-		else
-			tp->phy_addr = 1;
+		tp->phy_addr = PCI_FUNC(tp->pdev->devfn) + 1;
 
 		if (tp->pci_chip_rev_id != CHIPREV_ID_5717_A0)
 			is_serdes = tr32(SG_DIG_STATUS) & SG_DIG_IS_SERDES;
@@ -13608,7 +13604,7 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 		else
 			tg3_nvram_unlock(tp);
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
-		if (tr32(TG3_CPMU_STATUS) & TG3_CPMU_STATUS_PCIE_FUNC)
+		if (PCI_FUNC(tp->pdev->devfn))
 			mac_offset = 0xcc;
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		mac_offset = 0x10;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index c245e80..878cdee 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1073,10 +1073,8 @@
 #define TG3_CPMU_HST_ACC		0x0000361c
 #define  CPMU_HST_ACC_MACCLK_MASK	 0x001f0000
 #define  CPMU_HST_ACC_MACCLK_6_25	 0x00130000
-/* 0x3620 --> 0x362c unused */
+/* 0x3620 --> 0x3630 unused */
 
-#define TG3_CPMU_STATUS			0x0000362c
-#define  TG3_CPMU_STATUS_PCIE_FUNC	 0x20000000
 #define TG3_CPMU_CLCK_STAT		0x00003630
 #define  CPMU_CLCK_STAT_MAC_CLCK_MASK	 0x001f0000
 #define  CPMU_CLCK_STAT_MAC_CLCK_62_5	 0x00000000
-- 
1.6.4.4


