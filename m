From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH v1 1/4] net/utils: generic inet_pton_with_scope helper
Date: Mon, 27 Feb 2017 19:39:21 +0200
Message-ID: <1488217164-9221-2-git-send-email-sagi@grimberg.me>
References: <1488217164-9221-1-git-send-email-sagi@grimberg.me>
To: linux-nvme@lists.infradead.org, target-devel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:52860 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdB0Rlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 12:41:50 -0500
In-Reply-To: <1488217164-9221-1-git-send-email-sagi@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several locations in the stack need to handle ipv4/ipv6
(with scope) and port strings conversion to sockaddr.
Add a helper that takes either AF_INET, AF_INET6 or
AF_UNSPEC (for wildcard) to centralize this handling.

Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 include/linux/inet.h |   6 +++
 net/core/utils.c     | 103 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 109 insertions(+)

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
index 6592d7bbed39..f96cf527bb8f 100644
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
@@ -300,6 +302,107 @@ int in6_pton(const char *src, int srclen,
 }
 EXPORT_SYMBOL(in6_pton);
 
+static int inet4_pton(const char *src, u16 port_num,
+		struct sockaddr_storage *addr)
+{
+	struct sockaddr_in *addr4 = (struct sockaddr_in *)addr;
+	int srclen = strlen(src);
+
+	if (srclen > INET_ADDRSTRLEN)
+		return -EINVAL;
+
+	if (in4_pton(src, srclen, (u8 *)&addr4->sin_addr.s_addr,
+		     '\n', NULL) == 0)
+		return -EINVAL;
+
+	addr4->sin_family = AF_INET;
+	addr4->sin_port = htons(port_num);
+
+	return 0;
+}
+
+static int inet6_pton(struct net *net, const char *src, u16 port_num,
+		struct sockaddr_storage *addr)
+{
+	struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)addr;
+	const char *scope_delim;
+	int srclen = strlen(src);
+
+	if (srclen > INET6_ADDRSTRLEN)
+		return -EINVAL;
+
+	if (in6_pton(src, srclen, (u8 *)&addr6->sin6_addr.s6_addr,
+		     '%', &scope_delim) == 0)
+		return -EINVAL;
+
+	if (ipv6_addr_type(&addr6->sin6_addr) & IPV6_ADDR_LINKLOCAL &&
+	    src + srclen != scope_delim && *scope_delim == '%') {
+		struct net_device *dev;
+		char scope_id[16];
+		size_t scope_len = min_t(size_t, sizeof(scope_id),
+					 src + srclen - scope_delim - 1);
+
+		memcpy(scope_id, scope_delim + 1, scope_len);
+		scope_id[scope_len] = '\0';
+
+		dev = dev_get_by_name(net, scope_id);
+		if (dev) {
+			addr6->sin6_scope_id = dev->ifindex;
+			dev_put(dev);
+		} else if (kstrtouint(scope_id, 0, &addr6->sin6_scope_id)) {
+			return -EINVAL;
+		}
+	}
+
+	addr6->sin6_family = AF_INET6;
+	addr6->sin6_port = htons(port_num);
+
+	return 0;
+}
+
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
+	u16 port_num;
+	int ret = -EINVAL;
+
+	if (port) {
+		if (kstrtou16(port, 0, &port_num))
+			return -EINVAL;
+	} else {
+		port_num = 0;
+	}
+
+	switch (af) {
+	case AF_INET:
+		ret = inet4_pton(src, port_num, addr);
+		break;
+	case AF_INET6:
+		ret = inet6_pton(net, src, port_num, addr);
+		break;
+	case AF_UNSPEC:
+		ret = inet4_pton(src, port_num, addr);
+		if (ret)
+			ret = inet6_pton(net, src, port_num, addr);
+		break;
+	default:
+		pr_err("unexpected address family %d\n", af);
+	};
+
+	return ret;
+}
+EXPORT_SYMBOL(inet_pton_with_scope);
+
 void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 			      __be32 from, __be32 to, bool pseudohdr)
 {
-- 
2.7.4
