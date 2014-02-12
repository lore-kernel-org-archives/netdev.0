From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 07/10] ieee802154: add support
	for setting CCA energy detection levels
Date: Wed, 12 Feb 2014 17:37:11 +0100
Message-ID: <1392223034-19955-8-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1392223034-19955-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Since three of the four clear channel assesment modes make use of energy
detection, provide an API to set the energy detection threshold.
Driver support for this is available in at86rf230 for the RF212 chips.
Since for these chips the minimal energy detection threshold depends on
page and channel used, add a field to struct at86rf230_local that stores
the minimal threshold. Actual ED thresholds are configured as offsets
from this value.

For RF212, setting the ED threshold will not work before a channel/page
has been set due to the dependency of energy detection in the chip and
the actual channel/page selected.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c |   26 ++++++++++++++++++++++++--
 include/linux/nl802154.h           |    1 +
 include/net/mac802154.h            |    7 +++++++
 include/net/wpan-phy.h             |    2 ++
 net/ieee802154/nl-phy.c            |   30 +++++++++++++++++++++++++++---
 net/ieee802154/nl_policy.c         |    1 +
 net/mac802154/ieee802154_dev.c     |   11 +++++++++++
 7 files changed, 73 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index fb5e55a..9e3bb34 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -52,6 +52,8 @@ struct at86rf230_local {
 	spinlock_t lock;
 	bool irq_busy;
 	bool is_tx;
+
+	int rssi_base_val;
 };
 
 static inline int is_rf212(struct at86rf230_local *local)
@@ -580,6 +582,8 @@ at86rf230_stop(struct ieee802154_dev *dev)
 static int
 at86rf230_set_channel(struct at86rf230_local *lp, int page, int channel)
 {
+	lp->rssi_base_val = -91;
+
 	return at86rf230_write_subreg(lp, SR_CHANNEL, channel);
 }
 
@@ -596,10 +600,13 @@ at86rf212_set_channel(struct at86rf230_local *lp, int page, int channel)
 	if (rc < 0)
 		return rc;
 
-	if (page == 0)
+	if (page == 0) {
 		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 0);
-	else
+		lp->rssi_base_val = -100;
+	} else {
 		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 1);
+		lp->rssi_base_val = -98;
+	}
 
 	if (rc < 0)
 		return rc;
@@ -806,6 +813,20 @@ at86rf212_set_cca_mode(struct ieee802154_dev *dev, u8 mode)
 	return at86rf230_write_subreg(lp, SR_CCA_MODE, mode);
 }
 
+static int
+at86rf212_set_cca_ed_level(struct ieee802154_dev *dev, s32 level)
+{
+	struct at86rf230_local *lp = dev->priv;
+	int desens_steps;
+
+	if (level < lp->rssi_base_val || level > 30)
+		return -EINVAL;
+
+	desens_steps = (level - lp->rssi_base_val) * 100 / 207;
+
+	return at86rf230_write_subreg(lp, SR_CCA_ED_THRES, desens_steps);
+}
+
 static struct ieee802154_ops at86rf230_ops = {
 	.owner = THIS_MODULE,
 	.xmit = at86rf230_xmit,
@@ -827,6 +848,7 @@ static struct ieee802154_ops at86rf212_ops = {
 	.set_txpower = at86rf212_set_txpower,
 	.set_lbt = at86rf212_set_lbt,
 	.set_cca_mode = at86rf212_set_cca_mode,
+	.set_cca_ed_level = at86rf212_set_cca_ed_level,
 };
 
 static void at86rf230_irqwork(struct work_struct *work)
diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 5edefc1..0594a0a 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -73,6 +73,7 @@ enum {
 	IEEE802154_ATTR_TXPOWER,
 	IEEE802154_ATTR_LBT_ENABLED,
 	IEEE802154_ATTR_CCA_MODE,
+	IEEE802154_ATTR_CCA_ED_LEVEL,
 
 	__IEEE802154_ATTR_MAX,
 };
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 1a98e50..15fe6bc 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -126,6 +126,11 @@ struct ieee802154_dev {
  * set_cca_mode
  *	  Sets the CCA mode used by the device. Called with pib_lock held.
  *	  Returns either zero, or negative errno.
+ *
+ * set_cca_ed_level
+ *	  Sets the CCA energy detection threshold in dBm. Called with pib_lock
+ *	  held.
+ *	  Returns either zero, or negative errno.
  */
 struct ieee802154_ops {
 	struct module	*owner;
@@ -145,6 +150,8 @@ struct ieee802154_ops {
 	int		(*set_txpower)(struct ieee802154_dev *dev, int db);
 	int		(*set_lbt)(struct ieee802154_dev *dev, bool on);
 	int		(*set_cca_mode)(struct ieee802154_dev *dev, u8 mode);
+	int		(*set_cca_ed_level)(struct ieee802154_dev *dev,
+					    s32 level);
 };
 
 /* Basic interface to register ieee802154 device */
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 03b5905..0b570ad 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -48,6 +48,7 @@ struct wpan_phy {
 	u8 cca_mode;
 
 	bool lbt;
+	s32 cca_ed_level;
 
 	struct device dev;
 	int idx;
@@ -59,6 +60,7 @@ struct wpan_phy {
 	int (*set_txpower)(struct wpan_phy *phy, int db);
 	int (*set_lbt)(struct wpan_phy *phy, bool on);
 	int (*set_cca_mode)(struct wpan_phy *phy, u8 cca_mode);
+	int (*set_cca_ed_level)(struct wpan_phy *phy, int level);
 
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
 };
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 026b21a..23365fa 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -58,7 +58,8 @@ static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
 	    nla_put_u8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel) ||
 	    nla_put_s8(msg, IEEE802154_ATTR_TXPOWER, phy->transmit_power) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_LBT_ENABLED, phy->lbt) ||
-	    nla_put_u8(msg, IEEE802154_ATTR_CCA_MODE, phy->cca_mode))
+	    nla_put_u8(msg, IEEE802154_ATTR_CCA_MODE, phy->cca_mode) ||
+	    nla_put_s32(msg, IEEE802154_ATTR_CCA_ED_LEVEL, phy->cca_ed_level))
 		goto nla_put_failure;
 	for (i = 0; i < 32; i++) {
 		if (phy->channels_supported[i])
@@ -403,6 +404,20 @@ static int phy_set_cca_mode(struct wpan_phy *phy, struct genl_info *info)
 	return 0;
 }
 
+static int phy_set_cca_ed_level(struct wpan_phy *phy, struct genl_info *info)
+{
+	s32 level = nla_get_s32(info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL]);
+	int rc;
+
+	rc = phy->set_cca_ed_level(phy, level);
+	if (rc < 0)
+		return rc;
+
+	phy->cca_ed_level = level;
+
+	return 0;
+}
+
 int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 {
 	struct wpan_phy *phy;
@@ -413,7 +428,8 @@ int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 
 	if (!info->attrs[IEEE802154_ATTR_PHY_NAME] &&
 		!info->attrs[IEEE802154_ATTR_LBT_ENABLED] &&
-		!info->attrs[IEEE802154_ATTR_CCA_MODE])
+		!info->attrs[IEEE802154_ATTR_CCA_MODE] &&
+		!info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL])
 		return -EINVAL;
 
 	name = nla_data(info->attrs[IEEE802154_ATTR_PHY_NAME]);
@@ -426,7 +442,9 @@ int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 
 	if ((!phy->set_txpower && info->attrs[IEEE802154_ATTR_TXPOWER]) ||
 		(!phy->set_lbt && info->attrs[IEEE802154_ATTR_LBT_ENABLED]) ||
-		(!phy->set_cca_mode && info->attrs[IEEE802154_ATTR_CCA_MODE]))
+		(!phy->set_cca_mode && info->attrs[IEEE802154_ATTR_CCA_MODE]) ||
+		(!phy->set_cca_ed_level &&
+			info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL]))
 		goto out;
 
 	mutex_lock(&phy->pib_lock);
@@ -449,6 +467,12 @@ int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 			goto error;
 	}
 
+	if (info->attrs[IEEE802154_ATTR_CCA_ED_LEVEL]) {
+		rc = phy_set_cca_ed_level(phy, info);
+		if (rc < 0)
+			goto error;
+	}
+
 	mutex_unlock(&phy->pib_lock);
 
 	wpan_phy_put(phy);
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index d87c2c9..55b5616 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -56,5 +56,6 @@ const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_TXPOWER] = { .type = NLA_S8, },
 	[IEEE802154_ATTR_LBT_ENABLED] = { .type = NLA_U8, },
 	[IEEE802154_ATTR_CCA_MODE] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_CCA_ED_LEVEL] = { .type = NLA_S32, },
 };
 
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 4965e4c..4707f36 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -195,6 +195,16 @@ static int mac802154_set_cca_mode(struct wpan_phy *phy, u8 mode)
 	return priv->ops->set_cca_mode(&priv->hw, mode);
 }
 
+static int mac802154_set_cca_ed_level(struct wpan_phy *phy, s32 level)
+{
+	struct mac802154_priv *priv = wpan_phy_priv(phy);
+
+	if (!priv->ops->set_cca_ed_level)
+		return -ENOTSUPP;
+
+	return priv->ops->set_cca_ed_level(&priv->hw, level);
+}
+
 struct ieee802154_dev *
 ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 {
@@ -275,6 +285,7 @@ int ieee802154_register_device(struct ieee802154_dev *dev)
 	priv->phy->set_txpower = mac802154_set_txpower;
 	priv->phy->set_lbt = mac802154_set_lbt;
 	priv->phy->set_cca_mode = mac802154_set_cca_mode;
+	priv->phy->set_cca_ed_level = mac802154_set_cca_ed_level;
 
 	rc = wpan_phy_register(priv->phy);
 	if (rc < 0)
-- 
1.7.9.5


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
