From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next 1/3] bnx2x: fix possible deadlock in HC hw block
Date: Tue, 19 Oct 2010 17:13:05 +0200
Message-ID: <1287501185.740.41.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3615 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845Ab0JSPaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 11:30:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The possible deadlock (on 57710 devices only) will prevent from the
device to generate interrupts.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   37 +++++++++++++++++++++++++++++--------
 1 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 012c093..3f49b55 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1111,14 +1111,19 @@ static void bnx2x_hc_int_enable(struct bnx2x *bp)
 			HC_CONFIG_0_REG_INT_LINE_EN_0 |
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
 
-		DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)\n",
-		   val, port, addr);
+		if (!CHIP_IS_E1(bp)) {
+			DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)\n",
+			   val, port, addr);
 
-		REG_WR(bp, addr, val);
+			REG_WR(bp, addr, val);
 
-		val &= ~HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0;
+			val &= ~HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0;
+		}
 	}
 
+	if (CHIP_IS_E1(bp))
+		REG_WR(bp, HC_REG_INT_MASK + port*4, 0x1FFFF);
+
 	DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  mode %s\n",
 	   val, port, addr, (msix ? "MSI-X" : (msi ? "MSI" : "INTx")));
 
@@ -1212,10 +1217,26 @@ static void bnx2x_hc_int_disable(struct bnx2x *bp)
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
 	u32 val = REG_RD(bp, addr);
 
-	val &= ~(HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
-		 HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0 |
-		 HC_CONFIG_0_REG_INT_LINE_EN_0 |
-		 HC_CONFIG_0_REG_ATTN_BIT_EN_0);
+	/*
+	 * in E1 we must use only PCI configuration space to disable
+	 * MSI/MSIX capablility
+	 * It's forbitten to disable IGU_PF_CONF_MSI_MSIX_EN in HC block
+	 */
+	if (CHIP_IS_E1(bp)) {
+		/*  Since IGU_PF_CONF_MSI_MSIX_EN still always on
+		 *  Use mask register to prevent from HC sending interrupts
+		 *  after we exit the function
+		 */
+		REG_WR(bp, HC_REG_INT_MASK + port*4, 0);
+
+		val &= ~(HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
+			 HC_CONFIG_0_REG_INT_LINE_EN_0 |
+			 HC_CONFIG_0_REG_ATTN_BIT_EN_0);
+	} else
+		val &= ~(HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
+			 HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0 |
+			 HC_CONFIG_0_REG_INT_LINE_EN_0 |
+			 HC_CONFIG_0_REG_ATTN_BIT_EN_0);
 
 	DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)\n",
 	   val, port, addr);
-- 
1.7.1




