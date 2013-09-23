From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Subject: [PATCH] Do not drop DNATed 6to4/6rd packets (v3)
Date: Mon, 23 Sep 2013 21:33:15 +0300
Message-ID: <1379961195-20680-1-git-send-email-catab@embedromix.ro>
References: <1379869266.2086.13.camel@joe-AO722>
Cc: hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.embedromix.ro ([5.9.41.220]:36854 "EHLO mail.embedromix.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302Ab3IWSdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 14:33:35 -0400
In-Reply-To: <1379869266.2086.13.camel@joe-AO722>
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
 include/net/addrconf.h |  4 +++
 net/ipv6/addrconf.c    | 27 ++++++++++++++++
 net/ipv6/sit.c         | 83 +++++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 99 insertions(+), 15 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index fb314de..96966eb 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -67,6 +67,10 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr);
 #endif
 
+extern bool ipv6_chk_custom_prefix(const struct in6_addr *addr,
+				   const unsigned int prefix_len,
+				   struct net_device *dev);
+
 int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev);
 
 struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d6ff126..a0c3abe 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1499,6 +1499,33 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 	return false;
 }
 
+/* Compares an address/prefix_len with addresses on device @dev.
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
index 7ee5cb9..6b2230d 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -566,6 +566,69 @@ static inline bool is_spoofed_6rd(struct ip_tunnel *tunnel, const __be32 v4addr,
 	return false;
 }
 
+/* Checks if an address matches an address on the tunnel interface.
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
+/* Returns true if a packet is spoofed
+ */
+static bool packet_is_spoofed(struct sk_buff *skb,
+			      const struct iphdr *iph,
+			      struct ip_tunnel *tunnel)
+{
+	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+
+	if (tunnel->dev->priv_flags & IFF_ISATAP) {
+		if (!isatap_chksrc(skb, iph, tunnel))
+			return true;
+
+		return false;
+	}
+
+	if ((tunnel->dev->flags&IFF_POINTOPOINT))
+		return false;
+
+	if (unlikely(is_spoofed_6rd(tunnel, iph->saddr, &ipv6h->saddr))) {
+		net_warn_ratelimited("Src spoofed %pI4/%pI6c -> %pI4/%pI6c\n",
+				     &iph->saddr, &ipv6h->saddr,
+				     &iph->daddr, &ipv6h->daddr);
+		return true;
+	}
+
+	if (likely(!is_spoofed_6rd(tunnel, iph->daddr, &ipv6h->daddr)))
+		return false;
+
+	if (only_dnatted(tunnel, &ipv6h->daddr))
+		return false;
+
+	net_warn_ratelimited("Dst spoofed %pI4/%pI6c -> %pI4/%pI6c\n",
+			     &iph->saddr, &ipv6h->saddr,
+			     &iph->daddr, &ipv6h->daddr);
+	return true;
+}
+
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -586,19 +649,9 @@ static int ipip6_rcv(struct sk_buff *skb)
 		IPCB(skb)->flags = 0;
 		skb->protocol = htons(ETH_P_IPV6);
 
-		if (tunnel->dev->priv_flags & IFF_ISATAP) {
-			if (!isatap_chksrc(skb, iph, tunnel)) {
-				tunnel->dev->stats.rx_errors++;
-				goto out;
-			}
-		} else if (!(tunnel->dev->flags&IFF_POINTOPOINT)) {
-			if (is_spoofed_6rd(tunnel, iph->saddr,
-					   &ipv6_hdr(skb)->saddr) ||
-			    is_spoofed_6rd(tunnel, iph->daddr,
-					   &ipv6_hdr(skb)->daddr)) {
-				tunnel->dev->stats.rx_errors++;
-				goto out;
-			}
+		if (packet_is_spoofed(skb, iph, tunnel)) {
+			tunnel->dev->stats.rx_errors++;
+			goto out;
 		}
 
 		__skb_tunnel_rx(skb, tunnel->dev, tunnel->net);
@@ -748,7 +801,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
 		if (neigh == NULL) {
-			net_dbg_ratelimited("sit: nexthop == NULL\n");
+			net_dbg_ratelimited("nexthop == NULL\n");
 			goto tx_error;
 		}
 
@@ -777,7 +830,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
 		if (neigh == NULL) {
-			net_dbg_ratelimited("sit: nexthop == NULL\n");
+			net_dbg_ratelimited("nexthop == NULL\n");
 			goto tx_error;
 		}
 
-- 
1.8.3.1
