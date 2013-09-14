From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Subject: [PATCH] Do not drop DNATed 6to4/6rd packets
Date: Sat, 14 Sep 2013 13:30:47 +0300
Message-ID: <1379154647-5781-1-git-send-email-catab@embedromix.ro>
Cc: hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.embedromix.ro ([5.9.41.220]:34593 "EHLO mail.embedromix.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756664Ab3INMMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Sep 2013 08:12:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>

When a router is doing  DNAT for 6to4/6rd packets the latest anti-spoofing
patch (218774dc) will drop them because the IPv6 address embedded
does not match the IPv4 destination. This patch will allow them to
pass by testing if we have an address that matches on 6to4/6rd interface.
I have been hit by this problem using Fedora and IPV6TO4_IPV4ADDR.
Also, log the dropped packets (with rate limit).

Signed-off-by: Catalin(ux) M. BOIE <catab@embedromix.ro>
---
 include/net/addrconf.h |  5 +++++
 net/ipv6/addrconf.c    | 28 ++++++++++++++++++++++++++++
 net/ipv6/sit.c         | 50 +++++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 76 insertions(+), 7 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 84a6440..49886fc 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -73,6 +73,11 @@ extern int			ipv6_chk_home_addr(struct net *net,
 						   const struct in6_addr *addr);
 #endif
 
+extern bool			ipv6_chk_custom_prefix(
+					const struct in6_addr *addr,
+					const unsigned int prefix_len,
+					struct net_device *dev);
+
 extern int			ipv6_chk_prefix(const struct in6_addr *addr,
 						struct net_device *dev);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1ab6ab..70ab1ba 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1527,6 +1527,34 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 	return false;
 }
 
+/*
+ * Compares an address/prefix_len with addresses on device @dev.
+ * If one is found it returns true.
+ */
+bool ipv6_chk_custom_prefix(const struct in6_addr *addr,
+	const unsigned int prefix_len, struct net_device *dev)
+{
+	struct inet6_dev *idev;
+	struct inet6_ifaddr *ifa;
+	bool ret = false;
+
+	rcu_read_lock();
+	idev = __in6_dev_get(dev);
+	if (idev) {
+		read_lock_bh(&idev->lock);
+		list_for_each_entry(ifa, &idev->addr_list, if_list) {
+			ret = ipv6_prefix_equal(addr, &ifa->addr, prefix_len);
+			if (ret)
+				break;
+		}
+		read_unlock_bh(&idev->lock);
+	}
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(ipv6_chk_custom_prefix);
+
 int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev)
 {
 	struct inet6_dev *idev;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3353634..fd2aba9 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -566,6 +566,33 @@ static inline bool is_spoofed_6rd(struct ip_tunnel *tunnel, const __be32 v4addr,
 	return false;
 }
 
+/*
+ * Checks if an address matches an address on the tunnel interface.
+ * Used to detect the NAT of proto 41 packets and let them pass spoofing test.
+ * Long story:
+ * This function is called after we considered the packet as spoofed
+ * in is_spoofed_6rd.
+ * We may have a router that is doing NAT for proto 41 packets
+ * for an internal station. Destination a.a.a.a/PREFIX:bbbb:bbbb
+ * will be translated to n.n.n.n/PREFIX:bbbb:bbbb. And is_spoofed_6rd
+ * function will return true, dropping the packet.
+ * But, we can still check if is spoofed against the IP
+ * addresses associated with the interface.
+ */
+static bool only_dnatted(const struct ip_tunnel *tunnel,
+	const struct in6_addr *v6dst)
+{
+	int prefix_len;
+
+#ifdef CONFIG_IPV6_SIT_6RD
+	prefix_len = tunnel->ip6rd.prefixlen + 32
+		- tunnel->ip6rd.relay_prefixlen;
+#else
+	prefix_len = 48;
+#endif
+	return ipv6_chk_custom_prefix(v6dst, prefix_len, tunnel->dev);
+}
+
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -589,11 +616,20 @@ static int ipip6_rcv(struct sk_buff *skb)
 				tunnel->dev->stats.rx_errors++;
 				goto out;
 			}
-		} else {
-			if (is_spoofed_6rd(tunnel, iph->saddr,
-					   &ipv6_hdr(skb)->saddr) ||
-			    is_spoofed_6rd(tunnel, iph->daddr,
-					   &ipv6_hdr(skb)->daddr)) {
+		} else if (!(tunnel->dev->flags&IFF_POINTOPOINT)) {
+			if (unlikely(is_spoofed_6rd(tunnel, iph->saddr,
+				&ipv6_hdr(skb)->saddr))) {
+				net_warn_ratelimited("Src spoofed %pI4/%pI6c\n",
+					&iph->saddr, &ipv6_hdr(skb)->saddr);
+				tunnel->dev->stats.rx_errors++;
+				goto out;
+			}
+
+			if (unlikely(is_spoofed_6rd(tunnel, iph->daddr,
+				&ipv6_hdr(skb)->daddr)
+				&& !only_dnatted(tunnel, &ipv6_hdr(skb)->daddr))) {
+				net_warn_ratelimited("Dst spoofed %pI4/%pI6c\n",
+					&iph->daddr, &ipv6_hdr(skb)->daddr);
 				tunnel->dev->stats.rx_errors++;
 				goto out;
 			}
@@ -713,7 +749,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
 		if (neigh == NULL) {
-			net_dbg_ratelimited("sit: nexthop == NULL\n");
+			net_dbg_ratelimited("nexthop == NULL\n");
 			goto tx_error;
 		}
 
@@ -742,7 +778,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
 		if (neigh == NULL) {
-			net_dbg_ratelimited("sit: nexthop == NULL\n");
+			net_dbg_ratelimited("nexthop == NULL\n");
 			goto tx_error;
 		}
 
-- 
1.8.3.1
