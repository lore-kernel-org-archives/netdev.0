From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] Prefix List against 2.4.21
Date: Tue, 22 Jul 2003 16:52:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307221650530.14683-100000@DYN318430.beaverton.ibm.com>
References: <200307210155.FAA31320@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307210155.FAA31320@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The same patch against 2.4.21.

thanks,

- KK

------------------------------------------------------------------------------

diff -ruN linux-2.4.21.org/include/linux/ipv6_route.h linux-2.4.21.new/include/linux/ipv6_route.h
--- linux-2.4.21.org/include/linux/ipv6_route.h	1998-08-27 19:33:08.000000000 -0700
+++ linux-2.4.21.new/include/linux/ipv6_route.h	2003-07-22 15:08:07.000000000 -0700
@@ -25,6 +25,7 @@
 #define RTF_DEFAULT	0x00010000	/* default - learned via ND	*/
 #define RTF_ALLONLINK	0x00020000	/* fallback, no routers on link	*/
 #define RTF_ADDRCONF	0x00040000	/* addrconf route - RA		*/
+#define RTF_PREFIX_RT	0x00080000	/* A prefix only route - RA	*/

 #define RTF_NONEXTHOP	0x00200000	/* route with no nexthop	*/
 #define RTF_EXPIRES	0x00400000
diff -ruN linux-2.4.21.org/include/linux/rtnetlink.h linux-2.4.21.new/include/linux/rtnetlink.h
--- linux-2.4.21.org/include/linux/rtnetlink.h	2002-11-28 15:53:15.000000000 -0800
+++ linux-2.4.21.new/include/linux/rtnetlink.h	2003-07-22 15:08:35.000000000 -0700
@@ -167,6 +167,7 @@
 #define RTM_F_NOTIFY		0x100	/* Notify user of route change	*/
 #define RTM_F_CLONED		0x200	/* This route is cloned		*/
 #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
+#define RTM_F_PREFIX		0x800	/* Prefix addresses		*/

 /* Reserved table identifiers */

diff -ruN linux-2.4.21.org/net/ipv6/addrconf.c linux-2.4.21.new/net/ipv6/addrconf.c
--- linux-2.4.21.org/net/ipv6/addrconf.c	2003-06-13 07:51:39.000000000 -0700
+++ linux-2.4.21.new/net/ipv6/addrconf.c	2003-07-22 15:13:53.000000000 -0700
@@ -101,7 +101,7 @@

 static int addrconf_ifdown(struct net_device *dev, int how);

-static void addrconf_dad_start(struct inet6_ifaddr *ifp);
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags);
 static void addrconf_dad_timer(unsigned long data);
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
 static void addrconf_rs_timer(unsigned long data);
@@ -889,7 +889,7 @@
 	rtmsg.rtmsg_dst_len = 8;
 	rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
 	rtmsg.rtmsg_ifindex = dev->ifindex;
-	rtmsg.rtmsg_flags = RTF_UP|RTF_ADDRCONF;
+	rtmsg.rtmsg_flags = RTF_UP;
 	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
 	ip6_route_add(&rtmsg, NULL);
 }
@@ -916,7 +916,7 @@
 	struct in6_addr addr;

 	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
-	addrconf_prefix_route(&addr, 64, dev, 0, RTF_ADDRCONF);
+	addrconf_prefix_route(&addr, 64, dev, 0, 0);
 }

 static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
@@ -1008,7 +1008,7 @@
 		}
 	} else if (pinfo->onlink && valid_lft) {
 		addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
-				      dev, rt_expires, RTF_ADDRCONF|RTF_EXPIRES);
+				      dev, rt_expires, RTF_ADDRCONF|RTF_EXPIRES|RTF_PREFIX_RT);
 	}
 	if (rt)
 		dst_release(&rt->u.dst);
@@ -1054,7 +1054,7 @@
 				return;
 			}

-			addrconf_dad_start(ifp);
+			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
 		}

 		if (ifp && valid_lft == 0) {
@@ -1166,7 +1166,7 @@

 	ifp = ipv6_add_addr(idev, pfx, plen, scope, IFA_F_PERMANENT);
 	if (!IS_ERR(ifp)) {
-		addrconf_dad_start(ifp);
+		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 		return 0;
 	}
@@ -1341,7 +1341,7 @@

 	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
 	if (!IS_ERR(ifp)) {
-		addrconf_dad_start(ifp);
+		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 	}
 }
@@ -1578,8 +1578,7 @@
 		memset(&rtmsg, 0, sizeof(struct in6_rtmsg));
 		rtmsg.rtmsg_type = RTMSG_NEWROUTE;
 		rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
-		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_ADDRCONF |
-				     RTF_DEFAULT | RTF_UP);
+		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_DEFAULT | RTF_UP);

 		rtmsg.rtmsg_ifindex = ifp->idev->dev->ifindex;

@@ -1593,7 +1592,7 @@
 /*
  *	Duplicate Address Detection
  */
-static void addrconf_dad_start(struct inet6_ifaddr *ifp)
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags)
 {
 	struct net_device *dev;
 	unsigned long rand_num;
@@ -1603,7 +1602,7 @@
 	addrconf_join_solict(dev, &ifp->addr);

 	if (ifp->prefix_len != 128 && (ifp->flags&IFA_F_PERMANENT))
-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0, RTF_ADDRCONF);
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0, flags);

 	net_srandom(ifp->addr.s6_addr32[3]);
 	rand_num = net_random() % (ifp->idev->cnf.rtr_solicit_delay ? : 1);
diff -ruN linux-2.4.21.org/net/ipv6/route.c linux-2.4.21.new/net/ipv6/route.c
--- linux-2.4.21.org/net/ipv6/route.c	2003-06-13 07:51:39.000000000 -0700
+++ linux-2.4.21.new/net/ipv6/route.c	2003-07-22 15:15:56.000000000 -0700
@@ -1516,13 +1516,19 @@
 			 struct in6_addr *src,
 			 int iif,
 			 int type, u32 pid, u32 seq,
-			 struct nlmsghdr *in_nlh)
+			 struct nlmsghdr *in_nlh, int prefix)
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 	struct rta_cacheinfo ci;

+	if (prefix) {	/* user wants prefix routes only */
+		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
+			/* success since this is not a prefix route */
+			return 1;
+		}
+	}
 	if (!pid && in_nlh) {
 		pid = in_nlh->nlmsg_pid;
 	}
@@ -1603,10 +1609,17 @@
 static int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
+	struct rtmsg *rtm;
+	int prefix;
+
+	rtm = NLMSG_DATA(arg->cb->nlh);
+	if (rtm)
+		prefix = (rtm->rtm_flags & RTM_F_PREFIX) != 0;
+	else prefix = 0;

 	return rt6_fill_node(arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).pid, arg->cb->nlh->nlmsg_seq,
-		     NULL);
+		     NULL, prefix);
 }

 static int fib6_dump_node(struct fib6_walker_t *w)
@@ -1757,7 +1770,7 @@
 			    fl.nl_u.ip6_u.saddr,
 			    iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
-			    nlh->nlmsg_seq, nlh);
+			    nlh->nlmsg_seq, nlh, 0);
 	if (err < 0) {
 		err = -EMSGSIZE;
 		goto out_free;
@@ -1783,7 +1796,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_ROUTE, ENOBUFS);
 		return;
 	}
-	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, 0, 0, nlh) < 0) {
+	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, 0, 0, nlh, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_ROUTE, EINVAL);
 		return;
