From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V2 net-next-2.6] net: relax dst refcnt in input path
Date: Wed, 22 Jul 2009 14:22:01 +0200
Message-ID: <4A670469.2050404@gmail.com>
References: <4A66201D.9070103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53473 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbZGVMWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 08:22:24 -0400
In-Reply-To: <4A66201D.9070103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is V2 of this patch, taking into account forwarding.

dev_queue_xmit() was called with skb with non refcounted dst,
so this could be problematic, since dst could be freed, after
we left rcu read lock section, while skb waiting on output queue.


I added a WARN_ON() in dev_hard_start_xmit() to catch 'leaks' :

        /*
         * If device doesnt need skb->dst, release it right now while
         * its hot in this cpu cache
         */
        if (skb_dst(skb)) {
                if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
                        skb_dst_drop(skb);
                else
                        /*
                         * make sure dst was refcounted by caller
                         */
                        WARN_ON(!(skb->_skb_dst & SKB_DST_REFTAKEN));
        }

Then in dev_queue_xmit(), we force a refcount on !IFF_XMIT_DST_RELEASE devices

Thank you

[PATCH net-next-2.6] net: relax dst refcnt in input path

One serious point of contention in network stack is the IP route cache
refcounts in input path, on SMP setups.

On stress situation, one cpu (say A) handles network softirq RX processing.
When a packet is received, we need to find a dst_entry, take
a reference on this dst_entry and associate skb to this dst_entry.
skb is queued on a socket receive queue.

When application (running from another CPU B) dequeues this packet,
it has to release the dst_entry, which refcount is hot and dirty on
another CPU A cache, involving an expensive cache line ping-pong.

Back in November 2008, we tried to keep this cache line only
in CPU A (commit 70355602879229c6f8bd694ec9c0814222bc4936)
(net: release skb->dst in sock_queue_rcv_skb()), but we had
to revert this commit because it broke IP_PKTINFO handling,
as noticed by Mark McLoughlin

Then David suggested not taking the reference at the first place,
which this patch does when possible.

We prepared this work with commit adf30907 (net: skb->dst accessors),
introducing accessors to work on skb->dst

We now can use the low order bit of skb->_skb_dst to tell
if a reference was taken on dst for this skb

Then we add a new 'noref' parameter to ip_route_input(), to tell
this function to take or not a reference count on found dst.

We make ip_rcv_finish() calls ip_route_input() with noref=1.

When queueing a skb to socket receive queue, we drop dst
unless IP_CMSG_PKTINFO is set. 

This is done in ip_queue_rcv_skb(), a new wrapper around
sock_queue_rcv_skb(), for UDP (IPV4/IPV6) and RAW (IPV4)

In sock_queue_rcv_skb(), we check if skb has still a dst,
because we must take a reference on it unless already done.
(The dequeuing might be done long time after queueing, and
RCU wont protect dst that long)

skb_dst_drop() is called from tcp_data_queue() for TCP,
regardless of IP_CMSG_PKTINFO (not meaningfull for tcp)

Net effect of this patch is avoiding two atomic ops per
incoming packet, on possibly contented cache lines.

V2: Forwarding is taken into account by changes in dev_queue_xmit(),
forcing a dst refcount on !IFF_XMIT_DST_RELEASE devices.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h    |   35 +++++++++++++++++++++++++++-
 include/net/dst.h         |   45 ++++++++++++++++++++++++++++++++----
 include/net/ip.h          |    1
 include/net/route.h       |    3 +-
 net/bridge/br_netfilter.c |    2 -
 net/core/dev.c            |   18 ++++++++++++--
 net/core/skbuff.c         |    2 -
 net/core/sock.c           |    4 +++
 net/ipv4/arp.c            |    2 -
 net/ipv4/icmp.c           |    8 +++---
 net/ipv4/ip_input.c       |    2 -
 net/ipv4/ip_options.c     |   11 ++++----
 net/ipv4/ip_sockglue.c    |   16 ++++++++++++
 net/ipv4/netfilter.c      |    8 +++---
 net/ipv4/raw.c            |    2 -
 net/ipv4/route.c          |   15 ++++++++----
 net/ipv4/tcp_input.c      |    1
 net/ipv4/udp.c            |    2 -
 net/ipv4/xfrm4_input.c    |    2 -
 net/ipv6/ip6_tunnel.c     |    2 -
 net/ipv6/udp.c            |    2 -
 21 files changed, 147 insertions(+), 36 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f2c69a2..9d14368 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -426,13 +426,46 @@ extern void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
 			  enum dma_data_direction dir);
 #endif
 
+/*
+ * skb might have a dst pointer attached, refcounted or not
+ * _skb_dst low order bit is set if refcount was taken
+ */
+#define SKB_DST_REFTAKEN 1UL
+#define SKB_DST_PTRMASK ~1UL
+/**
+ * skb_dst - returns skb dst
+ * @skb: buffer
+ *
+ * Returns skb dst, regardless of reference taken or not.
+ */
 static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
 {
-	return (struct dst_entry *)skb->_skb_dst;
+	return (struct dst_entry *)(skb->_skb_dst & SKB_DST_PTRMASK);
 }
 
+/**
+ * skb_dst_set - sets skb dst
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was taken on dst and should
+ * be released by skb_dst_drop()
+ */
 static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
 {
+	skb->_skb_dst = (unsigned long)dst | SKB_DST_REFTAKEN;
+}
+
+/**
+ * skb_dst_set_noref - sets skb dst, without a reference
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was not taken on dst
+ * skb_dst_drop() should not dst_release() this dst
+ */
+static inline void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
+{
 	skb->_skb_dst = (unsigned long)dst;
 }
 
diff --git a/include/net/dst.h b/include/net/dst.h
index 7fc409c..9c3f0fc 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -179,13 +179,18 @@ static inline void dst_hold(struct dst_entry * dst)
 	atomic_inc(&dst->__refcnt);
 }
 
-static inline void dst_use(struct dst_entry *dst, unsigned long time)
+static inline void dst_use_noref(struct dst_entry *dst, unsigned long time)
 {
-	dst_hold(dst);
 	dst->__use++;
 	dst->lastuse = time;
 }
 
+static inline void dst_use(struct dst_entry *dst, unsigned long time)
+{
+	dst_hold(dst);
+	dst_use_noref(dst, time);
+}
+
 static inline
 struct dst_entry * dst_clone(struct dst_entry * dst)
 {
@@ -195,13 +200,45 @@ struct dst_entry * dst_clone(struct dst_entry * dst)
 }
 
 extern void dst_release(struct dst_entry *dst);
+
+static inline void __skb_dst_drop(unsigned long _skb_dst)
+{
+	if (_skb_dst & SKB_DST_REFTAKEN)
+		dst_release((struct dst_entry *)(_skb_dst & SKB_DST_PTRMASK));
+}
+/**
+ * skb_dst_drop - drops skb dst
+ * @skb: buffer
+ *
+ * Drops dst reference count if low order bit is set.
+ */
 static inline void skb_dst_drop(struct sk_buff *skb)
 {
-	if (skb->_skb_dst)
-		dst_release(skb_dst(skb));
+	__skb_dst_drop(skb->_skb_dst);
 	skb->_skb_dst = 0UL;
 }
 
+static inline void skb_dst_copy(struct sk_buff *nskb, const struct sk_buff *oskb)
+{
+	nskb->_skb_dst = oskb->_skb_dst;
+	if (nskb->_skb_dst & SKB_DST_REFTAKEN)
+		dst_clone(skb_dst(nskb));
+}
+
+/**
+ * skb_dst_force - makes sure skb dst is refcounted
+ * @skb: buffer
+ *
+ * If dst is not yet refcounted, let's do it
+ */
+static inline void skb_dst_force(struct sk_buff *skb)
+{
+	if (!(skb->_skb_dst & SKB_DST_REFTAKEN)) {
+		dst_clone(skb_dst(skb));
+		skb->_skb_dst |= SKB_DST_REFTAKEN;
+	}
+}
+
 /* Children define the path of the packet through the
  * Linux networking.  Thus, destinations are stackable.
  */
diff --git a/include/net/ip.h b/include/net/ip.h
index 72c3692..ec94680 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -378,6 +378,7 @@ extern int ip_options_rcv_srr(struct sk_buff *skb);
  *	Functions provided by ip_sockglue.c
  */
 
+extern int ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 extern void	ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
 extern int	ip_cmsg_send(struct net *net,
 			     struct msghdr *msg, struct ipcm_cookie *ipc);
diff --git a/include/net/route.h b/include/net/route.h
index 40f6346..726df35 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -115,7 +115,8 @@ extern void		rt_cache_flush(struct net *net, int how);
 extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
 extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
 extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
-extern int		ip_route_input(struct sk_buff*, __be32 dst, __be32 src, u8 tos, struct net_device *devin);
+extern int		ip_route_input(struct sk_buff*, __be32 dst, __be32 src, u8 tos,
+				       struct net_device *devin, int noref);
 extern unsigned short	ip_rt_frag_needed(struct net *net, struct iphdr *iph, unsigned short new_mtu, struct net_device *dev);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4fde742..5c88c83 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -349,7 +349,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	}
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 	if (dnat_took_place(skb)) {
-		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
+		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev, 1))) {
 			struct flowi fl = {
 				.nl_u = {
 					.ip4_u = {
diff --git a/net/core/dev.c b/net/core/dev.c
index dca8b50..e47280d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1700,9 +1700,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		 * If device doesnt need skb->dst, release it right now while
 		 * its hot in this cpu cache
 		 */
-		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
-			skb_dst_drop(skb);
-
+		if (skb_dst(skb)) {
+			if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
+				skb_dst_drop(skb);
+			else
+				/*
+				 * make sure dst was refcounted by caller
+				 */
+				WARN_ON(!(skb->_skb_dst & SKB_DST_REFTAKEN));
+		}
 		rc = ops->ndo_start_xmit(skb, dev);
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
@@ -1861,6 +1867,12 @@ gso:
 	if (q->enqueue) {
 		spinlock_t *root_lock = qdisc_lock(q);
 
+		/*
+		 * before queueing skb, we must enforce a refcounted dst
+		 */
+		if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
+			skb_dst_force(skb);
+
 		spin_lock(root_lock);
 
 		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9e0597d..37b1fc0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -530,7 +530,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->transport_header	= old->transport_header;
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;
-	skb_dst_set(new, dst_clone(skb_dst(old)));
+	skb_dst_copy(new, old);
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
diff --git a/net/core/sock.c b/net/core/sock.c
index d9eec15..2d1cf4c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -304,6 +304,10 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	 * from the queue.
 	 */
 	skb_len = skb->len;
+	/*
+	 * If we still have a dst entry linked, make sure we refcounted it
+	 */
+	skb_dst_force(skb);
 
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c29d75d..ff436be 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -812,7 +812,7 @@ static int arp_process(struct sk_buff *skb)
 	}
 
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
-	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
+	    ip_route_input(skb, tip, sip, 0, dev, 0) == 0) {
 
 		rt = skb_rtable(skb);
 		addr_type = rt->rt_type;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 97c410e..08e68d0 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -584,20 +584,20 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 			err = __ip_route_output_key(net, &rt2, &fl);
 		else {
 			struct flowi fl2 = {};
-			struct dst_entry *odst;
+			unsigned long odst;
 
 			fl2.fl4_dst = fl.fl4_src;
 			if (ip_route_output_key(net, &rt2, &fl2))
 				goto relookup_failed;
 
 			/* Ugh! */
-			odst = skb_dst(skb_in);
+			odst = skb_in->_skb_dst; /* save old dst */
 			err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
-					     RT_TOS(tos), rt2->u.dst.dev);
+					     RT_TOS(tos), rt2->u.dst.dev, 0);
 
 			dst_release(&rt2->u.dst);
 			rt2 = skb_rtable(skb_in);
-			skb_dst_set(skb_in, odst);
+			skb_in->_skb_dst = odst; /* restore old dst */
 		}
 
 		if (err)
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index db46b4b..23e974b 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -331,7 +331,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 */
 	if (skb_dst(skb) == NULL) {
 		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
-					 skb->dev);
+					 skb->dev, 1);
 		if (unlikely(err)) {
 			if (err == -EHOSTUNREACH)
 				IP_INC_STATS_BH(dev_net(skb->dev),
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 94bf105..e45abbd 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -600,6 +600,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	unsigned char *optptr = skb_network_header(skb) + opt->srr;
 	struct rtable *rt = skb_rtable(skb);
 	struct rtable *rt2;
+	unsigned long odst;
 	int err;
 
 	if (!opt->srr)
@@ -623,16 +624,16 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 		}
 		memcpy(&nexthop, &optptr[srrptr-1], 4);
 
-		rt = skb_rtable(skb);
+		odst = skb->_skb_dst;
 		skb_dst_set(skb, NULL);
-		err = ip_route_input(skb, nexthop, iph->saddr, iph->tos, skb->dev);
+		err = ip_route_input(skb, nexthop, iph->saddr, iph->tos, skb->dev, 0);
 		rt2 = skb_rtable(skb);
 		if (err || (rt2->rt_type != RTN_UNICAST && rt2->rt_type != RTN_LOCAL)) {
-			ip_rt_put(rt2);
-			skb_dst_set(skb, &rt->u.dst);
+			skb_dst_drop(skb);
+			skb->_skb_dst = odst;
 			return -EINVAL;
 		}
-		ip_rt_put(rt);
+		__skb_dst_drop(odst);
 		if (rt2->rt_type != RTN_LOCAL)
 			break;
 		/* Superfast 8) loopback forward */
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index fc7993e..7349554 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -946,6 +946,22 @@ e_inval:
 	return -EINVAL;
 }
 
+/**
+ * ip_queue_rcv_skb - Queue an skb into sock receive queue
+ * @sk: socket
+ * @skb: buffer
+ *
+ * Queues an skb into socket receive queue. If IP_CMSG_PKTINFO option
+ * is not set, we drop skb dst entry now.
+ */
+int ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO))
+		skb_dst_drop(skb);
+	return sock_queue_rcv_skb(sk, skb);
+}
+EXPORT_SYMBOL(ip_queue_rcv_skb);
+
 int ip_setsockopt(struct sock *sk, int level,
 		int optname, char __user *optval, int optlen)
 {
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 1725dc0..7eb2a20 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -16,7 +16,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi fl = {};
-	struct dst_entry *odst;
+	unsigned long odst;
 	unsigned int hh_len;
 	unsigned int type;
 
@@ -50,14 +50,14 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		if (ip_route_output_key(net, &rt, &fl) != 0)
 			return -1;
 
-		odst = skb_dst(skb);
+		odst = skb->_skb_dst;
 		if (ip_route_input(skb, iph->daddr, iph->saddr,
-				   RT_TOS(iph->tos), rt->u.dst.dev) != 0) {
+				   RT_TOS(iph->tos), rt->u.dst.dev, 0) != 0) {
 			dst_release(&rt->u.dst);
 			return -1;
 		}
 		dst_release(&rt->u.dst);
-		dst_release(odst);
+		__skb_dst_drop(odst);
 	}
 
 	if (skb_dst(skb)->error)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2979f14..ccccd91 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -291,7 +291,7 @@ static int raw_rcv_skb(struct sock * sk, struct sk_buff * skb)
 {
 	/* Charge it to the socket. */
 
-	if (sock_queue_rcv_skb(sk, skb) < 0) {
+	if (ip_queue_rcv_skb(sk, skb) < 0) {
 		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
 		return NET_RX_DROP;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 278f46f..e66d85d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2255,7 +2255,7 @@ martian_source:
 }
 
 int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-		   u8 tos, struct net_device *dev)
+		   u8 tos, struct net_device *dev, int noref)
 {
 	struct rtable * rth;
 	unsigned	hash;
@@ -2281,10 +2281,15 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->fl.mark == skb->mark &&
 		    net_eq(dev_net(rth->u.dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-			dst_use(&rth->u.dst, jiffies);
+			if (noref) {
+				dst_use_noref(&rth->u.dst, jiffies);
+				skb_dst_set_noref(skb, &rth->u.dst);
+			} else {
+				dst_use(&rth->u.dst, jiffies);
+				skb_dst_set(skb, &rth->u.dst);
+			}
 			RT_CACHE_STAT_INC(in_hit);
 			rcu_read_unlock();
-			skb_dst_set(skb, &rth->u.dst);
 			return 0;
 		}
 		RT_CACHE_STAT_INC(in_hlist_search);
@@ -2944,7 +2949,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		skb->protocol	= htons(ETH_P_IP);
 		skb->dev	= dev;
 		local_bh_disable();
-		err = ip_route_input(skb, dst, src, rtm->rtm_tos, dev);
+		err = ip_route_input(skb, dst, src, rtm->rtm_tos, dev, 0);
 		local_bh_enable();
 
 		rt = skb_rtable(skb);
@@ -3008,7 +3013,7 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 				continue;
 			if (rt_is_expired(rt))
 				continue;
-			skb_dst_set(skb, dst_clone(&rt->u.dst));
+			skb_dst_set_noref(skb, &rt->u.dst);
 			if (rt_fill_info(net, skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					 1, NLM_F_MULTI) <= 0) {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2bdb0da..32fb9c6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4297,6 +4297,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq)
 		goto drop;
 
+	skb_dst_drop(skb);
 	__skb_pull(skb, th->doff * 4);
 
 	TCP_ECN_accept_cwr(tp, skb);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 29ebb0d..094f1ad 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1024,7 +1024,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	int is_udplite = IS_UDPLITE(sk);
 	int rc;
 
-	if ((rc = sock_queue_rcv_skb(sk, skb)) < 0) {
+	if ((rc = ip_queue_rcv_skb(sk, skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM) {
 			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index f9f922a..fd5310b 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -27,7 +27,7 @@ static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 		const struct iphdr *iph = ip_hdr(skb);
 
 		if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
-				   skb->dev))
+				   skb->dev, 1))
 			goto drop;
 	}
 	return dst_input(skb);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a1d6045..94a23b9 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -564,7 +564,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	} else {
 		ip_rt_put(rt);
 		if (ip_route_input(skb2, eiph->daddr, eiph->saddr, eiph->tos,
-				   skb2->dev) ||
+				   skb2->dev, 0) ||
 		    skb_dst(skb2)->dev->type != ARPHRD_TUNNEL)
 			goto out;
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d79fa67..5732ff5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -385,7 +385,7 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 			goto drop;
 	}
 
-	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
+	if ((rc = ip_queue_rcv_skb(sk, skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM) {
 			UDP6_INC_STATS_BH(sock_net(sk),
