From: Amit Kumar Salecha <amit@netxen.com>
Subject: [net-2.6 PATCH 2/3] netxen: fix promisc for NX2031.
Date: Fri, 20 Nov 2009 17:09:33 -0800
Message-ID: <1258765774-27068-3-git-send-email-amit@netxen.com>
References: <1258765774-27068-1-git-send-email-amit@netxen.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	Narender Kumar <narender.kumar@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:27776 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753160AbZKUBJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 20:09:28 -0500
In-Reply-To: <1258765774-27068-1-git-send-email-amit@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narender Kumar <narender.kumar@qlogic.com>

Kernel crashes, if promisc mode set without disabling rx queue.
Before changing mode in NX2031 chip, wait till rx queue drains.

Signed-off-by: Narender Kumar <narender.kumar@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hdr.h |    2 +
 drivers/net/netxen/netxen_nic_hw.c  |   49 +++++++++++++++++++++++++++--------
 2 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 1c46da6..17bb381 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -545,6 +545,8 @@ enum {
 #define	NETXEN_NIU_TEST_MUX_CTL		(NETXEN_CRB_NIU + 0x00094)
 #define	NETXEN_NIU_XG_PAUSE_CTL		(NETXEN_CRB_NIU + 0x00098)
 #define	NETXEN_NIU_XG_PAUSE_LEVEL	(NETXEN_CRB_NIU + 0x000dc)
+#define	NETXEN_NIU_FRAME_COUNT_SELECT	(NETXEN_CRB_NIU + 0x000ac)
+#define	NETXEN_NIU_FRAME_COUNT		(NETXEN_CRB_NIU + 0x000b0)
 #define	NETXEN_NIU_XG_SEL		(NETXEN_CRB_NIU + 0x00128)
 #define NETXEN_NIU_GB_PAUSE_CTL		(NETXEN_CRB_NIU + 0x0030c)
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 3185a98..e2c4a01 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -383,24 +383,51 @@ int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 
 int netxen_p2_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
 {
-	__u32 reg;
+	u32 mac_cfg;
+	u32 cnt = 0;
+	__u32 reg = 0x0200;
 	u32 port = adapter->physical_port;
+	u16 board_type = adapter->ahw.board_type;
 
 	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
 
-	reg = NXRD32(adapter, NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port));
-	if (mode == NETXEN_NIU_PROMISC_MODE)
-		reg = (reg | 0x2000UL);
-	else
-		reg = (reg & ~0x2000UL);
+	mac_cfg = NXRD32(adapter, NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port));
+	mac_cfg &= ~0x4;
+	NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), mac_cfg);
 
-	if (mode == NETXEN_NIU_ALLMULTI_MODE)
-		reg = (reg | 0x1000UL);
-	else
-		reg = (reg & ~0x1000UL);
+	if ((board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ) ||
+			(board_type == NETXEN_BRDTYPE_P2_SB31_10G_HMEZ))
+		reg = (0x20 << port);
+
+	NXWR32(adapter, NETXEN_NIU_FRAME_COUNT_SELECT, reg);
+
+	mdelay(10);
+
+	while (NXRD32(adapter, NETXEN_NIU_FRAME_COUNT) && ++cnt < 20)
+		mdelay(10);
+
+	if (cnt < 20) {
+
+		reg = NXRD32(adapter,
+			NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port));
+
+		if (mode == NETXEN_NIU_PROMISC_MODE)
+			reg = (reg | 0x2000UL);
+		else
+			reg = (reg & ~0x2000UL);
+
+		if (mode == NETXEN_NIU_ALLMULTI_MODE)
+			reg = (reg | 0x1000UL);
+		else
+			reg = (reg & ~0x1000UL);
+
+		NXWR32(adapter,
+			NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port), reg);
+	}
 
-	NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port), reg);
+	mac_cfg |= 0x4;
+	NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), mac_cfg);
 
 	return 0;
 }
-- 
1.6.0.2

