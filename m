From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [RFC 3/3] secid reconciliation on inbound: core networking changes
Date: Tue, 01 Aug 2006 17:08:38 -0500
Message-ID: <44CFD0E6.6010408@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:32838 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751224AbWHAWIu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 18:08:50 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Invoke the skb_policy_check LSM hook from within networking code.

This is being done at the same time and as a part of checking
xfrm policy. This is hopefully adequate (not anticipating
IP protos that don't use xfrm).

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 xfrm.h |   50 +++++-----
 1 file changed, 27 insertions(+), 23 deletions(-)

--- linux-2.6.17.child_sock/include/net/xfrm.h	2006-07-31 09:55:23.000000000 -0500
+++ linux-2.6.17/include/net/xfrm.h	2006-08-01 15:08:20.000000000 -0500
@@ -690,22 +690,20 @@ extern int __xfrm_policy_check(struct so
 
 static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
 {
-	if (sk && sk->sk_policy[XFRM_POLICY_IN])
-		return __xfrm_policy_check(sk, dir, skb, family);
-		
-	return	(!xfrm_policy_list[dir] && !skb->sp) ||
-		(skb->dst->flags & DST_NOPOLICY) ||
-		__xfrm_policy_check(sk, dir, skb, family);
-}
-
-static inline int xfrm4_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
-{
-	return xfrm_policy_check(sk, dir, skb, AF_INET);
-}
+	int ret;
 
-static inline int xfrm6_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
-{
-	return xfrm_policy_check(sk, dir, skb, AF_INET6);
+	if (sk && sk->sk_policy[XFRM_POLICY_IN])
+		ret =  __xfrm_policy_check(sk, dir, skb, family);
+	else
+		ret = (!xfrm_policy_list[dir] && !skb->sp) ||
+			(skb->dst->flags & DST_NOPOLICY) ||
+			__xfrm_policy_check(sk, dir, skb, family);
+
+#ifdef CONFIG_SECURITY_NETWORK
+	if (ret)
+		ret = security_skb_policy_check(skb, family);
+#endif /* CONFIG_SECURITY_NETWORK */
+	return ret;
 }
 
 extern int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family);
@@ -757,20 +755,26 @@ static inline void xfrm_sk_free_policy(s
 static inline int xfrm_sk_clone_policy(struct sock *sk) { return 0; }
 static inline int xfrm6_route_forward(struct sk_buff *skb) { return 1; }  
 static inline int xfrm4_route_forward(struct sk_buff *skb) { return 1; } 
-static inline int xfrm6_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
-{ 
-	return 1; 
-} 
-static inline int xfrm4_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
-{
-	return 1;
-}
 static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
 {
+#ifdef CONFIG_SECURITY_NETWORK
+	return security_skb_policy_check(skb, family);
+#else
 	return 1;
+#endif /* CONFIG_SECURITY_NETWORK */
 }
 #endif
 
+static inline int xfrm4_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
+{
+	return xfrm_policy_check(sk, dir, skb, AF_INET);
+}
+
+static inline int xfrm6_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
+{
+	return xfrm_policy_check(sk, dir, skb, AF_INET6);
+}
+
 static __inline__
 xfrm_address_t *xfrm_flowi_daddr(struct flowi *fl, unsigned short family)
 {
