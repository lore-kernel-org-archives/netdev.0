From: pablo@netfilter.org
Subject: [PATCH 5/7] netfilter: nfnetlink: add mutex per subsystem
Date: Tue, 19 Feb 2013 01:10:49 +0100
Message-ID: <1361232651-5626-6-git-send-email-pablo@netfilter.org>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:33451 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757831Ab3BSALW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 19:11:22 -0500
In-Reply-To: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch replaces the global lock to one lock per subsystem.
The per-subsystem lock avoids that processes operating
with different subsystems are synchronized.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink.h  |    4 +--
 net/netfilter/ipset/ip_set_core.c    |   26 ++++++++---------
 net/netfilter/nf_conntrack_netlink.c |   12 ++++----
 net/netfilter/nfnetlink.c            |   52 +++++++++++++++++++++-------------
 4 files changed, 53 insertions(+), 41 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 4966dde..ecbb8e4 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -34,8 +34,8 @@ extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigne
 extern int nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error);
 extern int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u_int32_t pid, int flags);
 
-extern void nfnl_lock(void);
-extern void nfnl_unlock(void);
+extern void nfnl_lock(__u8 subsys_id);
+extern void nfnl_unlock(__u8 subsys_id);
 
 #define MODULE_ALIAS_NFNL_SUBSYS(subsys) \
 	MODULE_ALIAS("nfnetlink-subsys-" __stringify(subsys))
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 6d6d8f2..f82b2e6 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -88,14 +88,14 @@ find_set_type(const char *name, u8 family, u8 revision)
 static bool
 load_settype(const char *name)
 {
-	nfnl_unlock();
+	nfnl_unlock(NFNL_SUBSYS_IPSET);
 	pr_debug("try to load ip_set_%s\n", name);
 	if (request_module("ip_set_%s", name) < 0) {
 		pr_warning("Can't find ip_set type %s\n", name);
-		nfnl_lock();
+		nfnl_lock(NFNL_SUBSYS_IPSET);
 		return false;
 	}
-	nfnl_lock();
+	nfnl_lock(NFNL_SUBSYS_IPSET);
 	return true;
 }
 
@@ -532,7 +532,7 @@ ip_set_nfnl_get(const char *name)
 	ip_set_id_t i, index = IPSET_INVALID_ID;
 	struct ip_set *s;
 
-	nfnl_lock();
+	nfnl_lock(NFNL_SUBSYS_IPSET);
 	for (i = 0; i < ip_set_max; i++) {
 		s = nfnl_set(i);
 		if (s != NULL && STREQ(s->name, name)) {
@@ -541,7 +541,7 @@ ip_set_nfnl_get(const char *name)
 			break;
 		}
 	}
-	nfnl_unlock();
+	nfnl_unlock(NFNL_SUBSYS_IPSET);
 
 	return index;
 }
@@ -561,13 +561,13 @@ ip_set_nfnl_get_byindex(ip_set_id_t index)
 	if (index > ip_set_max)
 		return IPSET_INVALID_ID;
 
-	nfnl_lock();
+	nfnl_lock(NFNL_SUBSYS_IPSET);
 	set = nfnl_set(index);
 	if (set)
 		__ip_set_get(set);
 	else
 		index = IPSET_INVALID_ID;
-	nfnl_unlock();
+	nfnl_unlock(NFNL_SUBSYS_IPSET);
 
 	return index;
 }
@@ -584,11 +584,11 @@ void
 ip_set_nfnl_put(ip_set_id_t index)
 {
 	struct ip_set *set;
-	nfnl_lock();
+	nfnl_lock(NFNL_SUBSYS_IPSET);
 	set = nfnl_set(index);
 	if (set != NULL)
 		__ip_set_put(set);
-	nfnl_unlock();
+	nfnl_unlock(NFNL_SUBSYS_IPSET);
 }
 EXPORT_SYMBOL_GPL(ip_set_nfnl_put);
 
@@ -1763,10 +1763,10 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 			goto done;
 		}
 		req_get->set.name[IPSET_MAXNAMELEN - 1] = '\0';
-		nfnl_lock();
+		nfnl_lock(NFNL_SUBSYS_IPSET);
 		find_set_and_id(req_get->set.name, &id);
 		req_get->set.index = id;
-		nfnl_unlock();
+		nfnl_unlock(NFNL_SUBSYS_IPSET);
 		goto copy;
 	}
 	case IP_SET_OP_GET_BYINDEX: {
@@ -1778,11 +1778,11 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 			ret = -EINVAL;
 			goto done;
 		}
-		nfnl_lock();
+		nfnl_lock(NFNL_SUBSYS_IPSET);
 		set = nfnl_set(req_get->set.index);
 		strncpy(req_get->set.name, set ? set->name : "",
 			IPSET_MAXNAMELEN);
-		nfnl_unlock();
+		nfnl_unlock(NFNL_SUBSYS_IPSET);
 		goto copy;
 	}
 	default:
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 2334cc5..d490a30 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1256,13 +1256,13 @@ ctnetlink_parse_nat_setup(struct nf_conn *ct,
 	if (!parse_nat_setup) {
 #ifdef CONFIG_MODULES
 		rcu_read_unlock();
-		nfnl_unlock();
+		nfnl_unlock(NFNL_SUBSYS_CTNETLINK);
 		if (request_module("nf-nat") < 0) {
-			nfnl_lock();
+			nfnl_lock(NFNL_SUBSYS_CTNETLINK);
 			rcu_read_lock();
 			return -EOPNOTSUPP;
 		}
-		nfnl_lock();
+		nfnl_lock(NFNL_SUBSYS_CTNETLINK);
 		rcu_read_lock();
 		if (nfnetlink_parse_nat_setup_hook)
 			return -EAGAIN;
@@ -1274,13 +1274,13 @@ ctnetlink_parse_nat_setup(struct nf_conn *ct,
 	if (err == -EAGAIN) {
 #ifdef CONFIG_MODULES
 		rcu_read_unlock();
-		nfnl_unlock();
+		nfnl_unlock(NFNL_SUBSYS_CTNETLINK);
 		if (request_module("nf-nat-%u", nf_ct_l3num(ct)) < 0) {
-			nfnl_lock();
+			nfnl_lock(NFNL_SUBSYS_CTNETLINK);
 			rcu_read_lock();
 			return -EOPNOTSUPP;
 		}
-		nfnl_lock();
+		nfnl_lock(NFNL_SUBSYS_CTNETLINK);
 		rcu_read_lock();
 #else
 		err = -EOPNOTSUPP;
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 58a09b7..d578ec2 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -36,8 +36,10 @@ MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_NETFILTER);
 
 static char __initdata nfversion[] = "0.30";
 
-static const struct nfnetlink_subsystem __rcu *subsys_table[NFNL_SUBSYS_COUNT];
-static DEFINE_MUTEX(nfnl_mutex);
+static struct {
+	struct mutex				mutex;
+	const struct nfnetlink_subsystem __rcu	*subsys;
+} table[NFNL_SUBSYS_COUNT];
 
 static const int nfnl_group2type[NFNLGRP_MAX+1] = {
 	[NFNLGRP_CONNTRACK_NEW]		= NFNL_SUBSYS_CTNETLINK,
@@ -48,27 +50,32 @@ static const int nfnl_group2type[NFNLGRP_MAX+1] = {
 	[NFNLGRP_CONNTRACK_EXP_DESTROY] = NFNL_SUBSYS_CTNETLINK_EXP,
 };
 
-void nfnl_lock(void)
+void nfnl_lock(__u8 subsys_id)
 {
-	mutex_lock(&nfnl_mutex);
+	mutex_lock(&table[subsys_id].mutex);
 }
 EXPORT_SYMBOL_GPL(nfnl_lock);
 
-void nfnl_unlock(void)
+void nfnl_unlock(__u8 subsys_id)
 {
-	mutex_unlock(&nfnl_mutex);
+	mutex_unlock(&table[subsys_id].mutex);
 }
 EXPORT_SYMBOL_GPL(nfnl_unlock);
 
+static struct mutex *nfnl_get_lock(__u8 subsys_id)
+{
+	return &table[subsys_id].mutex;
+}
+
 int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n)
 {
-	nfnl_lock();
-	if (subsys_table[n->subsys_id]) {
-		nfnl_unlock();
+	nfnl_lock(n->subsys_id);
+	if (table[n->subsys_id].subsys) {
+		nfnl_unlock(n->subsys_id);
 		return -EBUSY;
 	}
-	rcu_assign_pointer(subsys_table[n->subsys_id], n);
-	nfnl_unlock();
+	rcu_assign_pointer(table[n->subsys_id].subsys, n);
+	nfnl_unlock(n->subsys_id);
 
 	return 0;
 }
@@ -76,9 +83,9 @@ EXPORT_SYMBOL_GPL(nfnetlink_subsys_register);
 
 int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n)
 {
-	nfnl_lock();
-	subsys_table[n->subsys_id] = NULL;
-	nfnl_unlock();
+	nfnl_lock(n->subsys_id);
+	table[n->subsys_id].subsys = NULL;
+	nfnl_unlock(n->subsys_id);
 	synchronize_rcu();
 	return 0;
 }
@@ -91,7 +98,7 @@ static inline const struct nfnetlink_subsystem *nfnetlink_get_subsys(u_int16_t t
 	if (subsys_id >= NFNL_SUBSYS_COUNT)
 		return NULL;
 
-	return rcu_dereference(subsys_table[subsys_id]);
+	return rcu_dereference(table[subsys_id].subsys);
 }
 
 static inline const struct nfnl_callback *
@@ -175,6 +182,7 @@ replay:
 		struct nlattr *cda[ss->cb[cb_id].attr_count + 1];
 		struct nlattr *attr = (void *)nlh + min_len;
 		int attrlen = nlh->nlmsg_len - min_len;
+		__u8 subsys_id = NFNL_SUBSYS_ID(type);
 
 		err = nla_parse(cda, ss->cb[cb_id].attr_count,
 				attr, attrlen, ss->cb[cb_id].policy);
@@ -189,10 +197,9 @@ replay:
 			rcu_read_unlock();
 		} else {
 			rcu_read_unlock();
-			nfnl_lock();
-			if (rcu_dereference_protected(
-					subsys_table[NFNL_SUBSYS_ID(type)],
-					lockdep_is_held(&nfnl_mutex)) != ss ||
+			nfnl_lock(subsys_id);
+			if (rcu_dereference_protected(table[subsys_id].subsys,
+				lockdep_is_held(nfnl_get_lock(subsys_id))) != ss ||
 			    nfnetlink_find_client(type, ss) != nc)
 				err = -EAGAIN;
 			else if (nc->call)
@@ -200,7 +207,7 @@ replay:
 						   (const struct nlattr **)cda);
 			else
 				err = -EINVAL;
-			nfnl_unlock();
+			nfnl_unlock(subsys_id);
 		}
 		if (err == -EAGAIN)
 			goto replay;
@@ -267,6 +274,11 @@ static struct pernet_operations nfnetlink_net_ops = {
 
 static int __init nfnetlink_init(void)
 {
+	int i;
+
+	for (i=0; i<NFNL_SUBSYS_COUNT; i++)
+		mutex_init(&table[i].mutex);
+
 	pr_info("Netfilter messages via NETLINK v%s.\n", nfversion);
 	return register_pernet_subsys(&nfnetlink_net_ops);
 }
-- 
1.7.10.4
