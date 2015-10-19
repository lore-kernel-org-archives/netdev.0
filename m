From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: sync with packet rx also after removing queue entries
Date: Mon, 19 Oct 2015 20:22:54 +0200
Message-ID: <1445278975-2412-4-git-send-email-pablo@netfilter.org>
References: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37510 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641AbbJSSP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 14:15:57 -0400
In-Reply-To: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We need to sync packet rx again after flushing the queue entries.
Otherwise, the following race could happen:

cpu1: nf_unregister_hook(H) called, H unliked from lists, calls
synchronize_net() to wait for packet rx completion.

Problem is that while no new nf_queue_entry structs that use H can be
allocated, another CPU might receive a verdict from userspace just before
cpu1 calls nf_queue_nf_hook_drop to remove this entry:

cpu2: receive verdict from userspace, lock queue
cpu2: unlink nf_queue_entry struct E, which references H, from queue list
cpu1: calls nf_queue_nf_hook_drop, blocks on queue spinlock
cpu2: unlock queue
cpu1: nf_queue_nf_hook_drop drops affected queue entries
cpu2: call nf_reinject for E
cpu1: kfree(H)
cpu2: potential use-after-free for H

Cc: Eric W. Biederman <ebiederm@xmission.com>
Fixes: 085db2c04557 ("netfilter: Per network namespace netfilter hooks.")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 8e47f81..21a0856 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -152,6 +152,8 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 #endif
 	synchronize_net();
 	nf_queue_nf_hook_drop(net, &entry->ops);
+	/* other cpu might still process nfqueue verdict that used reg */
+	synchronize_net();
 	kfree(entry);
 }
 EXPORT_SYMBOL(nf_unregister_net_hook);
-- 
2.1.4
