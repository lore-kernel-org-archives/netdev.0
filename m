From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2 03/10] ieee802154: add TX power control to wpan_phy
Date: Fri, 14 Feb 2014 23:49:25 +0100
Message-ID: <1392418172-5305-4-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:43985 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaBNW63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:58:29 -0500
In-Reply-To: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the current u8 transmit_power in wpan_phy with s8 transmit_power.
The u8 field contained the actual tx power and a tolerance field,
which no physical radio every used. Adjust sysfs entries to keep
compatibility with userspace, give tolerances of +-1dB statically there.

This patch only adds support for this in the at86rf230 driver and the
RF212 chip. Configuration calculation for RF212 is also somewhat basic,
but does the job - the RF212 datasheet gives a large table with
suggested values for combinations of TX power and page/channel, if this
does not work well, we might have to copy the whole table.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c | 25 +++++++++++++++++++
 include/linux/nl802154.h           |  4 ++++
 include/net/mac802154.h            |  5 ++++
 include/net/wpan-phy.h             |  6 +++--
 net/ieee802154/ieee802154.h        |  1 +
 net/ieee802154/netlink.c           |  1 +
 net/ieee802154/nl-phy.c            | 49 +++++++++++++++++++++++++++++++++++++-
 net/ieee802154/nl_policy.c         |  2 ++
 net/ieee802154/wpan-class.c        |  4 +---
 net/mac802154/ieee802154_dev.c     | 11 +++++++++
 10 files changed, 102 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 230258f..d2841b8 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -754,6 +754,30 @@ at86rf230_set_hw_addr_filt(struct ieee802154_dev *dev,
 	return 0;
 }
 
+static int
+at86rf212_set_txpower(struct ieee802154_dev *dev, int db)
+{
+	struct at86rf230_local *lp = dev->priv;
+	int rc;
+
+	/* typical maximum output is 5dBm with RG_PHY_TX_PWR 0x60, lower five
+	 * bits decrease power in 1dB steps. 0x60 represents extra PA gain of
+	 * 0dB.
+	 * thus, supported values for db range from -26 to 5, for 31dB of
+	 * reduction to 0dB of reduction.
+	 */
+	if (db > 5 || db < -26)
+		return -EINVAL;
+
+	db = -(db - 5);
+
+	rc = __at86rf230_write(lp, RG_PHY_TX_PWR, 0x60 | db);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
 static struct ieee802154_ops at86rf230_ops = {
 	.owner = THIS_MODULE,
 	.xmit = at86rf230_xmit,
@@ -772,6 +796,7 @@ static struct ieee802154_ops at86rf212_ops = {
 	.start = at86rf230_start,
 	.stop = at86rf230_stop,
 	.set_hw_addr_filt = at86rf230_set_hw_addr_filt,
+	.set_txpower = at86rf212_set_txpower,
 };
 
 static void at86rf230_irqwork(struct work_struct *work)
diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index fd4f2d1..625d19e 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -70,6 +70,8 @@ enum {
 	IEEE802154_ATTR_PHY_NAME,
 	IEEE802154_ATTR_DEV_TYPE,
 
+	IEEE802154_ATTR_TXPOWER,
+
 	__IEEE802154_ATTR_MAX,
 };
 
@@ -122,6 +124,8 @@ enum {
 	IEEE802154_ADD_IFACE,
 	IEEE802154_DEL_IFACE,
 
+	IEEE802154_SET_PHYPARAMS,
+
 	__IEEE802154_CMD_MAX,
 };
 
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 807d6b7..8bd2785 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -113,6 +113,10 @@ struct ieee802154_dev {
  *	  Set radio for listening on specific address.
  *	  Set the device for listening on specified address.
  *	  Returns either zero, or negative errno.
+ *
+ * set_txpower:
+ *	  Set radio transmit power in dB. Called with pib_lock held.
+ *	  Returns either zero, or negative errno.
  */
 struct ieee802154_ops {
 	struct module	*owner;
@@ -129,6 +133,7 @@ struct ieee802154_ops {
 					    unsigned long changed);
 	int		(*ieee_addr)(struct ieee802154_dev *dev,
 				     u8 addr[IEEE802154_ADDR_LEN]);
+	int		(*set_txpower)(struct ieee802154_dev *dev, int db);
 };
 
 /* Basic interface to register ieee802154 device */
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index b52bda8..47fc0c1 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -37,14 +37,14 @@ struct wpan_phy {
 	struct mutex pib_lock;
 
 	/*
-	 * This is a PIB according to 802.15.4-2006.
+	 * This is a PIB according to 802.15.4-2011.
 	 * We do not provide timing-related variables, as they
 	 * aren't used outside of driver
 	 */
 	u8 current_channel;
 	u8 current_page;
 	u32 channels_supported[32];
-	u8 transmit_power;
+	s8 transmit_power;
 	u8 cca_mode;
 
 	struct device dev;
@@ -54,6 +54,8 @@ struct wpan_phy {
 					const char *name, int type);
 	void (*del_iface)(struct wpan_phy *phy, struct net_device *dev);
 
+	int (*set_txpower)(struct wpan_phy *phy, int db);
+
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
 };
 
diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index cee4425..6cbc896 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -53,6 +53,7 @@ int ieee802154_list_phy(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_dump_phy(struct sk_buff *skb, struct netlink_callback *cb);
 int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info);
 int ieee802154_del_iface(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info);
 
 enum ieee802154_mcgrp_ids {
 	IEEE802154_COORD_MCGRP,
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 43f1b2b..67c151b 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -115,6 +115,7 @@ static const struct genl_ops ieee8021154_ops[] = {
 			ieee802154_dump_phy),
 	IEEE802154_OP(IEEE802154_ADD_IFACE, ieee802154_add_iface),
 	IEEE802154_OP(IEEE802154_DEL_IFACE, ieee802154_del_iface),
+	IEEE802154_OP(IEEE802154_SET_PHYPARAMS, ieee802154_set_phyparams),
 	/* see nl-mac.c */
 	IEEE802154_OP(IEEE802154_ASSOCIATE_REQ, ieee802154_associate_req),
 	IEEE802154_OP(IEEE802154_ASSOCIATE_RESP, ieee802154_associate_resp),
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 89b265a..d3ee62f 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -55,7 +55,8 @@ static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
 	mutex_lock(&phy->pib_lock);
 	if (nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_PAGE, phy->current_page) ||
-	    nla_put_u8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel))
+	    nla_put_u8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel) ||
+	    nla_put_s8(msg, IEEE802154_ATTR_TXPOWER, phy->transmit_power))
 		goto nla_put_failure;
 	for (i = 0; i < 32; i++) {
 		if (phy->channels_supported[i])
@@ -354,3 +355,49 @@ out_dev:
 
 	return rc;
 }
+
+int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
+{
+	struct wpan_phy *phy;
+	const char *name;
+	int txpower;
+	int rc = -EINVAL;
+
+	pr_debug("%s\n", __func__);
+
+	if (!info->attrs[IEEE802154_ATTR_PHY_NAME])
+		return -EINVAL;
+
+	name = nla_data(info->attrs[IEEE802154_ATTR_PHY_NAME]);
+	if (name[nla_len(info->attrs[IEEE802154_ATTR_PHY_NAME]) - 1] != '\0')
+		return -EINVAL; /* phy name should be null-terminated */
+
+	txpower = nla_get_s8(info->attrs[IEEE802154_ATTR_TXPOWER]);
+
+	phy = wpan_phy_find(name);
+	if (!phy)
+		return -ENODEV;
+
+	if (!phy->set_txpower)
+		goto out;
+
+	mutex_lock(&phy->pib_lock);
+
+	rc = phy->set_txpower(phy, txpower);
+	if (rc < 0) {
+		mutex_unlock(&phy->pib_lock);
+		goto out;
+	}
+
+	phy->transmit_power = txpower;
+
+	mutex_unlock(&phy->pib_lock);
+
+	wpan_phy_put(phy);
+
+	return 0;
+
+out:
+	wpan_phy_put(phy);
+	return rc;
+}
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index 6adda4d..90b1d0d 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -52,5 +52,7 @@ const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_DURATION] = { .type = NLA_U8, },
 	[IEEE802154_ATTR_ED_LIST] = { .len = 27 },
 	[IEEE802154_ATTR_CHANNEL_PAGE_LIST] = { .len = 32 * 4, },
+
+	[IEEE802154_ATTR_TXPOWER] = { .type = NLA_S8, },
 };
 
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 4dd3761..8d6f670 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -44,9 +44,7 @@ static DEVICE_ATTR_RO(name);
 
 MASTER_SHOW(current_channel, "%d");
 MASTER_SHOW(current_page, "%d");
-MASTER_SHOW_COMPLEX(transmit_power, "%d +- %d dB",
-	((signed char) (phy->transmit_power << 2)) >> 2,
-	(phy->transmit_power >> 6) ? (phy->transmit_power >> 6) * 3 : 1);
+MASTER_SHOW(transmit_power, "%d +- 1 dB");
 MASTER_SHOW(cca_mode, "%d");
 
 static ssize_t channels_supported_show(struct device *dev,
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 52ae664..9eb49e0 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -165,6 +165,16 @@ err:
 	return ERR_PTR(err);
 }
 
+static int mac802154_set_txpower(struct wpan_phy *phy, int db)
+{
+	struct mac802154_priv *priv = wpan_phy_priv(phy);
+
+	if (!priv->ops->set_txpower)
+		return -ENOTSUPP;
+
+	return priv->ops->set_txpower(&priv->hw, db);
+}
+
 struct ieee802154_dev *
 ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 {
@@ -242,6 +252,7 @@ int ieee802154_register_device(struct ieee802154_dev *dev)
 
 	priv->phy->add_iface = mac802154_add_iface;
 	priv->phy->del_iface = mac802154_del_iface;
+	priv->phy->set_txpower = mac802154_set_txpower;
 
 	rc = wpan_phy_register(priv->phy);
 	if (rc < 0)
-- 
1.8.5.4
