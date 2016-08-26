From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 5/5] net/xgene: fix error handling during reset
Date: Fri, 26 Aug 2016 17:25:46 +0200
Message-ID: <20160826152546.604384-6-arnd@arndb.de>
References: <20160826152546.604384-1-arnd@arndb.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>, Fushen Chen <fchen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>,
        Keyur Chudgar <kchudgar@apm.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160826152546.604384-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly added reset logic uses helper functions for the MMIO that
may fail. However, when the read operation fails, we end up writing
back uninitialized data to the register, as gcc warns:

drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c: In function 'xgene_enet_link_state':
drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c:213:2: error: 'data' may be used uninitialized in this function [-Werror=maybe-uninitialized]
drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c:209:6: note: 'data' was declared here
  u32 data;

We already print a warning to the console log if that happens,
the best alternative that I can see is skip the rest of the reset
sequence if the register value cannot be read: Most likely the
write would fail as well, and if it succeeded, worse things could
happen.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 3eb7cb9dc946 ("drivers: net: xgene: XFI PCS reset when link is down")
Cc: Fushen Chen <fchen@apm.com> 
---
Cc: Iyappan Subramanian <isubramanian@apm.com>
Cc: Keyur Chudgar <kchudgar@apm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org

 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index d672e71b5a50..279ee27004f7 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -155,19 +155,23 @@ static void xgene_enet_rd_mac(struct xgene_enet_pdata *pdata,
 			   rd_addr);
 }
 
-static void xgene_enet_rd_pcs(struct xgene_enet_pdata *pdata,
+static bool xgene_enet_rd_pcs(struct xgene_enet_pdata *pdata,
 			      u32 rd_addr, u32 *rd_data)
 {
 	void __iomem *addr, *rd, *cmd, *cmd_done;
+	bool success;
 
 	addr = pdata->pcs_addr + PCS_ADDR_REG_OFFSET;
 	rd = pdata->pcs_addr + PCS_READ_REG_OFFSET;
 	cmd = pdata->pcs_addr + PCS_COMMAND_REG_OFFSET;
 	cmd_done = pdata->pcs_addr + PCS_COMMAND_DONE_REG_OFFSET;
 
-	if (!xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data))
+	success = xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data);
+	if (!success)
 		netdev_err(pdata->ndev, "PCS read failed, addr: %04x\n",
 			   rd_addr);
+
+	return success;
 }
 
 static int xgene_enet_ecc_init(struct xgene_enet_pdata *pdata)
@@ -208,7 +212,9 @@ static void xgene_pcs_reset(struct xgene_enet_pdata *pdata)
 {
 	u32 data;
 
-	xgene_enet_rd_pcs(pdata, PCS_CONTROL_1, &data);
+	if (!xgene_enet_rd_pcs(pdata, PCS_CONTROL_1, &data))
+		return;
+
 	xgene_enet_wr_pcs(pdata, PCS_CONTROL_1, data | PCS_CTRL_PCS_RST);
 	xgene_enet_wr_pcs(pdata, PCS_CONTROL_1, data & ~PCS_CTRL_PCS_RST);
 }
-- 
2.9.0
