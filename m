From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 3/7] secid reconciliation-v03: Invoke LSM hook for inbound
 traffic
Date: Thu, 28 Sep 2006 21:33:02 -0500
Message-ID: <451C85DE.6050705@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:112 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161290AbWI2CdT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 22:33:19 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Invoke the skb_flow_in LSM hook for inbound
traffic for secid reconciliation and flow control.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/net/xfrm.h |   45 +++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 23 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 11e0b1d..8f9c184 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -675,22 +675,18 @@ extern int __xfrm_policy_check(struct so
 
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
+	if (ret)
+		ret = security_skb_flow_in(skb, family);
+	return ret;
 }
 
 extern int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family);
@@ -742,19 +738,22 @@ static inline void xfrm_sk_free_policy(s
 static inline int xfrm_sk_clone_policy(struct sock *sk) { return 0; }
 static inline int xfrm6_route_forward(struct sk_buff *skb) { return 1; }  
 static inline int xfrm4_route_forward(struct sk_buff *skb) { return 1; } 
-static inline int xfrm6_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
-{ 
-	return 1; 
-} 
+static inline int xfrm_policy_check(struct sock *sk, int dir,
+		struct sk_buff *skb, unsigned short family)
+{
+	return security_skb_flow_in(skb, family);
+}
+#endif
+
 static inline int xfrm4_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
 {
-	return 1;
+	return xfrm_policy_check(sk, dir, skb, AF_INET);
 }
-static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
+
+static inline int xfrm6_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
 {
-	return 1;
+	return xfrm_policy_check(sk, dir, skb, AF_INET6);
 }
-#endif
 
 static __inline__
 xfrm_address_t *xfrm_flowi_daddr(struct flowi *fl, unsigned short family)
