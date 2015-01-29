From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 5/6] ip_tunnel: Extend tunnel_info for STT.
Date: Thu, 29 Jan 2015 15:29:44 -0800
Message-ID: <1422574184-1976-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:60025 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752664AbbA2X3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:29:47 -0500
Received: by mail-pa0-f54.google.com with SMTP id eu11so44381427pac.13
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 15:29:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Next patch introduces stt kernel device. I am planning on using
generic ip_tunnel layer for setting up control plane. But
STT has 64-bit key and it has TCP port. Following patch enhances
ip_tunnel layer so that it can be used by STT.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ip_tunnels.h | 33 +++++++++++++++++++++++-----
 net/ipv4/gre_demux.c     |  4 ++--
 net/ipv4/ip_gre.c        | 14 ++++++------
 net/ipv4/ip_tunnel.c     | 56 +++++++++++++++++++++++++++++++-----------------
 net/ipv4/ip_vti.c        |  4 ++--
 net/ipv4/ipip.c          |  4 ++--
 6 files changed, 77 insertions(+), 38 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index b46b05d..0816d49 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -52,11 +52,12 @@ struct ip_tunnel_dst {
 };
 
 struct tunnel_info {
-	__be32		i_key;
-	__be32		o_key;
+	__be64		i_key;
+	__be64		o_key;
 	__be32		saddr;
 	__be32		daddr;
 	int		link;
+	__be16		portno;
 	__be16		i_flags;
 	__be16		o_flags;
 	__be16		df;
@@ -117,10 +118,10 @@ struct ip_tunnel {
 #define TUNNEL_OPTIONS_PRESENT	(TUNNEL_GENEVE_OPT | TUNNEL_VXLAN_OPT)
 
 struct tnl_ptk_info {
+	__be64 key;
+	__be32 seq;
 	__be16 flags;
 	__be16 proto;
-	__be32 key;
-	__be32 seq;
 };
 
 #define PACKET_RCVD	0
@@ -174,7 +175,7 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 				   int link, __be16 flags,
 				   __be32 remote, __be32 local,
-				   __be32 key);
+				   __be16 portno, __be64 key);
 
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		  const struct tnl_ptk_info *tpi, bool log_ecn_error);
@@ -240,6 +241,28 @@ static inline void iptunnel_xmit_stats(int err,
 	}
 }
 
+void tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst, __be32 saddr);
+struct rtable *tunnel_rtable_get(struct ip_tunnel *t,
+				 u32 cookie, __be32 *saddr);
+
+static inline __be64 tunnel_id32_to_key(__be32 key)
+{
+#ifdef __BIG_ENDIAN
+	return (__force __be64)(key);
+#else
+	return (__force __be64)((__force u64)key << 32);
+#endif
+}
+
+static inline __be32 key_to_tunnel_id32(__be64 x)
+{
+#ifdef __BIG_ENDIAN
+	return (__force __be32)x;
+#else
+	return (__force __be32)((__force u64)x >> 32);
+#endif
+}
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 4a7b5b2..5097581 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -81,7 +81,7 @@ void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 			ptr--;
 		}
 		if (tpi->flags&TUNNEL_KEY) {
-			*ptr = tpi->key;
+			*ptr = key_to_tunnel_id32(tpi->key);
 			ptr--;
 		}
 		if (tpi->flags&TUNNEL_CSUM &&
@@ -132,7 +132,7 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	}
 
 	if (greh->flags & GRE_KEY) {
-		tpi->key = *options;
+		tpi->key = tunnel_id32_to_key(*options);
 		options++;
 	} else
 		tpi->key = 0;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fa9ee75..93bbff1 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -180,7 +180,7 @@ static int ipgre_err(struct sk_buff *skb, u32 info,
 
 	iph = (const struct iphdr *)(icmp_hdr(skb) + 1);
 	t = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
-			     iph->daddr, iph->saddr, tpi->key);
+			     iph->daddr, iph->saddr, 0, tpi->key);
 
 	if (t == NULL)
 		return PACKET_REJECT;
@@ -214,7 +214,7 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 
 	iph = ip_hdr(skb);
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
-				  iph->saddr, iph->daddr, tpi->key);
+				  iph->saddr, iph->daddr, 0, tpi->key);
 
 	if (tunnel) {
 		skb_pop_mac_header(skb);
@@ -452,7 +452,7 @@ static int ipgre_open(struct net_device *dev)
 		rt = ip_route_output_gre(t->net, &fl4,
 					 t->info.daddr,
 					 t->info.saddr,
-					 t->info.o_key,
+					 key_to_tunnel_id32(t->info.o_key),
 					 RT_TOS(t->info.tos),
 					 t->info.link);
 		if (IS_ERR(rt))
@@ -650,10 +650,10 @@ static void ipgre_netlink_info(struct nlattr *data[], struct nlattr *tb[],
 		info->o_flags = gre_flags_to_tnl_flags(nla_get_be16(data[IFLA_GRE_OFLAGS]));
 
 	if (data[IFLA_GRE_IKEY])
-		info->i_key = nla_get_be32(data[IFLA_GRE_IKEY]);
+		info->i_key = tunnel_id32_to_key(nla_get_be32(data[IFLA_GRE_IKEY]));
 
 	if (data[IFLA_GRE_OKEY])
-		info->o_key = nla_get_be32(data[IFLA_GRE_OKEY]);
+		info->o_key = tunnel_id32_to_key(nla_get_be32(data[IFLA_GRE_OKEY]));
 
 	if (data[IFLA_GRE_LOCAL])
 		info->saddr = nla_get_be32(data[IFLA_GRE_LOCAL]);
@@ -809,8 +809,8 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put_u32(skb, IFLA_GRE_LINK, info->link) ||
 	    nla_put_be16(skb, IFLA_GRE_IFLAGS, tnl_flags_to_gre_flags(info->i_flags)) ||
 	    nla_put_be16(skb, IFLA_GRE_OFLAGS, tnl_flags_to_gre_flags(info->o_flags)) ||
-	    nla_put_be32(skb, IFLA_GRE_IKEY, info->i_key) ||
-	    nla_put_be32(skb, IFLA_GRE_OKEY, info->o_key) ||
+	    nla_put_be32(skb, IFLA_GRE_IKEY, key_to_tunnel_id32(info->i_key)) ||
+	    nla_put_be32(skb, IFLA_GRE_OKEY, key_to_tunnel_id32(info->o_key)) ||
 	    nla_put_be32(skb, IFLA_GRE_LOCAL, info->saddr) ||
 	    nla_put_be32(skb, IFLA_GRE_REMOTE, info->daddr) ||
 	    nla_put_u8(skb, IFLA_GRE_TTL, info->ttl) ||
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index fc078ae..00177db 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -72,8 +72,8 @@ void tunnel_info_to_parm(char dev_name[], struct tunnel_info *info,
 	p->link = info->link;
 	p->i_flags = info->i_flags;
 	p->o_flags = info->o_flags;
-	p->i_key = info->i_key;
-	p->o_key = info->o_key;
+	p->i_key = key_to_tunnel_id32(info->i_key);
+	p->o_key = key_to_tunnel_id32(info->o_key);
 
 	p->iph.version = 4;
 	p->iph.ihl = 5;
@@ -94,8 +94,8 @@ void ip_tunnel_parm_to_info(struct ip_tunnel_parm *p,
 	info->link = p->link;
 	info->i_flags = p->i_flags;
 	info->o_flags = p->o_flags;
-	info->i_key = p->i_key;
-	info->o_key = p->o_key;
+	info->i_key = tunnel_id32_to_key(p->i_key);
+	info->o_key = tunnel_id32_to_key(p->o_key);
 
 	info->tos = p->iph.tos;
 	info->df = p->iph.frag_off;
@@ -106,10 +106,13 @@ void ip_tunnel_parm_to_info(struct ip_tunnel_parm *p,
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_parm_to_info);
 
-static unsigned int ip_tunnel_hash(__be32 key, __be32 remote)
+static unsigned int ip_tunnel_hash(__be64 key, __be32 remote, __be16 portno)
 {
-	return hash_32((__force u32)key ^ (__force u32)remote,
-			 IP_TNL_HASH_BITS);
+	u32 initval;
+
+	initval = (__force u32) hash_64((__force u64)key, 32);
+	return jhash_2words((__force u32)remote, (__force u32)portno,
+			    initval) & (IP_TNL_HASH_SIZE - 1);
 }
 
 static void __tunnel_dst_set(struct ip_tunnel_dst *idst,
@@ -123,11 +126,11 @@ static void __tunnel_dst_set(struct ip_tunnel_dst *idst,
 	idst->saddr = saddr;
 }
 
-static noinline void tunnel_dst_set(struct ip_tunnel *t,
-			   struct dst_entry *dst, __be32 saddr)
+void tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst, __be32 saddr)
 {
 	__tunnel_dst_set(raw_cpu_ptr(t->dst_cache), dst, saddr);
 }
+EXPORT_SYMBOL_GPL(tunnel_dst_set);
 
 static void tunnel_dst_reset(struct ip_tunnel *t)
 {
@@ -143,8 +146,8 @@ void ip_tunnel_dst_reset_all(struct ip_tunnel *t)
 }
 EXPORT_SYMBOL(ip_tunnel_dst_reset_all);
 
-static struct rtable *tunnel_rtable_get(struct ip_tunnel *t,
-					u32 cookie, __be32 *saddr)
+struct rtable *tunnel_rtable_get(struct ip_tunnel *t,
+				 u32 cookie, __be32 *saddr)
 {
 	struct ip_tunnel_dst *idst;
 	struct dst_entry *dst;
@@ -166,9 +169,10 @@ static struct rtable *tunnel_rtable_get(struct ip_tunnel *t,
 	rcu_read_unlock();
 	return (struct rtable *)dst;
 }
+EXPORT_SYMBOL_GPL(tunnel_rtable_get);
 
 static bool ip_tunnel_key_match(const struct tunnel_info *t,
-				__be16 flags, __be32 key)
+				__be16 flags, __be64 key)
 {
 	if (t->i_flags & TUNNEL_KEY) {
 		if (flags & TUNNEL_KEY)
@@ -194,13 +198,13 @@ static bool ip_tunnel_key_match(const struct tunnel_info *t,
 struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 				   int link, __be16 flags,
 				   __be32 remote, __be32 local,
-				   __be32 key)
+				   __be16 portno, __be64 key)
 {
 	unsigned int hash;
 	struct ip_tunnel *t, *cand = NULL;
 	struct hlist_head *head;
 
-	hash = ip_tunnel_hash(key, remote);
+	hash = ip_tunnel_hash(key, remote, portno);
 	head = &itn->tunnels[hash];
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
@@ -212,6 +216,9 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 		if (!ip_tunnel_key_match(&t->info, flags, key))
 			continue;
 
+		if (portno != t->info.portno)
+			continue;
+
 		if (t->info.link == link)
 			return t;
 		else
@@ -227,13 +234,16 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 		if (!ip_tunnel_key_match(&t->info, flags, key))
 			continue;
 
+		if (portno != t->info.portno)
+			continue;
+
 		if (t->info.link == link)
 			return t;
 		else if (!cand)
 			cand = t;
 	}
 
-	hash = ip_tunnel_hash(key, 0);
+	hash = ip_tunnel_hash(key, 0, portno);
 	head = &itn->tunnels[hash];
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
@@ -247,6 +257,9 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 		if (!ip_tunnel_key_match(&t->info, flags, key))
 			continue;
 
+		if (portno != t->info.portno)
+			continue;
+
 		if (t->info.link == link)
 			return t;
 		else if (!cand)
@@ -260,6 +273,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 		if (t->info.i_key != key ||
 		    t->info.saddr != 0 ||
 		    t->info.daddr != 0 ||
+		    t->info.portno != portno ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
 
@@ -286,7 +300,7 @@ static struct hlist_head *ip_bucket(struct ip_tunnel_net *itn,
 {
 	unsigned int h;
 	__be32 remote;
-	__be32 i_key = info->i_key;
+	__be64 i_key = info->i_key;
 
 	if (info->daddr && !ipv4_is_multicast(info->daddr))
 		remote = info->daddr;
@@ -296,7 +310,7 @@ static struct hlist_head *ip_bucket(struct ip_tunnel_net *itn,
 	if (!(info->i_flags & TUNNEL_KEY) && (info->i_flags & VTI_ISVTI))
 		i_key = 0;
 
-	h = ip_tunnel_hash(i_key, remote);
+	h = ip_tunnel_hash(i_key, remote, info->portno);
 	return &itn->tunnels[h];
 }
 
@@ -318,8 +332,9 @@ static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
 {
 	__be32 remote = info->daddr;
 	__be32 local = info->saddr;
-	__be32 key = info->i_key;
+	__be64 key = info->i_key;
 	__be16 flags = info->i_flags;
+	__be16 portno = info->portno;
 	int link = info->link;
 	struct ip_tunnel *t = NULL;
 	struct hlist_head *head = ip_bucket(itn, info);
@@ -329,6 +344,7 @@ static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
 		    remote == t->info.daddr &&
 		    link == t->info.link &&
 		    type == t->dev->type &&
+		    portno == t->info.portno &&
 		    ip_tunnel_key_match(&t->info, flags, key))
 			break;
 	}
@@ -385,7 +401,7 @@ failed:
 static inline void init_tunnel_flow(struct flowi4 *fl4,
 				    int proto,
 				    __be32 daddr, __be32 saddr,
-				    __be32 key, __u8 tos, int oif)
+				    __be64 key, __u8 tos, int oif)
 {
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->flowi4_oif = oif;
@@ -393,7 +409,7 @@ static inline void init_tunnel_flow(struct flowi4 *fl4,
 	fl4->saddr = saddr;
 	fl4->flowi4_tos = tos;
 	fl4->flowi4_proto = proto;
-	fl4->fl4_gre_key = key;
+	fl4->fl4_gre_key = key_to_tunnel_id32(key);
 }
 
 static int ip_tunnel_bind_dev(struct net_device *dev)
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index f25222d..43eafa2 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -59,7 +59,7 @@ static int vti_input(struct sk_buff *skb, int nexthdr, __be32 spi,
 	struct ip_tunnel_net *itn = net_generic(net, vti_net_id);
 
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
-				  iph->saddr, iph->daddr, 0);
+				  iph->saddr, iph->daddr, 0, 0);
 	if (tunnel != NULL) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
@@ -251,7 +251,7 @@ static int vti4_err(struct sk_buff *skb, u32 info)
 	struct ip_tunnel_net *itn = net_generic(net, vti_net_id);
 
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
-				  iph->daddr, iph->saddr, 0);
+				  iph->daddr, iph->saddr, 0, 0);
 	if (!tunnel)
 		return -1;
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index b14b33d..a047e20 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -143,7 +143,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 
 	err = -ENOENT;
 	t = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
-			     iph->daddr, iph->saddr, 0);
+			     iph->daddr, iph->saddr, 0, 0);
 	if (t == NULL)
 		goto out;
 
@@ -192,7 +192,7 @@ static int ipip_rcv(struct sk_buff *skb)
 
 	iph = ip_hdr(skb);
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
-			iph->saddr, iph->daddr, 0);
+				  iph->saddr, iph->daddr, 0, 0);
 	if (tunnel) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
-- 
1.9.1
