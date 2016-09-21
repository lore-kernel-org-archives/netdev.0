From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next v3 2/7] netfilter: call nf_hook_state_init with rcu_read_lock held
Date: Wed, 21 Sep 2016 11:35:02 -0400
Message-ID: <1474472107-12992-3-git-send-email-aconole@bytheb.org>
References: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f193.google.com ([209.85.213.193]:36269 "EHLO
        mail-yb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757244AbcIUPfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:35:44 -0400
Received: by mail-yb0-f193.google.com with SMTP id u125so1748430ybg.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 08:35:44 -0700 (PDT)
In-Reply-To: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This makes things simpler because we can store the head of the list
in the nf_state structure without worrying about concurrent add/delete
of hook elements from the list.

A future commit will make use of this to implement a simpler
linked-list.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 include/linux/netfilter.h         | 8 +++++++-
 include/linux/netfilter_ingress.h | 1 +
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 9230f9a..ad444f0 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -174,10 +174,16 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 
 	if (!list_empty(hook_list)) {
 		struct nf_hook_state state;
+		int ret;
 
+		/* We may already have this, but read-locks nest anyway */
+		rcu_read_lock();
 		nf_hook_state_init(&state, hook_list, hook, thresh,
 				   pf, indev, outdev, sk, net, okfn);
-		return nf_hook_slow(skb, &state);
+
+		ret = nf_hook_slow(skb, &state);
+		rcu_read_unlock();
+		return ret;
 	}
 	return 1;
 }
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
index 5fcd375..6965ba0 100644
--- a/include/linux/netfilter_ingress.h
+++ b/include/linux/netfilter_ingress.h
@@ -14,6 +14,7 @@ static inline bool nf_hook_ingress_active(const struct sk_buff *skb)
 	return !list_empty(&skb->dev->nf_hooks_ingress);
 }
 
+/* caller must hold rcu_read_lock */
 static inline int nf_hook_ingress(struct sk_buff *skb)
 {
 	struct nf_hook_state state;
-- 
2.7.4
