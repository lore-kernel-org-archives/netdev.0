From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Wed, 25 Jun 2003 10:02:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EF9D5C2.5080101@us.ibm.com>
References: <3EF37458.3070103@us.ibm.com> <20030621.233634.67057417.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030621.233634.67057417.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Yoshfuji,

 > Rename inet6_dump_fib() to __inet6_dump_fib() and introduce

OK, done.

 > Hmm, what I expected is to get information via RTA_NEWLINK message.

I have made changes to return per interface flags, however I am not very
familiar with netlink and it's different interfaces. I wanted to clarify whether
the following code is what you are trying to get done. Otherwise please let me
know what changes need to be done. What I want to happen is :
	1. Return entire prefix list on request from user.
	2. Return flags for a particular interface on request from user.
What I have not yet done is to broadcast events when a new prefix arrives or
an existing prefix gets expired, and to broadcast flags when an RA is received.
Currently there is no need for these from DHCP, but it could be added later on.

 >>    #devices  #iteration for each dev  plist on IDEV    plist in RTTABLE     %
 >>     200          100                   3.95 secs        40.14 secs          916%
 > Well, what should we do...

The original code, though faster, you have more code as dave said in his initial
mail. I think this operation is not done too often to be concerned about
performance. Besides it is taking 40 secs to iterate 20,000 times over a 4K
routing table, effectively about 2ms for getting the prefix list for one device.
And for most systems, this is not an issue since this code will not run at all.

Thanks,

- KK

diff -ruN linux-2.5.70.org/include/linux/ipv6_route.h
linux-2.5.70.new/include/linux/ipv6_route.h
--- linux-2.5.70.org/include/linux/ipv6_route.h	2003-05-26 18:00:25.000000000 -0700
+++ linux-2.5.70.new/include/linux/ipv6_route.h	2003-06-24 04:36:39.000000000 -0700
@@ -44,4 +44,19 @@
   #define RTMSG_NEWROUTE		0x21
   #define RTMSG_DELROUTE		0x22

+#ifdef CONFIG_IPV6_PREFIXLIST
+
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
+#endif
+
   #endif
diff -ruN linux-2.5.70.org/include/linux/rtnetlink.h
linux-2.5.70.new/include/linux/rtnetlink.h
--- linux-2.5.70.org/include/linux/rtnetlink.h	2003-05-26 18:00:46.000000000 -0700
+++ linux-2.5.70.new/include/linux/rtnetlink.h	2003-06-24 04:39:59.000000000 -0700
@@ -47,7 +47,14 @@
   #define	RTM_DELTFILTER	(RTM_BASE+29)
   #define	RTM_GETTFILTER	(RTM_BASE+30)

-#define	RTM_MAX		(RTM_BASE+31)
+#define	RTM_GETLNKFLAGS	(RTM_BASE+34)
+
+#ifndef CONFIG_IPV6_PREFIXLIST
+#define	RTM_MAX		(RTM_GETLNKFLAGS+1)
+#else
+#define	RTM_GETPLIST	(RTM_BASE+38)
+#define	RTM_MAX		(RTM_GETPLIST+1)
+#endif

   /*
      Generic structure for encapsulation optional route information.
@@ -61,6 +68,14 @@
   	unsigned short	rta_type;
   };

+/* Structure to return per interface device flags */
+
+struct ifp_if6info
+{
+	int ifindex;
+	int flags;
+};
+
   /* Macros to handle rtattributes */

   #define RTA_ALIGNTO	4
@@ -201,9 +216,11 @@
   	RTA_FLOW,
   	RTA_CACHEINFO,
   	RTA_SESSION,
+	RTA_LINKFLAGS,
+	RTA_RA6INFO,	/* No support yet, send event on new prefix event */
   };

-#define RTA_MAX RTA_SESSION
+#define RTA_MAX RTA_RA6INFO

   #define RTM_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct
rtmsg))))
   #define RTM_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct rtmsg))
diff -ruN linux-2.5.70.org/include/net/if_inet6.h
linux-2.5.70.new/include/net/if_inet6.h
--- linux-2.5.70.org/include/net/if_inet6.h	2003-05-26 18:00:59.000000000 -0700
+++ linux-2.5.70.new/include/net/if_inet6.h	2003-06-19 05:42:08.000000000 -0700
@@ -17,6 +17,8 @@

   #include <net/snmp.h>

+#define IF_RA_OTHERCONF	0x80
+#define IF_RA_MANAGED	0x40
   #define IF_RA_RCVD	0x20
   #define IF_RS_SENT	0x10

diff -ruN linux-2.5.70.org/include/net/ip6_route.h
linux-2.5.70.new/include/net/ip6_route.h
--- linux-2.5.70.org/include/net/ip6_route.h	2003-05-26 18:00:26.000000000 -0700
+++ linux-2.5.70.new/include/net/ip6_route.h	2003-06-23 02:59:06.000000000 -0700
@@ -87,6 +87,7 @@
   struct nlmsghdr;
   struct netlink_callback;
   extern int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb);
+extern int inet6_dump_prefix(struct sk_buff *skb, struct netlink_callback *cb);
   extern int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void
*arg);
   extern int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void
*arg);
   extern int inet6_rtm_getroute(struct sk_buff *skb, struct nlmsghdr* nlh, void
*arg);
diff -ruN linux-2.5.70.org/net/ipv6/Kconfig linux-2.5.70.new/net/ipv6/Kconfig
--- linux-2.5.70.org/net/ipv6/Kconfig	2003-05-26 18:00:40.000000000 -0700
+++ linux-2.5.70.new/net/ipv6/Kconfig	2003-06-19 05:37:11.000000000 -0700
@@ -42,4 +42,13 @@

   	  If unsure, say Y.

+config IPV6_PREFIXLIST
+	bool "IPv6: Prefix List"
+	depends on IPV6
+	---help---
+	  For applications needing to retrieve the list of prefixes supported
+	  on the system. Defined in RFC2461.
+
+	  If unsure, say Y.
+
   source "net/ipv6/netfilter/Kconfig"
diff -ruN linux-2.5.70.org/net/ipv6/addrconf.c linux-2.5.70.new/net/ipv6/addrconf.c
--- linux-2.5.70.org/net/ipv6/addrconf.c	2003-05-26 18:00:58.000000000 -0700
+++ linux-2.5.70.new/net/ipv6/addrconf.c	2003-06-24 04:40:05.000000000 -0700
@@ -124,7 +124,7 @@

   static int addrconf_ifdown(struct net_device *dev, int how);

-static void addrconf_dad_start(struct inet6_ifaddr *ifp);
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags);
   static void addrconf_dad_timer(unsigned long data);
   static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
   static void addrconf_rs_timer(unsigned long data);
@@ -738,7 +738,7 @@
   	ift->prefered_lft = tmp_prefered_lft;
   	ift->tstamp = ifp->tstamp;
   	spin_unlock_bh(&ift->lock);
-	addrconf_dad_start(ift);
+	addrconf_dad_start(ift, 0);
   	in6_ifa_put(ift);
   	in6_dev_put(idev);
   out:
@@ -1234,7 +1234,7 @@
   	rtmsg.rtmsg_dst_len = 8;
   	rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
   	rtmsg.rtmsg_ifindex = dev->ifindex;
-	rtmsg.rtmsg_flags = RTF_UP|RTF_ADDRCONF;
+	rtmsg.rtmsg_flags = RTF_UP;
   	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
   	ip6_route_add(&rtmsg, NULL, NULL);
   }
@@ -1261,7 +1261,7 @@
   	struct in6_addr addr;

   	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
-	addrconf_prefix_route(&addr, 64, dev, 0, RTF_ADDRCONF);
+	addrconf_prefix_route(&addr, 64, dev, 0, 0);
   }

   static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
@@ -1401,7 +1401,7 @@
   			}

   			create = 1;
-			addrconf_dad_start(ifp);
+			addrconf_dad_start(ifp, RTF_ADDRCONF);
   		}

   		if (ifp && valid_lft == 0) {
@@ -1552,7 +1552,7 @@

   	ifp = ipv6_add_addr(idev, pfx, plen, scope, IFA_F_PERMANENT);
   	if (!IS_ERR(ifp)) {
-		addrconf_dad_start(ifp);
+		addrconf_dad_start(ifp, 0);
   		in6_ifa_put(ifp);
   		return 0;
   	}
@@ -1727,7 +1727,7 @@

   	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
   	if (!IS_ERR(ifp)) {
-		addrconf_dad_start(ifp);
+		addrconf_dad_start(ifp, 0);
   		in6_ifa_put(ifp);
   	}
   }
@@ -1965,8 +1965,7 @@
   		memset(&rtmsg, 0, sizeof(struct in6_rtmsg));
   		rtmsg.rtmsg_type = RTMSG_NEWROUTE;
   		rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
-		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_ADDRCONF |
-				     RTF_DEFAULT | RTF_UP);
+		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_DEFAULT | RTF_UP);

   		rtmsg.rtmsg_ifindex = ifp->idev->dev->ifindex;

@@ -1980,7 +1979,7 @@
   /*
    *	Duplicate Address Detection
    */
-static void addrconf_dad_start(struct inet6_ifaddr *ifp)
+static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags)
   {
   	struct net_device *dev;
   	unsigned long rand_num;
@@ -1990,7 +1989,7 @@
   	addrconf_join_solict(dev, &ifp->addr);

   	if (ifp->prefix_len != 128 && (ifp->flags&IFA_F_PERMANENT))
-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0, RTF_ADDRCONF);
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0, flags);

   	net_srandom(ifp->addr.s6_addr32[3]);
   	rand_num = net_random() % (ifp->idev->cnf.rtr_solicit_delay ? : 1);
@@ -2389,6 +2388,43 @@
   	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_IFADDR, GFP_ATOMIC);
   }

+int inet6_dump_linkflags(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int ifindex, flags = 0;
+	struct net_device *dev;
+	struct inet6_dev *idev;
+	struct nlmsghdr *nlh;
+	struct ifp_if6info *ifp = NLMSG_DATA(cb->nlh);
+	unsigned char *org_tail = skb->tail;
+
+	/* ifindex = cb->args[0]; ? */
+	ifindex = ifp->ifindex;
+
+	if ((dev = dev_get_by_index(ifindex)) == NULL)
+		goto out;
+	if ((idev = in6_dev_get(dev)) != NULL) {
+		flags = idev->if_flags;
+		in6_dev_put(idev);
+	}
+	dev_put(dev);
+
+	nlh = NLMSG_PUT(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+			RTA_LINKFLAGS, sizeof(*ifp));
+	ifp = NLMSG_DATA(nlh);
+	ifp->flags = flags;
+	ifp->ifindex = ifindex;	/* duplicate information for user to verify */
+
+	nlh->nlmsg_len = skb->tail - org_tail;
+	return skb->len;
+
+nlmsg_failure:
+	printk(KERN_INFO "inet6_dump_linkflags:skb size not enough\n");
+	skb_trim(skb, org_tail - skb->data);
+
+out:
+	return -1;
+}
+
   static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
   	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
   	[RTM_DELADDR - RTM_BASE] = { .doit	= inet6_rtm_deladdr, },
@@ -2397,6 +2433,10 @@
   	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet6_rtm_delroute, },
   	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet6_rtm_getroute,
   				      .dumpit	= inet6_dump_fib, },
+	[RTM_GETLNKFLAGS - RTM_BASE] = { .dumpit = inet6_dump_linkflags, },
+#ifdef CONFIG_IPV6_PREFIXLIST
+	[RTM_GETPLIST - RTM_BASE] = { .dumpit	= inet6_dump_prefix, },
+#endif
   };

   static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
@@ -2730,7 +2770,7 @@
   #ifdef CONFIG_PROC_FS
   	proc_net_create("if_inet6", 0, iface_proc_info);
   #endif
-	
+
   	addrconf_verify(0);
   	rtnetlink_links[PF_INET6] = inet6_rtnetlink_table;
   #ifdef CONFIG_SYSCTL
diff -ruN linux-2.5.70.org/net/ipv6/ndisc.c linux-2.5.70.new/net/ipv6/ndisc.c
--- linux-2.5.70.org/net/ipv6/ndisc.c	2003-05-26 18:00:41.000000000 -0700
+++ linux-2.5.70.new/net/ipv6/ndisc.c	2003-06-24 04:09:30.000000000 -0700
@@ -1049,6 +1049,16 @@
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

diff -ruN linux-2.5.70.org/net/ipv6/route.c linux-2.5.70.new/net/ipv6/route.c
--- linux-2.5.70.org/net/ipv6/route.c	2003-05-26 18:00:45.000000000 -0700
+++ linux-2.5.70.new/net/ipv6/route.c	2003-06-23 02:46:42.000000000 -0700
@@ -1520,6 +1520,68 @@
   	return 0;
   }

+#ifdef CONFIG_IPV6_PREFIXLIST
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
+#endif
+
   static void fib6_dump_end(struct netlink_callback *cb)
   {
   	struct fib6_walker_t *w = (void*)cb->args[0];
@@ -1541,12 +1603,17 @@
   	return cb->done(cb);
   }

-int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
+static int __inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb,
+			int prefix)
   {
   	struct rt6_rtnl_dump_arg arg;
   	struct fib6_walker_t *w;
   	int res;

+#ifndef CONFIG_IPV6_PREFIXLIST
+	BUG_TRAP(prefix == 0);
+#endif
+
   	arg.skb = skb;
   	arg.cb = cb;

@@ -1568,7 +1635,12 @@
   		RT6_TRACE("dump<%p", w);
   		memset(w, 0, sizeof(*w));
   		w->root = &ip6_routing_table;
-		w->func = fib6_dump_node;
+		if (prefix == 0)
+			w->func = fib6_dump_node;
+#ifdef CONFIG_IPV6_PREFIXLIST
+		else
+			w->func = fib6_dump_prefix;
+#endif
   		w->args = &arg;
   		cb->args[0] = (long)w;
   		read_lock_bh(&rt6_lock);
@@ -1595,6 +1667,16 @@
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
