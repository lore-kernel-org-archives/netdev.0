From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: ctnetlink: force null nat binding on insert
Date: Wed, 19 Feb 2014 12:41:42 +0100
Message-ID: <1392810102-13877-7-git-send-email-pablo@netfilter.org>
References: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45007 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777AbaBSLl5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 06:41:57 -0500
In-Reply-To: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Andrey Vagin:
  When a conntrack is created  by kernel, it is initialized (sets
  IPS_{DST,SRC}_NAT_DONE_BIT bits in nf_nat_setup_info) and only then it
  is added in hashes (__nf_conntrack_hash_insert), so one conntract
  can't be initialized from a few threads concurrently.

  ctnetlink can add an uninitialized conntrack (w/o
  IPS_{DST,SRC}_NAT_DONE_BIT) in hashes, then a few threads can look up
  this conntrack and start initialize it concurrently. It's dangerous,
  because BUG can be triggered from nf_nat_setup_info.

Fix this race by always setting up nat, even if no CTA_NAT_ attribute
was requested before inserting the ct into the hash table. In absence
of CTA_NAT_ attribute, a null binding is created.

This alters current behaviour: Before this patch, the first packet
matching the newly injected conntrack would be run through the nat
table since nf_nat_initialized() returns false.  IOW, this forces
ctnetlink users to specify the desired nat transformation on ct
creation time.

Thanks for Florian Westphal, this patch is based on his original
patch to address this problem, including this patch description.

Reported-By: Andrey Vagin <avagin@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/nf_conntrack_netlink.c |   35 +++++++++------------
 net/netfilter/nf_nat_core.c          |   56 +++++++++++++++++++++-------------
 2 files changed, 49 insertions(+), 42 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index bb322d0..b9f0e03 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1310,27 +1310,22 @@ ctnetlink_change_status(struct nf_conn *ct, const struct nlattr * const cda[])
 }
 
 static int
-ctnetlink_change_nat(struct nf_conn *ct, const struct nlattr * const cda[])
+ctnetlink_setup_nat(struct nf_conn *ct, const struct nlattr * const cda[])
 {
 #ifdef CONFIG_NF_NAT_NEEDED
 	int ret;
 
-	if (cda[CTA_NAT_DST]) {
-		ret = ctnetlink_parse_nat_setup(ct,
-						NF_NAT_MANIP_DST,
-						cda[CTA_NAT_DST]);
-		if (ret < 0)
-			return ret;
-	}
-	if (cda[CTA_NAT_SRC]) {
-		ret = ctnetlink_parse_nat_setup(ct,
-						NF_NAT_MANIP_SRC,
-						cda[CTA_NAT_SRC]);
-		if (ret < 0)
-			return ret;
-	}
-	return 0;
+	ret = ctnetlink_parse_nat_setup(ct, NF_NAT_MANIP_DST,
+					cda[CTA_NAT_DST]);
+	if (ret < 0)
+		return ret;
+
+	ret = ctnetlink_parse_nat_setup(ct, NF_NAT_MANIP_SRC,
+					cda[CTA_NAT_SRC]);
+	return ret;
 #else
+	if (!cda[CTA_NAT_DST] && !cda[CTA_NAT_SRC])
+		return 0;
 	return -EOPNOTSUPP;
 #endif
 }
@@ -1659,11 +1654,9 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 			goto err2;
 	}
 
-	if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
-		err = ctnetlink_change_nat(ct, cda);
-		if (err < 0)
-			goto err2;
-	}
+	err = ctnetlink_setup_nat(ct, cda);
+	if (err < 0)
+		goto err2;
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
 	nf_ct_tstamp_ext_add(ct, GFP_ATOMIC);
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index d3f5cd6..52ca952 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -432,15 +432,15 @@ nf_nat_setup_info(struct nf_conn *ct,
 }
 EXPORT_SYMBOL(nf_nat_setup_info);
 
-unsigned int
-nf_nat_alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
+static unsigned int
+__nf_nat_alloc_null_binding(struct nf_conn *ct, enum nf_nat_manip_type manip)
 {
 	/* Force range to this IP; let proto decide mapping for
 	 * per-proto parts (hence not IP_NAT_RANGE_PROTO_SPECIFIED).
 	 * Use reply in case it's already been mangled (eg local packet).
 	 */
 	union nf_inet_addr ip =
-		(HOOK2MANIP(hooknum) == NF_NAT_MANIP_SRC ?
+		(manip == NF_NAT_MANIP_SRC ?
 		ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3 :
 		ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3);
 	struct nf_nat_range range = {
@@ -448,7 +448,13 @@ nf_nat_alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
 		.min_addr	= ip,
 		.max_addr	= ip,
 	};
-	return nf_nat_setup_info(ct, &range, HOOK2MANIP(hooknum));
+	return nf_nat_setup_info(ct, &range, manip);
+}
+
+unsigned int
+nf_nat_alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
+{
+	return __nf_nat_alloc_null_binding(ct, HOOK2MANIP(hooknum));
 }
 EXPORT_SYMBOL_GPL(nf_nat_alloc_null_binding);
 
@@ -702,9 +708,9 @@ static const struct nla_policy nat_nla_policy[CTA_NAT_MAX+1] = {
 
 static int
 nfnetlink_parse_nat(const struct nlattr *nat,
-		    const struct nf_conn *ct, struct nf_nat_range *range)
+		    const struct nf_conn *ct, struct nf_nat_range *range,
+		    const struct nf_nat_l3proto *l3proto)
 {
-	const struct nf_nat_l3proto *l3proto;
 	struct nlattr *tb[CTA_NAT_MAX+1];
 	int err;
 
@@ -714,38 +720,46 @@ nfnetlink_parse_nat(const struct nlattr *nat,
 	if (err < 0)
 		return err;
 
-	rcu_read_lock();
-	l3proto = __nf_nat_l3proto_find(nf_ct_l3num(ct));
-	if (l3proto == NULL) {
-		err = -EAGAIN;
-		goto out;
-	}
 	err = l3proto->nlattr_to_range(tb, range);
 	if (err < 0)
-		goto out;
+		return err;
 
 	if (!tb[CTA_NAT_PROTO])
-		goto out;
+		return 0;
 
-	err = nfnetlink_parse_nat_proto(tb[CTA_NAT_PROTO], ct, range);
-out:
-	rcu_read_unlock();
-	return err;
+	return nfnetlink_parse_nat_proto(tb[CTA_NAT_PROTO], ct, range);
 }
 
+/* This function is called under rcu_read_lock() */
 static int
 nfnetlink_parse_nat_setup(struct nf_conn *ct,
 			  enum nf_nat_manip_type manip,
 			  const struct nlattr *attr)
 {
 	struct nf_nat_range range;
+	const struct nf_nat_l3proto *l3proto;
 	int err;
 
-	err = nfnetlink_parse_nat(attr, ct, &range);
+	/* Should not happen, restricted to creating new conntracks
+	 * via ctnetlink.
+	 */
+	if (WARN_ON_ONCE(nf_nat_initialized(ct, manip)))
+		return -EEXIST;
+
+	/* Make sure that L3 NAT is there by when we call nf_nat_setup_info to
+	 * attach the null binding, otherwise this may oops.
+	 */
+	l3proto = __nf_nat_l3proto_find(nf_ct_l3num(ct));
+	if (l3proto == NULL)
+		return -EAGAIN;
+
+	/* No NAT information has been passed, allocate the null-binding */
+	if (attr == NULL)
+		return __nf_nat_alloc_null_binding(ct, manip);
+
+	err = nfnetlink_parse_nat(attr, ct, &range, l3proto);
 	if (err < 0)
 		return err;
-	if (nf_nat_initialized(ct, manip))
-		return -EEXIST;
 
 	return nf_nat_setup_info(ct, &range, manip);
 }
-- 
1.7.10.4
