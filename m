From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH]dump interface IPv6 multicast/anycast addresses through netlink
Date: Mon, 5 Apr 2004 13:51:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404051351.09740.mashirle@us.ibm.com>
References: <OF8F6A9EBE.82E160C6-ON87256E69.001BB337-88256E69.001D33A3@us.ibm.com> <200404011028.13048.mashirle@us.ibm.com> <20040403144540.7f201bc1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_9accA6m7DJZzaxc"
Cc: xma@us.ibm.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
        yoshfuji@cerberus.hongo.wide.ad.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040403144540.7f201bc1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_9accA6m7DJZzaxc
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Dumping multicast/anycast api was removed in Linux 2.6.5 kernel, so it
couldn't be applied cleanly.
I recreated the patch. This patch has been tested against linux-2.6.5 kernel.



--Boundary-00=_9accA6m7DJZzaxc
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.5-ipv6mib.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.5-ipv6mib.patch"

diff -urN linux-2.6.5/include/linux/rtnetlink.h linux-2.6.5-ipv6mib/include/linux/rtnetlink.h
--- linux-2.6.5/include/linux/rtnetlink.h	2004-04-03 19:37:42.000000000 -0800
+++ linux-2.6.5-ipv6mib/include/linux/rtnetlink.h	2004-04-05 13:13:27.000000000 -0700
@@ -47,7 +47,11 @@
 #define RTM_NEWPREFIX	(RTM_BASE+36)
 #define RTM_GETPREFIX	(RTM_BASE+38)
 
-#define	RTM_MAX		(RTM_BASE+39)
+#define	RTM_GETMULTICAST (RTM_BASE+42)
+
+#define	RTM_GETANYCAST	(RTM_BASE+46)
+
+#define	RTM_MAX		(RTM_BASE+47)
 
 /* 
    Generic structure for encapsulation of optional route information.
@@ -340,7 +344,8 @@
 	IFA_LABEL,
 	IFA_BROADCAST,
 	IFA_ANYCAST,
-	IFA_CACHEINFO
+	IFA_CACHEINFO,
+	IFA_MULTICAST
 };
 
 #define IFA_MAX IFA_CACHEINFO
diff -urN linux-2.6.5/net/ipv6/addrconf.c linux-2.6.5-ipv6mib/net/ipv6/addrconf.c
--- linux-2.6.5/net/ipv6/addrconf.c	2004-04-03 19:38:17.000000000 -0800
+++ linux-2.6.5-ipv6mib/net/ipv6/addrconf.c	2004-04-05 13:20:34.194635432 -0700
@@ -2553,7 +2553,89 @@
 	return -1;
 }
 
-static int inet6_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
+static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
+				u32 pid, u32 seq, int event)
+{
+	struct ifaddrmsg *ifm;
+	struct nlmsghdr  *nlh;
+	struct ifa_cacheinfo ci;
+	unsigned char	 *b = skb->tail;
+
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
+	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	ifm = NLMSG_DATA(nlh);
+	ifm->ifa_family = AF_INET6;	
+	ifm->ifa_prefixlen = 128;
+	ifm->ifa_flags = IFA_F_PERMANENT;
+	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
+	if (ipv6_addr_scope(&ifmca->mca_addr)&IFA_SITE)
+		ifm->ifa_scope = RT_SCOPE_SITE;
+	ifm->ifa_index = ifmca->idev->dev->ifindex;
+	RTA_PUT(skb, IFA_MULTICAST, 16, &ifmca->mca_addr);
+	ci.cstamp = (__u32)(TIME_DELTA(ifmca->mca_cstamp, INITIAL_JIFFIES) / HZ
+		    * 100 + TIME_DELTA(ifmca->mca_cstamp, INITIAL_JIFFIES) % HZ
+		    * 100 / HZ);
+	ci.tstamp = (__u32)(TIME_DELTA(ifmca->mca_tstamp, INITIAL_JIFFIES) / HZ
+		    * 100 + TIME_DELTA(ifmca->mca_tstamp, INITIAL_JIFFIES) % HZ
+		    * 100 / HZ);
+	ci.ifa_prefered = INFINITY_LIFE_TIME;
+	ci.ifa_valid = INFINITY_LIFE_TIME;
+	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
+				u32 pid, u32 seq, int event)
+{
+	struct ifaddrmsg *ifm;
+	struct nlmsghdr  *nlh;
+	struct ifa_cacheinfo ci;
+	unsigned char	 *b = skb->tail;
+
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
+	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	ifm = NLMSG_DATA(nlh);
+	ifm->ifa_family = AF_INET6;	
+	ifm->ifa_prefixlen = 128;
+	ifm->ifa_flags = IFA_F_PERMANENT;
+	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
+	if (ipv6_addr_scope(&ifaca->aca_addr)&IFA_SITE)
+		ifm->ifa_scope = RT_SCOPE_SITE;
+	ifm->ifa_index = ifaca->aca_idev->dev->ifindex;
+	RTA_PUT(skb, IFA_ANYCAST, 16, &ifaca->aca_addr);
+	ci.cstamp = (__u32)(TIME_DELTA(ifaca->aca_cstamp, INITIAL_JIFFIES) / HZ
+		    * 100 + TIME_DELTA(ifaca->aca_cstamp, INITIAL_JIFFIES) % HZ
+		    * 100 / HZ);
+	ci.tstamp = (__u32)(TIME_DELTA(ifaca->aca_tstamp, INITIAL_JIFFIES) / HZ
+		    * 100 + TIME_DELTA(ifaca->aca_tstamp, INITIAL_JIFFIES) % HZ
+		    * 100 / HZ);
+	ci.ifa_prefered = INFINITY_LIFE_TIME;
+	ci.ifa_valid = INFINITY_LIFE_TIME;
+	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+enum addr_type_t
+{
+	UNICAST_ADDR,
+	MULTICAST_ADDR,
+	ANYCAST_ADDR,
+};
+
+static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
+			   enum addr_type_t type)
 {
 	int idx, ip_idx;
 	int s_idx, s_ip_idx;
@@ -2561,7 +2643,9 @@
 	struct net_device *dev;
 	struct inet6_dev *idev = NULL;
 	struct inet6_ifaddr *ifa;
-	
+	struct ifmcaddr6 *ifmca;
+	struct ifacaddr6 *ifaca;
+
 	s_idx = cb->args[0];
 	s_ip_idx = ip_idx = cb->args[1];
 	read_lock(&dev_base_lock);
@@ -2575,28 +2659,58 @@
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
+		switch (type) {
+		case UNICAST_ADDR:
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
+			break;
+		case MULTICAST_ADDR:
+			/* multicast address */
+			for (ifmca = idev->mc_list; ifmca; 
+			     ifmca = ifmca->next, ip_idx++) {
+				if (ip_idx < s_ip_idx)
+					continue;
+				if ((err = inet6_fill_ifmcaddr(skb, ifmca, 
+				    NETLINK_CB(cb->skb).pid, 
+				    cb->nlh->nlmsg_seq, RTM_GETMULTICAST)) <= 0)
+					goto done;
+			}
+			break;
+		case ANYCAST_ADDR:
+			/* anycast address */
+			for (ifaca = idev->ac_list; ifaca;
+			     ifaca = ifaca->aca_next, ip_idx++) {
+				if (ip_idx < s_ip_idx)
+					continue;
+				if ((err = inet6_fill_ifacaddr(skb, ifaca, 
+				    NETLINK_CB(cb->skb).pid, 
+				    cb->nlh->nlmsg_seq, RTM_GETANYCAST)) <= 0) 
+					goto done;
+			}
+			break;
+		default:
+			break;
+		}
 		read_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
 	}
@@ -2611,6 +2725,25 @@
 	return skb->len;
 }
 
+static int inet6_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	enum addr_type_t type = UNICAST_ADDR;
+	return inet6_dump_addr(skb, cb, type);
+}
+
+static int inet6_dump_ifmcaddr(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	enum addr_type_t type = MULTICAST_ADDR;
+	return inet6_dump_addr(skb, cb, type);
+}
+
+
+static int inet6_dump_ifacaddr(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	enum addr_type_t type = ANYCAST_ADDR;
+	return inet6_dump_addr(skb, cb, type);
+}
+
 static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 {
 	struct sk_buff *skb;
@@ -2835,6 +2968,8 @@
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
 	[RTM_DELADDR - RTM_BASE] = { .doit	= inet6_rtm_deladdr, },
 	[RTM_GETADDR - RTM_BASE] = { .dumpit	= inet6_dump_ifaddr, },
+	[RTM_GETMULTICAST - RTM_BASE] = { .dumpit = inet6_dump_ifmcaddr, },
+	[RTM_GETANYCAST - RTM_BASE] = { .dumpit	= inet6_dump_ifacaddr, },
 	[RTM_NEWROUTE - RTM_BASE] = { .doit	= inet6_rtm_newroute, },
 	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet6_rtm_delroute, },
 	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet6_rtm_getroute,

--Boundary-00=_9accA6m7DJZzaxc--
