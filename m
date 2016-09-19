From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next 2/2] openvswitch: avoid resetting flow key while installing new flow.
Date: Mon, 19 Sep 2016 13:51:00 -0700
Message-ID: <1474318260-16988-2-git-send-email-pshelar@ovn.org>
References: <1474318260-16988-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:33639 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbcISUvX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 16:51:23 -0400
In-Reply-To: <1474318260-16988-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since commit commit db74a3335e0f6 ("openvswitch: use percpu
flow stats") flow alloc resets flow-key. So there is no need
to reset the flow-key again if OVS is using newly allocated
flow-key.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/datapath.c     | 8 ++++----
 net/openvswitch/flow.c         | 2 --
 net/openvswitch/flow_netlink.c | 6 ++++--
 net/openvswitch/flow_netlink.h | 3 ++-
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 474e7a6..4d67ea8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -955,7 +955,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	/* Extract key. */
-	ovs_match_init(&match, &new_flow->key, &mask);
+	ovs_match_init(&match, &new_flow->key, false, &mask);
 	error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
 				  a[OVS_FLOW_ATTR_MASK], log);
 	if (error)
@@ -1124,7 +1124,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
 	ufid_present = ovs_nla_get_ufid(&sfid, a[OVS_FLOW_ATTR_UFID], log);
 	if (a[OVS_FLOW_ATTR_KEY]) {
-		ovs_match_init(&match, &key, &mask);
+		ovs_match_init(&match, &key, true, &mask);
 		error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
 					  a[OVS_FLOW_ATTR_MASK], log);
 	} else if (!ufid_present) {
@@ -1241,7 +1241,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 
 	ufid_present = ovs_nla_get_ufid(&ufid, a[OVS_FLOW_ATTR_UFID], log);
 	if (a[OVS_FLOW_ATTR_KEY]) {
-		ovs_match_init(&match, &key, NULL);
+		ovs_match_init(&match, &key, true, NULL);
 		err = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY], NULL,
 					log);
 	} else if (!ufid_present) {
@@ -1300,7 +1300,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 
 	ufid_present = ovs_nla_get_ufid(&ufid, a[OVS_FLOW_ATTR_UFID], log);
 	if (a[OVS_FLOW_ATTR_KEY]) {
-		ovs_match_init(&match, &key, NULL);
+		ovs_match_init(&match, &key, true, NULL);
 		err = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
 					NULL, log);
 		if (unlikely(err))
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 0fa45439..634cc10 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -767,8 +767,6 @@ int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 {
 	int err;
 
-	memset(key, 0, OVS_SW_FLOW_KEY_METADATA_SIZE);
-
 	/* Extract metadata from netlink attributes. */
 	err = ovs_nla_get_flow_metadata(net, attr, key, log);
 	if (err)
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 8efa718..ae25ded 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1996,13 +1996,15 @@ static int validate_and_copy_sample(struct net *net, const struct nlattr *attr,
 
 void ovs_match_init(struct sw_flow_match *match,
 		    struct sw_flow_key *key,
+		    bool reset_key,
 		    struct sw_flow_mask *mask)
 {
 	memset(match, 0, sizeof(*match));
 	match->key = key;
 	match->mask = mask;
 
-	memset(key, 0, sizeof(*key));
+	if (reset_key)
+		memset(key, 0, sizeof(*key));
 
 	if (mask) {
 		memset(&mask->key, 0, sizeof(mask->key));
@@ -2049,7 +2051,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	struct nlattr *a;
 	int err = 0, start, opts_type;
 
-	ovs_match_init(&match, &key, NULL);
+	ovs_match_init(&match, &key, true, NULL);
 	opts_type = ip_tun_from_nlattr(nla_data(attr), &match, false, log);
 	if (opts_type < 0)
 		return opts_type;
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 47dd142..45f9769 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -41,7 +41,8 @@ size_t ovs_tun_key_attr_size(void);
 size_t ovs_key_attr_size(void);
 
 void ovs_match_init(struct sw_flow_match *match,
-		    struct sw_flow_key *key, struct sw_flow_mask *mask);
+		    struct sw_flow_key *key, bool reset_key,
+		    struct sw_flow_mask *mask);
 
 int ovs_nla_put_key(const struct sw_flow_key *, const struct sw_flow_key *,
 		    int attr, bool is_mask, struct sk_buff *);
-- 
1.9.1
