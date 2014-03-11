From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC PATCH 1/2] netpoll:  Remove dead netpoll_rx code
Date: Tue, 11 Mar 2014 01:44:24 -0700
Message-ID: <8738ipf7kn.fsf_-_@xmission.com>
References: <871ty9qvaf.fsf_-_@xmission.com> <87vbvlpgnk.fsf_-_@xmission.com>
	<1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a9cxf7mp.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48005 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197AbaCKIoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 04:44:32 -0400
In-Reply-To: <87a9cxf7mp.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 01:43:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The netpoll_rx code only becomes active if the netpoll rx_skb_hook is
implemented.  There is not a single implementation of the netpoll
rx_skb_hook in the kernel.

There are problems with the netpoll packet receive code. Most
speifically every packet that makes it to netpoll_neigh_reply is
leaked.

Given that the netpoll packet receive code is buggy and has not been used
for a decade let's just remove it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/Kconfig       |    5 -
 include/linux/netdevice.h |   17 --
 include/linux/netpoll.h   |   59 ------
 net/core/dev.c            |   11 +-
 net/core/netpoll.c        |  471 ---------------------------------------------
 5 files changed, 1 insertions(+), 562 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 494b888a6568..89402c3b64f8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -177,11 +177,6 @@ config NETCONSOLE_DYNAMIC
 config NETPOLL
 	def_bool NETCONSOLE
 
-config NETPOLL_TRAP
-	bool "Netpoll traffic trapping"
-	default n
-	depends on NETPOLL
-
 config NET_POLL_CONTROLLER
 	def_bool NETPOLL
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1a869488b8ae..cd345f102926 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1979,9 +1979,6 @@ struct net_device *__dev_get_by_index(struct net *net, int ifindex);
 struct net_device *dev_get_by_index_rcu(struct net *net, int ifindex);
 int netdev_get_name(struct net *net, char *name, int ifindex);
 int dev_restart(struct net_device *dev);
-#ifdef CONFIG_NETPOLL_TRAP
-int netpoll_trap(void);
-#endif
 int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb);
 
 static inline unsigned int skb_gro_offset(const struct sk_buff *skb)
@@ -2186,12 +2183,6 @@ static inline void netif_tx_start_all_queues(struct net_device *dev)
 
 static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
 {
-#ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap()) {
-		netif_tx_start_queue(dev_queue);
-		return;
-	}
-#endif
 	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state))
 		__netif_schedule(dev_queue->qdisc);
 }
@@ -2435,10 +2426,6 @@ static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
 static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
-#ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap())
-		return;
-#endif
 	netif_tx_stop_queue(txq);
 }
 
@@ -2473,10 +2460,6 @@ static inline bool netif_subqueue_stopped(const struct net_device *dev,
 static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
-#ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap())
-		return;
-#endif
 	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &txq->state))
 		__netif_schedule(txq->qdisc);
 }
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index fbfdb9d8d3a7..6c14f0d89bcb 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -24,27 +24,20 @@ struct netpoll {
 	struct net_device *dev;
 	char dev_name[IFNAMSIZ];
 	const char *name;
-	void (*rx_skb_hook)(struct netpoll *np, int source, struct sk_buff *skb,
-			    int offset, int len);
 
 	union inet_addr local_ip, remote_ip;
 	bool ipv6;
 	u16 local_port, remote_port;
 	u8 remote_mac[ETH_ALEN];
 
-	struct list_head rx; /* rx_np list element */
 	struct work_struct cleanup_work;
 };
 
 struct netpoll_info {
 	atomic_t refcnt;
 
-	unsigned long rx_flags;
-	spinlock_t rx_lock;
 	struct semaphore dev_lock;
-	struct list_head rx_np; /* netpolls that registered an rx_skb_hook */
 
-	struct sk_buff_head neigh_tx; /* list of neigh requests to reply to */
 	struct sk_buff_head txq;
 
 	struct delayed_work tx_work;
@@ -66,12 +59,9 @@ void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
 int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp);
 int netpoll_setup(struct netpoll *np);
-int netpoll_trap(void);
-void netpoll_set_trap(int trap);
 void __netpoll_cleanup(struct netpoll *np);
 void __netpoll_free_async(struct netpoll *np);
 void netpoll_cleanup(struct netpoll *np);
-int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo);
 void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 			     struct net_device *dev);
 static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
@@ -83,44 +73,7 @@ static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 }
 
 
-
 #ifdef CONFIG_NETPOLL
-static inline bool netpoll_rx_on(struct sk_buff *skb)
-{
-	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
-
-	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
-}
-
-static inline bool netpoll_rx(struct sk_buff *skb)
-{
-	struct netpoll_info *npinfo;
-	unsigned long flags;
-	bool ret = false;
-
-	local_irq_save(flags);
-
-	if (!netpoll_rx_on(skb))
-		goto out;
-
-	npinfo = rcu_dereference_bh(skb->dev->npinfo);
-	spin_lock(&npinfo->rx_lock);
-	/* check rx_flags again with the lock held */
-	if (npinfo->rx_flags && __netpoll_rx(skb, npinfo))
-		ret = true;
-	spin_unlock(&npinfo->rx_lock);
-
-out:
-	local_irq_restore(flags);
-	return ret;
-}
-
-static inline int netpoll_receive_skb(struct sk_buff *skb)
-{
-	if (!list_empty(&skb->dev->napi_list))
-		return netpoll_rx(skb);
-	return 0;
-}
 
 static inline void *netpoll_poll_lock(struct napi_struct *napi)
 {
@@ -150,18 +103,6 @@ static inline bool netpoll_tx_running(struct net_device *dev)
 }
 
 #else
-static inline bool netpoll_rx(struct sk_buff *skb)
-{
-	return false;
-}
-static inline bool netpoll_rx_on(struct sk_buff *skb)
-{
-	return false;
-}
-static inline int netpoll_receive_skb(struct sk_buff *skb)
-{
-	return 0;
-}
 static inline void *netpoll_poll_lock(struct napi_struct *napi)
 {
 	return NULL;
diff --git a/net/core/dev.c b/net/core/dev.c
index b1b0c8d4d7df..3565c898a910 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3231,10 +3231,6 @@ static int netif_rx_internal(struct sk_buff *skb)
 {
 	int ret;
 
-	/* if netpoll wants it, pretend we never saw it */
-	if (netpoll_rx(skb))
-		return NET_RX_DROP;
-
 	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
 	trace_netif_rx(skb);
@@ -3520,10 +3516,6 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 
 	trace_netif_receive_skb(skb);
 
-	/* if we've gotten here through NAPI, check netpoll */
-	if (netpoll_receive_skb(skb))
-		goto out;
-
 	orig_dev = skb->dev;
 
 	skb_reset_network_header(skb);
@@ -3650,7 +3642,6 @@ drop:
 
 unlock:
 	rcu_read_unlock();
-out:
 	return ret;
 }
 
@@ -3875,7 +3866,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	int same_flow;
 	enum gro_result ret;
 
-	if (!(skb->dev->features & NETIF_F_GRO) || netpoll_rx_on(skb))
+	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
 
 	if (skb_is_gso(skb) || skb_has_frag_list(skb))
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a664f7829a6d..e883eff6799e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -46,13 +46,9 @@
 
 static struct sk_buff_head skb_pool;
 
-static atomic_t trapped;
-
 DEFINE_STATIC_SRCU(netpoll_srcu);
 
 #define USEC_PER_POLL	50
-#define NETPOLL_RX_ENABLED  1
-#define NETPOLL_RX_DROP     2
 
 #define MAX_SKB_SIZE							\
 	(sizeof(struct ethhdr) +					\
@@ -61,7 +57,6 @@ DEFINE_STATIC_SRCU(netpoll_srcu);
 	 MAX_UDP_CHUNK)
 
 static void zap_completion_queue(void);
-static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo);
 static void netpoll_async_cleanup(struct work_struct *work);
 
 static unsigned int carrier_timeout = 4;
@@ -109,25 +104,6 @@ static void queue_process(struct work_struct *work)
 	}
 }
 
-static __sum16 checksum_udp(struct sk_buff *skb, struct udphdr *uh,
-			    unsigned short ulen, __be32 saddr, __be32 daddr)
-{
-	__wsum psum;
-
-	if (uh->check == 0 || skb_csum_unnecessary(skb))
-		return 0;
-
-	psum = csum_tcpudp_nofold(saddr, daddr, ulen, IPPROTO_UDP, 0);
-
-	if (skb->ip_summed == CHECKSUM_COMPLETE &&
-	    !csum_fold(csum_add(psum, skb->csum)))
-		return 0;
-
-	skb->csum = psum;
-
-	return __skb_checksum_complete(skb);
-}
-
 /*
  * Check whether delayed processing was scheduled for our NIC. If so,
  * we attempt to grab the poll lock and use ->poll() to pump the card.
@@ -156,16 +132,12 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
 		return budget;
 
-	npinfo->rx_flags |= NETPOLL_RX_DROP;
-	atomic_inc(&trapped);
 	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
 	work = napi->poll(napi, budget);
 	trace_napi_poll(napi);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
-	atomic_dec(&trapped);
-	npinfo->rx_flags &= ~NETPOLL_RX_DROP;
 
 	return budget - work;
 }
@@ -188,16 +160,6 @@ static void poll_napi(struct net_device *dev)
 	}
 }
 
-static void service_neigh_queue(struct netpoll_info *npi)
-{
-	if (npi) {
-		struct sk_buff *skb;
-
-		while ((skb = skb_dequeue(&npi->neigh_tx)))
-			netpoll_neigh_reply(skb, npi);
-	}
-}
-
 static void netpoll_poll_dev(struct net_device *dev)
 {
 	const struct net_device_ops *ops;
@@ -228,23 +190,6 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	up(&ni->dev_lock);
 
-	if (dev->flags & IFF_SLAVE) {
-		if (ni) {
-			struct net_device *bond_dev;
-			struct sk_buff *skb;
-			struct netpoll_info *bond_ni;
-
-			bond_dev = netdev_master_upper_dev_get_rcu(dev);
-			bond_ni = rcu_dereference_bh(bond_dev->npinfo);
-			while ((skb = skb_dequeue(&ni->neigh_tx))) {
-				skb->dev = bond_dev;
-				skb_queue_tail(&bond_ni->neigh_tx, skb);
-			}
-		}
-	}
-
-	service_neigh_queue(ni);
-
 	zap_completion_queue();
 }
 
@@ -529,384 +474,6 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 }
 EXPORT_SYMBOL(netpoll_send_udp);
 
-static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo)
-{
-	int size, type = ARPOP_REPLY;
-	__be32 sip, tip;
-	unsigned char *sha;
-	struct sk_buff *send_skb;
-	struct netpoll *np, *tmp;
-	unsigned long flags;
-	int hlen, tlen;
-	int hits = 0, proto;
-
-	if (list_empty(&npinfo->rx_np))
-		return;
-
-	/* Before checking the packet, we do some early
-	   inspection whether this is interesting at all */
-	spin_lock_irqsave(&npinfo->rx_lock, flags);
-	list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-		if (np->dev == skb->dev)
-			hits++;
-	}
-	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-
-	/* No netpoll struct is using this dev */
-	if (!hits)
-		return;
-
-	proto = ntohs(eth_hdr(skb)->h_proto);
-	if (proto == ETH_P_ARP) {
-		struct arphdr *arp;
-		unsigned char *arp_ptr;
-		/* No arp on this interface */
-		if (skb->dev->flags & IFF_NOARP)
-			return;
-
-		if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
-			return;
-
-		skb_reset_network_header(skb);
-		skb_reset_transport_header(skb);
-		arp = arp_hdr(skb);
-
-		if ((arp->ar_hrd != htons(ARPHRD_ETHER) &&
-		     arp->ar_hrd != htons(ARPHRD_IEEE802)) ||
-		    arp->ar_pro != htons(ETH_P_IP) ||
-		    arp->ar_op != htons(ARPOP_REQUEST))
-			return;
-
-		arp_ptr = (unsigned char *)(arp+1);
-		/* save the location of the src hw addr */
-		sha = arp_ptr;
-		arp_ptr += skb->dev->addr_len;
-		memcpy(&sip, arp_ptr, 4);
-		arp_ptr += 4;
-		/* If we actually cared about dst hw addr,
-		   it would get copied here */
-		arp_ptr += skb->dev->addr_len;
-		memcpy(&tip, arp_ptr, 4);
-
-		/* Should we ignore arp? */
-		if (ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
-			return;
-
-		size = arp_hdr_len(skb->dev);
-
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (tip != np->local_ip.ip)
-				continue;
-
-			hlen = LL_RESERVED_SPACE(np->dev);
-			tlen = np->dev->needed_tailroom;
-			send_skb = find_skb(np, size + hlen + tlen, hlen);
-			if (!send_skb)
-				continue;
-
-			skb_reset_network_header(send_skb);
-			arp = (struct arphdr *) skb_put(send_skb, size);
-			send_skb->dev = skb->dev;
-			send_skb->protocol = htons(ETH_P_ARP);
-
-			/* Fill the device header for the ARP frame */
-			if (dev_hard_header(send_skb, skb->dev, ETH_P_ARP,
-					    sha, np->dev->dev_addr,
-					    send_skb->len) < 0) {
-				kfree_skb(send_skb);
-				continue;
-			}
-
-			/*
-			 * Fill out the arp protocol part.
-			 *
-			 * we only support ethernet device type,
-			 * which (according to RFC 1390) should
-			 * always equal 1 (Ethernet).
-			 */
-
-			arp->ar_hrd = htons(np->dev->type);
-			arp->ar_pro = htons(ETH_P_IP);
-			arp->ar_hln = np->dev->addr_len;
-			arp->ar_pln = 4;
-			arp->ar_op = htons(type);
-
-			arp_ptr = (unsigned char *)(arp + 1);
-			memcpy(arp_ptr, np->dev->dev_addr, np->dev->addr_len);
-			arp_ptr += np->dev->addr_len;
-			memcpy(arp_ptr, &tip, 4);
-			arp_ptr += 4;
-			memcpy(arp_ptr, sha, np->dev->addr_len);
-			arp_ptr += np->dev->addr_len;
-			memcpy(arp_ptr, &sip, 4);
-
-			netpoll_send_skb(np, send_skb);
-
-			/* If there are several rx_skb_hooks for the same
-			 * address we're fine by sending a single reply
-			 */
-			break;
-		}
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-	} else if( proto == ETH_P_IPV6) {
-#if IS_ENABLED(CONFIG_IPV6)
-		struct nd_msg *msg;
-		u8 *lladdr = NULL;
-		struct ipv6hdr *hdr;
-		struct icmp6hdr *icmp6h;
-		const struct in6_addr *saddr;
-		const struct in6_addr *daddr;
-		struct inet6_dev *in6_dev = NULL;
-		struct in6_addr *target;
-
-		in6_dev = in6_dev_get(skb->dev);
-		if (!in6_dev || !in6_dev->cnf.accept_ra)
-			return;
-
-		if (!pskb_may_pull(skb, skb->len))
-			return;
-
-		msg = (struct nd_msg *)skb_transport_header(skb);
-
-		__skb_push(skb, skb->data - skb_transport_header(skb));
-
-		if (ipv6_hdr(skb)->hop_limit != 255)
-			return;
-		if (msg->icmph.icmp6_code != 0)
-			return;
-		if (msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
-			return;
-
-		saddr = &ipv6_hdr(skb)->saddr;
-		daddr = &ipv6_hdr(skb)->daddr;
-
-		size = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
-
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (!ipv6_addr_equal(daddr, &np->local_ip.in6))
-				continue;
-
-			hlen = LL_RESERVED_SPACE(np->dev);
-			tlen = np->dev->needed_tailroom;
-			send_skb = find_skb(np, size + hlen + tlen, hlen);
-			if (!send_skb)
-				continue;
-
-			send_skb->protocol = htons(ETH_P_IPV6);
-			send_skb->dev = skb->dev;
-
-			skb_reset_network_header(send_skb);
-			hdr = (struct ipv6hdr *) skb_put(send_skb, sizeof(struct ipv6hdr));
-			*(__be32*)hdr = htonl(0x60000000);
-			hdr->payload_len = htons(size);
-			hdr->nexthdr = IPPROTO_ICMPV6;
-			hdr->hop_limit = 255;
-			hdr->saddr = *saddr;
-			hdr->daddr = *daddr;
-
-			icmp6h = (struct icmp6hdr *) skb_put(send_skb, sizeof(struct icmp6hdr));
-			icmp6h->icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
-			icmp6h->icmp6_router = 0;
-			icmp6h->icmp6_solicited = 1;
-
-			target = (struct in6_addr *) skb_put(send_skb, sizeof(struct in6_addr));
-			*target = msg->target;
-			icmp6h->icmp6_cksum = csum_ipv6_magic(saddr, daddr, size,
-							      IPPROTO_ICMPV6,
-							      csum_partial(icmp6h,
-									   size, 0));
-
-			if (dev_hard_header(send_skb, skb->dev, ETH_P_IPV6,
-					    lladdr, np->dev->dev_addr,
-					    send_skb->len) < 0) {
-				kfree_skb(send_skb);
-				continue;
-			}
-
-			netpoll_send_skb(np, send_skb);
-
-			/* If there are several rx_skb_hooks for the same
-			 * address, we're fine by sending a single reply
-			 */
-			break;
-		}
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-#endif
-	}
-}
-
-static bool pkt_is_ns(struct sk_buff *skb)
-{
-	struct nd_msg *msg;
-	struct ipv6hdr *hdr;
-
-	if (skb->protocol != htons(ETH_P_ARP))
-		return false;
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr) + sizeof(struct nd_msg)))
-		return false;
-
-	msg = (struct nd_msg *)skb_transport_header(skb);
-	__skb_push(skb, skb->data - skb_transport_header(skb));
-	hdr = ipv6_hdr(skb);
-
-	if (hdr->nexthdr != IPPROTO_ICMPV6)
-		return false;
-	if (hdr->hop_limit != 255)
-		return false;
-	if (msg->icmph.icmp6_code != 0)
-		return false;
-	if (msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
-		return false;
-
-	return true;
-}
-
-int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
-{
-	int proto, len, ulen, data_len;
-	int hits = 0, offset;
-	const struct iphdr *iph;
-	struct udphdr *uh;
-	struct netpoll *np, *tmp;
-	uint16_t source;
-
-	if (list_empty(&npinfo->rx_np))
-		goto out;
-
-	if (skb->dev->type != ARPHRD_ETHER)
-		goto out;
-
-	/* check if netpoll clients need ARP */
-	if (skb->protocol == htons(ETH_P_ARP) && atomic_read(&trapped)) {
-		skb_queue_tail(&npinfo->neigh_tx, skb);
-		return 1;
-	} else if (pkt_is_ns(skb) && atomic_read(&trapped)) {
-		skb_queue_tail(&npinfo->neigh_tx, skb);
-		return 1;
-	}
-
-	if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
-		skb = vlan_untag(skb);
-		if (unlikely(!skb))
-			goto out;
-	}
-
-	proto = ntohs(eth_hdr(skb)->h_proto);
-	if (proto != ETH_P_IP && proto != ETH_P_IPV6)
-		goto out;
-	if (skb->pkt_type == PACKET_OTHERHOST)
-		goto out;
-	if (skb_shared(skb))
-		goto out;
-
-	if (proto == ETH_P_IP) {
-		if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-			goto out;
-		iph = (struct iphdr *)skb->data;
-		if (iph->ihl < 5 || iph->version != 4)
-			goto out;
-		if (!pskb_may_pull(skb, iph->ihl*4))
-			goto out;
-		iph = (struct iphdr *)skb->data;
-		if (ip_fast_csum((u8 *)iph, iph->ihl) != 0)
-			goto out;
-
-		len = ntohs(iph->tot_len);
-		if (skb->len < len || len < iph->ihl*4)
-			goto out;
-
-		/*
-		 * Our transport medium may have padded the buffer out.
-		 * Now We trim to the true length of the frame.
-		 */
-		if (pskb_trim_rcsum(skb, len))
-			goto out;
-
-		iph = (struct iphdr *)skb->data;
-		if (iph->protocol != IPPROTO_UDP)
-			goto out;
-
-		len -= iph->ihl*4;
-		uh = (struct udphdr *)(((char *)iph) + iph->ihl*4);
-		offset = (unsigned char *)(uh + 1) - skb->data;
-		ulen = ntohs(uh->len);
-		data_len = skb->len - offset;
-		source = ntohs(uh->source);
-
-		if (ulen != len)
-			goto out;
-		if (checksum_udp(skb, uh, ulen, iph->saddr, iph->daddr))
-			goto out;
-		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (np->local_ip.ip && np->local_ip.ip != iph->daddr)
-				continue;
-			if (np->remote_ip.ip && np->remote_ip.ip != iph->saddr)
-				continue;
-			if (np->local_port && np->local_port != ntohs(uh->dest))
-				continue;
-
-			np->rx_skb_hook(np, source, skb, offset, data_len);
-			hits++;
-		}
-	} else {
-#if IS_ENABLED(CONFIG_IPV6)
-		const struct ipv6hdr *ip6h;
-
-		if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-			goto out;
-		ip6h = (struct ipv6hdr *)skb->data;
-		if (ip6h->version != 6)
-			goto out;
-		len = ntohs(ip6h->payload_len);
-		if (!len)
-			goto out;
-		if (len + sizeof(struct ipv6hdr) > skb->len)
-			goto out;
-		if (pskb_trim_rcsum(skb, len + sizeof(struct ipv6hdr)))
-			goto out;
-		ip6h = ipv6_hdr(skb);
-		if (!pskb_may_pull(skb, sizeof(struct udphdr)))
-			goto out;
-		uh = udp_hdr(skb);
-		offset = (unsigned char *)(uh + 1) - skb->data;
-		ulen = ntohs(uh->len);
-		data_len = skb->len - offset;
-		source = ntohs(uh->source);
-		if (ulen != skb->len)
-			goto out;
-		if (udp6_csum_init(skb, uh, IPPROTO_UDP))
-			goto out;
-		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			if (!ipv6_addr_equal(&np->local_ip.in6, &ip6h->daddr))
-				continue;
-			if (!ipv6_addr_equal(&np->remote_ip.in6, &ip6h->saddr))
-				continue;
-			if (np->local_port && np->local_port != ntohs(uh->dest))
-				continue;
-
-			np->rx_skb_hook(np, source, skb, offset, data_len);
-			hits++;
-		}
-#endif
-	}
-
-	if (!hits)
-		goto out;
-
-	kfree_skb(skb);
-	return 1;
-
-out:
-	if (atomic_read(&trapped)) {
-		kfree_skb(skb);
-		return 1;
-	}
-
-	return 0;
-}
-
 void netpoll_print_options(struct netpoll *np)
 {
 	np_info(np, "local port %d\n", np->local_port);
@@ -1030,7 +597,6 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 {
 	struct netpoll_info *npinfo;
 	const struct net_device_ops *ops;
-	unsigned long flags;
 	int err;
 
 	np->dev = ndev;
@@ -1052,12 +618,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 			goto out;
 		}
 
-		npinfo->rx_flags = 0;
-		INIT_LIST_HEAD(&npinfo->rx_np);
-
-		spin_lock_init(&npinfo->rx_lock);
 		sema_init(&npinfo->dev_lock, 1);
-		skb_queue_head_init(&npinfo->neigh_tx);
 		skb_queue_head_init(&npinfo->txq);
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
 
@@ -1076,13 +637,6 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 
 	npinfo->netpoll = np;
 
-	if (np->rx_skb_hook) {
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
-		list_add_tail(&np->rx, &npinfo->rx_np);
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-	}
-
 	/* last thing to do is link it to the net device structure */
 	rcu_assign_pointer(ndev->npinfo, npinfo);
 
@@ -1231,7 +785,6 @@ static void rcu_cleanup_netpoll_info(struct rcu_head *rcu_head)
 	struct netpoll_info *npinfo =
 			container_of(rcu_head, struct netpoll_info, rcu);
 
-	skb_queue_purge(&npinfo->neigh_tx);
 	skb_queue_purge(&npinfo->txq);
 
 	/* we can't call cancel_delayed_work_sync here, as we are in softirq */
@@ -1247,7 +800,6 @@ static void rcu_cleanup_netpoll_info(struct rcu_head *rcu_head)
 void __netpoll_cleanup(struct netpoll *np)
 {
 	struct netpoll_info *npinfo;
-	unsigned long flags;
 
 	/* rtnl_dereference would be preferable here but
 	 * rcu_cleanup_netpoll path can put us in here safely without
@@ -1257,14 +809,6 @@ void __netpoll_cleanup(struct netpoll *np)
 	if (!npinfo)
 		return;
 
-	if (!list_empty(&npinfo->rx_np)) {
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		list_del(&np->rx);
-		if (list_empty(&npinfo->rx_np))
-			npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-	}
-
 	synchronize_srcu(&netpoll_srcu);
 
 	if (atomic_dec_and_test(&npinfo->refcnt)) {
@@ -1308,18 +852,3 @@ out:
 	rtnl_unlock();
 }
 EXPORT_SYMBOL(netpoll_cleanup);
-
-int netpoll_trap(void)
-{
-	return atomic_read(&trapped);
-}
-EXPORT_SYMBOL(netpoll_trap);
-
-void netpoll_set_trap(int trap)
-{
-	if (trap)
-		atomic_inc(&trapped);
-	else
-		atomic_dec(&trapped);
-}
-EXPORT_SYMBOL(netpoll_set_trap);
-- 
1.7.5.4
