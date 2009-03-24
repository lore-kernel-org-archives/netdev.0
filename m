From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 36/41: ctnetlink: remove remaining module refcounting
Date: Tue, 24 Mar 2009 15:03:55 +0100 (MET)
Message-ID: <20090324140351.31401.70936.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34809 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758675AbZCXOD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:57 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit cd91566e4bdbcb8841385e4b2eacc8d0c29c9208
Author: Florian Westphal <fw@strlen.de>
Date:   Wed Mar 18 17:28:37 2009 +0100

    netfilter: ctnetlink: remove remaining module refcounting
    
    Convert the remaining refcount users.
    
    As pointed out by Patrick McHardy, the protocols can be accessed safely using RCU.
    
    Signed-off-by: Florian Westphal <fw@strlen.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9fb7cf7..735ea9c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -599,7 +599,8 @@ ctnetlink_parse_tuple_ip(struct nlattr *attr, struct nf_conntrack_tuple *tuple)
 
 	nla_parse_nested(tb, CTA_IP_MAX, attr, NULL);
 
-	l3proto = nf_ct_l3proto_find_get(tuple->src.l3num);
+	rcu_read_lock();
+	l3proto = __nf_ct_l3proto_find(tuple->src.l3num);
 
 	if (likely(l3proto->nlattr_to_tuple)) {
 		ret = nla_validate_nested(attr, CTA_IP_MAX,
@@ -608,7 +609,7 @@ ctnetlink_parse_tuple_ip(struct nlattr *attr, struct nf_conntrack_tuple *tuple)
 			ret = l3proto->nlattr_to_tuple(tb, tuple);
 	}
 
-	nf_ct_l3proto_put(l3proto);
+	rcu_read_unlock();
 
 	return ret;
 }
@@ -633,7 +634,8 @@ ctnetlink_parse_tuple_proto(struct nlattr *attr,
 		return -EINVAL;
 	tuple->dst.protonum = nla_get_u8(tb[CTA_PROTO_NUM]);
 
-	l4proto = nf_ct_l4proto_find_get(tuple->src.l3num, tuple->dst.protonum);
+	rcu_read_lock();
+	l4proto = __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.protonum);
 
 	if (likely(l4proto->nlattr_to_tuple)) {
 		ret = nla_validate_nested(attr, CTA_PROTO_MAX,
@@ -642,7 +644,7 @@ ctnetlink_parse_tuple_proto(struct nlattr *attr,
 			ret = l4proto->nlattr_to_tuple(tb, tuple);
 	}
 
-	nf_ct_l4proto_put(l4proto);
+	rcu_read_unlock();
 
 	return ret;
 }
@@ -989,10 +991,11 @@ ctnetlink_change_protoinfo(struct nf_conn *ct, struct nlattr *cda[])
 
 	nla_parse_nested(tb, CTA_PROTOINFO_MAX, attr, NULL);
 
-	l4proto = nf_ct_l4proto_find_get(nf_ct_l3num(ct), nf_ct_protonum(ct));
+	rcu_read_lock();
+	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto->from_nlattr)
 		err = l4proto->from_nlattr(tb, ct);
-	nf_ct_l4proto_put(l4proto);
+	rcu_read_unlock();
 
 	return err;
 }
