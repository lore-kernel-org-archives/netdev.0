From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH]Implementation for IPv6 MIB:ipv6InterfaceTable
Date: Tue, 14 Oct 2003 10:32:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310141032.23998.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The implementation is based on last call new draft of IP MIBs:
http://www.ietf.org/internet-drafts/draft-ietf-ipv6-rfc2011-update-04.txt

The patch has been tested against linux-2.6.0-test6-bk3. Please give
me your comments.

Thanks
Shirley Ma
IBM Linux Technology Center
======================

diff -urN linux-2.6.0-test6/include/linux/rtnetlink.h 
linux-2.6.0-test6-ipv6mib1/include/linux/rtnetlink.h
--- linux-2.6.0-test6/include/linux/rtnetlink.h	2003-09-27 17:50:40.000000000 
-0700
+++ linux-2.6.0-test6-ipv6mib1/include/linux/rtnetlink.h	2003-10-10 
15:55:39.000000000 -0700
@@ -555,9 +555,17 @@
 	IFLA_INET6_CONF,	/* sysctl parameters		*/
 	IFLA_INET6_STATS,	/* statistics			*/
 	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
+	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
 };
 
-#define IFLA_INET6_MAX	IFLA_INET6_MCAST
+struct ifla_cacheinfo
+{
+	__u32	max_reasm_len;
+	__u32	reachable_time;
+	__u32	retrans_time;
+};
+
+#define IFLA_INET6_MAX	IFLA_INET6_CACHEINFO
 
 /*****************************************************************
  *		Traffic control messages.
@@ -608,6 +616,7 @@
 #define RTMGRP_IPV6_IFADDR	0x100
 #define RTMGRP_IPV6_MROUTE	0x200
 #define RTMGRP_IPV6_ROUTE	0x400
+#define RTMGRP_IPV6_IFINFO	0x800
 
 #define RTMGRP_DECnet_IFADDR    0x1000
 #define RTMGRP_DECnet_ROUTE     0x4000
diff -urN linux-2.6.0-test6/include/net/neighbour.h 
linux-2.6.0-test6-ipv6mib1/include/net/neighbour.h
--- linux-2.6.0-test6/include/net/neighbour.h	2003-09-27 17:51:07.000000000 
-0700
+++ linux-2.6.0-test6-ipv6mib1/include/net/neighbour.h	2003-10-09 
10:36:56.000000000 -0700
@@ -47,6 +47,9 @@
 #include <linux/skbuff.h>
 
 #include <linux/err.h>
+#ifdef CONFIG_SYSCTL
+#include <linux/sysctl.h>
+#endif
 
 #define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_DELAY|NUD_PROBE)
 #define NUD_VALID	
(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STALE|NUD_DELAY)
@@ -206,8 +209,11 @@
 extern int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void 
*arg);
 extern void neigh_app_ns(struct neighbour *n);
 
-extern int			neigh_sysctl_register(struct net_device *dev, struct neigh_parms 
*p,
-						      int p_id, int pdev_id, char *p_name);
+extern int			neigh_sysctl_register(struct net_device *dev, 
+						      struct neigh_parms *p,
+						      int p_id, int pdev_id,
+						      char *p_name,
+						      proc_handler *proc_handler);
 extern void			neigh_sysctl_unregister(struct neigh_parms *p);
 
 /*
diff -urN linux-2.6.0-test6/net/core/neighbour.c 
linux-2.6.0-test6-ipv6mib1/net/core/neighbour.c
--- linux-2.6.0-test6/net/core/neighbour.c	2003-10-07 16:36:53.000000000 -0700
+++ linux-2.6.0-test6-ipv6mib1/net/core/neighbour.c	2003-10-09 
11:24:05.000000000 -0700
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
diff -urN linux-2.6.0-test6/net/ipv4/arp.c 
linux-2.6.0-test6-ipv6mib1/net/ipv4/arp.c
--- linux-2.6.0-test6/net/ipv4/arp.c	2003-10-07 16:36:53.000000000 -0700
+++ linux-2.6.0-test6-ipv6mib1/net/ipv4/arp.c	2003-10-07 13:52:32.000000000 
-0700
@@ -1123,7 +1123,7 @@
 	arp_proc_init();
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &arp_tbl.parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4");
+			      NET_IPV4_NEIGH, "ipv4", NULL);
 #endif
 	register_netdevice_notifier(&arp_netdev_notifier);
 }
diff -urN linux-2.6.0-test6/net/ipv4/devinet.c 
linux-2.6.0-test6-ipv6mib1/net/ipv4/devinet.c
--- linux-2.6.0-test6/net/ipv4/devinet.c	2003-10-07 16:36:53.000000000 -0700
+++ linux-2.6.0-test6-ipv6mib1/net/ipv4/devinet.c	2003-10-07 
13:52:32.000000000 -0700
@@ -155,7 +155,7 @@
 	dev_hold(dev);
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4");
+			      NET_IPV4_NEIGH, "ipv4", NULL);
 #endif
 	write_lock_bh(&inetdev_lock);
 	dev->ip_ptr = in_dev;
diff -urN linux-2.6.0-test6/net/ipv6/addrconf.c 
linux-2.6.0-test6-ipv6mib1/net/ipv6/addrconf.c
--- linux-2.6.0-test6/net/ipv6/addrconf.c	2003-09-27 17:51:02.000000000 -0700
+++ linux-2.6.0-test6-ipv6mib1/net/ipv6/addrconf.c	2003-10-10 
15:47:25.000000000 -0700
@@ -92,7 +92,9 @@
 #define ADBG(x)
 #endif
 
+void inet6_ifinfo_notify(int event, struct inet6_dev *idev);
 #ifdef CONFIG_SYSCTL
+extern int ndisc_ifinfo_sysctl_change(ctl_table *ctl, int write, struct file 
* filp, void __user *buffer, size_t *lenp);
 static void addrconf_sysctl_register(struct inet6_dev *idev, struct 
ipv6_devconf *p);
 static void addrconf_sysctl_unregister(struct ipv6_devconf *p);
 #endif
@@ -372,7 +374,8 @@
 		ipv6_mc_init_dev(ndev);
 
 #ifdef CONFIG_SYSCTL
-		neigh_sysctl_register(dev, ndev->nd_parms, NET_IPV6, NET_IPV6_NEIGH, 
"ipv6");
+		neigh_sysctl_register(dev, ndev->nd_parms, NET_IPV6, 
+			NET_IPV6_NEIGH, "ipv6", &ndisc_ifinfo_sysctl_change);
 		addrconf_sysctl_register(ndev, &ndev->cnf);
 #endif
 	}
@@ -1848,6 +1851,7 @@
 				rt6_mtu_change(dev, dev->mtu);
 				idev->cnf.mtu6 = dev->mtu;
 			}
+			inet6_ifinfo_notify(RTM_NEWLINK, idev);
 			/* If the changed mtu during down is lower than IPV6_MIN_MTU
 			   stop IPv6 on this interface.
 			 */
@@ -1875,7 +1879,6 @@
 	case NETDEV_CHANGE:
 		break;
 	};
-
 	return NOTIFY_OK;
 }
 
@@ -1966,7 +1969,9 @@
 		ipv6_mc_destroy_dev(idev);
 	else
 		ipv6_mc_down(idev);
-
+	/* Step 5: netlink notification of this interface */
+	inet6_ifinfo_notify(RTM_NEWLINK, idev);
+	
 	/* Shot the device (if unregistered) */
 
 	if (how == 1) {
@@ -2540,17 +2545,19 @@
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
@@ -2565,6 +2572,13 @@
 
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
@@ -2572,6 +2586,12 @@
 	/* return the device flags */
 	RTA_PUT(skb, IFLA_INET6_FLAGS, sizeof(__u32), &idev->if_flags);
 
+	/* return interface cacheinfo */
+	ci.max_reasm_len = IPV6_MAXPLEN;
+	ci.reachable_time = idev->nd_parms->reachable_time;
+	ci.retrans_time = idev->nd_parms->retrans_time;
+	RTA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
+	
 	/* return the device sysctl params */
 	if ((array = kmalloc(DEVCONF_MAX * sizeof(*array), GFP_ATOMIC)) == NULL)
 		goto rtattr_failure;
@@ -2606,8 +2626,8 @@
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
@@ -2618,6 +2638,26 @@
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
 static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = 
{
 	[RTM_GETLINK - RTM_BASE] = { .dumpit	= inet6_dump_ifinfo, },
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
diff -urN linux-2.6.0-test6/net/ipv6/ndisc.c 
linux-2.6.0-test6-ipv6mib1/net/ipv6/ndisc.c
--- linux-2.6.0-test6/net/ipv6/ndisc.c	2003-09-27 17:50:29.000000000 -0700
+++ linux-2.6.0-test6-ipv6mib1/net/ipv6/ndisc.c	2003-10-10 15:46:03.000000000 
-0700
@@ -76,7 +76,7 @@
 #include <linux/proc_fs.h>
 
 static struct socket *ndisc_socket;
-
+extern void inet6_ifinfo_notify(int event, struct inet6_dev *idev);
 static u32 ndisc_hash(const void *pkey, const struct net_device *dev);
 static int ndisc_constructor(struct neighbour *neigh);
 static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb);
@@ -1109,6 +1109,7 @@
 			if (rtime < HZ/10)
 				rtime = HZ/10;
 			in6_dev->nd_parms->retrans_time = rtime;
+			inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
 		}
 
 		rtime = ntohl(ra_msg->reachable_time);
@@ -1122,6 +1123,7 @@
 				in6_dev->nd_parms->base_reachable_time = rtime;
 				in6_dev->nd_parms->gc_staletime = 3 * rtime;
 				in6_dev->nd_parms->reachable_time = neigh_rand_reach_time(rtime);
+				inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
 			}
 		}
 	}
@@ -1487,6 +1489,20 @@
 	.notifier_call = ndisc_netdev_event,
 };
 
+#ifdef CONFIG_SYSCTL
+int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, struct file 
* filp, void __user *buffer, size_t *lenp)
+{
+	struct net_device *dev = ctl->extra1;
+	struct inet6_dev *idev;
+
+	if (write && dev && (idev = in6_dev_get(dev)) != NULL) {
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
@@ -1517,7 +1533,8 @@
 	neigh_table_init(&nd_tbl);
 
 #ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6, NET_IPV6_NEIGH, 
"ipv6");
+	neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6, NET_IPV6_NEIGH, 
+			      "ipv6", &ndisc_ifinfo_sysctl_change);
 #endif
 
 	register_netdevice_notifier(&ndisc_netdev_notifier);
