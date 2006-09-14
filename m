From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 3/3] cfg80211 thoughts on configuration
Date: Thu, 14 Sep 2006 12:53:02 +0200
Message-ID: <1158231183.2936.55.camel@ux156>
References: <1158230812.2936.46.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:24042 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751153AbWINKw0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 06:52:26 -0400
To: netdev@vger.kernel.org
In-Reply-To: <1158230812.2936.46.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is some preliminary code how I'm currently thinking (and that might
change radically :) ) configuration might look like.

It uses the patch I previously posted to make genetlink attributes
custom-definable.

--- wireless-dev.orig/include/linux/nl80211.h	2006-09-13 22:06:10.539647141 +0200
+++ wireless-dev/include/linux/nl80211.h	2006-09-13 22:06:11.919647141 +0200
@@ -45,6 +45,47 @@ enum {
 	/* get list of all interfaces belonging to a wiphy */
 	NL80211_CMD_NEW_INTERFACES,
 
+	/* configure device */
+	NL80211_CMD_CONFIGURE,
+
+	/* request configuration */
+	NL80211_CMD_GET_CONFIG,
+
+	/* configuration sent from kernel */
+	NL80211_CMD_CONFIGURATION,
+
+	/* initiate scan */
+	NL80211_CMD_INITIATE_SCAN,
+
+	/* scan result (kernel -> userspace) */
+	NL80211_CMD_SCAN_RESULT,
+
+	/* change roaming control */
+	NL80211_CMD_SET_ROAMING_CONTROL,
+
+	/* get roaming control setting */
+	NL80211_CMD_GET_ROAMING_CONTROL,
+
+	/* set access point BSSID for userspace roaming */
+	NL80211_CMD_SET_BSSID,
+
+	/* get current association information, if not associated then
+	 * the BSSID attribute is not present in response */
+	NL80211_CMD_GET_ASSOCIATION,
+
+	/* association notification/response to GET_BSSID */
+	NL80211_CMD_ASSOCIATION_CHANGED,
+
+	/* disassociate from current AP */
+	NL80211_CMD_DISASSOCIATE,
+
+	/* deauth from current AP */
+	NL80211_CMD_DEAUTH,
+
+	/* re-associate with current settings
+	 * (SSID and BSSID if roaming control in userspace) */
+	NL80211_CMD_REASSOCIATE,
+
 	/* add commands here */
 
 	/* used to define NL80211_CMD_MAX below */
@@ -88,6 +129,36 @@ enum {
 	/* wiphy list */
 	NL80211_ATTR_WIPHY_LIST,
 
+	/* attributes used for configuration */
+	/* network ID (pre 802.11 HW) */
+	NL80211_ATTR_NETWORK_ID,
+
+	/* channel, 1-14 are B/G */
+	NL80211_ATTR_CHANNEL,
+
+	/* receiver sensitivity in dBm */
+	NL80211_ATTR_RX_SENSITIVITY,
+
+	/* BSSID to associate to, only used when roaming control
+	 * is in userspace */
+	NL80211_ATTR_BSSID,
+
+	/* SSID of ESS to associate to */
+	NL80211_ATTR_SSID,
+
+	/* transmit power in mW */
+	NL80211_ATTR_TRANSMIT_POWER,
+
+	/* fragmentation threshold in bytes */
+	NL80211_ATTR_FRAG_THRESHOLD,
+
+	/* one or more information elements */
+	NL80211_ATTR_INFORMATION_ELEMENT,
+
+	NL80211_ATTR_ROAMING_CONTROL,
+
+	NL80211_ATTR_SCAN_TYPE,
+
 	/* add attributes here */
 
 	/* used to define NL80211_ATTR_MAX below */
@@ -134,4 +205,13 @@ enum {
 };
 #define NL80211_IFTYPE_MAX (__NL80211_IFTYPE_AFTER_LAST - 1)
 
+enum {
+	NL80211_ROAMING_CONTROL_KERNEL,
+	NL80211_ROAMING_CONTROL_USERSPACE,
+
+	/* keep last */
+	__NL80211_ROAMING_CONTROL_AFTER_LAST
+};
+#define NL80211_ROAMING_CONTROL_MAX (__NL80211_ROAMING_CONTROL_AFTER_LAST-1)
+
 #endif /* __LINUX_NL80211_H */
--- wireless-dev.orig/include/net/cfg80211.h	2006-09-13 22:06:10.539647141 +0200
+++ wireless-dev/include/net/cfg80211.h	2006-09-13 22:06:11.919647141 +0200
@@ -14,6 +14,30 @@
  */
 
 /**
+ * struct cfg80211_config - description of a configuration (request)
+ */
+struct cfg80211_config {
+	/* first fields with 'internal' validity */
+
+	/* SSID to use, valid if not NULL. change forces reassociation */
+	u8 *ssid;
+
+	/* now fields with explicit validity */
+#define CFG80211_CFG_VALID_NWID			(1<<0)
+#define CFG80211_CFG_VALID_RX_SENSITIVITY	(1<<1)
+#define CFG80211_CFG_VALID_TRANSMIT_POWER	(1<<2)
+#define CFG80211_CFG_VALID_FRAG_THRESHOLD	(1<<3)
+#define CFG80211_CFG_VALID_CHANNEL		(1<<4)
+	unsigned int valid;
+
+	u16 network_id;
+	s32 rx_sensitivity;
+	u32 transmit_power;
+	u32 fragmentation_threshold;
+	u32 channel;
+};
+
+/**
  * struct cfg80211_ops - backend description for wireless configuration
  *
  * This struct is registered by fullmac card drivers and/or wireless stacks
@@ -35,6 +59,26 @@
  * @add_virtual_intf: create a new virtual interface with the given name
  *
  * @del_virtual_intf: remove the virtual interface determined by ifindex.
+ *
+ * @configure: configure the given interface as requested in the config struct.
+ *	       must not ignore any configuration item, if something is
+ *	       is requested that cannot be fulfilled return an error
+ *
+ * @get_config: fill the given config structure with the current configuration
+ *
+ * @reassociate: reassociate with current settings (SSID, BSSID if
+ *		 userspace roaming is enabled)
+ *
+ * @disassociate: disassociate from current AP
+ *
+ * @deauth: deauth from current AP
+ *
+ * @initiate_scan: ...
+ *
+ * @set_roaming: set who gets to control roaming
+ *
+ * @set_bssid: only valid with userspace roaming control, sets
+ *	       BSSID to use, forces reassociation if changing
  */
 struct cfg80211_ops {
 	int	(*list_interfaces)(void *priv, void *data,
@@ -46,14 +90,24 @@ struct cfg80211_ops {
 				    unsigned int type);
 	int	(*del_virtual_intf)(void *priv, int ifindex);
 
-	/* more things to be added...
-	 *
-	 * for a (*configure)(...) call I'd probably guess that the
-	 * best bet would be to have one call that returns all
-	 * possible options, one that sets them based on the
-	 * struct genl_info *info, and one for that optimised
-	 * set-at-once thing.
-	 */
+	int	(*configure)(void *priv, struct net_device *dev,
+			     struct cfg80211_config *cfg);
+
+	void	(*get_config)(void *priv, struct net_device *dev,
+			      struct cfg80211_config *cfg);
+	int	(*reassociate)(void *priv, struct net_device *dev);
+	int	(*disassociate)(void *priv, struct net_device *dev);
+	int	(*deauth)(void *priv, struct net_device *dev);
+
+	/*
+	int	(*initiate_scan)(void *priv, struct net_device *dev, TBD);
+	TBD: which channels to scan, passive/active, background, ...?
+	*/
+
+	int	(*set_roaming)(void *priv, struct net_device *dev,
+			       int roaming_control);
+
+	int	(*set_bssid)(void *priv, struct net_device *dev, u8 *bssid);
 };
 
 /*
--- wireless-dev.orig/net/wireless/nl80211.c	2006-09-13 22:06:10.529647141 +0200
+++ wireless-dev/net/wireless/nl80211.c	2006-09-13 22:06:11.919647141 +0200
@@ -24,6 +24,22 @@ static struct genl_family nl80211_fam = 
 };
 
 /* policy for the attributes */
+
+static int check_information_element(struct nlattr *nla)
+{
+	int len = nla_len(nla);
+	u8 *data = nla_data(nla);
+	int elementlen;
+
+	while (len >= 2) {
+		/* 1 byte ID, 1 byte len, `len' bytes data */
+		elementlen = *(data+1) + 2;
+		data += elementlen;
+		len -= elementlen;
+	}
+	return len ? -EINVAL : 0;
+}
+
 static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
 	[NL80211_ATTR_IFINDEX] = { .type = NLA_U32 },
 	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
@@ -33,6 +49,17 @@ static struct nla_policy nl80211_policy[
 				 .len = NL80211_MAX_FRAME_LEN },
 	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ-1 },
 	[NL80211_ATTR_IFTYPE] = { .type = NLA_U32 },
+	[NL80211_ATTR_NETWORK_ID] = { .type = NLA_U16 },
+	[NL80211_ATTR_CHANNEL] = { .type = NLA_U32 },
+	[NL80211_ATTR_RX_SENSITIVITY] = { .type = NLA_U32 },
+	[NL80211_ATTR_BSSID] = { .len = 6 },
+	[NL80211_ATTR_SSID] = { .type = NLA_STRING, .len = 32 },
+	[NL80211_ATTR_TRANSMIT_POWER] = { .type = NLA_U32 },
+	[NL80211_ATTR_FRAG_THRESHOLD] = { .type = NLA_U32 },
+	[NL80211_ATTR_INFORMATION_ELEMENT] = { .type = NLA_CUSTOM_CHECK,
+					       .check = check_information_element },
+	[NL80211_ATTR_ROAMING_CONTROL] = { .type = NLA_U32 },
+	[NL80211_ATTR_SCAN_TYPE] = { .type = NLA_U32 },
 };
 
 /* netlink command implementations */
@@ -303,6 +330,77 @@ static int nl80211_del_virt_intf(struct 
 	return err;
 }
 
+static int nl80211_configure(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_driver *drv;
+	int ifindex, err;
+	struct net_device *dev;
+	struct cfg80211_config config;
+	struct nlattr *attr;
+
+        if (!info->attrs[NL80211_ATTR_IFINDEX])
+		return -EINVAL;
+
+	ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
+	dev = dev_get_by_index(ifindex);
+	if (!dev)
+		return -ENODEV;
+
+	drv = cfg80211_get_drv_from_info(info);
+	if (IS_ERR(drv)) {
+		err = PTR_ERR(drv);
+		goto out_nodrv;
+	}
+
+	if (!drv->ops->configure) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	memset(&config, 0, sizeof(config));
+
+	attr = info->attrs[NL80211_ATTR_SSID];
+	if (attr)
+		config.ssid = nla_data(attr);
+
+	attr = info->attrs[NL80211_ATTR_NETWORK_ID];
+	if (attr) {
+		config.valid |= CFG80211_CFG_VALID_NWID;
+		config.network_id = nla_get_u16(attr);
+	}
+
+	attr = info->attrs[NL80211_ATTR_RX_SENSITIVITY];
+	if (attr) {
+		config.valid |= CFG80211_CFG_VALID_RX_SENSITIVITY;
+		config.rx_sensitivity = (s32) nla_get_u32(attr);
+	}
+
+	attr = info->attrs[NL80211_ATTR_TRANSMIT_POWER];
+	if (attr) {
+		config.valid |= CFG80211_CFG_VALID_TRANSMIT_POWER;
+		config.transmit_power = nla_get_u32(attr);
+	}
+
+	attr = info->attrs[NL80211_ATTR_FRAG_THRESHOLD];
+	if (attr) {
+		config.valid |= CFG80211_CFG_VALID_FRAG_THRESHOLD;
+		config.fragmentation_threshold = nla_get_u32(attr);
+	}
+
+	attr = info->attrs[NL80211_ATTR_CHANNEL];
+	if (attr) {
+		config.valid |= CFG80211_CFG_VALID_CHANNEL;
+		config.channel = nla_get_u32(attr);
+	}
+
+	err = drv->ops->configure(drv->priv, dev, &config);
+ out:
+	cfg80211_put_drv(drv);
+ out_nodrv:
+	dev_put(dev);
+	return err;
+}
+
 static struct genl_ops nl80211_ops[] = {
 	{
 		.cmd = NL80211_CMD_GET_CMDLIST,
@@ -337,6 +435,12 @@ static struct genl_ops nl80211_ops[] = {
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
 	},
+	{
+		.cmd = NL80211_CMD_CONFIGURE,
+		.doit = nl80211_configure,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
 };
 
 
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/wext-compat.c	2006-09-13 22:06:11.929647141 +0200
@@ -0,0 +1,25 @@
+/* NOT YET */
+
+To implement compatibility, we add a new field to struct net_device
+that contains the pending configuration structure. This is dynamically
+allocated when needed and freed when committed.
+In a way it replaces the wireless_handlers field in there which is now
+done by dynamic lookup. No worries. No one is going to have thousands
+of wireless devices, and if that changes we can still trivially change
+this assumption :)
+
+Commit is done some time after the last parameter was changed
+(with each parameter change simply (re-)schedule a timer) or
+if explicitly asked for. This is probably not what most people
+would expect, but perfectly fine in the WE API.
+
+compatibility mappings:
+
+SIOCSIWAP
+  -> if bssid is all-ones: set roaming to kernel, reassociate
+  -> if bssid is all-zeroes: set roaming to kernel
+  -> otherwise: set roaming to userspace, set bssid
+
+SIOCGIWAP
+  -> get association parameters and fill return bssid appropriately
+

