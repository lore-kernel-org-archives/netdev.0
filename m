From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 18/22] openvswitch: Make tunnel set action attach a metadata dst
Date: Fri, 10 Jul 2015 16:19:20 +0200
Message-ID: <db45b60a2ab4aa0d6dde363558ebe3e46edb0e81.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40721 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667AbbGJOTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:49 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Utilize the new metadata dst to attach encapsulation instructions to
the skb. The existing egress_tun_info via the OVS_CB() is left in
place until all tunnel vports have been converted to the new method.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c      | 10 ++++++-
 net/openvswitch/datapath.c     |  8 +++---
 net/openvswitch/flow.h         |  6 +++++
 net/openvswitch/flow_netlink.c | 61 +++++++++++++++++++++++++++++++++++++-----
 net/openvswitch/flow_netlink.h |  1 +
 5 files changed, 74 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 27c1687..cf04c2f 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -733,7 +733,15 @@ static int execute_set_action(struct sk_buff *skb,
 {
 	/* Only tunnel set execution is supported without a mask. */
 	if (nla_type(a) == OVS_KEY_ATTR_TUNNEL_INFO) {
-		OVS_CB(skb)->egress_tun_info = nla_data(a);
+		struct ovs_tunnel_info *tun = nla_data(a);
+
+		skb_dst_drop(skb);
+		dst_hold((struct dst_entry *)tun->tun_dst);
+		skb_dst_set(skb, (struct dst_entry *)tun->tun_dst);
+
+		/* FIXME: Remove when all vports have been converted */
+		OVS_CB(skb)->egress_tun_info = &tun->tun_dst->u.tun_info;
+
 		return 0;
 	}
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ff8c4a4..0208210 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1018,7 +1018,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		}
 		ovs_unlock();
 
-		ovs_nla_free_flow_actions(old_acts);
+		ovs_nla_free_flow_actions_rcu(old_acts);
 		ovs_flow_free(new_flow, false);
 	}
 
@@ -1030,7 +1030,7 @@ err_unlock_ovs:
 	ovs_unlock();
 	kfree_skb(reply);
 err_kfree_acts:
-	kfree(acts);
+	ovs_nla_free_flow_actions(acts);
 err_kfree_flow:
 	ovs_flow_free(new_flow, false);
 error:
@@ -1157,7 +1157,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	if (reply)
 		ovs_notify(&dp_flow_genl_family, reply, info);
 	if (old_acts)
-		ovs_nla_free_flow_actions(old_acts);
+		ovs_nla_free_flow_actions_rcu(old_acts);
 
 	return 0;
 
@@ -1165,7 +1165,7 @@ err_unlock_ovs:
 	ovs_unlock();
 	kfree_skb(reply);
 err_kfree_acts:
-	kfree(acts);
+	ovs_nla_free_flow_actions(acts);
 error:
 	return error;
 }
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index cadc6c5..3fbf874 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -33,6 +33,7 @@
 #include <linux/flex_array.h>
 #include <net/inet_ecn.h>
 #include <net/ip_tunnels.h>
+#include <net/dst_metadata.h>
 
 struct sk_buff;
 
@@ -45,6 +46,11 @@ struct sk_buff;
 #define TUN_METADATA_OPTS(flow_key, opt_len) \
 	((void *)((flow_key)->tun_opts + TUN_METADATA_OFFSET(opt_len)))
 
+struct ovs_tunnel_info
+{
+	struct metadata_dst	*tun_dst;
+};
+
 #define OVS_SW_FLOW_KEY_METADATA_SIZE			\
 	(offsetof(struct sw_flow_key, recirc_id) +	\
 	FIELD_SIZEOF(struct sw_flow_key, recirc_id))
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index ecfa530..05fe46b 100644
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
+		dst_release((struct dst_entry *)ovs_tun->tun_dst);
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
@@ -1746,7 +1780,9 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 {
 	struct sw_flow_match match;
 	struct sw_flow_key key;
+	struct metadata_dst *tun_dst;
 	struct ip_tunnel_info *tun_info;
+	struct ovs_tunnel_info *ovs_tun;
 	struct nlattr *a;
 	int err = 0, start, opts_type;
 
@@ -1771,12 +1807,22 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	if (start < 0)
 		return start;
 
+	tun_dst = metadata_dst_alloc(key.tun_opts_len, GFP_KERNEL);
+	if (!tun_dst)
+		return -ENOMEM;
+
 	a = __add_action(sfa, OVS_KEY_ATTR_TUNNEL_INFO, NULL,
-			 sizeof(*tun_info) + key.tun_opts_len, log);
-	if (IS_ERR(a))
+			 sizeof(*ovs_tun), log);
+	if (IS_ERR(a)) {
+		dst_release((struct dst_entry *)tun_dst);
 		return PTR_ERR(a);
+	}
+
+	ovs_tun = nla_data(a);
+	ovs_tun->tun_dst = tun_dst;
 
-	tun_info = nla_data(a);
+	tun_info = &tun_dst->u.tun_info;
+	tun_info->mode = IP_TUNNEL_INFO_TX;
 	tun_info->key = key.tun_key;
 	tun_info->options_len = key.tun_opts_len;
 
@@ -2177,7 +2223,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 	err = __ovs_nla_copy_actions(attr, key, 0, sfa, key->eth.type,
 				     key->eth.tci, log);
 	if (err)
-		kfree(*sfa);
+		ovs_nla_free_flow_actions(*sfa);
 
 	return err;
 }
@@ -2227,7 +2273,8 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 
 	switch (key_type) {
 	case OVS_KEY_ATTR_TUNNEL_INFO: {
-		struct ip_tunnel_info *tun_info = nla_data(ovs_key);
+		struct ovs_tunnel_info *ovs_tun = nla_data(ovs_key);
+		struct ip_tunnel_info *tun_info = &ovs_tun->tun_dst->u.tun_info;
 
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
2.4.3
