From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 04/12] tg3: Preserve PCIe MPS setting for new devs
Date: Tue, 25 Aug 2009 13:08:16 -0700
Message-ID: <1251232429.25405@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1686 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756168AbZHYUgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:36:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most older tg3 devices only supported a PCIe maximum payload size of
128 bytes.  More recent devices bump this limit up to 256 bytes
though.  This patch modifies the code so that the MPS limit is only
enforced on those devices that only allow the 128 byte setting.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ca3052d..356b5d0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6226,6 +6226,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 	udelay(120);
 
 	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) && tp->pcie_cap) {
+		u16 val16;
+
 		if (tp->pci_chip_rev_id == CHIPREV_ID_5750_A0) {
 			int i;
 			u32 cfg_val;
@@ -6239,12 +6241,22 @@ static int tg3_chip_reset(struct tg3 *tp)
 					       cfg_val | (1 << 15));
 		}
 
-		/* Set PCIE max payload size to 128 bytes and
-		 * clear the "no snoop" and "relaxed ordering" bits.
+		/* Clear the "no snoop" and "relaxed ordering" bits. */
+		pci_read_config_word(tp->pdev,
+				     tp->pcie_cap + PCI_EXP_DEVCTL,
+				     &val16);
+		val16 &= ~(PCI_EXP_DEVCTL_RELAX_EN |
+			   PCI_EXP_DEVCTL_NOSNOOP_EN);
+		/*
+		 * Older PCIe devices only support the 128 byte
+		 * MPS setting.  Enforce the restriction.
 		 */
+		if (!(tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) ||
+		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784))
+			val16 &= ~PCI_EXP_DEVCTL_PAYLOAD;
 		pci_write_config_word(tp->pdev,
 				      tp->pcie_cap + PCI_EXP_DEVCTL,
-				      0);
+				      val16);
 
 		pcie_set_readrq(tp->pdev, 4096);
 
-- 
1.6.3.3


