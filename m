From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 3/7] secid reconciliation-v02: Invoke LSM hook for inbound
 traffic
Date: Fri, 08 Sep 2006 11:50:42 -0500
Message-ID: <45019F62.7000305@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:49987 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750958AbWIHQus
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 12:50:48 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Invoke the skb_policy_check LSM hook for inbound (INPUT/FORWARD)
traffic for secid reconciliation and flow control.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/net/xfrm.h |   50 +++++++++++++++++++++++--------------------
 1 file changed, 27 insertions(+), 23 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bf8e2df..7b020bd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -663,22 +663,20 @@ extern int __xfrm_policy_check(struct so
 
 static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
 {
-	if (sk && sk->sk_policy[XFRM_POLICY_IN])
-		return __xfrm_policy_check(sk, dir, skb, family);
-
-	return	(!xfrm_policy_count[dir] && !skb->sp) ||
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
+		ret = __xfrm_policy_check(sk, dir, skb, family);
+	else
+		ret = (!xfrm_policy_count[dir] && !skb->sp) ||
+		      (skb->dst->flags & DST_NOPOLICY) ||
+		      __xfrm_policy_check(sk, dir, skb, family);
+
+#ifdef CONFIG_SECURITY_NETWORK
+	if (ret)
+		ret = security_skb_policy_check(skb, family);
+#endif /* CONFIG_SECURITY_NETWORK */
+	return ret;
 }
 
 extern int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family);
@@ -730,20 +728,26 @@ static inline void xfrm_sk_free_policy(s
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
