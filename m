From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH]dump interface IPv6 multicast/anycast addresses through netlink
Date: Wed, 17 Mar 2004 11:30:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403171130.30282.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_WdKWAcXjZ67xWXv"
Cc: netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_WdKWAcXjZ67xWXv
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch is against Linux 2.6.4 kernel. It has been tested, 'ip' utility 
works fine. This patch is used by IPv6 MIBs.


-- 
Thanks
Shirley Ma
IBM Linux Technology Center
--Boundary-00=_WdKWAcXjZ67xWXv
Content-Type: text/x-diff;
  charset="us-ascii";
  name="linux-2.6.4-ipv6mib.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.4-ipv6mib.patch"

diff -urN linux-2.6.4/include/linux/rtnetlink.h linux-2.6.4-ipv6mib/include/linux/rtnetlink.h
--- linux-2.6.4/include/linux/rtnetlink.h	2004-03-10 18:55:42.000000000 -0800
+++ linux-2.6.4-ipv6mib/include/linux/rtnetlink.h	2004-03-16 16:41:26.000000000 -0800
@@ -47,7 +47,13 @@
 #define RTM_NEWPREFIX	(RTM_BASE+36)
 #define RTM_GETPREFIX	(RTM_BASE+38)
 
-#define	RTM_MAX		(RTM_BASE+39)
+#define	RTM_NEWMULTICAST (RTM_BASE+40)
+#define	RTM_GETMULTICAST (RTM_BASE+42)
+
+#define	RTM_NEWANYCAST	(RTM_BASE+44)
+#define	RTM_GETANYCAST	(RTM_BASE+46)
+
+#define	RTM_MAX		(RTM_BASE+47)
 
 /* 
    Generic structure for encapsulation of optional route information.
@@ -339,6 +345,7 @@
 	IFA_LOCAL,
 	IFA_LABEL,
 	IFA_BROADCAST,
+	IFA_MULTICAST,
 	IFA_ANYCAST,
 	IFA_CACHEINFO
 };
@@ -350,6 +357,10 @@
 #define IFA_F_SECONDARY		0x01
 #define IFA_F_TEMPORARY		IFA_F_SECONDARY
 
+#define IFA_F_ADDRESS		0x02
+#define IFA_F_MULTICAST 	0x04
+#define IFA_F_ANYCAST		0x08
+
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
 #define IFA_F_PERMANENT		0x80
diff -urN linux-2.6.4/net/ipv6/addrconf.c linux-2.6.4-ipv6mib/net/ipv6/addrconf.c
--- linux-2.6.4/net/ipv6/addrconf.c	2004-03-10 18:55:44.000000000 -0800
+++ linux-2.6.4-ipv6mib/net/ipv6/addrconf.c	2004-03-17 10:09:45.000000000 -0800
@@ -2571,7 +2571,7 @@
 	if (ipv6_addr_scope(&ifmca->mca_addr)&IFA_SITE)
 		ifm->ifa_scope = RT_SCOPE_SITE;
 	ifm->ifa_index = ifmca->idev->dev->ifindex;
-	RTA_PUT(skb, IFA_ADDRESS, 16, &ifmca->mca_addr);
+	RTA_PUT(skb, IFA_MULTICAST, 16, &ifmca->mca_addr);
 	ci.cstamp = (__u32)(TIME_DELTA(ifmca->mca_cstamp, INITIAL_JIFFIES) / HZ
 		    * 100 + TIME_DELTA(ifmca->mca_cstamp, INITIAL_JIFFIES) % HZ
 		    * 100 / HZ);
@@ -2608,7 +2608,7 @@
 	if (ipv6_addr_scope(&ifaca->aca_addr)&IFA_SITE)
 		ifm->ifa_scope = RT_SCOPE_SITE;
 	ifm->ifa_index = ifaca->aca_idev->dev->ifindex;
-	RTA_PUT(skb, IFA_ADDRESS, 16, &ifaca->aca_addr);
+	RTA_PUT(skb, IFA_ANYCAST, 16, &ifaca->aca_addr);
 	ci.cstamp = (__u32)(TIME_DELTA(ifaca->aca_cstamp, INITIAL_JIFFIES) / HZ
 		    * 100 + TIME_DELTA(ifaca->aca_cstamp, INITIAL_JIFFIES) % HZ
 		    * 100 / HZ);
@@ -2627,7 +2627,8 @@
 	return -1;
 }
 
-static int inet6_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
+static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
+			   unsigned char flags)
 {
 	int idx, ip_idx;
 	int s_idx, s_ip_idx;
@@ -2651,28 +2652,54 @@
 		if ((idev = in6_dev_get(dev)) == NULL)
 			continue;
 		read_lock_bh(&idev->lock);
-		/* unicast address */
-		for (ifa = idev->addr_list; ifa;
-		     ifa = ifa->if_next, ip_idx++) {
-			if (ip_idx < s_ip_idx)
-				continue;
-			if ((err = inet6_fill_ifaddr(skb, ifa, 
-			    NETLINK_CB(cb->skb).pid, 
-			    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0)
-				goto done;
-		}
-		/* temp addr */
+		if (flags & IFA_F_ADDRESS) {
+			/* unicast address */
+			for (ifa = idev->addr_list; ifa;
+			     ifa = ifa->if_next, ip_idx++) {
+				if (ip_idx < s_ip_idx)
+					continue;
+				if ((err = inet6_fill_ifaddr(skb, ifa, 
+				    NETLINK_CB(cb->skb).pid, 
+				    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0)
+					goto done;
+			}
+			/* temp addr */
 #ifdef CONFIG_IPV6_PRIVACY
-		for (ifa = idev->tempaddr_list; ifa; 
-		     ifa = ifa->tmp_next, ip_idx++) {
-			if (ip_idx < s_ip_idx)
-				continue;
-			if ((err = inet6_fill_ifaddr(skb, ifa, 
-			    NETLINK_CB(cb->skb).pid, 
-			    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
-				goto done;
-		}
+			for (ifa = idev->tempaddr_list; ifa; 
+			     ifa = ifa->tmp_next, ip_idx++) {
+				if (ip_idx < s_ip_idx)
+					continue;
+				if ((err = inet6_fill_ifaddr(skb, ifa, 
+				    NETLINK_CB(cb->skb).pid, 
+				    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
+					goto done;
+			}
 #endif
+		}
+		if (flags & IFA_F_MULTICAST) {
+			/* multicast address */
+			for (ifmca = idev->mc_list; ifmca; 
+			     ifmca = ifmca->next, ip_idx++) {
+				if (ip_idx < s_ip_idx)
+					continue;
+				if ((err = inet6_fill_ifmcaddr(skb, ifmca, 
+				    NETLINK_CB(cb->skb).pid, 
+				    cb->nlh->nlmsg_seq, RTM_NEWMULTICAST)) <= 0)
+					goto done;
+			}
+		}
+		if (flags & IFA_F_ANYCAST) {
+			/* anycast address */
+			for (ifaca = idev->ac_list; ifaca;
+			     ifaca = ifaca->aca_next, ip_idx++) {
+				if (ip_idx < s_ip_idx)
+					continue;
+				if ((err = inet6_fill_ifacaddr(skb, ifaca, 
+				    NETLINK_CB(cb->skb).pid, 
+				    cb->nlh->nlmsg_seq, RTM_NEWANYCAST)) <= 0) 
+					goto done;
+			}
+		}
 		read_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
 	}
@@ -2687,6 +2714,25 @@
 	return skb->len;
 }
 
+static int inet6_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	unsigned char flag = IFA_F_ADDRESS;
+	return inet6_dump_addr(skb, cb, flag);
+}
+
+static int inet6_dump_ifmcaddr(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	unsigned char flag = IFA_F_MULTICAST;
+	return inet6_dump_addr(skb, cb, flag);
+}
+
+
+static int inet6_dump_ifacaddr(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	unsigned char flag = IFA_F_ANYCAST;
+	return inet6_dump_addr(skb, cb, flag);
+}
+
 static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 {
 	struct sk_buff *skb;
@@ -2911,6 +2957,8 @@
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
 	[RTM_DELADDR - RTM_BASE] = { .doit	= inet6_rtm_deladdr, },
 	[RTM_GETADDR - RTM_BASE] = { .dumpit	= inet6_dump_ifaddr, },
+	[RTM_GETMULTICAST - RTM_BASE] = { .dumpit = inet6_dump_ifmcaddr, },
+	[RTM_GETANYCAST - RTM_BASE] = { .dumpit	= inet6_dump_ifacaddr, },
 	[RTM_NEWROUTE - RTM_BASE] = { .doit	= inet6_rtm_newroute, },
 	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet6_rtm_delroute, },
 	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet6_rtm_getroute,

--Boundary-00=_WdKWAcXjZ67xWXv--
