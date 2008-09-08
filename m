From: David Howells <dhowells@redhat.com>
Subject: [PATCH] Fix no-IPv6 warnings and errors in the netlabel code
Date: Mon, 08 Sep 2008 14:27:23 +0100
Message-ID: <20080908132723.27379.69655.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750739AbYIHN1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 09:27:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warnings and errors in the netlabel code when compiled with CONFIG_IPV6=n.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/netlabel/netlabel_domainhash.c |   10 +++++++++-
 net/netlabel/netlabel_mgmt.c       |   22 ++++++++++++++++++----
 net/netlabel/netlabel_unlabeled.c  |   28 +++++++++++++++++++++++++---
 3 files changed, 52 insertions(+), 8 deletions(-)


diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 25d17d2..a15160f 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -75,8 +75,10 @@ static void netlbl_domhsh_free_entry(struct rcu_head *entry)
 	struct netlbl_dom_map *ptr;
 	struct netlbl_af4list *iter4;
 	struct netlbl_af4list *tmp4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct netlbl_af6list *iter6;
 	struct netlbl_af6list *tmp6;
+#endif
 
 	ptr = container_of(entry, struct netlbl_dom_map, rcu);
 	if (ptr->type == NETLBL_NLTYPE_ADDRSELECT) {
@@ -298,7 +300,9 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 	int ret_val = 0;
 	struct netlbl_dom_map *entry_old;
 	struct netlbl_af4list *iter4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct netlbl_af6list *iter6;
+#endif
 
 	rcu_read_lock();
 
@@ -337,12 +341,16 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 	} else if (entry_old->type == NETLBL_NLTYPE_ADDRSELECT &&
 		   entry->type == NETLBL_NLTYPE_ADDRSELECT) {
 		struct netlbl_af4list *tmp4;
-		struct netlbl_af6list *tmp6;
 		struct list_head *old_list4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		struct netlbl_af6list *tmp6;
 		struct list_head *old_list6;
+#endif
 
 		old_list4 = &entry_old->type_def.addrsel->list4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		old_list6 = &entry_old->type_def.addrsel->list6;
+#endif
 
 		/* we only allow the addition of address selectors if all of
 		 * the selectors do not exist in the existing domain map */
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 5dc7d0f..f8d2b44 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -137,9 +137,13 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		goto add_failure;
 	}
 	if ((info->attrs[NLBL_MGMT_A_IPV4ADDR] &&
-	     info->attrs[NLBL_MGMT_A_IPV4MASK]) ||
+	     info->attrs[NLBL_MGMT_A_IPV4MASK])
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	    ||
 	    (info->attrs[NLBL_MGMT_A_IPV6ADDR] &&
-	     info->attrs[NLBL_MGMT_A_IPV6MASK])) {
+	     info->attrs[NLBL_MGMT_A_IPV6MASK])
+#endif
+	    ) {
 		addrmap = kzalloc(sizeof(*addrmap), GFP_KERNEL);
 		if (addrmap == NULL) {
 			ret_val = -ENOMEM;
@@ -148,7 +152,10 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 		INIT_LIST_HEAD(&addrmap->list4);
 		INIT_LIST_HEAD(&addrmap->list6);
 
-		if (info->attrs[NLBL_MGMT_A_IPV4ADDR]) {
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		if (info->attrs[NLBL_MGMT_A_IPV4ADDR])
+#endif
+		{
 			struct in_addr *addr;
 			struct in_addr *mask;
 			struct netlbl_domaddr4_map *map;
@@ -184,7 +191,9 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 				kfree(map);
 				goto add_failure;
 			}
-		} else {
+		}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		else {
 			struct in6_addr *addr;
 			struct in6_addr *mask;
 			struct netlbl_domaddr6_map *map;
@@ -223,6 +232,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 				goto add_failure;
 			}
 		}
+#endif
 
 		entry->type = NETLBL_NLTYPE_ADDRSELECT;
 		entry->type_def.addrsel = addrmap;
@@ -262,7 +272,9 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 	struct nlattr *nla_a;
 	struct nlattr *nla_b;
 	struct netlbl_af4list *iter4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct netlbl_af6list *iter6;
+#endif
 
 	if (entry->domain != NULL) {
 		ret_val = nla_put_string(skb,
@@ -314,6 +326,7 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 
 			nla_nest_end(skb, nla_b);
 		}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		netlbl_af6list_foreach_rcu(iter6,
 					   &entry->type_def.addrsel->list6) {
 			struct netlbl_domaddr6_map *map6;
@@ -340,6 +353,7 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 
 			nla_nest_end(skb, nla_b);
 		}
+#endif
 
 		nla_nest_end(skb, nla_a);
 		break;
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 8a87378..349fb47 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -205,8 +205,10 @@ static void netlbl_unlhsh_free_iface(struct rcu_head *entry)
 	struct netlbl_unlhsh_iface *iface;
 	struct netlbl_af4list *iter4;
 	struct netlbl_af4list *tmp4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct netlbl_af6list *iter6;
 	struct netlbl_af6list *tmp6;
+#endif
 
 	iface = container_of(entry, struct netlbl_unlhsh_iface, rcu);
 
@@ -217,10 +219,12 @@ static void netlbl_unlhsh_free_iface(struct rcu_head *entry)
 		netlbl_af4list_remove_entry(iter4);
 		kfree(netlbl_unlhsh_addr4_entry(iter4));
 	}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	netlbl_af6list_foreach_safe(iter6, tmp6, &iface->addr6_list) {
 		netlbl_af6list_remove_entry(iter6);
 		kfree(netlbl_unlhsh_addr6_entry(iter6));
 	}
+#endif
 	kfree(iface);
 }
 
@@ -672,13 +676,17 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 static void netlbl_unlhsh_condremove_iface(struct netlbl_unlhsh_iface *iface)
 {
 	struct netlbl_af4list *iter4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct netlbl_af6list *iter6;
+#endif
 
 	spin_lock(&netlbl_unlhsh_lock);
 	netlbl_af4list_foreach_rcu(iter4, &iface->addr4_list)
 		goto unlhsh_condremove_failure;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	netlbl_af6list_foreach_rcu(iter6, &iface->addr6_list)
 		goto unlhsh_condremove_failure;
+#endif
 	iface->valid = 0;
 	if (iface->ifindex > 0)
 		list_del_rcu(&iface->list);
@@ -1256,10 +1264,13 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 	u32 skip_addr4 = cb->args[2];
 	u32 skip_addr6 = cb->args[3];
 	u32 iter_bkt;
-	u32 iter_chain = 0, iter_addr4 = 0, iter_addr6 = 0;
+	u32 iter_chain = 0, iter_addr4 = 0;
 	struct netlbl_unlhsh_iface *iface;
 	struct netlbl_af4list *addr4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct netlbl_af6list *addr6;
+	u32 iter_addr6 = 0;
+#endif
 
 	cb_arg.nl_cb = cb;
 	cb_arg.skb = skb;
@@ -1268,7 +1279,11 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 	rcu_read_lock();
 	for (iter_bkt = skip_bkt;
 	     iter_bkt < rcu_dereference(netlbl_unlhsh)->size;
-	     iter_bkt++, iter_chain = 0, iter_addr4 = 0, iter_addr6 = 0) {
+	     iter_bkt++, iter_chain = 0, iter_addr4 = 0
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		     , iter_addr6 = 0
+#endif
+	     ) {
 		list_for_each_entry_rcu(iface,
 			        &rcu_dereference(netlbl_unlhsh)->tbl[iter_bkt],
 				list) {
@@ -1290,6 +1305,7 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 					goto unlabel_staticlist_return;
 				}
 			}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 			netlbl_af6list_foreach_rcu(addr6,
 						   &iface->addr6_list) {
 				if (iter_addr6++ < skip_addr6)
@@ -1305,6 +1321,7 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 					goto unlabel_staticlist_return;
 				}
 			}
+#endif
 		}
 	}
 
@@ -1335,9 +1352,12 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 	struct netlbl_unlhsh_iface *iface;
 	u32 skip_addr4 = cb->args[0];
 	u32 skip_addr6 = cb->args[1];
-	u32 iter_addr4 = 0, iter_addr6 = 0;
+	u32 iter_addr4 = 0;
 	struct netlbl_af4list *addr4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	u32 iter_addr6 = 0;
 	struct netlbl_af6list *addr6;
+#endif
 
 	cb_arg.nl_cb = cb;
 	cb_arg.skb = skb;
@@ -1360,6 +1380,7 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 			goto unlabel_staticlistdef_return;
 		}
 	}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	netlbl_af6list_foreach_rcu(addr6, &iface->addr6_list) {
 		if (iter_addr6++ < skip_addr6)
 			continue;
@@ -1372,6 +1393,7 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 			goto unlabel_staticlistdef_return;
 		}
 	}
+#endif
 
 unlabel_staticlistdef_return:
 	rcu_read_unlock();

