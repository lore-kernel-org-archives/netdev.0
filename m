From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/18] netfilter: kill nf_hooks_active
Date: Tue,  4 Aug 2015 12:02:31 +0200
Message-ID: <1438682568-8346-2-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55944 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932950AbbHDJ5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:09 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

The function obscures what is going on in nf_hook_thresh and it's existence
requires computing the hook list twice.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 00050df..60e89348 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -150,11 +150,6 @@ static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
 }
 #endif
 
-static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
-{
-	return nf_hook_list_active(&nf_hooks[pf][hook], pf, hook);
-}
-
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
 
 /**
@@ -172,10 +167,12 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 int (*okfn)(struct sock *, struct sk_buff *),
 				 int thresh)
 {
-	if (nf_hooks_active(pf, hook)) {
+	struct list_head *nf_hook_list = &nf_hooks[pf][hook];
+
+	if (nf_hook_list_active(nf_hook_list, pf, hook)) {
 		struct nf_hook_state state;
 
-		nf_hook_state_init(&state, &nf_hooks[pf][hook], hook, thresh,
+		nf_hook_state_init(&state, nf_hook_list, hook, thresh,
 				   pf, indev, outdev, sk, okfn);
 		return nf_hook_slow(skb, &state);
 	}
-- 
1.7.10.4
