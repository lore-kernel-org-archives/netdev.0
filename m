From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 16:06:30 +0200
Message-ID: <1209909990.3753.0.camel@johannes.berg>
References: <1209866916.6210.39.camel@johannes.berg>
	 <20080504021213.GA30660@gondor.apana.org.au>
	 <1209867740.6210.46.camel@johannes.berg>
	 <20080504031652.GA30993@gondor.apana.org.au>
	 <1209890847.6210.51.camel@johannes.berg>
	 <1209892489.6210.56.camel@johannes.berg>
	 <20080504094444.GA541@gondor.apana.org.au>
	 <1209894754.6210.58.camel@johannes.berg>
	 <1209900355.6210.64.camel@johannes.berg>
	 <1209904088.4065.11.camel@johannes.berg>
	 <20080504124542.GA1455@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080504124542.GA1455-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> There are three ways out of this.  You could have your own cache
> (I haven't looked at your headers so I don't know whether that
> makes sense), have no cache at all, or add a new field that gets
> added to hard_header_len for the purposes of calculating head
> room.

I tried the last option, patch below, didn't quite work out yet, but I
got:

[  256.241496] KERNEL: assertion (!atomic_read(&sk->sk_wmem_alloc))
failed at net/packet/af_packet.c (225)

any ideas about that?

johannes

---
 include/linux/netdevice.h  |   10 ++++++++--
 net/core/netpoll.c         |    2 +-
 net/econet/af_econet.c     |    2 +-
 net/ipv4/arp.c             |    2 +-
 net/ipv4/igmp.c            |    4 ++--
 net/ipv4/ip_forward.c      |    4 +++-
 net/ipv4/ipconfig.c        |    6 +++---
 net/ipv4/ipip.c            |    1 +
 net/ipv4/ipmr.c            |    1 +
 net/ipv4/ipvs/ip_vs_xmit.c |    1 +
 net/ipv4/raw.c             |   10 ++++------
 net/ipv6/ip6_output.c      |    3 ++-
 net/ipv6/mcast.c           |    4 ++--
 net/ipv6/ndisc.c           |    4 ++--
 net/ipv6/raw.c             |   10 ++++------
 net/ipv6/sit.c             |    2 ++
 net/packet/af_packet.c     |    2 +-
 net/xfrm/xfrm_output.c     |   11 ++++++-----
 18 files changed, 45 insertions(+), 34 deletions(-)

--- everything.orig/include/linux/netdevice.h	2008-05-04 14:48:47.000000000 +0200
+++ everything/include/linux/netdevice.h	2008-05-04 15:34:04.000000000 +0200
@@ -254,11 +254,16 @@ struct hh_cache
  *
  * We could use other alignment values, but we must maintain the
  * relationship HH alignment <= LL alignment.
+ *
+ * LL_ALLOCATED_SPACE also takes into account the tailroom the device
+ * may need.
  */
 #define LL_RESERVED_SPACE(dev) \
-	(((dev)->hard_header_len&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
+	((((dev)->hard_header_len+(dev)->needed_headroom)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
 #define LL_RESERVED_SPACE_EXTRA(dev,extra) \
-	((((dev)->hard_header_len+extra)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
+	((((dev)->hard_header_len+(dev)->needed_headroom+(extra))&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
+#define LL_ALLOCATED_SPACE(dev) \
+	((((dev)->hard_header_len+(dev)->needed_headroom+(dev)->needed_tailroom)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
 
 struct header_ops {
 	int	(*create) (struct sk_buff *skb, struct net_device *dev,
@@ -576,6 +581,7 @@ struct net_device
 	unsigned		mtu;	/* interface MTU value		*/
 	unsigned short		type;	/* interface hardware type	*/
 	unsigned short		hard_header_len;	/* hardware hdr length	*/
+	unsigned short		needed_headroom, needed_tailroom;
 
 	struct net_device	*master; /* Pointer to master device of a group,
 					  * which this device is member of.
--- everything.orig/net/core/netpoll.c	2008-05-04 14:53:54.000000000 +0200
+++ everything/net/core/netpoll.c	2008-05-04 15:02:53.000000000 +0200
@@ -421,7 +421,7 @@ static void arp_reply(struct sk_buff *sk
 		return;
 
 	size = sizeof(struct arphdr) + 2 * (skb->dev->addr_len + 4);
-	send_skb = find_skb(np, size + LL_RESERVED_SPACE(np->dev),
+	send_skb = find_skb(np, size + LL_ALLOCATED_SPACE(np->dev),
 			    LL_RESERVED_SPACE(np->dev));
 
 	if (!send_skb)
--- everything.orig/net/econet/af_econet.c	2008-05-04 14:53:53.000000000 +0200
+++ everything/net/econet/af_econet.c	2008-05-04 14:56:53.000000000 +0200
@@ -340,7 +340,7 @@ static int econet_sendmsg(struct kiocb *
 
 		dev_hold(dev);
 
-		skb = sock_alloc_send_skb(sk, len+LL_RESERVED_SPACE(dev),
+		skb = sock_alloc_send_skb(sk, len+LL_ALLOCATED_SPACE(dev),
 					  msg->msg_flags & MSG_DONTWAIT, &err);
 		if (skb==NULL)
 			goto out_unlock;
--- everything.orig/net/ipv4/arp.c	2008-05-04 14:53:54.000000000 +0200
+++ everything/net/ipv4/arp.c	2008-05-04 15:04:18.000000000 +0200
@@ -571,7 +571,7 @@ struct sk_buff *arp_create(int type, int
 	 */
 
 	skb = alloc_skb(sizeof(struct arphdr)+ 2*(dev->addr_len+4)
-				+ LL_RESERVED_SPACE(dev), GFP_ATOMIC);
+				+ LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL)
 		return NULL;
 
--- everything.orig/net/ipv4/igmp.c	2008-05-04 14:53:55.000000000 +0200
+++ everything/net/ipv4/igmp.c	2008-05-04 15:06:59.000000000 +0200
@@ -292,7 +292,7 @@ static struct sk_buff *igmpv3_newpack(st
 	struct iphdr *pip;
 	struct igmpv3_report *pig;
 
-	skb = alloc_skb(size + LL_RESERVED_SPACE(dev), GFP_ATOMIC);
+	skb = alloc_skb(size + LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL)
 		return NULL;
 
@@ -653,7 +653,7 @@ static int igmp_send_report(struct in_de
 		return -1;
 	}
 
-	skb=alloc_skb(IGMP_SIZE+LL_RESERVED_SPACE(dev), GFP_ATOMIC);
+	skb=alloc_skb(IGMP_SIZE+LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL) {
 		ip_rt_put(rt);
 		return -1;
--- everything.orig/net/ipv4/ip_forward.c	2008-05-04 14:53:54.000000000 +0200
+++ everything/net/ipv4/ip_forward.c	2008-05-04 15:05:43.000000000 +0200
@@ -93,7 +93,9 @@ int ip_forward(struct sk_buff *skb)
 		goto drop;
 	}
 
-	/* We are about to mangle packet. Copy it! */
+	/* We are about to mangle packet. Copy it!
+	 * FIXME: account for needed tail length?
+	 */
 	if (skb_cow(skb, LL_RESERVED_SPACE(rt->u.dst.dev)+rt->u.dst.header_len))
 		goto drop;
 	iph = ip_hdr(skb);
--- everything.orig/net/ipv4/ipconfig.c	2008-05-04 14:53:54.000000000 +0200
+++ everything/net/ipv4/ipconfig.c	2008-05-04 15:06:16.000000000 +0200
@@ -713,14 +713,14 @@ static void __init ic_bootp_send_if(stru
 	struct net_device *dev = d->dev;
 	struct sk_buff *skb;
 	struct bootp_pkt *b;
-	int hh_len = LL_RESERVED_SPACE(dev);
 	struct iphdr *h;
 
 	/* Allocate packet */
-	skb = alloc_skb(sizeof(struct bootp_pkt) + hh_len + 15, GFP_KERNEL);
+	skb = alloc_skb(sizeof(struct bootp_pkt) +
+			LL_ALLOCATED_SPACE(dev) + 15, GFP_KERNEL);
 	if (!skb)
 		return;
-	skb_reserve(skb, hh_len);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	b = (struct bootp_pkt *) skb_put(skb, sizeof(struct bootp_pkt));
 	memset(b, 0, sizeof(struct bootp_pkt));
 
--- everything.orig/net/ipv4/ipip.c	2008-05-04 14:53:55.000000000 +0200
+++ everything/net/ipv4/ipip.c	2008-05-04 15:07:10.000000000 +0200
@@ -587,6 +587,7 @@ static int ipip_tunnel_xmit(struct sk_bu
 
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
+	 * FIXME: tail room?
 	 */
 	max_headroom = (LL_RESERVED_SPACE(tdev)+sizeof(struct iphdr));
 
--- everything.orig/net/ipv4/ipmr.c	2008-05-04 14:53:54.000000000 +0200
+++ everything/net/ipv4/ipmr.c	2008-05-04 15:06:32.000000000 +0200
@@ -1211,6 +1211,7 @@ static void ipmr_queue_xmit(struct sk_bu
 		goto out_free;
 	}
 
+	/* FIXME: what about needed tailroom? */
 	encap += LL_RESERVED_SPACE(dev) + rt->u.dst.header_len;
 
 	if (skb_cow(skb, encap)) {
--- everything.orig/net/ipv4/ipvs/ip_vs_xmit.c	2008-05-04 14:53:54.000000000 +0200
+++ everything/net/ipv4/ipvs/ip_vs_xmit.c	2008-05-04 15:04:34.000000000 +0200
@@ -363,6 +363,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
 
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
+	 * FIXME: account for needed tailroom?
 	 */
 	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct iphdr);
 
--- everything.orig/net/ipv4/raw.c	2008-05-04 14:53:54.000000000 +0200
+++ everything/net/ipv4/raw.c	2008-05-04 15:30:46.000000000 +0200
@@ -329,7 +329,6 @@ static int raw_send_hdrinc(struct sock *
 			unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	int hh_len;
 	struct iphdr *iph;
 	struct sk_buff *skb;
 	unsigned int iphlen;
@@ -343,13 +342,12 @@ static int raw_send_hdrinc(struct sock *
 	if (flags&MSG_PROBE)
 		goto out;
 
-	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
-
-	skb = sock_alloc_send_skb(sk, length+hh_len+15,
-				  flags&MSG_DONTWAIT, &err);
+	skb = sock_alloc_send_skb(
+		sk, length + LL_ALLOCATED_SPACE(rt->u.dst.dev) + 15,
+		flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto error;
-	skb_reserve(skb, hh_len);
+	skb_reserve(skb, LL_RESERVED_SPACE(rt->u.dst.dev));
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
--- everything.orig/net/ipv6/ip6_output.c	2008-05-04 14:53:53.000000000 +0200
+++ everything/net/ipv6/ip6_output.c	2008-05-04 15:02:05.000000000 +0200
@@ -201,6 +201,7 @@ int ip6_xmit(struct sock *sk, struct sk_
 
 		/* First: exthdrs may take lots of space (~8K for now)
 		   MAX_HEADER is not enough.
+		   FIXME: LL_ALLOCATED_SPACE?
 		 */
 		head_room = opt->opt_nflen + opt->opt_flen;
 		seg_len += head_room;
@@ -780,7 +781,7 @@ slow_path:
 		 *	Allocate buffer.
 		 */
 
-		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_RESERVED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
+		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_ALLOCATED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
 			NETDEBUG(KERN_INFO "IPv6: frag: no memory for new fragment!\n");
 			IP6_INC_STATS(ip6_dst_idev(skb->dst),
 				      IPSTATS_MIB_FRAGFAILS);
--- everything.orig/net/ipv6/mcast.c	2008-05-04 14:53:53.000000000 +0200
+++ everything/net/ipv6/mcast.c	2008-05-04 15:01:21.000000000 +0200
@@ -1403,7 +1403,7 @@ static struct sk_buff *mld_newpack(struc
 		     IPV6_TLV_PADN, 0 };
 
 	/* we assume size > sizeof(ra) here */
-	skb = sock_alloc_send_skb(sk, size + LL_RESERVED_SPACE(dev), 1, &err);
+	skb = sock_alloc_send_skb(sk, size + LL_ALLOCATED_SPACE(dev), 1, &err);
 
 	if (!skb)
 		return NULL;
@@ -1776,7 +1776,7 @@ static void igmp6_send(struct in6_addr *
 	payload_len = len + sizeof(ra);
 	full_len = sizeof(struct ipv6hdr) + payload_len;
 
-	skb = sock_alloc_send_skb(sk, LL_RESERVED_SPACE(dev) + full_len, 1, &err);
+	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + full_len, 1, &err);
 
 	if (skb == NULL) {
 		rcu_read_lock();
--- everything.orig/net/ipv6/ndisc.c	2008-05-04 14:53:53.000000000 +0200
+++ everything/net/ipv6/ndisc.c	2008-05-04 15:01:37.000000000 +0200
@@ -494,7 +494,7 @@ static void __ndisc_send(struct net_devi
 
 	skb = sock_alloc_send_skb(sk,
 				  (MAX_HEADER + sizeof(struct ipv6hdr) +
-				   len + LL_RESERVED_SPACE(dev)),
+				   len + LL_ALLOCATED_SPACE(dev)),
 				  1, &err);
 	if (!skb) {
 		ND_PRINTK0(KERN_ERR
@@ -1494,7 +1494,7 @@ void ndisc_send_redirect(struct sk_buff 
 
 	buff = sock_alloc_send_skb(sk,
 				   (MAX_HEADER + sizeof(struct ipv6hdr) +
-				    len + LL_RESERVED_SPACE(dev)),
+				    len + LL_ALLOCATED_SPACE(dev)),
 				   1, &err);
 	if (buff == NULL) {
 		ND_PRINTK0(KERN_ERR
--- everything.orig/net/ipv6/raw.c	2008-05-04 14:53:53.000000000 +0200
+++ everything/net/ipv6/raw.c	2008-05-04 14:57:58.000000000 +0200
@@ -624,7 +624,6 @@ static int rawv6_send_hdrinc(struct sock
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
-	unsigned int hh_len;
 	int err;
 
 	if (length > rt->u.dst.dev->mtu) {
@@ -634,13 +633,12 @@ static int rawv6_send_hdrinc(struct sock
 	if (flags&MSG_PROBE)
 		goto out;
 
-	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
-
-	skb = sock_alloc_send_skb(sk, length+hh_len+15,
-				  flags&MSG_DONTWAIT, &err);
+	skb = sock_alloc_send_skb(
+		sk, length + LL_ALLOCATED_SPACE(rt->u.dst.dev) + 15,
+		flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto error;
-	skb_reserve(skb, hh_len);
+	skb_reserve(skb, LL_RESERVED_SPACE(rt->u.dst.dev));
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
--- everything.orig/net/ipv6/sit.c	2008-05-04 14:53:53.000000000 +0200
+++ everything/net/ipv6/sit.c	2008-05-04 15:00:55.000000000 +0200
@@ -603,6 +603,8 @@ static int ipip6_tunnel_xmit(struct sk_b
 
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
+	 *
+	 * XXX: tailroom? LL_ALLOCATED_SPACE?
 	 */
 	max_headroom = LL_RESERVED_SPACE(tdev)+sizeof(struct iphdr);
 
--- everything.orig/net/packet/af_packet.c	2008-05-04 14:53:53.000000000 +0200
+++ everything/net/packet/af_packet.c	2008-05-04 15:02:33.000000000 +0200
@@ -743,7 +743,7 @@ static int packet_sendmsg(struct kiocb *
 	if (len > dev->mtu+reserve)
 		goto out_unlock;
 
-	skb = sock_alloc_send_skb(sk, len + LL_RESERVED_SPACE(dev),
+	skb = sock_alloc_send_skb(sk, len + LL_ALLOCATED_SPACE(dev),
 				msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb==NULL)
 		goto out_unlock;
--- everything.orig/net/xfrm/xfrm_output.c	2008-05-04 14:53:52.000000000 +0200
+++ everything/net/xfrm/xfrm_output.c	2008-05-04 15:46:11.000000000 +0200
@@ -23,13 +23,14 @@ static int xfrm_output2(struct sk_buff *
 static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
-	int nhead = dst->header_len + LL_RESERVED_SPACE(dst->dev)
-		- skb_headroom(skb);
+	int nhead = max_t(int, 0, dst->header_len + LL_RESERVED_SPACE(dst->dev)
+				  - skb_headroom(skb));
+	int ntail = max_t(int, 0, dst->dev->needed_tailroom
+				  - skb_tailroom(skb));
 
-	if (nhead > 0)
-		return pskb_expand_head(skb, nhead, 0, GFP_ATOMIC);
+	if (nhead || ntail)
+		return pskb_expand_head(skb, nhead, ntail, GFP_ATOMIC);
 
-	/* Check tail too... */
 	return 0;
 }
 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
