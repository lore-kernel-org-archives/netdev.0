From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2 06/10] ieee802154: add support for CCA mode in wpan phys
Date: Fri, 14 Feb 2014 23:49:28 +0100
Message-ID: <1392418172-5305-7-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:43993 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbaBNW63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:58:29 -0500
In-Reply-To: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The standard describes four modes of clear channel assesment: "energy
above threshold", "carrier found", and the logical and/or of these two.
Support for CCA mode setting is included in the at86rf230 driver,
predicated for RF212 chips.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c |  9 +++++++++
 include/linux/nl802154.h           |  1 +
 include/net/mac802154.h            |  5 +++++
 include/net/wpan-phy.h             |  1 +
 net/ieee802154/nl-phy.c            | 32 +++++++++++++++++++++++++++++---
 net/ieee802154/nl_policy.c         |  1 +
 net/mac802154/ieee802154_dev.c     | 11 +++++++++++
 7 files changed, 57 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 75bc9cf..abdad66 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -795,6 +795,14 @@ at86rf212_set_lbt(struct ieee802154_dev *dev, bool on)
 	return at86rf230_write_subreg(lp, SR_CSMA_LBT_MODE, on);
 }
 
+static int
+at86rf212_set_cca_mode(struct ieee802154_dev *dev, u8 mode)
+{
+	struct at86rf230_local *lp = dev->priv;
+
+	return at86rf230_write_subreg(lp, SR_CCA_MODE, mode);
+}
+
 static struct ieee802154_ops at86rf230_ops = {
 	.owner = THIS_MODULE,
 	.xmit = at86rf230_xmit,
@@ -815,6 +823,7 @@ static struct ieee802154_ops at86rf212_ops = {
 	.set_hw_addr_filt = at86rf230_set_hw_addr_filt,
 	.set_txpower = at86rf212_set_txpower,
 	.set_lbt = at86rf212_set_lbt,
+	.set_cca_mode = at86rf212_set_cca_mode,
 };
 
 static void at86rf230_irqwork(struct work_struct *work)
diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 326baee..5edefc1 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -72,6 +72,7 @@ enum {
 
 	IEEE802154_ATTR_TXPOWER,
 	IEEE802154_ATTR_LBT_ENABLED,
+	IEEE802154_ATTR_CCA_MODE,
 
 	__IEEE802154_ATTR_MAX,
 };
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 521edcb..1a98e50 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -122,6 +122,10 @@ struct ieee802154_dev {
  *	  Enables or disables listen before talk on the device. Called with
  *	  pib_lock held.
  *	  Returns either zero, or negative errno.
+ *
+ * set_cca_mode
+ *	  Sets the CCA mode used by the device. Called with pib_lock held.
+ *	  Returns either zero, or negative errno.
  */
 struct ieee802154_ops {
 	struct module	*owner;
@@ -140,6 +144,7 @@ struct ieee802154_ops {
 				     u8 addr[IEEE802154_ADDR_LEN]);
 	int		(*set_txpower)(struct ieee802154_dev *dev, int db);
 	int		(*set_lbt)(struct ieee802154_dev *dev, bool on);
+	int		(*set_cca_mode)(struct ieee802154_dev *dev, u8 mode);
 };
 
 /* Basic interface to register ieee802154 device */
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 804e6c4..03b5905 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -58,6 +58,7 @@ struct wpan_phy {
 
 	int (*set_txpower)(struct wpan_phy *phy, int db);
 	int (*set_lbt)(struct wpan_phy *phy, bool on);
+	int (*set_cca_mode)(struct wpan_phy *phy, u8 cca_mode);
 
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
 };
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index f248122..026b21a 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -57,7 +57,8 @@ static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
 	    nla_put_u8(msg, IEEE802154_ATTR_PAGE, phy->current_page) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel) ||
 	    nla_put_s8(msg, IEEE802154_ATTR_TXPOWER, phy->transmit_power) ||
-	    nla_put_u8(msg, IEEE802154_ATTR_LBT_ENABLED, phy->lbt))
+	    nla_put_u8(msg, IEEE802154_ATTR_LBT_ENABLED, phy->lbt) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_CCA_MODE, phy->cca_mode))
 		goto nla_put_failure;
 	for (i = 0; i < 32; i++) {
 		if (phy->channels_supported[i])
@@ -385,6 +386,23 @@ static int phy_set_lbt(struct wpan_phy *phy, struct genl_info *info)
 	return 0;
 }
 
+static int phy_set_cca_mode(struct wpan_phy *phy, struct genl_info *info)
+{
+	u8 mode = nla_get_u8(info->attrs[IEEE802154_ATTR_CCA_MODE]);
+	int rc;
+
+	if (mode > 3)
+		return -EINVAL;
+
+	rc = phy->set_cca_mode(phy, mode);
+	if (rc < 0)
+		return rc;
+
+	phy->cca_mode = mode;
+
+	return 0;
+}
+
 int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 {
 	struct wpan_phy *phy;
@@ -394,7 +412,8 @@ int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 	pr_debug("%s\n", __func__);
 
 	if (!info->attrs[IEEE802154_ATTR_PHY_NAME] &&
-		!info->attrs[IEEE802154_ATTR_LBT_ENABLED])
+		!info->attrs[IEEE802154_ATTR_LBT_ENABLED] &&
+		!info->attrs[IEEE802154_ATTR_CCA_MODE])
 		return -EINVAL;
 
 	name = nla_data(info->attrs[IEEE802154_ATTR_PHY_NAME]);
@@ -406,7 +425,8 @@ int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 		return -ENODEV;
 
 	if ((!phy->set_txpower && info->attrs[IEEE802154_ATTR_TXPOWER]) ||
-		(!phy->set_lbt && info->attrs[IEEE802154_ATTR_LBT_ENABLED]))
+		(!phy->set_lbt && info->attrs[IEEE802154_ATTR_LBT_ENABLED]) ||
+		(!phy->set_cca_mode && info->attrs[IEEE802154_ATTR_CCA_MODE]))
 		goto out;
 
 	mutex_lock(&phy->pib_lock);
@@ -423,6 +443,12 @@ int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 			goto error;
 	}
 
+	if (info->attrs[IEEE802154_ATTR_CCA_MODE]) {
+		rc = phy_set_cca_mode(phy, info);
+		if (rc < 0)
+			goto error;
+	}
+
 	mutex_unlock(&phy->pib_lock);
 
 	wpan_phy_put(phy);
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index a09f642..d87c2c9 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -55,5 +55,6 @@ const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 
 	[IEEE802154_ATTR_TXPOWER] = { .type = NLA_S8, },
 	[IEEE802154_ATTR_LBT_ENABLED] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_CCA_MODE] = { .type = NLA_U8, },
 };
 
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 56338c8..4965e4c 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -185,6 +185,16 @@ static int mac802154_set_lbt(struct wpan_phy *phy, bool on)
 	return priv->ops->set_lbt(&priv->hw, on);
 }
 
+static int mac802154_set_cca_mode(struct wpan_phy *phy, u8 mode)
+{
+	struct mac802154_priv *priv = wpan_phy_priv(phy);
+
+	if (!priv->ops->set_cca_mode)
+		return -ENOTSUPP;
+
+	return priv->ops->set_cca_mode(&priv->hw, mode);
+}
+
 struct ieee802154_dev *
 ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 {
@@ -264,6 +274,7 @@ int ieee802154_register_device(struct ieee802154_dev *dev)
 	priv->phy->del_iface = mac802154_del_iface;
 	priv->phy->set_txpower = mac802154_set_txpower;
 	priv->phy->set_lbt = mac802154_set_lbt;
+	priv->phy->set_cca_mode = mac802154_set_cca_mode;
 
 	rc = wpan_phy_register(priv->phy);
 	if (rc < 0)
-- 
1.8.5.4
