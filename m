From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next 2/3] netpoll: add IPv6 support
Date: Tue,  1 Jan 2013 16:01:27 +0800
Message-ID: <1357027288-28675-2-git-send-email-amwang@redhat.com>
References: <1357027288-28675-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025Ab3AAIBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2013 03:01:51 -0500
In-Reply-To: <1357027288-28675-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Currently, netpoll only support IPv4. This patch adds IPv6
support to netpoll, so that we can run netconsole over IPv6 network.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/netconsole.c |   44 +++++++-
 include/net/udp.h        |    2 +
 net/core/netpoll.c       |  246 ++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/udp.c           |    3 +-
 4 files changed, 277 insertions(+), 18 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 998fa02..2fd281a 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -269,13 +269,17 @@ static ssize_t show_remote_port(struct netconsole_target *nt, char *buf)
 
 static ssize_t show_local_ip(struct netconsole_target *nt, char *buf)
 {
-	if (!nt->np.ipv6)
+	if (nt->np.ipv6)
+		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.local_ip.in6);
+	else
 		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.local_ip);
 }
 
 static ssize_t show_remote_ip(struct netconsole_target *nt, char *buf)
 {
-	if (!nt->np.ipv6)
+	if (nt->np.ipv6)
+		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.remote_ip.in6);
+	else
 		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.remote_ip);
 }
 
@@ -412,8 +416,22 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	if (!strnchr(buf, count, ':'))
-		nt->np.local_ip.ip = in_aton(buf);
+	if (strnchr(buf, count, ':')) {
+		const char *end;
+		if (in6_pton(buf, count, nt->np.local_ip.in6.s6_addr, -1, &end) > 0) {
+			if (*end && *end != '\n') {
+				printk(KERN_ERR "netconsole: invalid IPv6 address at: <%c>\n", *end);
+				return -EINVAL;
+			}
+			nt->np.ipv6 = 1;
+		} else
+			return -EINVAL;
+	} else {
+		if (!nt->np.ipv6)
+			nt->np.local_ip.ip = in_aton(buf);
+		else
+			return -EINVAL;
+	}
 
 	return strnlen(buf, count);
 }
@@ -429,8 +447,22 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	if (!strnchr(buf, count, ':'))
-		nt->np.remote_ip.ip = in_aton(buf);
+	if (strnchr(buf, count, ':')) {
+		const char *end;
+		if (in6_pton(buf, count, nt->np.remote_ip.in6.s6_addr, -1, &end) > 0) {
+			if (*end && *end != '\n') {
+				printk(KERN_ERR "netconsole: invalid IPv6 address at: <%c>\n", *end);
+				return -EINVAL;
+			}
+			nt->np.ipv6 = 1;
+		} else
+			return -EINVAL;
+	} else {
+		if (!nt->np.ipv6)
+			nt->np.remote_ip.ip = in_aton(buf);
+		else
+			return -EINVAL;
+	}
 
 	return strnlen(buf, count);
 }
diff --git a/include/net/udp.h b/include/net/udp.h
index 065f379..c3ddb4a 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -156,6 +156,8 @@ static inline __wsum udp_csum(struct sk_buff *skb)
 	return csum;
 }
 
+extern int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto);
+
 /* hash routines shared between UDPv4/6 and UDP-Litev4/6 */
 static inline void udp_lib_hash(struct sock *sk)
 {
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 46e8d1c..a2cafa3 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -29,6 +29,8 @@
 #include <linux/if_vlan.h>
 #include <net/tcp.h>
 #include <net/udp.h>
+#include <net/addrconf.h>
+#include <net/ndisc.h>
 #include <asm/unaligned.h>
 #include <trace/events/napi.h>
 
@@ -381,9 +383,12 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	struct iphdr *iph;
 	struct ethhdr *eth;
 	static atomic_t ip_ident;
+	struct ipv6hdr *ip6h;
 
 	udp_len = len + sizeof(*udph);
-	if (!np->ipv6)
+	if (np->ipv6)
+		ip_len = udp_len + sizeof(*ip6h);
+	else
 		ip_len = udp_len + sizeof(*iph);
 
 	total_len = ip_len + LL_RESERVED_SPACE(np->dev);
@@ -403,7 +408,35 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	udph->dest = htons(np->remote_port);
 	udph->len = htons(udp_len);
 
-	if (!np->ipv6) {
+	if (np->ipv6) {
+		udph->check = 0;
+		udph->check = csum_ipv6_magic(&np->local_ip.in6,
+					      &np->remote_ip.in6,
+					      udp_len, IPPROTO_UDP,
+					      csum_partial(udph, udp_len, 0));
+		if (udph->check == 0)
+			udph->check = CSUM_MANGLED_0;
+
+		skb_push(skb, sizeof(*ip6h));
+		skb_reset_network_header(skb);
+		ip6h = ipv6_hdr(skb);
+
+		/* ip6h->version = 6; ip6h->priority = 0; */
+		put_unaligned(0x60, (unsigned char *)ip6h);
+		ip6h->flow_lbl[0] = 0;
+		ip6h->flow_lbl[1] = 0;
+		ip6h->flow_lbl[2] = 0;
+
+		ip6h->payload_len = htons(sizeof(struct udphdr) + len);
+		ip6h->nexthdr = IPPROTO_UDP;
+		ip6h->hop_limit = 32;
+		ip6h->saddr = np->local_ip.in6;
+		ip6h->daddr = np->remote_ip.in6;
+
+		eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
+		skb_reset_mac_header(skb);
+		skb->protocol = eth->h_proto = htons(ETH_P_IPV6);
+	} else {
 		udph->check = 0;
 		udph->check = csum_tcpudp_magic(np->local_ip.ip,
 						np->remote_ip.ip,
@@ -445,9 +478,7 @@ EXPORT_SYMBOL(netpoll_send_udp);
 
 static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo)
 {
-	struct arphdr *arp;
-	unsigned char *arp_ptr;
-	int size, type = ARPOP_REPLY, ptype = ETH_P_ARP;
+	int size, type = ARPOP_REPLY;
 	__be32 sip, tip;
 	unsigned char *sha;
 	struct sk_buff *send_skb;
@@ -474,6 +505,8 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 	proto = ntohs(eth_hdr(skb)->h_proto);
 	if (proto == ETH_P_IP) {
+		struct arphdr *arp;
+		unsigned char *arp_ptr;
 		/* No arp on this interface */
 		if (skb->dev->flags & IFF_NOARP)
 			return;
@@ -525,7 +558,7 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 			send_skb->protocol = htons(ETH_P_ARP);
 
 			/* Fill the device header for the ARP frame */
-			if (dev_hard_header(send_skb, skb->dev, ptype,
+			if (dev_hard_header(send_skb, skb->dev, ETH_P_ARP,
 					    sha, np->dev->dev_addr,
 					    send_skb->len) < 0) {
 				kfree_skb(send_skb);
@@ -562,14 +595,140 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 			break;
 		}
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+	} else if( proto == ETH_P_IPV6) {
+		struct nd_msg *msg;
+		struct ndisc_options ndopts;
+		u8 *lladdr = NULL;
+		struct ipv6hdr *hdr;
+		struct icmp6hdr *icmp6h;
+		const struct in6_addr *saddr;
+		const struct in6_addr *daddr;
+		struct inet6_dev *in6_dev = NULL;
+		u32 ndoptlen;
+		struct in6_addr *target;
+
+		in6_dev = in6_dev_get(skb->dev);
+		if (!in6_dev || !in6_dev->cnf.accept_ra)
+			return;
+
+		if (!pskb_may_pull(skb, skb->len))
+			return;
+
+		msg = (struct nd_msg *)skb_transport_header(skb);
+
+		__skb_push(skb, skb->data - skb_transport_header(skb));
+
+		if (ipv6_hdr(skb)->hop_limit != 255)
+			return;
+		if (msg->icmph.icmp6_code != 0)
+			return;
+		if (msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
+			return;
+
+		saddr = &ipv6_hdr(skb)->saddr;
+		daddr = &ipv6_hdr(skb)->daddr;
+
+		ndoptlen = skb->tail - (skb->transport_header + offsetof(struct nd_msg, opt));
+		if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
+			return;
+
+		if (ndopts.nd_opts_src_lladdr) {
+			lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr, skb->dev);
+			if (!lladdr)
+				return;
+		}
+
+		size = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
+
+		spin_lock_irqsave(&npinfo->rx_lock, flags);
+		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
+			if (memcmp(daddr, &np->local_ip, sizeof(*daddr)))
+				continue;
+
+			hlen = LL_RESERVED_SPACE(np->dev);
+			tlen = np->dev->needed_tailroom;
+			send_skb = find_skb(np, size + hlen + tlen, hlen);
+			if (!send_skb)
+				continue;
+
+			send_skb->protocol = htons(ETH_P_IPV6);
+			send_skb->dev = skb->dev;
+
+			skb_reset_network_header(send_skb);
+			skb_put(send_skb, sizeof(struct ipv6hdr));
+			hdr = ipv6_hdr(send_skb);
+
+			*(__be32*)hdr = htonl(0x60000000);
+
+			hdr->payload_len = htons(size);
+			hdr->nexthdr = IPPROTO_ICMPV6;
+			hdr->hop_limit = 255;
+			hdr->saddr = *saddr;
+			hdr->daddr = *daddr;
+
+			send_skb->transport_header = send_skb->tail;
+			skb_put(send_skb, size);
+
+			icmp6h = (struct icmp6hdr *)skb_transport_header(skb);
+			icmp6h->icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
+			icmp6h->icmp6_router = 0;
+			icmp6h->icmp6_solicited = 1;
+			target = (struct in6_addr *)skb_transport_header(send_skb) + sizeof(struct icmp6hdr);
+			*target = msg->target;
+			icmp6h->icmp6_cksum = csum_ipv6_magic(saddr, daddr, size,
+							      IPPROTO_ICMPV6,
+							      csum_partial(icmp6h,
+									   size, 0));
+
+			if (dev_hard_header(send_skb, skb->dev, ETH_P_IPV6,
+					    lladdr, np->dev->dev_addr,
+					    send_skb->len) < 0) {
+				kfree_skb(send_skb);
+				continue;
+			}
+
+			netpoll_send_skb(np, send_skb);
+
+			/* If there are several rx_hooks for the same address,
+			   we're fine by sending a single reply */
+			break;
+		}
+		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
 }
 
+static bool pkt_is_ns(struct sk_buff *skb)
+{
+	struct nd_msg *msg;
+	struct ipv6hdr *hdr;
+
+	if (skb->protocol != htons(ETH_P_ARP))
+		return false;
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr) + sizeof(struct nd_msg)))
+		return false;
+
+	msg = (struct nd_msg *)skb_transport_header(skb);
+	__skb_push(skb, skb->data - skb_transport_header(skb));
+	hdr = ipv6_hdr(skb);
+
+	if (hdr->nexthdr != IPPROTO_ICMPV6)
+		return false;
+	if (hdr->hop_limit != 255)
+		return false;
+	if (msg->icmph.icmp6_code != 0)
+		return false;
+	if (msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
+		return false;
+
+	return true;
+}
+
 int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 {
 	int proto, len, ulen;
 	int hits = 0;
 	const struct iphdr *iph;
+	const struct ipv6hdr *ip6h;
 	struct udphdr *uh;
 	struct netpoll *np, *tmp;
 
@@ -580,8 +739,10 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 		goto out;
 
 	/* check if netpoll clients need ARP */
-	if (skb->protocol == htons(ETH_P_ARP) &&
-	    atomic_read(&trapped)) {
+	if (skb->protocol == htons(ETH_P_ARP) && atomic_read(&trapped)) {
+		skb_queue_tail(&npinfo->neigh_tx, skb);
+		return 1;
+	} else if (pkt_is_ns(skb) && atomic_read(&trapped)) {
 		skb_queue_tail(&npinfo->neigh_tx, skb);
 		return 1;
 	}
@@ -648,6 +809,41 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 				       ulen - sizeof(struct udphdr));
 			hits++;
 		}
+	} else {
+		if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+			goto out;
+		ip6h = (struct ipv6hdr *)skb->data;
+		if (ip6h->version != 6)
+			goto out;
+		len = ntohs(ip6h->payload_len);
+		if (!len)
+			goto out;
+		if (len + sizeof(struct ipv6hdr) > skb->len)
+			goto out;
+		if (pskb_trim_rcsum(skb, len + sizeof(struct ipv6hdr)))
+			goto out;
+		ip6h = ipv6_hdr(skb);
+		if (!pskb_may_pull(skb, sizeof(struct udphdr)))
+			goto out;
+		uh = udp_hdr(skb);
+		ulen = ntohs(uh->len);
+		if (ulen != skb->len)
+			goto out;
+		if (udp6_csum_init(skb, uh, IPPROTO_UDP))
+			goto out;
+		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
+			if (memcmp(&np->local_ip.in6, &ip6h->daddr, sizeof(struct in6_addr)) != 0)
+				continue;
+			if (memcmp(&np->remote_ip.in6, &ip6h->saddr, sizeof(struct in6_addr)) != 0)
+				continue;
+			if (np->local_port && np->local_port != ntohs(uh->dest))
+				continue;
+
+			np->rx_hook(np, ntohs(uh->source),
+				       (char *)(uh+1),
+				       ulen - sizeof(struct udphdr));
+			hits++;
+		}
 	}
 
 	if (!hits)
@@ -668,11 +864,15 @@ out:
 void netpoll_print_options(struct netpoll *np)
 {
 	np_info(np, "local port %d\n", np->local_port);
-	if (!np->ipv6)
+	if (np->ipv6)
+		np_info(np, "local IPv6 address %pI6c\n", &np->local_ip.in6);
+	else
 		np_info(np, "local IPv4 address %pI4\n", &np->local_ip.ip);
 	np_info(np, "interface '%s'\n", np->dev_name);
 	np_info(np, "remote port %d\n", np->remote_port);
-	if (!np->ipv6)
+	if (np->ipv6)
+		np_info(np, "remote IPv6 address %pI6c\n", &np->remote_ip.in6);
+	else
 		np_info(np, "remote IPv4 address %pI4\n", &np->remote_ip.ip);
 	np_info(np, "remote ethernet address %pM\n", np->remote_mac);
 }
@@ -912,6 +1112,32 @@ int netpoll_setup(struct netpoll *np)
 			np->local_ip.ip = in_dev->ifa_list->ifa_local;
 			rcu_read_unlock();
 			np_info(np, "local IP %pI4\n", &np->local_ip.ip);
+		} else {
+			struct inet6_dev *idev;
+
+			err = -EDESTADDRREQ;
+			rcu_read_lock();
+			idev = __in6_dev_get(ndev);
+			if (idev) {
+				struct inet6_ifaddr *ifp;
+
+				read_lock_bh(&idev->lock);
+				list_for_each_entry(ifp, &idev->addr_list, if_list) {
+					if (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)
+						continue;
+					np->local_ip.in6 = ifp->addr;
+					err = 0;
+					break;
+				}
+				read_unlock_bh(&idev->lock);
+			}
+			rcu_read_unlock();
+			if (err) {
+				np_err(np, "no IPv6 address for %s, aborting\n",
+				       np->dev_name);
+				goto put;
+			} else
+				np_info(np, "local IPv6 %pI6c\n", &np->local_ip.in6);
 		}
 	}
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index dfaa29b..285754c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -752,8 +752,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	return 0;
 }
 
-static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh,
-				 int proto)
+int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
 {
 	int err;
 
-- 
1.7.7.6
