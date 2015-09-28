From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 3/4] nl802154: add support for security layer
Date: Mon, 28 Sep 2015 09:00:25 +0200
Message-ID: <1443423626-3609-4-git-send-email-alex.aring@gmail.com>
References: <1443423626-3609-1-git-send-email-alex.aring@gmail.com>
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de,
	Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35476 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267AbbI1HCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 03:02:19 -0400
In-Reply-To: <1443423626-3609-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for accessing mac802154 llsec implementation
over nl802154. I added for a new Kconfig entry to provide this
functionality CONFIG_IEEE802154_NL802154_EXPERIMENTAL. This interface is
still in development. It provides to change security parameters and
add/del/dump entries of security tables. Later we can add also a get to
get an entry by unique identifier.

Cc: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 include/net/cfg802154.h         |  131 ++++
 include/net/ieee802154_netdev.h |   75 ---
 include/net/nl802154.h          |  191 ++++++
 net/ieee802154/Kconfig          |    5 +
 net/ieee802154/core.c           |   12 +
 net/ieee802154/core.h           |    1 +
 net/ieee802154/nl802154.c       | 1316 ++++++++++++++++++++++++++++++++++++---
 net/ieee802154/rdev-ops.h       |  109 ++++
 net/mac802154/cfg.c             |  205 ++++++
 9 files changed, 1876 insertions(+), 169 deletions(-)

diff --git a/include/net/cfg802154.h b/include/net/cfg802154.h
index 242273c..171cd76 100644
--- a/include/net/cfg802154.h
+++ b/include/net/cfg802154.h
@@ -27,6 +27,16 @@
 struct wpan_phy;
 struct wpan_phy_cca;
 
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+struct ieee802154_llsec_device_key;
+struct ieee802154_llsec_seclevel;
+struct ieee802154_llsec_params;
+struct ieee802154_llsec_device;
+struct ieee802154_llsec_table;
+struct ieee802154_llsec_key_id;
+struct ieee802154_llsec_key;
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
 struct cfg802154_ops {
 	struct net_device * (*add_virtual_intf_deprecated)(struct wpan_phy *wpan_phy,
 							   const char *name,
@@ -65,6 +75,51 @@ struct cfg802154_ops {
 				struct wpan_dev *wpan_dev, bool mode);
 	int	(*set_ackreq_default)(struct wpan_phy *wpan_phy,
 				      struct wpan_dev *wpan_dev, bool ackreq);
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+	void	(*get_llsec_table)(struct wpan_phy *wpan_phy,
+				   struct wpan_dev *wpan_dev,
+				   struct ieee802154_llsec_table **table);
+	void	(*lock_llsec_table)(struct wpan_phy *wpan_phy,
+				    struct wpan_dev *wpan_dev);
+	void	(*unlock_llsec_table)(struct wpan_phy *wpan_phy,
+				      struct wpan_dev *wpan_dev);
+	/* TODO remove locking/get table callbacks, this is part of the
+	 * nl802154 interface and should be accessible from ieee802154 layer.
+	 */
+	int	(*get_llsec_params)(struct wpan_phy *wpan_phy,
+				    struct wpan_dev *wpan_dev,
+				    struct ieee802154_llsec_params *params);
+	int	(*set_llsec_params)(struct wpan_phy *wpan_phy,
+				    struct wpan_dev *wpan_dev,
+				    const struct ieee802154_llsec_params *params,
+				    int changed);
+	int	(*add_llsec_key)(struct wpan_phy *wpan_phy,
+				 struct wpan_dev *wpan_dev,
+				 const struct ieee802154_llsec_key_id *id,
+				 const struct ieee802154_llsec_key *key);
+	int	(*del_llsec_key)(struct wpan_phy *wpan_phy,
+				 struct wpan_dev *wpan_dev,
+				 const struct ieee802154_llsec_key_id *id);
+	int	(*add_seclevel)(struct wpan_phy *wpan_phy,
+				 struct wpan_dev *wpan_dev,
+				 const struct ieee802154_llsec_seclevel *sl);
+	int	(*del_seclevel)(struct wpan_phy *wpan_phy,
+				 struct wpan_dev *wpan_dev,
+				 const struct ieee802154_llsec_seclevel *sl);
+	int	(*add_device)(struct wpan_phy *wpan_phy,
+			      struct wpan_dev *wpan_dev,
+			      const struct ieee802154_llsec_device *dev);
+	int	(*del_device)(struct wpan_phy *wpan_phy,
+			      struct wpan_dev *wpan_dev, __le64 extended_addr);
+	int	(*add_devkey)(struct wpan_phy *wpan_phy,
+			      struct wpan_dev *wpan_dev,
+			      __le64 extended_addr,
+			      const struct ieee802154_llsec_device_key *key);
+	int	(*del_devkey)(struct wpan_phy *wpan_phy,
+			      struct wpan_dev *wpan_dev,
+			      __le64 extended_addr,
+			      const struct ieee802154_llsec_device_key *key);
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
 };
 
 static inline bool
@@ -176,6 +231,82 @@ struct ieee802154_addr {
 	};
 };
 
+struct ieee802154_llsec_key_id {
+	u8 mode;
+	u8 id;
+	union {
+		struct ieee802154_addr device_addr;
+		__le32 short_source;
+		__le64 extended_source;
+	};
+};
+
+#define IEEE802154_LLSEC_KEY_SIZE 16
+
+struct ieee802154_llsec_key {
+	u8 frame_types;
+	u32 cmd_frame_ids;
+	/* TODO replace with NL802154_KEY_SIZE */
+	u8 key[IEEE802154_LLSEC_KEY_SIZE];
+};
+
+struct ieee802154_llsec_key_entry {
+	struct list_head list;
+
+	struct ieee802154_llsec_key_id id;
+	struct ieee802154_llsec_key *key;
+};
+
+struct ieee802154_llsec_params {
+	bool enabled;
+
+	__be32 frame_counter;
+	u8 out_level;
+	struct ieee802154_llsec_key_id out_key;
+
+	__le64 default_key_source;
+
+	__le16 pan_id;
+	__le64 hwaddr;
+	__le64 coord_hwaddr;
+	__le16 coord_shortaddr;
+};
+
+struct ieee802154_llsec_table {
+	struct list_head keys;
+	struct list_head devices;
+	struct list_head security_levels;
+};
+
+struct ieee802154_llsec_seclevel {
+	struct list_head list;
+
+	u8 frame_type;
+	u8 cmd_frame_id;
+	bool device_override;
+	u32 sec_levels;
+};
+
+struct ieee802154_llsec_device {
+	struct list_head list;
+
+	__le16 pan_id;
+	__le16 short_addr;
+	__le64 hwaddr;
+	u32 frame_counter;
+	bool seclevel_exempt;
+
+	u8 key_mode;
+	struct list_head keys;
+};
+
+struct ieee802154_llsec_device_key {
+	struct list_head list;
+
+	struct ieee802154_llsec_key_id key_id;
+	u32 frame_counter;
+};
+
 struct wpan_dev_header_ops {
 	/* TODO create callback currently assumes ieee802154_mac_cb inside
 	 * skb->cb. This should be changed to give these information as
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index aebb9d8..a62a051 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -234,38 +234,6 @@ static inline struct ieee802154_mac_cb *mac_cb_init(struct sk_buff *skb)
 	return mac_cb(skb);
 }
 
-#define IEEE802154_LLSEC_KEY_SIZE 16
-
-struct ieee802154_llsec_key_id {
-	u8 mode;
-	u8 id;
-	union {
-		struct ieee802154_addr device_addr;
-		__le32 short_source;
-		__le64 extended_source;
-	};
-};
-
-struct ieee802154_llsec_key {
-	u8 frame_types;
-	u32 cmd_frame_ids;
-	u8 key[IEEE802154_LLSEC_KEY_SIZE];
-};
-
-struct ieee802154_llsec_key_entry {
-	struct list_head list;
-
-	struct ieee802154_llsec_key_id id;
-	struct ieee802154_llsec_key *key;
-};
-
-struct ieee802154_llsec_device_key {
-	struct list_head list;
-
-	struct ieee802154_llsec_key_id key_id;
-	u32 frame_counter;
-};
-
 enum {
 	IEEE802154_LLSEC_DEVKEY_IGNORE,
 	IEEE802154_LLSEC_DEVKEY_RESTRICT,
@@ -274,49 +242,6 @@ enum {
 	__IEEE802154_LLSEC_DEVKEY_MAX,
 };
 
-struct ieee802154_llsec_device {
-	struct list_head list;
-
-	__le16 pan_id;
-	__le16 short_addr;
-	__le64 hwaddr;
-	u32 frame_counter;
-	bool seclevel_exempt;
-
-	u8 key_mode;
-	struct list_head keys;
-};
-
-struct ieee802154_llsec_seclevel {
-	struct list_head list;
-
-	u8 frame_type;
-	u8 cmd_frame_id;
-	bool device_override;
-	u32 sec_levels;
-};
-
-struct ieee802154_llsec_params {
-	bool enabled;
-
-	__be32 frame_counter;
-	u8 out_level;
-	struct ieee802154_llsec_key_id out_key;
-
-	__le64 default_key_source;
-
-	__le16 pan_id;
-	__le64 hwaddr;
-	__le64 coord_hwaddr;
-	__le16 coord_shortaddr;
-};
-
-struct ieee802154_llsec_table {
-	struct list_head keys;
-	struct list_head devices;
-	struct list_head security_levels;
-};
-
 #define IEEE802154_MAC_SCAN_ED		0
 #define IEEE802154_MAC_SCAN_ACTIVE	1
 #define IEEE802154_MAC_SCAN_PASSIVE	2
diff --git a/include/net/nl802154.h b/include/net/nl802154.h
index cf2713d..32cb3e5 100644
--- a/include/net/nl802154.h
+++ b/include/net/nl802154.h
@@ -56,6 +56,22 @@ enum nl802154_commands {
 
 	/* add new commands above here */
 
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+	NL802154_CMD_SET_SEC_PARAMS,
+	NL802154_CMD_GET_SEC_KEY,		/* can dump */
+	NL802154_CMD_NEW_SEC_KEY,
+	NL802154_CMD_DEL_SEC_KEY,
+	NL802154_CMD_GET_SEC_DEV,		/* can dump */
+	NL802154_CMD_NEW_SEC_DEV,
+	NL802154_CMD_DEL_SEC_DEV,
+	NL802154_CMD_GET_SEC_DEVKEY,		/* can dump */
+	NL802154_CMD_NEW_SEC_DEVKEY,
+	NL802154_CMD_DEL_SEC_DEVKEY,
+	NL802154_CMD_GET_SEC_LEVEL,		/* can dump */
+	NL802154_CMD_NEW_SEC_LEVEL,
+	NL802154_CMD_DEL_SEC_LEVEL,
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
 	/* used to define NL802154_CMD_MAX below */
 	__NL802154_CMD_AFTER_LAST,
 	NL802154_CMD_MAX = __NL802154_CMD_AFTER_LAST - 1
@@ -110,6 +126,18 @@ enum nl802154_attrs {
 
 	/* add attributes here, update the policy in nl802154.c */
 
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+	NL802154_ATTR_SEC_ENABLED,
+	NL802154_ATTR_SEC_OUT_LEVEL,
+	NL802154_ATTR_SEC_OUT_KEY_ID,
+	NL802154_ATTR_SEC_FRAME_COUNTER,
+
+	NL802154_ATTR_SEC_LEVEL,
+	NL802154_ATTR_SEC_DEVICE,
+	NL802154_ATTR_SEC_DEVKEY,
+	NL802154_ATTR_SEC_KEY,
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
 	__NL802154_ATTR_AFTER_LAST,
 	NL802154_ATTR_MAX = __NL802154_ATTR_AFTER_LAST - 1
 };
@@ -247,4 +275,167 @@ enum nl802154_supported_bool_states {
 	NL802154_SUPPORTED_BOOL_MAX = __NL802154_SUPPORTED_BOOL_AFTER_LAST - 1
 };
 
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+
+enum nl802154_dev_addr_modes {
+	NL802154_DEV_ADDR_NONE,
+	__NL802154_DEV_ADDR_INVALID,
+	NL802154_DEV_ADDR_SHORT,
+	NL802154_DEV_ADDR_EXTENDED,
+
+	/* keep last */
+	__NL802154_DEV_ADDR_AFTER_LAST,
+	NL802154_DEV_ADDR_MAX = __NL802154_DEV_ADDR_AFTER_LAST - 1
+};
+
+enum nl802154_dev_addr_attrs {
+	NL802154_DEV_ADDR_ATTR_UNSPEC,
+
+	NL802154_DEV_ADDR_ATTR_PAN_ID,
+	NL802154_DEV_ADDR_ATTR_MODE,
+	NL802154_DEV_ADDR_ATTR_SHORT,
+	NL802154_DEV_ADDR_ATTR_EXTENDED,
+
+	/* keep last */
+	__NL802154_DEV_ADDR_ATTR_AFTER_LAST,
+	NL802154_DEV_ADDR_ATTR_MAX = __NL802154_DEV_ADDR_ATTR_AFTER_LAST - 1
+};
+
+enum nl802154_key_id_modes {
+	NL802154_KEY_ID_MODE_IMPLICIT,
+	NL802154_KEY_ID_MODE_INDEX,
+	NL802154_KEY_ID_MODE_INDEX_SHORT,
+	NL802154_KEY_ID_MODE_INDEX_EXTENDED,
+
+	/* keep last */
+	__NL802154_KEY_ID_MODE_AFTER_LAST,
+	NL802154_KEY_ID_MODE_MAX = __NL802154_KEY_ID_MODE_AFTER_LAST - 1
+};
+
+enum nl802154_key_id_attrs {
+	NL802154_KEY_ID_ATTR_UNSPEC,
+
+	NL802154_KEY_ID_ATTR_MODE,
+	NL802154_KEY_ID_ATTR_INDEX,
+	NL802154_KEY_ID_ATTR_IMPLICIT,
+	NL802154_KEY_ID_ATTR_SOURCE_SHORT,
+	NL802154_KEY_ID_ATTR_SOURCE_EXTENDED,
+
+	/* keep last */
+	__NL802154_KEY_ID_ATTR_AFTER_LAST,
+	NL802154_KEY_ID_ATTR_MAX = __NL802154_KEY_ID_ATTR_AFTER_LAST - 1
+};
+
+enum nl802154_seclevels {
+	NL802154_SECLEVEL_NONE,
+	NL802154_SECLEVEL_MIC32,
+	NL802154_SECLEVEL_MIC64,
+	NL802154_SECLEVEL_MIC128,
+	NL802154_SECLEVEL_ENC,
+	NL802154_SECLEVEL_ENC_MIC32,
+	NL802154_SECLEVEL_ENC_MIC64,
+	NL802154_SECLEVEL_ENC_MIC128,
+
+	/* keep last */
+	__NL802154_SECLEVEL_AFTER_LAST,
+	NL802154_SECLEVEL_MAX = __NL802154_SECLEVEL_AFTER_LAST - 1
+};
+
+enum nl802154_frames {
+	NL802154_FRAME_BEACON,
+	NL802154_FRAME_DATA,
+	NL802154_FRAME_ACK,
+	NL802154_FRAME_CMD,
+
+	/* keep last */
+	__NL802154_FRAME_AFTER_LAST,
+	NL802154_FRAME_MAX = __NL802154_FRAME_AFTER_LAST - 1
+};
+
+enum nl802154_cmd_frames {
+	__NL802154_CMD_FRAME_INVALID,
+	NL802154_CMD_FRAME_ASSOC_REQUEST,
+	NL802154_CMD_FRAME_ASSOC_RESPONSE,
+	NL802154_CMD_FRAME_DISASSOC_NOTIFY,
+	NL802154_CMD_FRAME_DATA_REQUEST,
+	NL802154_CMD_FRAME_PAN_ID_CONFLICT_NOTIFY,
+	NL802154_CMD_FRAME_ORPHAN_NOTIFY,
+	NL802154_CMD_FRAME_BEACON_REQUEST,
+	NL802154_CMD_FRAME_COORD_REALIGNMENT,
+	NL802154_CMD_FRAME_GTS_REQUEST,
+
+	/* keep last */
+	__NL802154_CMD_FRAME_AFTER_LAST,
+	NL802154_CMD_FRAME_MAX = __NL802154_CMD_FRAME_AFTER_LAST - 1
+};
+
+enum nl802154_seclevel_attrs {
+	NL802154_SECLEVEL_ATTR_UNSPEC,
+
+	NL802154_SECLEVEL_ATTR_LEVELS,
+	NL802154_SECLEVEL_ATTR_FRAME,
+	NL802154_SECLEVEL_ATTR_CMD_FRAME,
+	NL802154_SECLEVEL_ATTR_DEV_OVERRIDE,
+
+	/* keep last */
+	__NL802154_SECLEVEL_ATTR_AFTER_LAST,
+	NL802154_SECLEVEL_ATTR_MAX = __NL802154_SECLEVEL_ATTR_AFTER_LAST - 1
+};
+
+/* TODO what is this? couldn't find in mib */
+enum {
+	NL802154_DEVKEY_IGNORE,
+	NL802154_DEVKEY_RESTRICT,
+	NL802154_DEVKEY_RECORD,
+
+	/* keep last */
+	__NL802154_DEVKEY_AFTER_LAST,
+	NL802154_DEVKEY_MAX = __NL802154_DEVKEY_AFTER_LAST - 1
+};
+
+enum nl802154_dev {
+	NL802154_DEV_ATTR_UNSPEC,
+
+	NL802154_DEV_ATTR_FRAME_COUNTER,
+	NL802154_DEV_ATTR_PAN_ID,
+	NL802154_DEV_ATTR_SHORT_ADDR,
+	NL802154_DEV_ATTR_EXTENDED_ADDR,
+	NL802154_DEV_ATTR_SECLEVEL_EXEMPT,
+	NL802154_DEV_ATTR_KEY_MODE,
+
+	/* keep last */
+	__NL802154_DEV_ATTR_AFTER_LAST,
+	NL802154_DEV_ATTR_MAX = __NL802154_DEV_ATTR_AFTER_LAST - 1
+};
+
+enum nl802154_devkey {
+	NL802154_DEVKEY_ATTR_UNSPEC,
+
+	NL802154_DEVKEY_ATTR_FRAME_COUNTER,
+	NL802154_DEVKEY_ATTR_EXTENDED_ADDR,
+	NL802154_DEVKEY_ATTR_ID,
+
+	/* keep last */
+	__NL802154_DEVKEY_ATTR_AFTER_LAST,
+	NL802154_DEVKEY_ATTR_MAX = __NL802154_DEVKEY_ATTR_AFTER_LAST - 1
+};
+
+enum nl802154_key {
+	NL802154_KEY_ATTR_UNSPEC,
+
+	NL802154_KEY_ATTR_ID,
+	NL802154_KEY_ATTR_USAGE_FRAMES,
+	NL802154_KEY_ATTR_USAGE_CMDS,
+	NL802154_KEY_ATTR_BYTES,
+
+	/* keep last */
+	__NL802154_KEY_ATTR_AFTER_LAST,
+	NL802154_KEY_ATTR_MAX = __NL802154_KEY_ATTR_AFTER_LAST - 1
+};
+
+#define NL802154_KEY_SIZE		16
+#define NL802154_CMD_FRAME_NR_IDS	256
+
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
 #endif /* __NL802154_H */
diff --git a/net/ieee802154/Kconfig b/net/ieee802154/Kconfig
index 1370d5b..188135b 100644
--- a/net/ieee802154/Kconfig
+++ b/net/ieee802154/Kconfig
@@ -12,6 +12,11 @@ menuconfig IEEE802154
 
 if IEEE802154
 
+config IEEE802154_NL802154_EXPERIMENTAL
+	bool "IEEE 802.15.4 experimental netlink support"
+	---help---
+	  Adds experimental netlink support for nl802154.
+
 config IEEE802154_SOCKET
 	tristate "IEEE 802.15.4 socket interface"
 	default y
diff --git a/net/ieee802154/core.c b/net/ieee802154/core.c
index b0248e9..c35fdfa 100644
--- a/net/ieee802154/core.c
+++ b/net/ieee802154/core.c
@@ -95,6 +95,18 @@ cfg802154_rdev_by_wpan_phy_idx(int wpan_phy_idx)
 	return result;
 }
 
+struct wpan_phy *wpan_phy_idx_to_wpan_phy(int wpan_phy_idx)
+{
+	struct cfg802154_registered_device *rdev;
+
+	ASSERT_RTNL();
+
+	rdev = cfg802154_rdev_by_wpan_phy_idx(wpan_phy_idx);
+	if (!rdev)
+		return NULL;
+	return &rdev->wpan_phy;
+}
+
 struct wpan_phy *
 wpan_phy_new(const struct cfg802154_ops *ops, size_t priv_size)
 {
diff --git a/net/ieee802154/core.h b/net/ieee802154/core.h
index f3e9558..231fade 100644
--- a/net/ieee802154/core.h
+++ b/net/ieee802154/core.h
@@ -42,5 +42,6 @@ extern int cfg802154_rdev_list_generation;
 void cfg802154_dev_free(struct cfg802154_registered_device *rdev);
 struct cfg802154_registered_device *
 cfg802154_rdev_by_wpan_phy_idx(int wpan_phy_idx);
+struct wpan_phy *wpan_phy_idx_to_wpan_phy(int wpan_phy_idx);
 
 #endif /* __IEEE802154_CORE_H */
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index 51110a6..1e9e865 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -232,8 +232,86 @@ static const struct nla_policy nl802154_policy[NL802154_ATTR_MAX+1] = {
 	[NL802154_ATTR_SUPPORTED_COMMANDS] = { .type = NLA_NESTED },
 
 	[NL802154_ATTR_ACKREQ_DEFAULT] = { .type = NLA_U8 },
+
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+	[NL802154_ATTR_SEC_ENABLED] = { .type = NLA_U8, },
+	[NL802154_ATTR_SEC_OUT_LEVEL] = { .type = NLA_U32, },
+	[NL802154_ATTR_SEC_OUT_KEY_ID] = { .type = NLA_NESTED, },
+	[NL802154_ATTR_SEC_FRAME_COUNTER] = { .type = NLA_U32 },
+
+	[NL802154_ATTR_SEC_LEVEL] = { .type = NLA_NESTED },
+	[NL802154_ATTR_SEC_DEVICE] = { .type = NLA_NESTED },
+	[NL802154_ATTR_SEC_DEVKEY] = { .type = NLA_NESTED },
+	[NL802154_ATTR_SEC_KEY] = { .type = NLA_NESTED },
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
 };
 
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+static int
+nl802154_prepare_wpan_dev_dump(struct sk_buff *skb,
+			       struct netlink_callback *cb,
+			       struct cfg802154_registered_device **rdev,
+			       struct wpan_dev **wpan_dev)
+{
+	int err;
+
+	rtnl_lock();
+
+	if (!cb->args[0]) {
+		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl802154_fam.hdrsize,
+				  nl802154_fam.attrbuf, nl802154_fam.maxattr,
+				  nl802154_policy);
+		if (err)
+			goto out_unlock;
+
+		*wpan_dev = __cfg802154_wpan_dev_from_attrs(sock_net(skb->sk),
+							    nl802154_fam.attrbuf);
+		if (IS_ERR(*wpan_dev)) {
+			err = PTR_ERR(*wpan_dev);
+			goto out_unlock;
+		}
+		*rdev = wpan_phy_to_rdev((*wpan_dev)->wpan_phy);
+		/* 0 is the first index - add 1 to parse only once */
+		cb->args[0] = (*rdev)->wpan_phy_idx + 1;
+		cb->args[1] = (*wpan_dev)->identifier;
+	} else {
+		/* subtract the 1 again here */
+		struct wpan_phy *wpan_phy = wpan_phy_idx_to_wpan_phy(cb->args[0] - 1);
+		struct wpan_dev *tmp;
+
+		if (!wpan_phy) {
+			err = -ENODEV;
+			goto out_unlock;
+		}
+		*rdev = wpan_phy_to_rdev(wpan_phy);
+		*wpan_dev = NULL;
+
+		list_for_each_entry(tmp, &(*rdev)->wpan_dev_list, list) {
+			if (tmp->identifier == cb->args[1]) {
+				*wpan_dev = tmp;
+				break;
+			}
+		}
+
+		if (!*wpan_dev) {
+			err = -ENODEV;
+			goto out_unlock;
+		}
+	}
+
+	return 0;
+ out_unlock:
+	rtnl_unlock();
+	return err;
+}
+
+static void
+nl802154_finish_wpan_dev_dump(struct cfg802154_registered_device *rdev)
+{
+	rtnl_unlock();
+}
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
 /* message building helper */
 static inline void *nl802154hdr_put(struct sk_buff *skb, u32 portid, u32 seq,
 				    int flags, u8 cmd)
@@ -612,6 +690,107 @@ static inline u64 wpan_dev_id(struct wpan_dev *wpan_dev)
 	       ((u64)wpan_phy_to_rdev(wpan_dev->wpan_phy)->wpan_phy_idx << 32);
 }
 
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+#include <net/ieee802154_netdev.h>
+
+static int
+ieee802154_llsec_send_key_id(struct sk_buff *msg,
+			     const struct ieee802154_llsec_key_id *desc)
+{
+	struct nlattr *nl_dev_addr;
+
+	if (nla_put_u32(msg, NL802154_KEY_ID_ATTR_MODE, desc->mode))
+		return -ENOBUFS;
+
+	switch (desc->mode) {
+	case NL802154_KEY_ID_MODE_IMPLICIT:
+		nl_dev_addr = nla_nest_start(msg, NL802154_KEY_ID_ATTR_IMPLICIT);
+		if (!nl_dev_addr)
+			return -ENOBUFS;
+
+		if (nla_put_le16(msg, NL802154_DEV_ADDR_ATTR_PAN_ID,
+				 desc->device_addr.pan_id) ||
+		    nla_put_u32(msg,  NL802154_DEV_ADDR_ATTR_MODE,
+				desc->device_addr.mode))
+			return -ENOBUFS;
+
+		switch (desc->device_addr.mode) {
+		case NL802154_DEV_ADDR_SHORT:
+			if (nla_put_le16(msg, NL802154_DEV_ADDR_ATTR_SHORT,
+					 desc->device_addr.short_addr))
+				return -ENOBUFS;
+			break;
+		case NL802154_DEV_ADDR_EXTENDED:
+			if (nla_put_le64(msg, NL802154_DEV_ADDR_ATTR_EXTENDED,
+					 desc->device_addr.extended_addr))
+				return -ENOBUFS;
+			break;
+		default:
+			/* userspace should handle unknown */
+			break;
+		}
+
+		nla_nest_end(msg, nl_dev_addr);
+		break;
+	case NL802154_KEY_ID_MODE_INDEX:
+		break;
+	case NL802154_KEY_ID_MODE_INDEX_SHORT:
+		/* TODO renmae short_source? */
+		if (nla_put_le32(msg, NL802154_KEY_ID_ATTR_SOURCE_SHORT,
+				 desc->short_source))
+			return -ENOBUFS;
+		break;
+	case NL802154_KEY_ID_MODE_INDEX_EXTENDED:
+		if (nla_put_le64(msg, NL802154_KEY_ID_ATTR_SOURCE_EXTENDED,
+				 desc->extended_source))
+			return -ENOBUFS;
+		break;
+	default:
+		/* userspace should handle unknown */
+		break;
+	}
+
+	/* TODO key_id to key_idx ? Check naming */
+	if (desc->mode != NL802154_KEY_ID_MODE_IMPLICIT) {
+		if (nla_put_u8(msg, NL802154_KEY_ID_ATTR_INDEX, desc->id))
+			return -ENOBUFS;
+	}
+
+	return 0;
+}
+
+static int nl802154_get_llsec_params(struct sk_buff *msg,
+				     struct cfg802154_registered_device *rdev,
+				     struct wpan_dev *wpan_dev)
+{
+	struct nlattr *nl_key_id;
+	struct ieee802154_llsec_params params;
+	int ret;
+
+	ret = rdev_get_llsec_params(rdev, wpan_dev, &params);
+	if (ret < 0)
+		return ret;
+
+	if (nla_put_u8(msg, NL802154_ATTR_SEC_ENABLED, params.enabled) ||
+	    nla_put_u32(msg, NL802154_ATTR_SEC_OUT_LEVEL, params.out_level) ||
+	    nla_put_be32(msg, NL802154_ATTR_SEC_FRAME_COUNTER,
+			 params.frame_counter))
+		return -ENOBUFS;
+
+	nl_key_id = nla_nest_start(msg, NL802154_ATTR_SEC_OUT_KEY_ID);
+	if (!nl_key_id)
+		return -ENOBUFS;
+
+	ret = ieee802154_llsec_send_key_id(msg, &params.out_key);
+	if (ret < 0)
+		return ret;
+
+	nla_nest_end(msg, nl_key_id);
+
+	return 0;
+}
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
 static int
 nl802154_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flags,
 		    struct cfg802154_registered_device *rdev,
@@ -663,6 +842,11 @@ nl802154_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flags,
 	if (nla_put_u8(msg, NL802154_ATTR_ACKREQ_DEFAULT, wpan_dev->ackreq))
 		goto nla_put_failure;
 
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+	if (nl802154_get_llsec_params(msg, rdev, wpan_dev) < 0)
+		goto nla_put_failure;
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
 	genlmsg_end(msg, hdr);
 	return 0;
 
@@ -1073,122 +1257,953 @@ nl802154_set_ackreq_default(struct sk_buff *skb, struct genl_info *info)
 	return rdev_set_ackreq_default(rdev, wpan_dev, ackreq);
 }
 
-#define NL802154_FLAG_NEED_WPAN_PHY	0x01
-#define NL802154_FLAG_NEED_NETDEV	0x02
-#define NL802154_FLAG_NEED_RTNL		0x04
-#define NL802154_FLAG_CHECK_NETDEV_UP	0x08
-#define NL802154_FLAG_NEED_NETDEV_UP	(NL802154_FLAG_NEED_NETDEV |\
-					 NL802154_FLAG_CHECK_NETDEV_UP)
-#define NL802154_FLAG_NEED_WPAN_DEV	0x10
-#define NL802154_FLAG_NEED_WPAN_DEV_UP	(NL802154_FLAG_NEED_WPAN_DEV |\
-					 NL802154_FLAG_CHECK_NETDEV_UP)
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+static const struct nla_policy nl802154_dev_addr_policy[NL802154_DEV_ADDR_ATTR_MAX + 1] = {
+	[NL802154_DEV_ADDR_ATTR_PAN_ID] = { .type = NLA_U16 },
+	[NL802154_DEV_ADDR_ATTR_MODE] = { .type = NLA_U32 },
+	[NL802154_DEV_ADDR_ATTR_SHORT] = { .type = NLA_U16 },
+	[NL802154_DEV_ADDR_ATTR_EXTENDED] = { .type = NLA_U64 },
+};
 
-static int nl802154_pre_doit(const struct genl_ops *ops, struct sk_buff *skb,
-			     struct genl_info *info)
+static int
+ieee802154_llsec_parse_dev_addr(struct nlattr *nla,
+				struct ieee802154_addr *addr)
 {
-	struct cfg802154_registered_device *rdev;
-	struct wpan_dev *wpan_dev;
-	struct net_device *dev;
-	bool rtnl = ops->internal_flags & NL802154_FLAG_NEED_RTNL;
+	struct nlattr *attrs[NL802154_DEV_ADDR_ATTR_MAX + 1];
 
-	if (rtnl)
-		rtnl_lock();
+	if (!nla || nla_parse_nested(attrs, NL802154_DEV_ADDR_ATTR_MAX, nla,
+				     nl802154_dev_addr_policy))
+		return -EINVAL;
 
-	if (ops->internal_flags & NL802154_FLAG_NEED_WPAN_PHY) {
-		rdev = cfg802154_get_dev_from_info(genl_info_net(info), info);
-		if (IS_ERR(rdev)) {
-			if (rtnl)
-				rtnl_unlock();
-			return PTR_ERR(rdev);
-		}
-		info->user_ptr[0] = rdev;
-	} else if (ops->internal_flags & NL802154_FLAG_NEED_NETDEV ||
-		   ops->internal_flags & NL802154_FLAG_NEED_WPAN_DEV) {
-		ASSERT_RTNL();
-		wpan_dev = __cfg802154_wpan_dev_from_attrs(genl_info_net(info),
-							   info->attrs);
-		if (IS_ERR(wpan_dev)) {
-			if (rtnl)
-				rtnl_unlock();
-			return PTR_ERR(wpan_dev);
-		}
+	if (!attrs[NL802154_DEV_ADDR_ATTR_PAN_ID] &&
+	    !attrs[NL802154_DEV_ADDR_ATTR_MODE] &&
+	    !(attrs[NL802154_DEV_ADDR_ATTR_SHORT] ||
+	      attrs[NL802154_DEV_ADDR_ATTR_EXTENDED]))
+		return -EINVAL;
 
-		dev = wpan_dev->netdev;
-		rdev = wpan_phy_to_rdev(wpan_dev->wpan_phy);
+	addr->pan_id = nla_get_le16(attrs[NL802154_DEV_ADDR_ATTR_PAN_ID]);
+	addr->mode = nla_get_u32(attrs[NL802154_DEV_ADDR_ATTR_MODE]);
+	switch (addr->mode) {
+	case NL802154_DEV_ADDR_SHORT:
+		addr->short_addr = nla_get_le16(attrs[NL802154_DEV_ADDR_ATTR_SHORT]);
+		break;
+	case NL802154_DEV_ADDR_EXTENDED:
+		addr->extended_addr = nla_get_le64(attrs[NL802154_DEV_ADDR_ATTR_EXTENDED]);
+		break;
+	default:
+		return -EINVAL;
+	}
 
-		if (ops->internal_flags & NL802154_FLAG_NEED_NETDEV) {
-			if (!dev) {
-				if (rtnl)
-					rtnl_unlock();
-				return -EINVAL;
-			}
+	return 0;
+}
 
-			info->user_ptr[1] = dev;
-		} else {
-			info->user_ptr[1] = wpan_dev;
-		}
+static const struct nla_policy nl802154_key_id_policy[NL802154_KEY_ID_ATTR_MAX + 1] = {
+	[NL802154_KEY_ID_ATTR_MODE] = { .type = NLA_U32 },
+	[NL802154_KEY_ID_ATTR_INDEX] = { .type = NLA_U8 },
+	[NL802154_KEY_ID_ATTR_IMPLICIT] = { .type = NLA_NESTED },
+	[NL802154_KEY_ID_ATTR_SOURCE_SHORT] = { .type = NLA_U32 },
+	[NL802154_KEY_ID_ATTR_SOURCE_EXTENDED] = { .type = NLA_U64 },
+};
 
-		if (dev) {
-			if (ops->internal_flags & NL802154_FLAG_CHECK_NETDEV_UP &&
-			    !netif_running(dev)) {
-				if (rtnl)
-					rtnl_unlock();
-				return -ENETDOWN;
-			}
+static int
+ieee802154_llsec_parse_key_id(struct nlattr *nla,
+			      struct ieee802154_llsec_key_id *desc)
+{
+	struct nlattr *attrs[NL802154_KEY_ID_ATTR_MAX + 1];
 
-			dev_hold(dev);
-		}
+	if (!nla || nla_parse_nested(attrs, NL802154_KEY_ID_ATTR_MAX, nla,
+				     nl802154_key_id_policy))
+		return -EINVAL;
 
-		info->user_ptr[0] = rdev;
+	if (!attrs[NL802154_KEY_ID_ATTR_MODE])
+		return -EINVAL;
+
+	desc->mode = nla_get_u32(attrs[NL802154_KEY_ID_ATTR_MODE]);
+	switch (desc->mode) {
+	case NL802154_KEY_ID_MODE_IMPLICIT:
+		if (!attrs[NL802154_KEY_ID_ATTR_IMPLICIT])
+			return -EINVAL;
+
+		if (ieee802154_llsec_parse_dev_addr(attrs[NL802154_KEY_ID_ATTR_IMPLICIT],
+						    &desc->device_addr) < 0)
+			return -EINVAL;
+		break;
+	case NL802154_KEY_ID_MODE_INDEX:
+		break;
+	case NL802154_KEY_ID_MODE_INDEX_SHORT:
+		if (!attrs[NL802154_KEY_ID_ATTR_SOURCE_SHORT])
+			return -EINVAL;
+
+		desc->short_source = nla_get_le32(attrs[NL802154_KEY_ID_ATTR_SOURCE_SHORT]);
+		break;
+	case NL802154_KEY_ID_MODE_INDEX_EXTENDED:
+		if (!attrs[NL802154_KEY_ID_ATTR_SOURCE_EXTENDED])
+			return -EINVAL;
+
+		desc->extended_source = nla_get_le64(attrs[NL802154_KEY_ID_ATTR_SOURCE_EXTENDED]);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (desc->mode != NL802154_KEY_ID_MODE_IMPLICIT) {
+		if (!attrs[NL802154_KEY_ID_ATTR_INDEX])
+			return -EINVAL;
+
+		/* TODO change id to idx */
+		desc->id = nla_get_u8(attrs[NL802154_KEY_ID_ATTR_INDEX]);
 	}
 
 	return 0;
 }
 
-static void nl802154_post_doit(const struct genl_ops *ops, struct sk_buff *skb,
-			       struct genl_info *info)
+static int nl802154_set_llsec_params(struct sk_buff *skb,
+				     struct genl_info *info)
 {
-	if (info->user_ptr[1]) {
-		if (ops->internal_flags & NL802154_FLAG_NEED_WPAN_DEV) {
-			struct wpan_dev *wpan_dev = info->user_ptr[1];
+	struct cfg802154_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wpan_dev *wpan_dev = dev->ieee802154_ptr;
+	struct ieee802154_llsec_params params;
+	u32 changed = 0;
+	int ret;
 
-			if (wpan_dev->netdev)
-				dev_put(wpan_dev->netdev);
-		} else {
-			dev_put(info->user_ptr[1]);
+	if (info->attrs[NL802154_ATTR_SEC_ENABLED]) {
+		u8 enabled;
+
+		enabled = nla_get_u8(info->attrs[NL802154_ATTR_SEC_ENABLED]);
+		if (enabled != 0 && enabled != 1)
+			return -EINVAL;
+
+		params.enabled = nla_get_u8(info->attrs[NL802154_ATTR_SEC_ENABLED]);
+		changed |= IEEE802154_LLSEC_PARAM_ENABLED;
+	}
+
+	if (info->attrs[NL802154_ATTR_SEC_OUT_KEY_ID]) {
+		ret = ieee802154_llsec_parse_key_id(info->attrs[NL802154_ATTR_SEC_OUT_KEY_ID],
+						    &params.out_key);
+		if (ret < 0)
+			return ret;
+
+		changed |= IEEE802154_LLSEC_PARAM_OUT_KEY;
+	}
+
+	if (info->attrs[NL802154_ATTR_SEC_OUT_LEVEL]) {
+		params.out_level = nla_get_u32(info->attrs[NL802154_ATTR_SEC_OUT_LEVEL]);
+		if (params.out_level > NL802154_SECLEVEL_MAX)
+			return -EINVAL;
+
+		changed |= IEEE802154_LLSEC_PARAM_OUT_LEVEL;
+	}
+
+	if (info->attrs[NL802154_ATTR_SEC_FRAME_COUNTER]) {
+		params.frame_counter = nla_get_be32(info->attrs[NL802154_ATTR_SEC_FRAME_COUNTER]);
+		changed |= IEEE802154_LLSEC_PARAM_FRAME_COUNTER;
+	}
+
+	return rdev_set_llsec_params(rdev, wpan_dev, &params, changed);
+}
+
+static int nl802154_send_key(struct sk_buff *msg, u32 cmd, u32 portid,
+			     u32 seq, int flags,
+			     struct cfg802154_registered_device *rdev,
+			     struct net_device *dev,
+			     const struct ieee802154_llsec_key_entry *key)
+{
+	void *hdr;
+	u32 commands[NL802154_CMD_FRAME_NR_IDS / 32];
+	struct nlattr *nl_key, *nl_key_id;
+
+	hdr = nl802154hdr_put(msg, portid, seq, flags, cmd);
+	if (!hdr)
+		return -1;
+
+	if (nla_put_u32(msg, NL802154_ATTR_IFINDEX, dev->ifindex))
+		goto nla_put_failure;
+
+	nl_key = nla_nest_start(msg, NL802154_ATTR_SEC_KEY);
+	if (!nl_key)
+		goto nla_put_failure;
+
+	nl_key_id = nla_nest_start(msg, NL802154_KEY_ATTR_ID);
+	if (!nl_key_id)
+		goto nla_put_failure;
+
+	if (ieee802154_llsec_send_key_id(msg, &key->id) < 0)
+		goto nla_put_failure;
+
+	nla_nest_end(msg, nl_key_id);
+
+	if (nla_put_u8(msg, NL802154_KEY_ATTR_USAGE_FRAMES,
+		       key->key->frame_types))
+		goto nla_put_failure;
+
+	if (key->key->frame_types & BIT(NL802154_FRAME_CMD)) {
+		/* TODO for each nested */
+		memset(commands, 0, sizeof(commands));
+		commands[7] = key->key->cmd_frame_ids;
+		if (nla_put(msg, NL802154_KEY_ATTR_USAGE_CMDS,
+			    sizeof(commands), commands))
+			goto nla_put_failure;
+	}
+
+	if (nla_put(msg, NL802154_KEY_ATTR_BYTES, NL802154_KEY_SIZE,
+		    key->key->key))
+		goto nla_put_failure;
+
+	nla_nest_end(msg, nl_key);
+	genlmsg_end(msg, hdr);
+
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int
+nl802154_dump_llsec_key(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct cfg802154_registered_device *rdev = NULL;
+	struct ieee802154_llsec_key_entry *key;
+	struct ieee802154_llsec_table *table;
+	struct wpan_dev *wpan_dev;
+	int err;
+
+	err = nl802154_prepare_wpan_dev_dump(skb, cb, &rdev, &wpan_dev);
+	if (err)
+		return err;
+
+	if (!wpan_dev->netdev) {
+		err = -EINVAL;
+		goto out_err;
+	}
+
+	rdev_lock_llsec_table(rdev, wpan_dev);
+	rdev_get_llsec_table(rdev, wpan_dev, &table);
+
+	/* TODO make it like station dump */
+	if (cb->args[2])
+		goto out;
+
+	list_for_each_entry(key, &table->keys, list) {
+		if (nl802154_send_key(skb, NL802154_CMD_NEW_SEC_KEY,
+				      NETLINK_CB(cb->skb).portid,
+				      cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				      rdev, wpan_dev->netdev, key) < 0) {
+			/* TODO */
+			err = -EIO;
+			rdev_unlock_llsec_table(rdev, wpan_dev);
+			goto out_err;
 		}
 	}
 
-	if (ops->internal_flags & NL802154_FLAG_NEED_RTNL)
-		rtnl_unlock();
+	cb->args[2] = 1;
+
+out:
+	rdev_unlock_llsec_table(rdev, wpan_dev);
+	err = skb->len;
+out_err:
+	nl802154_finish_wpan_dev_dump(rdev);
+
+	return err;
 }
 
-static const struct genl_ops nl802154_ops[] = {
-	{
-		.cmd = NL802154_CMD_GET_WPAN_PHY,
-		.doit = nl802154_get_wpan_phy,
-		.dumpit = nl802154_dump_wpan_phy,
-		.done = nl802154_dump_wpan_phy_done,
-		.policy = nl802154_policy,
-		/* can be retrieved by unprivileged users */
-		.internal_flags = NL802154_FLAG_NEED_WPAN_PHY |
-				  NL802154_FLAG_NEED_RTNL,
-	},
-	{
-		.cmd = NL802154_CMD_GET_INTERFACE,
-		.doit = nl802154_get_interface,
-		.dumpit = nl802154_dump_interface,
-		.policy = nl802154_policy,
-		/* can be retrieved by unprivileged users */
-		.internal_flags = NL802154_FLAG_NEED_WPAN_DEV |
-				  NL802154_FLAG_NEED_RTNL,
-	},
-	{
-		.cmd = NL802154_CMD_NEW_INTERFACE,
-		.doit = nl802154_new_interface,
-		.policy = nl802154_policy,
-		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL802154_FLAG_NEED_WPAN_PHY |
+static const struct nla_policy nl802154_key_policy[NL802154_KEY_ATTR_MAX + 1] = {
+	[NL802154_KEY_ATTR_ID] = { NLA_NESTED },
+	/* TODO handle it as for_each_nested and NLA_FLAG? */
+	[NL802154_KEY_ATTR_USAGE_FRAMES] = { NLA_U8 },
+	/* TODO handle it as for_each_nested, not static array? */
+	[NL802154_KEY_ATTR_USAGE_CMDS] = { .len = NL802154_CMD_FRAME_NR_IDS / 8 },
+	[NL802154_KEY_ATTR_BYTES] = { .len = NL802154_KEY_SIZE },
+};
+
+static int nl802154_add_llsec_key(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg802154_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wpan_dev *wpan_dev = dev->ieee802154_ptr;
+	struct nlattr *attrs[NL802154_KEY_ATTR_MAX + 1];
+	struct ieee802154_llsec_key key = { };
+	struct ieee802154_llsec_key_id id = { };
+	u32 commands[NL802154_CMD_FRAME_NR_IDS / 32] = { };
+
+	if (nla_parse_nested(attrs, NL802154_KEY_ATTR_MAX,
+			     info->attrs[NL802154_ATTR_SEC_KEY],
+			     nl802154_key_policy))
+		return -EINVAL;
+
+	if (!attrs[NL802154_KEY_ATTR_USAGE_FRAMES] ||
+	    !attrs[NL802154_KEY_ATTR_BYTES])
+
+	if (ieee802154_llsec_parse_key_id(attrs[NL802154_KEY_ATTR_ID], &id) < 0)
+		return -ENOBUFS;
+
+	key.frame_types = nla_get_u8(attrs[NL802154_KEY_ATTR_USAGE_FRAMES]);
+	if (key.frame_types > BIT(NL802154_FRAME_MAX) ||
+	    ((key.frame_types & BIT(NL802154_FRAME_CMD)) &&
+	     !attrs[NL802154_KEY_ATTR_USAGE_CMDS]))
+		return -EINVAL;
+
+	if (attrs[NL802154_KEY_ATTR_USAGE_CMDS]) {
+		/* TODO for each nested */
+		nla_memcpy(commands, attrs[NL802154_KEY_ATTR_USAGE_CMDS],
+			   NL802154_CMD_FRAME_NR_IDS / 8);
+
+		/* TODO understand the -EINVAL logic here? last condition */
+		if (commands[0] || commands[1] || commands[2] || commands[3] ||
+		    commands[4] || commands[5] || commands[6] ||
+		    commands[7] > BIT(NL802154_CMD_FRAME_MAX))
+			return -EINVAL;
+
+		key.cmd_frame_ids = commands[7];
+	} else {
+		key.cmd_frame_ids = 0;
+	}
+
+	nla_memcpy(key.key, attrs[NL802154_KEY_ATTR_BYTES], NL802154_KEY_SIZE);
+
+	if (ieee802154_llsec_parse_key_id(attrs[NL802154_KEY_ATTR_ID], &id) < 0)
+		return -ENOBUFS;
+
+	return rdev_add_llsec_key(rdev, wpan_dev, &id, &key);
+}
+
+static int nl802154_del_llsec_key(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg802154_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wpan_dev *wpan_dev = dev->ieee802154_ptr;
+	struct nlattr *attrs[NL802154_KEY_ATTR_MAX + 1];
+	struct ieee802154_llsec_key_id id;
+
+	if (nla_parse_nested(attrs, NL802154_KEY_ATTR_MAX,
+			     info->attrs[NL802154_ATTR_SEC_KEY],
+			     nl802154_key_policy))
+		return -EINVAL;
+
+	if (ieee802154_llsec_parse_key_id(attrs[NL802154_KEY_ATTR_ID], &id) < 0)
+		return -ENOBUFS;
+
+	return rdev_del_llsec_key(rdev, wpan_dev, &id);
+}
+
+static int nl802154_send_device(struct sk_buff *msg, u32 cmd, u32 portid,
+				u32 seq, int flags,
+				struct cfg802154_registered_device *rdev,
+				struct net_device *dev,
+				const struct ieee802154_llsec_device *dev_desc)
+{
+	void *hdr;
+	struct nlattr *nl_device;
+
+	hdr = nl802154hdr_put(msg, portid, seq, flags, cmd);
+	if (!hdr)
+		return -1;
+
+	if (nla_put_u32(msg, NL802154_ATTR_IFINDEX, dev->ifindex))
+		goto nla_put_failure;
+
+	nl_device = nla_nest_start(msg, NL802154_ATTR_SEC_DEVICE);
+	if (!nl_device)
+		goto nla_put_failure;
+
+	if (nla_put_u32(msg, NL802154_DEV_ATTR_FRAME_COUNTER,
+			dev_desc->frame_counter) ||
+	    nla_put_le16(msg, NL802154_DEV_ATTR_PAN_ID, dev_desc->pan_id) ||
+	    nla_put_le16(msg, NL802154_DEV_ATTR_SHORT_ADDR,
+			 dev_desc->short_addr) ||
+	    nla_put_le64(msg, NL802154_DEV_ATTR_EXTENDED_ADDR,
+			 dev_desc->hwaddr) ||
+	    nla_put_u8(msg, NL802154_DEV_ATTR_SECLEVEL_EXEMPT,
+		       dev_desc->seclevel_exempt) ||
+	    nla_put_u32(msg, NL802154_DEV_ATTR_KEY_MODE, dev_desc->key_mode))
+		goto nla_put_failure;
+
+	nla_nest_end(msg, nl_device);
+	genlmsg_end(msg, hdr);
+
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int
+nl802154_dump_llsec_dev(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct cfg802154_registered_device *rdev = NULL;
+	struct ieee802154_llsec_device *dev;
+	struct ieee802154_llsec_table *table;
+	struct wpan_dev *wpan_dev;
+	int err;
+
+	err = nl802154_prepare_wpan_dev_dump(skb, cb, &rdev, &wpan_dev);
+	if (err)
+		return err;
+
+	if (!wpan_dev->netdev) {
+		err = -EINVAL;
+		goto out_err;
+	}
+
+	rdev_lock_llsec_table(rdev, wpan_dev);
+	rdev_get_llsec_table(rdev, wpan_dev, &table);
+
+	/* TODO make it like station dump */
+	if (cb->args[2])
+		goto out;
+
+	list_for_each_entry(dev, &table->devices, list) {
+		if (nl802154_send_device(skb, NL802154_CMD_NEW_SEC_LEVEL,
+					 NETLINK_CB(cb->skb).portid,
+					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					 rdev, wpan_dev->netdev, dev) < 0) {
+			/* TODO */
+			err = -EIO;
+			rdev_unlock_llsec_table(rdev, wpan_dev);
+			goto out_err;
+		}
+	}
+
+	cb->args[2] = 1;
+
+out:
+	rdev_unlock_llsec_table(rdev, wpan_dev);
+	err = skb->len;
+out_err:
+	nl802154_finish_wpan_dev_dump(rdev);
+
+	return err;
+}
+
+static const struct nla_policy nl802154_dev_policy[NL802154_DEV_ATTR_MAX + 1] = {
+	[NL802154_DEV_ATTR_FRAME_COUNTER] = { NLA_U32 },
+	[NL802154_DEV_ATTR_PAN_ID] = { .type = NLA_U16 },
+	[NL802154_DEV_ATTR_SHORT_ADDR] = { .type = NLA_U16 },
+	[NL802154_DEV_ATTR_EXTENDED_ADDR] = { .type = NLA_U64 },
+	[NL802154_DEV_ATTR_SECLEVEL_EXEMPT] = { NLA_U8 },
+	[NL802154_DEV_ATTR_KEY_MODE] = { NLA_U32 },
+};
+
+static int
+ieee802154_llsec_parse_device(struct nlattr *nla,
+			      struct ieee802154_llsec_device *dev)
+{
+	struct nlattr *attrs[NL802154_DEV_ATTR_MAX + 1];
+
+	if (!nla || nla_parse_nested(attrs, NL802154_DEV_ATTR_MAX, nla,
+				     nl802154_dev_policy))
+		return -EINVAL;
+
+	memset(dev, 0, sizeof(*dev));
+
+	if (!attrs[NL802154_DEV_ATTR_FRAME_COUNTER] ||
+	    !attrs[NL802154_DEV_ATTR_PAN_ID] ||
+	    !attrs[NL802154_DEV_ATTR_SHORT_ADDR] ||
+	    !attrs[NL802154_DEV_ATTR_EXTENDED_ADDR] ||
+	    !attrs[NL802154_DEV_ATTR_SECLEVEL_EXEMPT] ||
+	    !attrs[NL802154_DEV_ATTR_KEY_MODE])
+		return -EINVAL;
+
+	/* TODO be32 */
+	dev->frame_counter = nla_get_u32(attrs[NL802154_DEV_ATTR_FRAME_COUNTER]);
+	dev->pan_id = nla_get_le16(attrs[NL802154_DEV_ATTR_PAN_ID]);
+	dev->short_addr = nla_get_le16(attrs[NL802154_DEV_ATTR_SHORT_ADDR]);
+	/* TODO rename hwaddr to extended_addr */
+	dev->hwaddr = nla_get_le64(attrs[NL802154_DEV_ATTR_EXTENDED_ADDR]);
+	dev->seclevel_exempt = nla_get_u8(attrs[NL802154_DEV_ATTR_SECLEVEL_EXEMPT]);
+	dev->key_mode = nla_get_u32(attrs[NL802154_DEV_ATTR_KEY_MODE]);
+
+	if (dev->key_mode > NL802154_DEVKEY_MAX ||
+	    (dev->seclevel_exempt != 0 && dev->seclevel_exempt != 1))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int nl802154_add_llsec_dev(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg802154_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wpan_dev *wpan_dev = dev->ieee802154_ptr;
+	struct ieee802154_llsec_device dev_desc;
+
+	if (ieee802154_llsec_parse_device(info->attrs[NL802154_ATTR_SEC_DEVICE],
+					  &dev_desc) < 0)
+		return -EINVAL;
+
+	return rdev_add_device(rdev, wpan_dev, &dev_desc);
+}
+
+static int nl802154_del_llsec_dev(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg802154_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wpan_dev *wpan_dev = dev->ieee802154_ptr;
+	struct nlattr *attrs[NL802154_DEV_ATTR_MAX + 1];
+	__le64 extended_addr;
+
+	if (nla_parse_nested(attrs, NL802154_DEV_ATTR_MAX,
+			     info->attrs[NL802154_ATTR_SEC_DEVICE],
+			     nl802154_dev_policy))
+		return -EINVAL;
+
+	if (!attrs[NL802154_DEV_ATTR_EXTENDED_ADDR])
+		return -EINVAL;
+
+	extended_addr = nla_get_le64(attrs[NL802154_DEV_ATTR_EXTENDED_ADDR]);
+	return rdev_del_device(rdev, wpan_dev, extended_addr);
+}
+
+static int nl802154_send_devkey(struct sk_buff *msg, u32 cmd, u32 portid,
+				u32 seq, int flags,
+				struct cfg802154_registered_device *rdev,
+				struct net_device *dev, __le64 extended_addr,
+				const struct ieee802154_llsec_device_key *devkey)
+{
+	void *hdr;
+	struct nlattr *nl_devkey, *nl_key_id;
+
+	hdr = nl802154hdr_put(msg, portid, seq, flags, cmd);
+	if (!hdr)
+		return -1;
+
+	if (nla_put_u32(msg, NL802154_ATTR_IFINDEX, dev->ifindex))
+		goto nla_put_failure;
+
+	nl_devkey = nla_nest_start(msg, NL802154_ATTR_SEC_DEVKEY);
+	if (!nl_devkey)
+		goto nla_put_failure;
+
+	if (nla_put_le64(msg, NL802154_DEVKEY_ATTR_EXTENDED_ADDR,
+			 extended_addr) ||
+	    nla_put_u32(msg, NL802154_DEVKEY_ATTR_FRAME_COUNTER,
+			devkey->frame_counter))
+		goto nla_put_failure;
+
+	nl_key_id = nla_nest_start(msg, NL802154_DEVKEY_ATTR_ID);
+	if (!nl_key_id)
+		goto nla_put_failure;
+
+	if (ieee802154_llsec_send_key_id(msg, &devkey->key_id) < 0)
+		goto nla_put_failure;
+
+	nla_nest_end(msg, nl_key_id);
+	nla_nest_end(msg, nl_devkey);
+	genlmsg_end(msg, hdr);
+
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int
+nl802154_dump_llsec_devkey(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct cfg802154_registered_device *rdev = NULL;
+	struct ieee802154_llsec_device_key *kpos;
+	struct ieee802154_llsec_device *dpos;
+	struct ieee802154_llsec_table *table;
+	struct wpan_dev *wpan_dev;
+	int err;
+
+	err = nl802154_prepare_wpan_dev_dump(skb, cb, &rdev, &wpan_dev);
+	if (err)
+		return err;
+
+	if (!wpan_dev->netdev) {
+		err = -EINVAL;
+		goto out_err;
+	}
+
+	rdev_lock_llsec_table(rdev, wpan_dev);
+	rdev_get_llsec_table(rdev, wpan_dev, &table);
+
+	/* TODO make it like station dump */
+	if (cb->args[2])
+		goto out;
+
+	/* TODO look if remove devkey and do some nested attribute */
+	list_for_each_entry(dpos, &table->devices, list) {
+		list_for_each_entry(kpos, &dpos->keys, list) {
+			if (nl802154_send_devkey(skb,
+						 NL802154_CMD_NEW_SEC_LEVEL,
+						 NETLINK_CB(cb->skb).portid,
+						 cb->nlh->nlmsg_seq,
+						 NLM_F_MULTI, rdev,
+						 wpan_dev->netdev,
+						 dpos->hwaddr,
+						 kpos) < 0) {
+				/* TODO */
+				err = -EIO;
+				rdev_unlock_llsec_table(rdev, wpan_dev);
+				goto out_err;
+			}
+		}
+	}
+
+	cb->args[2] = 1;
+
+out:
+	rdev_unlock_llsec_table(rdev, wpan_dev);
+	err = skb->len;
+out_err:
+	nl802154_finish_wpan_dev_dump(rdev);
+
+	return err;
+}
+
+static const struct nla_policy nl802154_devkey_policy[NL802154_DEVKEY_ATTR_MAX + 1] = {
+	[NL802154_DEVKEY_ATTR_FRAME_COUNTER] = { NLA_U32 },
+	[NL802154_DEVKEY_ATTR_EXTENDED_ADDR] = { NLA_U64 },
+	[NL802154_DEVKEY_ATTR_ID] = { NLA_NESTED },
+};
+
+static int nl802154_add_llsec_devkey(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg802154_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wpan_dev *wpan_dev = dev->ieee802154_ptr;
+	struct nlattr *attrs[NL802154_DEVKEY_ATTR_MAX + 1];
+	struct ieee802154_llsec_device_key key;
+	__le64 extended_addr;
+
+	if (!info->attrs[NL802154_ATTR_SEC_DEVKEY] ||
+	    nla_parse_nested(attrs, NL802154_DEVKEY_ATTR_MAX,
+			     info->attrs[NL802154_ATTR_SEC_DEVKEY],
+			     nl802154_devkey_policy) < 0)
+		return -EINVAL;
+
+	if (!attrs[NL802154_DEVKEY_ATTR_FRAME_COUNTER] ||
+	    !attrs[NL802154_DEVKEY_ATTR_EXTENDED_ADDR])
+		return -EINVAL;
+
+	/* TODO change key.id ? */
+	if (ieee802154_llsec_parse_key_id(attrs[NL802154_DEVKEY_ATTR_ID],
+					  &key.key_id) < 0)
+		return -ENOBUFS;
+
+	/* TODO be32 */
+	key.frame_counter = nla_get_u32(attrs[NL802154_DEVKEY_ATTR_FRAME_COUNTER]);
+	/* TODO change naming hwaddr -> extended_addr
+	 * check unique identifier short+pan OR extended_addr
+	 */
+	extended_addr = nla_get_le64(attrs[NL802154_DEVKEY_ATTR_EXTENDED_ADDR]);
+	return rdev_add_devkey(rdev, wpan_dev, extended_addr, &key);
+}
+
+static int nl802154_del_llsec_devkey(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg802154_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wpan_dev *wpan_dev = dev->ieee802154_ptr;
+	struct nlattr *attrs[NL802154_DEVKEY_ATTR_MAX + 1];
+	struct ieee802154_llsec_device_key key;
+	__le64 extended_addr;
+
+	if (nla_parse_nested(attrs, NL802154_DEVKEY_ATTR_MAX,
+			     info->attrs[NL802154_ATTR_SEC_DEVKEY],
+			     nl802154_devkey_policy))
+		return -EINVAL;
+
+	if (!attrs[NL802154_DEVKEY_ATTR_EXTENDED_ADDR])
+		return -EINVAL;
+
+	/* TODO change key.id ? */
+	if (ieee802154_llsec_parse_key_id(attrs[NL802154_DEVKEY_ATTR_ID],
+					  &key.key_id) < 0)
+		return -ENOBUFS;
+
+	/* TODO change naming hwaddr -> extended_addr
+	 * check unique identifier short+pan OR extended_addr
+	 */
+	extended_addr = nla_get_le64(attrs[NL802154_DEVKEY_ATTR_EXTENDED_ADDR]);
+	return rdev_del_devkey(rdev, wpan_dev, extended_addr, &key);
+}
+
+static int nl802154_send_seclevel(struct sk_buff *msg, u32 cmd, u32 portid,
+				  u32 seq, int flags,
+				  struct cfg802154_registered_device *rdev,
+				  struct net_device *dev,
+				  const struct ieee802154_llsec_seclevel *sl)
+{
+	void *hdr;
+	struct nlattr *nl_seclevel;
+
+	hdr = nl802154hdr_put(msg, portid, seq, flags, cmd);
+	if (!hdr)
+		return -1;
+
+	if (nla_put_u32(msg, NL802154_ATTR_IFINDEX, dev->ifindex))
+		goto nla_put_failure;
+
+	nl_seclevel = nla_nest_start(msg, NL802154_ATTR_SEC_LEVEL);
+	if (!nl_seclevel)
+		goto nla_put_failure;
+
+	if (nla_put_u32(msg, NL802154_SECLEVEL_ATTR_FRAME, sl->frame_type) ||
+	    nla_put_u32(msg, NL802154_SECLEVEL_ATTR_LEVELS, sl->sec_levels) ||
+	    nla_put_u8(msg, NL802154_SECLEVEL_ATTR_DEV_OVERRIDE,
+		       sl->device_override))
+		goto nla_put_failure;
+
+	if (sl->frame_type == NL802154_FRAME_CMD) {
+		if (nla_put_u32(msg, NL802154_SECLEVEL_ATTR_CMD_FRAME,
+				sl->cmd_frame_id))
+			goto nla_put_failure;
+	}
+
+	nla_nest_end(msg, nl_seclevel);
+	genlmsg_end(msg, hdr);
+
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int
+nl802154_dump_llsec_seclevel(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct cfg802154_registered_device *rdev = NULL;
+	struct ieee802154_llsec_seclevel *sl;
+	struct ieee802154_llsec_table *table;
+	struct wpan_dev *wpan_dev;
+	int err;
+
+	err = nl802154_prepare_wpan_dev_dump(skb, cb, &rdev, &wpan_dev);
+	if (err)
+		return err;
+
+	if (!wpan_dev->netdev) {
+		err = -EINVAL;
+		goto out_err;
+	}
+
+	rdev_lock_llsec_table(rdev, wpan_dev);
+	rdev_get_llsec_table(rdev, wpan_dev, &table);
+
+	/* TODO make it like station dump */
+	if (cb->args[2])
+		goto out;
+
+	list_for_each_entry(sl, &table->security_levels, list) {
+		if (nl802154_send_seclevel(skb, NL802154_CMD_NEW_SEC_LEVEL,
+					   NETLINK_CB(cb->skb).portid,
+					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					   rdev, wpan_dev->netdev, sl) < 0) {
+			/* TODO */
+			err = -EIO;
+			rdev_unlock_llsec_table(rdev, wpan_dev);
+			goto out_err;
+		}
+	}
+
+	cb->args[2] = 1;
+
+out:
+	rdev_unlock_llsec_table(rdev, wpan_dev);
+	err = skb->len;
+out_err:
+	nl802154_finish_wpan_dev_dump(rdev);
+
+	return err;
+}
+
+static const struct nla_policy nl802154_seclevel_policy[NL802154_SECLEVEL_ATTR_MAX + 1] = {
+	[NL802154_SECLEVEL_ATTR_LEVELS] = { .type = NLA_U8 },
+	[NL802154_SECLEVEL_ATTR_FRAME] = { .type = NLA_U32 },
+	[NL802154_SECLEVEL_ATTR_CMD_FRAME] = { .type = NLA_U32 },
+	[NL802154_SECLEVEL_ATTR_DEV_OVERRIDE] = { .type = NLA_U8 },
+};
+
+static int
+llsec_parse_seclevel(struct nlattr *nla, struct ieee802154_llsec_seclevel *sl)
+{
+	struct nlattr *attrs[NL802154_SECLEVEL_ATTR_MAX + 1];
+
+	if (!nla || nla_parse_nested(attrs, NL802154_SECLEVEL_ATTR_MAX, nla,
+				     nl802154_seclevel_policy))
+		return -EINVAL;
+
+	memset(sl, 0, sizeof(*sl));
+
+	if (!attrs[NL802154_SECLEVEL_ATTR_LEVELS] ||
+	    !attrs[NL802154_SECLEVEL_ATTR_FRAME] ||
+	    !attrs[NL802154_SECLEVEL_ATTR_DEV_OVERRIDE])
+		return -EINVAL;
+
+	sl->sec_levels = nla_get_u8(attrs[NL802154_SECLEVEL_ATTR_LEVELS]);
+	sl->frame_type = nla_get_u32(attrs[NL802154_SECLEVEL_ATTR_FRAME]);
+	sl->device_override = nla_get_u8(attrs[NL802154_SECLEVEL_ATTR_DEV_OVERRIDE]);
+	if (sl->frame_type > NL802154_FRAME_MAX ||
+	    (sl->device_override != 0 && sl->device_override != 1))
+		return -EINVAL;
+
+	if (sl->frame_type == NL802154_FRAME_CMD) {
+		if (!attrs[NL802154_SECLEVEL_ATTR_CMD_FRAME])
+			return -EINVAL;
+
+		sl->cmd_frame_id = nla_get_u32(attrs[NL802154_SECLEVEL_ATTR_CMD_FRAME]);
+		if (sl->cmd_frame_id > NL802154_CMD_FRAME_MAX)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int nl802154_add_llsec_seclevel(struct sk_buff *skb,
+				       struct genl_info *info)
+{
+	struct cfg802154_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wpan_dev *wpan_dev = dev->ieee802154_ptr;
+	struct ieee802154_llsec_seclevel sl;
+
+	if (llsec_parse_seclevel(info->attrs[NL802154_ATTR_SEC_LEVEL],
+				 &sl) < 0)
+		return -EINVAL;
+
+	return rdev_add_seclevel(rdev, wpan_dev, &sl);
+}
+
+static int nl802154_del_llsec_seclevel(struct sk_buff *skb,
+				       struct genl_info *info)
+{
+	struct cfg802154_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
+	struct wpan_dev *wpan_dev = dev->ieee802154_ptr;
+	struct ieee802154_llsec_seclevel sl;
+
+	if (!info->attrs[NL802154_ATTR_SEC_LEVEL] ||
+	    llsec_parse_seclevel(info->attrs[NL802154_ATTR_SEC_LEVEL],
+				 &sl) < 0)
+		return -EINVAL;
+
+	return rdev_del_seclevel(rdev, wpan_dev, &sl);
+}
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
+#define NL802154_FLAG_NEED_WPAN_PHY	0x01
+#define NL802154_FLAG_NEED_NETDEV	0x02
+#define NL802154_FLAG_NEED_RTNL		0x04
+#define NL802154_FLAG_CHECK_NETDEV_UP	0x08
+#define NL802154_FLAG_NEED_NETDEV_UP	(NL802154_FLAG_NEED_NETDEV |\
+					 NL802154_FLAG_CHECK_NETDEV_UP)
+#define NL802154_FLAG_NEED_WPAN_DEV	0x10
+#define NL802154_FLAG_NEED_WPAN_DEV_UP	(NL802154_FLAG_NEED_WPAN_DEV |\
+					 NL802154_FLAG_CHECK_NETDEV_UP)
+
+static int nl802154_pre_doit(const struct genl_ops *ops, struct sk_buff *skb,
+			     struct genl_info *info)
+{
+	struct cfg802154_registered_device *rdev;
+	struct wpan_dev *wpan_dev;
+	struct net_device *dev;
+	bool rtnl = ops->internal_flags & NL802154_FLAG_NEED_RTNL;
+
+	if (rtnl)
+		rtnl_lock();
+
+	if (ops->internal_flags & NL802154_FLAG_NEED_WPAN_PHY) {
+		rdev = cfg802154_get_dev_from_info(genl_info_net(info), info);
+		if (IS_ERR(rdev)) {
+			if (rtnl)
+				rtnl_unlock();
+			return PTR_ERR(rdev);
+		}
+		info->user_ptr[0] = rdev;
+	} else if (ops->internal_flags & NL802154_FLAG_NEED_NETDEV ||
+		   ops->internal_flags & NL802154_FLAG_NEED_WPAN_DEV) {
+		ASSERT_RTNL();
+		wpan_dev = __cfg802154_wpan_dev_from_attrs(genl_info_net(info),
+							   info->attrs);
+		if (IS_ERR(wpan_dev)) {
+			if (rtnl)
+				rtnl_unlock();
+			return PTR_ERR(wpan_dev);
+		}
+
+		dev = wpan_dev->netdev;
+		rdev = wpan_phy_to_rdev(wpan_dev->wpan_phy);
+
+		if (ops->internal_flags & NL802154_FLAG_NEED_NETDEV) {
+			if (!dev) {
+				if (rtnl)
+					rtnl_unlock();
+				return -EINVAL;
+			}
+
+			info->user_ptr[1] = dev;
+		} else {
+			info->user_ptr[1] = wpan_dev;
+		}
+
+		if (dev) {
+			if (ops->internal_flags & NL802154_FLAG_CHECK_NETDEV_UP &&
+			    !netif_running(dev)) {
+				if (rtnl)
+					rtnl_unlock();
+				return -ENETDOWN;
+			}
+
+			dev_hold(dev);
+		}
+
+		info->user_ptr[0] = rdev;
+	}
+
+	return 0;
+}
+
+static void nl802154_post_doit(const struct genl_ops *ops, struct sk_buff *skb,
+			       struct genl_info *info)
+{
+	if (info->user_ptr[1]) {
+		if (ops->internal_flags & NL802154_FLAG_NEED_WPAN_DEV) {
+			struct wpan_dev *wpan_dev = info->user_ptr[1];
+
+			if (wpan_dev->netdev)
+				dev_put(wpan_dev->netdev);
+		} else {
+			dev_put(info->user_ptr[1]);
+		}
+	}
+
+	if (ops->internal_flags & NL802154_FLAG_NEED_RTNL)
+		rtnl_unlock();
+}
+
+static const struct genl_ops nl802154_ops[] = {
+	{
+		.cmd = NL802154_CMD_GET_WPAN_PHY,
+		.doit = nl802154_get_wpan_phy,
+		.dumpit = nl802154_dump_wpan_phy,
+		.done = nl802154_dump_wpan_phy_done,
+		.policy = nl802154_policy,
+		/* can be retrieved by unprivileged users */
+		.internal_flags = NL802154_FLAG_NEED_WPAN_PHY |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_GET_INTERFACE,
+		.doit = nl802154_get_interface,
+		.dumpit = nl802154_dump_interface,
+		.policy = nl802154_policy,
+		/* can be retrieved by unprivileged users */
+		.internal_flags = NL802154_FLAG_NEED_WPAN_DEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_NEW_INTERFACE,
+		.doit = nl802154_new_interface,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_WPAN_PHY |
 				  NL802154_FLAG_NEED_RTNL,
 	},
 	{
@@ -1287,6 +2302,119 @@ static const struct genl_ops nl802154_ops[] = {
 		.internal_flags = NL802154_FLAG_NEED_NETDEV |
 				  NL802154_FLAG_NEED_RTNL,
 	},
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+	{
+		.cmd = NL802154_CMD_SET_SEC_PARAMS,
+		.doit = nl802154_set_llsec_params,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_GET_SEC_KEY,
+		/* TODO .doit by matching key id? */
+		.dumpit = nl802154_dump_llsec_key,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_NEW_SEC_KEY,
+		.doit = nl802154_add_llsec_key,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_DEL_SEC_KEY,
+		.doit = nl802154_del_llsec_key,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	/* TODO unique identifier must short+pan OR extended_addr */
+	{
+		.cmd = NL802154_CMD_GET_SEC_DEV,
+		/* TODO .doit by matching extended_addr? */
+		.dumpit = nl802154_dump_llsec_dev,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_NEW_SEC_DEV,
+		.doit = nl802154_add_llsec_dev,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_DEL_SEC_DEV,
+		.doit = nl802154_del_llsec_dev,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	/* TODO remove complete devkey, put it as nested? */
+	{
+		.cmd = NL802154_CMD_GET_SEC_DEVKEY,
+		/* TODO doit by matching ??? */
+		.dumpit = nl802154_dump_llsec_devkey,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_NEW_SEC_DEVKEY,
+		.doit = nl802154_add_llsec_devkey,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_DEL_SEC_DEVKEY,
+		.doit = nl802154_del_llsec_devkey,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_GET_SEC_LEVEL,
+		/* TODO .doit by matching frame_type? */
+		.dumpit = nl802154_dump_llsec_seclevel,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_NEW_SEC_LEVEL,
+		.doit = nl802154_add_llsec_seclevel,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+	{
+		.cmd = NL802154_CMD_DEL_SEC_LEVEL,
+		/* TODO match frame_type only? */
+		.doit = nl802154_del_llsec_seclevel,
+		.policy = nl802154_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL802154_FLAG_NEED_NETDEV |
+				  NL802154_FLAG_NEED_RTNL,
+	},
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
 };
 
 /* initialisation/exit functions */
diff --git a/net/ieee802154/rdev-ops.h b/net/ieee802154/rdev-ops.h
index 03b3575..4441c63 100644
--- a/net/ieee802154/rdev-ops.h
+++ b/net/ieee802154/rdev-ops.h
@@ -208,4 +208,113 @@ rdev_set_ackreq_default(struct cfg802154_registered_device *rdev,
 	return ret;
 }
 
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+/* TODO this is already a nl802154, so move into ieee802154 */
+static inline void
+rdev_get_llsec_table(struct cfg802154_registered_device *rdev,
+		     struct wpan_dev *wpan_dev,
+		     struct ieee802154_llsec_table **table)
+{
+	rdev->ops->get_llsec_table(&rdev->wpan_phy, wpan_dev, table);
+}
+
+static inline void
+rdev_lock_llsec_table(struct cfg802154_registered_device *rdev,
+		      struct wpan_dev *wpan_dev)
+{
+	rdev->ops->lock_llsec_table(&rdev->wpan_phy, wpan_dev);
+}
+
+static inline void
+rdev_unlock_llsec_table(struct cfg802154_registered_device *rdev,
+			struct wpan_dev *wpan_dev)
+{
+	rdev->ops->unlock_llsec_table(&rdev->wpan_phy, wpan_dev);
+}
+
+static inline int
+rdev_get_llsec_params(struct cfg802154_registered_device *rdev,
+		      struct wpan_dev *wpan_dev,
+		      struct ieee802154_llsec_params *params)
+{
+	return rdev->ops->get_llsec_params(&rdev->wpan_phy, wpan_dev, params);
+}
+
+static inline int
+rdev_set_llsec_params(struct cfg802154_registered_device *rdev,
+		      struct wpan_dev *wpan_dev,
+		      const struct ieee802154_llsec_params *params,
+		      u32 changed)
+{
+	return rdev->ops->set_llsec_params(&rdev->wpan_phy, wpan_dev, params,
+					   changed);
+}
+
+static inline int
+rdev_add_llsec_key(struct cfg802154_registered_device *rdev,
+		   struct wpan_dev *wpan_dev,
+		   const struct ieee802154_llsec_key_id *id,
+		   const struct ieee802154_llsec_key *key)
+{
+	return rdev->ops->add_llsec_key(&rdev->wpan_phy, wpan_dev, id, key);
+}
+
+static inline int
+rdev_del_llsec_key(struct cfg802154_registered_device *rdev,
+		   struct wpan_dev *wpan_dev,
+		   const struct ieee802154_llsec_key_id *id)
+{
+	return rdev->ops->del_llsec_key(&rdev->wpan_phy, wpan_dev, id);
+}
+
+static inline int
+rdev_add_seclevel(struct cfg802154_registered_device *rdev,
+		  struct wpan_dev *wpan_dev,
+		  const struct ieee802154_llsec_seclevel *sl)
+{
+	return rdev->ops->add_seclevel(&rdev->wpan_phy, wpan_dev, sl);
+}
+
+static inline int
+rdev_del_seclevel(struct cfg802154_registered_device *rdev,
+		  struct wpan_dev *wpan_dev,
+		  const struct ieee802154_llsec_seclevel *sl)
+{
+	return rdev->ops->del_seclevel(&rdev->wpan_phy, wpan_dev, sl);
+}
+
+static inline int
+rdev_add_device(struct cfg802154_registered_device *rdev,
+		struct wpan_dev *wpan_dev,
+		const struct ieee802154_llsec_device *dev_desc)
+{
+	return rdev->ops->add_device(&rdev->wpan_phy, wpan_dev, dev_desc);
+}
+
+static inline int
+rdev_del_device(struct cfg802154_registered_device *rdev,
+		struct wpan_dev *wpan_dev, __le64 extended_addr)
+{
+	return rdev->ops->del_device(&rdev->wpan_phy, wpan_dev, extended_addr);
+}
+
+static inline int
+rdev_add_devkey(struct cfg802154_registered_device *rdev,
+		struct wpan_dev *wpan_dev, __le64 extended_addr,
+		const struct ieee802154_llsec_device_key *devkey)
+{
+	return rdev->ops->add_devkey(&rdev->wpan_phy, wpan_dev, extended_addr,
+				     devkey);
+}
+
+static inline int
+rdev_del_devkey(struct cfg802154_registered_device *rdev,
+		struct wpan_dev *wpan_dev, __le64 extended_addr,
+		const struct ieee802154_llsec_device_key *devkey)
+{
+	return rdev->ops->del_devkey(&rdev->wpan_phy, wpan_dev, extended_addr,
+				     devkey);
+}
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
 #endif /* __CFG802154_RDEV_OPS */
diff --git a/net/mac802154/cfg.c b/net/mac802154/cfg.c
index c865ebb..57b5e94 100644
--- a/net/mac802154/cfg.c
+++ b/net/mac802154/cfg.c
@@ -266,6 +266,195 @@ ieee802154_set_ackreq_default(struct wpan_phy *wpan_phy,
 	return 0;
 }
 
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+static void
+ieee802154_get_llsec_table(struct wpan_phy *wpan_phy,
+			   struct wpan_dev *wpan_dev,
+			   struct ieee802154_llsec_table **table)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+
+	*table = &sdata->sec.table;
+}
+
+static void
+ieee802154_lock_llsec_table(struct wpan_phy *wpan_phy,
+			    struct wpan_dev *wpan_dev)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+
+	mutex_lock(&sdata->sec_mtx);
+}
+
+static void
+ieee802154_unlock_llsec_table(struct wpan_phy *wpan_phy,
+			      struct wpan_dev *wpan_dev)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+
+	mutex_unlock(&sdata->sec_mtx);
+}
+
+static int
+ieee802154_set_llsec_params(struct wpan_phy *wpan_phy,
+			    struct wpan_dev *wpan_dev,
+			    const struct ieee802154_llsec_params *params,
+			    int changed)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_set_params(&sdata->sec, params, changed);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+
+static int
+ieee802154_get_llsec_params(struct wpan_phy *wpan_phy,
+			    struct wpan_dev *wpan_dev,
+			    struct ieee802154_llsec_params *params)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_get_params(&sdata->sec, params);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+
+static int
+ieee802154_add_llsec_key(struct wpan_phy *wpan_phy, struct wpan_dev *wpan_dev,
+			 const struct ieee802154_llsec_key_id *id,
+			 const struct ieee802154_llsec_key *key)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_key_add(&sdata->sec, id, key);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+
+static int
+ieee802154_del_llsec_key(struct wpan_phy *wpan_phy, struct wpan_dev *wpan_dev,
+			 const struct ieee802154_llsec_key_id *id)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_key_del(&sdata->sec, id);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+
+static int
+ieee802154_add_seclevel(struct wpan_phy *wpan_phy, struct wpan_dev *wpan_dev,
+			const struct ieee802154_llsec_seclevel *sl)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_seclevel_add(&sdata->sec, sl);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+
+static int
+ieee802154_del_seclevel(struct wpan_phy *wpan_phy, struct wpan_dev *wpan_dev,
+			const struct ieee802154_llsec_seclevel *sl)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_seclevel_del(&sdata->sec, sl);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+
+static int
+ieee802154_add_device(struct wpan_phy *wpan_phy, struct wpan_dev *wpan_dev,
+		      const struct ieee802154_llsec_device *dev_desc)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_dev_add(&sdata->sec, dev_desc);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+
+static int
+ieee802154_del_device(struct wpan_phy *wpan_phy, struct wpan_dev *wpan_dev,
+		      __le64 extended_addr)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_dev_del(&sdata->sec, extended_addr);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+
+static int
+ieee802154_add_devkey(struct wpan_phy *wpan_phy, struct wpan_dev *wpan_dev,
+		      __le64 extended_addr,
+		      const struct ieee802154_llsec_device_key *key)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_devkey_add(&sdata->sec, extended_addr, key);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+
+static int
+ieee802154_del_devkey(struct wpan_phy *wpan_phy, struct wpan_dev *wpan_dev,
+		      __le64 extended_addr,
+		      const struct ieee802154_llsec_device_key *key)
+{
+	struct net_device *dev = wpan_dev->netdev;
+	struct ieee802154_sub_if_data *sdata = IEEE802154_DEV_TO_SUB_IF(dev);
+	int res;
+
+	mutex_lock(&sdata->sec_mtx);
+	res = mac802154_llsec_devkey_del(&sdata->sec, extended_addr, key);
+	mutex_unlock(&sdata->sec_mtx);
+
+	return res;
+}
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
+
 const struct cfg802154_ops mac802154_config_ops = {
 	.add_virtual_intf_deprecated = ieee802154_add_iface_deprecated,
 	.del_virtual_intf_deprecated = ieee802154_del_iface_deprecated,
@@ -284,4 +473,20 @@ const struct cfg802154_ops mac802154_config_ops = {
 	.set_max_frame_retries = ieee802154_set_max_frame_retries,
 	.set_lbt_mode = ieee802154_set_lbt_mode,
 	.set_ackreq_default = ieee802154_set_ackreq_default,
+#ifdef CONFIG_IEEE802154_NL802154_EXPERIMENTAL
+	.get_llsec_table = ieee802154_get_llsec_table,
+	.lock_llsec_table = ieee802154_lock_llsec_table,
+	.unlock_llsec_table = ieee802154_unlock_llsec_table,
+	/* TODO above */
+	.set_llsec_params = ieee802154_set_llsec_params,
+	.get_llsec_params = ieee802154_get_llsec_params,
+	.add_llsec_key = ieee802154_add_llsec_key,
+	.del_llsec_key = ieee802154_del_llsec_key,
+	.add_seclevel = ieee802154_add_seclevel,
+	.del_seclevel = ieee802154_del_seclevel,
+	.add_device = ieee802154_add_device,
+	.del_device = ieee802154_del_device,
+	.add_devkey = ieee802154_add_devkey,
+	.del_devkey = ieee802154_del_devkey,
+#endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
 };
-- 
2.5.3
