From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/5] genetlink: introduce and use genl_family_attrbuf()
Date: Mon, 24 Oct 2016 14:40:01 +0200
Message-ID: <1477312805-7110-2-git-send-email-johannes@sipsolutions.net>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51686 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935211AbcJXMkL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 08:40:11 -0400
In-Reply-To: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

This helper function allows family implementations to access
their family's attrbuf. This gets rid of the attrbuf usage
in families, and also adds locking validation, since it's not
valid to use the attrbuf with parallel_ops or outside of the
dumpit callback.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h   |  2 ++
 net/ieee802154/nl802154.c |  7 ++++---
 net/netlink/genetlink.c   | 19 ++++++++++++++++++
 net/nfc/netlink.c         |  9 ++++-----
 net/tipc/netlink.c        |  2 +-
 net/wireless/nl80211.c    | 51 +++++++++++++++++++++++------------------------
 6 files changed, 55 insertions(+), 35 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 8d4608ce8716..ef9defb3f5bc 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -73,6 +73,8 @@ struct genl_family {
 	struct module		*module;
 };
 
+struct nlattr **genl_family_attrbuf(struct genl_family *family);
+
 /**
  * struct genl_info - receiving information
  * @snd_seq: sending sequence number
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index d90a4ed5b8a0..21aabadccd0e 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -263,13 +263,14 @@ nl802154_prepare_wpan_dev_dump(struct sk_buff *skb,
 
 	if (!cb->args[0]) {
 		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl802154_fam.hdrsize,
-				  nl802154_fam.attrbuf, nl802154_fam.maxattr,
+				  genl_family_attrbuf(&nl802154_fam),
+				  nl802154_fam.maxattr,
 				  nl802154_policy);
 		if (err)
 			goto out_unlock;
 
 		*wpan_dev = __cfg802154_wpan_dev_from_attrs(sock_net(skb->sk),
-							    nl802154_fam.attrbuf);
+							    genl_family_attrbuf(&nl802154_fam));
 		if (IS_ERR(*wpan_dev)) {
 			err = PTR_ERR(*wpan_dev);
 			goto out_unlock;
@@ -575,7 +576,7 @@ static int nl802154_dump_wpan_phy_parse(struct sk_buff *skb,
 					struct netlink_callback *cb,
 					struct nl802154_dump_wpan_phy_state *state)
 {
-	struct nlattr **tb = nl802154_fam.attrbuf;
+	struct nlattr **tb = genl_family_attrbuf(&nl802154_fam);
 	int ret = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl802154_fam.hdrsize,
 			      tb, nl802154_fam.maxattr, nl802154_policy);
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 23cc12639ba7..01291b7a27bb 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -1096,6 +1096,25 @@ static int __init genl_init(void)
 
 subsys_initcall(genl_init);
 
+/**
+ * genl_family_attrbuf - return family's attrbuf
+ * @family: the family
+ *
+ * Return the family's attrbuf, while validating that it's
+ * actually valid to access it.
+ *
+ * You cannot use this function with a family that has parallel_ops
+ * and you can only use it within (pre/post) doit/dumpit callbacks.
+ */
+struct nlattr **genl_family_attrbuf(struct genl_family *family)
+{
+	if (!WARN_ON(family->parallel_ops))
+		lockdep_assert_held(&genl_mutex);
+
+	return family->attrbuf;
+}
+EXPORT_SYMBOL(genl_family_attrbuf);
+
 static int genlmsg_mcast(struct sk_buff *skb, u32 portid, unsigned long group,
 			 gfp_t flags)
 {
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index ea023b35f1c2..79786bf62b88 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -120,21 +120,20 @@ static int nfc_genl_send_target(struct sk_buff *msg, struct nfc_target *target,
 
 static struct nfc_dev *__get_device_from_cb(struct netlink_callback *cb)
 {
+	struct nlattr **attrbuf = genl_family_attrbuf(&nfc_genl_family);
 	struct nfc_dev *dev;
 	int rc;
 	u32 idx;
 
 	rc = nlmsg_parse(cb->nlh, GENL_HDRLEN + nfc_genl_family.hdrsize,
-			 nfc_genl_family.attrbuf,
-			 nfc_genl_family.maxattr,
-			 nfc_genl_policy);
+			 attrbuf, nfc_genl_family.maxattr, nfc_genl_policy);
 	if (rc < 0)
 		return ERR_PTR(rc);
 
-	if (!nfc_genl_family.attrbuf[NFC_ATTR_DEVICE_INDEX])
+	if (!attrbuf[NFC_ATTR_DEVICE_INDEX])
 		return ERR_PTR(-EINVAL);
 
-	idx = nla_get_u32(nfc_genl_family.attrbuf[NFC_ATTR_DEVICE_INDEX]);
+	idx = nla_get_u32(attrbuf[NFC_ATTR_DEVICE_INDEX]);
 
 	dev = nfc_get_device(idx);
 	if (!dev)
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 3200059d14b2..4b94f3cfe3af 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -262,7 +262,7 @@ int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***attr)
 {
 	u32 maxattr = tipc_genl_family.maxattr;
 
-	*attr = tipc_genl_family.attrbuf;
+	*attr = genl_family_attrbuf(&tipc_genl_family);
 	if (!*attr)
 		return -EOPNOTSUPP;
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index c510810f0b7c..7d8cb3330c86 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -551,13 +551,14 @@ static int nl80211_prepare_wdev_dump(struct sk_buff *skb,
 
 	if (!cb->args[0]) {
 		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
-				  nl80211_fam.attrbuf, nl80211_fam.maxattr,
-				  nl80211_policy);
+				  genl_family_attrbuf(&nl80211_fam),
+				  nl80211_fam.maxattr, nl80211_policy);
 		if (err)
 			goto out_unlock;
 
-		*wdev = __cfg80211_wdev_from_attrs(sock_net(skb->sk),
-						   nl80211_fam.attrbuf);
+		*wdev = __cfg80211_wdev_from_attrs(
+					sock_net(skb->sk),
+					genl_family_attrbuf(&nl80211_fam));
 		if (IS_ERR(*wdev)) {
 			err = PTR_ERR(*wdev);
 			goto out_unlock;
@@ -1881,7 +1882,7 @@ static int nl80211_dump_wiphy_parse(struct sk_buff *skb,
 				    struct netlink_callback *cb,
 				    struct nl80211_dump_wiphy_state *state)
 {
-	struct nlattr **tb = nl80211_fam.attrbuf;
+	struct nlattr **tb = genl_family_attrbuf(&nl80211_fam);
 	int ret = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
 			      tb, nl80211_fam.maxattr, nl80211_policy);
 	/* ignore parse errors for backward compatibility */
@@ -7643,6 +7644,7 @@ static int nl80211_send_survey(struct sk_buff *msg, u32 portid, u32 seq,
 
 static int nl80211_dump_survey(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct nlattr **attrbuf = genl_family_attrbuf(&nl80211_fam);
 	struct survey_info survey;
 	struct cfg80211_registered_device *rdev;
 	struct wireless_dev *wdev;
@@ -7655,7 +7657,7 @@ static int nl80211_dump_survey(struct sk_buff *skb, struct netlink_callback *cb)
 		return res;
 
 	/* prepare_wdev_dump parsed the attributes */
-	radio_stats = nl80211_fam.attrbuf[NL80211_ATTR_SURVEY_RADIO_STATS];
+	radio_stats = attrbuf[NL80211_ATTR_SURVEY_RADIO_STATS];
 
 	if (!wdev->netdev) {
 		res = -EINVAL;
@@ -8478,14 +8480,14 @@ static int nl80211_testmode_dump(struct sk_buff *skb,
 		 */
 		phy_idx = cb->args[0] - 1;
 	} else {
+		struct nlattr **attrbuf = genl_family_attrbuf(&nl80211_fam);
+
 		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
-				  nl80211_fam.attrbuf, nl80211_fam.maxattr,
-				  nl80211_policy);
+				  attrbuf, nl80211_fam.maxattr, nl80211_policy);
 		if (err)
 			goto out_err;
 
-		rdev = __cfg80211_rdev_from_attrs(sock_net(skb->sk),
-						  nl80211_fam.attrbuf);
+		rdev = __cfg80211_rdev_from_attrs(sock_net(skb->sk), attrbuf);
 		if (IS_ERR(rdev)) {
 			err = PTR_ERR(rdev);
 			goto out_err;
@@ -8493,9 +8495,8 @@ static int nl80211_testmode_dump(struct sk_buff *skb,
 		phy_idx = rdev->wiphy_idx;
 		rdev = NULL;
 
-		if (nl80211_fam.attrbuf[NL80211_ATTR_TESTDATA])
-			cb->args[1] =
-				(long)nl80211_fam.attrbuf[NL80211_ATTR_TESTDATA];
+		if (attrbuf[NL80211_ATTR_TESTDATA])
+			cb->args[1] = (long)attrbuf[NL80211_ATTR_TESTDATA];
 	}
 
 	if (cb->args[1]) {
@@ -11277,6 +11278,7 @@ static int nl80211_prepare_vendor_dump(struct sk_buff *skb,
 				       struct cfg80211_registered_device **rdev,
 				       struct wireless_dev **wdev)
 {
+	struct nlattr **attrbuf = genl_family_attrbuf(&nl80211_fam);
 	u32 vid, subcmd;
 	unsigned int i;
 	int vcmd_idx = -1;
@@ -11312,31 +11314,28 @@ static int nl80211_prepare_vendor_dump(struct sk_buff *skb,
 	}
 
 	err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
-			  nl80211_fam.attrbuf, nl80211_fam.maxattr,
-			  nl80211_policy);
+			  attrbuf, nl80211_fam.maxattr, nl80211_policy);
 	if (err)
 		goto out_unlock;
 
-	if (!nl80211_fam.attrbuf[NL80211_ATTR_VENDOR_ID] ||
-	    !nl80211_fam.attrbuf[NL80211_ATTR_VENDOR_SUBCMD]) {
+	if (!attrbuf[NL80211_ATTR_VENDOR_ID] ||
+	    !attrbuf[NL80211_ATTR_VENDOR_SUBCMD]) {
 		err = -EINVAL;
 		goto out_unlock;
 	}
 
-	*wdev = __cfg80211_wdev_from_attrs(sock_net(skb->sk),
-					   nl80211_fam.attrbuf);
+	*wdev = __cfg80211_wdev_from_attrs(sock_net(skb->sk), attrbuf);
 	if (IS_ERR(*wdev))
 		*wdev = NULL;
 
-	*rdev = __cfg80211_rdev_from_attrs(sock_net(skb->sk),
-					   nl80211_fam.attrbuf);
+	*rdev = __cfg80211_rdev_from_attrs(sock_net(skb->sk), attrbuf);
 	if (IS_ERR(*rdev)) {
 		err = PTR_ERR(*rdev);
 		goto out_unlock;
 	}
 
-	vid = nla_get_u32(nl80211_fam.attrbuf[NL80211_ATTR_VENDOR_ID]);
-	subcmd = nla_get_u32(nl80211_fam.attrbuf[NL80211_ATTR_VENDOR_SUBCMD]);
+	vid = nla_get_u32(attrbuf[NL80211_ATTR_VENDOR_ID]);
+	subcmd = nla_get_u32(attrbuf[NL80211_ATTR_VENDOR_SUBCMD]);
 
 	for (i = 0; i < (*rdev)->wiphy.n_vendor_commands; i++) {
 		const struct wiphy_vendor_command *vcmd;
@@ -11360,9 +11359,9 @@ static int nl80211_prepare_vendor_dump(struct sk_buff *skb,
 		goto out_unlock;
 	}
 
-	if (nl80211_fam.attrbuf[NL80211_ATTR_VENDOR_DATA]) {
-		data = nla_data(nl80211_fam.attrbuf[NL80211_ATTR_VENDOR_DATA]);
-		data_len = nla_len(nl80211_fam.attrbuf[NL80211_ATTR_VENDOR_DATA]);
+	if (attrbuf[NL80211_ATTR_VENDOR_DATA]) {
+		data = nla_data(attrbuf[NL80211_ATTR_VENDOR_DATA]);
+		data_len = nla_len(attrbuf[NL80211_ATTR_VENDOR_DATA]);
 	}
 
 	/* 0 is the first index - add 1 to parse only once */
-- 
2.8.1
