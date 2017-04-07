From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC 3/3] nl80211: add a few extended error strings
Date: Fri,  7 Apr 2017 20:26:20 +0200
Message-ID: <20170407182620.6438-4-johannes@sipsolutions.net>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407182620.6438-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 net/wireless/nl80211.c | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 9910aae08f1a..8808099db909 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -740,7 +740,8 @@ struct key_parse {
 	bool def_uni, def_multi;
 };
 
-static int nl80211_parse_key_new(struct nlattr *key, struct key_parse *k)
+static int nl80211_parse_key_new(struct genl_info *info, struct nlattr *key,
+				 struct key_parse *k)
 {
 	struct nlattr *tb[NL80211_KEY_MAX + 1];
 	int err = nla_parse_nested(tb, NL80211_KEY_MAX, key,
@@ -777,7 +778,7 @@ static int nl80211_parse_key_new(struct nlattr *key, struct key_parse *k)
 	if (tb[NL80211_KEY_TYPE]) {
 		k->type = nla_get_u32(tb[NL80211_KEY_TYPE]);
 		if (k->type < 0 || k->type >= NUM_NL80211_KEYTYPES)
-			return -EINVAL;
+			return genl_err_attr(info, -EINVAL, NL80211_KEY_TYPE);
 	}
 
 	if (tb[NL80211_KEY_DEFAULT_TYPES]) {
@@ -855,7 +856,7 @@ static int nl80211_parse_key(struct genl_info *info, struct key_parse *k)
 	k->type = -1;
 
 	if (info->attrs[NL80211_ATTR_KEY])
-		err = nl80211_parse_key_new(info->attrs[NL80211_ATTR_KEY], k);
+		err = nl80211_parse_key_new(info, info->attrs[NL80211_ATTR_KEY], k);
 	else
 		err = nl80211_parse_key_old(info, k);
 
@@ -863,23 +864,27 @@ static int nl80211_parse_key(struct genl_info *info, struct key_parse *k)
 		return err;
 
 	if (k->def && k->defmgmt)
-		return -EINVAL;
+		return genl_err_str(info, -EINVAL, "def && defmgmt is invalid");
 
 	if (k->defmgmt) {
 		if (k->def_uni || !k->def_multi)
-			return -EINVAL;
+			return genl_err_str(info, -EINVAL,
+					    "defmgmt must be mcast");
 	}
 
 	if (k->idx != -1) {
 		if (k->defmgmt) {
 			if (k->idx < 4 || k->idx > 5)
-				return -EINVAL;
+				return genl_err_str(info, -EINVAL,
+						    "defmgmt key idx not 4 or 5");
 		} else if (k->def) {
 			if (k->idx < 0 || k->idx > 3)
-				return -EINVAL;
+				return genl_err_str(info, -EINVAL,
+						    "def key idx not 0-3");
 		} else {
 			if (k->idx < 0 || k->idx > 5)
-				return -EINVAL;
+				return genl_err_str(info, -EINVAL,
+						    "key idx not 0-5");
 		}
 	}
 
@@ -888,8 +893,9 @@ static int nl80211_parse_key(struct genl_info *info, struct key_parse *k)
 
 static struct cfg80211_cached_keys *
 nl80211_parse_connkeys(struct cfg80211_registered_device *rdev,
-		       struct nlattr *keys, bool *no_ht)
+		       struct genl_info *info, bool *no_ht)
 {
+	struct nlattr *keys = info->attrs[NL80211_ATTR_KEYS];
 	struct key_parse parse;
 	struct nlattr *key;
 	struct cfg80211_cached_keys *result;
@@ -914,7 +920,7 @@ nl80211_parse_connkeys(struct cfg80211_registered_device *rdev,
 		memset(&parse, 0, sizeof(parse));
 		parse.idx = -1;
 
-		err = nl80211_parse_key_new(key, &parse);
+		err = nl80211_parse_key_new(info, key, &parse);
 		if (err)
 			goto error;
 		err = -EINVAL;
@@ -8460,9 +8466,7 @@ static int nl80211_join_ibss(struct sk_buff *skb, struct genl_info *info)
 	if (ibss.privacy && info->attrs[NL80211_ATTR_KEYS]) {
 		bool no_ht = false;
 
-		connkeys = nl80211_parse_connkeys(rdev,
-					  info->attrs[NL80211_ATTR_KEYS],
-					  &no_ht);
+		connkeys = nl80211_parse_connkeys(rdev, info, &no_ht);
 		if (IS_ERR(connkeys))
 			return PTR_ERR(connkeys);
 
@@ -8853,8 +8857,7 @@ static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	if (connect.privacy && info->attrs[NL80211_ATTR_KEYS]) {
-		connkeys = nl80211_parse_connkeys(rdev,
-					  info->attrs[NL80211_ATTR_KEYS], NULL);
+		connkeys = nl80211_parse_connkeys(rdev, info, NULL);
 		if (IS_ERR(connkeys))
 			return PTR_ERR(connkeys);
 	}
-- 
2.11.0
