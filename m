From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/50] netfilter: decouple nf_hook_entry and nf_hook_ops
Date: Wed,  7 Dec 2016 22:52:27 +0100
Message-ID: <1481147576-5690-22-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60190 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933364AbcLGVxl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:41 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C9BD4B6C93
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B98A0DA848
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9BB95DA849
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:34 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@redhat.com>

During nfhook traversal we only need a very small subset of
nf_hook_ops members.

We need:
- next element
- hook function to call
- hook function priv argument

Bridge netfilter also needs 'thresh'; can be obtained via ->orig_ops.

nf_hook_entry struct is now 32 bytes on x86_64.

A followup patch will turn the run-time list into an array that only
stores hook functions plus their priv arguments, eliminating the ->next
element.

Suggested-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 575aa198097e..a4b97be30b28 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -75,7 +75,8 @@ struct nf_hook_ops {
 
 struct nf_hook_entry {
 	struct nf_hook_entry __rcu	*next;
-	struct nf_hook_ops		ops;
+	nf_hookfn			*hook;
+	void				*priv;
 	const struct nf_hook_ops	*orig_ops;
 };
 
@@ -83,21 +84,22 @@ static inline void
 nf_hook_entry_init(struct nf_hook_entry *entry,	const struct nf_hook_ops *ops)
 {
 	entry->next = NULL;
-	entry->ops = *ops;
+	entry->hook = ops->hook;
+	entry->priv = ops->priv;
 	entry->orig_ops = ops;
 }
 
 static inline int
 nf_hook_entry_priority(const struct nf_hook_entry *entry)
 {
-	return entry->ops.priority;
+	return entry->orig_ops->priority;
 }
 
 static inline int
 nf_hook_entry_hookfn(const struct nf_hook_entry *entry, struct sk_buff *skb,
 		     struct nf_hook_state *state)
 {
-	return entry->ops.hook(entry->ops.priv, skb, state);
+	return entry->hook(entry->priv, skb, state);
 }
 
 static inline const struct nf_hook_ops *
-- 
2.1.4
