From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH 2/2] Prefix List and O/M flags against 2.5.73
Date: Mon, 21 Jul 2003 10:16:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307211006500.9924-100000@DYN318430.beaverton.ibm.com>
References: <20030721051733.2f2e9fb7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>, <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030721051733.2f2e9fb7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> Ok, I tried to apply this, but it had lots of rejects, here
> is why.
>
> > diff -ruN linux-2.5.73.org/net/ipv6/addrconf.c test/linux-2.5.73/net/ipv6/addrconf.c
> > --- linux-2.5.73.org/net/ipv6/addrconf.c	2003-06-22 11:33:17.000000000 -0700
> > +++ test/linux-2.5.73/net/ipv6/addrconf.c	2003-07-17 16:59:17.000000000 -0700
>  ...
> > @@ -1330,7 +1330,8 @@
> >  		}
> >  	} else if (pinfo->onlink && valid_lft) {
> >  		addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
>
> The "pinfo->onlink" part of this if test does not exist
> in the sources, so patch application failed.
>
> You're mixing this patch up with other changes in your
> tree already.

The problem happened since the patch was against 2.5.73, and this line
seems to have been changed sometime after that before 2.6.0. Following
is the prefix list (only) patch against 2.6.0-test1 bits.

Thanks,

- KK

-------------------------------------------------------------------------------

diff -ruN linux-2.6.0-test1.org/include/linux/ipv6_route.h linux-2.6.0-test1.new/include/linux/ipv6_route.h
--- linux-2.6.0-test1.org/include/linux/ipv6_route.h	2003-07-13 20:31:50.000000000 -0700
+++ linux-2.6.0-test1.new/include/linux/ipv6_route.h	2003-07-21 09:50:54.000000000 -0700
@@ -16,6 +16,7 @@
 #define RTF_DEFAULT	0x00010000	/* default - learned via ND	*/
 #define RTF_ALLONLINK	0x00020000	/* fallback, no routers on link	*/
 #define RTF_ADDRCONF	0x00040000	/* addrconf route - RA		*/
+#define RTF_PREFIX_RT	0x00080000	/* A prefix only route - RA	*/

 #define RTF_NONEXTHOP	0x00200000	/* route with no nexthop	*/
 #define RTF_EXPIRES	0x00400000
diff -ruN linux-2.6.0-test1.org/include/linux/rtnetlink.h linux-2.6.0-test1.new/include/linux/rtnetlink.h
--- linux-2.6.0-test1.org/include/linux/rtnetlink.h	2003-07-13 20:37:13.000000000 -0700
+++ linux-2.6.0-test1.new/include/linux/rtnetlink.h	2003-07-21 09:51:29.000000000 -0700
@@ -168,6 +168,7 @@
 #define RTM_F_NOTIFY		0x100	/* Notify user of route change	*/
 #define RTM_F_CLONED		0x200	/* This route is cloned		*/
 #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
+#define RTM_F_PREFIX		0x800	/* Prefix addresses		*/

 /* Reserved table identifiers */

diff -ruN linux-2.6.0-test1.org/net/ipv6/addrconf.c linux-2.6.0-test1.new/net/ipv6/addrconf.c
--- linux-2.6.0-test1.org/net/ipv6/addrconf.c	2003-07-13 20:38:06.000000000 -0700
+++ linux-2.6.0-test1.new/net/ipv6/addrconf.c	2003-07-21 09:56:19.000000000 -0700
@@ -130,7 +130,7 @@

 static int addrconf_ifdown(struct net_device *dev, int how);

-static void addrconf_dad_start(struct inet6_ifaddr *ifp);
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags);
 static void addrconf_dad_timer(unsigned long data);
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
 static void addrconf_rs_timer(unsigned long data);
@@ -716,7 +716,7 @@
 	ift->prefered_lft = tmp_prefered_lft;
 	ift->tstamp = ifp->tstamp;
 	spin_unlock_bh(&ift->lock);
-	addrconf_dad_start(ift);
+	addrconf_dad_start(ift, 0);
 	in6_ifa_put(ift);
 	in6_dev_put(idev);
 out:
@@ -1249,7 +1249,7 @@
 	rtmsg.rtmsg_dst_len = 8;
 	rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
 	rtmsg.rtmsg_ifindex = dev->ifindex;
-	rtmsg.rtmsg_flags = RTF_UP|RTF_ADDRCONF;
+	rtmsg.rtmsg_flags = RTF_UP;
 	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
 	ip6_route_add(&rtmsg, NULL, NULL);
 }
@@ -1276,7 +1276,7 @@
 	struct in6_addr addr;

 	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
-	addrconf_prefix_route(&addr, 64, dev, 0, RTF_ADDRCONF);
+	addrconf_prefix_route(&addr, 64, dev, 0, 0);
 }

 static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
@@ -1369,7 +1369,7 @@
 			}
 		} else if (valid_lft) {
 			addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
-					      dev, rt_expires, RTF_ADDRCONF|RTF_EXPIRES);
+					      dev, rt_expires, RTF_ADDRCONF|RTF_EXPIRES|RTF_PREFIX_RT);
 		}
 		if (rt)
 			dst_release(&rt->u.dst);
@@ -1415,7 +1415,7 @@
 			}

 			update_lft = create = 1;
-			addrconf_dad_start(ifp);
+			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
 		}

 		if (ifp) {
@@ -1588,7 +1588,7 @@

 	ifp = ipv6_add_addr(idev, pfx, plen, scope, IFA_F_PERMANENT);
 	if (!IS_ERR(ifp)) {
-		addrconf_dad_start(ifp);
+		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 		return 0;
 	}
@@ -1763,7 +1763,7 @@

 	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
 	if (!IS_ERR(ifp)) {
-		addrconf_dad_start(ifp);
+		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 	}
 }
@@ -2002,8 +2002,7 @@
 		memset(&rtmsg, 0, sizeof(struct in6_rtmsg));
 		rtmsg.rtmsg_type = RTMSG_NEWROUTE;
 		rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
-		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_ADDRCONF |
-				     RTF_DEFAULT | RTF_UP);
+		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_DEFAULT | RTF_UP);

 		rtmsg.rtmsg_ifindex = ifp->idev->dev->ifindex;

@@ -2017,7 +2016,7 @@
 /*
  *	Duplicate Address Detection
  */
-static void addrconf_dad_start(struct inet6_ifaddr *ifp)
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags)
 {
 	struct net_device *dev;
 	unsigned long rand_num;
@@ -2027,7 +2026,8 @@
 	addrconf_join_solict(dev, &ifp->addr);

 	if (ifp->prefix_len != 128 && (ifp->flags&IFA_F_PERMANENT))
-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0, RTF_ADDRCONF);
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0,
+					flags);

 	net_srandom(ifp->addr.s6_addr32[3]);
 	rand_num = net_random() % (ifp->idev->cnf.rtr_solicit_delay ? : 1);
diff -ruN linux-2.6.0-test1.org/net/ipv6/route.c linux-2.6.0-test1.new/net/ipv6/route.c
--- linux-2.6.0-test1.org/net/ipv6/route.c	2003-07-13 20:36:42.000000000 -0700
+++ linux-2.6.0-test1.new/net/ipv6/route.c	2003-07-21 09:58:11.000000000 -0700
@@ -1452,13 +1452,20 @@
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
@@ -1539,10 +1546,17 @@
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
@@ -1690,7 +1704,7 @@
 			    &fl.fl6_dst, &fl.fl6_src,
 			    iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
-			    nlh->nlmsg_seq, nlh);
+			    nlh->nlmsg_seq, nlh, 0);
 	if (err < 0) {
 		err = -EMSGSIZE;
 		goto out_free;
@@ -1716,7 +1730,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_ROUTE, ENOBUFS);
 		return;
 	}
-	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, 0, 0, nlh) < 0) {
+	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, 0, 0, nlh, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_ROUTE, EINVAL);
 		return;
