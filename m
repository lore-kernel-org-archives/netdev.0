From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 2/7] net: introduce generic simple_inet_pton()
Date: Mon, 22 Jul 2013 15:05:08 +0800
Message-ID: <1374476713-8838-3-git-send-email-amwang@redhat.com>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756456Ab3GVHFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 03:05:41 -0400
In-Reply-To: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

simple_inet_pton() is a simple implementation of inet_pton()
in kernel, the original code is already in netpoll, so just move
it to global.

Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/inet_addr.h |    3 +++
 net/core/netpoll.c      |   36 ++++++++----------------------------
 net/core/utils.c        |   36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+), 28 deletions(-)

diff --git a/include/net/inet_addr.h b/include/net/inet_addr.h
index 66a16fe..3416f65 100644
--- a/include/net/inet_addr.h
+++ b/include/net/inet_addr.h
@@ -4,6 +4,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/socket.h>
+#include <linux/inet.h>
 #include <net/addrconf.h>
 
 union inet_addr {
@@ -59,4 +60,6 @@ static inline bool inet_addr_multicast(const union inet_addr *ipa)
 }
 #endif
 
+extern int simple_inet_pton(const char *str, union inet_addr *addr);
+
 #endif
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index e7d4388..67174c4 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -908,30 +908,10 @@ void netpoll_print_options(struct netpoll *np)
 }
 EXPORT_SYMBOL(netpoll_print_options);
 
-static int netpoll_parse_ip_addr(const char *str, union inet_addr *addr)
-{
-	const char *end;
-
-	if (!strchr(str, ':') &&
-	    in4_pton(str, -1, (void *)addr, -1, &end) > 0) {
-		if (!*end)
-			return 0;
-	}
-	if (in6_pton(str, -1, addr->sin6.sin6_addr.s6_addr, -1, &end) > 0) {
-#if IS_ENABLED(CONFIG_IPV6)
-		if (!*end)
-			return 1;
-#else
-		return -1;
-#endif
-	}
-	return -1;
-}
-
 int netpoll_parse_options(struct netpoll *np, char *opt)
 {
 	char *cur=opt, *delim;
-	int ipv6;
+	int ret;
 
 	if (*cur != '@') {
 		if ((delim = strchr(cur, '@')) == NULL)
@@ -947,11 +927,11 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		if ((delim = strchr(cur, '/')) == NULL)
 			goto parse_failed;
 		*delim = 0;
-		ipv6 = netpoll_parse_ip_addr(cur, &np->local_ip);
-		if (ipv6 < 0)
+		ret = simple_inet_pton(cur, &np->local_ip);
+		if (ret < 0)
 			goto parse_failed;
 		else
-			np->ipv6 = (bool)ipv6;
+			np->ipv6 = np->local_ip.sa.sa_family == AF_INET6;
 		cur = delim;
 	}
 	cur++;
@@ -983,13 +963,13 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	if ((delim = strchr(cur, '/')) == NULL)
 		goto parse_failed;
 	*delim = 0;
-	ipv6 = netpoll_parse_ip_addr(cur, &np->remote_ip);
-	if (ipv6 < 0)
+	ret = simple_inet_pton(cur, &np->remote_ip);
+	if (ret < 0)
 		goto parse_failed;
-	else if (np->ipv6 != (bool)ipv6)
+	else if (np->ipv6 != (np->local_ip.sa.sa_family == AF_INET6))
 		goto parse_failed;
 	else
-		np->ipv6 = (bool)ipv6;
+		np->ipv6 = np->local_ip.sa.sa_family == AF_INET6;
 	cur = delim + 1;
 
 	if (*cur != 0) {
diff --git a/net/core/utils.c b/net/core/utils.c
index aa88e23..22dd621 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -29,6 +29,7 @@
 
 #include <net/sock.h>
 #include <net/net_ratelimit.h>
+#include <net/inet_addr.h>
 
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
@@ -338,3 +339,38 @@ void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 				  csum_unfold(*sum)));
 }
 EXPORT_SYMBOL(inet_proto_csum_replace16);
+
+/**
+ * simple_inet_pton - a simple implementation of inet_pton()
+ * @str: the start of the IPv4 or IPv6 address string
+ * @addr: a pointer to union inet_addr
+ *
+ * Return zero on success, callers should check addr->sa.sa_family
+ * to know if the address is IPv4 or IPv6; return negative when
+ * any error occurs.
+ *
+ */
+int simple_inet_pton(const char *str, union inet_addr *addr)
+{
+	const char *end;
+
+	if (!strchr(str, ':') &&
+	    in4_pton(str, -1, (void *)addr, -1, &end) > 0) {
+		if (!*end) {
+			addr->sa.sa_family = AF_INET;
+			return 0;
+		}
+	}
+	if (in6_pton(str, -1, addr->sin6.sin6_addr.s6_addr, -1, &end) > 0) {
+#if IS_ENABLED(CONFIG_IPV6)
+		if (!*end) {
+			addr->sa.sa_family = AF_INET6;
+			return 0;
+		}
+#else
+		return -EAFNOSUPPORT;
+#endif
+	}
+	return -EINVAL;
+}
+EXPORT_SYMBOL(simple_inet_pton);
-- 
1.7.7.6
