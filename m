From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH 6/6] net: sh_eth: add set_mdio_gate in bb_info
Date: Tue, 08 Mar 2011 16:59:55 +0900
Message-ID: <4D75E1FB.6000607@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:60768 "EHLO
	relmlor2.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755980Ab1CHH75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 02:59:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SH7757's ETHER and GETHER use common MDIO pin. The MDIO pin is
selected by specific register. So this patch adds new interface in
bb_info, and when the sh_eth driver use the mdio, the register can
be changed by the function.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 This patch are based on net-next-2.6.git.

 arch/sh/include/asm/sh_eth.h |    1 +
 drivers/net/sh_eth.c         |   21 +++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/arch/sh/include/asm/sh_eth.h b/arch/sh/include/asm/sh_eth.h
index e86c880..0f325da 100644
--- a/arch/sh/include/asm/sh_eth.h
+++ b/arch/sh/include/asm/sh_eth.h
@@ -15,6 +15,7 @@ struct sh_eth_plat_data {
 	int edmac_endian;
 	int register_type;
 	phy_interface_t phy_interface;
+	void (*set_mdio_gate)(unsigned long addr);

 	unsigned char mac_addr[6];
 	unsigned no_ether_link:1;
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index dcf9f87..e9e7a53 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -512,6 +512,7 @@ static unsigned long sh_eth_get_edtrr_trns(struct sh_eth_private *mdp)
 }

 struct bb_info {
+	void (*set_gate)(unsigned long addr);
 	struct mdiobb_ctrl ctrl;
 	u32 addr;
 	u32 mmd_msk;/* MMD */
@@ -542,6 +543,10 @@ static int bb_read(u32 addr, u32 msk)
 static void sh_mmd_ctrl(struct mdiobb_ctrl *ctrl, int bit)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
+	if (bitbang->set_gate)
+		bitbang->set_gate(bitbang->addr);
+
 	if (bit)
 		bb_set(bitbang->addr, bitbang->mmd_msk);
 	else
@@ -553,6 +558,9 @@ static void sh_set_mdio(struct mdiobb_ctrl *ctrl, int bit)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);

+	if (bitbang->set_gate)
+		bitbang->set_gate(bitbang->addr);
+
 	if (bit)
 		bb_set(bitbang->addr, bitbang->mdo_msk);
 	else
@@ -563,6 +571,10 @@ static void sh_set_mdio(struct mdiobb_ctrl *ctrl, int bit)
 static int sh_get_mdio(struct mdiobb_ctrl *ctrl)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
+	if (bitbang->set_gate)
+		bitbang->set_gate(bitbang->addr);
+
 	return bb_read(bitbang->addr, bitbang->mdi_msk);
 }

@@ -571,6 +583,9 @@ static void sh_mdc_ctrl(struct mdiobb_ctrl *ctrl, int bit)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);

+	if (bitbang->set_gate)
+		bitbang->set_gate(bitbang->addr);
+
 	if (bit)
 		bb_set(bitbang->addr, bitbang->mdc_msk);
 	else
@@ -1646,7 +1661,8 @@ static int sh_mdio_release(struct net_device *ndev)
 }

 /* MDIO bus init function */
-static int sh_mdio_init(struct net_device *ndev, int id)
+static int sh_mdio_init(struct net_device *ndev, int id,
+			struct sh_eth_plat_data *pd)
 {
 	int ret, i;
 	struct bb_info *bitbang;
@@ -1661,6 +1677,7 @@ static int sh_mdio_init(struct net_device *ndev, int id)

 	/* bitbang init */
 	bitbang->addr = ndev->base_addr + mdp->reg_offset[PIR];
+	bitbang->set_gate = pd->set_mdio_gate;
 	bitbang->mdi_msk = 0x08;
 	bitbang->mdo_msk = 0x04;
 	bitbang->mmd_msk = 0x02;/* MMD */
@@ -1854,7 +1871,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		goto out_release;

 	/* mdio bus init */
-	ret = sh_mdio_init(ndev, pdev->id);
+	ret = sh_mdio_init(ndev, pdev->id, pd);
 	if (ret)
 		goto out_unregister;

-- 
1.7.1
