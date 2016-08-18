From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: conntrack: do not dump other netns's conntrack entries via proc
Date: Thu, 18 Aug 2016 19:29:03 +0200
Message-ID: <1471541348-1538-2-git-send-email-pablo@netfilter.org>
References: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44000 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754231AbcHSA5o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 20:57:44 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 5B355A4195
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4C8DEDA7E2
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EA6459D6A4
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:17 +0200 (CEST)
In-Reply-To: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

We should skip the conntracks that belong to a different namespace,
otherwise other unrelated netns's conntrack entries will be dumped via
/proc/net/nf_conntrack.

Fixes: 56d52d4892d0 ("netfilter: conntrack: use a single hashtable for all namespaces")
Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Reviewed-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_standalone.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 958a145..9f267c3 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -205,6 +205,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(hash);
 	const struct nf_conntrack_l3proto *l3proto;
 	const struct nf_conntrack_l4proto *l4proto;
+	struct net *net = seq_file_net(s);
 	int ret = 0;
 
 	NF_CT_ASSERT(ct);
@@ -215,6 +216,9 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	if (NF_CT_DIRECTION(hash))
 		goto release;
 
+	if (!net_eq(nf_ct_net(ct), net))
+		goto release;
+
 	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
 	NF_CT_ASSERT(l3proto);
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
-- 
2.1.4
