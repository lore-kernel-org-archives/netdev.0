From: Cong Wang <amwang@redhat.com>
Subject: [RFC Patch net-next 1/5] net: introduce generic union inet_addr
Date: Thu, 27 Jun 2013 14:43:14 +0800
Message-ID: <1372315398-19683-2-git-send-email-amwang@redhat.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>, Rob Landley <rob@landley.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Veaceslav Falico <vfalico@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	George Spelvin <linux@horizon.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Andrei Emeltchenko <andrei.emeltchenko@intel.com>,
	Jan Beulich <jbeulich@suse.com>,
	Eric Dumazet <edumazet@google.com>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372315398-19683-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 Documentation/printk-formats.txt |    9 +++++
 drivers/net/netconsole.c         |   22 ++++++-------
 include/linux/netpoll.h          |    9 +-----
 include/net/inet_addr.h          |   62 ++++++++++++++++++++++++++++++++++++++
 lib/vsprintf.c                   |   18 ++++++++++-
 net/core/netpoll.c               |   52 ++++++++++++++-----------------
 6 files changed, 122 insertions(+), 50 deletions(-)
 create mode 100644 include/net/inet_addr.h

diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
index 3af5ae6..26ff336 100644
--- a/Documentation/printk-formats.txt
+++ b/Documentation/printk-formats.txt
@@ -121,6 +121,15 @@ IPv6 addresses:
 	print a compressed IPv6 address as described by
 	http://tools.ietf.org/html/rfc5952
 
+Generic IP addresses:
+
+	%pIg
+	%pig
+
+	For printing genernic IP address, which has union inet_addr type.
+	The 'Ig' specifier is same with 'I4' (for IPv4 addresses) or 'I6'
+	(for IPv6 address), 'ig' is same with 'i4' or 'i6'.
+
 UUID/GUID addresses:
 
 	%pUb	00010203-0405-0607-0809-0a0b0c0d0e0f
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 1d1d0a1..02d7389 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -269,18 +269,12 @@ static ssize_t show_remote_port(struct netconsole_target *nt, char *buf)
 
 static ssize_t show_local_ip(struct netconsole_target *nt, char *buf)
 {
-	if (nt->np.ipv6)
-		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.local_ip.in6);
-	else
-		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.local_ip);
+	return snprintf(buf, PAGE_SIZE, "%pIg\n", &nt->np.local_ip);
 }
 
 static ssize_t show_remote_ip(struct netconsole_target *nt, char *buf)
 {
-	if (nt->np.ipv6)
-		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.remote_ip.in6);
-	else
-		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.remote_ip);
+	return snprintf(buf, PAGE_SIZE, "%pIg\n", &nt->np.remote_ip);
 }
 
 static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
@@ -418,17 +412,19 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 
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
@@ -449,17 +445,19 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 
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
index e149c64..6bcc7b9 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -27,6 +27,7 @@
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
 #include <net/addrconf.h>
+#include <net/inet_addr.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/sections.h>	/* for dereference_function_descriptor() */
@@ -1004,10 +1005,10 @@ int kptr_restrict __read_mostly;
  * - 'MF' For a 6-byte MAC FDDI address, it prints the address
  *       with a dash-separated hex notation
  * - '[mM]R' For a 6-byte MAC address, Reverse order (Bluetooth)
- * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
+ * - 'I' [46g] for IPv4/IPv6 addresses printed in the usual way
  *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
  *       IPv6 uses colon separated network-order 16 bit hex with leading 0's
- * - 'i' [46] for 'raw' IPv4/IPv6 addresses
+ * - 'i' [46g] for 'raw' IPv4/IPv6 addresses
  *       IPv6 omits the colons (01020304...0f)
  *       IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
  * - '[Ii]4[hnbl]' IPv4 addresses in host, network, big or little endian order
@@ -1093,6 +1094,17 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 			return ip6_addr_string(buf, end, ptr, spec, fmt);
 		case '4':
 			return ip4_addr_string(buf, end, ptr, spec, fmt);
+		case 'g': {
+				union inet_addr *ia = ptr;
+
+				if (ia->sa.sa_family == AF_INET6) {
+					ptr = &ia->sin6.sin6_addr;
+					return ip6_addr_string(buf, end, ptr, spec, fmt);
+				} else {
+					ptr = &ia->sin.sin_addr.s_addr;
+					return ip4_addr_string(buf, end, ptr, spec, fmt);
+				}
+			}
 		}
 		break;
 	case 'U':
@@ -1370,6 +1382,8 @@ qualifier:
  * %pI6 print an IPv6 address with colons
  * %pi6 print an IPv6 address without colons
  * %pI6c print an IPv6 address as specified by RFC 5952
+ * %pIg print generic IP address of union inet_addr, either %pI4 or %pI6
+ * %pig print generic IP address of union inet_addr, either %pi4 or %pi6
  * %pU[bBlL] print a UUID/GUID in big or little endian using lower or upper
  *   case.
  * %*ph[CDN] a variable-length hex string with a separator (supports up to 64
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 03c8ec3..c300358 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -455,8 +455,8 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 
 	if (np->ipv6) {
 		udph->check = 0;
-		udph->check = csum_ipv6_magic(&np->local_ip.in6,
-					      &np->remote_ip.in6,
+		udph->check = csum_ipv6_magic(&np->local_ip.sin6.sin6_addr,
+					      &np->remote_ip.sin6.sin6_addr,
 					      udp_len, IPPROTO_UDP,
 					      csum_partial(udph, udp_len, 0));
 		if (udph->check == 0)
@@ -475,16 +475,16 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
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
@@ -503,8 +503,8 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 		iph->ttl      = 64;
 		iph->protocol = IPPROTO_UDP;
 		iph->check    = 0;
-		put_unaligned(np->local_ip.ip, &(iph->saddr));
-		put_unaligned(np->remote_ip.ip, &(iph->daddr));
+		put_unaligned(np->local_ip.sin.sin_addr.s_addr, &(iph->saddr));
+		put_unaligned(np->remote_ip.sin.sin_addr.s_addr, &(iph->daddr));
 		iph->check    = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
 		eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
@@ -588,7 +588,7 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (tip != np->local_ip.ip)
+			if (tip != np->local_ip.sin.sin_addr.s_addr)
 				continue;
 
 			hlen = LL_RESERVED_SPACE(np->dev);
@@ -676,7 +676,7 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (!ipv6_addr_equal(daddr, &np->local_ip.in6))
+			if (!ipv6_addr_equal(daddr, &np->local_ip.sin6.sin6_addr))
 				continue;
 
 			hlen = LL_RESERVED_SPACE(np->dev);
@@ -826,9 +826,11 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
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
@@ -864,9 +866,9 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
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
@@ -897,16 +899,10 @@ out:
 void netpoll_print_options(struct netpoll *np)
 {
 	np_info(np, "local port %d\n", np->local_port);
-	if (np->ipv6)
-		np_info(np, "local IPv6 address %pI6c\n", &np->local_ip.in6);
-	else
-		np_info(np, "local IPv4 address %pI4\n", &np->local_ip.ip);
+	np_info(np, "local IPv6 address %pIg\n", &np->local_ip);
 	np_info(np, "interface '%s'\n", np->dev_name);
 	np_info(np, "remote port %d\n", np->remote_port);
-	if (np->ipv6)
-		np_info(np, "remote IPv6 address %pI6c\n", &np->remote_ip.in6);
-	else
-		np_info(np, "remote IPv4 address %pI4\n", &np->remote_ip.ip);
+	np_info(np, "remote IPv6 address %pIg\n", &np->remote_ip);
 	np_info(np, "remote ethernet address %pM\n", np->remote_mac);
 }
 EXPORT_SYMBOL(netpoll_print_options);
@@ -920,7 +916,7 @@ static int netpoll_parse_ip_addr(const char *str, union inet_addr *addr)
 		if (!*end)
 			return 0;
 	}
-	if (in6_pton(str, -1, addr->in6.s6_addr, -1, &end) > 0) {
+	if (in6_pton(str, -1, addr->sin6.sin6_addr.s6_addr, -1, &end) > 0) {
 #if IS_ENABLED(CONFIG_IPV6)
 		if (!*end)
 			return 1;
@@ -1139,7 +1135,7 @@ int netpoll_setup(struct netpoll *np)
 		rtnl_lock();
 	}
 
-	if (!np->local_ip.ip) {
+	if (!np->local_ip.sin.sin_addr.s_addr) {
 		if (!np->ipv6) {
 			in_dev = __in_dev_get_rtnl(ndev);
 
@@ -1150,8 +1146,8 @@ int netpoll_setup(struct netpoll *np)
 				goto put;
 			}
 
-			np->local_ip.ip = in_dev->ifa_list->ifa_local;
-			np_info(np, "local IP %pI4\n", &np->local_ip.ip);
+			np->local_ip.sin.sin_addr.s_addr = in_dev->ifa_list->ifa_local;
+			np_info(np, "local IP %pI4\n", &np->local_ip.sin.sin_addr.s_addr);
 		} else {
 #if IS_ENABLED(CONFIG_IPV6)
 			struct inet6_dev *idev;
@@ -1165,7 +1161,7 @@ int netpoll_setup(struct netpoll *np)
 				list_for_each_entry(ifp, &idev->addr_list, if_list) {
 					if (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)
 						continue;
-					np->local_ip.in6 = ifp->addr;
+					np->local_ip.sin6.sin6_addr = ifp->addr;
 					err = 0;
 					break;
 				}
@@ -1176,7 +1172,7 @@ int netpoll_setup(struct netpoll *np)
 				       np->dev_name);
 				goto put;
 			} else
-				np_info(np, "local IPv6 %pI6c\n", &np->local_ip.in6);
+				np_info(np, "local IPv6 %pI6c\n", &np->local_ip.sin6.sin6_addr);
 #else
 			np_err(np, "IPv6 is not supported %s, aborting\n",
 			       np->dev_name);
-- 
1.7.7.6
