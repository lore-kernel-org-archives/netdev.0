From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 1/9] net: introduce generic union inet_addr
Date: Mon, 19 Aug 2013 18:14:30 +0800
Message-ID: <1376907278-26377-2-git-send-email-amwang@redhat.com>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276Ab3HSKOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 06:14:51 -0400
In-Reply-To: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Introduce a generic IP address type, union inet_addr, so that
subsystems don't have to use their own definitions. Because
netpoll already defines union inet_addr, just move it to global.
Some of the helper functions will be used by VXLAN IPv6 code too.

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/netconsole.c |   20 +++++++++------
 include/linux/netpoll.h  |    9 +------
 include/net/inet_addr.h  |   62 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/netpoll.c       |   50 +++++++++++++++++++-----------------
 4 files changed, 101 insertions(+), 40 deletions(-)
 create mode 100644 include/net/inet_addr.h

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 4822aaf..e4eac0c 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -271,17 +271,17 @@ static ssize_t show_remote_port(struct netconsole_target *nt, char *buf)
 static ssize_t show_local_ip(struct netconsole_target *nt, char *buf)
 {
 	if (nt->np.ipv6)
-		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.local_ip.in6);
+		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.local_ip.sin6.sin6_addr);
 	else
-		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.local_ip);
+		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.local_ip.sin.sin_addr.s_addr);
 }
 
 static ssize_t show_remote_ip(struct netconsole_target *nt, char *buf)
 {
 	if (nt->np.ipv6)
-		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.remote_ip.in6);
+		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.remote_ip.sin6.sin6_addr);
 	else
-		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.remote_ip);
+		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.remote_ip.sin.sin_addr.s_addr);
 }
 
 static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
@@ -419,17 +419,19 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 
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
@@ -450,17 +452,19 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 
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
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 2c637e9..dd38553 100644
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
@@ -899,15 +901,15 @@ void netpoll_print_options(struct netpoll *np)
 {
 	np_info(np, "local port %d\n", np->local_port);
 	if (np->ipv6)
-		np_info(np, "local IPv6 address %pI6c\n", &np->local_ip.in6);
+		np_info(np, "local IPv6 address %pI6c\n", &np->local_ip.sin6.sin6_addr);
 	else
-		np_info(np, "local IPv4 address %pI4\n", &np->local_ip.ip);
+		np_info(np, "local IPv4 address %pI4\n", &np->local_ip.sin.sin_addr.s_addr);
 	np_info(np, "interface '%s'\n", np->dev_name);
 	np_info(np, "remote port %d\n", np->remote_port);
 	if (np->ipv6)
-		np_info(np, "remote IPv6 address %pI6c\n", &np->remote_ip.in6);
+		np_info(np, "remote IPv6 address %pI6c\n", &np->remote_ip.sin6.sin6_addr);
 	else
-		np_info(np, "remote IPv4 address %pI4\n", &np->remote_ip.ip);
+		np_info(np, "remote IPv4 address %pI4\n", &np->remote_ip.sin.sin_addr.s_addr);
 	np_info(np, "remote ethernet address %pM\n", np->remote_mac);
 }
 EXPORT_SYMBOL(netpoll_print_options);
@@ -921,7 +923,7 @@ static int netpoll_parse_ip_addr(const char *str, union inet_addr *addr)
 		if (!*end)
 			return 0;
 	}
-	if (in6_pton(str, -1, addr->in6.s6_addr, -1, &end) > 0) {
+	if (in6_pton(str, -1, addr->sin6.sin6_addr.s6_addr, -1, &end) > 0) {
 #if IS_ENABLED(CONFIG_IPV6)
 		if (!*end)
 			return 1;
@@ -1140,7 +1142,7 @@ int netpoll_setup(struct netpoll *np)
 		rtnl_lock();
 	}
 
-	if (!np->local_ip.ip) {
+	if (!np->local_ip.sin.sin_addr.s_addr) {
 		if (!np->ipv6) {
 			in_dev = __in_dev_get_rtnl(ndev);
 
@@ -1151,8 +1153,8 @@ int netpoll_setup(struct netpoll *np)
 				goto put;
 			}
 
-			np->local_ip.ip = in_dev->ifa_list->ifa_local;
-			np_info(np, "local IP %pI4\n", &np->local_ip.ip);
+			np->local_ip.sin.sin_addr.s_addr = in_dev->ifa_list->ifa_local;
+			np_info(np, "local IP %pI4\n", &np->local_ip.sin.sin_addr.s_addr);
 		} else {
 #if IS_ENABLED(CONFIG_IPV6)
 			struct inet6_dev *idev;
@@ -1166,7 +1168,7 @@ int netpoll_setup(struct netpoll *np)
 				list_for_each_entry(ifp, &idev->addr_list, if_list) {
 					if (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)
 						continue;
-					np->local_ip.in6 = ifp->addr;
+					np->local_ip.sin6.sin6_addr = ifp->addr;
 					err = 0;
 					break;
 				}
@@ -1177,7 +1179,7 @@ int netpoll_setup(struct netpoll *np)
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
