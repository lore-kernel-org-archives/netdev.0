From: Joe Perches <joe@perches.com>
Subject: [PATCH] net: Convert int functions to bool
Date: Wed, 13 Sep 2017 13:58:15 -0700
Message-ID: <f9e044957a949f10d472a48437f62649ea57f858.1505336212.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Global function ipv6_rcv_saddr_equal and static functions
ipv6_rcv_saddr_equal and ipv4_rcv_saddr_equal currently return int.

bool is slightly more descriptive for these functions so change
their return type from int to bool.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/addrconf.h          |  4 ++--
 net/ipv4/inet_connection_sock.c | 36 ++++++++++++++++++------------------
 2 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index f44ff2476758..87981cd63180 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -94,8 +94,8 @@ int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
 		      u32 banned_flags);
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
 		    u32 banned_flags);
-int inet_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
-			 bool match_wildcard);
+bool inet_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+			  bool match_wildcard);
 void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr);
 void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 4089c013cb03..054b26295638 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -39,11 +39,11 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
  *                          IPV6_ADDR_ANY only equals to IPV6_ADDR_ANY,
  *                          and 0.0.0.0 equals to 0.0.0.0 only
  */
-static int ipv6_rcv_saddr_equal(const struct in6_addr *sk1_rcv_saddr6,
-				const struct in6_addr *sk2_rcv_saddr6,
-				__be32 sk1_rcv_saddr, __be32 sk2_rcv_saddr,
-				bool sk1_ipv6only, bool sk2_ipv6only,
-				bool match_wildcard)
+static bool ipv6_rcv_saddr_equal(const struct in6_addr *sk1_rcv_saddr6,
+				 const struct in6_addr *sk2_rcv_saddr6,
+				 __be32 sk1_rcv_saddr, __be32 sk2_rcv_saddr,
+				 bool sk1_ipv6only, bool sk2_ipv6only,
+				 bool match_wildcard)
 {
 	int addr_type = ipv6_addr_type(sk1_rcv_saddr6);
 	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
@@ -52,29 +52,29 @@ static int ipv6_rcv_saddr_equal(const struct in6_addr *sk1_rcv_saddr6,
 	if (addr_type == IPV6_ADDR_MAPPED && addr_type2 == IPV6_ADDR_MAPPED) {
 		if (!sk2_ipv6only) {
 			if (sk1_rcv_saddr == sk2_rcv_saddr)
-				return 1;
+				return true;
 			if (!sk1_rcv_saddr || !sk2_rcv_saddr)
 				return match_wildcard;
 		}
-		return 0;
+		return false;
 	}
 
 	if (addr_type == IPV6_ADDR_ANY && addr_type2 == IPV6_ADDR_ANY)
-		return 1;
+		return true;
 
 	if (addr_type2 == IPV6_ADDR_ANY && match_wildcard &&
 	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
-		return 1;
+		return true;
 
 	if (addr_type == IPV6_ADDR_ANY && match_wildcard &&
 	    !(sk1_ipv6only && addr_type2 == IPV6_ADDR_MAPPED))
-		return 1;
+		return true;
 
 	if (sk2_rcv_saddr6 &&
 	    ipv6_addr_equal(sk1_rcv_saddr6, sk2_rcv_saddr6))
-		return 1;
+		return true;
 
-	return 0;
+	return false;
 }
 #endif
 
@@ -82,20 +82,20 @@ static int ipv6_rcv_saddr_equal(const struct in6_addr *sk1_rcv_saddr6,
  * match_wildcard == false: addresses must be exactly the same, i.e.
  *                          0.0.0.0 only equals to 0.0.0.0
  */
-static int ipv4_rcv_saddr_equal(__be32 sk1_rcv_saddr, __be32 sk2_rcv_saddr,
-				bool sk2_ipv6only, bool match_wildcard)
+static bool ipv4_rcv_saddr_equal(__be32 sk1_rcv_saddr, __be32 sk2_rcv_saddr,
+				 bool sk2_ipv6only, bool match_wildcard)
 {
 	if (!sk2_ipv6only) {
 		if (sk1_rcv_saddr == sk2_rcv_saddr)
-			return 1;
+			return true;
 		if (!sk1_rcv_saddr || !sk2_rcv_saddr)
 			return match_wildcard;
 	}
-	return 0;
+	return false;
 }
 
-int inet_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
-			 bool match_wildcard)
+bool inet_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+			  bool match_wildcard)
 {
 #if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == AF_INET6)
-- 
2.10.0.rc2.1.g053435c
