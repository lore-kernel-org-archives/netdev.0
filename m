From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 08/14] openvswitch: Allocate & attach ip_tunnel_info for tunnel set action
Date: Mon,  1 Jun 2015 16:27:32 +0200
Message-ID: <13ac5a4837771ff2f52aa685f526b04c1ed76b86.1433167296.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51019 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbbFAO1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:51 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the new skb tunnel metadata field by allocating a
ip_tunnel_info per OVS tunnel set action and then attaching that
metadata to each skb that passes the set action.

The old egress_tun_info via the OVS_CB() is left in place until
all tunnel vports have been converted to the new method.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c      |  8 +++++-
 net/openvswitch/datapath.c     |  8 +++---
 net/openvswitch/flow.h         |  5 ++++
 net/openvswitch/flow_netlink.c | 59 +++++++++++++++++++++++++++++++++++++-----
 net/openvswitch/flow_netlink.h |  1 +
 5 files changed, 69 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 34cad57..484d965 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -726,7 +726,13 @@ static int execute_set_action(struct sk_buff *skb,
 {
 	/* Only tunnel set execution is supported without a mask. */
 	if (nla_type(a) == OVS_KEY_ATTR_TUNNEL_INFO) {
-		OVS_CB(skb)->egress_tun_info = nla_data(a);
+		struct ovs_tunnel_info *tun = nla_data(a);
+
+		skb_attach_tunnel_info(skb, tun->info);
+
+		/* FIXME: Remove when all vports have been converted */
+		OVS_CB(skb)->egress_tun_info = tun->info;
+
 		return 0;
 	}
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 3b90461..3315e3a 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1004,7 +1004,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		}
 		ovs_unlock();
 
-		ovs_nla_free_flow_actions(old_acts);
+		ovs_nla_free_flow_actions_rcu(old_acts);
 		ovs_flow_free(new_flow, false);
 	}
 
@@ -1016,7 +1016,7 @@ err_unlock_ovs:
 	ovs_unlock();
 	kfree_skb(reply);
 err_kfree_acts:
-	kfree(acts);
+	ovs_nla_free_flow_actions(acts);
 err_kfree_flow:
 	ovs_flow_free(new_flow, false);
 error:
@@ -1143,7 +1143,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	if (reply)
 		ovs_notify(&dp_flow_genl_family, reply, info);
 	if (old_acts)
-		ovs_nla_free_flow_actions(old_acts);
+		ovs_nla_free_flow_actions_rcu(old_acts);
 
 	return 0;
 
@@ -1151,7 +1151,7 @@ err_unlock_ovs:
 	ovs_unlock();
 	kfree_skb(reply);
 err_kfree_acts:
-	kfree(acts);
+	ovs_nla_free_flow_actions(acts);
 error:
 	return error;
 }
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index cadc6c5..193eab9 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -45,6 +45,11 @@ struct sk_buff;
 #define TUN_METADATA_OPTS(flow_key, opt_len) \
 	((void *)((flow_key)->tun_opts + TUN_METADATA_OFFSET(opt_len)))
 
+struct ovs_tunnel_info
+{
+	struct ip_tunnel_info	*info;
+};
+
 #define OVS_SW_FLOW_KEY_METADATA_SIZE			\
 	(offsetof(struct sw_flow_key, recirc_id) +	\
 	FIELD_SIZEOF(struct sw_flow_key, recirc_id))
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index ecfa530..35086c6 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1548,11 +1548,45 @@ static struct sw_flow_actions *nla_alloc_flow_actions(int size, bool log)
 	return sfa;
 }
 
+static void ovs_nla_free_set_action(const struct nlattr *a)
+{
+	const struct nlattr *ovs_key = nla_data(a);
+	struct ovs_tunnel_info *ovs_tun;
+
+	switch (nla_type(ovs_key)) {
+	case OVS_KEY_ATTR_TUNNEL_INFO:
+		ovs_tun = nla_data(ovs_key);
+		ip_tunnel_info_put(ovs_tun->info);
+		break;
+	}
+}
+
+void ovs_nla_free_flow_actions(struct sw_flow_actions *sf_acts)
+{
+	const struct nlattr *a;
+	int rem;
+
+	nla_for_each_attr(a, sf_acts->actions, sf_acts->actions_len, rem) {
+		switch (nla_type(a)) {
+		case OVS_ACTION_ATTR_SET:
+			ovs_nla_free_set_action(a);
+			break;
+		}
+	}
+
+	kfree(sf_acts);
+}
+
+static void __ovs_nla_free_flow_actions(struct rcu_head *head)
+{
+	ovs_nla_free_flow_actions(container_of(head, struct sw_flow_actions, rcu));
+}
+
 /* Schedules 'sf_acts' to be freed after the next RCU grace period.
  * The caller must hold rcu_read_lock for this to be sensible. */
-void ovs_nla_free_flow_actions(struct sw_flow_actions *sf_acts)
+void ovs_nla_free_flow_actions_rcu(struct sw_flow_actions *sf_acts)
 {
-	kfree_rcu(sf_acts, rcu);
+	call_rcu(&sf_acts->rcu, __ovs_nla_free_flow_actions);
 }
 
 static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa,
@@ -1747,6 +1781,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	struct sw_flow_match match;
 	struct sw_flow_key key;
 	struct ip_tunnel_info *tun_info;
+	struct ovs_tunnel_info *ovs_tun;
 	struct nlattr *a;
 	int err = 0, start, opts_type;
 
@@ -1771,12 +1806,21 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	if (start < 0)
 		return start;
 
+	tun_info = ip_tunnel_info_alloc(key.tun_opts_len, GFP_KERNEL);
+	if (!tun_info)
+		return -ENOMEM;
+
+	ip_tunnel_info_get(tun_info);
 	a = __add_action(sfa, OVS_KEY_ATTR_TUNNEL_INFO, NULL,
-			 sizeof(*tun_info) + key.tun_opts_len, log);
-	if (IS_ERR(a))
+			 sizeof(*ovs_tun), log);
+	if (IS_ERR(a)) {
+		ip_tunnel_info_put(tun_info);
 		return PTR_ERR(a);
+	}
 
-	tun_info = nla_data(a);
+	ovs_tun = nla_data(a);
+	ovs_tun->info = tun_info;
+	tun_info->mode = IP_TUNNEL_INFO_TX;
 	tun_info->key = key.tun_key;
 	tun_info->options_len = key.tun_opts_len;
 
@@ -2177,7 +2221,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 	err = __ovs_nla_copy_actions(attr, key, 0, sfa, key->eth.type,
 				     key->eth.tci, log);
 	if (err)
-		kfree(*sfa);
+		ovs_nla_free_flow_actions(*sfa);
 
 	return err;
 }
@@ -2227,7 +2271,8 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 
 	switch (key_type) {
 	case OVS_KEY_ATTR_TUNNEL_INFO: {
-		struct ip_tunnel_info *tun_info = nla_data(ovs_key);
+		struct ovs_tunnel_info *ovs_tun = nla_data(ovs_key);
+		struct ip_tunnel_info *tun_info = ovs_tun->info;
 
 		start = nla_nest_start(skb, OVS_ACTION_ATTR_SET);
 		if (!start)
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index ec53eb6..acd0744 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -69,5 +69,6 @@ int ovs_nla_put_actions(const struct nlattr *attr,
 			int len, struct sk_buff *skb);
 
 void ovs_nla_free_flow_actions(struct sw_flow_actions *);
+void ovs_nla_free_flow_actions_rcu(struct sw_flow_actions *);
 
 #endif /* flow_netlink.h */
-- 
2.3.5
