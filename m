From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/7] netfilter: nf_ct_helper: bail out on duplicated helpers
Date: Wed,  1 Jun 2016 14:03:24 +0200
Message-ID: <1464782604-19346-8-git-send-email-pablo@netfilter.org>
References: <1464782604-19346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52884 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932358AbcFAMDm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 08:03:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id D367A129E154
	for <netdev@vger.kernel.org>; Wed,  1 Jun 2016 14:03:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BF5712310A4
	for <netdev@vger.kernel.org>; Wed,  1 Jun 2016 14:03:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 658612310A4
	for <netdev@vger.kernel.org>; Wed,  1 Jun 2016 14:03:35 +0200 (CEST)
In-Reply-To: <1464782604-19346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't allow registration of helpers using the same tuple:

	{ l3proto, l4proto, src-port }

We lookup for the helper from the packet path using this tuple through
__nf_ct_helper_find(). Therefore, we have to avoid having two helpers
with the same tuple to ensure predictible behaviour.

Don't compare the helper string names anymore since it is valid to
register two helpers with the same name, but using different tuples.
This is also implicitly fixing up duplicated helper registration via
ports= modparam since the name comparison was defeating the tuple
duplication validation.

Reported-by: Feng Gao <gfree.wind@gmail.com>
Reported-by: Taehee Yoo <ap420073@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 3b40ec5..48de9be 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -361,9 +361,10 @@ EXPORT_SYMBOL_GPL(nf_ct_helper_log);
 
 int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 {
-	int ret = 0;
-	struct nf_conntrack_helper *cur;
+	struct nf_conntrack_tuple_mask mask = { .src.u.all = htons(0xFFFF) };
 	unsigned int h = helper_hash(&me->tuple);
+	struct nf_conntrack_helper *cur;
+	int ret = 0;
 
 	BUG_ON(me->expect_policy == NULL);
 	BUG_ON(me->expect_class_max >= NF_CT_MAX_EXPECT_CLASSES);
@@ -371,9 +372,7 @@ int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 
 	mutex_lock(&nf_ct_helper_mutex);
 	hlist_for_each_entry(cur, &nf_ct_helper_hash[h], hnode) {
-		if (strncmp(cur->name, me->name, NF_CT_HELPER_NAME_LEN) == 0 &&
-		    cur->tuple.src.l3num == me->tuple.src.l3num &&
-		    cur->tuple.dst.protonum == me->tuple.dst.protonum) {
+		if (nf_ct_tuple_src_mask_cmp(&cur->tuple, &me->tuple, &mask)) {
 			ret = -EEXIST;
 			goto out;
 		}
-- 
2.1.4
