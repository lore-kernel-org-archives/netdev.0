From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH rfc 1/4] net/utils: generic inet_pton_with_scope helper
Date: Thu, 16 Feb 2017 19:43:34 +0200
Message-ID: <1487267017-29904-2-git-send-email-sagi@grimberg.me>
References: <1487267017-29904-1-git-send-email-sagi@grimberg.me>
To: linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1487267017-29904-1-git-send-email-sagi@grimberg.me>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several locations in the stack need to handle ipv4/ipv6
(with scope) and port strings conversion to sockaddr.
Add a helper that takes either AF_INET, AF_INET6 or
AF_UNSPEC (for wildcard) to centralize this handling.

Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 include/linux/inet.h |  6 ++++
 net/core/utils.c     | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 97 insertions(+)

diff --git a/include/linux/inet.h b/include/linux/inet.h
index 4cca05c9678e..636ebe87e6f8 100644
--- a/include/linux/inet.h
+++ b/include/linux/inet.h
@@ -43,6 +43,8 @@
 #define _LINUX_INET_H
 
 #include <linux/types.h>
+#include <net/net_namespace.h>
+#include <linux/socket.h>
 
 /*
  * These mimic similar macros defined in user-space for inet_ntop(3).
@@ -54,4 +56,8 @@
 extern __be32 in_aton(const char *str);
 extern int in4_pton(const char *src, int srclen, u8 *dst, int delim, const char **end);
 extern int in6_pton(const char *src, int srclen, u8 *dst, int delim, const char **end);
+
+extern int inet_pton_with_scope(struct net *net, unsigned short af,
+		const char *src, const char *port, struct sockaddr_storage *addr);
+
 #endif	/* _LINUX_INET_H */
diff --git a/net/core/utils.c b/net/core/utils.c
index 6592d7bbed39..8f15d016c64a 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -26,9 +26,11 @@
 #include <linux/percpu.h>
 #include <linux/init.h>
 #include <linux/ratelimit.h>
+#include <linux/socket.h>
 
 #include <net/sock.h>
 #include <net/net_ratelimit.h>
+#include <net/ipv6.h>
 
 #include <asm/byteorder.h>
 #include <linux/uaccess.h>
@@ -300,6 +302,95 @@ int in6_pton(const char *src, int srclen,
 }
 EXPORT_SYMBOL(in6_pton);
 
+/**
+ * inet_pton_with_scope - convert an IPv4/IPv6 and port to socket address
+ * @net: net namespace (used for scope handling)
+ * @af: address family, AF_INET, AF_INET6 or AF_UNSPEC for either
+ * @src: the start of the address string
+ * @port: the start of the port string (or NULL for none)
+ * @addr: output socket address
+ *
+ * Return zero on success, return errno when any error occurs.
+ */
+int inet_pton_with_scope(struct net *net, __kernel_sa_family_t af,
+		const char *src, const char *port, struct sockaddr_storage *addr)
+{
+	struct sockaddr_in *addr4;
+	struct sockaddr_in6 *addr6;
+	const char *scope_delim;
+	bool unspec = false;
+	int srclen = strlen(src);
+	u16 port_num;
+
+	if (port) {
+		if (kstrtou16(port, 0, &port_num)) {
+			pr_err("failed port_num %s\n", port);
+			return -EINVAL;
+		}
+	} else {
+		port_num = 0;
+	}
+
+	switch (af) {
+	case AF_UNSPEC:
+		unspec = true;
+		/* FALLTHRU */
+	case AF_INET:
+		if (srclen <= INET_ADDRSTRLEN) {
+			addr4 = (struct sockaddr_in *)addr;
+			if (in4_pton(src, srclen, (u8 *) &addr4->sin_addr.s_addr,
+				     '\n', NULL) > 0) {
+				addr4->sin_family = AF_INET;
+				addr4->sin_port = htons(port_num);
+				return 0;
+			}
+			pr_err("failed in4_pton %s\n", src);
+		}
+		if (!unspec)
+			break;
+	case AF_INET6:
+		if (srclen <= INET6_ADDRSTRLEN) {
+			addr6 = (struct sockaddr_in6 *)addr;
+			if (in6_pton(src, srclen, (u8 *) &addr6->sin6_addr.s6_addr,
+				     '%', &scope_delim) == 0) {
+				pr_err("failed in6_pton %s\n", src);
+				return -EINVAL;
+			}
+
+			if (ipv6_addr_type(&addr6->sin6_addr) & IPV6_ADDR_LINKLOCAL &&
+			    src + srclen != scope_delim && *scope_delim == '%') {
+				struct net_device *dev;
+				char scope_id[16];
+				size_t scope_len = min_t(size_t, sizeof scope_id,
+							 src + srclen - scope_delim - 1);
+
+				memcpy(scope_id, scope_delim + 1, scope_len);
+				scope_id[scope_len] = '\0';
+
+				dev = dev_get_by_name(net, scope_id);
+				if (dev) {
+					addr6->sin6_scope_id = dev->ifindex;
+					dev_put(dev);
+				} else if (kstrtouint(scope_id, 0, &addr6->sin6_scope_id)) {
+					pr_err("failed dev_get_by_name %s\n", scope_id);
+					return -EINVAL;
+				}
+			}
+
+			addr6->sin6_family = AF_INET6;
+			addr6->sin6_port = htons(port_num);
+
+			return 0;
+		}
+		break;
+	default:
+		pr_err("unexpected address family %d\n", af);
+	};
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(inet_pton_with_scope);
+
 void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 			      __be32 from, __be32 to, bool pseudohdr)
 {
-- 
2.7.4
