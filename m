From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/10] netfilter: don't call hooks unless needed
Date: Tue,  8 Mar 2016 11:00:49 +0100
Message-ID: <1457431250-3086-10-git-send-email-pablo@netfilter.org>
References: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

With the previous patches in place, a netns nf_hook_list might be empty,
even if e.g. init_net performs filtering.

Thus change nf_hook_thresh to check the hook_list as well before
initializing hook_state and calling nf_hook_slow().

We still make use of static keys; if no netfilter modules are loaded
list is guaranteed to be empty.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 0ad5567..9230f9a 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -141,22 +141,6 @@ void nf_unregister_sockopt(struct nf_sockopt_ops *reg);
 
 #ifdef HAVE_JUMP_LABEL
 extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
-
-static inline bool nf_hook_list_active(struct list_head *hook_list,
-				       u_int8_t pf, unsigned int hook)
-{
-	if (__builtin_constant_p(pf) &&
-	    __builtin_constant_p(hook))
-		return static_key_false(&nf_hooks_needed[pf][hook]);
-
-	return !list_empty(hook_list);
-}
-#else
-static inline bool nf_hook_list_active(struct list_head *hook_list,
-				       u_int8_t pf, unsigned int hook)
-{
-	return !list_empty(hook_list);
-}
 #endif
 
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
@@ -177,9 +161,18 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 int (*okfn)(struct net *, struct sock *, struct sk_buff *),
 				 int thresh)
 {
-	struct list_head *hook_list = &net->nf.hooks[pf][hook];
+	struct list_head *hook_list;
+
+#ifdef HAVE_JUMP_LABEL
+	if (__builtin_constant_p(pf) &&
+	    __builtin_constant_p(hook) &&
+	    !static_key_false(&nf_hooks_needed[pf][hook]))
+		return 1;
+#endif
+
+	hook_list = &net->nf.hooks[pf][hook];
 
-	if (nf_hook_list_active(hook_list, pf, hook)) {
+	if (!list_empty(hook_list)) {
 		struct nf_hook_state state;
 
 		nf_hook_state_init(&state, hook_list, hook, thresh,
-- 
2.1.4

