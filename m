From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v3 net-next 3/6] drivers: net: xgene-v2: Add ethernet hardware configuration
Date: Fri,  3 Mar 2017 17:09:29 -0800
Message-ID: <1488589773-28055-4-git-send-email-isubramanian@apm.com>
References: <1488589773-28055-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
        f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35001 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751970AbdCDBIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 20:08:46 -0500
Received: by mail-pg0-f43.google.com with SMTP id b129so49134317pgc.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 17:08:44 -0800 (PST)
In-Reply-To: <1488589773-28055-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds functions to configure ethernet hardware.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 drivers/net/ethernet/apm/xgene-v2/enet.c | 71 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/enet.h | 43 +++++++++++++++++++
 2 files changed, 114 insertions(+)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/enet.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/enet.h

diff --git a/drivers/net/ethernet/apm/xgene-v2/enet.c b/drivers/net/ethernet/apm/xgene-v2/enet.c
new file mode 100644
index 0000000..b49edee
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/enet.c
@@ -0,0 +1,71 @@
+/*
+ * Applied Micro X-Gene SoC Ethernet v2 Driver
+ *
+ * Copyright (c) 2017, Applied Micro Circuits Corporation
+ * Author(s): Iyappan Subramanian <isubramanian@apm.com>
+ *	      Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "main.h"
+
+void xge_wr_csr(struct xge_pdata *pdata, u32 offset, u32 val)
+{
+	void __iomem *addr = pdata->resources.base_addr + offset;
+
+	iowrite32(val, addr);
+}
+
+u32 xge_rd_csr(struct xge_pdata *pdata, u32 offset)
+{
+	void __iomem *addr = pdata->resources.base_addr + offset;
+
+	return ioread32(addr);
+}
+
+int xge_port_reset(struct net_device *ndev)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+
+	xge_wr_csr(pdata, ENET_SRST, 0x3);
+	xge_wr_csr(pdata, ENET_SRST, 0x2);
+	xge_wr_csr(pdata, ENET_SRST, 0x0);
+
+	xge_wr_csr(pdata, ENET_SHIM, DEVM_ARAUX_COH | DEVM_AWAUX_COH);
+
+	return 0;
+}
+
+static void xge_traffic_resume(struct net_device *ndev)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+
+	xge_wr_csr(pdata, CFG_FORCE_LINK_STATUS_EN, 1);
+	xge_wr_csr(pdata, FORCE_LINK_STATUS, 1);
+
+	xge_wr_csr(pdata, CFG_LINK_AGGR_RESUME, 1);
+	xge_wr_csr(pdata, RX_DV_GATE_REG, 1);
+}
+
+int xge_port_init(struct net_device *ndev)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+
+	pdata->phy_speed = SPEED_1000;
+	xge_mac_init(pdata);
+	xge_traffic_resume(ndev);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/apm/xgene-v2/enet.h b/drivers/net/ethernet/apm/xgene-v2/enet.h
new file mode 100644
index 0000000..40371cf
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/enet.h
@@ -0,0 +1,43 @@
+/*
+ * Applied Micro X-Gene SoC Ethernet v2 Driver
+ *
+ * Copyright (c) 2017, Applied Micro Circuits Corporation
+ * Author(s): Iyappan Subramanian <isubramanian@apm.com>
+ *	      Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __XGENE_ENET_V2_ENET_H__
+#define __XGENE_ENET_V2_ENET_H__
+
+#define ENET_CLKEN		0xc008
+#define ENET_SRST		0xc000
+#define ENET_SHIM		0xc010
+#define CFG_MEM_RAM_SHUTDOWN	0xd070
+#define BLOCK_MEM_RDY		0xd074
+
+#define DEVM_ARAUX_COH		BIT(19)
+#define DEVM_AWAUX_COH		BIT(3)
+
+#define CFG_FORCE_LINK_STATUS_EN	0x229c
+#define FORCE_LINK_STATUS		0x22a0
+#define CFG_LINK_AGGR_RESUME		0x27c8
+#define RX_DV_GATE_REG			0x2dfc
+
+void xge_wr_csr(struct xge_pdata *pdata, u32 offset, u32 val);
+u32 xge_rd_csr(struct xge_pdata *pdata, u32 offset);
+int xge_port_reset(struct net_device *ndev);
+
+#endif  /* __XGENE_ENET_V2_ENET__H__ */
-- 
1.9.1
