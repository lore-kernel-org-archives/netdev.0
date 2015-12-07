From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/3] sh_eth: factor out common code from MDIO bitbang methods
Date: Tue, 08 Dec 2015 00:40:57 +0300
Message-ID: <2708108.aPmlclaWv5@wasted.cogentembedded.com>
References: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sh_mm[cd]_ctrl()  and sh_set_mdio() all look mostly the same -- factor out
their common code and put it into sh_mdio_ctrl().

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   35 +++++++++++-----------------------
 1 file changed, 12 insertions(+), 23 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1033,32 +1033,29 @@ static int bb_read(void *addr, u32 msk)
 	return (ioread32(addr) & msk) != 0;
 }
 
-/* Data I/O pin control */
-static void sh_mmd_ctrl(struct mdiobb_ctrl *ctrl, int bit)
+static void sh_mdio_ctrl(struct mdiobb_ctrl *ctrl, u32 mask, int set)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
 
 	if (bitbang->set_gate)
 		bitbang->set_gate(bitbang->addr);
 
-	if (bit)
-		bb_set(bitbang->addr, PIR_MMD);
+	if (set)
+		bb_set(bitbang->addr, mask);
 	else
-		bb_clr(bitbang->addr, PIR_MMD);
+		bb_clr(bitbang->addr, mask);
+}
+
+/* Data I/O pin control */
+static void sh_mmd_ctrl(struct mdiobb_ctrl *ctrl, int bit)
+{
+	sh_mdio_ctrl(ctrl, PIR_MMD, bit);
 }
 
 /* Set bit data*/
 static void sh_set_mdio(struct mdiobb_ctrl *ctrl, int bit)
 {
-	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
-
-	if (bitbang->set_gate)
-		bitbang->set_gate(bitbang->addr);
-
-	if (bit)
-		bb_set(bitbang->addr, PIR_MDO);
-	else
-		bb_clr(bitbang->addr, PIR_MDO);
+	sh_mdio_ctrl(ctrl, PIR_MDO, bit);
 }
 
 /* Get bit data*/
@@ -1075,15 +1072,7 @@ static int sh_get_mdio(struct mdiobb_ctr
 /* MDC pin control */
 static void sh_mdc_ctrl(struct mdiobb_ctrl *ctrl, int bit)
 {
-	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
-
-	if (bitbang->set_gate)
-		bitbang->set_gate(bitbang->addr);
-
-	if (bit)
-		bb_set(bitbang->addr, PIR_MDC);
-	else
-		bb_clr(bitbang->addr, PIR_MDC);
+	sh_mdio_ctrl(ctrl, PIR_MDC, bit);
 }
 
 /* mdio bus control struct */

