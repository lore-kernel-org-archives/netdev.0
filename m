From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH 1/2] Prefix List against 2.5.73
Date: Wed, 16 Jul 2003 11:42:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307161128520.1972-100000@DYN318430.beaverton.ibm.com>
References: <20030716.173926.81875946.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <davem@redhat.com>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030716.173926.81875946.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

> > Select yourself: either IFA_IFFLAGS or translated flags in ifa_flags.
> > I prefer the second way just because it is too unpleasant to add
> > a new attribute for sake of two bits with no visible candidates
> > to use remaining ones.
>
> Well, I dislike ifa_flags because
>  - it is conceptually wrong to combine them.
>    e.g. even if all autoconf addresses expired, flags lasts and
>    we should report it to userspace.
>  - ifa_flags is extremely expensive resource.
>    There are only 8 bits. Use it only for addresses.

Well, I tend to agree with Alexey since we don't need a lot of extra data
support for providing 2 bits. The advantage with this approach is that the
unmodified ip util can display the flags correctly after it removes the
address specific flags. Going by the other approach, we need to support a
new type to get this information (IFA_IFFLAGS). If number of bits is
considered important, then it is possible to just return the 6 bits
(ignore the RS* bits). I feel this is less complicated of the two ways.

So at this time, I am sending the patch for 2.5.73 (is this too old ?)
using Alexey's suggestion. Patch follows for 2.4.21.

Thanks,

- KK

diff -ruN linux-2.5.73.org/include/linux/ipv6_route.h test/linux-2.5.73/include/linux/ipv6_route.h
--- linux-2.5.73.org/include/linux/ipv6_route.h	2003-06-22 11:32:36.000000000 -0700
+++ test/linux-2.5.73/include/linux/ipv6_route.h	2003-07-15 10:38:31.000000000 -0700
@@ -16,6 +16,7 @@
 #define RTF_DEFAULT	0x00010000	/* default - learned via ND	*/
 #define RTF_ALLONLINK	0x00020000	/* fallback, no routers on link	*/
 #define RTF_ADDRCONF	0x00040000	/* addrconf route - RA		*/
+#define RTF_PREFIX_RT	0x00080000	/* A prefix only route - RA	*/

 #define RTF_NONEXTHOP	0x00200000	/* route with no nexthop	*/
 #define RTF_EXPIRES	0x00400000
@@ -44,4 +45,16 @@
 #define RTMSG_NEWROUTE		0x21
 #define RTMSG_DELROUTE		0x22

+/*
+ * Return entire prefix list in array of following structures. Provides the
+ * prefix and prefix length for all devices.
+ */
+
+struct in6_prefix_msg
+{
+	int ifindex;
+	int prefix_len;
+	struct in6_addr prefix;
+};
+
 #endif
diff -ruN linux-2.5.73.org/include/linux/rtnetlink.h test/linux-2.5.73/include/linux/rtnetlink.h
--- linux-2.5.73.org/include/linux/rtnetlink.h	2003-06-22 11:33:07.000000000 -0700
+++ test/linux-2.5.73/include/linux/rtnetlink.h	2003-07-16 10:58:19.000000000 -0700
@@ -168,6 +168,7 @@
 #define RTM_F_NOTIFY		0x100	/* Notify user of route change	*/
 #define RTM_F_CLONED		0x200	/* This route is cloned		*/
 #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
+#define RTM_F_PREFIX		0x800	/* Prefix addresses		*/

 /* Reserved table identifiers */

diff -ruN linux-2.5.73.org/include/net/if_inet6.h test/linux-2.5.73/include/net/if_inet6.h
--- linux-2.5.73.org/include/net/if_inet6.h	2003-06-22 11:33:32.000000000 -0700
+++ test/linux-2.5.73/include/net/if_inet6.h	2003-07-16 09:55:25.000000000 -0700
@@ -17,7 +17,9 @@

 #include <net/snmp.h>

-#define IF_RA_RCVD	0x20
+#define IF_RA_OTHERCONF	0x02
+#define IF_RA_MANAGED	0x04
+#define IF_RA_RCVD	0x08
 #define IF_RS_SENT	0x10

 #ifdef __KERNEL__
diff -ruN linux-2.5.73.org/net/ipv6/addrconf.c test/linux-2.5.73/net/ipv6/addrconf.c
--- linux-2.5.73.org/net/ipv6/addrconf.c	2003-06-22 11:33:17.000000000 -0700
+++ test/linux-2.5.73/net/ipv6/addrconf.c	2003-07-16 11:01:10.000000000 -0700
@@ -129,7 +129,7 @@

 static int addrconf_ifdown(struct net_device *dev, int how);

-static void addrconf_dad_start(struct inet6_ifaddr *ifp);
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags);
 static void addrconf_dad_timer(unsigned long data);
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
 static void addrconf_rs_timer(unsigned long data);
@@ -715,7 +715,7 @@
 	ift->prefered_lft = tmp_prefered_lft;
 	ift->tstamp = ifp->tstamp;
 	spin_unlock_bh(&ift->lock);
-	addrconf_dad_start(ift);
+	addrconf_dad_start(ift, 0);
 	in6_ifa_put(ift);
 	in6_dev_put(idev);
 out:
@@ -1211,7 +1211,7 @@
 	rtmsg.rtmsg_dst_len = 8;
 	rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
 	rtmsg.rtmsg_ifindex = dev->ifindex;
-	rtmsg.rtmsg_flags = RTF_UP|RTF_ADDRCONF;
+	rtmsg.rtmsg_flags = RTF_UP;
 	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
 	ip6_route_add(&rtmsg, NULL, NULL);
 }
@@ -1238,7 +1238,7 @@
 	struct in6_addr addr;

 	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
-	addrconf_prefix_route(&addr, 64, dev, 0, RTF_ADDRCONF);
+	addrconf_prefix_route(&addr, 64, dev, 0, 0);
 }

 static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
@@ -1330,7 +1330,8 @@
 		}
 	} else if (pinfo->onlink && valid_lft) {
 		addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
-				      dev, rt_expires, RTF_ADDRCONF|RTF_EXPIRES);
+				      dev, rt_expires,
+				      RTF_ADDRCONF|RTF_EXPIRES|RTF_PREFIX_RT);
 	}
 	if (rt)
 		dst_release(&rt->u.dst);
@@ -1378,7 +1379,7 @@
 			}

 			create = 1;
-			addrconf_dad_start(ifp);
+			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
 		}

 		if (ifp && valid_lft == 0) {
@@ -1529,7 +1530,7 @@

 	ifp = ipv6_add_addr(idev, pfx, plen, scope, IFA_F_PERMANENT);
 	if (!IS_ERR(ifp)) {
-		addrconf_dad_start(ifp);
+		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 		return 0;
 	}
@@ -1704,7 +1705,7 @@

 	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
 	if (!IS_ERR(ifp)) {
-		addrconf_dad_start(ifp);
+		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 	}
 }
@@ -1943,8 +1944,7 @@
 		memset(&rtmsg, 0, sizeof(struct in6_rtmsg));
 		rtmsg.rtmsg_type = RTMSG_NEWROUTE;
 		rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
-		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_ADDRCONF |
-				     RTF_DEFAULT | RTF_UP);
+		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_DEFAULT | RTF_UP);

 		rtmsg.rtmsg_ifindex = ifp->idev->dev->ifindex;

@@ -1958,7 +1958,7 @@
 /*
  *	Duplicate Address Detection
  */
-static void addrconf_dad_start(struct inet6_ifaddr *ifp)
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags)
 {
 	struct net_device *dev;
 	unsigned long rand_num;
@@ -1968,7 +1968,7 @@
 	addrconf_join_solict(dev, &ifp->addr);

 	if (ifp->prefix_len != 128 && (ifp->flags&IFA_F_PERMANENT))
-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0, RTF_ADDRCONF);
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0, flags);

 	net_srandom(ifp->addr.s6_addr32[3]);
 	rand_num = net_random() % (ifp->idev->cnf.rtr_solicit_delay ? : 1);
@@ -2368,7 +2368,7 @@
 	ifm = NLMSG_DATA(nlh);
 	ifm->ifa_family = AF_INET6;
 	ifm->ifa_prefixlen = ifa->prefix_len;
-	ifm->ifa_flags = ifa->flags;
+	ifm->ifa_flags = ifa->flags | ifa->idev->if_flags;
 	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
 	if (ifa->scope&IFA_HOST)
 		ifm->ifa_scope = RT_SCOPE_HOST;
diff -ruN linux-2.5.73.org/net/ipv6/ndisc.c test/linux-2.5.73/net/ipv6/ndisc.c
--- linux-2.5.73.org/net/ipv6/ndisc.c	2003-06-22 11:32:56.000000000 -0700
+++ test/linux-2.5.73/net/ipv6/ndisc.c	2003-07-14 15:06:14.000000000 -0700
@@ -1036,6 +1036,16 @@
 		 */
 		in6_dev->if_flags |= IF_RA_RCVD;
 	}
+	/*
+	 * Remember the managed/otherconf flags from most recently
+	 * receieved RA message (RFC 2462) -- yoshfuji
+	 */
+	in6_dev->if_flags = (in6_dev->if_flags & ~(IF_RA_MANAGED|
+				IF_RA_OTHERCONF)) |
+				(ra_msg->icmph.icmp6_addrconf_managed ?
+					IF_RA_MANAGED : 0) |
+				(ra_msg->icmph.icmp6_addrconf_other ?
+					IF_RA_OTHERCONF : 0);

 	lifetime = ntohs(ra_msg->icmph.icmp6_rt_lifetime);

diff -ruN linux-2.5.73.org/net/ipv6/route.c test/linux-2.5.73/net/ipv6/route.c
--- linux-2.5.73.org/net/ipv6/route.c	2003-06-22 11:33:05.000000000 -0700
+++ test/linux-2.5.73/net/ipv6/route.c	2003-07-16 10:42:01.000000000 -0700
@@ -1400,13 +1400,20 @@
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
+
 	if (!pid && in_nlh) {
 		pid = in_nlh->nlmsg_pid;
 	}
@@ -1487,10 +1494,16 @@
 static int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
+	struct rtmsg *rtm;
+	int prefix;

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
@@ -1638,7 +1651,7 @@
 			    &fl.fl6_dst, &fl.fl6_src,
 			    iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
-			    nlh->nlmsg_seq, nlh);
+			    nlh->nlmsg_seq, nlh, 0);
 	if (err < 0) {
 		err = -EMSGSIZE;
 		goto out_free;
@@ -1664,7 +1677,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_ROUTE, ENOBUFS);
 		return;
 	}
-	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, 0, 0, nlh) < 0) {
+	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, 0, 0, nlh, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_ROUTE, EINVAL);
 		return;
