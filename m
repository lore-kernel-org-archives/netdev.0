From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 07/10]: [NETFILTER]: Fix xfrm lookup in ip_route_me_harder
Date: Fri, 11 Nov 2005 04:19:31 +0100
Message-ID: <43740DC3.7040604@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="07.diff"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="07.diff"
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Fix xfrm lookup in ip_route_me_harder

ip_route_me_harder uses ip_route_input for non-local addresses, which
doesn't do a xfrm lookup, and doesn't use the port numbers for the
lookup for local addresses. Use xfrm_decode_session and do the lookup
manually.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 909b664477ab16fc04f2bf24ef92676117ccbc26
tree 7085763e2f28f37ffc7f5ce4af044e92f835d03e
parent d14a36982a14bb6695a6ce44fd4f3f4c9aaa6a0c
author Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 03:02:17 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 03:02:17 +0100

 include/net/xfrm.h     |    2 +-
 net/ipv4/netfilter.c   |    7 ++++++-
 net/xfrm/xfrm_policy.c |    8 ++++----
 3 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5beae1c..19d6aa0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -644,7 +644,7 @@ static inline int xfrm6_policy_check(str
 	return xfrm_policy_check(sk, dir, skb, AF_INET6);
 }
 
-
+extern int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family);
 extern int __xfrm_route_forward(struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 3c39296..0f6616f 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -34,7 +34,6 @@ int ip_route_me_harder(struct sk_buff **
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
 #endif
-		fl.proto = iph->protocol;
 		if (ip_route_output_key(&rt, &fl) != 0)
 			return -1;
 
@@ -61,6 +60,12 @@ int ip_route_me_harder(struct sk_buff **
 	if ((*pskb)->dst->error)
 		return -1;
 
+#ifdef CONFIG_XFRM
+	if (xfrm_decode_session(*pskb, &fl, AF_INET) == 0)
+		if (xfrm_lookup(&(*pskb)->dst, &fl, (*pskb)->sk, 0))
+			return -1;
+#endif
+
 	/* Change in oif may mean change in hh_len. */
 	hh_len = (*pskb)->dst->dev->hard_header_len;
 	if (skb_headroom(*pskb) < hh_len) {
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0db9e57..29d1343 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -906,8 +906,8 @@ xfrm_policy_ok(struct xfrm_tmpl *tmpl, s
 	return start;
 }
 
-static int
-_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family)
+int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
+                        unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 
@@ -935,7 +935,7 @@ int __xfrm_policy_check(struct sock *sk,
 	struct xfrm_policy *pol;
 	struct flowi fl;
 
-	if (_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
 
 	/* First, check used SA against their selectors. */
@@ -1007,7 +1007,7 @@ int __xfrm_route_forward(struct sk_buff 
 {
 	struct flowi fl;
 
-	if (_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
 
 	return xfrm_lookup(&skb->dst, &fl, NULL, 0) == 0;
