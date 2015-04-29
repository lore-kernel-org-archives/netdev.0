From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: add hook list to nf_hook_state
Date: Wed, 29 Apr 2015 20:53:05 +0200
Message-ID: <1430333589-4940-3-git-send-email-pablo@netfilter.org>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55837 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbbD2Ssv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 14:48:51 -0400
In-Reply-To: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h |    7 +++++--
 net/netfilter/core.c      |    6 ++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 83be4a3..388ed19 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -54,10 +54,12 @@ struct nf_hook_state {
 	struct net_device *in;
 	struct net_device *out;
 	struct sock *sk;
+	struct list_head *hook_list;
 	int (*okfn)(struct sock *, struct sk_buff *);
 };
 
 static inline void nf_hook_state_init(struct nf_hook_state *p,
+				      struct list_head *hook_list,
 				      unsigned int hook,
 				      int thresh, u_int8_t pf,
 				      struct net_device *indev,
@@ -71,6 +73,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 	p->in = indev;
 	p->out = outdev;
 	p->sk = sk;
+	p->hook_list = hook_list;
 	p->okfn = okfn;
 }
 
@@ -166,8 +169,8 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 	if (nf_hooks_active(pf, hook)) {
 		struct nf_hook_state state;
 
-		nf_hook_state_init(&state, hook, thresh, pf,
-				   indev, outdev, sk, okfn);
+		nf_hook_state_init(&state, &nf_hooks[pf][hook], hook, thresh,
+				   pf, indev, outdev, sk, okfn);
 		return nf_hook_slow(skb, &state);
 	}
 	return 1;
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e616301..e418cfd 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -166,11 +166,9 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
 
-	elem = list_entry_rcu(&nf_hooks[state->pf][state->hook],
-			      struct nf_hook_ops, list);
+	elem = list_entry_rcu(state->hook_list, struct nf_hook_ops, list);
 next_hook:
-	verdict = nf_iterate(&nf_hooks[state->pf][state->hook], skb, state,
-			     &elem);
+	verdict = nf_iterate(state->hook_list, skb, state, &elem);
 	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
 		ret = 1;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_DROP) {
-- 
1.7.10.4
