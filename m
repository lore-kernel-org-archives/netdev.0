From: jamal <hadi@cyberus.ca>
Subject: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 08:32:37 -0400
Message-ID: <1117197157.6688.24.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-WvJ4csN17Q9w9js+PpKh"
Cc: Thomas Graf <tgraf@suug.ch>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-WvJ4csN17Q9w9js+PpKh
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


I think i may have missed a few spots.

Thomas it would be worth creating a macro which takes flags as input as
well to replace things along the lines of:
        nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
        nlh->nlmsg_flags = flags;
Since theres a sufficient number of them.

I will work next on fixing ioctl derived events to contain the proper
pid of the process that caused the event

cheers,
jamal
--


This patch rectifies some rtnetlink message builders that derive the
flags from the pid. It is now explicit like the other cases
which get it right.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>




--=-WvJ4csN17Q9w9js+PpKh
Content-Disposition: attachment; filename=rtnet_info_p
Content-Type: text/plain; name=rtnet_info_p; charset=UTF-8
Content-Transfer-Encoding: 7bit

net/core/neighbour.c: needs update
net/core/rtnetlink.c: needs update
net/decnet/dn_route.c: needs update
net/ipv4/devinet.c: needs update
net/ipv4/route.c: needs update
net/ipv6/addrconf.c: needs update
Index: net/core/neighbour.c
===================================================================
--- 2cbffac3afc093b729781fdc58acfb43acc98bc8/net/core/neighbour.c  (mode:100644)
+++ uncommitted/net/core/neighbour.c  (mode:100644)
@@ -1548,7 +1548,7 @@
 
 
 static int neigh_fill_info(struct sk_buff *skb, struct neighbour *n,
-			   u32 pid, u32 seq, int event)
+			   u32 pid, u32 seq, int event, unsigned flags)
 {
 	unsigned long now = jiffies;
 	unsigned char *b = skb->tail;
@@ -1559,7 +1559,7 @@
 					 sizeof(struct ndmsg));
 	struct ndmsg *ndm = NLMSG_DATA(nlh);
 
-	nlh->nlmsg_flags = pid ? NLM_F_MULTI : 0;
+	nlh->nlmsg_flags = flags;
 	ndm->ndm_family	 = n->ops->family;
 	ndm->ndm_flags	 = n->flags;
 	ndm->ndm_type	 = n->type;
@@ -1609,7 +1609,8 @@
 				continue;
 			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
 					    cb->nlh->nlmsg_seq,
-					    RTM_NEWNEIGH) <= 0) {
+					    RTM_NEWNEIGH,
+					    NLM_F_MULTI) <= 0) {
 				read_unlock_bh(&tbl->lock);
 				rc = -1;
 				goto out;
@@ -2018,7 +2019,7 @@
 	if (!skb)
 		return;
 
-	if (neigh_fill_info(skb, n, 0, 0, RTM_GETNEIGH) < 0) {
+	if (neigh_fill_info(skb, n, 0, 0, RTM_GETNEIGH, 0) < 0) {
 		kfree_skb(skb);
 		return;
 	}
@@ -2037,7 +2038,7 @@
 	if (!skb)
 		return;
 
-	if (neigh_fill_info(skb, n, 0, 0, RTM_NEWNEIGH) < 0) {
+	if (neigh_fill_info(skb, n, 0, 0, RTM_NEWNEIGH, 0) < 0) {
 		kfree_skb(skb);
 		return;
 	}
Index: net/core/rtnetlink.c
===================================================================
--- 2cbffac3afc093b729781fdc58acfb43acc98bc8/net/core/rtnetlink.c  (mode:100644)
+++ uncommitted/net/core/rtnetlink.c  (mode:100644)
@@ -176,14 +176,15 @@
 
 
 static int rtnetlink_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
-				 int type, u32 pid, u32 seq, u32 change)
+				 int type, u32 pid, u32 seq, u32 change, 
+				 unsigned flags)
 {
 	struct ifinfomsg *r;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, type, sizeof(*r));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh->nlmsg_flags = flags;
 	r = NLMSG_DATA(nlh);
 	r->ifi_family = AF_UNSPEC;
 	r->ifi_type = dev->type;
@@ -273,7 +274,7 @@
 	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
 		if (idx < s_idx)
 			continue;
-		if (rtnetlink_fill_ifinfo(skb, dev, RTM_NEWLINK, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq, 0) <= 0)
+		if (rtnetlink_fill_ifinfo(skb, dev, RTM_NEWLINK, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq, 0, NLM_F_MULTI) <= 0)
 			break;
 	}
 	read_unlock(&dev_base_lock);
@@ -447,7 +448,7 @@
 	if (!skb)
 		return;
 
-	if (rtnetlink_fill_ifinfo(skb, dev, type, 0, 0, change) < 0) {
+	if (rtnetlink_fill_ifinfo(skb, dev, type, 0, 0, change, 0) < 0) {
 		kfree_skb(skb);
 		return;
 	}
Index: net/decnet/dn_route.c
===================================================================
--- 2cbffac3afc093b729781fdc58acfb43acc98bc8/net/decnet/dn_route.c  (mode:100644)
+++ uncommitted/net/decnet/dn_route.c  (mode:100644)
@@ -1465,7 +1465,7 @@
 	return dn_route_input_slow(skb);
 }
 
-static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event, int nowait)
+static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event, int nowait, unsigned flags)
 {
 	struct dn_route *rt = (struct dn_route *)skb->dst;
 	struct rtmsg *r;
@@ -1475,7 +1475,7 @@
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*r));
 	r = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = (nowait && pid) ? NLM_F_MULTI : 0;
+	nlh->nlmsg_flags = flags;
 	r->rtm_family = AF_DECnet;
 	r->rtm_dst_len = 16;
 	r->rtm_src_len = 0;
@@ -1596,7 +1596,7 @@
 
 	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 
-	err = dn_rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq, RTM_NEWROUTE, 0);
+	err = dn_rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq, RTM_NEWROUTE, 0, 0);
 
 	if (err == 0)
 		goto out_free;
@@ -1644,7 +1644,8 @@
 				continue;
 			skb->dst = dst_clone(&rt->u.dst);
 			if (dn_rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
-					cb->nlh->nlmsg_seq, RTM_NEWROUTE, 1) <= 0) {
+					cb->nlh->nlmsg_seq, RTM_NEWROUTE, 
+					1, NLM_F_MULTI) <= 0) {
 				dst_release(xchg(&skb->dst, NULL));
 				rcu_read_unlock_bh();
 				goto done;
Index: net/ipv4/devinet.c
===================================================================
--- 2cbffac3afc093b729781fdc58acfb43acc98bc8/net/ipv4/devinet.c  (mode:100644)
+++ uncommitted/net/ipv4/devinet.c  (mode:100644)
@@ -1015,14 +1015,14 @@
 };
 
 static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
-			    u32 pid, u32 seq, int event)
+			    u32 pid, u32 seq, int event, unsigned flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh->nlmsg_flags = flags;
 	ifm = NLMSG_DATA(nlh);
 	ifm->ifa_family = AF_INET;
 	ifm->ifa_prefixlen = ifa->ifa_prefixlen;
@@ -1075,7 +1075,7 @@
 				continue;
 			if (inet_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq,
-					     RTM_NEWADDR) <= 0) {
+					     RTM_NEWADDR, NLM_F_MULTI) <= 0) {
 				rcu_read_unlock();
 				goto done;
 			}
@@ -1098,7 +1098,7 @@
 
 	if (!skb)
 		netlink_set_err(rtnl, 0, RTMGRP_IPV4_IFADDR, ENOBUFS);
-	else if (inet_fill_ifaddr(skb, ifa, 0, 0, event) < 0) {
+	else if (inet_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV4_IFADDR, EINVAL);
 	} else {
Index: net/ipv4/route.c
===================================================================
--- 2cbffac3afc093b729781fdc58acfb43acc98bc8/net/ipv4/route.c  (mode:100644)
+++ uncommitted/net/ipv4/route.c  (mode:100644)
@@ -2581,7 +2581,7 @@
 }
 
 static int rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-			int nowait)
+			int nowait, unsigned flags)
 {
 	struct rtable *rt = (struct rtable*)skb->dst;
 	struct rtmsg *r;
@@ -2593,7 +2593,7 @@
 #endif
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*r));
 	r = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = (nowait && pid) ? NLM_F_MULTI : 0;
+	nlh->nlmsg_flags = flags;
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
@@ -2744,7 +2744,7 @@
 	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 
 	err = rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
-				RTM_NEWROUTE, 0);
+				RTM_NEWROUTE, 0, 0);
 	if (!err)
 		goto out_free;
 	if (err < 0) {
@@ -2781,8 +2781,8 @@
 				continue;
 			skb->dst = dst_clone(&rt->u.dst);
 			if (rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
-					 cb->nlh->nlmsg_seq,
-					 RTM_NEWROUTE, 1) <= 0) {
+					 cb->nlh->nlmsg_seq, RTM_NEWROUTE, 
+					 1, NLM_F_MULTI) <= 0) {
 				dst_release(xchg(&skb->dst, NULL));
 				rcu_read_unlock_bh();
 				goto done;
Index: net/ipv6/addrconf.c
===================================================================
--- 2cbffac3afc093b729781fdc58acfb43acc98bc8/net/ipv6/addrconf.c  (mode:100644)
+++ uncommitted/net/ipv6/addrconf.c  (mode:100644)
@@ -2621,7 +2621,7 @@
 }
 
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
-			     u32 pid, u32 seq, int event)
+			     u32 pid, u32 seq, int event, unsigned flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
@@ -2629,7 +2629,7 @@
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh->nlmsg_flags = flags;
 	ifm = NLMSG_DATA(nlh);
 	ifm->ifa_family = AF_INET6;
 	ifm->ifa_prefixlen = ifa->prefix_len;
@@ -2671,7 +2671,7 @@
 }
 
 static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
-				u32 pid, u32 seq, int event)
+				u32 pid, u32 seq, int event, unsigned flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
@@ -2679,7 +2679,7 @@
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh->nlmsg_flags = flags;
 	ifm = NLMSG_DATA(nlh);
 	ifm->ifa_family = AF_INET6;	
 	ifm->ifa_prefixlen = 128;
@@ -2708,7 +2708,7 @@
 }
 
 static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
-				u32 pid, u32 seq, int event)
+				u32 pid, u32 seq, int event, unsigned flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
@@ -2716,7 +2716,7 @@
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh->nlmsg_flags = flags;
 	ifm = NLMSG_DATA(nlh);
 	ifm->ifa_family = AF_INET6;	
 	ifm->ifa_prefixlen = 128;
@@ -2785,7 +2785,8 @@
 					continue;
 				if ((err = inet6_fill_ifaddr(skb, ifa, 
 				    NETLINK_CB(cb->skb).pid, 
-				    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0)
+				    cb->nlh->nlmsg_seq, RTM_NEWADDR,
+				    NLM_F_MULTI)) <= 0)
 					goto done;
 			}
 			/* temp addr */
@@ -2796,7 +2797,8 @@
 					continue;
 				if ((err = inet6_fill_ifaddr(skb, ifa, 
 				    NETLINK_CB(cb->skb).pid, 
-				    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
+				    cb->nlh->nlmsg_seq, RTM_NEWADDR,
+				    NLM_F_MULTI)) <= 0) 
 					goto done;
 			}
 #endif
@@ -2809,7 +2811,8 @@
 					continue;
 				if ((err = inet6_fill_ifmcaddr(skb, ifmca, 
 				    NETLINK_CB(cb->skb).pid, 
-				    cb->nlh->nlmsg_seq, RTM_GETMULTICAST)) <= 0)
+				    cb->nlh->nlmsg_seq, RTM_GETMULTICAST,
+				    NLM_F_MULTI)) <= 0)
 					goto done;
 			}
 			break;
@@ -2821,7 +2824,8 @@
 					continue;
 				if ((err = inet6_fill_ifacaddr(skb, ifaca, 
 				    NETLINK_CB(cb->skb).pid, 
-				    cb->nlh->nlmsg_seq, RTM_GETANYCAST)) <= 0) 
+				    cb->nlh->nlmsg_seq, RTM_GETANYCAST,
+				    NLM_F_MULTI)) <= 0) 
 					goto done;
 			}
 			break;
@@ -2871,7 +2875,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFADDR, ENOBUFS);
 		return;
 	}
-	if (inet6_fill_ifaddr(skb, ifa, 0, 0, event) < 0) {
+	if (inet6_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFADDR, EINVAL);
 		return;
@@ -2906,7 +2910,7 @@
 }
 
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev, 
-			     u32 pid, u32 seq, int event)
+			     u32 pid, u32 seq, int event, unsigned flags)
 {
 	struct net_device	*dev = idev->dev;
 	__s32			*array = NULL;
@@ -2918,7 +2922,7 @@
 	struct ifla_cacheinfo	ci;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*r));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh->nlmsg_flags = flags;
 	r = NLMSG_DATA(nlh);
 	r->ifi_family = AF_INET6;
 	r->ifi_type = dev->type;
@@ -2985,7 +2989,7 @@
 		if ((idev = in6_dev_get(dev)) == NULL)
 			continue;
 		err = inet6_fill_ifinfo(skb, idev, NETLINK_CB(cb->skb).pid, 
-				cb->nlh->nlmsg_seq, RTM_NEWLINK);
+				cb->nlh->nlmsg_seq, RTM_NEWLINK, NLM_F_MULTI);
 		in6_dev_put(idev);
 		if (err <= 0)
 			break;
@@ -3007,7 +3011,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFINFO, ENOBUFS);
 		return;
 	}
-	if (inet6_fill_ifinfo(skb, idev, 0, 0, event) < 0) {
+	if (inet6_fill_ifinfo(skb, idev, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFINFO, EINVAL);
 		return;
@@ -3017,7 +3021,8 @@
 }
 
 static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
-			struct prefix_info *pinfo, u32 pid, u32 seq, int event)
+			struct prefix_info *pinfo, u32 pid, u32 seq, 
+			int event, unsigned flags)
 {
 	struct prefixmsg	*pmsg;
 	struct nlmsghdr 	*nlh;
@@ -3025,9 +3030,7 @@
 	struct prefix_cacheinfo	ci;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*pmsg));
-	
-	if (pid) 
-		nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh->nlmsg_flags = flags;
 	
 	pmsg = NLMSG_DATA(nlh);
 	pmsg->prefix_family = AF_INET6;
@@ -3067,7 +3070,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_PREFIX, ENOBUFS);
 		return;
 	}
-	if (inet6_fill_prefix(skb, idev, pinfo, 0, 0, event) < 0) {
+	if (inet6_fill_prefix(skb, idev, pinfo, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_PREFIX, EINVAL);
 		return;

--=-WvJ4csN17Q9w9js+PpKh--
