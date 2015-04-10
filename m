From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/7] netfilter: add nf_hook_list_active()
Date: Fri, 10 Apr 2015 14:15:37 +0200
Message-ID: <1428668142-4006-3-git-send-email-pablo@netfilter.org>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40063 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755430AbbDJMLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 08:11:46 -0400
In-Reply-To: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to have netfilter ingress per-device hook list.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 63560d0..936f5c2 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -131,26 +131,33 @@ extern struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 #ifdef HAVE_JUMP_LABEL
 extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 
-static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
+static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
+				       u_int8_t pf, unsigned int hook)
 {
 	if (__builtin_constant_p(pf) &&
 	    __builtin_constant_p(hook))
 		return static_key_false(&nf_hooks_needed[pf][hook]);
 
-	return !list_empty(&nf_hooks[pf][hook]);
+	return !list_empty(nf_hook_list);
 }
 #else
-static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
+static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
+				       u_int8_t pf, unsigned int hook)
 {
-	return !list_empty(&nf_hooks[pf][hook]);
+	return !list_empty(nf_hook_list);
 }
 #endif
 
+static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
+{
+	return nf_hook_list_active(&nf_hooks[pf][hook], pf, hook);
+}
+
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
 
 /**
  *	nf_hook_thresh - call a netfilter hook
- *	
+ *
  *	Returns 1 if the hook has allowed the packet to pass.  The function
  *	okfn must be invoked by the caller in this case.  Any other return
  *	value indicates the packet has been consumed by the hook.
-- 
1.7.10.4
