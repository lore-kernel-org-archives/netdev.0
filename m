From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 1/7] net: introduce generic union inet_addr
Date: Mon, 22 Jul 2013 15:05:07 +0800
Message-ID: <1374476713-8838-2-git-send-email-amwang@redhat.com>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>

Introduce a generic IP address type, union inet_addr, so that
subsystems don't have to use their own definitions. Because
netpoll already defines union inet_addr, just move it to global.
Some of the helper functions will be used by VXLAN IPv6 code too.

This patch also reuses the "%pIS" specifier, to make it accept
union inet_addr instead of struct sockaddr.

Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 Documentation/printk-formats.txt |   20 ++++++------
 drivers/net/netconsole.c         |   22 ++++++-------
 include/linux/netpoll.h          |    9 +-----
 include/net/inet_addr.h          |   62 ++++++++++++++++++++++++++++++++++++++
 lib/vsprintf.c                   |   29 ++++++++----------
 net/core/netpoll.c               |   52 ++++++++++++++-----------------
 net/sctp/associola.c             |    6 ++--
 net/sctp/protocol.c              |    6 ++--
 net/sctp/sm_sideeffect.c         |    2 +-
 net/sctp/socket.c                |    4 +-
 10 files changed, 129 insertions(+), 83 deletions(-)
 create mode 100644 include/net/inet_addr.h

diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
index 3e8cb73..3521cc9 100644
--- a/Documentation/printk-formats.txt
+++ b/Documentation/printk-formats.txt
@@ -123,15 +123,15 @@ IPv6 addresses:
 
 IPv4/IPv6 addresses (generic, with port, flowinfo, scope):
 
-	%pIS	1.2.3.4		or 0001:0002:0003:0004:0005:0006:0007:0008
-	%piS	001.002.003.004	or 00010002000300040005000600070008
-	%pISc	1.2.3.4		or 1:2:3:4:5:6:7:8
-	%pISpc	1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345
-	%p[Ii]S[pfschnbl]
+	%pIA	1.2.3.4		or 0001:0002:0003:0004:0005:0006:0007:0008
+	%piA	001.002.003.004	or 00010002000300040005000600070008
+	%pIAc	1.2.3.4		or 1:2:3:4:5:6:7:8
+	%pIApc	1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345
+	%p[Ii]A[pfschnbl]
 
 	For printing an IP address without the need to distinguish whether it's
-	of type AF_INET or AF_INET6, a pointer to a valid 'struct sockaddr',
-	specified through 'IS' or 'iS', can be passed to this format specifier.
+	of type AF_INET or AF_INET6, a pointer to a valid 'union inet_addr',
+	specified through 'IA' or 'iA', can be passed to this format specifier.
 
 	The additional 'p', 'f', and 's' specifiers are used to specify port
 	(IPv4, IPv6), flowinfo (IPv6) and scope (IPv6). Ports have a ':' prefix,
@@ -149,9 +149,9 @@ IPv4/IPv6 addresses (generic, with port, flowinfo, scope):
 
 	Further examples:
 
-	%pISfc		1.2.3.4		or [1:2:3:4:5:6:7:8]/123456789
-	%pISsc		1.2.3.4		or [1:2:3:4:5:6:7:8]%1234567890
-	%pISpfc		1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345/123456789
+	%pIAfc		1.2.3.4		or [1:2:3:4:5:6:7:8]/123456789
+	%pIAsc		1.2.3.4		or [1:2:3:4:5:6:7:8]%1234567890
+	%pIApfc		1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345/123456789
 
 UUID/GUID addresses:
 
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 4822aaf..28234f8 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -270,18 +270,12 @@ static ssize_t show_remote_port(struct netconsole_target *nt, char *buf)
 
 static ssize_t show_local_ip(struct netconsole_target *nt, char *buf)
 {
-	if (nt->np.ipv6)
-		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.local_ip.in6);
-	else
-		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.local_ip);
+	return snprintf(buf, PAGE_SIZE, "%pIA\n", &nt->np.local_ip);
 }
 
 static ssize_t show_remote_ip(struct netconsole_target *nt, char *buf)
 {
-	if (nt->np.ipv6)
-		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.remote_ip.in6);
-	else
-		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.remote_ip);
+	return snprintf(buf, PAGE_SIZE, "%pIA\n", &nt->np.remote_ip);
 }
 
 static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
@@ -419,17 +413,19 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 
 	if (strnchr(buf, count, ':')) {
 		const char *end;
-		if (in6_pton(buf, count, nt->np.local_ip.in6.s6_addr, -1, &end) > 0) {
+		if (in6_pton(buf, count, nt->np.local_ip.sin6.sin6_addr.s6_addr, -1, &end) > 0) {
 			if (*end && *end != '\n') {
 				printk(KERN_ERR "netconsole: invalid IPv6 address at: <%c>\n", *end);
 				return -EINVAL;
 			}
+			nt->np.local_ip.sa.sa_family = AF_INET6;
 			nt->np.ipv6 = true;
 		} else
 			return -EINVAL;
 	} else {
 		if (!nt->np.ipv6) {
-			nt->np.local_ip.ip = in_aton(buf);
+			nt->np.local_ip.sin.sin_addr.s_addr = in_aton(buf);
+			nt->np.local_ip.sa.sa_family = AF_INET;
 		} else
 			return -EINVAL;
 	}
@@ -450,17 +446,19 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 
 	if (strnchr(buf, count, ':')) {
 		const char *end;
-		if (in6_pton(buf, count, nt->np.remote_ip.in6.s6_addr, -1, &end) > 0) {
+		if (in6_pton(buf, count, nt->np.remote_ip.sin6.sin6_addr.s6_addr, -1, &end) > 0) {
 			if (*end && *end != '\n') {
 				printk(KERN_ERR "netconsole: invalid IPv6 address at: <%c>\n", *end);
 				return -EINVAL;
 			}
+			nt->np.remote_ip.sa.sa_family = AF_INET6;
 			nt->np.ipv6 = true;
 		} else
 			return -EINVAL;
 	} else {
 		if (!nt->np.ipv6) {
-			nt->np.remote_ip.ip = in_aton(buf);
+			nt->np.remote_ip.sin.sin_addr.s_addr = in_aton(buf);
+			nt->np.remote_ip.sa.sa_family = AF_INET;
 		} else
 			return -EINVAL;
 	}
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index f3c7c24..3884834 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -11,14 +11,7 @@
 #include <linux/interrupt.h>
 #include <linux/rcupdate.h>
 #include <linux/list.h>
-
-union inet_addr {
-	__u32		all[4];
-	__be32		ip;
-	__be32		ip6[4];
-	struct in_addr	in;
-	struct in6_addr	in6;
-};
+#include <net/inet_addr.h>
 
 struct netpoll {
 	struct net_device *dev;
diff --git a/include/net/inet_addr.h b/include/net/inet_addr.h
new file mode 100644
index 0000000..66a16fe
--- /dev/null
+++ b/include/net/inet_addr.h
@@ -0,0 +1,62 @@
+#ifndef _INET_ADDR_H
+#define _INET_ADDR_H
+
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/socket.h>
+#include <net/addrconf.h>
+
+union inet_addr {
+	struct sockaddr_in sin;
+	struct sockaddr_in6 sin6;
+	struct sockaddr sa;
+};
+
+#if IS_ENABLED(CONFIG_IPV6)
+static inline
+bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b)
+{
+	if (a->sa.sa_family != b->sa.sa_family)
+		return false;
+	if (a->sa.sa_family == AF_INET6)
+		return ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr);
+	else
+		return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
+}
+
+static inline bool inet_addr_any(const union inet_addr *ipa)
+{
+	if (ipa->sa.sa_family == AF_INET6)
+		return ipv6_addr_any(&ipa->sin6.sin6_addr);
+	else
+		return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
+}
+
+static inline bool inet_addr_multicast(const union inet_addr *ipa)
+{
+	if (ipa->sa.sa_family == AF_INET6)
+		return ipv6_addr_is_multicast(&ipa->sin6.sin6_addr);
+	else
+		return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
+}
+
+#else /* !CONFIG_IPV6 */
+
+static inline
+bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b)
+{
+	return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
+}
+
+static inline bool inet_addr_any(const union inet_addr *ipa)
+{
+	return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
+}
+
+static inline bool inet_addr_multicast(const union inet_addr *ipa)
+{
+	return IN_MULTICAST(ntohl(ipa->sin.sin_addr.s_addr));
+}
+#endif
+
+#endif
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 739a363..49618d0 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -27,6 +27,7 @@
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
 #include <net/addrconf.h>
+#include <net/inet_addr.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/sections.h>	/* for dereference_function_descriptor() */
@@ -1104,14 +1105,14 @@ int kptr_restrict __read_mostly;
  * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
  *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
  *       IPv6 uses colon separated network-order 16 bit hex with leading 0's
- *       [S][pfs]
- *       Generic IPv4/IPv6 address (struct sockaddr *) that falls back to
+ *       [A][pfs]
+ *       Generic IPv4/IPv6 address (union inet_addr *) that falls back to
  *       [4] or [6] and is able to print port [p], flowinfo [f], scope [s]
  * - 'i' [46] for 'raw' IPv4/IPv6 addresses
  *       IPv6 omits the colons (01020304...0f)
  *       IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
- *       [S][pfs]
- *       Generic IPv4/IPv6 address (struct sockaddr *) that falls back to
+ *       [A][pfs]
+ *       Generic IPv4/IPv6 address (union inet_addr *) that falls back to
  *       [4] or [6] and is able to print port [p], flowinfo [f], scope [s]
  * - '[Ii][4S][hnbl]' IPv4 addresses in host, network, big or little endian order
  * - 'I[6S]c' for IPv6 addresses printed as specified by
@@ -1196,18 +1197,14 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 			return ip6_addr_string(buf, end, ptr, spec, fmt);
 		case '4':
 			return ip4_addr_string(buf, end, ptr, spec, fmt);
-		case 'S': {
-			const union {
-				struct sockaddr		raw;
-				struct sockaddr_in	v4;
-				struct sockaddr_in6	v6;
-			} *sa = ptr;
-
-			switch (sa->raw.sa_family) {
+		case 'A': {
+			const union inet_addr *sa = ptr;
+
+			switch (sa->sa.sa_family) {
 			case AF_INET:
-				return ip4_addr_string_sa(buf, end, &sa->v4, spec, fmt);
+				return ip4_addr_string_sa(buf, end, &sa->sin, spec, fmt);
 			case AF_INET6:
-				return ip6_addr_string_sa(buf, end, &sa->v6, spec, fmt);
+				return ip6_addr_string_sa(buf, end, &sa->sin6, spec, fmt);
 			default:
 				return string(buf, end, "(invalid address)", spec);
 			}}
@@ -1488,8 +1485,8 @@ qualifier:
  * %pI6 print an IPv6 address with colons
  * %pi6 print an IPv6 address without colons
  * %pI6c print an IPv6 address as specified by RFC 5952
- * %pIS depending on sa_family of 'struct sockaddr *' print IPv4/IPv6 address
- * %piS depending on sa_family of 'struct sockaddr *' print IPv4/IPv6 address
+ * %pIA depending on sa_family of 'union inet_addr *' print IPv4/IPv6 address
+ * %piA depending on sa_family of 'union inet_addr *' print IPv4/IPv6 address
  * %pU[bBlL] print a UUID/GUID in big or little endian using lower or upper
  *   case.
  * %*ph[CDN] a variable-length hex string with a separator (supports up to 64
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 2c637e9..e7d4388 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -456,8 +456,8 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 
 	if (np->ipv6) {
 		udph->check = 0;
-		udph->check = csum_ipv6_magic(&np->local_ip.in6,
-					      &np->remote_ip.in6,
+		udph->check = csum_ipv6_magic(&np->local_ip.sin6.sin6_addr,
+					      &np->remote_ip.sin6.sin6_addr,
 					      udp_len, IPPROTO_UDP,
 					      csum_partial(udph, udp_len, 0));
 		if (udph->check == 0)
@@ -476,16 +476,16 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 		ip6h->payload_len = htons(sizeof(struct udphdr) + len);
 		ip6h->nexthdr = IPPROTO_UDP;
 		ip6h->hop_limit = 32;
-		ip6h->saddr = np->local_ip.in6;
-		ip6h->daddr = np->remote_ip.in6;
+		ip6h->saddr = np->local_ip.sin6.sin6_addr;
+		ip6h->daddr = np->remote_ip.sin6.sin6_addr;
 
 		eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
 		skb_reset_mac_header(skb);
 		skb->protocol = eth->h_proto = htons(ETH_P_IPV6);
 	} else {
 		udph->check = 0;
-		udph->check = csum_tcpudp_magic(np->local_ip.ip,
-						np->remote_ip.ip,
+		udph->check = csum_tcpudp_magic(np->local_ip.sin.sin_addr.s_addr,
+						np->remote_ip.sin.sin_addr.s_addr,
 						udp_len, IPPROTO_UDP,
 						csum_partial(udph, udp_len, 0));
 		if (udph->check == 0)
@@ -504,8 +504,8 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 		iph->ttl      = 64;
 		iph->protocol = IPPROTO_UDP;
 		iph->check    = 0;
-		put_unaligned(np->local_ip.ip, &(iph->saddr));
-		put_unaligned(np->remote_ip.ip, &(iph->daddr));
+		put_unaligned(np->local_ip.sin.sin_addr.s_addr, &(iph->saddr));
+		put_unaligned(np->remote_ip.sin.sin_addr.s_addr, &(iph->daddr));
 		iph->check    = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
 		eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
@@ -589,7 +589,7 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (tip != np->local_ip.ip)
+			if (tip != np->local_ip.sin.sin_addr.s_addr)
 				continue;
 
 			hlen = LL_RESERVED_SPACE(np->dev);
@@ -677,7 +677,7 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (!ipv6_addr_equal(daddr, &np->local_ip.in6))
+			if (!ipv6_addr_equal(daddr, &np->local_ip.sin6.sin6_addr))
 				continue;
 
 			hlen = LL_RESERVED_SPACE(np->dev);
@@ -827,9 +827,11 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 		if (checksum_udp(skb, uh, ulen, iph->saddr, iph->daddr))
 			goto out;
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (np->local_ip.ip && np->local_ip.ip != iph->daddr)
+			__be32 daddr = np->local_ip.sin.sin_addr.s_addr;
+			__be32 saddr = np->remote_ip.sin.sin_addr.s_addr;
+			if (daddr && daddr != iph->daddr)
 				continue;
-			if (np->remote_ip.ip && np->remote_ip.ip != iph->saddr)
+			if (saddr && saddr != iph->saddr)
 				continue;
 			if (np->local_port && np->local_port != ntohs(uh->dest))
 				continue;
@@ -865,9 +867,9 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 		if (udp6_csum_init(skb, uh, IPPROTO_UDP))
 			goto out;
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (!ipv6_addr_equal(&np->local_ip.in6, &ip6h->daddr))
+			if (!ipv6_addr_equal(&np->local_ip.sin6.sin6_addr, &ip6h->daddr))
 				continue;
-			if (!ipv6_addr_equal(&np->remote_ip.in6, &ip6h->saddr))
+			if (!ipv6_addr_equal(&np->remote_ip.sin6.sin6_addr, &ip6h->saddr))
 				continue;
 			if (np->local_port && np->local_port != ntohs(uh->dest))
 				continue;
@@ -898,16 +900,10 @@ out:
 void netpoll_print_options(struct netpoll *np)
 {
 	np_info(np, "local port %d\n", np->local_port);
-	if (np->ipv6)
-		np_info(np, "local IPv6 address %pI6c\n", &np->local_ip.in6);
-	else
-		np_info(np, "local IPv4 address %pI4\n", &np->local_ip.ip);
+	np_info(np, "local IPv6 address %pIA\n", &np->local_ip);
 	np_info(np, "interface '%s'\n", np->dev_name);
 	np_info(np, "remote port %d\n", np->remote_port);
-	if (np->ipv6)
-		np_info(np, "remote IPv6 address %pI6c\n", &np->remote_ip.in6);
-	else
-		np_info(np, "remote IPv4 address %pI4\n", &np->remote_ip.ip);
+	np_info(np, "remote IPv6 address %pIA\n", &np->remote_ip);
 	np_info(np, "remote ethernet address %pM\n", np->remote_mac);
 }
 EXPORT_SYMBOL(netpoll_print_options);
@@ -921,7 +917,7 @@ static int netpoll_parse_ip_addr(const char *str, union inet_addr *addr)
 		if (!*end)
 			return 0;
 	}
-	if (in6_pton(str, -1, addr->in6.s6_addr, -1, &end) > 0) {
+	if (in6_pton(str, -1, addr->sin6.sin6_addr.s6_addr, -1, &end) > 0) {
 #if IS_ENABLED(CONFIG_IPV6)
 		if (!*end)
 			return 1;
@@ -1140,7 +1136,7 @@ int netpoll_setup(struct netpoll *np)
 		rtnl_lock();
 	}
 
-	if (!np->local_ip.ip) {
+	if (!np->local_ip.sin.sin_addr.s_addr) {
 		if (!np->ipv6) {
 			in_dev = __in_dev_get_rtnl(ndev);
 
@@ -1151,8 +1147,8 @@ int netpoll_setup(struct netpoll *np)
 				goto put;
 			}
 
-			np->local_ip.ip = in_dev->ifa_list->ifa_local;
-			np_info(np, "local IP %pI4\n", &np->local_ip.ip);
+			np->local_ip.sin.sin_addr.s_addr = in_dev->ifa_list->ifa_local;
+			np_info(np, "local IP %pI4\n", &np->local_ip.sin.sin_addr.s_addr);
 		} else {
 #if IS_ENABLED(CONFIG_IPV6)
 			struct inet6_dev *idev;
@@ -1166,7 +1162,7 @@ int netpoll_setup(struct netpoll *np)
 				list_for_each_entry(ifp, &idev->addr_list, if_list) {
 					if (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)
 						continue;
-					np->local_ip.in6 = ifp->addr;
+					np->local_ip.sin6.sin6_addr = ifp->addr;
 					err = 0;
 					break;
 				}
@@ -1177,7 +1173,7 @@ int netpoll_setup(struct netpoll *np)
 				       np->dev_name);
 				goto put;
 			} else
-				np_info(np, "local IPv6 %pI6c\n", &np->local_ip.in6);
+				np_info(np, "local IPv6 %pI6c\n", &np->local_ip.sin6.sin6_addr);
 #else
 			np_err(np, "IPv6 is not supported %s, aborting\n",
 			       np->dev_name);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index bce5b79..3084c7c 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -540,7 +540,7 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
 	struct list_head	*pos;
 	struct sctp_transport	*transport;
 
-	pr_debug("%s: association:%p addr:%pISpc\n",
+	pr_debug("%s: association:%p addr:%pIApc\n",
 		 __func__, asoc, &peer->ipaddr.sa);
 
 	/* If we are to remove the current retran_path, update it
@@ -637,7 +637,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 	/* AF_INET and AF_INET6 share common port field. */
 	port = ntohs(addr->v4.sin_port);
 
-	pr_debug("%s: association:%p addr:%pISpc state:%d\n", __func__,
+	pr_debug("%s: association:%p addr:%pIApc state:%d\n", __func__,
 		 asoc, &addr->sa, peer_state);
 
 	/* Set the port if it has not been set yet.  */
@@ -1347,7 +1347,7 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
 	else
 		t = asoc->peer.retran_path;
 
-	pr_debug("%s: association:%p addr:%pISpc\n", __func__, asoc,
+	pr_debug("%s: association:%p addr:%pIApc\n", __func__, asoc,
 		 &t->ipaddr.sa);
 }
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4a17494d..f8953c2 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -604,7 +604,7 @@ static void sctp_addr_wq_timeout_handler(unsigned long arg)
 	spin_lock_bh(&net->sctp.addr_wq_lock);
 
 	list_for_each_entry_safe(addrw, temp, &net->sctp.addr_waitq, list) {
-		pr_debug("%s: the first ent in wq:%p is addr:%pISc for cmd:%d at "
+		pr_debug("%s: the first ent in wq:%p is addr:%pIAc for cmd:%d at "
 			 "entry:%p\n", __func__, &net->sctp.addr_waitq, &addrw->a.sa,
 			 addrw->state, addrw);
 
@@ -709,7 +709,7 @@ void sctp_addr_wq_mgmt(struct net *net, struct sctp_sockaddr_entry *addr, int cm
 	addrw = sctp_addr_wq_lookup(net, addr);
 	if (addrw) {
 		if (addrw->state != cmd) {
-			pr_debug("%s: offsets existing entry for %d, addr:%pISc "
+			pr_debug("%s: offsets existing entry for %d, addr:%pIAc "
 				 "in wq:%p\n", __func__, addrw->state, &addrw->a.sa,
 				 &net->sctp.addr_waitq);
 
@@ -729,7 +729,7 @@ void sctp_addr_wq_mgmt(struct net *net, struct sctp_sockaddr_entry *addr, int cm
 	addrw->state = cmd;
 	list_add_tail(&addrw->list, &net->sctp.addr_waitq);
 
-	pr_debug("%s: add new entry for cmd:%d, addr:%pISc in wq:%p\n",
+	pr_debug("%s: add new entry for cmd:%d, addr:%pIAc in wq:%p\n",
 		 __func__, addrw->state, &addrw->a.sa, &net->sctp.addr_waitq);
 
 	if (!timer_pending(&net->sctp.addr_wq_timer)) {
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 9da6885..14a46d8 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -520,7 +520,7 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
 
 	if (transport->state != SCTP_INACTIVE &&
 	    (transport->error_count > transport->pathmaxrxt)) {
-		pr_debug("%s: association:%p transport addr:%pISpc failed\n",
+		pr_debug("%s: association:%p transport addr:%pIApc failed\n",
 			 __func__, asoc, &transport->ipaddr.sa);
 
 		sctp_assoc_control_transport(asoc, transport,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index c6670d2..5e4402b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -349,7 +349,7 @@ static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 
 	snum = ntohs(addr->v4.sin_port);
 
-	pr_debug("%s: sk:%p, new addr:%pISc, port:%d, new port:%d, len:%d\n",
+	pr_debug("%s: sk:%p, new addr:%pIAc, port:%d, new port:%d, len:%d\n",
 		 __func__, sk, &addr->sa, bp->port, snum, len);
 
 	/* PF specific bind() address verification. */
@@ -803,7 +803,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 				asoc->asconf_addr_del_pending->v6.sin6_addr = sin6->sin6_addr;
 			}
 
-			pr_debug("%s: keep the last address asoc:%p %pISc at %p\n",
+			pr_debug("%s: keep the last address asoc:%p %pIAc at %p\n",
 				 __func__, asoc, &asoc->asconf_addr_del_pending->sa,
 				 asoc->asconf_addr_del_pending);
 
-- 
1.7.7.6
