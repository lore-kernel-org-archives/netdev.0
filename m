From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/6] ipv6: Remove all uses of LL_ALLOCATED_SPACE
Date: Fri, 18 Nov 2011 20:20:04 +0800
Message-ID: <E1RRNQK-0000lD-DX@gondolin.me.apana.org.au>
References: <20111118121832.GA2868@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	evonlanthen@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, timo.teras@iki.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipv6: Remove all uses of LL_ALLOCATED_SPACE

The macro LL_ALLOCATED_SPACE was ill-conceived.  It applies the
alignment to the sum of needed_headroom and needed_tailroom.  As
the amount that is then reserved for head room is needed_headroom
with alignment, this means that the tail room left may be too small.

This patch replaces all uses of LL_ALLOCATED_SPACE in net/ipv6
with the macro LL_RESERVED_SPACE and direct reference to
needed_tailroom.

This also fixes the problem with needed_headroom changing between
allocating the skb and reserving the head room.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/ip6_output.c |    8 ++++++--
 net/ipv6/mcast.c      |   12 ++++++++----
 net/ipv6/ndisc.c      |   13 +++++++++----
 net/ipv6/raw.c        |    6 ++++--
 4 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 84d0bd5..68ef97f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -631,6 +631,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	struct ipv6hdr *tmp_hdr;
 	struct frag_hdr *fh;
 	unsigned int mtu, hlen, left, len;
+	int hroom, troom;
 	__be32 frag_id = 0;
 	int ptr, offset = 0, err=0;
 	u8 *prevhdr, nexthdr = 0;
@@ -797,6 +798,8 @@ slow_path:
 	 */
 
 	*prevhdr = NEXTHDR_FRAGMENT;
+	hroom = LL_RESERVED_SPACE(rt->dst.dev);
+	troom = rt->dst.dev->needed_tailroom;
 
 	/*
 	 *	Keep copying data until we run out.
@@ -815,7 +818,8 @@ slow_path:
 		 *	Allocate buffer.
 		 */
 
-		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_ALLOCATED_SPACE(rt->dst.dev), GFP_ATOMIC)) == NULL) {
+		if ((frag = alloc_skb(len + hlen + sizeof(struct frag_hdr) +
+				      hroom + troom, GFP_ATOMIC)) == NULL) {
 			NETDEBUG(KERN_INFO "IPv6: frag: no memory for new fragment!\n");
 			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 				      IPSTATS_MIB_FRAGFAILS);
@@ -828,7 +832,7 @@ slow_path:
 		 */
 
 		ip6_copy_metadata(frag, skb);
-		skb_reserve(frag, LL_RESERVED_SPACE(rt->dst.dev));
+		skb_reserve(frag, hroom);
 		skb_put(frag, len + hlen + sizeof(struct frag_hdr));
 		skb_reset_network_header(frag);
 		fh = (struct frag_hdr *)(skb_network_header(frag) + hlen);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index ee7839f..7b94beb 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1343,13 +1343,15 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 	struct mld2_report *pmr;
 	struct in6_addr addr_buf;
 	const struct in6_addr *saddr;
+	int hlen = LL_RESERVED_SPACE(dev);
+	int tlen = dev->needed_tailroom;
 	int err;
 	u8 ra[8] = { IPPROTO_ICMPV6, 0,
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
 		     IPV6_TLV_PADN, 0 };
 
 	/* we assume size > sizeof(ra) here */
-	size += LL_ALLOCATED_SPACE(dev);
+	size += hlen + tlen;
 	/* limit our allocations to order-0 page */
 	size = min_t(int, size, SKB_MAX_ORDER(0, 0));
 	skb = sock_alloc_send_skb(sk, size, 1, &err);
@@ -1357,7 +1359,7 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 	if (!skb)
 		return NULL;
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 
 	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
@@ -1723,6 +1725,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	struct mld_msg *hdr;
 	const struct in6_addr *snd_addr, *saddr;
 	struct in6_addr addr_buf;
+	int hlen = LL_RESERVED_SPACE(dev);
+	int tlen = dev->needed_tailroom;
 	int err, len, payload_len, full_len;
 	u8 ra[8] = { IPPROTO_ICMPV6, 0,
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
@@ -1744,7 +1748,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 		      IPSTATS_MIB_OUT, full_len);
 	rcu_read_unlock();
 
-	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + full_len, 1, &err);
+	skb = sock_alloc_send_skb(sk, hlen + tlen + full_len, 1, &err);
 
 	if (skb == NULL) {
 		rcu_read_lock();
@@ -1754,7 +1758,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 		return;
 	}
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 
 	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 44e5b7f..5f191c4 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -446,6 +446,8 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
+	int hlen = LL_RESERVED_SPACE(dev);
+	int tlen = dev->needed_tailroom;
 	int len;
 	int err;
 	u8 *opt;
@@ -459,7 +461,7 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 
 	skb = sock_alloc_send_skb(sk,
 				  (MAX_HEADER + sizeof(struct ipv6hdr) +
-				   len + LL_ALLOCATED_SPACE(dev)),
+				   len + hlen + tlen),
 				  1, &err);
 	if (!skb) {
 		ND_PRINTK0(KERN_ERR
@@ -468,7 +470,7 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 		return NULL;
 	}
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
 
 	skb->transport_header = skb->tail;
@@ -1533,6 +1535,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	struct inet6_dev *idev;
 	struct flowi6 fl6;
 	u8 *opt;
+	int hlen, tlen;
 	int rd_len;
 	int err;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
@@ -1590,9 +1593,11 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	rd_len &= ~0x7;
 	len += rd_len;
 
+	hlen = LL_RESERVED_SPACE(dev);
+	tlen = dev->needed_tailroom;
 	buff = sock_alloc_send_skb(sk,
 				   (MAX_HEADER + sizeof(struct ipv6hdr) +
-				    len + LL_ALLOCATED_SPACE(dev)),
+				    len + hlen + tlen),
 				   1, &err);
 	if (buff == NULL) {
 		ND_PRINTK0(KERN_ERR
@@ -1601,7 +1606,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 		goto release;
 	}
 
-	skb_reserve(buff, LL_RESERVED_SPACE(dev));
+	skb_reserve(buff, hlen);
 	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
 		   IPPROTO_ICMPV6, len);
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 331af3b..638fb2a 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -610,6 +610,8 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	struct sk_buff *skb;
 	int err;
 	struct rt6_info *rt = (struct rt6_info *)*dstp;
+	int hlen = LL_RESERVED_SPACE(rt->dst.dev);
+	int tlen = rt->dst.dev->needed_tailroom;
 
 	if (length > rt->dst.dev->mtu) {
 		ipv6_local_error(sk, EMSGSIZE, fl6, rt->dst.dev->mtu);
@@ -619,11 +621,11 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 		goto out;
 
 	skb = sock_alloc_send_skb(sk,
-				  length + LL_ALLOCATED_SPACE(rt->dst.dev) + 15,
+				  length + hlen + tlen + 15,
 				  flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto error;
-	skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
+	skb_reserve(skb, hlen);
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
