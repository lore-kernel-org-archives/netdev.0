From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH 4/7] devlink: Adding perm config of link settings
Date: Tue, 17 Oct 2017 16:44:26 -0400
Message-ID: <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:49935 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760630AbdJQUoq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:44:46 -0400
In-Reply-To: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extending DEVLINK_ATTR_PERM_CFG (permanent/NVRAM device configuration)
to include persistent configuration of device link settings:

DEVLINK_ATTR_PERM_CFG_AUTONEG_PROTOCOL: Configure default autoneg
protocol; use enum devlink_autoneg_protocol.

DEVLINK_ATTR_PERM_CFG_MEDIA_AUTO_DETECT: Configure default
auto-detection of attached media connector (1 = enable, 0 =
disable).

DEVLINK_ATTR_PERM_CFG_PHY_SELECT: Configure default external PHY
selection (0 = PHY 0, 1 = PHY 1).

DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D0: Configure default
pre-OS link speed in full power (D0) state; use enum
devlink_pre_os_link_speed.

DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3: Configure default
pre-OS link speed in sleep (D3) state; use enum
devlink_pre_os_link_speed.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 27 ++++++++++++++++++++++++++-
 net/core/devlink.c           |  5 +++++
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 4a9eafd..2e1c006 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -142,6 +142,26 @@ enum devlink_multifunc_mode {
 	DEVLINK_MULTIFUNC_MODE_NPAR20,		/* NPAR 2.0 */
 };
 
+enum devlink_autoneg_protocol {
+	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_BAM,
+	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_CONSORTIUM,
+	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY,
+	DEVLINK_AUTONEG_PROTOCOL_BAM,		/* Broadcom Autoneg Mode */
+	DEVLINK_AUTONEG_PROTOCOL_CONSORTIUM,	/* Consortium Autoneg Mode */
+};
+
+enum devlink_pre_os_link_speed {
+	DEVLINK_PRE_OS_LINK_SPEED_AUTONEG,
+	DEVLINK_PRE_OS_LINK_SPEED_1G,
+	DEVLINK_PRE_OS_LINK_SPEED_10G,
+	DEVLINK_PRE_OS_LINK_SPEED_25G,
+	DEVLINK_PRE_OS_LINK_SPEED_40G,
+	DEVLINK_PRE_OS_LINK_SPEED_50G,
+	DEVLINK_PRE_OS_LINK_SPEED_100G,
+	DEVLINK_PRE_OS_LINK_SPEED_5G = 0xe,
+	DEVLINK_PRE_OS_LINK_SPEED_100M = 0xf,
+};
+
 enum devlink_attr {
 	/* don't change the order or add anything between, this is ABI! */
 	DEVLINK_ATTR_UNSPEC,
@@ -249,9 +269,14 @@ enum devlink_attr {
 	DEVLINK_ATTR_PERM_CFG_PME_CAPABILITY_ENABLED,	/* u8 */
 	DEVLINK_ATTR_PERM_CFG_MAGIC_PACKET_WOL_ENABLED,	/* u8 */
 	DEVLINK_ATTR_PERM_CFG_EEE_PWR_SAVE_ENABLED,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_AUTONEG_PROTOCOL,		/* u32 */
+	DEVLINK_ATTR_PERM_CFG_MEDIA_AUTO_DETECT,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_PHY_SELECT,		/* u8 */
+	DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D0,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3,	/* u32 */
 
 	/* Add new permanent config parameters above here */
-	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_EEE_PWR_SAVE_ENABLED,
+	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3,
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index d611154..80a2a50 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -2562,6 +2562,11 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_PERM_CFG_PME_CAPABILITY_ENABLED] = { .type = NLA_U8 },
 	[DEVLINK_ATTR_PERM_CFG_MAGIC_PACKET_WOL_ENABLED] = { .type = NLA_U8 },
 	[DEVLINK_ATTR_PERM_CFG_EEE_PWR_SAVE_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_AUTONEG_PROTOCOL] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_MEDIA_AUTO_DETECT] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_PHY_SELECT] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D0] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3] = { .type = NLA_U32 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
-- 
2.7.4
