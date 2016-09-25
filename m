From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 38/53] netfilter: call nf_hook_state_init with rcu_read_lock held
Date: Mon, 26 Sep 2016 01:06:48 +0200
Message-ID: <1474844823-2026-39-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

This makes things simpler because we can store the head of the list
in the nf_state structure without worrying about concurrent add/delete
of hook elements from the list.

A future commit will make use of this to implement a simpler
linked-list.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h         | 8 +++++++-
 include/linux/netfilter_ingress.h | 1 +
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 9230f9aee896..ad444f0b4ed0 100644
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
index 5fcd375ef175..6965ba09eba7 100644
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
2.1.4

