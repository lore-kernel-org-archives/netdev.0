From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH] New Patch Implementation for IPv6 MIB:ipv6InterfaceTable
Date: Mon, 20 Oct 2003 16:43:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310201643.36382.mashirle@us.ibm.com>
References: <200310141032.23998.mashirle@us.ibm.com> <20031014152441.1be6b336.davem@redhat.com> <200310201600.10016.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_OWX2VS19HYA5PIJUZMID"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <200310201600.10016.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--------------Boundary-00=_OWX2VS19HYA5PIJUZMID
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

This is the attachment file for this patch, please use this one.

 Thanks
 Shirley Ma
 Linux Technology Center
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


--------------Boundary-00=_OWX2VS19HYA5PIJUZMID
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="ipv6mib1-2.6.0-test8.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="ipv6mib1-2.6.0-test8.patch"

diff -urN linux-2.6.0-test8/include/linux/rtnetlink.h linux-2.6.0-test8-ipv6mib1/include/linux/rtnetlink.h
--- linux-2.6.0-test8/include/linux/rtnetlink.h	2003-10-17 14:43:24.000000000 -0700
+++ linux-2.6.0-test8-ipv6mib1/include/linux/rtnetlink.h	2003-10-20 12:52:29.000000000 -0700
@@ -557,9 +557,18 @@
 	IFLA_INET6_CONF,	/* sysctl parameters		*/
 	IFLA_INET6_STATS,	/* statistics			*/
 	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
+	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
 };
 
-#define IFLA_INET6_MAX	IFLA_INET6_MCAST
+struct ifla_cacheinfo
+{
+	__u32	max_reasm_len;
+	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
+	__u32	reachable_time;
+	__u32	retrans_time;
+};
+
+#define IFLA_INET6_MAX	IFLA_INET6_CACHEINFO
 
 /*****************************************************************
  *		Traffic control messages.
@@ -610,6 +619,7 @@
 #define RTMGRP_IPV6_IFADDR	0x100
 #define RTMGRP_IPV6_MROUTE	0x200
 #define RTMGRP_IPV6_ROUTE	0x400
+#define RTMGRP_IPV6_IFINFO	0x800
 
 #define RTMGRP_DECnet_IFADDR    0x1000
 #define RTMGRP_DECnet_ROUTE     0x4000
diff -urN linux-2.6.0-test8/include/net/if_inet6.h linux-2.6.0-test8-ipv6mib1/include/net/if_inet6.h
--- linux-2.6.0-test8/include/net/if_inet6.h	2003-10-17 14:43:34.000000000 -0700
+++ linux-2.6.0-test8-ipv6mib1/include/net/if_inet6.h	2003-10-20 12:52:29.000000000 -0700
@@ -181,6 +181,7 @@
 	struct inet6_dev	*next;
 	struct ipv6_devconf	cnf;
 	struct ipv6_devstat	stats;
+	unsigned long		tstamp; /* ipv6InterfaceTable update timestamp */
 };
 
 extern struct ipv6_devconf ipv6_devconf;
diff -urN linux-2.6.0-test8/include/net/ndisc.h linux-2.6.0-test8-ipv6mib1/include/net/ndisc.h
--- linux-2.6.0-test8/include/net/ndisc.h	2003-10-17 14:43:24.000000000 -0700
+++ linux-2.6.0-test8-ipv6mib1/include/net/ndisc.h	2003-10-20 12:52:29.000000000 -0700
@@ -98,6 +98,17 @@
 
 extern void			igmp6_cleanup(void);
 
+#ifdef CONFIG_SYSCTL
+extern int 			ndisc_ifinfo_sysctl_change(ctl_table *ctl,
+							   int write,
+							   struct file * filp,
+							   void __user *buffer,
+							   size_t *lenp);
+#endif
+
+extern void 			inet6_ifinfo_notify(int event,
+						    struct inet6_dev *idev);
+
 static inline struct neighbour * ndisc_get_neigh(struct net_device *dev, struct in6_addr *addr)
 {
 
diff -urN linux-2.6.0-test8/include/net/neighbour.h linux-2.6.0-test8-ipv6mib1/include/net/neighbour.h
--- linux-2.6.0-test8/include/net/neighbour.h	2003-10-17 14:43:34.000000000 -0700
+++ linux-2.6.0-test8-ipv6mib1/include/net/neighbour.h	2003-10-20 14:39:37.000000000 -0700
@@ -47,6 +47,7 @@
 #include <linux/skbuff.h>
 
 #include <linux/err.h>
+#include <linux/sysctl.h>
 
 #define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_DELAY|NUD_PROBE)
 #define NUD_VALID	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STALE|NUD_DELAY)
@@ -206,8 +207,11 @@
 extern int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 extern void neigh_app_ns(struct neighbour *n);
 
-extern int			neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
-						      int p_id, int pdev_id, char *p_name);
+extern int			neigh_sysctl_register(struct net_device *dev, 
+						      struct neigh_parms *p,
+						      int p_id, int pdev_id,
+						      char *p_name,
+						      proc_handler *proc_handler);
 extern void			neigh_sysctl_unregister(struct neigh_parms *p);
 
 /*
diff -urN linux-2.6.0-test8/net/core/neighbour.c linux-2.6.0-test8-ipv6mib1/net/core/neighbour.c
--- linux-2.6.0-test8/net/core/neighbour.c	2003-10-17 14:42:53.000000000 -0700
+++ linux-2.6.0-test8-ipv6mib1/net/core/neighbour.c	2003-10-20 12:52:29.000000000 -0700
@@ -1625,7 +1625,8 @@
 };
 
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
-			  int p_id, int pdev_id, char *p_name)
+			  int p_id, int pdev_id, char *p_name, 
+			  proc_handler *handler)
 {
 	struct neigh_sysctl_table *t = kmalloc(sizeof(*t), GFP_KERNEL);
 
@@ -1636,6 +1637,10 @@
 	t->neigh_vars[1].data  = &p->ucast_probes;
 	t->neigh_vars[2].data  = &p->app_probes;
 	t->neigh_vars[3].data  = &p->retrans_time;
+	if (handler) {
+		t->neigh_vars[3].proc_handler = handler;
+		t->neigh_vars[3].extra1 = dev;
+	}
 	t->neigh_vars[4].data  = &p->base_reachable_time;
 	t->neigh_vars[5].data  = &p->delay_probe_time;
 	t->neigh_vars[6].data  = &p->gc_staletime;
diff -urN linux-2.6.0-test8/net/ipv4/arp.c linux-2.6.0-test8-ipv6mib1/net/ipv4/arp.c
--- linux-2.6.0-test8/net/ipv4/arp.c	2003-10-17 14:43:26.000000000 -0700
+++ linux-2.6.0-test8-ipv6mib1/net/ipv4/arp.c	2003-10-20 12:52:29.000000000 -0700
@@ -1122,7 +1122,7 @@
 	arp_proc_init();
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &arp_tbl.parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4");
+			      NET_IPV4_NEIGH, "ipv4", NULL);
 #endif
 	register_netdevice_notifier(&arp_netdev_notifier);
 }
diff -urN linux-2.6.0-test8/net/ipv4/devinet.c linux-2.6.0-test8-ipv6mib1/net/ipv4/devinet.c
--- linux-2.6.0-test8/net/ipv4/devinet.c	2003-10-17 14:42:56.000000000 -0700
+++ linux-2.6.0-test8-ipv6mib1/net/ipv4/devinet.c	2003-10-20 12:52:29.000000000 -0700
@@ -155,7 +155,7 @@
 	dev_hold(dev);
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4");
+			      NET_IPV4_NEIGH, "ipv4", NULL);
 #endif
 	write_lock_bh(&inetdev_lock);
 	dev->ip_ptr = in_dev;
diff -urN linux-2.6.0-test8/net/ipv6/addrconf.c linux-2.6.0-test8-ipv6mib1/net/ipv6/addrconf.c
--- linux-2.6.0-test8/net/ipv6/addrconf.c	2003-10-17 14:43:33.000000000 -0700
+++ linux-2.6.0-test8-ipv6mib1/net/ipv6/addrconf.c	2003-10-20 15:36:54.000000000 -0700
@@ -373,9 +373,10 @@
 		write_unlock_bh(&addrconf_lock);
 
 		ipv6_mc_init_dev(ndev);
-
+		ndev->tstamp = jiffies;
 #ifdef CONFIG_SYSCTL
-		neigh_sysctl_register(dev, ndev->nd_parms, NET_IPV6, NET_IPV6_NEIGH, "ipv6");
+		neigh_sysctl_register(dev, ndev->nd_parms, NET_IPV6, 
+			NET_IPV6_NEIGH, "ipv6", &ndisc_ifinfo_sysctl_change);
 		addrconf_sysctl_register(ndev, &ndev->cnf);
 #endif
 	}
@@ -1854,6 +1855,8 @@
 				rt6_mtu_change(dev, dev->mtu);
 				idev->cnf.mtu6 = dev->mtu;
 			}
+			idev->tstamp = jiffies;
+			inet6_ifinfo_notify(RTM_NEWLINK, idev);
 			/* If the changed mtu during down is lower than IPV6_MIN_MTU
 			   stop IPv6 on this interface.
 			 */
@@ -1972,7 +1975,10 @@
 		ipv6_mc_destroy_dev(idev);
 	else
 		ipv6_mc_down(idev);
-
+	/* Step 5: netlink notification of this interface */
+	idev->tstamp = jiffies;
+	inet6_ifinfo_notify(RTM_NEWLINK, idev);
+	
 	/* Shot the device (if unregistered) */
 
 	if (how == 1) {
@@ -2673,17 +2679,19 @@
 #endif
 }
 
-static int inet6_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
-			    struct inet6_dev *idev,
-			    int type, u32 pid, u32 seq)
+static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev, 
+			     u32 pid, u32 seq, int event)
 {
+	struct net_device	*dev = idev->dev;
 	__s32			*array = NULL;
 	struct ifinfomsg	*r;
 	struct nlmsghdr 	*nlh;
 	unsigned char		*b = skb->tail;
 	struct rtattr		*subattr;
+	__u32			mtu = dev->mtu;
+	struct ifla_cacheinfo	ci;
 
-	nlh = NLMSG_PUT(skb, pid, seq, type, sizeof(*r));
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*r));
 	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
 	r = NLMSG_DATA(nlh);
 	r->ifi_family = AF_INET6;
@@ -2698,6 +2706,13 @@
 
 	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
 
+	if (dev->addr_len)
+		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
+
+	RTA_PUT(skb, IFLA_MTU, sizeof(mtu), &mtu);
+	if (dev->ifindex != dev->iflink)
+		RTA_PUT(skb, IFLA_LINK, sizeof(int), &dev->iflink);
+			
 	subattr = (struct rtattr*)skb->tail;
 
 	RTA_PUT(skb, IFLA_PROTINFO, 0, NULL);
@@ -2705,6 +2720,14 @@
 	/* return the device flags */
 	RTA_PUT(skb, IFLA_INET6_FLAGS, sizeof(__u32), &idev->if_flags);
 
+	/* return interface cacheinfo */
+	ci.max_reasm_len = IPV6_MAXPLEN;
+	ci.tstamp = (__u32)(TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) / HZ * 100
+		    + TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
+	ci.reachable_time = idev->nd_parms->reachable_time;
+	ci.retrans_time = idev->nd_parms->retrans_time;
+	RTA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
+	
 	/* return the device sysctl params */
 	if ((array = kmalloc(DEVCONF_MAX * sizeof(*array), GFP_ATOMIC)) == NULL)
 		goto rtattr_failure;
@@ -2739,8 +2762,8 @@
 			continue;
 		if ((idev = in6_dev_get(dev)) == NULL)
 			continue;
-		err = inet6_fill_ifinfo(skb, dev, idev, RTM_NEWLINK,
-				NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq);
+		err = inet6_fill_ifinfo(skb, idev, NETLINK_CB(cb->skb).pid, 
+				cb->nlh->nlmsg_seq, RTM_NEWLINK);
 		in6_dev_put(idev);
 		if (err <= 0)
 			break;
@@ -2751,6 +2774,26 @@
 	return skb->len;
 }
 
+void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
+{
+	struct sk_buff *skb;
+	/* 128 bytes ?? */
+	int size = NLMSG_SPACE(sizeof(struct ifinfomsg)+128);
+	
+	skb = alloc_skb(size, GFP_ATOMIC);
+	if (!skb) {
+		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFINFO, ENOBUFS);
+		return;
+	}
+	if (inet6_fill_ifinfo(skb, idev, 0, 0, event) < 0) {
+		kfree_skb(skb);
+		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFINFO, EINVAL);
+		return;
+	}
+	NETLINK_CB(skb).dst_groups = RTMGRP_IPV6_IFINFO;
+	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_IFINFO, GFP_ATOMIC);
+}
+
 static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
 	[RTM_GETLINK - RTM_BASE] = { .dumpit	= inet6_dump_ifinfo, },
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
diff -urN linux-2.6.0-test8/net/ipv6/ndisc.c linux-2.6.0-test8-ipv6mib1/net/ipv6/ndisc.c
--- linux-2.6.0-test8/net/ipv6/ndisc.c	2003-10-17 14:43:18.000000000 -0700
+++ linux-2.6.0-test8-ipv6mib1/net/ipv6/ndisc.c	2003-10-20 15:36:27.000000000 -0700
@@ -1109,6 +1109,8 @@
 			if (rtime < HZ/10)
 				rtime = HZ/10;
 			in6_dev->nd_parms->retrans_time = rtime;
+			in6_dev->tstamp = jiffies;
+			inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
 		}
 
 		rtime = ntohl(ra_msg->reachable_time);
@@ -1122,6 +1124,8 @@
 				in6_dev->nd_parms->base_reachable_time = rtime;
 				in6_dev->nd_parms->gc_staletime = 3 * rtime;
 				in6_dev->nd_parms->reachable_time = neigh_rand_reach_time(rtime);
+				in6_dev->tstamp = jiffies;
+				inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
 			}
 		}
 	}
@@ -1487,6 +1491,21 @@
 	.notifier_call = ndisc_netdev_event,
 };
 
+#ifdef CONFIG_SYSCTL
+int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, struct file * filp, void __user *buffer, size_t *lenp)
+{
+	struct net_device *dev = ctl->extra1;
+	struct inet6_dev *idev;
+
+	if (write && dev && (idev = in6_dev_get(dev)) != NULL) {
+		idev->tstamp = jiffies;
+		inet6_ifinfo_notify(RTM_NEWLINK, idev);
+		in6_dev_put(idev);
+	}
+	return proc_dointvec(ctl, write, filp, buffer, lenp);
+}
+#endif
+
 int __init ndisc_init(struct net_proto_family *ops)
 {
 	struct ipv6_pinfo *np;
@@ -1517,7 +1536,8 @@
 	neigh_table_init(&nd_tbl);
 
 #ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6, NET_IPV6_NEIGH, "ipv6");
+	neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6, NET_IPV6_NEIGH, 
+			      "ipv6", &ndisc_ifinfo_sysctl_change);
 #endif
 
 	register_netdevice_notifier(&ndisc_netdev_notifier);

--------------Boundary-00=_OWX2VS19HYA5PIJUZMID--
