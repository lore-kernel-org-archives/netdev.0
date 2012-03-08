From: pablo@netfilter.org
Subject: [PATCH 09/23] netfilter: ctnetlink: allow to set expectfn for expectations
Date: Thu,  8 Mar 2012 02:00:58 +0100
Message-ID: <1331168472-5820-10-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch allows you to set expectfn which is specifically used
by the NAT side of most of the existing conntrack helpers.

I have added a symbol map that uses a string as key to look up for
the function that is attached to the expectation object. This is
the best solution I came out with to solve this issue.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 include/net/netfilter/nf_conntrack_helper.h   |   13 ++++++
 net/ipv4/netfilter/nf_nat_core.c              |    8 ++++
 net/ipv4/netfilter/nf_nat_h323.c              |   14 ++++++
 net/ipv4/netfilter/nf_nat_sip.c               |    7 +++
 net/netfilter/nf_conntrack_helper.c           |   54 +++++++++++++++++++++++++
 net/netfilter/nf_conntrack_netlink.c          |   19 ++++++++-
 7 files changed, 115 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index a2f1f48..e58e4b9 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -175,6 +175,7 @@ enum ctattr_expect {
 	CTA_EXPECT_FLAGS,
 	CTA_EXPECT_CLASS,
 	CTA_EXPECT_NAT,
+	CTA_EXPECT_FN,
 	__CTA_EXPECT_MAX
 };
 #define CTA_EXPECT_MAX (__CTA_EXPECT_MAX - 1)
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index f1c1311..5767dc2 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -69,4 +69,17 @@ extern int nf_conntrack_broadcast_help(struct sk_buff *skb,
 				       enum ip_conntrack_info ctinfo,
 				       unsigned int timeout);
 
+struct nf_ct_helper_expectfn {
+	struct list_head head;
+	const char *name;
+	void (*expectfn)(struct nf_conn *ct, struct nf_conntrack_expect *exp);
+};
+
+void nf_ct_helper_expectfn_register(struct nf_ct_helper_expectfn *n);
+void nf_ct_helper_expectfn_unregister(struct nf_ct_helper_expectfn *n);
+struct nf_ct_helper_expectfn *
+nf_ct_helper_expectfn_find_by_name(const char *name);
+struct nf_ct_helper_expectfn *
+nf_ct_helper_expectfn_find_by_symbol(const void *symbol);
+
 #endif /*_NF_CONNTRACK_HELPER_H*/
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index a708933..abb52ad 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -686,6 +686,11 @@ static struct pernet_operations nf_nat_net_ops = {
 	.exit = nf_nat_net_exit,
 };
 
+static struct nf_ct_helper_expectfn follow_master_nat = {
+	.name		= "nat-follow-master",
+	.expectfn	= nf_nat_follow_master,
+};
+
 static int __init nf_nat_init(void)
 {
 	size_t i;
@@ -717,6 +722,8 @@ static int __init nf_nat_init(void)
 
 	l3proto = nf_ct_l3proto_find_get((u_int16_t)AF_INET);
 
+	nf_ct_helper_expectfn_register(&follow_master_nat);
+
 	BUG_ON(nf_nat_seq_adjust_hook != NULL);
 	RCU_INIT_POINTER(nf_nat_seq_adjust_hook, nf_nat_seq_adjust);
 	BUG_ON(nfnetlink_parse_nat_setup_hook != NULL);
@@ -736,6 +743,7 @@ static void __exit nf_nat_cleanup(void)
 	unregister_pernet_subsys(&nf_nat_net_ops);
 	nf_ct_l3proto_put(l3proto);
 	nf_ct_extend_unregister(&nat_extend);
+	nf_ct_helper_expectfn_unregister(&follow_master_nat);
 	RCU_INIT_POINTER(nf_nat_seq_adjust_hook, NULL);
 	RCU_INIT_POINTER(nfnetlink_parse_nat_setup_hook, NULL);
 	RCU_INIT_POINTER(nf_ct_nat_offset, NULL);
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index dc1dd91..8253670 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -568,6 +568,16 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 	return 0;
 }
 
+static struct nf_ct_helper_expectfn q931_nat = {
+	.name		= "Q.931",
+	.expectfn	= ip_nat_q931_expect,
+};
+
+static struct nf_ct_helper_expectfn callforwarding_nat = {
+	.name		= "callforwarding",
+	.expectfn	= ip_nat_callforwarding_expect,
+};
+
 /****************************************************************************/
 static int __init init(void)
 {
@@ -590,6 +600,8 @@ static int __init init(void)
 	RCU_INIT_POINTER(nat_h245_hook, nat_h245);
 	RCU_INIT_POINTER(nat_callforwarding_hook, nat_callforwarding);
 	RCU_INIT_POINTER(nat_q931_hook, nat_q931);
+	nf_ct_helper_expectfn_register(&q931_nat);
+	nf_ct_helper_expectfn_register(&callforwarding_nat);
 	return 0;
 }
 
@@ -605,6 +617,8 @@ static void __exit fini(void)
 	RCU_INIT_POINTER(nat_h245_hook, NULL);
 	RCU_INIT_POINTER(nat_callforwarding_hook, NULL);
 	RCU_INIT_POINTER(nat_q931_hook, NULL);
+	nf_ct_helper_expectfn_unregister(&q931_nat);
+	nf_ct_helper_expectfn_unregister(&callforwarding_nat);
 	synchronize_rcu();
 }
 
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index d0319f9..57932c4 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -526,6 +526,11 @@ err1:
 	return NF_DROP;
 }
 
+static struct nf_ct_helper_expectfn sip_nat = {
+        .name           = "sip",
+        .expectfn       = ip_nat_sip_expected,
+};
+
 static void __exit nf_nat_sip_fini(void)
 {
 	RCU_INIT_POINTER(nf_nat_sip_hook, NULL);
@@ -535,6 +540,7 @@ static void __exit nf_nat_sip_fini(void)
 	RCU_INIT_POINTER(nf_nat_sdp_port_hook, NULL);
 	RCU_INIT_POINTER(nf_nat_sdp_session_hook, NULL);
 	RCU_INIT_POINTER(nf_nat_sdp_media_hook, NULL);
+	nf_ct_helper_expectfn_unregister(&sip_nat);
 	synchronize_rcu();
 }
 
@@ -554,6 +560,7 @@ static int __init nf_nat_sip_init(void)
 	RCU_INIT_POINTER(nf_nat_sdp_port_hook, ip_nat_sdp_port);
 	RCU_INIT_POINTER(nf_nat_sdp_session_hook, ip_nat_sdp_session);
 	RCU_INIT_POINTER(nf_nat_sdp_media_hook, ip_nat_sdp_media);
+	nf_ct_helper_expectfn_register(&sip_nat);
 	return 0;
 }
 
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index bbe23ba..436b7cb 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -181,6 +181,60 @@ void nf_ct_helper_destroy(struct nf_conn *ct)
 	}
 }
 
+static LIST_HEAD(nf_ct_helper_expectfn_list);
+
+void nf_ct_helper_expectfn_register(struct nf_ct_helper_expectfn *n)
+{
+	spin_lock_bh(&nf_conntrack_lock);
+	list_add_rcu(&n->head, &nf_ct_helper_expectfn_list);
+	spin_unlock_bh(&nf_conntrack_lock);
+}
+EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_register);
+
+void nf_ct_helper_expectfn_unregister(struct nf_ct_helper_expectfn *n)
+{
+	spin_lock_bh(&nf_conntrack_lock);
+	list_del_rcu(&n->head);
+	spin_unlock_bh(&nf_conntrack_lock);
+}
+EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_unregister);
+
+struct nf_ct_helper_expectfn *
+nf_ct_helper_expectfn_find_by_name(const char *name)
+{
+	struct nf_ct_helper_expectfn *cur;
+	bool found = false;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(cur, &nf_ct_helper_expectfn_list, head) {
+		if (!strcmp(cur->name, name)) {
+			found = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return found ? cur : NULL;
+}
+EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_find_by_name);
+
+struct nf_ct_helper_expectfn *
+nf_ct_helper_expectfn_find_by_symbol(const void *symbol)
+{
+	struct nf_ct_helper_expectfn *cur;
+	bool found = false;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(cur, &nf_ct_helper_expectfn_list, head) {
+		if (cur->expectfn == symbol) {
+			found = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return found ? cur : NULL;
+}
+EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_find_by_symbol);
+
 int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 {
 	unsigned int h = helper_hash(&me->tuple);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 845c8ca..b8827e8 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1679,6 +1679,8 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 	struct nlattr *nest_parms;
 	struct nf_conntrack_tuple nat_tuple = {};
 #endif
+	struct nf_ct_helper_expectfn *expfn;
+
 	if (timeout < 0)
 		timeout = 0;
 
@@ -1722,6 +1724,9 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 		if (helper)
 			NLA_PUT_STRING(skb, CTA_EXPECT_HELP_NAME, helper->name);
 	}
+	expfn = nf_ct_helper_expectfn_find_by_symbol(exp->expectfn);
+	if (expfn != NULL)
+		NLA_PUT_STRING(skb, CTA_EXPECT_FN, expfn->name);
 
 	return 0;
 
@@ -1881,6 +1886,7 @@ static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
 	[CTA_EXPECT_FLAGS]	= { .type = NLA_U32 },
 	[CTA_EXPECT_CLASS]	= { .type = NLA_U32 },
 	[CTA_EXPECT_NAT]	= { .type = NLA_NESTED },
+	[CTA_EXPECT_FN]		= { .type = NLA_NUL_STRING },
 };
 
 static int
@@ -2182,9 +2188,20 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 		} else
 			exp->flags = 0;
 	}
+	if (cda[CTA_EXPECT_FN]) {
+		const char *name = nla_data(cda[CTA_EXPECT_FN]);
+		struct nf_ct_helper_expectfn *expfn;
+
+		expfn = nf_ct_helper_expectfn_find_by_name(name);
+		if (expfn == NULL) {
+			err = -EINVAL;
+			goto err_out;
+		}
+		exp->expectfn = expfn->expectfn;
+	} else
+		exp->expectfn = NULL;
 
 	exp->class = class;
-	exp->expectfn = NULL;
 	exp->master = ct;
 	exp->helper = helper;
 	memcpy(&exp->tuple, &tuple, sizeof(struct nf_conntrack_tuple));
-- 
1.7.7.3

