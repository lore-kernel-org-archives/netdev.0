From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] netfilter: add helper for adding nat extension
Date: Thu, 29 May 2014 17:55:00 +0200
Message-ID: <1401378900-12436-4-git-send-email-pablo@netfilter.org>
References: <1401378900-12436-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58805 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933523AbaE2PzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:55:15 -0400
In-Reply-To: <1401378900-12436-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Reduce copy-past a bit by adding a common helper.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat.h          |    2 ++
 net/ipv4/netfilter/iptable_nat.c        |   14 +++-----------
 net/ipv4/netfilter/nft_chain_nat_ipv4.c |   12 +++---------
 net/ipv6/netfilter/ip6table_nat.c       |   14 +++-----------
 net/ipv6/netfilter/nft_chain_nat_ipv6.c |   12 +++---------
 net/netfilter/nf_nat_core.c             |   24 ++++++++++++++++--------
 6 files changed, 30 insertions(+), 48 deletions(-)

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index 07eaaf6..a71dd33 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -48,6 +48,8 @@ unsigned int nf_nat_setup_info(struct nf_conn *ct,
 extern unsigned int nf_nat_alloc_null_binding(struct nf_conn *ct,
 					      unsigned int hooknum);
 
+struct nf_conn_nat *nf_ct_nat_ext_add(struct nf_conn *ct);
+
 /* Is this tuple already taken? (not by us)*/
 int nf_nat_used_tuple(const struct nf_conntrack_tuple *tuple,
 		      const struct nf_conn *ignored_conntrack);
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index ee28861..f1787c0 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -91,17 +91,9 @@ nf_nat_ipv4_fn(const struct nf_hook_ops *ops,
 	if (nf_ct_is_untracked(ct))
 		return NF_ACCEPT;
 
-	nat = nfct_nat(ct);
-	if (!nat) {
-		/* NAT module was loaded late. */
-		if (nf_ct_is_confirmed(ct))
-			return NF_ACCEPT;
-		nat = nf_ct_ext_add(ct, NF_CT_EXT_NAT, GFP_ATOMIC);
-		if (nat == NULL) {
-			pr_debug("failed to add NAT extension\n");
-			return NF_ACCEPT;
-		}
-	}
+	nat = nf_ct_nat_ext_add(ct);
+	if (nat == NULL)
+		return NF_ACCEPT;
 
 	switch (ctinfo) {
 	case IP_CT_RELATED:
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index b5b256d..3964157 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -48,15 +48,9 @@ static unsigned int nf_nat_fn(const struct nf_hook_ops *ops,
 
 	NF_CT_ASSERT(!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)));
 
-	nat = nfct_nat(ct);
-	if (nat == NULL) {
-		/* Conntrack module was loaded late, can't add extension. */
-		if (nf_ct_is_confirmed(ct))
-			return NF_ACCEPT;
-		nat = nf_ct_ext_add(ct, NF_CT_EXT_NAT, GFP_ATOMIC);
-		if (nat == NULL)
-			return NF_ACCEPT;
-	}
+	nat = nf_ct_nat_ext_add(ct);
+	if (nat == NULL)
+		return NF_ACCEPT;
 
 	switch (ctinfo) {
 	case IP_CT_RELATED:
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index 84c7f33..387d8b8 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -90,17 +90,9 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops,
 	if (nf_ct_is_untracked(ct))
 		return NF_ACCEPT;
 
-	nat = nfct_nat(ct);
-	if (!nat) {
-		/* NAT module was loaded late. */
-		if (nf_ct_is_confirmed(ct))
-			return NF_ACCEPT;
-		nat = nf_ct_ext_add(ct, NF_CT_EXT_NAT, GFP_ATOMIC);
-		if (nat == NULL) {
-			pr_debug("failed to add NAT extension\n");
-			return NF_ACCEPT;
-		}
-	}
+	nat = nf_ct_nat_ext_add(ct);
+	if (nat == NULL)
+		return NF_ACCEPT;
 
 	switch (ctinfo) {
 	case IP_CT_RELATED:
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index 9c3297a..d189fcb 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -47,15 +47,9 @@ static unsigned int nf_nat_ipv6_fn(const struct nf_hook_ops *ops,
 	if (ct == NULL || nf_ct_is_untracked(ct))
 		return NF_ACCEPT;
 
-	nat = nfct_nat(ct);
-	if (nat == NULL) {
-		/* Conntrack module was loaded late, can't add extension. */
-		if (nf_ct_is_confirmed(ct))
-			return NF_ACCEPT;
-		nat = nf_ct_ext_add(ct, NF_CT_EXT_NAT, GFP_ATOMIC);
-		if (nat == NULL)
-			return NF_ACCEPT;
-	}
+	nat = nf_ct_nat_ext_add(ct);
+	if (nat == NULL)
+		return NF_ACCEPT;
 
 	switch (ctinfo) {
 	case IP_CT_RELATED:
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 52ca952..09096a6 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -358,6 +358,19 @@ out:
 	rcu_read_unlock();
 }
 
+struct nf_conn_nat *nf_ct_nat_ext_add(struct nf_conn *ct)
+{
+	struct nf_conn_nat *nat = nfct_nat(ct);
+	if (nat)
+		return nat;
+
+	if (!nf_ct_is_confirmed(ct))
+		nat = nf_ct_ext_add(ct, NF_CT_EXT_NAT, GFP_ATOMIC);
+
+	return nat;
+}
+EXPORT_SYMBOL_GPL(nf_ct_nat_ext_add);
+
 unsigned int
 nf_nat_setup_info(struct nf_conn *ct,
 		  const struct nf_nat_range *range,
@@ -368,14 +381,9 @@ nf_nat_setup_info(struct nf_conn *ct,
 	struct nf_conn_nat *nat;
 
 	/* nat helper or nfctnetlink also setup binding */
-	nat = nfct_nat(ct);
-	if (!nat) {
-		nat = nf_ct_ext_add(ct, NF_CT_EXT_NAT, GFP_ATOMIC);
-		if (nat == NULL) {
-			pr_debug("failed to add NAT extension\n");
-			return NF_ACCEPT;
-		}
-	}
+	nat = nf_ct_nat_ext_add(ct);
+	if (nat == NULL)
+		return NF_ACCEPT;
 
 	NF_CT_ASSERT(maniptype == NF_NAT_MANIP_SRC ||
 		     maniptype == NF_NAT_MANIP_DST);
-- 
1.7.10.4
