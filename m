From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Fri, 20 Jun 2003 13:53:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EF37458.3070103@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The earlier patch to implement the prefix list has been redone to use fib.
Following are the implementation details and a couple of issues :

1. I change the netlink_dump_start to pass another parameter, <type>, which is
    stored in a new field in the cb, <type>. All users of this function have been
    changed to pass a -1 since they don't care about the type, except the
    generic routine rtnetlink_rcv_msg() which calculates the type and stores it.
    So the same routine which is used to dump route table can be used to dump
    the prefix list by checking the type. It might be possible to derive the
    type from the table offset, but that is more complicated (probably doable).
2. Added yoshifuji's patch to store the M/O flags (now it is needed).
3. Added user interface for retrieving M/O flags. This is a separate interface
    from the one for getting the prefix list since the flags are per interface
    while the prefix list is per route. However these two can be merged into one
    if needed.
4. Changed the usage of RTF_ADDRCONF to be used only when the action is being
    performed due to receipt of a RA.
5. Though this patch is modified to use only routing table for updating and
    accessing the prefix list, I did a performace analysis for this approach vs
    storing the plist on the idev. Following is the result :

    System : 1 CPU. 866 MHz, 256MB memory
    For 1000 VLAN devices (4036 route entries gets created automatically as part
    of address assignment), retrieve prefix list for (system times only) :

    #devices  #iteration for each dev  plist on IDEV    plist in RTTABLE     %
    200          100                   3.95 secs        40.14 secs          916%
    1000         10                    2.60 secs        20.98 secs          706%
    200          1000                  38.44 secs       400.76 secs         942%

6. I have kept #ifdef PREFIXLIST in a few places, I can modify the patch to
    remove that if required.
7. I removed the /proc interface since I was not able to cleanly use seq_file
    with fib6_walk(). If needed, I can work on this later (but will need some
    input on how to proceed). So currently, the only user interface is using
    rtnetlink.
8. The patch can be extended to issue events on new prefix addition and on
    prefix deletion. I can do that if required.
9. I have tested using rtnetlink for both interfaces (prefix list and get O/M
    flags), no issues found.

Please let me know if this looks acceptable, in which case I can also send the 
patch for 2.4 kernel.

Thanks,

- KK

diff -ruN linux-2.5.70.org/include/linux/ipv6_route.h 
linux-2.5.70.new/include/linux/ipv6_route.h
--- linux-2.5.70.org/include/linux/ipv6_route.h	2003-05-26 18:00:25.000000000 -0700
+++ linux-2.5.70.new/include/linux/ipv6_route.h	2003-06-20 01:45:17.000000000 -0700
@@ -44,4 +44,16 @@
  #define RTMSG_NEWROUTE		0x21
  #define RTMSG_DELROUTE		0x22

+#ifdef CONFIG_IPV6_PREFIXLIST
+
+/* Structure to return prefix and prefix length for all devices */
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
diff -ruN linux-2.5.70.org/include/linux/netlink.h 
linux-2.5.70.new/include/linux/netlink.h
--- linux-2.5.70.org/include/linux/netlink.h	2003-05-26 18:00:56.000000000 -0700
+++ linux-2.5.70.new/include/linux/netlink.h	2003-06-20 05:00:47.000000000 -0700
@@ -132,6 +132,7 @@
  	int		(*dump)(struct sk_buff * skb, struct netlink_callback *cb);
  	int		(*done)(struct netlink_callback *cb);
  	int		family;
+	int		type;	/* for overloading functions */
  	long		args[4];
  };

@@ -161,7 +162,7 @@
     __nlmsg_put(skb, pid, seq, type, len); })

  extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
-			      struct nlmsghdr *nlh,
+			      struct nlmsghdr *nlh, int type,
  			      int (*dump)(struct sk_buff *skb, struct netlink_callback*),
  			      int (*done)(struct netlink_callback*));

diff -ruN linux-2.5.70.org/include/linux/rtnetlink.h 
linux-2.5.70.new/include/linux/rtnetlink.h
--- linux-2.5.70.org/include/linux/rtnetlink.h	2003-05-26 18:00:46.000000000 -0700
+++ linux-2.5.70.new/include/linux/rtnetlink.h	2003-06-20 01:36:19.000000000 -0700
@@ -47,7 +47,14 @@
  #define	RTM_DELTFILTER	(RTM_BASE+29)
  #define	RTM_GETTFILTER	(RTM_BASE+30)

-#define	RTM_MAX		(RTM_BASE+31)
+#define	RTM_GETOMFLAGS	(RTM_BASE+34)
+
+#ifndef CONFIG_IPV6_PREFIXLIST
+#define	RTM_MAX		(RTM_GETOMFLAGS+1)
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
@@ -201,9 +216,10 @@
  	RTA_FLOW,
  	RTA_CACHEINFO,
  	RTA_SESSION,
+	RTA_RA6INFO,	/* No support yet, send event on prefix event */
  };

-#define RTA_MAX RTA_SESSION
+#define RTA_MAX RTA_RA6INFO

  #define RTM_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct 
rtmsg))))
  #define RTM_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct rtmsg))
diff -ruN linux-2.5.70.org/include/net/if_inet6.h 
linux-2.5.70.new/include/net/if_inet6.h
--- linux-2.5.70.org/include/net/if_inet6.h	2003-05-26 18:00:59.000000000 -0700
+++ linux-2.5.70.new/include/net/if_inet6.h	2003-06-20 02:01:39.000000000 -0700
@@ -17,6 +17,9 @@

  #include <net/snmp.h>

+/* inet6_dev.if_flags */
+#define IF_RA_OTHERCONF	0x80
+#define IF_RA_MANAGED	0x40
  #define IF_RA_RCVD	0x20
  #define IF_RS_SENT	0x10

diff -ruN linux-2.5.70.org/net/core/rtnetlink.c 
linux-2.5.70.new/net/core/rtnetlink.c
--- linux-2.5.70.org/net/core/rtnetlink.c	2003-05-26 18:01:03.000000000 -0700
+++ linux-2.5.70.new/net/core/rtnetlink.c	2003-06-19 06:05:34.000000000 -0700
@@ -380,7 +380,7 @@
  		if (link->dumpit == NULL)
  			goto err_inval;

-		if ((*errp = netlink_dump_start(rtnl, skb, nlh,
+		if ((*errp = netlink_dump_start(rtnl, skb, nlh, type,
  						link->dumpit,
  						rtnetlink_done)) != 0) {
  			return -1;
diff -ruN linux-2.5.70.org/net/ipv4/tcp_diag.c linux-2.5.70.new/net/ipv4/tcp_diag.c
--- linux-2.5.70.org/net/ipv4/tcp_diag.c	2003-05-26 18:00:20.000000000 -0700
+++ linux-2.5.70.new/net/ipv4/tcp_diag.c	2003-06-19 06:09:45.000000000 -0700
@@ -591,7 +591,7 @@
  			if (tcpdiag_bc_audit(RTA_DATA(rta), RTA_PAYLOAD(rta)))
  				goto err_inval;
  		}
-		return netlink_dump_start(tcpnl, skb, nlh,
+		return netlink_dump_start(tcpnl, skb, nlh, -1,
  					  tcpdiag_dump,
  					  tcpdiag_dump_done);
  	} else {
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
+++ linux-2.5.70.new/net/ipv6/addrconf.c	2003-06-20 01:34:14.000000000 -0700
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
@@ -2389,6 +2388,42 @@
  	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_IFADDR, GFP_ATOMIC);
  }

+int inet6_dump_omflags(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int flags;
+	struct ifp_if6info *ifp;
+	struct net_device *dev;
+	struct inet6_dev *idev;
+	struct nlmsghdr  *nlh;
+	unsigned char *cur_tail, *org_tail = skb->tail;
+
+	read_lock(&dev_base_lock);
+	for (dev = dev_base; dev; dev = dev->next) {
+		if (dev->flags & IFF_LOOPBACK)
+			continue;
+		if ((idev = in6_dev_get(dev)) == NULL)
+			continue;
+		flags = idev->if_flags;
+		in6_dev_put(idev);
+		cur_tail = skb->tail;
+		nlh = NLMSG_PUT(skb, NETLINK_CB(cb->skb).pid,
+				cb->nlh->nlmsg_seq, RTM_GETOMFLAGS,
+				sizeof(*ifp));
+		ifp = NLMSG_DATA(nlh);
+		ifp->ifindex = dev->ifindex;
+		ifp->flags = flags;
+		nlh->nlmsg_len = skb->tail - cur_tail;
+	}
+	read_unlock(&dev_base_lock);
+	return skb->len;
+
+nlmsg_failure:
+	read_unlock(&dev_base_lock);
+	printk(KERN_INFO "inet6_dump_omflags:skb size not enough\n");
+	skb_trim(skb, org_tail - skb->data);
+	return -1;
+}
+
  static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
  	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
  	[RTM_DELADDR - RTM_BASE] = { .doit	= inet6_rtm_deladdr, },
@@ -2397,6 +2432,10 @@
  	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet6_rtm_delroute, },
  	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet6_rtm_getroute,
  				      .dumpit	= inet6_dump_fib, },
+	[RTM_GETOMFLAGS - RTM_BASE] = { .dumpit	= inet6_dump_omflags, },
+#ifdef CONFIG_IPV6_PREFIXLIST
+	[RTM_GETPLIST - RTM_BASE] = { .dumpit	= inet6_dump_fib, },
+#endif
  };

  static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
@@ -2730,7 +2769,7 @@
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
+++ linux-2.5.70.new/net/ipv6/ndisc.c	2003-06-20 02:00:53.000000000 -0700
@@ -1049,6 +1049,16 @@
  		 */
  		in6_dev->if_flags |= IF_RA_RCVD;
  	}
+	/*
+	 * Remember the managed/otherconf flags from most recently
+	 * received RA message (RFC 2462) -- yoshfuji
+	 */
+	in6_dev->if_flags = (in6_dev->if_flags & ~(IF_RA_MANAGED |
+				IF_RA_OTHERCONF)) |
+				(ra_msg->icmph.icmp6_addrconf_managed ?
+					IF_RA_MANAGED : 0) |
+				(ra_msg->icmph.icmp6_addrconf_other ?
+					IF_RA_OTHERCONF : 0);

  	lifetime = ntohs(ra_msg->icmph.icmp6_rt_lifetime);

diff -ruN linux-2.5.70.org/net/ipv6/route.c linux-2.5.70.new/net/ipv6/route.c
--- linux-2.5.70.org/net/ipv6/route.c	2003-05-26 18:00:45.000000000 -0700
+++ linux-2.5.70.new/net/ipv6/route.c	2003-06-20 02:05:48.000000000 -0700
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
@@ -1547,6 +1609,13 @@
  	struct fib6_walker_t *w;
  	int res;

+#ifdef CONFIG_IPV6_PREFIXLIST
+	BUG_TRAP(cb->type + RTM_BASE == RTM_GETROUTE ||
+			cb->type + RTM_BASE == RTM_GETPLIST);
+#else
+	BUG_TRAP(cb->type + RTM_BASE == RTM_GETROUTE);
+#endif
+
  	arg.skb = skb;
  	arg.cb = cb;

@@ -1568,7 +1637,12 @@
  		RT6_TRACE("dump<%p", w);
  		memset(w, 0, sizeof(*w));
  		w->root = &ip6_routing_table;
-		w->func = fib6_dump_node;
+		if (cb->type + RTM_BASE == RTM_GETROUTE)
+			w->func = fib6_dump_node;
+#ifdef CONFIG_IPV6_PREFIXLIST
+		else
+			w->func = fib6_dump_prefix;
+#endif
  		w->args = &arg;
  		cb->args[0] = (long)w;
  		read_lock_bh(&rt6_lock);
diff -ruN linux-2.5.70.org/net/netlink/af_netlink.c 
linux-2.5.70.new/net/netlink/af_netlink.c
--- linux-2.5.70.org/net/netlink/af_netlink.c	2003-05-26 18:00:40.000000000 -0700
+++ linux-2.5.70.new/net/netlink/af_netlink.c	2003-06-19 06:14:26.000000000 -0700
@@ -842,7 +842,7 @@
  }

  int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
-		       struct nlmsghdr *nlh,
+		       struct nlmsghdr *nlh, int type,
  		       int (*dump)(struct sk_buff *skb, struct netlink_callback*),
  		       int (*done)(struct netlink_callback*))
  {
@@ -858,6 +858,7 @@
  	cb->dump = dump;
  	cb->done = done;
  	cb->nlh = nlh;
+	cb->type = type;
  	atomic_inc(&skb->users);
  	cb->skb = skb;

diff -ruN linux-2.5.70.org/net/xfrm/xfrm_user.c 
linux-2.5.70.new/net/xfrm/xfrm_user.c
--- linux-2.5.70.org/net/xfrm/xfrm_user.c	2003-05-26 18:00:41.000000000 -0700
+++ linux-2.5.70.new/net/xfrm/xfrm_user.c	2003-06-19 06:10:17.000000000 -0700
@@ -869,7 +869,7 @@
  		if (link->dump == NULL)
  			goto err_einval;

-		if ((*errp = netlink_dump_start(xfrm_nl, skb, nlh,
+		if ((*errp = netlink_dump_start(xfrm_nl, skb, nlh, -1,
  						link->dump,
  						xfrm_done)) != 0) {
  			return -1;
