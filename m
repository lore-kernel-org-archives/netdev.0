From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK PATCH] INET6 Updates (2004/10/26)
Date: Tue, 26 Oct 2004 13:16:26 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026.131626.77300437.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Please pull following changesets available at
<bk://bk.skbuff.net:20610/linux-2.6-inet6-20041026/>.

Thank you.

HEADLINES
---------
ChangeSet@1.2176, 2004-10-26 12:51:07+09:00, Brian.Haley@hp.com
 [IPV6] Lookup appropriate destination when sending TCPv6 with routing header.
ChangeSet@1.2177, 2004-10-26 12:54:41+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Remove codes related to RTF_ALLONLINK.
ChangeSet@1.2178, 2004-10-26 12:54:58+09:00, yoshfuji@linux-ipv6.org
 [IPV6] simplify functions related to RTF_ALLONLINK.
ChangeSet@1.2179, 2004-10-26 12:55:56+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: update neighbor cache entry by RS.
ChangeSet@1.2180, 2004-10-26 13:11:47+09:00, yoshfuji@linux-ipv6.org
 [IPV6] kill a warning when building without CONFIG_SYSCTL.


DIFFSTATS
---------
 include/linux/ipv6_route.h |    3 +-
 include/net/addrconf.h     |    3 --
 include/net/ip6_route.h    |    2 -
 include/net/ndisc.h        |    5 +++
 net/ipv6/addrconf.c        |   26 ++++-------------
 net/ipv6/ip6_fib.c         |    2 -
 net/ipv6/ndisc.c           |   66 +++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/route.c           |   12 ++------
 net/ipv6/tcp_ipv6.c        |    6 ++++
 9 files changed, 90 insertions(+), 35 deletions(-)


CHANGESETS
----------
ChangeSet@1.2176, 2004-10-26 12:51:07+09:00, Brian.Haley@hp.com
 [IPV6] Lookup appropriate destination when sending TCPv6 with routing header.
 
 Signed-off-by: Brian Haley <Brian.Haley@hp.com>
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-10-26 13:12:33 +09:00
+++ b/net/ipv6/tcp_ipv6.c	2004-10-26 13:12:34 +09:00
@@ -1802,6 +1802,7 @@
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flowi fl;
 	struct dst_entry *dst;
+	struct in6_addr *final_p = NULL, final;
 
 	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_TCP;
@@ -1815,7 +1816,9 @@
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
+		ipv6_addr_copy(&final, &fl.fl6_dst);
 		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		final_p = &final;
 	}
 
 	dst = __sk_dst_check(sk, np->dst_cookie);
@@ -1827,6 +1830,9 @@
 			sk->sk_err_soft = -err;
 			return err;
 		}
+
+		if (final_p)
+			ipv6_addr_copy(&fl.fl6_dst, final_p);
 
 		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
 			sk->sk_route_caps = 0;

ChangeSet@1.2177, 2004-10-26 12:54:41+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Remove codes related to RTF_ALLONLINK.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/linux/ipv6_route.h b/include/linux/ipv6_route.h
--- a/include/linux/ipv6_route.h	2004-10-26 13:12:38 +09:00
+++ b/include/linux/ipv6_route.h	2004-10-26 13:12:38 +09:00
@@ -14,7 +14,8 @@
 #define _LINUX_IPV6_ROUTE_H
 
 #define RTF_DEFAULT	0x00010000	/* default - learned via ND	*/
-#define RTF_ALLONLINK	0x00020000	/* fallback, no routers on link	*/
+#define RTF_ALLONLINK	0x00020000	/* (deprecated and will be removed)
+					   fallback, no routers on link */
 #define RTF_ADDRCONF	0x00040000	/* addrconf route - RA		*/
 #define RTF_PREFIX_RT	0x00080000	/* A prefix only route - RA	*/
 
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-10-26 13:12:38 +09:00
+++ b/net/ipv6/addrconf.c	2004-10-26 13:12:38 +09:00
@@ -885,7 +885,7 @@
 	if (rt)
 		dev = rt->rt6i_dev;
 
-	onlink = (rt && (rt->rt6i_flags & RTF_ALLONLINK));
+	onlink = 0;
 
 	return ipv6_dev_get_saddr(dev, daddr, saddr, onlink);
 }
diff -Nru a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
--- a/net/ipv6/ip6_fib.c	2004-10-26 13:12:38 +09:00
+++ b/net/ipv6/ip6_fib.c	2004-10-26 13:12:38 +09:00
@@ -433,7 +433,7 @@
 
 	if (fn->fn_flags&RTN_TL_ROOT &&
 	    fn->leaf == &ip6_null_entry &&
-	    !(rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF | RTF_ALLONLINK)) ){
+	    !(rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ){
 		fn->leaf = rt;
 		rt->u.next = NULL;
 		goto out;
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-10-26 13:12:38 +09:00
+++ b/net/ipv6/ndisc.c	2004-10-26 13:12:38 +09:00
@@ -1026,7 +1026,7 @@
 		 *	delete it
 		 */
 
-		rt6_purge_dflt_routers(RTF_ALLONLINK);
+		rt6_purge_dflt_routers(0);
 	}
 
 	if (rt)
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-10-26 13:12:38 +09:00
+++ b/net/ipv6/route.c	2004-10-26 13:12:38 +09:00
@@ -1293,10 +1293,7 @@
 	struct rt6_info *rt;
 	u32 flags;
 
-	if (last_resort)
-		flags = RTF_ALLONLINK;
-	else
-		flags = RTF_DEFAULT | RTF_ADDRCONF;	
+	flags = RTF_DEFAULT | RTF_ADDRCONF;	
 
 restart:
 	read_lock_bh(&rt6_lock);
@@ -1592,7 +1589,7 @@
 	rtm->rtm_protocol = rt->rt6i_protocol;
 	if (rt->rt6i_flags&RTF_DYNAMIC)
 		rtm->rtm_protocol = RTPROT_REDIRECT;
-	else if (rt->rt6i_flags&(RTF_ADDRCONF|RTF_ALLONLINK))
+	else if (rt->rt6i_flags & RTF_ADDRCONF)
 		rtm->rtm_protocol = RTPROT_KERNEL;
 	else if (rt->rt6i_flags&RTF_DEFAULT)
 		rtm->rtm_protocol = RTPROT_RA;

ChangeSet@1.2178, 2004-10-26 12:54:58+09:00, yoshfuji@linux-ipv6.org
 [IPV6] simplify functions related to RTF_ALLONLINK.
 
 Simplify ipv6_get_saddr(), ipv6_dev_get_saddr() and
 rt6_purge_dflt_routers().
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/addrconf.h b/include/net/addrconf.h
--- a/include/net/addrconf.h	2004-10-26 13:12:42 +09:00
+++ b/include/net/addrconf.h	2004-10-26 13:12:42 +09:00
@@ -67,8 +67,7 @@
 					       struct in6_addr *saddr);
 extern int			ipv6_dev_get_saddr(struct net_device *dev, 
 					       struct in6_addr *daddr,
-					       struct in6_addr *saddr,
-					       int onlink);
+					       struct in6_addr *saddr);
 extern int			ipv6_get_lladdr(struct net_device *dev, struct in6_addr *);
 extern int			ipv6_rcv_saddr_equal(const struct sock *sk, 
 						      const struct sock *sk2);
diff -Nru a/include/net/ip6_route.h b/include/net/ip6_route.h
--- a/include/net/ip6_route.h	2004-10-26 13:12:42 +09:00
+++ b/include/net/ip6_route.h	2004-10-26 13:12:42 +09:00
@@ -87,7 +87,7 @@
 extern struct rt6_info *	rt6_add_dflt_router(struct in6_addr *gwaddr,
 						    struct net_device *dev);
 
-extern void			rt6_purge_dflt_routers(int lst_resort);
+extern void			rt6_purge_dflt_routers(void);
 
 extern void			rt6_reset_dflt_pointer(struct rt6_info *rt);
 
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-10-26 13:12:42 +09:00
+++ b/net/ipv6/addrconf.c	2004-10-26 13:12:42 +09:00
@@ -760,7 +760,7 @@
 #endif
 
 int ipv6_dev_get_saddr(struct net_device *dev,
-		   struct in6_addr *daddr, struct in6_addr *saddr, int onlink)
+		       struct in6_addr *daddr, struct in6_addr *saddr)
 {
 	struct inet6_ifaddr *ifp = NULL;
 	struct inet6_ifaddr *match = NULL;
@@ -769,10 +769,7 @@
 	int err;
 	int hiscore = -1, score;
 
-	if (!onlink)
-		scope = ipv6_addr_scope(daddr);
-	else
-		scope = IFA_LINK;
+	scope = ipv6_addr_scope(daddr);
 
 	/*
 	 *	known dev
@@ -877,17 +874,7 @@
 int ipv6_get_saddr(struct dst_entry *dst,
 		   struct in6_addr *daddr, struct in6_addr *saddr)
 {
-	struct rt6_info *rt;
-	struct net_device *dev = NULL;
-	int onlink;
-
-	rt = (struct rt6_info *) dst;
-	if (rt)
-		dev = rt->rt6i_dev;
-
-	onlink = 0;
-
-	return ipv6_dev_get_saddr(dev, daddr, saddr, onlink);
+	return ipv6_dev_get_saddr(dst ? dst->dev : NULL, daddr, saddr);
 }
 
 
@@ -3042,7 +3029,7 @@
 			addrconf_forward_change();
 		}
 		if (*valp)
-			rt6_purge_dflt_routers(0);
+			rt6_purge_dflt_routers();
 	}
 
         return ret;
@@ -3096,7 +3083,7 @@
 		}
 
 		if (*valp)
-			rt6_purge_dflt_routers(0);
+			rt6_purge_dflt_routers();
 	} else
 		*valp = new;
 
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-10-26 13:12:42 +09:00
+++ b/net/ipv6/ndisc.c	2004-10-26 13:12:42 +09:00
@@ -396,7 +396,7 @@
 		src_addr = solicited_addr;
 		in6_ifa_put(ifp);
 	} else {
-		if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr, 0))
+		if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr))
 			return;
 		src_addr = &tmpaddr;
 	}
@@ -1026,7 +1026,7 @@
 		 *	delete it
 		 */
 
-		rt6_purge_dflt_routers(0);
+		rt6_purge_dflt_routers();
 	}
 
 	if (rt)
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-10-26 13:12:42 +09:00
+++ b/net/ipv6/route.c	2004-10-26 13:12:42 +09:00
@@ -1288,17 +1288,14 @@
 	return rt6_get_dflt_router(gwaddr, dev);
 }
 
-void rt6_purge_dflt_routers(int last_resort)
+void rt6_purge_dflt_routers(void)
 {
 	struct rt6_info *rt;
-	u32 flags;
-
-	flags = RTF_DEFAULT | RTF_ADDRCONF;	
 
 restart:
 	read_lock_bh(&rt6_lock);
 	for (rt = ip6_routing_table.leaf; rt; rt = rt->u.next) {
-		if (rt->rt6i_flags & flags) {
+		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) {
 			dst_hold(&rt->u.dst);
 
 			rt6_reset_dflt_pointer(NULL);

ChangeSet@1.2179, 2004-10-26 12:55:56+09:00, yoshfuji@linux-ipv6.org
 [IPV6] NDISC: update neighbor cache entry by RS.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/ndisc.h b/include/net/ndisc.h
--- a/include/net/ndisc.h	2004-10-26 13:12:46 +09:00
+++ b/include/net/ndisc.h	2004-10-26 13:12:46 +09:00
@@ -45,6 +45,11 @@
 	__u8		opt[0];
 };
 
+struct rs_msg {
+	struct icmp6hdr	icmph;
+	__u8		opt[0];
+};
+
 struct ra_msg {
         struct icmp6hdr		icmph;
 	__u32			reachable_time;
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-10-26 13:12:46 +09:00
+++ b/net/ipv6/ndisc.c	2004-10-26 13:12:46 +09:00
@@ -921,6 +921,64 @@
 	}
 }
 
+static void ndisc_recv_rs(struct sk_buff *skb)
+{
+	struct rs_msg *rs_msg = (struct rs_msg *) skb->h.raw;
+	unsigned long ndoptlen = skb->len - sizeof(*rs_msg);
+	struct neighbour *neigh;
+	struct inet6_dev *idev;
+	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;
+	struct ndisc_options ndopts;
+	u8 *lladdr = NULL;
+	int lladdrlen = 0;
+
+	if (skb->len < sizeof(*rs_msg))
+		return;
+
+	idev = in6_dev_get(skb->dev);
+	if (!idev) {
+		if (net_ratelimit())
+			ND_PRINTK1("ICMP6 RS: can't find in6 device\n");
+		return;
+	}
+
+	/* Don't accept RS if we're not in router mode */
+	if (!idev->cnf.forwarding || idev->cnf.accept_ra)
+		goto out;
+
+	/*
+	 * Don't update NCE if src = ::;
+	 * this implies that the source node has no ip address assigned yet.
+	 */
+	if (ipv6_addr_any(saddr))
+		goto out;
+
+	/* Parse ND options */
+	if (!ndisc_parse_options(rs_msg->opt, ndoptlen, &ndopts)) {
+		if (net_ratelimit())
+			ND_PRINTK2("ICMP6 NS: invalid ND option, ignored\n");
+		goto out;
+	}
+
+	if (ndopts.nd_opts_src_lladdr) {
+		lladdr = (u8 *)(ndopts.nd_opts_src_lladdr + 1);
+		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
+		if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len))
+			goto out;
+	}
+
+	neigh = __neigh_lookup(&nd_tbl, saddr, skb->dev, 1);
+	if (neigh) {
+		neigh_update(neigh, lladdr, NUD_STALE,
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
+			     NEIGH_UPDATE_F_OVERRIDE|
+			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER);
+		neigh_release(neigh);
+	}
+out:
+	in6_dev_put(idev);
+}
+
 static void ndisc_router_discovery(struct sk_buff *skb)
 {
         struct ra_msg *ra_msg = (struct ra_msg *) skb->h.raw;
@@ -1393,6 +1451,10 @@
 
 	case NDISC_NEIGHBOUR_ADVERTISEMENT:
 		ndisc_recv_na(skb);
+		break;
+
+	case NDISC_ROUTER_SOLICITATION:
+		ndisc_recv_rs(skb);
 		break;
 
 	case NDISC_ROUTER_ADVERTISEMENT:

ChangeSet@1.2180, 2004-10-26 13:11:47+09:00, yoshfuji@linux-ipv6.org
 [IPV6] kill a warning when building without CONFIG_SYSCTL.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-10-26 13:12:51 +09:00
+++ b/net/ipv6/addrconf.c	2004-10-26 13:12:51 +09:00
@@ -404,6 +404,7 @@
 	return idev;
 }
 
+#ifdef CONFIG_SYSCTL
 static void dev_forward_change(struct inet6_dev *idev)
 {
 	struct net_device *dev;
@@ -449,7 +450,7 @@
 	}
 	read_unlock(&dev_base_lock);
 }
-
+#endif
 
 /* Nobody refers to this ifaddr, destroy it */
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
