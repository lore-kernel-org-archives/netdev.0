From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next 1/3] netpoll: prepare for ipv6
Date: Tue,  1 Jan 2013 16:01:26 +0800
Message-ID: <1357027288-28675-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018Ab3AAIBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2013 03:01:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This patch adjusts some struct and functions, to prepare
for supporting IPv6.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/netconsole.c |   12 +-
 include/linux/netpoll.h  |   13 ++-
 net/core/netpoll.c       |  398 +++++++++++++++++++++++++---------------------
 3 files changed, 239 insertions(+), 184 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 6989ebe..998fa02 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -269,12 +269,14 @@ static ssize_t show_remote_port(struct netconsole_target *nt, char *buf)
 
 static ssize_t show_local_ip(struct netconsole_target *nt, char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.local_ip);
+	if (!nt->np.ipv6)
+		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.local_ip);
 }
 
 static ssize_t show_remote_ip(struct netconsole_target *nt, char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.remote_ip);
+	if (!nt->np.ipv6)
+		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.remote_ip);
 }
 
 static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
@@ -410,7 +412,8 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	nt->np.local_ip = in_aton(buf);
+	if (!strnchr(buf, count, ':'))
+		nt->np.local_ip.ip = in_aton(buf);
 
 	return strnlen(buf, count);
 }
@@ -426,7 +429,8 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	nt->np.remote_ip = in_aton(buf);
+	if (!strnchr(buf, count, ':'))
+		nt->np.remote_ip.ip = in_aton(buf);
 
 	return strnlen(buf, count);
 }
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 66d5379..24da730 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -12,13 +12,22 @@
 #include <linux/rcupdate.h>
 #include <linux/list.h>
 
+union inet_addr {
+	__u32		all[4];
+	__be32		ip;
+	__be32		ip6[4];
+	struct in_addr	in;
+	struct in6_addr	in6;
+};
+
 struct netpoll {
 	struct net_device *dev;
 	char dev_name[IFNAMSIZ];
 	const char *name;
 	void (*rx_hook)(struct netpoll *, int, char *, int);
 
-	__be32 local_ip, remote_ip;
+	int ipv6;
+	union inet_addr local_ip, remote_ip;
 	u16 local_port, remote_port;
 	u8 remote_mac[ETH_ALEN];
 
@@ -33,7 +42,7 @@ struct netpoll_info {
 	spinlock_t rx_lock;
 	struct list_head rx_np; /* netpolls that registered an rx_hook */
 
-	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
+	struct sk_buff_head neigh_tx; /* list of neigh requests to reply to */
 	struct sk_buff_head txq;
 
 	struct delayed_work tx_work;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 3151acf..46e8d1c 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -55,7 +55,7 @@ static atomic_t trapped;
 	 MAX_UDP_CHUNK)
 
 static void zap_completion_queue(void);
-static void netpoll_arp_reply(struct sk_buff *skb, struct netpoll_info *npinfo);
+static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo);
 
 static unsigned int carrier_timeout = 4;
 module_param(carrier_timeout, uint, 0644);
@@ -181,13 +181,13 @@ static void poll_napi(struct net_device *dev)
 	}
 }
 
-static void service_arp_queue(struct netpoll_info *npi)
+static void service_neigh_queue(struct netpoll_info *npi)
 {
 	if (npi) {
 		struct sk_buff *skb;
 
-		while ((skb = skb_dequeue(&npi->arp_tx)))
-			netpoll_arp_reply(skb, npi);
+		while ((skb = skb_dequeue(&npi->neigh_tx)))
+			netpoll_neigh_reply(skb, npi);
 	}
 }
 
@@ -213,14 +213,14 @@ static void netpoll_poll_dev(struct net_device *dev)
 			struct net_device *bond_dev = dev->master;
 			struct sk_buff *skb;
 			struct netpoll_info *bond_ni = rcu_dereference_bh(bond_dev->npinfo);
-			while ((skb = skb_dequeue(&ni->arp_tx))) {
+			while ((skb = skb_dequeue(&ni->neigh_tx))) {
 				skb->dev = bond_dev;
-				skb_queue_tail(&bond_ni->arp_tx, skb);
+				skb_queue_tail(&bond_ni->neigh_tx, skb);
 			}
 		}
 	}
 
-	service_arp_queue(ni);
+	service_neigh_queue(ni);
 
 	zap_completion_queue();
 }
@@ -383,7 +383,9 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	static atomic_t ip_ident;
 
 	udp_len = len + sizeof(*udph);
-	ip_len = udp_len + sizeof(*iph);
+	if (!np->ipv6)
+		ip_len = udp_len + sizeof(*iph);
+
 	total_len = ip_len + LL_RESERVED_SPACE(np->dev);
 
 	skb = find_skb(np, total_len + np->dev->needed_tailroom,
@@ -400,34 +402,38 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	udph->source = htons(np->local_port);
 	udph->dest = htons(np->remote_port);
 	udph->len = htons(udp_len);
-	udph->check = 0;
-	udph->check = csum_tcpudp_magic(np->local_ip,
-					np->remote_ip,
-					udp_len, IPPROTO_UDP,
-					csum_partial(udph, udp_len, 0));
-	if (udph->check == 0)
-		udph->check = CSUM_MANGLED_0;
-
-	skb_push(skb, sizeof(*iph));
-	skb_reset_network_header(skb);
-	iph = ip_hdr(skb);
-
-	/* iph->version = 4; iph->ihl = 5; */
-	put_unaligned(0x45, (unsigned char *)iph);
-	iph->tos      = 0;
-	put_unaligned(htons(ip_len), &(iph->tot_len));
-	iph->id       = htons(atomic_inc_return(&ip_ident));
-	iph->frag_off = 0;
-	iph->ttl      = 64;
-	iph->protocol = IPPROTO_UDP;
-	iph->check    = 0;
-	put_unaligned(np->local_ip, &(iph->saddr));
-	put_unaligned(np->remote_ip, &(iph->daddr));
-	iph->check    = ip_fast_csum((unsigned char *)iph, iph->ihl);
-
-	eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
-	skb_reset_mac_header(skb);
-	skb->protocol = eth->h_proto = htons(ETH_P_IP);
+
+	if (!np->ipv6) {
+		udph->check = 0;
+		udph->check = csum_tcpudp_magic(np->local_ip.ip,
+						np->remote_ip.ip,
+						udp_len, IPPROTO_UDP,
+						csum_partial(udph, udp_len, 0));
+		if (udph->check == 0)
+			udph->check = CSUM_MANGLED_0;
+
+		skb_push(skb, sizeof(*iph));
+		skb_reset_network_header(skb);
+		iph = ip_hdr(skb);
+
+		/* iph->version = 4; iph->ihl = 5; */
+		put_unaligned(0x45, (unsigned char *)iph);
+		iph->tos      = 0;
+		put_unaligned(htons(ip_len), &(iph->tot_len));
+		iph->id       = htons(atomic_inc_return(&ip_ident));
+		iph->frag_off = 0;
+		iph->ttl      = 64;
+		iph->protocol = IPPROTO_UDP;
+		iph->check    = 0;
+		put_unaligned(np->local_ip.ip, &(iph->saddr));
+		put_unaligned(np->remote_ip.ip, &(iph->daddr));
+		iph->check    = ip_fast_csum((unsigned char *)iph, iph->ihl);
+
+		eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
+		skb_reset_mac_header(skb);
+		skb->protocol = eth->h_proto = htons(ETH_P_IP);
+	}
+
 	memcpy(eth->h_source, np->dev->dev_addr, ETH_ALEN);
 	memcpy(eth->h_dest, np->remote_mac, ETH_ALEN);
 
@@ -437,7 +443,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 }
 EXPORT_SYMBOL(netpoll_send_udp);
 
-static void netpoll_arp_reply(struct sk_buff *skb, struct netpoll_info *npinfo)
+static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo)
 {
 	struct arphdr *arp;
 	unsigned char *arp_ptr;
@@ -448,7 +454,7 @@ static void netpoll_arp_reply(struct sk_buff *skb, struct netpoll_info *npinfo)
 	struct netpoll *np, *tmp;
 	unsigned long flags;
 	int hlen, tlen;
-	int hits = 0;
+	int hits = 0, proto;
 
 	if (list_empty(&npinfo->rx_np))
 		return;
@@ -466,94 +472,97 @@ static void netpoll_arp_reply(struct sk_buff *skb, struct netpoll_info *npinfo)
 	if (!hits)
 		return;
 
-	/* No arp on this interface */
-	if (skb->dev->flags & IFF_NOARP)
-		return;
-
-	if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
-		return;
+	proto = ntohs(eth_hdr(skb)->h_proto);
+	if (proto == ETH_P_IP) {
+		/* No arp on this interface */
+		if (skb->dev->flags & IFF_NOARP)
+			return;
 
-	skb_reset_network_header(skb);
-	skb_reset_transport_header(skb);
-	arp = arp_hdr(skb);
+		if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
+			return;
 
-	if ((arp->ar_hrd != htons(ARPHRD_ETHER) &&
-	     arp->ar_hrd != htons(ARPHRD_IEEE802)) ||
-	    arp->ar_pro != htons(ETH_P_IP) ||
-	    arp->ar_op != htons(ARPOP_REQUEST))
-		return;
+		skb_reset_network_header(skb);
+		skb_reset_transport_header(skb);
+		arp = arp_hdr(skb);
 
-	arp_ptr = (unsigned char *)(arp+1);
-	/* save the location of the src hw addr */
-	sha = arp_ptr;
-	arp_ptr += skb->dev->addr_len;
-	memcpy(&sip, arp_ptr, 4);
-	arp_ptr += 4;
-	/* If we actually cared about dst hw addr,
-	   it would get copied here */
-	arp_ptr += skb->dev->addr_len;
-	memcpy(&tip, arp_ptr, 4);
-
-	/* Should we ignore arp? */
-	if (ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
-		return;
+		if ((arp->ar_hrd != htons(ARPHRD_ETHER) &&
+		     arp->ar_hrd != htons(ARPHRD_IEEE802)) ||
+		    arp->ar_pro != htons(ETH_P_IP) ||
+		    arp->ar_op != htons(ARPOP_REQUEST))
+			return;
 
-	size = arp_hdr_len(skb->dev);
+		arp_ptr = (unsigned char *)(arp+1);
+		/* save the location of the src hw addr */
+		sha = arp_ptr;
+		arp_ptr += skb->dev->addr_len;
+		memcpy(&sip, arp_ptr, 4);
+		arp_ptr += 4;
+		/* If we actually cared about dst hw addr,
+		   it would get copied here */
+		arp_ptr += skb->dev->addr_len;
+		memcpy(&tip, arp_ptr, 4);
 
-	spin_lock_irqsave(&npinfo->rx_lock, flags);
-	list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-		if (tip != np->local_ip)
-			continue;
+		/* Should we ignore arp? */
+		if (ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
+			return;
 
-		hlen = LL_RESERVED_SPACE(np->dev);
-		tlen = np->dev->needed_tailroom;
-		send_skb = find_skb(np, size + hlen + tlen, hlen);
-		if (!send_skb)
-			continue;
+		size = arp_hdr_len(skb->dev);
 
-		skb_reset_network_header(send_skb);
-		arp = (struct arphdr *) skb_put(send_skb, size);
-		send_skb->dev = skb->dev;
-		send_skb->protocol = htons(ETH_P_ARP);
+		spin_lock_irqsave(&npinfo->rx_lock, flags);
+		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
+			if (tip != np->local_ip.ip)
+				continue;
+
+			hlen = LL_RESERVED_SPACE(np->dev);
+			tlen = np->dev->needed_tailroom;
+			send_skb = find_skb(np, size + hlen + tlen, hlen);
+			if (!send_skb)
+				continue;
+
+			skb_reset_network_header(send_skb);
+			arp = (struct arphdr *) skb_put(send_skb, size);
+			send_skb->dev = skb->dev;
+			send_skb->protocol = htons(ETH_P_ARP);
+
+			/* Fill the device header for the ARP frame */
+			if (dev_hard_header(send_skb, skb->dev, ptype,
+					    sha, np->dev->dev_addr,
+					    send_skb->len) < 0) {
+				kfree_skb(send_skb);
+				continue;
+			}
 
-		/* Fill the device header for the ARP frame */
-		if (dev_hard_header(send_skb, skb->dev, ptype,
-				    sha, np->dev->dev_addr,
-				    send_skb->len) < 0) {
-			kfree_skb(send_skb);
-			continue;
+			/*
+			 * Fill out the arp protocol part.
+			 *
+			 * we only support ethernet device type,
+			 * which (according to RFC 1390) should
+			 * always equal 1 (Ethernet).
+			 */
+
+			arp->ar_hrd = htons(np->dev->type);
+			arp->ar_pro = htons(ETH_P_IP);
+			arp->ar_hln = np->dev->addr_len;
+			arp->ar_pln = 4;
+			arp->ar_op = htons(type);
+
+			arp_ptr = (unsigned char *)(arp + 1);
+			memcpy(arp_ptr, np->dev->dev_addr, np->dev->addr_len);
+			arp_ptr += np->dev->addr_len;
+			memcpy(arp_ptr, &tip, 4);
+			arp_ptr += 4;
+			memcpy(arp_ptr, sha, np->dev->addr_len);
+			arp_ptr += np->dev->addr_len;
+			memcpy(arp_ptr, &sip, 4);
+
+			netpoll_send_skb(np, send_skb);
+
+			/* If there are several rx_hooks for the same address,
+			   we're fine by sending a single reply */
+			break;
 		}
-
-		/*
-		 * Fill out the arp protocol part.
-		 *
-		 * we only support ethernet device type,
-		 * which (according to RFC 1390) should
-		 * always equal 1 (Ethernet).
-		 */
-
-		arp->ar_hrd = htons(np->dev->type);
-		arp->ar_pro = htons(ETH_P_IP);
-		arp->ar_hln = np->dev->addr_len;
-		arp->ar_pln = 4;
-		arp->ar_op = htons(type);
-
-		arp_ptr = (unsigned char *)(arp + 1);
-		memcpy(arp_ptr, np->dev->dev_addr, np->dev->addr_len);
-		arp_ptr += np->dev->addr_len;
-		memcpy(arp_ptr, &tip, 4);
-		arp_ptr += 4;
-		memcpy(arp_ptr, sha, np->dev->addr_len);
-		arp_ptr += np->dev->addr_len;
-		memcpy(arp_ptr, &sip, 4);
-
-		netpoll_send_skb(np, send_skb);
-
-		/* If there are several rx_hooks for the same address,
-		   we're fine by sending a single reply */
-		break;
+		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
-	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 }
 
 int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
@@ -573,7 +582,7 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 	/* check if netpoll clients need ARP */
 	if (skb->protocol == htons(ETH_P_ARP) &&
 	    atomic_read(&trapped)) {
-		skb_queue_tail(&npinfo->arp_tx, skb);
+		skb_queue_tail(&npinfo->neigh_tx, skb);
 		return 1;
 	}
 
@@ -584,60 +593,61 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 	}
 
 	proto = ntohs(eth_hdr(skb)->h_proto);
-	if (proto != ETH_P_IP)
+	if (proto != ETH_P_IP && proto != ETH_P_IPV6)
 		goto out;
 	if (skb->pkt_type == PACKET_OTHERHOST)
 		goto out;
 	if (skb_shared(skb))
 		goto out;
 
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-		goto out;
-	iph = (struct iphdr *)skb->data;
-	if (iph->ihl < 5 || iph->version != 4)
-		goto out;
-	if (!pskb_may_pull(skb, iph->ihl*4))
-		goto out;
-	iph = (struct iphdr *)skb->data;
-	if (ip_fast_csum((u8 *)iph, iph->ihl) != 0)
-		goto out;
-
-	len = ntohs(iph->tot_len);
-	if (skb->len < len || len < iph->ihl*4)
-		goto out;
-
-	/*
-	 * Our transport medium may have padded the buffer out.
-	 * Now We trim to the true length of the frame.
-	 */
-	if (pskb_trim_rcsum(skb, len))
-		goto out;
+	if (proto == ETH_P_IP) {
+		if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+			goto out;
+		iph = (struct iphdr *)skb->data;
+		if (iph->ihl < 5 || iph->version != 4)
+			goto out;
+		if (!pskb_may_pull(skb, iph->ihl*4))
+			goto out;
+		iph = (struct iphdr *)skb->data;
+		if (ip_fast_csum((u8 *)iph, iph->ihl) != 0)
+			goto out;
 
-	iph = (struct iphdr *)skb->data;
-	if (iph->protocol != IPPROTO_UDP)
-		goto out;
+		len = ntohs(iph->tot_len);
+		if (skb->len < len || len < iph->ihl*4)
+			goto out;
 
-	len -= iph->ihl*4;
-	uh = (struct udphdr *)(((char *)iph) + iph->ihl*4);
-	ulen = ntohs(uh->len);
+		/*
+		 * Our transport medium may have padded the buffer out.
+		 * Now We trim to the true length of the frame.
+		 */
+		if (pskb_trim_rcsum(skb, len))
+			goto out;
 
-	if (ulen != len)
-		goto out;
-	if (checksum_udp(skb, uh, ulen, iph->saddr, iph->daddr))
-		goto out;
+		iph = (struct iphdr *)skb->data;
+		if (iph->protocol != IPPROTO_UDP)
+			goto out;
 
-	list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-		if (np->local_ip && np->local_ip != iph->daddr)
-			continue;
-		if (np->remote_ip && np->remote_ip != iph->saddr)
-			continue;
-		if (np->local_port && np->local_port != ntohs(uh->dest))
-			continue;
+		len -= iph->ihl*4;
+		uh = (struct udphdr *)(((char *)iph) + iph->ihl*4);
+		ulen = ntohs(uh->len);
 
-		np->rx_hook(np, ntohs(uh->source),
-			       (char *)(uh+1),
-			       ulen - sizeof(struct udphdr));
-		hits++;
+		if (ulen != len)
+			goto out;
+		if (checksum_udp(skb, uh, ulen, iph->saddr, iph->daddr))
+			goto out;
+		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
+			if (np->local_ip.ip && np->local_ip.ip != iph->daddr)
+				continue;
+			if (np->remote_ip.ip && np->remote_ip.ip != iph->saddr)
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
@@ -658,17 +668,36 @@ out:
 void netpoll_print_options(struct netpoll *np)
 {
 	np_info(np, "local port %d\n", np->local_port);
-	np_info(np, "local IP %pI4\n", &np->local_ip);
+	if (!np->ipv6)
+		np_info(np, "local IPv4 address %pI4\n", &np->local_ip.ip);
 	np_info(np, "interface '%s'\n", np->dev_name);
 	np_info(np, "remote port %d\n", np->remote_port);
-	np_info(np, "remote IP %pI4\n", &np->remote_ip);
+	if (!np->ipv6)
+		np_info(np, "remote IPv4 address %pI4\n", &np->remote_ip.ip);
 	np_info(np, "remote ethernet address %pM\n", np->remote_mac);
 }
 EXPORT_SYMBOL(netpoll_print_options);
 
+static int netpoll_parse_ip_addr(const char *str, union inet_addr *addr)
+{
+	const char *end;
+
+	if (!strchr(str, ':') &&
+	    in4_pton(str, -1, (void *)addr, -1, &end) > 0) {
+		if (!*end)
+			return 0;
+	}
+	if (in6_pton(str, -1, addr->in6.s6_addr, -1, &end) > 0) {
+		if (!*end)
+			return 1;
+	}
+	return -1;
+}
+
 int netpoll_parse_options(struct netpoll *np, char *opt)
 {
 	char *cur=opt, *delim;
+	int ipv6;
 
 	if (*cur != '@') {
 		if ((delim = strchr(cur, '@')) == NULL)
@@ -684,7 +713,11 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		if ((delim = strchr(cur, '/')) == NULL)
 			goto parse_failed;
 		*delim = 0;
-		np->local_ip = in_aton(cur);
+		ipv6 = netpoll_parse_ip_addr(cur, &np->local_ip);
+		if (ipv6 < 0)
+			goto parse_failed;
+		else
+			np->ipv6 = ipv6;
 		cur = delim;
 	}
 	cur++;
@@ -716,7 +749,13 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	if ((delim = strchr(cur, '/')) == NULL)
 		goto parse_failed;
 	*delim = 0;
-	np->remote_ip = in_aton(cur);
+	ipv6 = netpoll_parse_ip_addr(cur, &np->remote_ip);
+	if (ipv6 < 0)
+		goto parse_failed;
+	else if (np->ipv6 != ipv6)
+		goto parse_failed;
+	else
+		np->ipv6 = ipv6;
 	cur = delim + 1;
 
 	if (*cur != 0) {
@@ -764,7 +803,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 		INIT_LIST_HEAD(&npinfo->rx_np);
 
 		spin_lock_init(&npinfo->rx_lock);
-		skb_queue_head_init(&npinfo->arp_tx);
+		skb_queue_head_init(&npinfo->neigh_tx);
 		skb_queue_head_init(&npinfo->txq);
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
 
@@ -856,21 +895,24 @@ int netpoll_setup(struct netpoll *np)
 		}
 	}
 
-	if (!np->local_ip) {
-		rcu_read_lock();
-		in_dev = __in_dev_get_rcu(ndev);
+	if (!np->local_ip.ip) {
+		if (!np->ipv6) {
+			rcu_read_lock();
+			in_dev = __in_dev_get_rcu(ndev);
 
-		if (!in_dev || !in_dev->ifa_list) {
+
+			if (!in_dev || !in_dev->ifa_list) {
+				rcu_read_unlock();
+				np_err(np, "no IP address for %s, aborting\n",
+				       np->dev_name);
+				err = -EDESTADDRREQ;
+				goto put;
+			}
+
+			np->local_ip.ip = in_dev->ifa_list->ifa_local;
 			rcu_read_unlock();
-			np_err(np, "no IP address for %s, aborting\n",
-			       np->dev_name);
-			err = -EDESTADDRREQ;
-			goto put;
+			np_info(np, "local IP %pI4\n", &np->local_ip.ip);
 		}
-
-		np->local_ip = in_dev->ifa_list->ifa_local;
-		rcu_read_unlock();
-		np_info(np, "local IP %pI4\n", &np->local_ip);
 	}
 
 	/* fill up the skb queue */
@@ -903,7 +945,7 @@ static void rcu_cleanup_netpoll_info(struct rcu_head *rcu_head)
 	struct netpoll_info *npinfo =
 			container_of(rcu_head, struct netpoll_info, rcu);
 
-	skb_queue_purge(&npinfo->arp_tx);
+	skb_queue_purge(&npinfo->neigh_tx);
 	skb_queue_purge(&npinfo->txq);
 
 	/* we can't call cancel_delayed_work_sync here, as we are in softirq */
-- 
1.7.7.6
