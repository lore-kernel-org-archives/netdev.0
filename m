From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL 2.6.20] IPv6 Updates
Date: Fri, 10 Nov 2006 17:15:14 -0800 (PST)
Message-ID: <20061110.171514.79983384.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:516 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1424479AbWKKBPS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 20:15:18 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Please consider pulling following changesets from
"2.6.19-rc5-net-2.6.20-20061110-to-davem" branch at:
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git

Regards,

HEADLINES
---------

    [IPV6] ROUTE: Use macros to format /proc/net/ipv6_route.
    [IPV6] ROUTE: Use &rt->u.dst instead of cast.
    [IPV6]: Introduce ip6_dst_idev() to get inet6_dev{} stored in dst_entry{}.
    [IPV6]: Per-interface statistics support.

DIFFSTAT
--------

 include/net/if_inet6.h |    1 +
 include/net/ip6_fib.h  |    5 +++
 include/net/ipv6.h     |   21 ++++++++++++--
 net/ipv6/addrconf.c    |    2 +
 net/ipv6/exthdrs.c     |   57 ++++++++++++++++++++++++++-------------
 net/ipv6/fib6_rules.c  |    2 +
 net/ipv6/icmp.c        |    3 +-
 net/ipv6/ip6_input.c   |   42 +++++++++++++++++++---------
 net/ipv6/ip6_output.c  |   71 ++++++++++++++++++++++++++++--------------------
 net/ipv6/mcast.c       |   20 +++++++++-----
 net/ipv6/ndisc.c       |    8 +++--
 net/ipv6/netfilter.c   |    2 +
 net/ipv6/proc.c        |    7 +++++
 net/ipv6/raw.c         |    4 +--
 net/ipv6/reassembly.c  |   65 ++++++++++++++++++++++++++------------------
 net/ipv6/route.c       |   47 ++++++++++++--------------------
 16 files changed, 219 insertions(+), 138 deletions(-)

CHANGESETS
----------

commit 465b80b2a10ac1fb395f73d41c7578a12ed70267
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Oct 14 02:00:56 2006 +0900

    [IPV6] ROUTE: Use macros to format /proc/net/ipv6_route.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cb31d00..92c948c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2245,7 +2245,6 @@ struct rt6_proc_arg
 static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_proc_arg *arg = (struct rt6_proc_arg *) p_arg;
-	int i;
 
 	if (arg->skip < arg->offset / RT6_INFO_LEN) {
 		arg->skip++;
@@ -2255,38 +2254,28 @@ static int rt6_info_route(struct rt6_inf
 	if (arg->len >= arg->length)
 		return 0;
 
-	for (i=0; i<16; i++) {
-		sprintf(arg->buffer + arg->len, "%02x",
-			rt->rt6i_dst.addr.s6_addr[i]);
-		arg->len += 2;
-	}
-	arg->len += sprintf(arg->buffer + arg->len, " %02x ",
+	arg->len += sprintf(arg->buffer + arg->len,
+			    NIP6_SEQFMT " %02x ",
+			    NIP6(rt->rt6i_dst.addr),
 			    rt->rt6i_dst.plen);
 
 #ifdef CONFIG_IPV6_SUBTREES
-	for (i=0; i<16; i++) {
-		sprintf(arg->buffer + arg->len, "%02x",
-			rt->rt6i_src.addr.s6_addr[i]);
-		arg->len += 2;
-	}
-	arg->len += sprintf(arg->buffer + arg->len, " %02x ",
+	arg->len += sprintf(arg->buffer + arg->len,
+			    NIP6_SEQFMT " %02x ",
+			    NIP6(rt->rt6i_src.addr),
 			    rt->rt6i_src.plen);
 #else
-	sprintf(arg->buffer + arg->len,
-		"00000000000000000000000000000000 00 ");
-	arg->len += 36;
+	arg->len += sprintf(arg->buffer + arg->len,
+			    "00000000000000000000000000000000 00 ");
 #endif
 
 	if (rt->rt6i_nexthop) {
-		for (i=0; i<16; i++) {
-			sprintf(arg->buffer + arg->len, "%02x",
-				rt->rt6i_nexthop->primary_key[i]);
-			arg->len += 2;
-		}
+		arg->len += sprintf(arg->buffer + arg->len,
+				    NIP6_SEQFMT,
+				    NIP6(*((struct in6_addr *)rt->rt6i_nexthop->primary_key)));
 	} else {
-		sprintf(arg->buffer + arg->len,
-			"00000000000000000000000000000000");
-		arg->len += 32;
+		arg->len += sprintf(arg->buffer + arg->len,
+				    "00000000000000000000000000000000");
 	}
 	arg->len += sprintf(arg->buffer + arg->len,
 			    " %08x %08x %08x %08x %8s\n",

---
commit 9f19e129e7acc28c64cc139f7f65e755d3f51fc9
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Oct 19 13:50:09 2006 +0900

    [IPV6] ROUTE: Use &rt->u.dst instead of cast.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 8377477..25804cb 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -63,7 +63,7 @@ struct dst_entry *fib6_rule_lookup(struc
 		fib_rule_put(arg.rule);
 
 	if (arg.result)
-		return (struct dst_entry *) arg.result;
+		return arg.result;
 
 	dst_hold(&ip6_null_entry.u.dst);
 	return &ip6_null_entry.u.dst;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 92c948c..07d8dbc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -939,7 +939,7 @@ struct dst_entry *ndisc_dst_alloc(struct
 	fib6_force_start_gc();
 
 out:
-	return (struct dst_entry *)rt;
+	return &rt->u.dst;
 }
 
 int ndisc_dst_gc(int *more)
@@ -1222,7 +1222,7 @@ out:
 	if (idev)
 		in6_dev_put(idev);
 	if (rt)
-		dst_free((struct dst_entry *) rt);
+		dst_free(&rt->u.dst);
 	return err;
 }
 
@@ -1821,7 +1821,7 @@ struct rt6_info *addrconf_dst_alloc(stru
 		rt->rt6i_flags |= RTF_LOCAL;
 	rt->rt6i_nexthop = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
 	if (rt->rt6i_nexthop == NULL) {
-		dst_free((struct dst_entry *) rt);
+		dst_free(&rt->u.dst);
 		return ERR_PTR(-ENOMEM);
 	}
 

---
commit d58c0a82b288b237ac1f0f5f80d5edc336cc8959
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Oct 13 16:17:25 2006 +0900

    [IPV6]: Introduce ip6_dst_idev() to get inet6_dev{} stored in dst_entry{}.
    
    Otherwise, we will see a lot of casts...
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index e4438de..f9cde44 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -107,6 +107,11 @@ struct rt6_info
 	u8				rt6i_protocol;
 };
 
+static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
+{
+	return ((struct rt6_info *)dst)->rt6i_idev;
+}
+
 struct fib6_walker_t
 {
 	struct fib6_walker_t *prev, *next;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b312a5f..6a98f68 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1164,7 +1164,7 @@ record_it:
 int ipv6_get_saddr(struct dst_entry *dst,
 		   struct in6_addr *daddr, struct in6_addr *saddr)
 {
-	return ipv6_dev_get_saddr(dst ? ((struct rt6_info *)dst)->rt6i_idev->dev : NULL, daddr, saddr);
+	return ipv6_dev_get_saddr(dst ? ip6_dst_idev(dst)->dev : NULL, daddr, saddr);
 }
 
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 6b8e6d7..ebf54ae 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -84,7 +84,7 @@ int ipv6_rcv(struct sk_buff *skb, struct
 	 * arrived via the sending interface (ethX), because of the
 	 * nature of scoping architecture. --yoshfuji
 	 */
-	IP6CB(skb)->iif = skb->dst ? ((struct rt6_info *)skb->dst)->rt6i_idev->dev->ifindex : dev->ifindex;
+	IP6CB(skb)->iif = skb->dst ? ip6_dst_idev(skb->dst)->dev->ifindex : dev->ifindex;
 
 	if (unlikely(!pskb_may_pull(skb, sizeof(*hdr))))
 		goto err;

---
commit bc130a0ec3aea6e0a349968447b33e4c2bf5f36e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Nov 4 20:11:37 2006 +0900

    [IPV6]: Per-interface statistics support.
    
    For IP MIB (RFC4293).
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 34489c1..3ec7d07 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -152,6 +152,7 @@ struct ifacaddr6
 
 struct ipv6_devstat {
 	struct proc_dir_entry	*proc_dir_entry;
+	DEFINE_SNMP_STAT(struct ipstats_mib, ipv6);
 	DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6);
 };
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 0b8c9b9..3c266ad 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -113,9 +113,24 @@ extern int sysctl_mld_max_msf;
 
 /* MIBs */
 DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
-#define IP6_INC_STATS(field)		SNMP_INC_STATS(ipv6_statistics, field)
-#define IP6_INC_STATS_BH(field)		SNMP_INC_STATS_BH(ipv6_statistics, field)
-#define IP6_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(ipv6_statistics, field)
+#define IP6_INC_STATS(idev,field)		({			\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_INC_STATS(_idev->stats.ipv6, field);		\
+	SNMP_INC_STATS(ipv6_statistics, field);				\
+})
+#define IP6_INC_STATS_BH(idev,field)		({			\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_INC_STATS_BH(_idev->stats.ipv6, field);		\
+	SNMP_INC_STATS_BH(ipv6_statistics, field);			\
+})
+#define IP6_INC_STATS_USER(idev,field)		({			\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_INC_STATS_USER(_idev->stats.ipv6, field);		\
+	SNMP_INC_STATS_USER(ipv6_statistics, field);			\
+})
 DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
 #define ICMP6_INC_STATS(idev, field)		({			\
 	struct inet6_dev *_idev = (idev);				\
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 88c96b1..27829cc 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -284,10 +284,12 @@ static int ipv6_destopt_rcv(struct sk_bu
 #ifdef CONFIG_IPV6_MIP6
 	__u16 dstbuf;
 #endif
+	struct dst_entry *dst;
 
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+8) ||
 	    !pskb_may_pull(skb, (skb->h.raw-skb->data)+((skb->h.raw[1]+1)<<3))) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -298,7 +300,9 @@ static int ipv6_destopt_rcv(struct sk_bu
 	dstbuf = opt->dst1;
 #endif
 
+	dst = dst_clone(skb->dst);
 	if (ip6_parse_tlv(tlvprocdestopt_lst, skbp)) {
+		dst_release(dst);
 		skb = *skbp;
 		skb->h.raw += ((skb->h.raw[1]+1)<<3);
 		opt = IP6CB(skb);
@@ -310,7 +314,8 @@ static int ipv6_destopt_rcv(struct sk_bu
 		return 1;
 	}
 
-	IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
+	dst_release(dst);
 	return -1;
 }
 
@@ -365,7 +370,8 @@ static int ipv6_rthdr_rcv(struct sk_buff
 
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+8) ||
 	    !pskb_may_pull(skb, (skb->h.raw-skb->data)+((skb->h.raw[1]+1)<<3))) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -374,7 +380,8 @@ static int ipv6_rthdr_rcv(struct sk_buff
 
 	if (ipv6_addr_is_multicast(&skb->nh.ipv6h->daddr) ||
 	    skb->pkt_type != PACKET_HOST) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INADDRERRORS);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -388,7 +395,8 @@ looped_back:
 			 * processed by own
 			 */
 			if (!addr) {
-				IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+				IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+						 IPSTATS_MIB_INADDRERRORS);
 				kfree_skb(skb);
 				return -1;
 			}
@@ -410,7 +418,8 @@ looped_back:
 	switch (hdr->type) {
 	case IPV6_SRCRT_TYPE_0:
 		if (hdr->hdrlen & 0x01) {
-			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+					 IPSTATS_MIB_INHDRERRORS);
 			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->hdrlen) - skb->nh.raw);
 			return -1;
 		}
@@ -419,14 +428,16 @@ looped_back:
 	case IPV6_SRCRT_TYPE_2:
 		/* Silently discard invalid RTH type 2 */
 		if (hdr->hdrlen != 2 || hdr->segments_left != 1) {
-			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+					 IPSTATS_MIB_INHDRERRORS);
 			kfree_skb(skb);
 			return -1;
 		}
 		break;
 #endif
 	default:
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->type) - skb->nh.raw);
 		return -1;
 	}
@@ -439,7 +450,8 @@ looped_back:
 	n = hdr->hdrlen >> 1;
 
 	if (hdr->segments_left > n) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->segments_left) - skb->nh.raw);
 		return -1;
 	}
@@ -449,12 +461,14 @@ looped_back:
 	 */
 	if (skb_cloned(skb)) {
 		struct sk_buff *skb2 = skb_copy(skb, GFP_ATOMIC);
-		kfree_skb(skb);
 		/* the copy is a forwarded packet */
 		if (skb2 == NULL) {
-			IP6_INC_STATS_BH(IPSTATS_MIB_OUTDISCARDS);	
+			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+					 IPSTATS_MIB_OUTDISCARDS);
+			kfree_skb(skb);
 			return -1;
 		}
+		kfree_skb(skb);
 		*skbp = skb = skb2;
 		opt = IP6CB(skb2);
 		hdr = (struct ipv6_rt_hdr *) skb2->h.raw;
@@ -475,12 +489,14 @@ looped_back:
 		if (xfrm6_input_addr(skb, (xfrm_address_t *)addr,
 				     (xfrm_address_t *)&skb->nh.ipv6h->saddr,
 				     IPPROTO_ROUTING) < 0) {
-			IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+					 IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);
 			return -1;
 		}
 		if (!ipv6_chk_home_addr(addr)) {
-			IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+					 IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);
 			return -1;
 		}
@@ -491,7 +507,8 @@ looped_back:
 	}
 
 	if (ipv6_addr_is_multicast(addr)) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INADDRERRORS);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -510,7 +527,8 @@ looped_back:
 
 	if (skb->dst->dev->flags&IFF_LOOPBACK) {
 		if (skb->nh.ipv6h->hop_limit <= 1) {
-			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+					 IPSTATS_MIB_INHDRERRORS);
 			icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 				    0, skb->dev);
 			kfree_skb(skb);
@@ -632,24 +650,25 @@ static int ipv6_hop_jumbo(struct sk_buff
 	if (skb->nh.raw[optoff+1] != 4 || (optoff&3) != 2) {
 		LIMIT_NETDEBUG(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n",
 		               skb->nh.raw[optoff+1]);
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
 
 	pkt_len = ntohl(*(u32*)(skb->nh.raw+optoff+2));
 	if (pkt_len <= IPV6_MAXPLEN) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff+2);
 		return 0;
 	}
 	if (skb->nh.ipv6h->payload_len) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff);
 		return 0;
 	}
 
 	if (pkt_len > skb->len - sizeof(struct ipv6hdr)) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INTRUNCATEDPKTS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	}
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 81bd45b..52cca93 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -177,7 +177,8 @@ static inline int icmpv6_xrlim_allow(str
 	 */
 	dst = ip6_route_output(sk, fl);
 	if (dst->error) {
-		IP6_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
+		IP6_INC_STATS(ip6_dst_idev(dst),
+			      IPSTATS_MIB_OUTNOROUTES);
 	} else if (dst->dev && (dst->dev->flags&IFF_LOOPBACK)) {
 		res = 1;
 	} else {
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index ebf54ae..ad0b8ab 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -60,14 +60,22 @@ int ipv6_rcv(struct sk_buff *skb, struct
 {
 	struct ipv6hdr *hdr;
 	u32 		pkt_len;
+	struct inet6_dev *idev;
 
-	if (skb->pkt_type == PACKET_OTHERHOST)
-		goto drop;
+	if (skb->pkt_type == PACKET_OTHERHOST) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	rcu_read_lock();
 
-	IP6_INC_STATS_BH(IPSTATS_MIB_INRECEIVES);
+	idev = __in6_dev_get(skb->dev);
+
+	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INRECEIVES);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
+		IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDISCARDS);
+		rcu_read_unlock();
 		goto out;
 	}
 
@@ -104,7 +112,7 @@ int ipv6_rcv(struct sk_buff *skb, struct
 		if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
 			goto truncated;
 		if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr))) {
-			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
 			goto drop;
 		}
 		hdr = skb->nh.ipv6h;
@@ -112,17 +120,21 @@ int ipv6_rcv(struct sk_buff *skb, struct
 
 	if (hdr->nexthdr == NEXTHDR_HOP) {
 		if (ipv6_parse_hopopts(&skb) < 0) {
-			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
+			rcu_read_unlock();
 			return 0;
 		}
 	}
 
+	rcu_read_unlock();
+
 	return NF_HOOK(PF_INET6,NF_IP6_PRE_ROUTING, skb, dev, NULL, ip6_rcv_finish);
 truncated:
-	IP6_INC_STATS_BH(IPSTATS_MIB_INTRUNCATEDPKTS);
+	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INTRUNCATEDPKTS);
 err:
-	IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
 drop:
+	rcu_read_unlock();
 	kfree_skb(skb);
 out:
 	return 0;
@@ -140,6 +152,7 @@ static inline int ip6_input_finish(struc
 	unsigned int nhoff;
 	int nexthdr;
 	u8 hash;
+	struct inet6_dev *idev;
 
 	/*
 	 *	Parse extension headers
@@ -147,6 +160,7 @@ static inline int ip6_input_finish(struc
 
 	rcu_read_lock();
 resubmit:
+	idev = ip6_dst_idev(skb->dst);
 	if (!pskb_pull(skb, skb->h.raw - skb->data))
 		goto discard;
 	nhoff = IP6CB(skb)->nhoff;
@@ -185,24 +199,24 @@ resubmit:
 		if (ret > 0)
 			goto resubmit;
 		else if (ret == 0)
-			IP6_INC_STATS_BH(IPSTATS_MIB_INDELIVERS);
+			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDELIVERS);
 	} else {
 		if (!raw_sk) {
 			if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-				IP6_INC_STATS_BH(IPSTATS_MIB_INUNKNOWNPROTOS);
+				IP6_INC_STATS_BH(idev, IPSTATS_MIB_INUNKNOWNPROTOS);
 				icmpv6_send(skb, ICMPV6_PARAMPROB,
 				            ICMPV6_UNK_NEXTHDR, nhoff,
 				            skb->dev);
 			}
 		} else
-			IP6_INC_STATS_BH(IPSTATS_MIB_INDELIVERS);
+			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDELIVERS);
 		kfree_skb(skb);
 	}
 	rcu_read_unlock();
 	return 0;
 
 discard:
-	IP6_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
+	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDISCARDS);
 	rcu_read_unlock();
 	kfree_skb(skb);
 	return 0;
@@ -219,7 +233,7 @@ int ip6_mc_input(struct sk_buff *skb)
 	struct ipv6hdr *hdr;
 	int deliver;
 
-	IP6_INC_STATS_BH(IPSTATS_MIB_INMCASTPKTS);
+	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCASTPKTS);
 
 	hdr = skb->nh.ipv6h;
 	deliver = likely(!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI))) ||
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1bde3ac..85f8892 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -88,7 +88,7 @@ static inline int ip6_output_finish(stru
 	} else if (dst->neighbour)
 		return dst->neighbour->output(skb);
 
-	IP6_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EINVAL;
 
@@ -118,6 +118,7 @@ static int ip6_output2(struct sk_buff *s
 
 	if (ipv6_addr_is_multicast(&skb->nh.ipv6h->daddr)) {
 		struct ipv6_pinfo* np = skb->sk ? inet6_sk(skb->sk) : NULL;
+		struct inet6_dev *idev = ip6_dst_idev(skb->dst);
 
 		if (!(dev->flags & IFF_LOOPBACK) && (!np || np->mc_loop) &&
 		    ipv6_chk_mcast_addr(dev, &skb->nh.ipv6h->daddr,
@@ -133,13 +134,13 @@ static int ip6_output2(struct sk_buff *s
 					ip6_dev_loopback_xmit);
 
 			if (skb->nh.ipv6h->hop_limit == 0) {
-				IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+				IP6_INC_STATS(idev, IPSTATS_MIB_OUTDISCARDS);
 				kfree_skb(skb);
 				return 0;
 			}
 		}
 
-		IP6_INC_STATS(IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
 	}
 
 	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb,NULL, skb->dev,ip6_output_finish);
@@ -182,12 +183,14 @@ int ip6_xmit(struct sock *sk, struct sk_
 
 		if (skb_headroom(skb) < head_room) {
 			struct sk_buff *skb2 = skb_realloc_headroom(skb, head_room);
-			kfree_skb(skb);
-			skb = skb2;
-			if (skb == NULL) {	
-				IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+			if (skb2 == NULL) {
+				IP6_INC_STATS(ip6_dst_idev(skb->dst),
+					      IPSTATS_MIB_OUTDISCARDS);
+				kfree_skb(skb);
 				return -ENOBUFS;
 			}
+			kfree_skb(skb);
+			skb = skb2;
 			if (sk)
 				skb_set_owner_w(skb, sk);
 		}
@@ -230,7 +233,8 @@ int ip6_xmit(struct sock *sk, struct sk_
 
 	mtu = dst_mtu(dst);
 	if ((skb->len <= mtu) || ipfragok || skb_is_gso(skb)) {
-		IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
+		IP6_INC_STATS(ip6_dst_idev(skb->dst),
+			      IPSTATS_MIB_OUTREQUESTS);
 		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
 	}
@@ -239,7 +243,7 @@ int ip6_xmit(struct sock *sk, struct sk_
 		printk(KERN_DEBUG "IPv6: sending pkt_too_big to self\n");
 	skb->dev = dst->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
-	IP6_INC_STATS(IPSTATS_MIB_FRAGFAILS);
+	IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb);
 	return -EMSGSIZE;
 }
@@ -373,7 +377,7 @@ int ip6_forward(struct sk_buff *skb)
 		goto error;
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb)) {
-		IP6_INC_STATS(IPSTATS_MIB_INDISCARDS);
+		IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -406,7 +410,7 @@ int ip6_forward(struct sk_buff *skb)
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 			    0, skb->dev);
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
 
 		kfree_skb(skb);
 		return -ETIMEDOUT;
@@ -419,13 +423,13 @@ int ip6_forward(struct sk_buff *skb)
 		if (proxied > 0)
 			return ip6_input(skb);
 		else if (proxied < 0) {
-			IP6_INC_STATS(IPSTATS_MIB_INDISCARDS);
+			IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
 			goto drop;
 		}
 	}
 
 	if (!xfrm6_route_forward(skb)) {
-		IP6_INC_STATS(IPSTATS_MIB_INDISCARDS);
+		IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 	dst = skb->dst;
@@ -464,14 +468,14 @@ int ip6_forward(struct sk_buff *skb)
 		/* Again, force OUTPUT device used as source address */
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, dst_mtu(dst), skb->dev);
-		IP6_INC_STATS_BH(IPSTATS_MIB_INTOOBIGERRORS);
-		IP6_INC_STATS_BH(IPSTATS_MIB_FRAGFAILS);
+		IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_INTOOBIGERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_FRAGFAILS);
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
 
 	if (skb_cow(skb, dst->dev->hard_header_len)) {
-		IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_OUTDISCARDS);
 		goto drop;
 	}
 
@@ -481,11 +485,11 @@ int ip6_forward(struct sk_buff *skb)
  
 	hdr->hop_limit--;
 
-	IP6_INC_STATS_BH(IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
 	return NF_HOOK(PF_INET6,NF_IP6_FORWARD, skb, skb->dev, dst->dev, ip6_forward_finish);
 
 error:
-	IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_INADDRERRORS);
 drop:
 	kfree_skb(skb);
 	return -EINVAL;
@@ -622,7 +626,7 @@ static int ip6_fragment(struct sk_buff *
 
 		tmp_hdr = kmalloc(hlen, GFP_ATOMIC);
 		if (!tmp_hdr) {
-			IP6_INC_STATS(IPSTATS_MIB_FRAGFAILS);
+			IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGFAILS);
 			return -ENOMEM;
 		}
 
@@ -643,7 +647,8 @@ static int ip6_fragment(struct sk_buff *
 		skb->data_len = first_len - skb_headlen(skb);
 		skb->len = first_len;
 		skb->nh.ipv6h->payload_len = htons(first_len - sizeof(struct ipv6hdr));
- 
+
+		dst_hold(&rt->u.dst);
 
 		for (;;) {
 			/* Prepare header of the next frame,
@@ -667,7 +672,7 @@ static int ip6_fragment(struct sk_buff *
 			
 			err = output(skb);
 			if(!err)
-				IP6_INC_STATS(IPSTATS_MIB_FRAGCREATES);
+				IP6_INC_STATS(ip6_dst_idev(&rt->u.dst), IPSTATS_MIB_FRAGCREATES);
 
 			if (err || !frag)
 				break;
@@ -680,7 +685,8 @@ static int ip6_fragment(struct sk_buff *
 		kfree(tmp_hdr);
 
 		if (err == 0) {
-			IP6_INC_STATS(IPSTATS_MIB_FRAGOKS);
+			IP6_INC_STATS(ip6_dst_idev(&rt->u.dst), IPSTATS_MIB_FRAGOKS);
+			dst_release(&rt->u.dst);
 			return 0;
 		}
 
@@ -690,7 +696,8 @@ static int ip6_fragment(struct sk_buff *
 			frag = skb;
 		}
 
-		IP6_INC_STATS(IPSTATS_MIB_FRAGFAILS);
+		IP6_INC_STATS(ip6_dst_idev(&rt->u.dst), IPSTATS_MIB_FRAGFAILS);
+		dst_release(&rt->u.dst);
 		return err;
 	}
 
@@ -723,7 +730,8 @@ slow_path:
 
 		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_RESERVED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
 			NETDEBUG(KERN_INFO "IPv6: frag: no memory for new fragment!\n");
-			IP6_INC_STATS(IPSTATS_MIB_FRAGFAILS);
+			IP6_INC_STATS(ip6_dst_idev(skb->dst),
+				      IPSTATS_MIB_FRAGFAILS);
 			err = -ENOMEM;
 			goto fail;
 		}
@@ -784,15 +792,17 @@ slow_path:
 		if (err)
 			goto fail;
 
-		IP6_INC_STATS(IPSTATS_MIB_FRAGCREATES);
+		IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGCREATES);
 	}
+	IP6_INC_STATS(ip6_dst_idev(skb->dst),
+		      IPSTATS_MIB_FRAGOKS);
 	kfree_skb(skb);
-	IP6_INC_STATS(IPSTATS_MIB_FRAGOKS);
 	return err;
 
 fail:
+	IP6_INC_STATS(ip6_dst_idev(skb->dst),
+		      IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb); 
-	IP6_INC_STATS(IPSTATS_MIB_FRAGFAILS);
 	return err;
 }
 
@@ -1265,7 +1275,7 @@ alloc_new_skb:
 	return 0;
 error:
 	inet->cork.length -= length;
-	IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
 
@@ -1326,7 +1336,7 @@ int ip6_push_pending_frames(struct sock
 	skb->priority = sk->sk_priority;
 
 	skb->dst = dst_clone(&rt->u.dst);
-	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);	
+	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
 	if (err) {
 		if (err > 0)
@@ -1357,7 +1367,8 @@ void ip6_flush_pending_frames(struct soc
 	struct sk_buff *skb;
 
 	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
-		IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS(ip6_dst_idev(skb->dst),
+			      IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
 	}
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 9055979..c006d02 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1465,7 +1465,7 @@ static void mld_sendpack(struct sk_buff
 	struct inet6_dev *idev = in6_dev_get(skb->dev);
 	int err;
 
-	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
+	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
 	payload_len = skb->tail - (unsigned char *)skb->nh.ipv6h -
 		sizeof(struct ipv6hdr);
 	mldlen = skb->tail - skb->h.raw;
@@ -1477,9 +1477,9 @@ static void mld_sendpack(struct sk_buff
 		mld_dev_queue_xmit);
 	if (!err) {
 		ICMP6_INC_STATS(idev,ICMP6_MIB_OUTMSGS);
-		IP6_INC_STATS(IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
 	} else
-		IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS(idev, IPSTATS_MIB_OUTDISCARDS);
 
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
@@ -1763,7 +1763,10 @@ static void igmp6_send(struct in6_addr *
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
 		     IPV6_TLV_PADN, 0 };
 
-	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
+	rcu_read_lock();
+	IP6_INC_STATS(__in6_dev_get(dev),
+		      IPSTATS_MIB_OUTREQUESTS);
+	rcu_read_unlock();
 	snd_addr = addr;
 	if (type == ICMPV6_MGM_REDUCTION) {
 		snd_addr = &all_routers;
@@ -1777,7 +1780,10 @@ static void igmp6_send(struct in6_addr *
 	skb = sock_alloc_send_skb(sk, LL_RESERVED_SPACE(dev) + full_len, 1, &err);
 
 	if (skb == NULL) {
-		IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+		rcu_read_lock();
+		IP6_INC_STATS(__in6_dev_get(dev),
+			      IPSTATS_MIB_OUTDISCARDS);
+		rcu_read_unlock();
 		return;
 	}
 
@@ -1816,9 +1822,9 @@ static void igmp6_send(struct in6_addr *
 		else
 			ICMP6_INC_STATS(idev, ICMP6_MIB_OUTGROUPMEMBRESPONSES);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
-		IP6_INC_STATS(IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
 	} else
-		IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS(idev, IPSTATS_MIB_OUTDISCARDS);
 
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 73eb8c3..4ac7e6b 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -513,7 +513,7 @@ static void ndisc_send_na(struct net_dev
 
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
-	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
+	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORADVERTISEMENTS);
@@ -597,7 +597,7 @@ void ndisc_send_ns(struct net_device *de
 	/* send it! */
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
-	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
+	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORSOLICITS);
@@ -670,7 +670,7 @@ void ndisc_send_rs(struct net_device *de
 	/* send it! */
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
-	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);	
+	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTROUTERSOLICITS);
@@ -1504,7 +1504,7 @@ void ndisc_send_redirect(struct sk_buff
 
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
-	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
+	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTREDIRECTS);
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 580b1ab..646a474 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -31,7 +31,7 @@ int ip6_route_me_harder(struct sk_buff *
 #endif
 
 	if (dst->error) {
-		IP6_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
+		IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
 		dst_release(dst);
 		return -EINVAL;
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index efee7a6..4158d38 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -161,6 +161,7 @@ static int snmp6_seq_show(struct seq_fil
 
 	if (idev) {
 		seq_printf(seq, "%-32s\t%u\n", "ifIndex", idev->dev->ifindex);
+		snmp6_seq_show_item(seq, (void **)idev->stats.ipv6, snmp6_ipstats_list);
 		snmp6_seq_show_item(seq, (void **)idev->stats.icmpv6, snmp6_icmp6_list);
 	} else {
 		snmp6_seq_show_item(seq, (void **)ipv6_statistics, snmp6_ipstats_list);
@@ -281,6 +282,9 @@ int snmp6_alloc_dev(struct inet6_dev *id
 	if (!idev || !idev->dev)
 		return -EINVAL;
 
+	if (snmp6_mib_init((void **)idev->stats.ipv6, sizeof(struct ipstats_mib),
+			   __alignof__(struct ipstats_mib)) < 0)
+		goto err_ip;
 	if (snmp6_mib_init((void **)idev->stats.icmpv6, sizeof(struct icmpv6_mib),
 			   __alignof__(struct icmpv6_mib)) < 0)
 		goto err_icmp;
@@ -288,12 +292,15 @@ int snmp6_alloc_dev(struct inet6_dev *id
 	return 0;
 
 err_icmp:
+	snmp6_mib_free((void **)idev->stats.ipv6);
+err_ip:
 	return err;
 }
 
 int snmp6_free_dev(struct inet6_dev *idev)
 {
 	snmp6_mib_free((void **)idev->stats.icmpv6);
+	snmp6_mib_free((void **)idev->stats.ipv6);
 	return 0;
 }
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 6bc6655..18a9007 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -586,7 +586,7 @@ static int rawv6_send_hdrinc(struct sock
 	if (err)
 		goto error_fault;
 
-	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);		
+	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
@@ -600,7 +600,7 @@ error_fault:
 	err = -EFAULT;
 	kfree_skb(skb);
 error:
-	IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
+	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	return err; 
 }
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index f39bbed..3af0d5a 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -47,6 +47,7 @@
 #include <net/snmp.h>
 
 #include <net/ipv6.h>
+#include <net/ip6_route.h>
 #include <net/protocol.h>
 #include <net/transp_v6.h>
 #include <net/rawv6.h>
@@ -257,7 +258,7 @@ static __inline__ void fq_kill(struct fr
 	}
 }
 
-static void ip6_evictor(void)
+static void ip6_evictor(struct inet6_dev *idev)
 {
 	struct frag_queue *fq;
 	struct list_head *tmp;
@@ -284,14 +285,14 @@ static void ip6_evictor(void)
 		spin_unlock(&fq->lock);
 
 		fq_put(fq, &work);
-		IP6_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+		IP6_INC_STATS_BH(idev, IPSTATS_MIB_REASMFAILS);
 	}
 }
 
 static void ip6_frag_expire(unsigned long data)
 {
 	struct frag_queue *fq = (struct frag_queue *) data;
-	struct net_device *dev;
+	struct net_device *dev = NULL;
 
 	spin_lock(&fq->lock);
 
@@ -300,17 +301,19 @@ static void ip6_frag_expire(unsigned lon
 
 	fq_kill(fq);
 
-	IP6_INC_STATS_BH(IPSTATS_MIB_REASMTIMEOUT);
-	IP6_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+	dev = dev_get_by_index(fq->iif);
+	if (!dev)
+		goto out;
+
+	rcu_read_lock();
+	IP6_INC_STATS_BH(__in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
+	IP6_INC_STATS_BH(__in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
+	rcu_read_unlock();
 
 	/* Don't send error if the first segment did not arrive. */
 	if (!(fq->last_in&FIRST_IN) || !fq->fragments)
 		goto out;
 
-	dev = dev_get_by_index(fq->iif);
-	if (!dev)
-		goto out;
-
 	/*
 	   But use as source device on which LAST ARRIVED
 	   segment was received. And do not use fq->dev
@@ -318,8 +321,9 @@ static void ip6_frag_expire(unsigned lon
 	 */
 	fq->fragments->dev = dev;
 	icmpv6_send(fq->fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME, 0, dev);
-	dev_put(dev);
 out:
+	if (dev)
+		dev_put(dev);
 	spin_unlock(&fq->lock);
 	fq_put(fq, NULL);
 }
@@ -366,7 +370,8 @@ static struct frag_queue *ip6_frag_inter
 
 
 static struct frag_queue *
-ip6_frag_create(u32 id, struct in6_addr *src, struct in6_addr *dst)
+ip6_frag_create(u32 id, struct in6_addr *src, struct in6_addr *dst,
+		struct inet6_dev *idev)
 {
 	struct frag_queue *fq;
 
@@ -386,12 +391,13 @@ ip6_frag_create(u32 id, struct in6_addr
 	return ip6_frag_intern(fq);
 
 oom:
-	IP6_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS_BH(idev, IPSTATS_MIB_REASMFAILS);
 	return NULL;
 }
 
 static __inline__ struct frag_queue *
-fq_find(u32 id, struct in6_addr *src, struct in6_addr *dst)
+fq_find(u32 id, struct in6_addr *src, struct in6_addr *dst,
+	struct inet6_dev *idev)
 {
 	struct frag_queue *fq;
 	struct hlist_node *n;
@@ -410,7 +416,7 @@ fq_find(u32 id, struct in6_addr *src, st
 	}
 	read_unlock(&ip6_frag_lock);
 
-	return ip6_frag_create(id, src, dst);
+	return ip6_frag_create(id, src, dst, idev);
 }
 
 
@@ -428,7 +434,8 @@ static void ip6_frag_queue(struct frag_q
 			((u8 *) (fhdr + 1) - (u8 *) (skb->nh.ipv6h + 1)));
 
 	if ((unsigned int)end > IPV6_MAXPLEN) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				 IPSTATS_MIB_INHDRERRORS);
  		icmpv6_param_prob(skb,ICMPV6_HDR_FIELD, (u8*)&fhdr->frag_off - skb->nh.raw);
  		return;
 	}
@@ -455,7 +462,8 @@ static void ip6_frag_queue(struct frag_q
 			/* RFC2460 says always send parameter problem in
 			 * this case. -DaveM
 			 */
-			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+					 IPSTATS_MIB_INHDRERRORS);
 			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, 
 					  offsetof(struct ipv6hdr, payload_len));
 			return;
@@ -571,7 +579,7 @@ static void ip6_frag_queue(struct frag_q
 	return;
 
 err:
-	IP6_INC_STATS(IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 }
 
@@ -665,7 +673,9 @@ static int ip6_frag_reasm(struct frag_qu
 	if (head->ip_summed == CHECKSUM_COMPLETE)
 		head->csum = csum_partial(head->nh.raw, head->h.raw-head->nh.raw, head->csum);
 
-	IP6_INC_STATS_BH(IPSTATS_MIB_REASMOKS);
+	rcu_read_lock();
+	IP6_INC_STATS_BH(__in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
+	rcu_read_unlock();
 	fq->fragments = NULL;
 	return 1;
 
@@ -677,7 +687,9 @@ out_oom:
 	if (net_ratelimit())
 		printk(KERN_DEBUG "ip6_frag_reasm: no memory for reassembly\n");
 out_fail:
-	IP6_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+	rcu_read_lock();
+	IP6_INC_STATS_BH(__in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
+	rcu_read_unlock();
 	return -1;
 }
 
@@ -691,16 +703,16 @@ static int ipv6_frag_rcv(struct sk_buff
 
 	hdr = skb->nh.ipv6h;
 
-	IP6_INC_STATS_BH(IPSTATS_MIB_REASMREQDS);
+	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMREQDS);
 
 	/* Jumbo payload inhibits frag. header */
 	if (hdr->payload_len==0) {
-		IP6_INC_STATS(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb->h.raw-skb->nh.raw);
 		return -1;
 	}
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+sizeof(struct frag_hdr))) {
-		IP6_INC_STATS(IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb->h.raw-skb->nh.raw);
 		return -1;
 	}
@@ -711,16 +723,17 @@ static int ipv6_frag_rcv(struct sk_buff
 	if (!(fhdr->frag_off & htons(0xFFF9))) {
 		/* It is not a fragmented frame */
 		skb->h.raw += sizeof(struct frag_hdr);
-		IP6_INC_STATS_BH(IPSTATS_MIB_REASMOKS);
+		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMOKS);
 
 		IP6CB(skb)->nhoff = (u8*)fhdr - skb->nh.raw;
 		return 1;
 	}
 
 	if (atomic_read(&ip6_frag_mem) > sysctl_ip6frag_high_thresh)
-		ip6_evictor();
+		ip6_evictor(ip6_dst_idev(skb->dst));
 
-	if ((fq = fq_find(fhdr->identification, &hdr->saddr, &hdr->daddr)) != NULL) {
+	if ((fq = fq_find(fhdr->identification, &hdr->saddr, &hdr->daddr,
+			  ip6_dst_idev(skb->dst))) != NULL) {
 		int ret = -1;
 
 		spin_lock(&fq->lock);
@@ -736,7 +749,7 @@ static int ipv6_frag_rcv(struct sk_buff
 		return ret;
 	}
 
-	IP6_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 07d8dbc..d88da13 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1748,9 +1748,9 @@ static inline int ip6_pkt_drop(struct sk
 {
 	int type = ipv6_addr_type(&skb->nh.ipv6h->daddr);
 	if (type == IPV6_ADDR_ANY || type == IPV6_ADDR_RESERVED)
-		IP6_INC_STATS(IPSTATS_MIB_INADDRERRORS);
+		IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INADDRERRORS);
 
-	IP6_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
+	IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_OUTNOROUTES);
 	icmpv6_send(skb, ICMPV6_DEST_UNREACH, code, 0, skb->dev);
 	kfree_skb(skb);
 	return 0;

---
