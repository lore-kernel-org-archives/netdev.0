From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] IPv6 MIB:ipv6Prefix netlink notification
Date: Fri, 5 Dec 2003 13:51:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312051351.47962.mashirle@us.ibm.com>
References: <200311191621.38087.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_BEZFRZA61GQXT3MPYBIA"
Cc: xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
In-Reply-To: <200311191621.38087.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--------------Boundary-00=_BEZFRZA61GQXT3MPYBIA
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Once receiving a router advertisement message for prefix info,=20
a netlink notification event will be created.

This patch has been tested against linux-2.6.0-test11.=20

Thanks
Shirley Ma
IBM Linux Technology Center


--------------Boundary-00=_BEZFRZA61GQXT3MPYBIA
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.0-test11-ipv6mib3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.0-test11-ipv6mib3.patch"

diff -urN linux-2.6.0-test11/include/linux/rtnetlink.h linux-2.6.0-test11-ipv6mib3/include/linux/rtnetlink.h
--- linux-2.6.0-test11/include/linux/rtnetlink.h	2003-11-26 12:45:11.000000000 -0800
+++ linux-2.6.0-test11-ipv6mib3/include/linux/rtnetlink.h	2003-12-05 12:20:11.000000000 -0800
@@ -44,7 +44,10 @@
 #define	RTM_DELTFILTER	(RTM_BASE+29)
 #define	RTM_GETTFILTER	(RTM_BASE+30)
 
-#define	RTM_MAX		(RTM_BASE+31)
+#define RTM_NEWPREFIX	(RTM_BASE+36)
+#define RTM_GETPREFIX	(RTM_BASE+38)
+
+#define	RTM_MAX		(RTM_BASE+39)
 
 /* 
    Generic structure for encapsulation of optional route information.
@@ -458,6 +461,34 @@
 	unsigned	ifi_change;		/* IFF_* change mask */
 };
 
+/********************************************************************
+ *		prefix information 
+ ****/
+
+struct prefixmsg
+{
+	unsigned char	prefix_family;
+	int		prefix_ifindex;
+	unsigned char	prefix_type;
+	unsigned char	prefix_len;
+	unsigned char	prefix_flags;
+};
+
+enum 
+{
+	PREFIX_UNSPEC,
+	PREFIX_ADDRESS,
+	PREFIX_CACHEINFO,
+};
+
+#define PREFIX_MAX	PREFIX_CACHEINFO
+
+struct prefix_cacheinfo
+{
+	__u32	preferred_time;
+	__u32	valid_time;
+};
+
 /* The struct should be in sync with struct net_device_stats */
 struct rtnl_link_stats
 {
@@ -614,6 +645,8 @@
 #define RTMGRP_DECnet_IFADDR    0x1000
 #define RTMGRP_DECnet_ROUTE     0x4000
 
+#define RTMGRP_IPV6_PREFIX	0x20000
+
 /* End of information exported to user level */
 
 #ifdef __KERNEL__
diff -urN linux-2.6.0-test11/include/net/if_inet6.h linux-2.6.0-test11-ipv6mib3/include/net/if_inet6.h
--- linux-2.6.0-test11/include/net/if_inet6.h	2003-11-26 12:45:45.000000000 -0800
+++ linux-2.6.0-test11-ipv6mib3/include/net/if_inet6.h	2003-12-05 12:20:11.000000000 -0800
@@ -25,6 +25,10 @@
 #define IF_RA_RCVD	0x20
 #define IF_RS_SENT	0x10
 
+/* prefix flags */
+#define IF_PREFIX_ONLINK	0x01
+#define IF_PREFIX_AUTOCONF	0x02
+
 #ifdef __KERNEL__
 
 struct inet6_ifaddr 
diff -urN linux-2.6.0-test11/net/ipv6/addrconf.c linux-2.6.0-test11-ipv6mib3/net/ipv6/addrconf.c
--- linux-2.6.0-test11/net/ipv6/addrconf.c	2003-11-26 12:45:37.000000000 -0800
+++ linux-2.6.0-test11-ipv6mib3/net/ipv6/addrconf.c	2003-12-05 12:21:59.000000000 -0800
@@ -138,6 +138,8 @@
 static void addrconf_rs_timer(unsigned long data);
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifa);
 
+static void inet6_prefix_notify(int event, struct inet6_dev *idev, 
+				struct prefix_info *pinfo);
 static int ipv6_chk_same_addr(const struct in6_addr *addr, struct net_device *dev);
 
 static struct notifier_block *inet6addr_chain;
@@ -1491,6 +1493,7 @@
 			addrconf_verify(0);
 		}
 	}
+	inet6_prefix_notify(RTM_NEWPREFIX, in6_dev, pinfo);
 	in6_dev_put(in6_dev);
 }
 
@@ -2751,6 +2754,66 @@
 	return skb->len;
 }
 
+static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
+			struct prefix_info *pinfo, u32 pid, u32 seq, int event)
+{
+	struct prefixmsg	*pmsg;
+	struct nlmsghdr 	*nlh;
+	unsigned char		*b = skb->tail;
+	struct prefix_cacheinfo	ci;
+
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*pmsg));
+	
+	if (pid) 
+		nlh->nlmsg_flags |= NLM_F_MULTI;
+	
+	pmsg = NLMSG_DATA(nlh);
+	pmsg->prefix_family = AF_INET6;
+	pmsg->prefix_ifindex = idev->dev->ifindex;
+	pmsg->prefix_len = pinfo->prefix_len;
+	pmsg->prefix_type = pinfo->type;
+	
+	pmsg->prefix_flags = 0;
+	if (pinfo->onlink)
+		pmsg->prefix_flags |= IF_PREFIX_ONLINK;
+	if (pinfo->autoconf)
+		pmsg->prefix_flags |= IF_PREFIX_AUTOCONF;
+
+	RTA_PUT(skb, PREFIX_ADDRESS, sizeof(pinfo->prefix), &pinfo->prefix);
+
+	ci.preferred_time = ntohl(pinfo->prefered);
+	ci.valid_time = ntohl(pinfo->valid);
+	RTA_PUT(skb, PREFIX_CACHEINFO, sizeof(ci), &ci);
+
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static void inet6_prefix_notify(int event, struct inet6_dev *idev, 
+			 struct prefix_info *pinfo)
+{
+	struct sk_buff *skb;
+	int size = NLMSG_SPACE(sizeof(struct prefixmsg)+128);
+
+	skb = alloc_skb(size, GFP_ATOMIC);
+	if (!skb) {
+		netlink_set_err(rtnl, 0, RTMGRP_IPV6_PREFIX, ENOBUFS);
+		return;
+	}
+	if (inet6_fill_prefix(skb, idev, pinfo, 0, 0, event) < 0) {
+		kfree_skb(skb);
+		netlink_set_err(rtnl, 0, RTMGRP_IPV6_PREFIX, EINVAL);
+		return;
+	}
+	NETLINK_CB(skb).dst_groups = RTMGRP_IPV6_PREFIX;
+	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_PREFIX, GFP_ATOMIC);
+}
+
 static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
 	[RTM_GETLINK - RTM_BASE] = { .dumpit	= inet6_dump_ifinfo, },
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },

--------------Boundary-00=_BEZFRZA61GQXT3MPYBIA--
