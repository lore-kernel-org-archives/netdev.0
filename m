From: kaber@trash.net
Subject: [PATCH 14/26] netfilter: ipset: use nla_parse_nested()
Date: Thu,  3 Feb 2011 00:11:52 +0100
Message-ID: <1296688324-7830-15-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44729 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350Ab1BBXMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:12:34 -0500
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Replace calls of the form:

nla_parse(tb, ATTR_MAX, nla_data(attr), nla_len(attr), policy)

by:

nla_parse_nested(tb, ATTR_MAX, attr, policy)

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_core.c |   42 ++++++++++++++----------------------
 1 files changed, 16 insertions(+), 26 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 8a73624..ae0f8b5 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -246,8 +246,7 @@ ip_set_get_ipaddr4(struct nlattr *nla,  __be32 *ipaddr)
 
 	if (unlikely(!flag_nested(nla)))
 		return -IPSET_ERR_PROTOCOL;
-	if (nla_parse(tb, IPSET_ATTR_IPADDR_MAX, nla_data(nla), nla_len(nla),
-		      ipaddr_policy))
+	if (nla_parse_nested(tb, IPSET_ATTR_IPADDR_MAX, nla, ipaddr_policy))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_IPADDR_IPV4)))
 		return -IPSET_ERR_PROTOCOL;
@@ -265,8 +264,7 @@ ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr)
 	if (unlikely(!flag_nested(nla)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (nla_parse(tb, IPSET_ATTR_IPADDR_MAX, nla_data(nla), nla_len(nla),
-		      ipaddr_policy))
+	if (nla_parse_nested(tb, IPSET_ATTR_IPADDR_MAX, nla, ipaddr_policy))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_IPADDR_IPV6)))
 		return -IPSET_ERR_PROTOCOL;
@@ -666,10 +664,8 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	 * Without holding any locks, create private part.
 	 */
 	if (attr[IPSET_ATTR_DATA] &&
-	    nla_parse(tb, IPSET_ATTR_CREATE_MAX,
-	    	      nla_data(attr[IPSET_ATTR_DATA]),
-	    	      nla_len(attr[IPSET_ATTR_DATA]),
-	    	      set->type->create_policy)) {
+	    nla_parse_nested(tb, IPSET_ATTR_CREATE_MAX, attr[IPSET_ATTR_DATA],
+			     set->type->create_policy)) {
 	    	ret = -IPSET_ERR_PROTOCOL;
 	    	goto put_out;
 	}
@@ -1169,10 +1165,9 @@ ip_set_uadd(struct sock *ctnl, struct sk_buff *skb,
 
 	use_lineno = !!attr[IPSET_ATTR_LINENO];
 	if (attr[IPSET_ATTR_DATA]) {
-		if (nla_parse(tb, IPSET_ATTR_ADT_MAX,
-			      nla_data(attr[IPSET_ATTR_DATA]),
-			      nla_len(attr[IPSET_ATTR_DATA]),
-			      set->type->adt_policy))
+		if (nla_parse_nested(tb, IPSET_ATTR_ADT_MAX,
+				     attr[IPSET_ATTR_DATA],
+				     set->type->adt_policy))
 			return -IPSET_ERR_PROTOCOL;
 		ret = call_ad(skb, set, tb, IPSET_ADD, flags, use_lineno);
 	} else {
@@ -1182,9 +1177,8 @@ ip_set_uadd(struct sock *ctnl, struct sk_buff *skb,
 			memset(tb, 0, sizeof(tb));
 			if (nla_type(nla) != IPSET_ATTR_DATA ||
 			    !flag_nested(nla) ||
-			    nla_parse(tb, IPSET_ATTR_ADT_MAX,
-			    	      nla_data(nla), nla_len(nla),
-			    	      set->type->adt_policy))
+			    nla_parse_nested(tb, IPSET_ATTR_ADT_MAX, nla,
+					     set->type->adt_policy))
 				return -IPSET_ERR_PROTOCOL;
 			ret = call_ad(skb, set, tb, IPSET_ADD,
 				      flags, use_lineno);
@@ -1224,10 +1218,9 @@ ip_set_udel(struct sock *ctnl, struct sk_buff *skb,
 
 	use_lineno = !!attr[IPSET_ATTR_LINENO];
 	if (attr[IPSET_ATTR_DATA]) {
-		if (nla_parse(tb, IPSET_ATTR_ADT_MAX,
-			      nla_data(attr[IPSET_ATTR_DATA]),
-			      nla_len(attr[IPSET_ATTR_DATA]),
-			      set->type->adt_policy))
+		if (nla_parse_nested(tb, IPSET_ATTR_ADT_MAX,
+				     attr[IPSET_ATTR_DATA],
+				     set->type->adt_policy))
 			return -IPSET_ERR_PROTOCOL;
 		ret = call_ad(skb, set, tb, IPSET_DEL, flags, use_lineno);
 	} else {
@@ -1237,9 +1230,8 @@ ip_set_udel(struct sock *ctnl, struct sk_buff *skb,
 			memset(tb, 0, sizeof(*tb));
 			if (nla_type(nla) != IPSET_ATTR_DATA ||
 			    !flag_nested(nla) ||
-			    nla_parse(tb, IPSET_ATTR_ADT_MAX,
-			    	      nla_data(nla), nla_len(nla),
-			    	      set->type->adt_policy))
+			    nla_parse_nested(tb, IPSET_ATTR_ADT_MAX, nla,
+					     set->type->adt_policy))
 				return -IPSET_ERR_PROTOCOL;
 			ret = call_ad(skb, set, tb, IPSET_DEL,
 				      flags, use_lineno);
@@ -1269,10 +1261,8 @@ ip_set_utest(struct sock *ctnl, struct sk_buff *skb,
 	if (set == NULL)
 		return -ENOENT;
 
-	if (nla_parse(tb, IPSET_ATTR_ADT_MAX,
-		      nla_data(attr[IPSET_ATTR_DATA]),
-		      nla_len(attr[IPSET_ATTR_DATA]),
-		      set->type->adt_policy))
+	if (nla_parse_nested(tb, IPSET_ATTR_ADT_MAX, attr[IPSET_ATTR_DATA],
+			     set->type->adt_policy))
 		return -IPSET_ERR_PROTOCOL;
 
 	read_lock_bh(&set->lock);
-- 
1.7.2.3

