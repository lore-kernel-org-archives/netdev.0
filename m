From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH net-next v4 5/5] netlink: pass extended ACK struct where available
Date: Tue, 11 Apr 2017 08:57:00 +0200
Message-ID: <20170411065700.2623-6-johannes@sipsolutions.net>
References: <20170411065700.2623-1-johannes@sipsolutions.net>
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>, jiri@resnulli.us,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47308 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753174AbdDKG5J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 02:57:09 -0400
In-Reply-To: <20170411065700.2623-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

This is an add-on to the previous patch that passes
the extended ACK structure where it's already available
by existing genl_info or extack function arguments.

This was done with this spatch (with some manual
adjustment of indentation):

@@
expression A, B, C, D, E;
identifier fn, info;
@@
fn(..., struct genl_info *info, ...) {
...
-nlmsg_parse(A, B, C, D, E, NULL)
+nlmsg_parse(A, B, C, D, E, info->extack)
...
}

@@
expression A, B, C, D, E;
identifier fn, info;
@@
fn(..., struct genl_info *info, ...) {
<...
-nla_parse_nested(A, B, C, D, NULL)
+nla_parse_nested(A, B, C, D, info->extack)
...>
}

@@
expression A, B, C, D, E;
identifier fn, extack;
@@
fn(..., struct netlink_ext_ack *extack, ...) {
<...
-nlmsg_parse(A, B, C, D, E, NULL)
+nlmsg_parse(A, B, C, D, E, extack)
...>
}

@@
expression A, B, C, D, E;
identifier fn, extack;
@@
fn(..., struct netlink_ext_ack *extack, ...) {
<...
-nla_parse(A, B, C, D, E, NULL)
+nla_parse(A, B, C, D, E, extack)
...>
}

@@
expression A, B, C, D, E;
identifier fn, extack;
@@
fn(..., struct netlink_ext_ack *extack, ...) {
...
-nlmsg_parse(A, B, C, D, E, NULL)
+nlmsg_parse(A, B, C, D, E, extack)
...
}

@@
expression A, B, C, D;
identifier fn, extack;
@@
fn(..., struct netlink_ext_ack *extack, ...) {
<...
-nla_parse_nested(A, B, C, D, NULL)
+nla_parse_nested(A, B, C, D, extack)
...>
}

@@
expression A, B, C, D;
identifier fn, extack;
@@
fn(..., struct netlink_ext_ack *extack, ...) {
<...
-nlmsg_validate(A, B, C, D, NULL)
+nlmsg_validate(A, B, C, D, extack)
...>
}

@@
expression A, B, C, D;
identifier fn, extack;
@@
fn(..., struct netlink_ext_ack *extack, ...) {
<...
-nla_validate(A, B, C, D, NULL)
+nla_validate(A, B, C, D, extack)
...>
}

@@
expression A, B, C;
identifier fn, extack;
@@
fn(..., struct netlink_ext_ack *extack, ...) {
<...
-nla_validate_nested(A, B, C, NULL)
+nla_validate_nested(A, B, C, extack)
...>
}

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 crypto/crypto_user.c           |  2 +-
 drivers/net/team/team.c        |  3 ++-
 net/ieee802154/nl802154.c      | 10 +++++-----
 net/netfilter/ipvs/ip_vs_ctl.c |  2 +-
 net/netfilter/nfnetlink.c      |  2 +-
 net/netlink/genetlink.c        |  2 +-
 net/nfc/netlink.c              |  2 +-
 net/tipc/bearer.c              | 14 +++++++-------
 net/tipc/net.c                 |  2 +-
 net/tipc/node.c                |  8 ++++----
 net/wireless/nl80211.c         | 33 ++++++++++++++++++---------------
 net/xfrm/xfrm_user.c           |  2 +-
 12 files changed, 43 insertions(+), 39 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index fc79906c1fe7..b5758768920b 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -523,7 +523,7 @@ static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	err = nlmsg_parse(nlh, crypto_msg_min[type], attrs, CRYPTOCFGA_MAX,
-			  crypto_policy, NULL);
+			  crypto_policy, extack);
 	if (err < 0)
 		return err;
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 86f227124ba1..65c056e2f705 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2471,7 +2471,8 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 			goto team_put;
 		}
 		err = nla_parse_nested(opt_attrs, TEAM_ATTR_OPTION_MAX,
-				       nl_option, team_nl_option_policy, NULL);
+				       nl_option, team_nl_option_policy,
+				       info->extack);
 		if (err)
 			goto team_put;
 		if (!opt_attrs[TEAM_ATTR_OPTION_NAME] ||
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index d6b1a1b21909..99f6c254ea77 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -1564,7 +1564,7 @@ static int nl802154_add_llsec_key(struct sk_buff *skb, struct genl_info *info)
 
 	if (nla_parse_nested(attrs, NL802154_KEY_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_KEY],
-			     nl802154_key_policy, NULL))
+			     nl802154_key_policy, info->extack))
 		return -EINVAL;
 
 	if (!attrs[NL802154_KEY_ATTR_USAGE_FRAMES] ||
@@ -1614,7 +1614,7 @@ static int nl802154_del_llsec_key(struct sk_buff *skb, struct genl_info *info)
 
 	if (nla_parse_nested(attrs, NL802154_KEY_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_KEY],
-			     nl802154_key_policy, NULL))
+			     nl802154_key_policy, info->extack))
 		return -EINVAL;
 
 	if (ieee802154_llsec_parse_key_id(attrs[NL802154_KEY_ATTR_ID], &id) < 0)
@@ -1782,7 +1782,7 @@ static int nl802154_del_llsec_dev(struct sk_buff *skb, struct genl_info *info)
 
 	if (nla_parse_nested(attrs, NL802154_DEV_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_DEVICE],
-			     nl802154_dev_policy, NULL))
+			     nl802154_dev_policy, info->extack))
 		return -EINVAL;
 
 	if (!attrs[NL802154_DEV_ATTR_EXTENDED_ADDR])
@@ -1910,7 +1910,7 @@ static int nl802154_add_llsec_devkey(struct sk_buff *skb, struct genl_info *info
 	if (!info->attrs[NL802154_ATTR_SEC_DEVKEY] ||
 	    nla_parse_nested(attrs, NL802154_DEVKEY_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_DEVKEY],
-			     nl802154_devkey_policy, NULL) < 0)
+			     nl802154_devkey_policy, info->extack) < 0)
 		return -EINVAL;
 
 	if (!attrs[NL802154_DEVKEY_ATTR_FRAME_COUNTER] ||
@@ -1942,7 +1942,7 @@ static int nl802154_del_llsec_devkey(struct sk_buff *skb, struct genl_info *info
 
 	if (nla_parse_nested(attrs, NL802154_DEVKEY_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_DEVKEY],
-			     nl802154_devkey_policy, NULL))
+			     nl802154_devkey_policy, info->extack))
 		return -EINVAL;
 
 	if (!attrs[NL802154_DEVKEY_ATTR_EXTENDED_ADDR])
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index adb7ee142c5f..892da70866d6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3532,7 +3532,7 @@ static int ip_vs_genl_set_daemon(struct sk_buff *skb, struct genl_info *info)
 		if (!info->attrs[IPVS_CMD_ATTR_DAEMON] ||
 		    nla_parse_nested(daemon_attrs, IPVS_DAEMON_ATTR_MAX,
 				     info->attrs[IPVS_CMD_ATTR_DAEMON],
-				     ip_vs_daemon_policy, NULL))
+				     ip_vs_daemon_policy, info->extack))
 			goto out;
 
 		if (cmd == IPVS_CMD_NEW_DAEMON)
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 792def00a07d..e42f858b91d2 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -193,7 +193,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		__u8 subsys_id = NFNL_SUBSYS_ID(type);
 
 		err = nla_parse(cda, ss->cb[cb_id].attr_count, attr, attrlen,
-				ss->cb[cb_id].policy, NULL);
+				ss->cb[cb_id].policy, extack);
 		if (err < 0) {
 			rcu_read_unlock();
 			return err;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index ff6db5e66eb5..10f8b4cff40a 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -574,7 +574,7 @@ static int genl_family_rcv_msg(const struct genl_family *family,
 
 	if (attrbuf) {
 		err = nlmsg_parse(nlh, hdrlen, attrbuf, family->maxattr,
-				  ops->policy, NULL);
+				  ops->policy, extack);
 		if (err < 0)
 			goto out;
 	}
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index aca903c12671..529443acd3bc 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -1162,7 +1162,7 @@ static int nfc_genl_llc_sdreq(struct sk_buff *skb, struct genl_info *info)
 
 	nla_for_each_nested(attr, info->attrs[NFC_ATTR_LLC_SDP], rem) {
 		rc = nla_parse_nested(sdp_attrs, NFC_SDP_ATTR_MAX, attr,
-				      nfc_sdp_genl_policy, NULL);
+				      nfc_sdp_genl_policy, info->extack);
 
 		if (rc != 0) {
 			rc = -EINVAL;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 9b5c45f48f60..d174ee3254ee 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -802,7 +802,7 @@ int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy, NULL);
+			       tipc_nl_bearer_policy, info->extack);
 	if (err)
 		return err;
 
@@ -851,7 +851,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy, NULL);
+			       tipc_nl_bearer_policy, info->extack);
 	if (err)
 		return err;
 
@@ -891,7 +891,7 @@ int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy, NULL);
+			       tipc_nl_bearer_policy, info->extack);
 	if (err)
 		return err;
 
@@ -939,7 +939,7 @@ int tipc_nl_bearer_add(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy, NULL);
+			       tipc_nl_bearer_policy, info->extack);
 	if (err)
 		return err;
 
@@ -982,7 +982,7 @@ int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy, NULL);
+			       tipc_nl_bearer_policy, info->extack);
 	if (err)
 		return err;
 
@@ -1104,7 +1104,7 @@ int tipc_nl_media_get(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_MEDIA_MAX,
 			       info->attrs[TIPC_NLA_MEDIA],
-			       tipc_nl_media_policy, NULL);
+			       tipc_nl_media_policy, info->extack);
 	if (err)
 		return err;
 
@@ -1152,7 +1152,7 @@ int tipc_nl_media_set(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_MEDIA_MAX,
 			       info->attrs[TIPC_NLA_MEDIA],
-			       tipc_nl_media_policy, NULL);
+			       tipc_nl_media_policy, info->extack);
 
 	if (!attrs[TIPC_NLA_MEDIA_NAME])
 		return -EINVAL;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 836da66cd852..719c5924b638 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -212,7 +212,7 @@ int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_NET_MAX,
 			       info->attrs[TIPC_NLA_NET], tipc_nl_net_policy,
-			       NULL);
+			       info->extack);
 	if (err)
 		return err;
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 1dcde24c7053..01b1f077603e 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1608,7 +1608,7 @@ int tipc_nl_peer_rm(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_NET_MAX,
 			       info->attrs[TIPC_NLA_NET], tipc_nl_net_policy,
-			       NULL);
+			       info->extack);
 	if (err)
 		return err;
 
@@ -1774,7 +1774,7 @@ int tipc_nl_node_set_link(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_LINK_MAX,
 			       info->attrs[TIPC_NLA_LINK],
-			       tipc_nl_link_policy, NULL);
+			       tipc_nl_link_policy, info->extack);
 	if (err)
 		return err;
 
@@ -1902,7 +1902,7 @@ int tipc_nl_node_reset_link_stats(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_LINK_MAX,
 			       info->attrs[TIPC_NLA_LINK],
-			       tipc_nl_link_policy, NULL);
+			       tipc_nl_link_policy, info->extack);
 	if (err)
 		return err;
 
@@ -2042,7 +2042,7 @@ int tipc_nl_node_set_monitor(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_MON_MAX,
 			       info->attrs[TIPC_NLA_MON],
-			       tipc_nl_monitor_policy, NULL);
+			       tipc_nl_monitor_policy, info->extack);
 	if (err)
 		return err;
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index e7594a3a0ab6..f280357552b2 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -810,7 +810,8 @@ static int nl80211_parse_key_old(struct genl_info *info, struct key_parse *k)
 		int err = nla_parse_nested(kdt,
 					   NUM_NL80211_KEY_DEFAULT_TYPES - 1,
 					   info->attrs[NL80211_ATTR_KEY_DEFAULT_TYPES],
-					   nl80211_key_default_policy, NULL);
+					   nl80211_key_default_policy,
+					   info->extack);
 		if (err)
 			return err;
 
@@ -2308,7 +2309,8 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 				    rem_txq_params) {
 			result = nla_parse_nested(tb, NL80211_TXQ_ATTR_MAX,
 						  nl_txq_params,
-						  txq_params_policy, NULL);
+						  txq_params_policy,
+						  info->extack);
 			if (result)
 				return result;
 			result = parse_txq_params(tb, &txq_params);
@@ -3561,7 +3563,7 @@ static int nl80211_parse_tx_bitrate_mask(struct genl_info *info,
 		if (sband == NULL)
 			return -EINVAL;
 		err = nla_parse_nested(tb, NL80211_TXRATE_MAX, tx_rates,
-				       nl80211_txattr_policy, NULL);
+				       nl80211_txattr_policy, info->extack);
 		if (err)
 			return err;
 		if (tb[NL80211_TXRATE_LEGACY]) {
@@ -4101,7 +4103,7 @@ static int parse_station_flags(struct genl_info *info,
 		return 0;
 
 	if (nla_parse_nested(flags, NL80211_STA_FLAG_MAX, nla,
-			     sta_flags_policy, NULL))
+			     sta_flags_policy, info->extack))
 		return -EINVAL;
 
 	/*
@@ -4728,7 +4730,7 @@ static int nl80211_parse_sta_wme(struct genl_info *info,
 
 	nla = info->attrs[NL80211_ATTR_STA_WME];
 	err = nla_parse_nested(tb, NL80211_STA_WME_MAX, nla,
-			       nl80211_sta_wme_policy, NULL);
+			       nl80211_sta_wme_policy, info->extack);
 	if (err)
 		return err;
 
@@ -5853,7 +5855,7 @@ do {									    \
 		return -EINVAL;
 	if (nla_parse_nested(tb, NL80211_MESHCONF_ATTR_MAX,
 			     info->attrs[NL80211_ATTR_MESH_CONFIG],
-			     nl80211_meshconf_params_policy, NULL))
+			     nl80211_meshconf_params_policy, info->extack))
 		return -EINVAL;
 
 	/* This makes sure that there aren't more than 32 mesh config
@@ -6002,7 +6004,7 @@ static int nl80211_parse_mesh_setup(struct genl_info *info,
 		return -EINVAL;
 	if (nla_parse_nested(tb, NL80211_MESH_SETUP_ATTR_MAX,
 			     info->attrs[NL80211_ATTR_MESH_SETUP],
-			     nl80211_mesh_setup_params_policy, NULL))
+			     nl80211_mesh_setup_params_policy, info->extack))
 		return -EINVAL;
 
 	if (tb[NL80211_MESH_SETUP_ENABLE_VENDOR_SYNC])
@@ -6393,7 +6395,8 @@ static int nl80211_set_reg(struct sk_buff *skb, struct genl_info *info)
 	nla_for_each_nested(nl_reg_rule, info->attrs[NL80211_ATTR_REG_RULES],
 			    rem_reg_rules) {
 		r = nla_parse_nested(tb, NL80211_REG_RULE_ATTR_MAX,
-				     nl_reg_rule, reg_rule_policy, NULL);
+				     nl_reg_rule, reg_rule_policy,
+				     info->extack);
 		if (r)
 			goto bad_reg;
 		r = parse_reg_rule(tb, &rd->reg_rules[rule_idx]);
@@ -7435,7 +7438,7 @@ static int nl80211_channel_switch(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(csa_attrs, NL80211_ATTR_MAX,
 			       info->attrs[NL80211_ATTR_CSA_IES],
-			       nl80211_policy, NULL);
+			       nl80211_policy, info->extack);
 	if (err)
 		return err;
 
@@ -9533,7 +9536,7 @@ static int nl80211_set_cqm(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 
 	err = nla_parse_nested(attrs, NL80211_ATTR_CQM_MAX, cqm,
-			       nl80211_attr_cqm_policy, NULL);
+			       nl80211_attr_cqm_policy, info->extack);
 	if (err)
 		return err;
 
@@ -10126,7 +10129,7 @@ static int nl80211_set_wowlan(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(tb, MAX_NL80211_WOWLAN_TRIG,
 			       info->attrs[NL80211_ATTR_WOWLAN_TRIGGERS],
-			       nl80211_wowlan_policy, NULL);
+			       nl80211_wowlan_policy, info->extack);
 	if (err)
 		return err;
 
@@ -10209,7 +10212,7 @@ static int nl80211_set_wowlan(struct sk_buff *skb, struct genl_info *info)
 			u8 *mask_pat;
 
 			nla_parse_nested(pat_tb, MAX_NL80211_PKTPAT, pat,
-					 NULL, NULL);
+					 NULL, info->extack);
 			err = -EINVAL;
 			if (!pat_tb[NL80211_PKTPAT_MASK] ||
 			    !pat_tb[NL80211_PKTPAT_PATTERN])
@@ -10579,7 +10582,7 @@ static int nl80211_set_rekey_data(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(tb, MAX_NL80211_REKEY_DATA,
 			       info->attrs[NL80211_ATTR_REKEY_DATA],
-			       nl80211_rekey_policy, NULL);
+			       nl80211_rekey_policy, info->extack);
 	if (err)
 		return err;
 
@@ -10896,7 +10899,7 @@ static int nl80211_nan_add_func(struct sk_buff *skb,
 
 	err = nla_parse_nested(tb, NL80211_NAN_FUNC_ATTR_MAX,
 			       info->attrs[NL80211_ATTR_NAN_FUNC],
-			       nl80211_nan_func_policy, NULL);
+			       nl80211_nan_func_policy, info->extack);
 	if (err)
 		return err;
 
@@ -10993,7 +10996,7 @@ static int nl80211_nan_add_func(struct sk_buff *skb,
 
 		err = nla_parse_nested(srf_tb, NL80211_NAN_SRF_ATTR_MAX,
 				       tb[NL80211_NAN_FUNC_SRF],
-				       nl80211_nan_srf_policy, NULL);
+				       nl80211_nan_srf_policy, info->extack);
 		if (err)
 			goto out;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 0db72dd82c7e..b4c278af7ed5 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2489,7 +2489,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs,
 			  link->nla_max ? : XFRMA_MAX,
-			  link->nla_pol ? : xfrma_policy, NULL);
+			  link->nla_pol ? : xfrma_policy, extack);
 	if (err < 0)
 		return err;
 
-- 
2.11.0
