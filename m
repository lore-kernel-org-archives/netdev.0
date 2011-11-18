From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/6] ipv4: Remove all uses of LL_ALLOCATED_SPACE
Date: Fri, 18 Nov 2011 20:20:04 +0800
Message-ID: <E1RRNQK-0000lA-5P@gondolin.me.apana.org.au>
References: <20111118121832.GA2868@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	evonlanthen@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, timo.teras@iki.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipv4: Remove all uses of LL_ALLOCATED_SPACE

The macro LL_ALLOCATED_SPACE was ill-conceived.  It applies the
alignment to the sum of needed_headroom and needed_tailroom.  As
the amount that is then reserved for head room is needed_headroom
with alignment, this means that the tail room left may be too small.

This patch replaces all uses of LL_ALLOCATED_SPACE in net/ipv4
with the macro LL_RESERVED_SPACE and direct reference to
needed_tailroom.

This also fixes the problem with needed_headroom changing between
allocating the skb and reserving the head room.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/arp.c      |    6 ++++--
 net/ipv4/igmp.c     |   13 +++++++++----
 net/ipv4/ipconfig.c |    6 ++++--
 net/ipv4/raw.c      |    7 +++++--
 4 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 96a164a..fb3fdbc 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -592,16 +592,18 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	struct sk_buff *skb;
 	struct arphdr *arp;
 	unsigned char *arp_ptr;
+	int hlen = LL_RESERVED_SPACE(dev);
+	int tlen = dev->needed_tailroom;
 
 	/*
 	 *	Allocate a buffer
 	 */
 
-	skb = alloc_skb(arp_hdr_len(dev) + LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
+	skb = alloc_skb(arp_hdr_len(dev) + hlen + tlen, GFP_ATOMIC);
 	if (skb == NULL)
 		return NULL;
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
 	arp = (struct arphdr *) skb_put(skb, arp_hdr_len(dev));
 	skb->dev = dev;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c7472ef..fbc5376 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -304,9 +304,11 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	struct igmpv3_report *pig;
 	struct net *net = dev_net(dev);
 	struct flowi4 fl4;
+	int hlen = LL_RESERVED_SPACE(dev);
+	int tlen = dev->needed_tailroom;
 
 	while (1) {
-		skb = alloc_skb(size + LL_ALLOCATED_SPACE(dev),
+		skb = alloc_skb(size + hlen + tlen,
 				GFP_ATOMIC | __GFP_NOWARN);
 		if (skb)
 			break;
@@ -327,7 +329,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	skb_dst_set(skb, &rt->dst);
 	skb->dev = dev;
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 
 	skb_reset_network_header(skb);
 	pip = ip_hdr(skb);
@@ -647,6 +649,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	__be32	group = pmc ? pmc->multiaddr : 0;
 	struct flowi4 fl4;
 	__be32	dst;
+	int hlen, tlen;
 
 	if (type == IGMPV3_HOST_MEMBERSHIP_REPORT)
 		return igmpv3_send_report(in_dev, pmc);
@@ -661,7 +664,9 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	if (IS_ERR(rt))
 		return -1;
 
-	skb = alloc_skb(IGMP_SIZE+LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
+	hlen = LL_RESERVED_SPACE(dev);
+	tlen = dev->needed_tailroom;
+	skb = alloc_skb(IGMP_SIZE + hlen + tlen, GFP_ATOMIC);
 	if (skb == NULL) {
 		ip_rt_put(rt);
 		return -1;
@@ -669,7 +674,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 
 	skb_dst_set(skb, &rt->dst);
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 0da2afc..adcac64 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -763,13 +763,15 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	struct sk_buff *skb;
 	struct bootp_pkt *b;
 	struct iphdr *h;
+	int hlen = LL_RESERVED_SPACE(dev);
+	int tlen = dev->needed_tailroom;
 
 	/* Allocate packet */
-	skb = alloc_skb(sizeof(struct bootp_pkt) + LL_ALLOCATED_SPACE(dev) + 15,
+	skb = alloc_skb(sizeof(struct bootp_pkt) + hlen + tlen + 15,
 			GFP_KERNEL);
 	if (!skb)
 		return;
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 	b = (struct bootp_pkt *) skb_put(skb, sizeof(struct bootp_pkt));
 	memset(b, 0, sizeof(struct bootp_pkt));
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 007e2eb..e6c1f0e 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -327,6 +327,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	unsigned int iphlen;
 	int err;
 	struct rtable *rt = *rtp;
+	int hlen, tlen;
 
 	if (length > rt->dst.dev->mtu) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -336,12 +337,14 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	if (flags&MSG_PROBE)
 		goto out;
 
+	hlen = LL_RESERVED_SPACE(rt->dst.dev);
+	tlen = rt->dst.dev->needed_tailroom;
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
