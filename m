From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Wed, 14 Jan 2004 15:52:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401141552.51424.mashirle@us.ibm.com>
References: <200311191621.38087.mashirle@us.ibm.com> <200312051351.47962.mashirle@us.ibm.com> <20031205145700.120e9e68.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_3O7IXDFKN1YZ3LLGABBV"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031205145700.120e9e68.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--------------Boundary-00=_3O7IXDFKN1YZ3LLGABBV
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Once receiving a router advertisement message,
a netlink notification event will be created.

This patch is against linux-2.6.1.



--------------Boundary-00=_3O7IXDFKN1YZ3LLGABBV
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.1-ipv6mib8.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.1-ipv6mib8.patch"

diff -urN linux-2.6.1/include/linux/rtnetlink.h linux-2.6.1-ipv6mib8/include/linux/rtnetlink.h
--- linux-2.6.1/include/linux/rtnetlink.h	2004-01-08 22:59:55.000000000 -0800
+++ linux-2.6.1-ipv6mib8/include/linux/rtnetlink.h	2004-01-13 10:45:20.000000000 -0800
@@ -44,7 +44,10 @@
 #define	RTM_DELTFILTER	(RTM_BASE+29)
 #define	RTM_GETTFILTER	(RTM_BASE+30)
 
-#define	RTM_MAX		(RTM_BASE+31)
+#define RTM_NEWRA	(RTM_BASE+32)
+#define RTM_GETRA	(RTM_BASE+34)
+
+#define	RTM_MAX		(RTM_BASE+35)
 
 /* 
    Generic structure for encapsulation of optional route information.
@@ -441,6 +444,38 @@
 };
 
 /*****************************************************************
+ *		Route Advertisement specific messages.
+ * ******/
+
+/* struct iframsg
+ * passes router advertisement specific information
+ */
+
+struct iframsg
+{
+	unsigned char   ifra_family;
+	unsigned	ifra_flags;
+	int		ifra_index;
+};
+
+enum
+{
+	IFRA_UNSPEC,
+	IFRA_LMTU,
+	IFRA_CACHEINFO
+};
+
+/* max_adver_interval, min_adver_interval should be gotten from user level */
+struct ifra_cacheinfo {
+	__u32		hop_limit;
+	__u32		lifetime;
+	__u32		reachable_time;
+	__u32		retrans_time;
+};
+
+#define IFRA_MAX IFRA_CACHEINFO
+
+/*****************************************************************
  *		Link layer specific messages.
  ****/
 
@@ -615,6 +650,8 @@
 #define RTMGRP_DECnet_IFADDR    0x1000
 #define RTMGRP_DECnet_ROUTE     0x4000
 
+#define RTMGRP_IPV6_IFRA	0x10000
+
 /* End of information exported to user level */
 
 #ifdef __KERNEL__
diff -urN linux-2.6.1/include/net/ndisc.h linux-2.6.1-ipv6mib8/include/net/ndisc.h
--- linux-2.6.1/include/net/ndisc.h	2004-01-08 22:59:55.000000000 -0800
+++ linux-2.6.1-ipv6mib8/include/net/ndisc.h	2004-01-13 10:45:20.000000000 -0800
@@ -98,6 +98,10 @@
 
 extern void			igmp6_cleanup(void);
 
+extern void			inet6_ifra_notify(int event,
+						  struct inet6_dev *idev,
+						  struct ra_msg *ra_msg);
+
 static inline struct neighbour * ndisc_get_neigh(struct net_device *dev, struct in6_addr *addr)
 {
 
diff -urN linux-2.6.1/net/ipv6/addrconf.c linux-2.6.1-ipv6mib8/net/ipv6/addrconf.c
--- linux-2.6.1/net/ipv6/addrconf.c	2004-01-08 23:00:03.000000000 -0800
+++ linux-2.6.1-ipv6mib8/net/ipv6/addrconf.c	2004-01-13 10:45:20.000000000 -0800
@@ -2802,6 +2802,62 @@
 	return skb->len;
 }
 
+static int inet6_fill_ifra(struct sk_buff *skb, struct inet6_dev *idev,
+			   struct ra_msg *ra_msg, u32 pid, u32 seq, int event)
+{
+	struct iframsg		*ifra;
+	struct nlmsghdr 	*nlh;
+	unsigned char		*b = skb->tail;
+	__u32			mtu = idev->dev->mtu;
+	struct ifra_cacheinfo	ci;
+
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifra));
+	
+	if (pid) 
+		nlh->nlmsg_flags |= NLM_F_MULTI;
+	
+	ifra = NLMSG_DATA(nlh);
+	ifra->ifra_family = AF_INET6;
+	ifra->ifra_index = idev->dev->ifindex;
+	ifra->ifra_flags = idev->if_flags;
+
+	RTA_PUT(skb, IFRA_LMTU, sizeof(mtu), &mtu);
+
+	ci.hop_limit = ra_msg->icmph.icmp6_hop_limit;
+	ci.lifetime = ntohs(ra_msg->icmph.icmp6_rt_lifetime);
+	ci.reachable_time = ntohl(ra_msg->reachable_time);
+	ci.retrans_time = ntohl(ra_msg->retrans_timer);
+	RTA_PUT(skb, IFRA_CACHEINFO, sizeof(ci), &ci);
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
+void inet6_ifra_notify(int event, struct inet6_dev *idev, 
+			      struct ra_msg *ra_msg)
+{
+	struct sk_buff *skb;
+	int size = NLMSG_SPACE(sizeof(struct iframsg)+128);
+
+	skb = alloc_skb(size, GFP_ATOMIC);
+	if (!skb) {
+		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFRA, ENOBUFS);
+		return;
+	}
+	if (inet6_fill_ifra(skb, idev, ra_msg, 0, 0, event) < 0) {
+		kfree_skb(skb);
+		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFRA, EINVAL);
+		return;
+	}
+	NETLINK_CB(skb).dst_groups = RTMGRP_IPV6_IFRA;
+	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_IFRA, GFP_ATOMIC);
+}
+
 static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
 	[RTM_GETLINK - RTM_BASE] = { .dumpit	= inet6_dump_ifinfo, },
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
diff -urN linux-2.6.1/net/ipv6/ndisc.c linux-2.6.1-ipv6mib8/net/ipv6/ndisc.c
--- linux-2.6.1/net/ipv6/ndisc.c	2004-01-08 22:59:44.000000000 -0800
+++ linux-2.6.1-ipv6mib8/net/ipv6/ndisc.c	2004-01-13 10:45:20.000000000 -0800
@@ -1190,6 +1190,7 @@
 out:
 	if (rt)
 		dst_release(&rt->u.dst);
+	inet6_ifra_notify(RTM_NEWRA, in6_dev, ra_msg);
 	in6_dev_put(in6_dev);
 }
 

--------------Boundary-00=_3O7IXDFKN1YZ3LLGABBV--
