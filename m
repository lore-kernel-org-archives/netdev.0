From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 02/12] drivers: net: phy: xgene: Add lock to protect mac access
Date: Wed, 10 May 2017 13:45:00 -0700
Message-ID: <1494449110-23785-3-git-send-email-isubramanian@apm.com>
References: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34313 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753114AbdEJUmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 16:42:23 -0400
Received: by mail-io0-f175.google.com with SMTP id k91so9465897ioi.1
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:42:23 -0700 (PDT)
In-Reply-To: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch,

- refactors mac access routine
- adds lock to protect mac indirect access

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/phy/mdio-xgene.c | 74 ++++++++++++++++++++++----------------------
 drivers/net/phy/mdio-xgene.h |  3 ++
 2 files changed, 40 insertions(+), 37 deletions(-)

diff --git a/drivers/net/phy/mdio-xgene.c b/drivers/net/phy/mdio-xgene.c
index 3e2ac07..bfd3090 100644
--- a/drivers/net/phy/mdio-xgene.c
+++ b/drivers/net/phy/mdio-xgene.c
@@ -34,76 +34,73 @@
 
 static bool xgene_mdio_status;
 
-static u32 xgene_enet_rd_mac(void __iomem *base_addr, u32 rd_addr)
+u32 xgene_mdio_rd_mac(struct xgene_mdio_pdata *pdata, u32 rd_addr)
 {
 	void __iomem *addr, *rd, *cmd, *cmd_done;
 	u32 done, rd_data = BUSY_MASK;
 	u8 wait = 10;
 
-	addr = base_addr + MAC_ADDR_REG_OFFSET;
-	rd = base_addr + MAC_READ_REG_OFFSET;
-	cmd = base_addr + MAC_COMMAND_REG_OFFSET;
-	cmd_done = base_addr + MAC_COMMAND_DONE_REG_OFFSET;
+	addr = pdata->mac_csr_addr + MAC_ADDR_REG_OFFSET;
+	rd = pdata->mac_csr_addr + MAC_READ_REG_OFFSET;
+	cmd = pdata->mac_csr_addr + MAC_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mac_csr_addr + MAC_COMMAND_DONE_REG_OFFSET;
 
+	spin_lock(&pdata->mac_lock);
 	iowrite32(rd_addr, addr);
 	iowrite32(XGENE_ENET_RD_CMD, cmd);
 
-	while (wait--) {
-		done = ioread32(cmd_done);
-		if (done)
-			break;
+	while (!(done = ioread32(cmd_done)) && wait--)
 		udelay(1);
-	}
 
-	if (!done)
-		return rd_data;
+	if (done)
+		rd_data = ioread32(rd);
 
-	rd_data = ioread32(rd);
 	iowrite32(0, cmd);
+	spin_unlock(&pdata->mac_lock);
 
 	return rd_data;
 }
+EXPORT_SYMBOL(xgene_mdio_rd_mac);
 
-static void xgene_enet_wr_mac(void __iomem *base_addr, u32 wr_addr, u32 wr_data)
+void xgene_mdio_wr_mac(struct xgene_mdio_pdata *pdata, u32 wr_addr, u32 data)
 {
 	void __iomem *addr, *wr, *cmd, *cmd_done;
 	u8 wait = 10;
 	u32 done;
 
-	addr = base_addr + MAC_ADDR_REG_OFFSET;
-	wr = base_addr + MAC_WRITE_REG_OFFSET;
-	cmd = base_addr + MAC_COMMAND_REG_OFFSET;
-	cmd_done = base_addr + MAC_COMMAND_DONE_REG_OFFSET;
+	addr = pdata->mac_csr_addr + MAC_ADDR_REG_OFFSET;
+	wr = pdata->mac_csr_addr + MAC_WRITE_REG_OFFSET;
+	cmd = pdata->mac_csr_addr + MAC_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mac_csr_addr + MAC_COMMAND_DONE_REG_OFFSET;
 
+	spin_lock(&pdata->mac_lock);
 	iowrite32(wr_addr, addr);
-	iowrite32(wr_data, wr);
+	iowrite32(data, wr);
 	iowrite32(XGENE_ENET_WR_CMD, cmd);
 
-	while (wait--) {
-		done = ioread32(cmd_done);
-		if (done)
-			break;
+	while (!(done = ioread32(cmd_done)) && wait--)
 		udelay(1);
-	}
 
 	if (!done)
 		pr_err("MCX mac write failed, addr: 0x%04x\n", wr_addr);
 
 	iowrite32(0, cmd);
+	spin_unlock(&pdata->mac_lock);
 }
+EXPORT_SYMBOL(xgene_mdio_wr_mac);
 
 int xgene_mdio_rgmii_read(struct mii_bus *bus, int phy_id, int reg)
 {
-	void __iomem *addr = (void __iomem *)bus->priv;
+	struct xgene_mdio_pdata *pdata = (struct xgene_mdio_pdata *)bus->priv;
 	u32 data, done;
 	u8 wait = 10;
 
 	data = SET_VAL(PHY_ADDR, phy_id) | SET_VAL(REG_ADDR, reg);
-	xgene_enet_wr_mac(addr, MII_MGMT_ADDRESS_ADDR, data);
-	xgene_enet_wr_mac(addr, MII_MGMT_COMMAND_ADDR, READ_CYCLE_MASK);
+	xgene_mdio_wr_mac(pdata, MII_MGMT_ADDRESS_ADDR, data);
+	xgene_mdio_wr_mac(pdata, MII_MGMT_COMMAND_ADDR, READ_CYCLE_MASK);
 	do {
 		usleep_range(5, 10);
-		done = xgene_enet_rd_mac(addr, MII_MGMT_INDICATORS_ADDR);
+		done = xgene_mdio_rd_mac(pdata, MII_MGMT_INDICATORS_ADDR);
 	} while ((done & BUSY_MASK) && wait--);
 
 	if (done & BUSY_MASK) {
@@ -111,8 +108,8 @@ int xgene_mdio_rgmii_read(struct mii_bus *bus, int phy_id, int reg)
 		return -EBUSY;
 	}
 
-	data = xgene_enet_rd_mac(addr, MII_MGMT_STATUS_ADDR);
-	xgene_enet_wr_mac(addr, MII_MGMT_COMMAND_ADDR, 0);
+	data = xgene_mdio_rd_mac(pdata, MII_MGMT_STATUS_ADDR);
+	xgene_mdio_wr_mac(pdata, MII_MGMT_COMMAND_ADDR, 0);
 
 	return data;
 }
@@ -120,17 +117,17 @@ int xgene_mdio_rgmii_read(struct mii_bus *bus, int phy_id, int reg)
 
 int xgene_mdio_rgmii_write(struct mii_bus *bus, int phy_id, int reg, u16 data)
 {
-	void __iomem *addr = (void __iomem *)bus->priv;
+	struct xgene_mdio_pdata *pdata = (struct xgene_mdio_pdata *)bus->priv;
 	u32 val, done;
 	u8 wait = 10;
 
 	val = SET_VAL(PHY_ADDR, phy_id) | SET_VAL(REG_ADDR, reg);
-	xgene_enet_wr_mac(addr, MII_MGMT_ADDRESS_ADDR, val);
+	xgene_mdio_wr_mac(pdata, MII_MGMT_ADDRESS_ADDR, val);
 
-	xgene_enet_wr_mac(addr, MII_MGMT_CONTROL_ADDR, data);
+	xgene_mdio_wr_mac(pdata, MII_MGMT_CONTROL_ADDR, data);
 	do {
 		usleep_range(5, 10);
-		done = xgene_enet_rd_mac(addr, MII_MGMT_INDICATORS_ADDR);
+		done = xgene_mdio_rd_mac(pdata, MII_MGMT_INDICATORS_ADDR);
 	} while ((done & BUSY_MASK) && wait--);
 
 	if (done & BUSY_MASK) {
@@ -174,8 +171,8 @@ static int xgene_enet_ecc_init(struct xgene_mdio_pdata *pdata)
 
 static void xgene_gmac_reset(struct xgene_mdio_pdata *pdata)
 {
-	xgene_enet_wr_mac(pdata->mac_csr_addr, MAC_CONFIG_1_ADDR, SOFT_RESET);
-	xgene_enet_wr_mac(pdata->mac_csr_addr, MAC_CONFIG_1_ADDR, 0);
+	xgene_mdio_wr_mac(pdata, MAC_CONFIG_1_ADDR, SOFT_RESET);
+	xgene_mdio_wr_mac(pdata, MAC_CONFIG_1_ADDR, 0);
 }
 
 static int xgene_mdio_reset(struct xgene_mdio_pdata *pdata)
@@ -375,6 +372,9 @@ static int xgene_mdio_probe(struct platform_device *pdev)
 	pdata->mdio_csr_addr = csr_base + BLOCK_XG_MDIO_CSR_OFFSET;
 	pdata->diag_csr_addr = csr_base + BLOCK_DIAG_CSR_OFFSET;
 
+	if (mdio_id == XGENE_MDIO_RGMII)
+		spin_lock_init(&pdata->mac_lock);
+
 	if (dev->of_node) {
 		pdata->clk = devm_clk_get(dev, NULL);
 		if (IS_ERR(pdata->clk)) {
@@ -396,7 +396,7 @@ static int xgene_mdio_probe(struct platform_device *pdev)
 	if (mdio_id == XGENE_MDIO_RGMII) {
 		mdio_bus->read = xgene_mdio_rgmii_read;
 		mdio_bus->write = xgene_mdio_rgmii_write;
-		mdio_bus->priv = (void __force *)pdata->mac_csr_addr;
+		mdio_bus->priv = (void __force *)pdata;
 		snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s",
 			 "xgene-mii-rgmii");
 	} else {
diff --git a/drivers/net/phy/mdio-xgene.h b/drivers/net/phy/mdio-xgene.h
index 594a11d..3c85f3e 100644
--- a/drivers/net/phy/mdio-xgene.h
+++ b/drivers/net/phy/mdio-xgene.h
@@ -102,6 +102,7 @@ struct xgene_mdio_pdata {
 	void __iomem *mdio_csr_addr;
 	struct mii_bus *mdio_bus;
 	int mdio_id;
+	spinlock_t mac_lock; /* mac lock */
 };
 
 /* Set the specified value into a bit-field defined by its starting position
@@ -132,6 +133,8 @@ static inline u64 xgene_enet_get_field_value(int pos, int len, u64 src)
 #define GET_BIT(field, src) \
 		xgene_enet_get_field_value(field ## _POS, 1, src)
 
+u32 xgene_mdio_rd_mac(struct xgene_mdio_pdata *pdata, u32 rd_addr);
+void xgene_mdio_wr_mac(struct xgene_mdio_pdata *pdata, u32 wr_addr, u32 data);
 int xgene_mdio_rgmii_read(struct mii_bus *bus, int phy_id, int reg);
 int xgene_mdio_rgmii_write(struct mii_bus *bus, int phy_id, int reg, u16 data);
 struct phy_device *xgene_enet_phy_register(struct mii_bus *bus, int phy_addr);
-- 
1.9.1
