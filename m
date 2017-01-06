From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [net-next v1 6/8] net: netcp: ale: update to support unknown vlan controls for NU switch
Date: Fri, 6 Jan 2017 15:37:44 -0500
Message-ID: <1483735066-14632-7-git-send-email-m-karicheri2@ti.com>
References: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <mugunthanvnm@ti.com>,
        <linux-omap@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:59643 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031312AbdAFUhy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:37:54 -0500
In-Reply-To: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In NU Ethernet switch used on some of the Keystone SoCs, there is
separate UNKNOWNVLAN register for membership, unreg mcast flood, reg
mcast flood and force untag egress bits in ALE. So control for these
fields require different address offset, shift and size of field.
As this ALE has the same version number as ALE in CPSW found on other
SoCs, customization based on version number is not possible. So
use a configuration parameter, nu_switch_ale, to identify the ALE
ALE found in NU Switch. Different treatment is needed for NU Switch
ALE due to difference in the ale table bits, separate unknown vlan
registers etc. The register information available in ale_controls,
needs to be updated to support the netcp NU switch h/w. So it is not
constant array any more since it needs to be updated based
on ALE type. The header of the file is also updated to indicate it
supports N port switch ALE, not just 3 port. The version mask is
3 bits in NU Switch ALE vs 8 bits on other ALE types.

While at it, change the debug print to info print so that ALE
version gets displayed in boot log.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/cpsw_ale.c    | 50 +++++++++++++++++++++++++++++++----
 drivers/net/ethernet/ti/cpsw_ale.h    | 13 ++++++++-
 drivers/net/ethernet/ti/netcp_ethss.c |  5 +++-
 3 files changed, 61 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 43b061b..e15db39 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -1,5 +1,5 @@
 /*
- * Texas Instruments 3-Port Ethernet Switch Address Lookup Engine
+ * Texas Instruments N-Port Ethernet Switch Address Lookup Engine
  *
  * Copyright (C) 2012 Texas Instruments
  *
@@ -27,8 +27,9 @@
 
 #define BITMASK(bits)		(BIT(bits) - 1)
 
-#define ALE_VERSION_MAJOR(rev)	((rev >> 8) & 0xff)
+#define ALE_VERSION_MAJOR(rev, mask) (((rev) >> 8) & (mask))
 #define ALE_VERSION_MINOR(rev)	(rev & 0xff)
+#define ALE_VERSION_1R4		0x0104
 
 /* ALE Registers */
 #define ALE_IDVER		0x00
@@ -39,6 +40,12 @@
 #define ALE_TABLE		0x34
 #define ALE_PORTCTL		0x40
 
+/* ALE NetCP NU switch specific Registers */
+#define ALE_UNKNOWNVLAN_MEMBER			0x90
+#define ALE_UNKNOWNVLAN_UNREG_MCAST_FLOOD	0x94
+#define ALE_UNKNOWNVLAN_REG_MCAST_FLOOD		0x98
+#define ALE_UNKNOWNVLAN_FORCE_UNTAG_EGRESS	0x9C
+
 #define ALE_TABLE_WRITE		BIT(31)
 
 #define ALE_TYPE_FREE			0
@@ -464,7 +471,7 @@ struct ale_control_info {
 	int		bits;
 };
 
-static const struct ale_control_info ale_controls[ALE_NUM_CONTROLS] = {
+static struct ale_control_info ale_controls[ALE_NUM_CONTROLS] = {
 	[ALE_ENABLE]		= {
 		.name		= "enable",
 		.offset		= ALE_CONTROL,
@@ -724,8 +731,41 @@ void cpsw_ale_start(struct cpsw_ale *ale)
 	u32 rev;
 
 	rev = __raw_readl(ale->params.ale_regs + ALE_IDVER);
-	dev_dbg(ale->params.dev, "initialized cpsw ale revision %d.%d\n",
-		ALE_VERSION_MAJOR(rev), ALE_VERSION_MINOR(rev));
+	if (!ale->params.major_ver_mask)
+		ale->params.major_ver_mask = 0xff;
+	ale->version =
+		(ALE_VERSION_MAJOR(rev, ale->params.major_ver_mask) << 8) |
+		 ALE_VERSION_MINOR(rev);
+	dev_info(ale->params.dev, "initialized cpsw ale version %d.%d\n",
+		 ALE_VERSION_MAJOR(rev, ale->params.major_ver_mask),
+		 ALE_VERSION_MINOR(rev));
+
+	if (ale->params.nu_switch_ale) {
+		/* Separate registers for unknown vlan configuration.
+		 * Also there are N bits, where N is number of ale
+		 * ports and shift value should be 0
+		 */
+		ale_controls[ALE_PORT_UNKNOWN_VLAN_MEMBER].bits =
+					ale->params.ale_ports;
+		ale_controls[ALE_PORT_UNKNOWN_VLAN_MEMBER].offset =
+					ALE_UNKNOWNVLAN_MEMBER;
+		ale_controls[ALE_PORT_UNKNOWN_MCAST_FLOOD].bits =
+					ale->params.ale_ports;
+		ale_controls[ALE_PORT_UNKNOWN_MCAST_FLOOD].shift = 0;
+		ale_controls[ALE_PORT_UNKNOWN_MCAST_FLOOD].offset =
+					ALE_UNKNOWNVLAN_UNREG_MCAST_FLOOD;
+		ale_controls[ALE_PORT_UNKNOWN_REG_MCAST_FLOOD].bits =
+					ale->params.ale_ports;
+		ale_controls[ALE_PORT_UNKNOWN_REG_MCAST_FLOOD].shift = 0;
+		ale_controls[ALE_PORT_UNKNOWN_REG_MCAST_FLOOD].offset =
+					ALE_UNKNOWNVLAN_REG_MCAST_FLOOD;
+		ale_controls[ALE_PORT_UNTAGGED_EGRESS].bits =
+					ale->params.ale_ports;
+		ale_controls[ALE_PORT_UNTAGGED_EGRESS].shift = 0;
+		ale_controls[ALE_PORT_UNTAGGED_EGRESS].offset =
+					ALE_UNKNOWNVLAN_FORCE_UNTAG_EGRESS;
+	}
+
 	cpsw_ale_control_set(ale, 0, ALE_ENABLE, 1);
 	cpsw_ale_control_set(ale, 0, ALE_CLEAR, 1);
 
diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
index a700189..b1c7954 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.h
+++ b/drivers/net/ethernet/ti/cpsw_ale.h
@@ -1,5 +1,5 @@
 /*
- * Texas Instruments 3-Port Ethernet Switch Address Lookup Engine APIs
+ * Texas Instruments N-Port Ethernet Switch Address Lookup Engine APIs
  *
  * Copyright (C) 2012 Texas Instruments
  *
@@ -21,6 +21,16 @@ struct cpsw_ale_params {
 	unsigned long		ale_ageout;	/* in secs */
 	unsigned long		ale_entries;
 	unsigned long		ale_ports;
+	/* NU Switch has specific handling as number of bits in ALE entries
+	 * are different than other versions of ALE. Also there are specific
+	 * registers for unknown vlan specific fields. So use nu_switch_ale
+	 * to identify this hardware.
+	 */
+	bool			nu_switch_ale;
+	/* mask bit used in NU Switch ALE is 3 bits instead of 8 bits. So
+	 * pass it from caller.
+	 */
+	u32			major_ver_mask;
 };
 
 struct cpsw_ale {
@@ -28,6 +38,7 @@ struct cpsw_ale {
 	struct timer_list	timer;
 	unsigned long		ageout;
 	int			allmulti;
+	u32			version;
 };
 
 enum cpsw_ale_control {
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 6bb8e26..e4a1862 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -3609,7 +3609,10 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	ale_params.ale_ageout	= GBE_DEFAULT_ALE_AGEOUT;
 	ale_params.ale_entries	= gbe_dev->ale_entries;
 	ale_params.ale_ports	= gbe_dev->ale_ports;
-
+	if (IS_SS_ID_MU(gbe_dev)) {
+		ale_params.major_ver_mask = 0x7;
+		ale_params.nu_switch_ale = true;
+	}
 	gbe_dev->ale = cpsw_ale_create(&ale_params);
 	if (!gbe_dev->ale) {
 		dev_err(gbe_dev->dev, "error initializing ale engine\n");
-- 
1.9.1
