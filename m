From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH 4/4] Prefix List against 2.4.21
Date: Mon, 14 Jul 2003 15:43:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307141541340.5140-100000@DYN318430.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>,
   <kuznet@ms2.inr.ac.ru>, <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------------------ Prefix List against 2.4.21 ---------------------------
diff -ruN linux-2.4.21.org/include/linux/ipv6_route.h PATCHES/linux-2.4.21/include/linux/ipv6_route.h
--- linux-2.4.21.org/include/linux/ipv6_route.h	1998-08-27 19:33:08.000000000 -0700
+++ PATCHES/linux-2.4.21/include/linux/ipv6_route.h	2003-07-14 10:30:53.000000000 -0700
@@ -53,4 +53,16 @@
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
diff -ruN linux-2.4.21.org/include/linux/rtnetlink.h PATCHES/linux-2.4.21/include/linux/rtnetlink.h
--- linux-2.4.21.org/include/linux/rtnetlink.h	2002-11-28 15:53:15.000000000 -0800
+++ PATCHES/linux-2.4.21/include/linux/rtnetlink.h	2003-07-14 12:32:49.000000000 -0700
@@ -46,7 +46,9 @@
 #define	RTM_DELTFILTER	(RTM_BASE+29)
 #define	RTM_GETTFILTER	(RTM_BASE+30)

-#define	RTM_MAX		(RTM_BASE+31)
+#define	RTM_GETPLIST	(RTM_BASE+34)
+
+#define	RTM_MAX		(RTM_GETPLIST+1)

 /*
    Generic structure for encapsulation optional route information.
@@ -198,10 +200,11 @@
 	RTA_MULTIPATH,
 	RTA_PROTOINFO,
 	RTA_FLOW,
-	RTA_CACHEINFO
+	RTA_CACHEINFO,
+	RTA_RA6INFO,	/* No support yet, send event on new prefix event */
 };

-#define RTA_MAX RTA_CACHEINFO
+#define RTA_MAX RTA_RA6INFO

 #define RTM_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct rtmsg))))
 #define RTM_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct rtmsg))
diff -ruN linux-2.4.21.org/include/net/ip6_route.h PATCHES/linux-2.4.21/include/net/ip6_route.h
--- linux-2.4.21.org/include/net/ip6_route.h	2003-06-13 07:51:39.000000000 -0700
+++ PATCHES/linux-2.4.21/include/net/ip6_route.h	2003-07-14 12:49:45.000000000 -0700
@@ -84,6 +84,7 @@
 struct nlmsghdr;
 struct netlink_callback;
 extern int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb);
+extern int inet6_dump_prefix(struct sk_buff *skb, struct netlink_callback *cb);
 extern int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
 extern int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
 extern int inet6_rtm_getroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
diff -ruN linux-2.4.21.org/net/ipv6/addrconf.c PATCHES/linux-2.4.21/net/ipv6/addrconf.c
--- linux-2.4.21.org/net/ipv6/addrconf.c	2003-06-13 07:51:39.000000000 -0700
+++ PATCHES/linux-2.4.21/net/ipv6/addrconf.c	2003-07-14 12:21:50.000000000 -0700
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
@@ -1054,7 +1054,7 @@
 				return;
 			}

-			addrconf_dad_start(ifp);
+			addrconf_dad_start(ifp, RTF_ADDRCONF);
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
@@ -1987,6 +1986,36 @@
 	{ inet6_rtm_delroute,	NULL,			},
 	{ inet6_rtm_getroute,	inet6_dump_fib,		},
 	{ NULL,			NULL,			},
+
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+
+	{ NULL,			NULL,			},
+	{ NULL,			NULL,			},
+	{ NULL,			inet6_dump_prefix	},
+	{ NULL,			NULL,			},
 };

 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
diff -ruN linux-2.4.21.org/net/ipv6/route.c PATCHES/linux-2.4.21/net/ipv6/route.c
--- linux-2.4.21.org/net/ipv6/route.c	2003-06-13 07:51:39.000000000 -0700
+++ PATCHES/linux-2.4.21/net/ipv6/route.c	2003-07-14 10:30:53.000000000 -0700
@@ -1627,6 +1627,66 @@
 	return 0;
 }

+static int rt6_fill_prefix(struct sk_buff *skb, struct rt6_info *rt,
+			 int type, u32 pid, u32 seq)
+{
+	struct in6_prefix_msg *pmsg;
+	struct nlmsghdr  *nlh;
+	unsigned char *b = skb->tail;
+
+	nlh = NLMSG_PUT(skb, pid, seq, type, sizeof(*pmsg));
+	pmsg = NLMSG_DATA(nlh);
+	pmsg->ifindex = rt->rt6i_dev->ifindex;
+	pmsg->prefix_len = rt->rt6i_dst.plen;
+	ipv6_addr_copy(&pmsg->prefix, &rt->rt6i_dst.addr);
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+	printk(KERN_INFO "rt6_fill_prefix:skb size not enough\n");
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int rt6_dump_route_prefix(struct rt6_info *rt, void *p_arg)
+{
+	int addr_type;
+	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
+
+	/*
+	 * Definition of a prefix :
+	 * 	- Should be autoconfigured
+	 *	- No nexthop
+	 *	- Not a linklocal, loopback or multicast type.
+	 */
+	if (rt->rt6i_nexthop || (rt->rt6i_flags & RTF_ADDRCONF) == 0)
+		return 0;
+	addr_type = ipv6_addr_type(&rt->rt6i_dst.addr);
+	if ((addr_type & (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK |
+			IPV6_ADDR_MULTICAST)) != 0 ||
+			addr_type == IPV6_ADDR_ANY)
+		return 0;
+	return rt6_fill_prefix(arg->skb, rt, RTM_GETPLIST,
+		     NETLINK_CB(arg->cb->skb).pid, arg->cb->nlh->nlmsg_seq);
+}
+
+static int fib6_dump_prefix(struct fib6_walker_t *w)
+{
+	int res;
+	struct rt6_info *rt;
+
+	for (rt = w->leaf; rt; rt = rt->u.next) {
+		res = rt6_dump_route_prefix(rt, w->args);
+		if (res < 0) {
+			/* Frame is full, suspend walking */
+			w->leaf = rt;
+			return 1;
+		}
+	}
+	w->leaf = NULL;
+	return 0;
+}
+
 static void fib6_dump_end(struct netlink_callback *cb)
 {
 	struct fib6_walker_t *w = (void*)cb->args[0];
@@ -1648,7 +1708,8 @@
 	return cb->done(cb);
 }

-int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
+static int __inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb,
+			int prefix)
 {
 	struct rt6_rtnl_dump_arg arg;
 	struct fib6_walker_t *w;
@@ -1675,7 +1736,10 @@
 		RT6_TRACE("dump<%p", w);
 		memset(w, 0, sizeof(*w));
 		w->root = &ip6_routing_table;
-		w->func = fib6_dump_node;
+		if (prefix)
+			w->func = fib6_dump_prefix;
+		else
+			w->func = fib6_dump_node;
 		w->args = &arg;
 		cb->args[0] = (long)w;
 		read_lock_bh(&rt6_lock);
@@ -1702,6 +1766,16 @@
 	return res;
 }

+int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	return __inet6_dump_fib(skb, cb, 0);
+}
+
+int inet6_dump_prefix(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	return __inet6_dump_fib(skb, cb, 1);
+}
+
 int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct rtattr **rta = arg;
-----------------------------------------------------------------------------
