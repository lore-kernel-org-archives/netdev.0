From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC] allow netdevices to specify needed head/tailroom
Date: Mon, 12 May 2008 20:50:32 -0700 (PDT)
Message-ID: <20080512.205032.14370318.davem@davemloft.net>
References: <1209992486.8245.14.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209992486.8245.14.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Mon, 05 May 2008 15:01:26 +0200

> Forgot again to post this this morning, sorry.

No worries.

I made some minor cleanups and removed the comment "FIXME" blobs
you added the for skb_cow()/skb_realloc_headroom() code paths.

I promise we'll investigate and inspect those :-)

Here is the final patch I applied.

net: Allow netdevices to specify needed head/tailroom

This patch adds needed_headroom/needed_tailroom members to struct
net_device and updates many places that allocate sbks to use them. Not
all of them can be converted though, and I'm sure I missed some (I
mostly grepped for LL_RESERVED_SPACE)

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/linux/netdevice.h |   16 ++++++++++++++--
 net/core/netpoll.c        |    2 +-
 net/econet/af_econet.c    |    2 +-
 net/ipv4/arp.c            |    2 +-
 net/ipv4/igmp.c           |    4 ++--
 net/ipv4/ipconfig.c       |    6 +++---
 net/ipv4/raw.c            |   10 ++++------
 net/ipv6/ip6_output.c     |    2 +-
 net/ipv6/mcast.c          |    4 ++--
 net/ipv6/ndisc.c          |    4 ++--
 net/ipv6/raw.c            |   10 ++++------
 net/packet/af_packet.c    |    2 +-
 net/xfrm/xfrm_output.c    |    6 +++---
 13 files changed, 39 insertions(+), 31 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fb57f..b11e6e1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -246,11 +246,16 @@ struct hh_cache
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
@@ -569,6 +574,13 @@ struct net_device
 	unsigned short		type;	/* interface hardware type	*/
 	unsigned short		hard_header_len;	/* hardware hdr length	*/
 
+	/* extra head- and tailroom the hardware may need, but not in all cases
+	 * can this be guaranteed, especially tailroom. Some cases also use
+	 * LL_MAX_HEADER instead to allocate the skb.
+	 */
+	unsigned short		needed_headroom;
+	unsigned short		needed_tailroom;
+
 	struct net_device	*master; /* Pointer to master device of a group,
 					  * which this device is member of.
 					  */
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index b04d643..8fb134d 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -419,7 +419,7 @@ static void arp_reply(struct sk_buff *skb)
 		return;
 
 	size = arp_hdr_len(skb->dev);
-	send_skb = find_skb(np, size + LL_RESERVED_SPACE(np->dev),
+	send_skb = find_skb(np, size + LL_ALLOCATED_SPACE(np->dev),
 			    LL_RESERVED_SPACE(np->dev));
 
 	if (!send_skb)
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 68d1544..7c9bb13 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -340,7 +340,7 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 		dev_hold(dev);
 
-		skb = sock_alloc_send_skb(sk, len+LL_RESERVED_SPACE(dev),
+		skb = sock_alloc_send_skb(sk, len+LL_ALLOCATED_SPACE(dev),
 					  msg->msg_flags & MSG_DONTWAIT, &err);
 		if (skb==NULL)
 			goto out_unlock;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 68b72a7..418862f 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -570,7 +570,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	 *	Allocate a buffer
 	 */
 
-	skb = alloc_skb(arp_hdr_len(dev) + LL_RESERVED_SPACE(dev), GFP_ATOMIC);
+	skb = alloc_skb(arp_hdr_len(dev) + LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL)
 		return NULL;
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 6250f42..2769dc4 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -292,7 +292,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	struct iphdr *pip;
 	struct igmpv3_report *pig;
 
-	skb = alloc_skb(size + LL_RESERVED_SPACE(dev), GFP_ATOMIC);
+	skb = alloc_skb(size + LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL)
 		return NULL;
 
@@ -653,7 +653,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 		return -1;
 	}
 
-	skb=alloc_skb(IGMP_SIZE+LL_RESERVED_SPACE(dev), GFP_ATOMIC);
+	skb=alloc_skb(IGMP_SIZE+LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL) {
 		ip_rt_put(rt);
 		return -1;
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 89dee43..ed45037 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -710,14 +710,14 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	struct net_device *dev = d->dev;
 	struct sk_buff *skb;
 	struct bootp_pkt *b;
-	int hh_len = LL_RESERVED_SPACE(dev);
 	struct iphdr *h;
 
 	/* Allocate packet */
-	skb = alloc_skb(sizeof(struct bootp_pkt) + hh_len + 15, GFP_KERNEL);
+	skb = alloc_skb(sizeof(struct bootp_pkt) + LL_ALLOCATED_SPACE(dev) + 15,
+			GFP_KERNEL);
 	if (!skb)
 		return;
-	skb_reserve(skb, hh_len);
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	b = (struct bootp_pkt *) skb_put(skb, sizeof(struct bootp_pkt));
 	memset(b, 0, sizeof(struct bootp_pkt));
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 11d7f75..fead049 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -322,7 +322,6 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 			unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	int hh_len;
 	struct iphdr *iph;
 	struct sk_buff *skb;
 	unsigned int iphlen;
@@ -336,13 +335,12 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	if (flags&MSG_PROBE)
 		goto out;
 
-	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
-
-	skb = sock_alloc_send_skb(sk, length+hh_len+15,
-				  flags&MSG_DONTWAIT, &err);
+	skb = sock_alloc_send_skb(sk,
+				  length + LL_ALLOCATED_SPACE(rt->u.dst.dev) + 15,
+				  flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto error;
-	skb_reserve(skb, hh_len);
+	skb_reserve(skb, LL_RESERVED_SPACE(rt->u.dst.dev));
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 0af2e05..48cdce9 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -780,7 +780,7 @@ slow_path:
 		 *	Allocate buffer.
 		 */
 
-		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_RESERVED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
+		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_ALLOCATED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
 			NETDEBUG(KERN_INFO "IPv6: frag: no memory for new fragment!\n");
 			IP6_INC_STATS(ip6_dst_idev(skb->dst),
 				      IPSTATS_MIB_FRAGFAILS);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 54f91ef..fd632dd 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1411,7 +1411,7 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 		     IPV6_TLV_PADN, 0 };
 
 	/* we assume size > sizeof(ra) here */
-	skb = sock_alloc_send_skb(sk, size + LL_RESERVED_SPACE(dev), 1, &err);
+	skb = sock_alloc_send_skb(sk, size + LL_ALLOCATED_SPACE(dev), 1, &err);
 
 	if (!skb)
 		return NULL;
@@ -1790,7 +1790,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	payload_len = len + sizeof(ra);
 	full_len = sizeof(struct ipv6hdr) + payload_len;
 
-	skb = sock_alloc_send_skb(sk, LL_RESERVED_SPACE(dev) + full_len, 1, &err);
+	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + full_len, 1, &err);
 
 	if (skb == NULL) {
 		rcu_read_lock();
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2c74885..a55fc05 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -479,7 +479,7 @@ static void __ndisc_send(struct net_device *dev,
 
 	skb = sock_alloc_send_skb(sk,
 				  (MAX_HEADER + sizeof(struct ipv6hdr) +
-				   len + LL_RESERVED_SPACE(dev)),
+				   len + LL_ALLOCATED_SPACE(dev)),
 				  1, &err);
 	if (!skb) {
 		ND_PRINTK0(KERN_ERR
@@ -1521,7 +1521,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 
 	buff = sock_alloc_send_skb(sk,
 				   (MAX_HEADER + sizeof(struct ipv6hdr) +
-				    len + LL_RESERVED_SPACE(dev)),
+				    len + LL_ALLOCATED_SPACE(dev)),
 				   1, &err);
 	if (buff == NULL) {
 		ND_PRINTK0(KERN_ERR
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 396f0ea..232e0dc 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -609,7 +609,6 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
-	unsigned int hh_len;
 	int err;
 
 	if (length > rt->u.dst.dev->mtu) {
@@ -619,13 +618,12 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	if (flags&MSG_PROBE)
 		goto out;
 
-	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
-
-	skb = sock_alloc_send_skb(sk, length+hh_len+15,
-				  flags&MSG_DONTWAIT, &err);
+	skb = sock_alloc_send_skb(sk,
+				  length + LL_ALLOCATED_SPACE(rt->u.dst.dev) + 15,
+				  flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto error;
-	skb_reserve(skb, hh_len);
+	skb_reserve(skb, LL_RESERVED_SPACE(rt->u.dst.dev));
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2507024..2cee87d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -743,7 +743,7 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (len > dev->mtu+reserve)
 		goto out_unlock;
 
-	skb = sock_alloc_send_skb(sk, len + LL_RESERVED_SPACE(dev),
+	skb = sock_alloc_send_skb(sk, len + LL_ALLOCATED_SPACE(dev),
 				msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb==NULL)
 		goto out_unlock;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 09cd9c0..3f964db 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -25,11 +25,11 @@ static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 	struct dst_entry *dst = skb->dst;
 	int nhead = dst->header_len + LL_RESERVED_SPACE(dst->dev)
 		- skb_headroom(skb);
+	int ntail = dst->dev->needed_tailroom - skb_tailroom(skb);
 
-	if (nhead > 0)
-		return pskb_expand_head(skb, nhead, 0, GFP_ATOMIC);
+	if (nhead > 0 || ntail > 0)
+		return pskb_expand_head(skb, nhead, ntail, GFP_ATOMIC);
 
-	/* Check tail too... */
 	return 0;
 }
 
-- 
1.5.5.1.57.g5909c

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
