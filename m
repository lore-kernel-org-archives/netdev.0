From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 2/2] mac802154: make csma/cca
	parameters per-wpan
Date: Mon, 31 Mar 2014 15:17:53 +0200
Message-ID: <1396271873-10300-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1396271873-10300-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1396271873-10300-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 9b2777d6089bcd (ieee802154: add TX power control to wpan_phy)
and following erroneously added CSMA and CCA parameters for 8021.5.4
devices as PHY parameters, while they are actually MAC parameters and
can differ for any two WPAN instances. Since it is now sensible to have
multiple WPAN devices with differing CSMA/CCA parameters, make these
parameters MAC parameters instead.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 include/linux/nl802154.h        |    2 +-
 include/net/ieee802154_netdev.h |   17 ++++
 net/ieee802154/ieee802154.h     |    2 +-
 net/ieee802154/netlink.c        |    2 +-
 net/ieee802154/nl-mac.c         |  122 +++++++++++++++++++++++-
 net/ieee802154/nl-phy.c         |  200 +--------------------------------------
 net/ieee802154/wpan-class.c     |    6 --
 net/mac802154/mac802154.h       |    9 ++
 net/mac802154/mac_cmd.c         |    3 +
 net/mac802154/wpan.c            |   89 ++++++++++++++++-
 10 files changed, 240 insertions(+), 212 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index e110b8c..c8d7f39 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -132,7 +132,7 @@ enum {
 	IEEE802154_ADD_IFACE,
 	IEEE802154_DEL_IFACE,
 
-	IEEE802154_SET_PHYPARAMS,
+	IEEE802154_SET_MACPARAMS,
 
 	__IEEE802154_CMD_MAX,
 };
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index e1717cb..5a719ca 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -229,6 +229,18 @@ static inline int mac_cb_type(struct sk_buff *skb)
 #define IEEE802154_MAC_SCAN_PASSIVE	2
 #define IEEE802154_MAC_SCAN_ORPHAN	3
 
+struct ieee802154_mac_params {
+	s8 transmit_power;
+	u8 min_be;
+	u8 max_be;
+	u8 csma_retries;
+	s8 frame_retries;
+
+	bool lbt;
+	u8 cca_mode;
+	s32 cca_ed_level;
+};
+
 struct wpan_phy;
 /*
  * This should be located at net_device->ml_priv
@@ -255,6 +267,11 @@ struct ieee802154_mlme_ops {
 	int (*scan_req)(struct net_device *dev,
 			u8 type, u32 channels, u8 page, u8 duration);
 
+	int (*set_mac_params)(struct net_device *dev,
+			      const struct ieee802154_mac_params *params);
+	void (*get_mac_params)(struct net_device *dev,
+			       struct ieee802154_mac_params *params);
+
 	/* The fields below are required. */
 
 	struct wpan_phy *(*get_phy)(const struct net_device *dev);
diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index 6cbc896..6693a5c 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -53,7 +53,6 @@ int ieee802154_list_phy(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_dump_phy(struct sk_buff *skb, struct netlink_callback *cb);
 int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_del_iface(struct sk_buff *skb, struct genl_info *info);
-int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info);
 
 enum ieee802154_mcgrp_ids {
 	IEEE802154_COORD_MCGRP,
@@ -67,5 +66,6 @@ int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_list_iface(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_dump_iface(struct sk_buff *skb, struct netlink_callback *cb);
+int ieee802154_set_macparams(struct sk_buff *skb, struct genl_info *info);
 
 #endif
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 67c151b..04b2058 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -115,7 +115,6 @@ static const struct genl_ops ieee8021154_ops[] = {
 			ieee802154_dump_phy),
 	IEEE802154_OP(IEEE802154_ADD_IFACE, ieee802154_add_iface),
 	IEEE802154_OP(IEEE802154_DEL_IFACE, ieee802154_del_iface),
-	IEEE802154_OP(IEEE802154_SET_PHYPARAMS, ieee802154_set_phyparams),
 	/* see nl-mac.c */
 	IEEE802154_OP(IEEE802154_ASSOCIATE_REQ, ieee802154_associate_req),
 	IEEE802154_OP(IEEE802154_ASSOCIATE_RESP, ieee802154_associate_resp),
@@ -124,6 +123,7 @@ static const struct genl_ops ieee8021154_ops[] = {
 	IEEE802154_OP(IEEE802154_START_REQ, ieee802154_start_req),
 	IEEE802154_DUMP(IEEE802154_LIST_IFACE, ieee802154_list_iface,
 			ieee802154_dump_iface),
+	IEEE802154_OP(IEEE802154_SET_MACPARAMS, ieee802154_set_macparams),
 };
 
 static const struct genl_multicast_group ieee802154_mcgrps[] = {
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index bda8dba..cbe6b1a 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -264,6 +264,7 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 {
 	void *hdr;
 	struct wpan_phy *phy;
+	struct ieee802154_mlme_ops *ops;
 	__le16 short_addr, pan_id;
 
 	pr_debug("%s\n", __func__);
@@ -273,11 +274,12 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 	if (!hdr)
 		goto out;
 
-	phy = ieee802154_mlme_ops(dev)->get_phy(dev);
+	ops = ieee802154_mlme_ops(dev);
+	phy = ops->get_phy(dev);
 	BUG_ON(!phy);
 
-	short_addr = ieee802154_mlme_ops(dev)->get_short_addr(dev);
-	pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
+	short_addr = ops->get_short_addr(dev);
+	pan_id = ops->get_pan_id(dev);
 
 	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
 	    nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
@@ -287,6 +289,30 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 	    nla_put_shortaddr(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr) ||
 	    nla_put_shortaddr(msg, IEEE802154_ATTR_PAN_ID, pan_id))
 		goto nla_put_failure;
+
+	if (ops->get_mac_params) {
+		struct ieee802154_mac_params params;
+
+		ops->get_mac_params(dev, &params);
+
+		if (nla_put_s8(msg, IEEE802154_ATTR_TXPOWER,
+			       params.transmit_power) ||
+		    nla_put_u8(msg, IEEE802154_ATTR_LBT_ENABLED, params.lbt) ||
+		    nla_put_u8(msg, IEEE802154_ATTR_CCA_MODE,
+			       params.cca_mode) ||
+		    nla_put_s32(msg, IEEE802154_ATTR_CCA_ED_LEVEL,
+				params.cca_ed_level) ||
+		    nla_put_u8(msg, IEEE802154_ATTR_CSMA_RETRIES,
+			       params.csma_retries) ||
+		    nla_put_u8(msg, IEEE802154_ATTR_CSMA_MIN_BE,
+			       params.min_be) ||
+		    nla_put_u8(msg, IEEE802154_ATTR_CSMA_MAX_BE,
+			       params.max_be) ||
+		    nla_put_s8(msg, IEEE802154_ATTR_FRAME_RETRIES,
+			       params.frame_retries))
+			goto nla_put_failure;
+	}
+
 	wpan_phy_put(phy);
 	return genlmsg_end(msg, hdr);
 
@@ -599,3 +625,93 @@ cont:
 
 	return skb->len;
 }
+
+int ieee802154_set_macparams(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev = NULL;
+	struct ieee802154_mlme_ops *ops;
+	struct ieee802154_mac_params params;
+	struct wpan_phy *phy;
+	int rc = -EINVAL;
+
+	pr_debug("%s\n", __func__);
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	ops = ieee802154_mlme_ops(dev);
+
+	if (!ops->get_mac_params || !ops->set_mac_params) {
+		rc = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (netif_running(dev)) {
+		rc = -EBUSY;
+		goto out;
+	}
+
+	if (!info->attrs[IEEE802154_ATTR_LBT_ENABLED] &&
+	    !info->attrs[IEEE802154_ATTR_CCA_MODE] &&
+	    !info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL] &&
+	    !info->attrs[IEEE802154_ATTR_CSMA_RETRIES] &&
+	    !info->attrs[IEEE802154_ATTR_CSMA_MIN_BE] &&
+	    !info->attrs[IEEE802154_ATTR_CSMA_MAX_BE] &&
+	    !info->attrs[IEEE802154_ATTR_FRAME_RETRIES])
+		goto out;
+
+	phy = ops->get_phy(dev);
+
+	if ((!phy->set_lbt && info->attrs[IEEE802154_ATTR_LBT_ENABLED]) ||
+	    (!phy->set_cca_mode && info->attrs[IEEE802154_ATTR_CCA_MODE]) ||
+	    (!phy->set_cca_ed_level &&
+	     info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL]) ||
+	    (!phy->set_csma_params &&
+	     (info->attrs[IEEE802154_ATTR_CSMA_RETRIES] ||
+	      info->attrs[IEEE802154_ATTR_CSMA_MIN_BE] ||
+	      info->attrs[IEEE802154_ATTR_CSMA_MAX_BE])) ||
+	    (!phy->set_frame_retries && 
+	     info->attrs[IEEE802154_ATTR_FRAME_RETRIES])) {
+		rc = -EOPNOTSUPP;
+		goto out_phy;
+	}
+
+	ops->get_mac_params(dev, &params);
+
+	if (info->attrs[IEEE802154_ATTR_TXPOWER])
+		params.transmit_power = nla_get_s8(info->attrs[IEEE802154_ATTR_TXPOWER]);
+
+	if (info->attrs[IEEE802154_ATTR_LBT_ENABLED])
+		params.lbt = nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
+
+	if (info->attrs[IEEE802154_ATTR_CCA_MODE])
+		params.cca_mode = nla_get_u8(info->attrs[IEEE802154_ATTR_CCA_MODE]);
+
+	if (info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL])
+		params.cca_ed_level = nla_get_s32(info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL]);
+
+	if (info->attrs[IEEE802154_ATTR_CSMA_RETRIES])
+		params.csma_retries = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_RETRIES]);
+
+	if (info->attrs[IEEE802154_ATTR_CSMA_MIN_BE])
+		params.min_be = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_MIN_BE]);
+
+	if (info->attrs[IEEE802154_ATTR_CSMA_MAX_BE])
+		params.max_be = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_MAX_BE]);
+
+	if (info->attrs[IEEE802154_ATTR_FRAME_RETRIES])
+		params.frame_retries = nla_get_s8(info->attrs[IEEE802154_ATTR_FRAME_RETRIES]);
+
+	rc = ops->set_mac_params(dev, &params);
+
+	wpan_phy_put(phy);
+	dev_put(dev);
+	return rc;
+
+out_phy:
+	wpan_phy_put(phy);
+out:
+	dev_put(dev);
+	return rc;
+}
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 222310a..89b265a 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -55,15 +55,7 @@ static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
 	mutex_lock(&phy->pib_lock);
 	if (nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_PAGE, phy->current_page) ||
-	    nla_put_u8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel) ||
-	    nla_put_s8(msg, IEEE802154_ATTR_TXPOWER, phy->transmit_power) ||
-	    nla_put_u8(msg, IEEE802154_ATTR_LBT_ENABLED, phy->lbt) ||
-	    nla_put_u8(msg, IEEE802154_ATTR_CCA_MODE, phy->cca_mode) ||
-	    nla_put_s32(msg, IEEE802154_ATTR_CCA_ED_LEVEL, phy->cca_ed_level) ||
-	    nla_put_u8(msg, IEEE802154_ATTR_CSMA_RETRIES, phy->csma_retries) ||
-	    nla_put_u8(msg, IEEE802154_ATTR_CSMA_MIN_BE, phy->min_be) ||
-	    nla_put_u8(msg, IEEE802154_ATTR_CSMA_MAX_BE, phy->max_be) ||
-	    nla_put_s8(msg, IEEE802154_ATTR_FRAME_RETRIES, phy->frame_retries))
+	    nla_put_u8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel))
 		goto nla_put_failure;
 	for (i = 0; i < 32; i++) {
 		if (phy->channels_supported[i])
@@ -362,193 +354,3 @@ out_dev:
 
 	return rc;
 }
-
-static int phy_set_txpower(struct wpan_phy *phy, struct genl_info *info)
-{
-	int txpower = nla_get_s8(info->attrs[IEEE802154_ATTR_TXPOWER]);
-	int rc;
-
-	rc = phy->set_txpower(phy, txpower);
-	if (rc < 0)
-		return rc;
-
-	phy->transmit_power = txpower;
-
-	return 0;
-}
-
-static int phy_set_lbt(struct wpan_phy *phy, struct genl_info *info)
-{
-	u8 on = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
-	int rc;
-
-	rc = phy->set_lbt(phy, on);
-	if (rc < 0)
-		return rc;
-
-	phy->lbt = on;
-
-	return 0;
-}
-
-static int phy_set_cca_mode(struct wpan_phy *phy, struct genl_info *info)
-{
-	u8 mode = nla_get_u8(info->attrs[IEEE802154_ATTR_CCA_MODE]);
-	int rc;
-
-	if (mode > 3)
-		return -EINVAL;
-
-	rc = phy->set_cca_mode(phy, mode);
-	if (rc < 0)
-		return rc;
-
-	phy->cca_mode = mode;
-
-	return 0;
-}
-
-static int phy_set_cca_ed_level(struct wpan_phy *phy, struct genl_info *info)
-{
-	s32 level = nla_get_s32(info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL]);
-	int rc;
-
-	rc = phy->set_cca_ed_level(phy, level);
-	if (rc < 0)
-		return rc;
-
-	phy->cca_ed_level = level;
-
-	return 0;
-}
-
-static int phy_set_csma_params(struct wpan_phy *phy, struct genl_info *info)
-{
-	int rc;
-	u8 min_be = phy->min_be;
-	u8 max_be = phy->max_be;
-	u8 retries = phy->csma_retries;
-
-	if (info->attrs[IEEE802154_ATTR_CSMA_RETRIES])
-		retries = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_RETRIES]);
-	if (info->attrs[IEEE802154_ATTR_CSMA_MIN_BE])
-		min_be = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_MIN_BE]);
-	if (info->attrs[IEEE802154_ATTR_CSMA_MAX_BE])
-		max_be = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_MAX_BE]);
-
-	if (retries > 5 || max_be < 3 || max_be > 8 || min_be > max_be)
-		return -EINVAL;
-
-	rc = phy->set_csma_params(phy, min_be, max_be, retries);
-	if (rc < 0)
-		return rc;
-
-	phy->min_be = min_be;
-	phy->max_be = max_be;
-	phy->csma_retries = retries;
-
-	return 0;
-}
-
-static int phy_set_frame_retries(struct wpan_phy *phy, struct genl_info *info)
-{
-	s8 retries = nla_get_s8(info->attrs[IEEE802154_ATTR_FRAME_RETRIES]);
-	int rc;
-
-	if (retries < -1 || retries > 7)
-		return -EINVAL;
-
-	rc = phy->set_frame_retries(phy, retries);
-	if (rc < 0)
-		return rc;
-
-	phy->frame_retries = retries;
-
-	return 0;
-}
-
-int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
-{
-	struct wpan_phy *phy;
-	const char *name;
-	int rc = -ENOTSUPP;
-
-	pr_debug("%s\n", __func__);
-
-	if (!info->attrs[IEEE802154_ATTR_PHY_NAME] &&
-	    !info->attrs[IEEE802154_ATTR_LBT_ENABLED] &&
-	    !info->attrs[IEEE802154_ATTR_CCA_MODE] &&
-	    !info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL] &&
-	    !info->attrs[IEEE802154_ATTR_CSMA_RETRIES] &&
-	    !info->attrs[IEEE802154_ATTR_CSMA_MIN_BE] &&
-	    !info->attrs[IEEE802154_ATTR_CSMA_MAX_BE] &&
-	    !info->attrs[IEEE802154_ATTR_FRAME_RETRIES])
-		return -EINVAL;
-
-	name = nla_data(info->attrs[IEEE802154_ATTR_PHY_NAME]);
-	if (name[nla_len(info->attrs[IEEE802154_ATTR_PHY_NAME]) - 1] != '\0')
-		return -EINVAL; /* phy name should be null-terminated */
-
-	phy = wpan_phy_find(name);
-	if (!phy)
-		return -ENODEV;
-
-	if ((!phy->set_txpower && info->attrs[IEEE802154_ATTR_TXPOWER]) ||
-	    (!phy->set_lbt && info->attrs[IEEE802154_ATTR_LBT_ENABLED]) ||
-	    (!phy->set_cca_mode && info->attrs[IEEE802154_ATTR_CCA_MODE]) ||
-	    (!phy->set_cca_ed_level &&
-	     info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL]))
-		goto out;
-
-	mutex_lock(&phy->pib_lock);
-
-	if (info->attrs[IEEE802154_ATTR_TXPOWER]) {
-		rc = phy_set_txpower(phy, info);
-		if (rc < 0)
-			goto error;
-	}
-
-	if (info->attrs[IEEE802154_ATTR_LBT_ENABLED]) {
-		rc = phy_set_lbt(phy, info);
-		if (rc < 0)
-			goto error;
-	}
-
-	if (info->attrs[IEEE802154_ATTR_CCA_MODE]) {
-		rc = phy_set_cca_mode(phy, info);
-		if (rc < 0)
-			goto error;
-	}
-
-	if (info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL]) {
-		rc = phy_set_cca_ed_level(phy, info);
-		if (rc < 0)
-			goto error;
-	}
-
-	if (info->attrs[IEEE802154_ATTR_CSMA_RETRIES] ||
-	    info->attrs[IEEE802154_ATTR_CSMA_MIN_BE] ||
-	    info->attrs[IEEE802154_ATTR_CSMA_MAX_BE]) {
-		rc = phy_set_csma_params(phy, info);
-		if (rc < 0)
-			goto error;
-	}
-
-	if (info->attrs[IEEE802154_ATTR_FRAME_RETRIES]) {
-		rc = phy_set_frame_retries(phy, info);
-		if (rc < 0)
-			goto error;
-	}
-
-	mutex_unlock(&phy->pib_lock);
-
-	wpan_phy_put(phy);
-
-	return 0;
-
-error:
-	mutex_unlock(&phy->pib_lock);
-out:
-	wpan_phy_put(phy);
-	return rc;
-}
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index edd0962..8d6f670 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -169,12 +169,6 @@ struct wpan_phy *wpan_phy_alloc(size_t priv_size)
 	phy->current_channel = -1; /* not initialised */
 	phy->current_page = 0; /* for compatibility */
 
-	/* defaults per 802.15.4-2011 */
-	phy->min_be = 3;
-	phy->max_be = 5;
-	phy->csma_retries = 4;
-	phy->frame_retries = -1; /* for compatibility, actual default is 3 */
-
 	return phy;
 
 out:
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index f40522e..28ef59c 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -23,6 +23,8 @@
 #ifndef MAC802154_H
 #define MAC802154_H
 
+#include <net/ieee802154_netdev.h>
+
 /* mac802154 device private data */
 struct mac802154_priv {
 	struct ieee802154_dev hw;
@@ -82,6 +84,8 @@ struct mac802154_sub_if_data {
 	u8 chan;
 	u8 page;
 
+	struct ieee802154_mac_params mac_params;
+
 	/* MAC BSN field */
 	u8 bsn;
 	/* MAC DSN field */
@@ -116,4 +120,9 @@ void mac802154_dev_set_pan_id(struct net_device *dev, __le16 val);
 void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan);
 u8 mac802154_dev_get_dsn(const struct net_device *dev);
 
+int mac802154_set_mac_params(struct net_device *dev,
+			     const struct ieee802154_mac_params *params);
+void mac802154_get_mac_params(struct net_device *dev,
+			      struct ieee802154_mac_params *params);
+
 #endif /* MAC802154_H */
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index 15bac33..d40c092 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -74,4 +74,7 @@ struct ieee802154_mlme_ops mac802154_mlme_wpan = {
 	.get_pan_id = mac802154_dev_get_pan_id,
 	.get_short_addr = mac802154_dev_get_short_addr,
 	.get_dsn = mac802154_dev_get_dsn,
+
+	.set_mac_params = mac802154_set_mac_params,
+	.get_mac_params = mac802154_get_mac_params,
 };
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 80cbee1..1df7a6a 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -102,6 +102,87 @@ static int mac802154_wpan_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
+int mac802154_set_mac_params(struct net_device *dev,
+			     const struct ieee802154_mac_params *params)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	mutex_lock(&priv->hw->slaves_mtx);
+	priv->mac_params = *params;
+	mutex_unlock(&priv->hw->slaves_mtx);
+
+	return 0;
+}
+
+void mac802154_get_mac_params(struct net_device *dev,
+			      struct ieee802154_mac_params *params)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	mutex_lock(&priv->hw->slaves_mtx);
+	*params = priv->mac_params;
+	mutex_unlock(&priv->hw->slaves_mtx);
+}
+
+int mac802154_wpan_open(struct net_device *dev)
+{
+	int rc;
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct wpan_phy *phy = priv->hw->phy;
+
+	rc = mac802154_slave_open(dev);
+	if (rc < 0)
+		return rc;
+
+	mutex_lock(&phy->pib_lock);
+
+	if (phy->set_txpower) {
+		rc = phy->set_txpower(phy, priv->mac_params.transmit_power);
+		if (rc < 0)
+			goto out;
+	}
+
+	if (phy->set_lbt) {
+		rc = phy->set_lbt(phy, priv->mac_params.lbt);
+		if (rc < 0)
+			goto out;
+	}
+
+	if (phy->set_cca_mode) {
+		rc = phy->set_cca_mode(phy, priv->mac_params.cca_mode);
+		if (rc < 0)
+			goto out;
+	}
+
+	if (phy->set_cca_ed_level) {
+		rc = phy->set_cca_ed_level(phy, priv->mac_params.cca_ed_level);
+		if (rc < 0)
+			goto out;
+	}
+
+	if (phy->set_csma_params) {
+		rc = phy->set_csma_params(phy, priv->mac_params.min_be,
+					  priv->mac_params.max_be,
+					  priv->mac_params.csma_retries);
+		if (rc < 0)
+			goto out;
+	}
+
+	if (phy->set_frame_retries) {
+		rc = phy->set_frame_retries(phy,
+					    priv->mac_params.frame_retries);
+		if (rc < 0)
+			goto out;
+	}
+
+	mutex_unlock(&phy->pib_lock);
+	return 0;
+
+out:
+	mutex_unlock(&phy->pib_lock);
+	return rc;
+}
+
 static int mac802154_header_create(struct sk_buff *skb,
 				   struct net_device *dev,
 				   unsigned short type,
@@ -204,7 +285,7 @@ static struct header_ops mac802154_header_ops = {
 };
 
 static const struct net_device_ops mac802154_wpan_ops = {
-	.ndo_open		= mac802154_slave_open,
+	.ndo_open		= mac802154_wpan_open,
 	.ndo_stop		= mac802154_slave_close,
 	.ndo_start_xmit		= mac802154_wpan_xmit,
 	.ndo_do_ioctl		= mac802154_wpan_ioctl,
@@ -242,6 +323,12 @@ void mac802154_wpan_setup(struct net_device *dev)
 	get_random_bytes(&priv->bsn, 1);
 	get_random_bytes(&priv->dsn, 1);
 
+	/* defaults per 802.15.4-2011 */
+	priv->mac_params.min_be = 3;
+	priv->mac_params.max_be = 5;
+	priv->mac_params.csma_retries = 4;
+	priv->mac_params.frame_retries = -1; /* for compatibility, actual default is 3 */
+
 	priv->pan_id = cpu_to_le16(IEEE802154_PANID_BROADCAST);
 	priv->short_addr = cpu_to_le16(IEEE802154_ADDR_BROADCAST);
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
