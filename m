From: Andrey Savochkin <saw@swsoft.com>
Subject: [patch 3/7] net_device list cleanup: netlink_dump
Date: Mon, 3 Jul 2006 12:18:53 +0400
Message-ID: <20060630154639.D22285@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:33544 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1750946AbWGCQcA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 12:32:00 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060630150823.A22285@castle.nmd.msu.ru>; from "Andrey Savochkin" on Fri, Jun 30, 2006 at 03:08:23PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup of net_device list use in netlink_dump routines in core networking
files.

The cleanup consists of
 - converting the to list_head, to make the list double-linked (thus making
   remove operation O(1)), and list walks more readable;
 - introducing of for_each_netdev wrapper over list_for_each.

Signed-off-by: Andrey Savochkin <saw@swsoft.com>
---
 core/rtnetlink.c |   18 ++++++++++--------
 ipv4/devinet.c   |   14 ++++++++------
 ipv6/addrconf.c  |   20 +++++++++++++-------
 sched/sch_api.c  |    8 ++++++--
 4 files changed, 37 insertions(+), 23 deletions(-)

--- ./net/core/rtnetlink.c.vedevbase-dump	Mon Jul  3 15:14:19 2006
+++ ./net/core/rtnetlink.c	Mon Jul  3 16:10:12 2006
@@ -319,14 +319,16 @@ static int rtnetlink_dump_ifinfo(struct 
 	struct net_device *dev;
 
 	read_lock(&dev_base_lock);
-	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
-		if (idx < s_idx)
-			continue;
-		if (rtnetlink_fill_ifinfo(skb, dev, RTM_NEWLINK,
-					  NETLINK_CB(cb->skb).pid,
-					  cb->nlh->nlmsg_seq, 0,
-					  NLM_F_MULTI) <= 0)
-			break;
+	idx = 0;
+	for_each_netdev(dev) {
+		if (idx >= s_idx) {
+			if (rtnetlink_fill_ifinfo(skb, dev, RTM_NEWLINK,
+						  NETLINK_CB(cb->skb).pid,
+						  cb->nlh->nlmsg_seq, 0,
+						  NLM_F_MULTI) <= 0)
+				break;
+		}
+		idx++;
 	}
 	read_unlock(&dev_base_lock);
 	cb->args[0] = idx;
--- ./net/ipv4/devinet.c.vedevbase-dump	Mon Jul  3 16:10:12 2006
+++ ./net/ipv4/devinet.c	Mon Jul  3 16:10:12 2006
@@ -1094,18 +1094,17 @@ static int inet_dump_ifaddr(struct sk_bu
 	struct in_ifaddr *ifa;
 	int s_ip_idx, s_idx = cb->args[0];
 
+	idx = 0;
 	s_ip_idx = ip_idx = cb->args[1];
 	read_lock(&dev_base_lock);
-	for (dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
+	for_each_netdev(dev) {
 		if (idx < s_idx)
-			continue;
+			goto cont;
 		if (idx > s_idx)
 			s_ip_idx = 0;
 		rcu_read_lock();
-		if ((in_dev = __in_dev_get_rcu(dev)) == NULL) {
-			rcu_read_unlock();
-			continue;
-		}
+		if ((in_dev = __in_dev_get_rcu(dev)) == NULL)
+			goto cont_unlock;
 
 		for (ifa = in_dev->ifa_list, ip_idx = 0; ifa;
 		     ifa = ifa->ifa_next, ip_idx++) {
@@ -1118,7 +1117,10 @@ static int inet_dump_ifaddr(struct sk_bu
 				goto done;
 			}
 		}
+cont_unlock:
 		rcu_read_unlock();
+cont:
+		idx++;
 	}
 
 done:
--- ./net/ipv6/addrconf.c.vedevbase-dump	Mon Jul  3 16:10:12 2006
+++ ./net/ipv6/addrconf.c	Mon Jul  3 16:10:12 2006
@@ -3013,18 +3013,19 @@ static int inet6_dump_addr(struct sk_buf
 	struct ifmcaddr6 *ifmca;
 	struct ifacaddr6 *ifaca;
 
+	idx = 0;
 	s_idx = cb->args[0];
 	s_ip_idx = ip_idx = cb->args[1];
 	read_lock(&dev_base_lock);
 	
-	for (dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
+	for_each_netdev(dev) {
 		if (idx < s_idx)
-			continue;
+			goto cont;
 		if (idx > s_idx)
 			s_ip_idx = 0;
 		ip_idx = 0;
 		if ((idev = in6_dev_get(dev)) == NULL)
-			continue;
+			goto cont;
 		read_lock_bh(&idev->lock);
 		switch (type) {
 		case UNICAST_ADDR:
@@ -3071,6 +3072,8 @@ static int inet6_dump_addr(struct sk_buf
 		}
 		read_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
+cont:
+		idx++;
 	}
 done:
 	if (err <= 0) {
@@ -3238,17 +3241,20 @@ static int inet6_dump_ifinfo(struct sk_b
 	struct net_device *dev;
 	struct inet6_dev *idev;
 
+	idx = 0;
 	read_lock(&dev_base_lock);
-	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
+	for_each_netdev(dev) {
 		if (idx < s_idx)
-			continue;
+			goto cont;
 		if ((idev = in6_dev_get(dev)) == NULL)
-			continue;
+			goto cont;
 		err = inet6_fill_ifinfo(skb, idev, NETLINK_CB(cb->skb).pid, 
 				cb->nlh->nlmsg_seq, RTM_NEWLINK, NLM_F_MULTI);
 		in6_dev_put(idev);
 		if (err <= 0)
 			break;
+cont:
+		idx++;
 	}
 	read_unlock(&dev_base_lock);
 	cb->args[0] = idx;
@@ -3872,7 +3878,7 @@ void __exit addrconf_cleanup(void)
 	 *	clean dev list.
 	 */
 
-	for (dev=dev_base; dev; dev=dev->next) {
+	for_each_netdev(dev) {
 		if ((idev = __in6_dev_get(dev)) == NULL)
 			continue;
 		addrconf_ifdown(dev, 1);
--- ./net/sched/sch_api.c.vedevbase-dump	Mon Jul  3 15:14:22 2006
+++ ./net/sched/sch_api.c	Mon Jul  3 16:10:12 2006
@@ -829,12 +829,15 @@ static int tc_dump_qdisc(struct sk_buff 
 	struct net_device *dev;
 	struct Qdisc *q;
 
+	idx = 0;
 	s_idx = cb->args[0];
 	s_q_idx = q_idx = cb->args[1];
 	read_lock(&dev_base_lock);
-	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
-		if (idx < s_idx)
+	for_each_netdev(dev) {
+		if (idx < s_idx) {
+			idx++;
 			continue;
+		}
 		if (idx > s_idx)
 			s_q_idx = 0;
 		read_lock_bh(&qdisc_tree_lock);
@@ -852,6 +855,7 @@ static int tc_dump_qdisc(struct sk_buff 
 			q_idx++;
 		}
 		read_unlock_bh(&qdisc_tree_lock);
+		idx++;
 	}
 
 done:
