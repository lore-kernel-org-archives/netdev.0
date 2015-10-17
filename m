From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/35] netfilter: nfqueue: don't use prev pointer
Date: Sat, 17 Oct 2015 13:32:52 +0200
Message-ID: <1445081590-2924-18-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48392 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752712AbbJQL0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:23 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Usage of -prev seems buggy.  While packet was out our hook cannot be
removed but we have no way to know if the previous one is still valid.

So better not use ->prev at all.  Since NF_REPEAT just asks to invoke
same hook function again, just do so, and continue with nf_interate
if we get an ACCEPT verdict.

A side effect of this change is that if nf_reinject(NF_REPEAT) causes
another REPEAT we will now drop the skb instead of a kernel loop.

However, NF_REPEAT loops would be a bug so this should not happen anyway.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_queue.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 34f628e..634d18e 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -192,10 +192,8 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	nf_queue_entry_release_refs(entry);
 
 	/* Continue traversal iff userspace said ok... */
-	if (verdict == NF_REPEAT) {
-		elem = list_entry(elem->list.prev, struct nf_hook_ops, list);
-		verdict = NF_ACCEPT;
-	}
+	if (verdict == NF_REPEAT)
+		verdict = elem->hook(elem->priv, skb, &entry->state);
 
 	if (verdict == NF_ACCEPT) {
 		afinfo = nf_get_afinfo(entry->state.pf);
-- 
2.1.4
