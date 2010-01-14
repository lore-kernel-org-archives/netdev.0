From: Liu Yu <yu.liu@freescale.com>
Subject: [PATCH 3/4] ucc_geth: update the tbi-phy setting
Date: Thu, 14 Jan 2010 16:13:18 +0800
Message-ID: <1263456799-3306-3-git-send-email-yu.liu@freescale.com>
References: <1263456799-3306-1-git-send-email-yu.liu@freescale.com>
	<1263456799-3306-2-git-send-email-yu.liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liu Yu <yu.liu@freescale.com>,
	linuxppc-dev@lists.ozlabs.org
To: galak@kernel.crashing.org, davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1263456799-3306-2-git-send-email-yu.liu@freescale.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Old method only set tbi-phy for eth0.

Signed-off-by: Liu Yu <yu.liu@freescale.com>
---
 drivers/net/ucc_geth.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 750d86d..0e72013 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -37,6 +37,7 @@
 #include <asm/qe.h>
 #include <asm/ucc.h>
 #include <asm/ucc_fast.h>
+#include <asm/machdep.h>
 
 #include "ucc_geth.h"
 #include "fsl_pq_mdio.h"
@@ -1334,7 +1335,7 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	struct ucc_geth __iomem *ug_regs;
 	struct ucc_fast __iomem *uf_regs;
 	int ret_val;
-	u32 upsmr, maccfg2, tbiBaseAddress;
+	u32 upsmr, maccfg2;
 	u16 value;
 
 	ugeth_vdbg("%s: IN", __func__);
@@ -1389,14 +1390,20 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	/* Note that this depends on proper setting in utbipar register. */
 	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_TBI) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
-		tbiBaseAddress = in_be32(&ug_regs->utbipar);
-		tbiBaseAddress &= UTBIPAR_PHY_ADDRESS_MASK;
-		tbiBaseAddress >>= UTBIPAR_PHY_ADDRESS_SHIFT;
-		value = ugeth->phydev->bus->read(ugeth->phydev->bus,
-				(u8) tbiBaseAddress, ENET_TBI_MII_CR);
+		struct ucc_geth_info *ug_info = ugeth->ug_info;
+		struct phy_device *tbiphy;
+
+		if (!ug_info->tbi_node)
+			ugeth_warn("TBI mode requires that the device "
+				"tree specify a tbi-handle\n");
+
+		tbiphy = of_phy_find_device(ug_info->tbi_node);
+		if (!tbiphy)
+			ugeth_warn("Could not get TBI device\n");
+
+		value = phy_read(tbiphy, ENET_TBI_MII_CR);
 		value &= ~0x1000;	/* Turn off autonegotiation */
-		ugeth->phydev->bus->write(ugeth->phydev->bus,
-				(u8) tbiBaseAddress, ENET_TBI_MII_CR, value);
+		phy_write(tbiphy, ENET_TBI_MII_CR, value);
 	}
 
 	init_check_frame_length_mode(ug_info->lengthCheckRx, &ug_regs->maccfg2);
-- 
1.6.4
