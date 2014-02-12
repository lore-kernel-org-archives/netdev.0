From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 09/10] ieee802154: add netlink APIs for smartMAC configuration
Date: Wed, 12 Feb 2014 17:37:13 +0100
Message-ID: <1392223034-19955-10-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:46841 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbaBLQhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:37:50 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s1CGbiII030944
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 17:37:44 +0100
In-Reply-To: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce new netlink attributes for SET_PHY_ATTRS:
 * CSMA minimal backoff exponent
 * CSMA maximal backoff exponent
 * CSMA retry limit
 * frame retransmission limit

The CSMA attributes shall correspond to minBE, maxBE and maxCSMABackoffs of
802.15.4, respectively. The frame retransmission shall correspond to
maxFrameRetries of 802.15.4, unless given as -1: then the old behaviour
of the stack shall apply. For RF2xy, the old behaviour is to not do
channel sensing at all and simply send *right now*, which is not
intended behaviour for most applications and actually prohibited for
some channel/page combinations.

For all values except frame retransmission limit, the defaults of
802.15.4 apply. Frame retransmission limits are set to -1 to indicate
backward-compatible behaviour.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 include/linux/nl802154.h       |    5 ++++
 include/net/mac802154.h        |   12 ++++++++
 include/net/wpan-phy.h         |    7 +++++
 net/ieee802154/nl-phy.c        |   63 +++++++++++++++++++++++++++++++++++++++-
 net/ieee802154/nl_policy.c     |    5 ++++
 net/ieee802154/wpan-class.c    |    6 ++++
 net/mac802154/ieee802154_dev.c |   23 +++++++++++++++
 7 files changed, 120 insertions(+), 1 deletion(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 0594a0a..e110b8c 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -74,6 +74,11 @@ enum {
 	IEEE802154_ATTR_LBT_ENABLED,
 	IEEE802154_ATTR_CCA_MODE,
 	IEEE802154_ATTR_CCA_ED_LEVEL,
+	IEEE802154_ATTR_CSMA_RETRIES,
+	IEEE802154_ATTR_CSMA_MIN_BE,
+	IEEE802154_ATTR_CSMA_MAX_BE,
+
+	IEEE802154_ATTR_FRAME_RETRIES,
 
 	__IEEE802154_ATTR_MAX,
 };
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 15fe6bc..8ca3d04 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -131,6 +131,14 @@ struct ieee802154_dev {
  *	  Sets the CCA energy detection threshold in dBm. Called with pib_lock
  *	  held.
  *	  Returns either zero, or negative errno.
+ *
+ * set_csma_params
+ *	  Sets the CSMA parameter set for the PHY. Called with pib_lock held.
+ *	  Returns either zero, or negative errno.
+ *
+ * set_frame_retries
+ *	  Sets the retransmission attempt limit. Called with pib_lock held.
+ *	  Returns either zero, or negative errno.
  */
 struct ieee802154_ops {
 	struct module	*owner;
@@ -152,6 +160,10 @@ struct ieee802154_ops {
 	int		(*set_cca_mode)(struct ieee802154_dev *dev, u8 mode);
 	int		(*set_cca_ed_level)(struct ieee802154_dev *dev,
 					    s32 level);
+	int		(*set_csma_params)(struct ieee802154_dev *dev,
+					   u8 min_be, u8 max_be, u8 retries);
+	int		(*set_frame_retries)(struct ieee802154_dev *dev,
+					     s8 retries);
 };
 
 /* Basic interface to register ieee802154 device */
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 0b570ad..10ab0fc 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -46,6 +46,10 @@ struct wpan_phy {
 	u32 channels_supported[32];
 	s8 transmit_power;
 	u8 cca_mode;
+	u8 min_be;
+	u8 max_be;
+	u8 csma_retries;
+	s8 frame_retries;
 
 	bool lbt;
 	s32 cca_ed_level;
@@ -61,6 +65,9 @@ struct wpan_phy {
 	int (*set_lbt)(struct wpan_phy *phy, bool on);
 	int (*set_cca_mode)(struct wpan_phy *phy, u8 cca_mode);
 	int (*set_cca_ed_level)(struct wpan_phy *phy, int level);
+	int (*set_csma_params)(struct wpan_phy *phy, u8 min_be, u8 max_be,
+			       u8 retries);
+	int (*set_frame_retries)(struct wpan_phy *phy, s8 retries);
 
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
 };
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 23365fa..7331bc6 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -418,6 +418,49 @@ static int phy_set_cca_ed_level(struct wpan_phy *phy, struct genl_info *info)
 	return 0;
 }
 
+static int phy_set_csma_params(struct wpan_phy *phy, struct genl_info *info)
+{
+	int rc;
+	u8 min_be = phy->min_be;
+	u8 max_be = phy->max_be;
+	u8 retries = phy->csma_retries;
+
+	if (info->attrs[IEEE802154_ATTR_CSMA_RETRIES])
+		retries = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_RETRIES]);
+	if (info->attrs[IEEE802154_ATTR_CSMA_MIN_BE])
+		min_be = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_MIN_BE]);
+	if (info->attrs[IEEE802154_ATTR_CSMA_MAX_BE])
+		max_be = nla_get_u8(info->attrs[IEEE802154_ATTR_CSMA_MAX_BE]);
+
+	if (retries > 5 || max_be > 8 || min_be > max_be ||
+		retries < -1 || retries > 7)
+		return -EINVAL;
+
+	rc = phy->set_csma_params(phy, min_be, max_be, retries);
+	if (rc < 0)
+		return rc;
+
+	phy->min_be = min_be;
+	phy->max_be = max_be;
+	phy->csma_retries = retries;
+
+	return 0;
+}
+
+static int phy_set_frame_retries(struct wpan_phy *phy, struct genl_info *info)
+{
+	s8 retries = nla_get_s8(info->attrs[IEEE802154_ATTR_FRAME_RETRIES]);
+	int rc;
+
+	rc = phy->set_frame_retries(phy, retries);
+	if (rc < 0)
+		return rc;
+
+	phy->frame_retries = retries;
+
+	return 0;
+}
+
 int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 {
 	struct wpan_phy *phy;
@@ -429,7 +472,11 @@ int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 	if (!info->attrs[IEEE802154_ATTR_PHY_NAME] &&
 		!info->attrs[IEEE802154_ATTR_LBT_ENABLED] &&
 		!info->attrs[IEEE802154_ATTR_CCA_MODE] &&
-		!info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL])
+		!info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL] &&
+		!info->attrs[IEEE802154_ATTR_CSMA_RETRIES] &&
+		!info->attrs[IEEE802154_ATTR_CSMA_MIN_BE] &&
+		!info->attrs[IEEE802154_ATTR_CSMA_MAX_BE] &&
+		!info->attrs[IEEE802154_ATTR_FRAME_RETRIES])
 		return -EINVAL;
 
 	name = nla_data(info->attrs[IEEE802154_ATTR_PHY_NAME]);
@@ -473,6 +520,20 @@ int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 			goto error;
 	}
 
+	if (info->attrs[IEEE802154_ATTR_CSMA_RETRIES] ||
+		info->attrs[IEEE802154_ATTR_CSMA_MIN_BE] ||
+		info->attrs[IEEE802154_ATTR_CSMA_MAX_BE]) {
+		rc = phy_set_csma_params(phy, info);
+		if (rc < 0)
+			goto error;
+	}
+
+	if (info->attrs[IEEE802154_ATTR_FRAME_RETRIES]) {
+		rc = phy_set_frame_retries(phy, info);
+		if (rc < 0)
+			goto error;
+	}
+
 	mutex_unlock(&phy->pib_lock);
 
 	wpan_phy_put(phy);
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index 55b5616..fd7be5e 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -57,5 +57,10 @@ const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_LBT_ENABLED] = { .type = NLA_U8, },
 	[IEEE802154_ATTR_CCA_MODE] = { .type = NLA_U8, },
 	[IEEE802154_ATTR_CCA_ED_LEVEL] = { .type = NLA_S32, },
+	[IEEE802154_ATTR_CSMA_RETRIES] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_CSMA_MIN_BE] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_CSMA_MAX_BE] = { .type = NLA_U8, },
+
+	[IEEE802154_ATTR_FRAME_RETRIES] = { .type = NLA_S8, },
 };
 
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 8d6f670..edd0962 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -169,6 +169,12 @@ struct wpan_phy *wpan_phy_alloc(size_t priv_size)
 	phy->current_channel = -1; /* not initialised */
 	phy->current_page = 0; /* for compatibility */
 
+	/* defaults per 802.15.4-2011 */
+	phy->min_be = 3;
+	phy->max_be = 5;
+	phy->csma_retries = 4;
+	phy->frame_retries = -1; /* for compatibility, actual default is 3 */
+
 	return phy;
 
 out:
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 4707f36..b75bb01 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -205,6 +205,27 @@ static int mac802154_set_cca_ed_level(struct wpan_phy *phy, s32 level)
 	return priv->ops->set_cca_ed_level(&priv->hw, level);
 }
 
+static int mac802154_set_csma_params(struct wpan_phy *phy, u8 min_be,
+				     u8 max_be, u8 retries)
+{
+	struct mac802154_priv *priv = wpan_phy_priv(phy);
+
+	if (!priv->ops->set_csma_params)
+		return -ENOTSUPP;
+
+	return priv->ops->set_csma_params(&priv->hw, min_be, max_be, retries);
+}
+
+static int mac802154_set_frame_retries(struct wpan_phy *phy, s8 retries)
+{
+	struct mac802154_priv *priv = wpan_phy_priv(phy);
+
+	if (!priv->ops->set_frame_retries)
+		return -ENOTSUPP;
+
+	return priv->ops->set_frame_retries(&priv->hw, retries);
+}
+
 struct ieee802154_dev *
 ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 {
@@ -286,6 +307,8 @@ int ieee802154_register_device(struct ieee802154_dev *dev)
 	priv->phy->set_lbt = mac802154_set_lbt;
 	priv->phy->set_cca_mode = mac802154_set_cca_mode;
 	priv->phy->set_cca_ed_level = mac802154_set_cca_ed_level;
+	priv->phy->set_csma_params = mac802154_set_csma_params;
+	priv->phy->set_frame_retries = mac802154_set_frame_retries;
 
 	rc = wpan_phy_register(priv->phy);
 	if (rc < 0)
-- 
1.7.9.5
