From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/36] netfilter: conntrack: small refactoring of conntrack seq_printf
Date: Mon,  9 May 2016 20:46:37 +0200
Message-ID: <1462819614-5402-20-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45723 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752505AbcEISrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:24 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 5F0ACE8E87
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 41388134719
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2860113471D
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:21 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The iteration process is lockless, so we test if the conntrack object is
eligible for printing (e.g. is AF_INET) after obtaining the reference
count.

Once we put all conntracks into same hash table we might see more
entries that need to be skipped.

So add a helper and first perform the test in a lockless fashion
for fast skip.

Once we obtain the reference count, just repeat the check.

Note that this refactoring also includes a missing check for unconfirmed
conntrack entries due to slab rcu object re-usage, so they need to be
skipped since they are not part of the listing.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   | 24 +++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index f0dfe92..483cf79 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -114,6 +114,19 @@ static inline void ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
 }
 #endif
 
+static bool ct_seq_should_skip(const struct nf_conn *ct,
+			       const struct nf_conntrack_tuple_hash *hash)
+{
+	/* we only want to print DIR_ORIGINAL */
+	if (NF_CT_DIRECTION(hash))
+		return true;
+
+	if (nf_ct_l3num(ct) != AF_INET)
+		return true;
+
+	return false;
+}
+
 static int ct_seq_show(struct seq_file *s, void *v)
 {
 	struct nf_conntrack_tuple_hash *hash = v;
@@ -123,14 +136,15 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	int ret = 0;
 
 	NF_CT_ASSERT(ct);
-	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+	if (ct_seq_should_skip(ct, hash))
 		return 0;
 
+	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		return 0;
 
-	/* we only want to print DIR_ORIGINAL */
-	if (NF_CT_DIRECTION(hash))
-		goto release;
-	if (nf_ct_l3num(ct) != AF_INET)
+	/* check if we raced w. object reuse */
+	if (!nf_ct_is_confirmed(ct) ||
+	    ct_seq_should_skip(ct, hash))
 		goto release;
 
 	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
-- 
2.1.4
