From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH 5/7] devlink: Adding pre-boot permanent config parameters
Date: Tue, 17 Oct 2017 16:44:27 -0400
Message-ID: <1508273069-40461-6-git-send-email-steven.lin1@broadcom.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:49943 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760635AbdJQUor (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:44:47 -0400
In-Reply-To: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extending DEVLINK_ATTR_PERM_CFG (permanent/NVRAM device configuration)
to include some pre-boot device configuration settings:

DEVLINK_ATTR_PERM_CFG_MBA_ENABLED: 1 to enable Multiple Boot
Agent (BMA), 0 to disable.

DEVLINK_ATTR_PERM_CFG_MBA_BOOT_TYPE: Controls mechanism MBA will
use to insert itself into the list of devices recognized by the
BIOS; use enum devlink_mba_boot_type.

DEVLINK_ATTR_PERM_CFG_MBA_DELAY_TIME: Controls how long MBA
banner display and ability to enter MBA setup will persist
during initialization, in seconds.

DEVLINK_ATTR_PERM_CFG_MBA_SETUP_HOT_KEY: Configures which hot-key
will be used to enter MBA setup; use enum devlink_mba_setup_hot_key.

DEVLINK_ATTR_PERM_CFG_MBA_HIDE_SETUP_PROMPT: 1 to enable hiding
of 'enter setup' prompt during initialization, 0 to disable.

DEVLINK_ATTR_PERM_CFG_MBA_BOOT_RETRY_COUNT: MBA retries booting
this number of times, if it fails initially.

DEVLINK_ATTR_PERM_CFG_MBA_VLAN_ENABLED: 1 to enable using VLAN
when executing MBA host software (PXE/iSCSI), 0 to disable.

DEVLINK_ATTR_PERM_CFG_MBA_VLAN_TAG: The 16 bit VLAN tag to use
if MBA_VLAN_ENABLED is set.

DEVLINK_ATTR_PERM_CFG_MBA_BOOT_PROTOCOL: Selects MBA boot
protocol; use enum devlink_mba_boot_protocol.

DEVLINK_ATTR_PERM_CFG_MBA_LINK_SPEED: Configured link speed
while executing MBA host software (PXI/iSCSI); use enum
devlink_mba_link_speed.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 39 ++++++++++++++++++++++++++++++++++++++-
 net/core/devlink.c           | 10 ++++++++++
 2 files changed, 48 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 2e1c006..609784a 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -162,6 +162,33 @@ enum devlink_pre_os_link_speed {
 	DEVLINK_PRE_OS_LINK_SPEED_100M = 0xf,
 };
 
+enum devlink_mba_boot_type {
+	DEVLINK_MBA_BOOT_TYPE_AUTO_DETECT,
+	DEVLINK_MBA_BOOT_TYPE_BBS,		/* BIOS Boot Specification */
+	DEVLINK_MBA_BOOT_TYPE_INTR18,		/* Hook interrupt 0x18 */
+	DEVLINK_MBA_BOOT_TYPE_INTR19,		/* Hook interrupt 0x19 */
+};
+
+enum devlink_mba_setup_hot_key {
+	DEVLINK_MBA_SETUP_HOT_KEY_CTRL_S,
+	DEVLINK_MBA_SETUP_HOT_KEY_CTRL_B,
+};
+
+enum devlink_mba_boot_protocol {
+	DEVLINK_MBA_BOOT_PROTOCOL_PXE,
+	DEVLINK_MBA_BOOT_PROTOCOL_ISCSI,
+	DEVLINK_MBA_BOOT_PROTOCOL_NONE = 0x7,
+};
+
+enum devlink_mba_link_speed {
+	DEVLINK_MBA_LINK_SPEED_AUTONEG,
+	DEVLINK_MBA_LINK_SPEED_1G,
+	DEVLINK_MBA_LINK_SPEED_10G,
+	DEVLINK_MBA_LINK_SPEED_25G,
+	DEVLINK_MBA_LINK_SPEED_40G,
+	DEVLINK_MBA_LINK_SPEED_50G,
+};
+
 enum devlink_attr {
 	/* don't change the order or add anything between, this is ABI! */
 	DEVLINK_ATTR_UNSPEC,
@@ -274,9 +301,19 @@ enum devlink_attr {
 	DEVLINK_ATTR_PERM_CFG_PHY_SELECT,		/* u8 */
 	DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D0,	/* u32 */
 	DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_MBA_ENABLED,		/* u8 */
+	DEVLINK_ATTR_PERM_CFG_MBA_BOOT_TYPE,		/* u32 */
+	DEVLINK_ATTR_PERM_CFG_MBA_DELAY_TIME,		/* u32 */
+	DEVLINK_ATTR_PERM_CFG_MBA_SETUP_HOT_KEY,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_MBA_HIDE_SETUP_PROMPT,	/* u8 */
+	DEVLINK_ATTR_PERM_CFG_MBA_BOOT_RETRY_COUNT,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_MBA_VLAN_ENABLED,		/* u8 */
+	DEVLINK_ATTR_PERM_CFG_MBA_VLAN_TAG,		/* u16 */
+	DEVLINK_ATTR_PERM_CFG_MBA_BOOT_PROTOCOL,	/* u32 */
+	DEVLINK_ATTR_PERM_CFG_MBA_LINK_SPEED,		/* u32 */
 
 	/* Add new permanent config parameters above here */
-	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3,
+	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_MBA_LINK_SPEED,
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 80a2a50..2eaa566 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -2567,6 +2567,16 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_PERM_CFG_PHY_SELECT] = { .type = NLA_U8 },
 	[DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D0] = { .type = NLA_U32 },
 	[DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_BOOT_TYPE] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_DELAY_TIME] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_SETUP_HOT_KEY] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_HIDE_SETUP_PROMPT] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_BOOT_RETRY_COUNT] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_VLAN_ENABLED] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_VLAN_TAG] = { .type = NLA_U16 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_BOOT_PROTOCOL] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PERM_CFG_MBA_LINK_SPEED] = { .type = NLA_U32 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
-- 
2.7.4
