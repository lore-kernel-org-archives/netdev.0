From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 35/53] netns xfrm: xfrm_policy_check in netns
Date: Tue, 25 Nov 2008 20:27:07 +0300
Message-ID: <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:41378 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbYKYRZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:05 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23508eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:02 -0800 (PST)
In-Reply-To: <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h     |    3 ++-
 net/xfrm/xfrm_policy.c |    5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1dc4ff0..158848f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -992,12 +992,13 @@ static inline int __xfrm_policy_check2(struct sock *sk, int dir,
 				       struct sk_buff *skb,
 				       unsigned int family, int reverse)
 {
+	struct net *net = dev_net(skb->dev);
 	int ndir = dir | (reverse ? XFRM_POLICY_MASK + 1 : 0);
 
 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
 		return __xfrm_policy_check(sk, ndir, skb, family);
 
-	return	(!init_net.xfrm.policy_count[dir] && !skb->sp) ||
+	return	(!net->xfrm.policy_count[dir] && !skb->sp) ||
 		(skb->dst->flags & DST_NOPOLICY) ||
 		__xfrm_policy_check(sk, ndir, skb, family);
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7c88a25..8097c99 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1894,6 +1894,7 @@ static inline int secpath_has_nontransport(struct sec_path *sp, int k, int *idxp
 int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 			unsigned short family)
 {
+	struct net *net = dev_net(skb->dev);
 	struct xfrm_policy *pol;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	int npols = 0;
@@ -1938,7 +1939,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	}
 
 	if (!pol)
-		pol = flow_cache_lookup(&init_net, &fl, family, fl_dir,
+		pol = flow_cache_lookup(net, &fl, family, fl_dir,
 					xfrm_policy_lookup);
 
 	if (IS_ERR(pol)) {
@@ -1961,7 +1962,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	npols ++;
 #ifdef CONFIG_XFRM_SUB_POLICY
 	if (pols[0]->type != XFRM_POLICY_TYPE_MAIN) {
-		pols[1] = xfrm_policy_lookup_bytype(&init_net, XFRM_POLICY_TYPE_MAIN,
+		pols[1] = xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_MAIN,
 						    &fl, family,
 						    XFRM_POLICY_IN);
 		if (pols[1]) {
-- 
1.5.6.5

