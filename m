From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] netfilter: conntrack: avoid integer overflow when resizing
Date: Tue, 12 Jul 2016 18:10:59 +0200
Message-ID: <1468339862-4028-4-git-send-email-pablo@netfilter.org>
References: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49144 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753847AbcGLQLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 12:11:16 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 789C3E7DA4
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 18:11:15 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 51737FAB5F
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 18:11:15 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1F7B7FAB55
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 18:11:13 +0200 (CEST)
In-Reply-To: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Can overflow so we might allocate very small table when bucket count is
high on a 32bit platform.

Note: resize is only possible from init_netns.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f204274..62c42e9 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1601,8 +1601,15 @@ void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
 	unsigned int nr_slots, i;
 	size_t sz;
 
+	if (*sizep > (UINT_MAX / sizeof(struct hlist_nulls_head)))
+		return NULL;
+
 	BUILD_BUG_ON(sizeof(struct hlist_nulls_head) != sizeof(struct hlist_head));
 	nr_slots = *sizep = roundup(*sizep, PAGE_SIZE / sizeof(struct hlist_nulls_head));
+
+	if (nr_slots > (UINT_MAX / sizeof(struct hlist_nulls_head)))
+		return NULL;
+
 	sz = nr_slots * sizeof(struct hlist_nulls_head);
 	hash = (void *)__get_free_pages(GFP_KERNEL | __GFP_NOWARN | __GFP_ZERO,
 					get_order(sz));
-- 
2.1.4
