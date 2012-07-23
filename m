From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Mon, 23 Jul 2012 16:04:33 -0700 (PDT)
Message-ID: <20120723.160433.1634330030961496713.davem@davemloft.net>
References: <20120723.140737.822125500680433996.davem@davemloft.net>
	<20120723.152220.822947775372843073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab2GWXEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 19:04:36 -0400
In-Reply-To: <20120723.152220.822947775372843073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 23 Jul 2012 15:22:20 -0700 (PDT)

> From: David Miller <davem@davemloft.net>
> Date: Mon, 23 Jul 2012 14:07:37 -0700 (PDT)
> 
>> On input packet processing, rt->rt_iif will be zero if we should
>> use skb->dev->ifindex.
>> 
>> Since we access rt->rt_iif consistently via inet_iif(), that is
>> the only spot whose interpretation have to adjust.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Julian, as you seem to have feared, this turns out to not work.
> 
> We zap the skb->dev apparently, so I'll need to come up with
> a different scheme to handle this.

Just to clarify, the specific issue is that tcp input will set
skb->dev to NULL right before we lock the socket and try to process
the packet in that socket's context.

So inet_iif() implemented conditionally using skb->dev won't
work without some kind of adjustment.

And we need to do inet_iif() even after we have the top-level
socket in-hand, in order to lookup listener socket children,
and maintain the cached RX dst.

Oddly enough, I had expected that this sort of change came from Eric
Dumazet as some kind of optimization, but it's rather a poorly
documented change from many years ago apparently written by your's
truly :-)

--------------------
commit 72ffc30d67f33b69ce4596b940a66e45bf5994b3
Author: davem <davem>
Date:   Fri Dec 8 17:15:53 2000 +0000

    Kill both is_clone and rx_dev from sk_buff, both
    were superfluous.

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index feb7236..8744f61 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -785,8 +785,7 @@ int pppoe_sendmsg(struct socket *sock, struct msghdr *m,
 	skb_reserve(skb, dev->hard_header_len);
 	skb->nh.raw = skb->data;
 
-	skb->rx_dev = skb->dev = dev;
-	dev_hold(skb->rx_dev);
+	skb->dev = dev;
 
 	skb->priority = sk->priority;
 	skb->protocol = __constant_htons(ETH_P_PPP_SES);
@@ -869,11 +868,7 @@ int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 
 	skb->nh.raw = skb->data;
 
-	/* Change device of skb, update reference counts */
-	if(skb->rx_dev)
-	    dev_put(skb->rx_dev);
-	skb->rx_dev = skb->dev = dev;
-	dev_hold(skb->rx_dev);
+	skb->dev = dev;
 
 	dev->hard_header(skb, dev, ETH_P_PPP_SES,
 			 sk->protinfo.pppox->pppoe_pa.remote,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c67f8c8..17e48d0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -65,8 +65,7 @@ struct sk_buff {
 	struct sk_buff_head * list;		/* List we are on				*/
 	struct sock	*sk;			/* Socket we are owned by 			*/
 	struct timeval	stamp;			/* Time we arrived				*/
-	struct net_device	*dev;			/* Device we arrived on/are leaving by		*/
-	struct net_device	*rx_dev;
+	struct net_device	*dev;		/* Device we arrived on/are leaving by		*/
 
 	/* Transport layer header */
 	union
@@ -110,8 +109,7 @@ struct sk_buff {
 	unsigned int 	len;			/* Length of actual data			*/
 	unsigned int	csum;			/* Checksum 					*/
 	volatile char 	used;			/* Data moved to user and not MSG_PEEK		*/
-	unsigned char	is_clone,		/* We are a clone				*/
-			cloned, 		/* head may be cloned (check refcnt to be sure). */
+	unsigned char	cloned, 		/* head may be cloned (check refcnt to be sure). */
   			pkt_type,		/* Packet class					*/
   			ip_summed;		/* Driver fed us an IP checksum			*/
 	__u32		priority;		/* Packet queueing priority			*/
diff --git a/include/net/sock.h b/include/net/sock.h
index 4b3a82b..8550282 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1169,6 +1169,7 @@ static inline int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	}
 #endif /* CONFIG_FILTER */
 
+	skb->dev = NULL;
 	skb_set_owner_r(skb, sk);
 	skb_queue_tail(&sk->receive_queue, skb);
 	if (!sk->dead)
diff --git a/net/core/dev.c b/net/core/dev.c
index 0f097b8..f8d5437 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -617,7 +617,7 @@ void netdev_state_change(struct net_device *dev)
 
 void dev_load(const char *name)
 {
-	if (!__dev_get_by_name(name) && capable(CAP_SYS_MODULE))
+	if (!dev_get(name) && capable(CAP_SYS_MODULE))
 		request_module(name);
 }
 
@@ -875,8 +875,6 @@ void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 
 			skb2->h.raw = skb2->nh.raw;
 			skb2->pkt_type = PACKET_OUTGOING;
-			skb2->rx_dev = skb->dev;
-			dev_hold(skb2->rx_dev);
 			ptype->func(skb2, skb->dev, ptype);
 		}
 	}
@@ -1129,10 +1127,7 @@ int netif_rx(struct sk_buff *skb)
 				goto drop;
 
 enqueue:
-			if (skb->rx_dev)
-				dev_put(skb->rx_dev);
-			skb->rx_dev = skb->dev;
-			dev_hold(skb->rx_dev);
+			dev_hold(skb->dev);
 			__skb_queue_tail(&queue->input_pkt_queue,skb);
 			__cpu_raise_softirq(this_cpu, NET_RX_SOFTIRQ);
 			local_irq_restore(flags);
@@ -1206,11 +1201,11 @@ static int deliver_to_old_ones(struct packet_type *pt, struct sk_buff *skb, int
  */
 static __inline__ void skb_bond(struct sk_buff *skb)
 {
-	struct net_device *dev = skb->rx_dev;
+	struct net_device *dev = skb->dev;
 	
 	if (dev->master) {
 		dev_hold(dev->master);
-		skb->dev = skb->rx_dev = dev->master;
+		skb->dev = dev->master;
 		dev_put(dev);
 	}
 }
@@ -1320,6 +1315,7 @@ static void net_rx_action(struct softirq_action *h)
 
 	for (;;) {
 		struct sk_buff *skb;
+		struct net_device *rx_dev;
 
 		local_irq_disable();
 		skb = __skb_dequeue(&queue->input_pkt_queue);
@@ -1330,10 +1326,13 @@ static void net_rx_action(struct softirq_action *h)
 
 		skb_bond(skb);
 
+		rx_dev = skb->dev;
+
 #ifdef CONFIG_NET_FASTROUTE
 		if (skb->pkt_type == PACKET_FASTROUTE) {
 			netdev_rx_stat[this_cpu].fastroute_deferred_out++;
 			dev_queue_xmit(skb);
+			dev_put(rx_dev);
 			continue;
 		}
 #endif
@@ -1369,6 +1368,7 @@ static void net_rx_action(struct softirq_action *h)
 			if (skb->dev->br_port != NULL &&
 			    br_handle_frame_hook != NULL) {
 				handle_bridge(skb, pt_prev);
+				dev_put(rx_dev)
 				continue;
 			}
 #endif
@@ -1399,6 +1399,8 @@ static void net_rx_action(struct softirq_action *h)
 				kfree_skb(skb);
 		}
 
+		dev_put(rx_dev);
+
 		if (bugdet-- < 0 || jiffies - start_time > 1)
 			goto softnet_break;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d7f575d..1d8dc09 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4,7 +4,7 @@
  *	Authors:	Alan Cox <iiitac@pyr.swan.ac.uk>
  *			Florian La Roche <rzsfl@rz.uni-sb.de>
  *
- *	Version:	$Id: skbuff.c,v 1.74 2000-12-06 11:45:19 anton Exp $
+ *	Version:	$Id: skbuff.c,v 1.75 2000-12-08 17:15:53 davem Exp $
  *
  *	Fixes:	
  *		Alan Cox	:	Fixed the worst of the load balancer bugs.
@@ -202,7 +202,6 @@ struct sk_buff *alloc_skb(unsigned int size,int gfp_mask)
 
 	/* Set up other state */
 	skb->len = 0;
-	skb->is_clone = 0;
 	skb->cloned = 0;
 
 	atomic_set(&skb->users, 1); 
@@ -233,7 +232,6 @@ static inline void skb_headerinit(void *p, kmem_cache_t *cache,
 	skb->ip_summed = 0;
 	skb->security = 0;	/* By default packets are insecure */
 	skb->dst = NULL;
-	skb->rx_dev = NULL;
 #ifdef CONFIG_NETFILTER
 	skb->nfmark = skb->nfcache = 0;
 	skb->nfct = NULL;
@@ -287,10 +285,6 @@ void __kfree_skb(struct sk_buff *skb)
 #ifdef CONFIG_NETFILTER
 	nf_conntrack_put(skb->nfct);
 #endif
-#ifdef CONFIG_NET		
-	if(skb->rx_dev)
-		dev_put(skb->rx_dev);
-#endif		
 	skb_headerinit(skb, NULL, 0);  /* clean state */
 	kfree_skbmem(skb);
 }
@@ -325,12 +319,10 @@ struct sk_buff *skb_clone(struct sk_buff *skb, int gfp_mask)
 	skb->cloned = 1;
        
 	dst_clone(n->dst);
-	n->rx_dev = NULL;
 	n->cloned = 1;
 	n->next = n->prev = NULL;
 	n->list = NULL;
 	n->sk = NULL;
-	n->is_clone = 1;
 	atomic_set(&n->users, 1);
 	n->destructor = NULL;
 #ifdef CONFIG_NETFILTER
@@ -349,7 +341,6 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->list=NULL;
 	new->sk=NULL;
 	new->dev=old->dev;
-	new->rx_dev=NULL;
 	new->priority=old->priority;
 	new->protocol=old->protocol;
 	new->dst=dst_clone(old->dst);
@@ -358,7 +349,6 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->mac.raw=old->mac.raw+offset;
 	memcpy(new->cb, old->cb, sizeof(old->cb));
 	new->used=old->used;
-	new->is_clone=0;
 	atomic_set(&new->users, 1);
 	new->pkt_type=old->pkt_type;
 	new->stamp=old->stamp;
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 4754cd8..3617294 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -78,9 +78,9 @@ extern int decnet_log_martians;
 static void dn_log_martian(struct sk_buff *skb, const char *msg)
 {
 	if (decnet_log_martians && net_ratelimit()) {
-		char *devname = skb->rx_dev ? skb->rx_dev->name : "???";
+		char *devname = skb->dev ? skb->dev->name : "???";
 		struct dn_skb_cb *cb = (struct dn_skb_cb *)skb->cb;
-		printk(KERN_INFO "DECnet: Martian packet (%s) rx_dev=%s src=0x%04hx dst=0x%04hx srcport=0x%04hx dstport=0x%04hx\n", msg, devname, cb->src, cb->dst, cb->src_port, cb->dst_port);
+		printk(KERN_INFO "DECnet: Martian packet (%s) dev=%s src=0x%04hx dst=0x%04hx srcport=0x%04hx dstport=0x%04hx\n", msg, devname, cb->src, cb->dst, cb->src_port, cb->dst_port);
 	}
 }
 
@@ -782,7 +782,7 @@ free_out:
 
 int dn_nsp_rx(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_DECnet, NF_DN_LOCAL_IN, skb, skb->rx_dev, NULL, dn_nsp_rx_packet);
+	return NF_HOOK(PF_DECnet, NF_DN_LOCAL_IN, skb, skb->dev, NULL, dn_nsp_rx_packet);
 }
 
 /*
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 20ec07a..70646fc 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -526,6 +526,7 @@ static int dn_forward(struct sk_buff *skb)
 {
 	struct dn_skb_cb *cb = (struct dn_skb_cb *)skb->cb;
 	struct dst_entry *dst = skb->dst;
+	struct net_device *dev = skb->dev;
 	struct neighbour *neigh;
 	int err = -EINVAL;
 
@@ -551,7 +552,7 @@ static int dn_forward(struct sk_buff *skb)
 	else
 		cb->rt_flags &= ~DN_RT_F_IE;
 
-	return NF_HOOK(PF_DECnet, NF_DN_FORWARD, skb, skb->rx_dev, skb->dev, neigh->output);
+	return NF_HOOK(PF_DECnet, NF_DN_FORWARD, skb, dev, skb->dev, neigh->output);
 
 
 error:
@@ -985,7 +986,6 @@ int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
 		}
 		skb->protocol = __constant_htons(ETH_P_DNA_RT);
 		skb->dev = dev;
-		skb->rx_dev = dev;
 		cb->src = src;
 		cb->dst = dst;
 		local_bh_disable();
@@ -1002,7 +1002,6 @@ int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
 	if (skb->dev)
 		dev_put(skb->dev);
 	skb->dev = NULL;
-	skb->rx_dev = NULL;
 	if (err)
 		goto out_free;
 	skb->dst = &rt->u.dst;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b520899..3dec2c7 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -5,7 +5,7 @@
  *
  *		The IP fragmentation functionality.
  *		
- * Version:	$Id: ip_fragment.c,v 1.52 2000-11-28 13:32:54 davem Exp $
+ * Version:	$Id: ip_fragment.c,v 1.53 2000-12-08 17:15:53 davem Exp $
  *
  * Authors:	Fred N. van Kempen <waltje@uWalt.NL.Mugnet.ORG>
  *		Alan Cox <Alan.Cox@linux.org>
@@ -83,7 +83,7 @@ struct ipq {
 	atomic_t	refcnt;
 	struct timer_list timer;	/* when will this queue expire?		*/
 	struct ipq	**pprev;
-	struct net_device	*dev;	/* Device - for icmp replies */
+	int		iif;		/* Device index - for icmp replies	*/
 };
 
 /* Hash table. */
@@ -255,8 +255,13 @@ static void ip_expire(unsigned long arg)
 	IP_INC_STATS_BH(IpReasmFails);
 
 	if ((qp->last_in&FIRST_IN) && qp->fragments != NULL) {
+		struct sk_buff *head = qp->fragments;
+
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
-		icmp_send(qp->fragments, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
+		if ((head->dev = dev_get_by_index(qp->iif)) != NULL) {
+			icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
+			dev_put(head->dev);
+		}
 	}
 out:
 	spin_unlock(&qp->lock);
@@ -480,7 +485,8 @@ static void ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	else
 		qp->fragments = skb;
 
-	qp->dev = skb->dev;
+	qp->iif = skb->dev->ifindex;
+	skb->dev = NULL;
 	qp->meat += skb->len;
 	atomic_add(skb->truesize, &ip_frag_mem);
 	if (offset == 0)
@@ -499,7 +505,7 @@ err:
  * of bits on input. Until the new skb data handling is in I'm not going
  * to touch this with a bargepole. 
  */
-static struct sk_buff *ip_frag_reasm(struct ipq *qp)
+static struct sk_buff *ip_frag_reasm(struct ipq *qp, struct net_device *dev)
 {
 	struct sk_buff *skb;
 	struct iphdr *iph;
@@ -546,7 +552,7 @@ static struct sk_buff *ip_frag_reasm(struct ipq *qp)
 	skb->dst = dst_clone(head->dst);
 	skb->pkt_type = head->pkt_type;
 	skb->protocol = head->protocol;
-	skb->dev = qp->dev;
+	skb->dev = dev;
 
 	/*
 	*  Clearly bogus, because security markings of the individual
@@ -595,6 +601,7 @@ struct sk_buff *ip_defrag(struct sk_buff *skb)
 {
 	struct iphdr *iph = skb->nh.iph;
 	struct ipq *qp;
+	struct net_device *dev;
 	
 	IP_INC_STATS_BH(IpReasmReqds);
 
@@ -602,6 +609,8 @@ struct sk_buff *ip_defrag(struct sk_buff *skb)
 	if (atomic_read(&ip_frag_mem) > sysctl_ipfrag_high_thresh)
 		ip_evictor();
 
+	dev = skb->dev;
+
 	/* Lookup (or create) queue header */
 	if ((qp = ip_find(iph)) != NULL) {
 		struct sk_buff *ret = NULL;
@@ -612,7 +621,7 @@ struct sk_buff *ip_defrag(struct sk_buff *skb)
 
 		if (qp->last_in == (FIRST_IN|LAST_IN) &&
 		    qp->meat == qp->len)
-			ret = ip_frag_reasm(qp);
+			ret = ip_frag_reasm(qp, dev);
 
 		spin_unlock(&qp->lock);
 		ipq_put(qp);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 120c844..c98617d 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -5,7 +5,7 @@
  *
  *		The Internet Protocol (IP) module.
  *
- * Version:	$Id: ip_input.c,v 1.50 2000-10-24 22:54:26 davem Exp $
+ * Version:	$Id: ip_input.c,v 1.51 2000-12-08 17:15:53 davem Exp $
  *
  * Authors:	Ross Biro, <bir7@leland.Stanford.Edu>
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
@@ -225,12 +225,6 @@ static inline int ip_local_deliver_finish(struct sk_buff *skb)
 	nf_debug_ip_local_deliver(skb);
 #endif /*CONFIG_NETFILTER_DEBUG*/
 
-	/* Free rx_dev before enqueueing to sockets */
-	if (skb->rx_dev) {
-		dev_put(skb->rx_dev);
-		skb->rx_dev = NULL;
-	}
-
         /* Point into the IP datagram, just past the header. */
         skb->h.raw = skb->nh.raw + iph->ihl*4;
 
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 73fd4ea..9c8d493 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -400,13 +400,6 @@ static struct sk_buff *netlink_build_message(ipq_queue_element_t *e, int *errp)
 	if (e->info->outdev) strcpy(pm->outdev_name, e->info->outdev->name);
 	else pm->outdev_name[0] = '\0';
 	pm->hw_protocol = e->skb->protocol;
-	if (e->skb->rx_dev) {
-		pm->hw_type = e->skb->rx_dev->type;
-		if (e->skb->rx_dev->hard_header_parse)
-			pm->hw_addrlen =
-				e->skb->rx_dev->hard_header_parse(e->skb,
-				                                  pm->hw_addr);
-	}
 	if (data_len)
 		memcpy(pm->payload, e->skb->data, data_len);
 	nlh->nlmsg_len = skb->tail - old_tail;
diff --git a/net/ipv4/netfilter/ipt_MIRROR.c b/net/ipv4/netfilter/ipt_MIRROR.c
index cb5362d..9449c51 100644
--- a/net/ipv4/netfilter/ipt_MIRROR.c
+++ b/net/ipv4/netfilter/ipt_MIRROR.c
@@ -50,7 +50,7 @@ static int route_mirror(struct sk_buff *skb)
 
 	/* check if the interface we are leaving by is the same as the
            one we arrived on */
-	if (skb->rx_dev == rt->u.dst.dev) {
+	if (skb->dev == rt->u.dst.dev) {
 		/* Drop old route. */
 		dst_release(skb->dst);
 		skb->dst = &rt->u.dst;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 27ff7be..7c06a6b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -5,7 +5,7 @@
  *
  *		Implementation of the Transmission Control Protocol(TCP).
  *
- * Version:	$Id: tcp_ipv4.c,v 1.221 2000-11-28 17:04:10 davem Exp $
+ * Version:	$Id: tcp_ipv4.c,v 1.222 2000-12-08 17:15:53 davem Exp $
  *
  *		IPv4 specific functions
  *
@@ -1649,6 +1649,8 @@ process:
 	if (sk->state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
+	skb->dev = NULL;
+
 	bh_lock_sock(sk);
 	ret = 0;
 	if (!sk->lock.users) {
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index c5b645d..41b42a4 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -6,7 +6,7 @@
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *	Ian P. Morris		<I.P.Morris@soton.ac.uk>
  *
- *	$Id: ip6_input.c,v 1.17 2000-02-27 19:42:53 davem Exp $
+ *	$Id: ip6_input.c,v 1.18 2000-12-08 17:15:54 davem Exp $
  *
  *	Based in linux/net/ipv4/ip_input.c
  *
@@ -146,11 +146,6 @@ static inline int ip6_input_finish(struct sk_buff *skb)
 	}
 	len = skb->tail - skb->h.raw;
 
-	if (skb->rx_dev) {
-		dev_put(skb->rx_dev);
-		skb->rx_dev = NULL;
-	}
-
 	raw_sk = raw_v6_htable[nexthdr&(MAX_INET_PROTOS-1)];
 	if (raw_sk)
 		raw_sk = ipv6_raw_deliver(skb, nexthdr, len);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 4111466..edfdc23 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -5,7 +5,7 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>	
  *
- *	$Id: reassembly.c,v 1.20 2000-11-28 13:48:03 davem Exp $
+ *	$Id: reassembly.c,v 1.21 2000-12-08 17:15:54 davem Exp $
  *
  *	Based on: net/ipv4/ip_fragment.c
  *
@@ -78,7 +78,6 @@ struct frag_queue
 	struct sk_buff		*fragments;
 	int			len;
 	int			meat;
-	struct net_device	*dev;
 	int			iif;
 	__u8			last_in;	/* has first/last segment arrived? */
 #define COMPLETE		4
@@ -476,8 +475,8 @@ static void ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	else
 		fq->fragments = skb;
 
-	fq->dev = skb->dev;
 	fq->iif = skb->dev->ifindex;
+	skb->dev = NULL;
 	fq->meat += skb->len;
 	atomic_add(skb->truesize, &ip6_frag_mem);
 
@@ -507,7 +506,8 @@ err:
  *	queue is eligible for reassembly i.e. it is not COMPLETE,
  *	the last and the first frames arrived and all the bits are here.
  */
-static u8* ip6_frag_reasm(struct frag_queue *fq, struct sk_buff **skb_in)
+static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff **skb_in,
+			  struct net_device *dev)
 {
 	struct sk_buff *fp, *head = fq->fragments;
 	struct sk_buff *skb;
@@ -541,7 +541,7 @@ static u8* ip6_frag_reasm(struct frag_queue *fq, struct sk_buff **skb_in)
 
 	skb->mac.raw = skb->data;
 	skb->nh.ipv6h = (struct ipv6hdr *) skb->data;
-	skb->dev = fq->dev;
+	skb->dev = dev;
 	skb->protocol = __constant_htons(ETH_P_IPV6);
 	skb->pkt_type = head->pkt_type;
 	FRAG6_CB(skb)->h = FRAG6_CB(head)->h;
@@ -579,6 +579,7 @@ u8* ipv6_reassembly(struct sk_buff **skbp, __u8 *nhptr)
 {
 	struct sk_buff *skb = *skbp; 
 	struct frag_hdr *fhdr = (struct frag_hdr *) (skb->h.raw);
+	struct net_device *dev = skb->dev;
 	struct frag_queue *fq;
 	struct ipv6hdr *hdr;
 
@@ -616,7 +617,7 @@ u8* ipv6_reassembly(struct sk_buff **skbp, __u8 *nhptr)
 
 		if (fq->last_in == (FIRST_IN|LAST_IN) &&
 		    fq->meat == fq->len)
-			ret = ip6_frag_reasm(fq, skbp);
+			ret = ip6_frag_reasm(fq, skbp, dev);
 
 		spin_unlock(&fq->lock);
 		fq_put(fq);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0801f14..bfb5aef 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -5,7 +5,7 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>	
  *
- *	$Id: tcp_ipv6.c,v 1.127 2000-11-28 17:04:10 davem Exp $
+ *	$Id: tcp_ipv6.c,v 1.128 2000-12-08 17:15:54 davem Exp $
  *
  *	Based on: 
  *	linux/net/ipv4/tcp.c
@@ -1576,6 +1576,8 @@ process:
 	if(sk->state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
+	skb->dev = NULL;
+
 	bh_lock_sock(sk);
 	ret = 0;
 	if (!sk->lock.users) {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b30efe7..b76a320 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -5,7 +5,7 @@
  *
  *		PACKET - implements raw packet sockets.
  *
- * Version:	$Id: af_packet.c,v 1.46 2000-10-24 21:26:19 davem Exp $
+ * Version:	$Id: af_packet.c,v 1.47 2000-12-08 17:15:54 davem Exp $
  *
  * Authors:	Ross Biro, <bir7@leland.Stanford.Edu>
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
@@ -264,11 +264,6 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 	strncpy(spkt->spkt_device, dev->name, sizeof(spkt->spkt_device));
 	spkt->spkt_protocol = skb->protocol;
 
-	if (skb->rx_dev) {
-		dev_put(skb->rx_dev);
-		skb->rx_dev = NULL;
-	}
-
 	/*
 	 *	Charge the memory to the socket. This is done specifically
 	 *	to prevent sockets using all the memory up.
@@ -482,17 +477,13 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,  struct packe
 	if (dev->hard_header_parse)
 		sll->sll_halen = dev->hard_header_parse(skb, sll->sll_addr);
 
-	if (skb->rx_dev) {
-		dev_put(skb->rx_dev);
-		skb->rx_dev = NULL;
-	}
-
 #ifdef CONFIG_FILTER
 	if (skb->len > snaplen)
 		__skb_trim(skb, snaplen);
 #endif
 
 	skb_set_owner_r(skb, sk);
+	skb->dev = NULL;
 	spin_lock(&sk->receive_queue.lock);
 	po->stats.tp_packets++;
 	__skb_queue_tail(&sk->receive_queue, skb);
