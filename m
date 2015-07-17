From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 17/22] fib: Add fib rule match on tunnel id
Date: Fri, 17 Jul 2015 14:55:36 +0200
Message-ID: <4cd149ae8fff85e949d29e60bf3d6d72f5ecfec0.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49662 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758015AbbGQM4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 08:56:07 -0400
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This add the ability to select a routing table based on the tunnel
id which allows to maintain separate routing tables for each virtual
tunnel network.

ip rule add from all tunnel-id 100 lookup 100
ip rule add from all tunnel-id 200 lookup 200

A new static key controls the collection of metadata at tunnel level
upon demand.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c            |  3 ++-
 include/net/fib_rules.h        |  1 +
 include/net/ip_tunnels.h       | 11 +++++++++++
 include/uapi/linux/fib_rules.h |  2 +-
 net/core/fib_rules.c           | 24 ++++++++++++++++++++++--
 net/ipv4/ip_tunnel_core.c      | 16 ++++++++++++++++
 6 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a350afb..23378db 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -143,7 +143,8 @@ static struct workqueue_struct *vxlan_wq;
 
 static inline bool vxlan_collect_metadata(struct vxlan_sock *vs)
 {
-	return vs->flags & VXLAN_F_COLLECT_METADATA;
+	return vs->flags & VXLAN_F_COLLECT_METADATA ||
+	       ip_tunnel_collect_metadata();
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 903a55e..4e8f804 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -19,6 +19,7 @@ struct fib_rule {
 	u8			action;
 	/* 3 bytes hole, try to use */
 	u32			target;
+	__be64			tun_id;
 	struct fib_rule __rcu	*ctarget;
 	struct net		*fr_net;
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 0b7e18c..0a5a776 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -303,6 +303,17 @@ static inline struct ip_tunnel_info *lwt_tun_info(struct lwtunnel_state *lwtstat
 	return (struct ip_tunnel_info *)lwtstate->data;
 }
 
+extern struct static_key ip_tunnel_metadata_cnt;
+
+/* Returns > 0 if metadata should be collected */
+static inline int ip_tunnel_collect_metadata(void)
+{
+	return static_key_false(&ip_tunnel_metadata_cnt);
+}
+
+void ip_tunnel_need_metadata(void);
+void ip_tunnel_unneed_metadata(void);
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 2b82d7e..96161b8 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -43,7 +43,7 @@ enum {
 	FRA_UNUSED5,
 	FRA_FWMARK,	/* mark */
 	FRA_FLOW,	/* flow/class id */
-	FRA_UNUSED6,
+	FRA_TUN_ID,
 	FRA_SUPPRESS_IFGROUP,
 	FRA_SUPPRESS_PREFIXLEN,
 	FRA_TABLE,	/* Extended table id */
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 9a12668..ae8306e 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -16,6 +16,7 @@
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <net/fib_rules.h>
+#include <net/ip_tunnels.h>
 
 int fib_default_rule_add(struct fib_rules_ops *ops,
 			 u32 pref, u32 table, u32 flags)
@@ -186,6 +187,9 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 	if ((rule->mark ^ fl->flowi_mark) & rule->mark_mask)
 		goto out;
 
+	if (rule->tun_id && (rule->tun_id != fl->flowi_tun_key.tun_id))
+		goto out;
+
 	ret = ops->match(rule, fl, flags);
 out:
 	return (rule->flags & FIB_RULE_INVERT) ? !ret : ret;
@@ -330,6 +334,9 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (tb[FRA_FWMASK])
 		rule->mark_mask = nla_get_u32(tb[FRA_FWMASK]);
 
+	if (tb[FRA_TUN_ID])
+		rule->tun_id = nla_get_be64(tb[FRA_TUN_ID]);
+
 	rule->action = frh->action;
 	rule->flags = frh->flags;
 	rule->table = frh_get_table(frh, tb);
@@ -407,6 +414,9 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (unresolved)
 		ops->unresolved_rules++;
 
+	if (rule->tun_id)
+		ip_tunnel_need_metadata();
+
 	notify_rule_change(RTM_NEWRULE, rule, ops, nlh, NETLINK_CB(skb).portid);
 	flush_route_cache(ops);
 	rules_ops_put(ops);
@@ -473,6 +483,10 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 		    (rule->mark_mask != nla_get_u32(tb[FRA_FWMASK])))
 			continue;
 
+		if (tb[FRA_TUN_ID] &&
+		    (rule->tun_id != nla_get_be64(tb[FRA_TUN_ID])))
+			continue;
+
 		if (!ops->compare(rule, frh, tb))
 			continue;
 
@@ -487,6 +501,9 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 				goto errout;
 		}
 
+		if (rule->tun_id)
+			ip_tunnel_unneed_metadata();
+
 		list_del_rcu(&rule->list);
 
 		if (rule->action == FR_ACT_GOTO) {
@@ -535,7 +552,8 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 			 + nla_total_size(4) /* FRA_SUPPRESS_PREFIXLEN */
 			 + nla_total_size(4) /* FRA_SUPPRESS_IFGROUP */
 			 + nla_total_size(4) /* FRA_FWMARK */
-			 + nla_total_size(4); /* FRA_FWMASK */
+			 + nla_total_size(4) /* FRA_FWMASK */
+			 + nla_total_size(8); /* FRA_TUN_ID */
 
 	if (ops->nlmsg_payload)
 		payload += ops->nlmsg_payload(rule);
@@ -591,7 +609,9 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	    ((rule->mark_mask || rule->mark) &&
 	     nla_put_u32(skb, FRA_FWMASK, rule->mark_mask)) ||
 	    (rule->target &&
-	     nla_put_u32(skb, FRA_GOTO, rule->target)))
+	     nla_put_u32(skb, FRA_GOTO, rule->target)) ||
+	    (rule->tun_id &&
+	     nla_put_be64(skb, FRA_TUN_ID, rule->tun_id)))
 		goto nla_put_failure;
 
 	if (rule->suppress_ifgroup != -1) {
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 025b76e..630e6d5 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -32,6 +32,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
+#include <linux/static_key.h>
 
 #include <net/ip.h>
 #include <net/icmp.h>
@@ -304,3 +305,18 @@ static void __exit ip_tunnel_core_exit(void)
 	lwtunnel_encap_del_ops(&ip_tun_lwt_ops, LWTUNNEL_ENCAP_IP);
 }
 module_exit(ip_tunnel_core_exit);
+
+struct static_key ip_tunnel_metadata_cnt = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL(ip_tunnel_metadata_cnt);
+
+void ip_tunnel_need_metadata(void)
+{
+	static_key_slow_inc(&ip_tunnel_metadata_cnt);
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_need_metadata);
+
+void ip_tunnel_unneed_metadata(void)
+{
+	static_key_slow_dec(&ip_tunnel_metadata_cnt);
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_unneed_metadata);
-- 
2.4.3
