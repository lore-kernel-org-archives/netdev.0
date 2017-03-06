From: Christian Lamparter <chunkeey@googlemail.com>
Subject: [PATCH] net: ibm: emac: fix regression caused by emac_dt_phy_probe()
Date: Mon,  6 Mar 2017 14:34:27 +0100
Message-ID: <20170306133427.27025-1-chunkeey@googlemail.com>
Cc: Julian Margetson <runaway@candw.ms>,
        "David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34197 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752789AbdCFNes (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 08:34:48 -0500
Received: by mail-wr0-f196.google.com with SMTP id u48so21801179wrc.1
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 05:34:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Margetson reported a panic on his SAM460EX with Kernel 4.11-rc1:
| Unable to handle kernel paging request for data at address 0x00000014
| Oops: Kernel access of bad area, sig: 11 [#1]
| PREEMPT
| Canyonlands
| Modules linked in:
| CPU: 0 PID: 1 Comm: swapper Not tainted [...]
| task: ea838000 task.stack: ea836000
| NIP: c0599f5c LR: c0599dd8 CTR: 00000000
| REGS: ea837c80 TRAP: 0300   Not tainted [...]
| MSR: 00029000 <CE,EE,ME>
|  CR: 24371242  XER: 20000000
| DEAR: 00000014 ESR: 00000000
| GPR00: c0599ce8 ea837d30 ea838000 c0e52dcc c0d56ffb [...]
| NIP [c0599f5c] emac_probe+0xfb4/0x1304
| LR [c0599dd8] emac_probe+0xe30/0x1304
| Call Trace:
| [ea837d30] [c0599ce8] emac_probe+0xd40/0x1304 (unreliable)
| [ea837d80] [c0533504] platform_drv_probe+0x48/0x90
| [ea837da0] [c0531c14] driver_probe_device+0x15c/0x2c4
| [ea837dd0] [c0531e04] __driver_attach+0x88/0xb0
| ---[ end trace ... ]---

The problem is caused by emac_dt_phy_probe() returing success (0)
for existing device-trees configurations that do not specify a
"phy-handle" property. This caused the code to skip the existing
phy probe and setup. Which led to essential phy related
data-structures being uninitialized.

This patch also removes the unused variable in emac_dt_phy_connect().

Fixes: a577ca6badb5261d ("net: emac: add support for device-tree based PHY discovery and setup")
Reported-by: Julian Margetson <runaway@candw.ms>
Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
---
 drivers/net/ethernet/ibm/emac/core.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 275c2e2349ad..c44036d5761a 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2589,8 +2589,6 @@ static int emac_dt_mdio_probe(struct emac_instance *dev)
 static int emac_dt_phy_connect(struct emac_instance *dev,
 			       struct device_node *phy_handle)
 {
-	int res;
-
 	dev->phy.def = devm_kzalloc(&dev->ofdev->dev, sizeof(*dev->phy.def),
 				    GFP_KERNEL);
 	if (!dev->phy.def)
@@ -2617,7 +2615,7 @@ static int emac_dt_phy_probe(struct emac_instance *dev)
 {
 	struct device_node *np = dev->ofdev->dev.of_node;
 	struct device_node *phy_handle;
-	int res = 0;
+	int res = 1;
 
 	phy_handle = of_parse_phandle(np, "phy-handle", 0);
 
@@ -2714,13 +2712,24 @@ static int emac_init_phy(struct emac_instance *dev)
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII)) {
 		int res = emac_dt_phy_probe(dev);
 
-		mutex_unlock(&emac_phy_map_lock);
-		if (!res)
+		switch (res) {
+		case 1:
+			/* No phy-handle property configured.
+			 * Continue with the existing phy probe
+			 * and setup code.
+			 */
+			break;
+
+		case 0:
+			mutex_unlock(&emac_phy_map_lock);
 			goto init_phy;
 
-		dev_err(&dev->ofdev->dev, "failed to attach dt phy (%d).\n",
-			res);
-		return res;
+		default:
+			mutex_unlock(&emac_phy_map_lock);
+			dev_err(&dev->ofdev->dev, "failed to attach dt phy (%d).\n",
+				res);
+			return res;
+		}
 	}
 
 	if (dev->phy_address != 0xffffffff)
-- 
2.11.0
