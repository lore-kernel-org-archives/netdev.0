From: Cong Wang <amwang@redhat.com>
Subject: [RFC Patch net-next 2/5] net: introduce generic inet_pton()
Date: Thu, 27 Jun 2013 14:43:15 +0800
Message-ID: <1372315398-19683-3-git-send-email-amwang@redhat.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372315398-19683-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/inet_addr.h |   20 ++++++++++++++++++++
 net/core/netpoll.c      |   24 ++----------------------
 2 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/include/net/inet_addr.h b/include/net/inet_addr.h
index 66a16fe..1379287 100644
--- a/include/net/inet_addr.h
+++ b/include/net/inet_addr.h
@@ -4,6 +4,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/socket.h>
+#include <linux/inet.h>
 #include <net/addrconf.h>
 
 union inet_addr {
@@ -59,4 +60,23 @@ static inline bool inet_addr_multicast(const union inet_addr *ipa)
 }
 #endif
 
+static inline int inet_pton(const char *str, union inet_addr *addr)
+{
+	const char *end;
+
+	if (!strchr(str, ':') &&
+	    in4_pton(str, -1, (void *)addr, -1, &end) > 0) {
+		if (!*end)
+			return 0;
+	}
+	if (in6_pton(str, -1, addr->sin6.sin6_addr.s6_addr, -1, &end) > 0) {
+#if IS_ENABLED(CONFIG_IPV6)
+		if (!*end)
+			return 1;
+#else
+		return -1;
+#endif
+	}
+	return -1;
+}
 #endif
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index c300358..6631b5e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -907,26 +907,6 @@ void netpoll_print_options(struct netpoll *np)
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
@@ -946,7 +926,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		if ((delim = strchr(cur, '/')) == NULL)
 			goto parse_failed;
 		*delim = 0;
-		ipv6 = netpoll_parse_ip_addr(cur, &np->local_ip);
+		ipv6 = inet_pton(cur, &np->local_ip);
 		if (ipv6 < 0)
 			goto parse_failed;
 		else
@@ -982,7 +962,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	if ((delim = strchr(cur, '/')) == NULL)
 		goto parse_failed;
 	*delim = 0;
-	ipv6 = netpoll_parse_ip_addr(cur, &np->remote_ip);
+	ipv6 = inet_pton(cur, &np->remote_ip);
 	if (ipv6 < 0)
 		goto parse_failed;
 	else if (np->ipv6 != (bool)ipv6)
-- 
1.7.7.6
