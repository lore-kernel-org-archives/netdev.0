From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: speedup inet6_dump_addr()
Date: Thu, 12 Nov 2009 15:11:50 +0100
Message-ID: <4AFC17A6.4040801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37585 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbZKLOLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 09:11:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When handling large number of netdevices, inet6_dump_addr()
is very slow because it has O(N^2) complexity.

Instead of scanning one single list, we can use the NETDEV_HASHENTRIES
sub lists of the dev_index hash table, and RCU lookups.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/addrconf.c |  171 +++++++++++++++++++++++-------------------
 1 files changed, 97 insertions(+), 74 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9ff8ab9..522bdc7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3481,91 +3481,114 @@ enum addr_type_t
 	ANYCAST_ADDR,
 };
 
+/* called with rcu_read_lock() */
+static int in6_dump_addrs(struct inet6_dev *idev, struct sk_buff *skb,
+			  struct netlink_callback *cb, enum addr_type_t type,
+			  int s_ip_idx, int *p_ip_idx)
+{
+	struct inet6_ifaddr *ifa;
+	struct ifmcaddr6 *ifmca;
+	struct ifacaddr6 *ifaca;
+	int err = 1;
+	int ip_idx = *p_ip_idx;
+
+	read_lock_bh(&idev->lock);
+	switch (type) {
+	case UNICAST_ADDR:
+		/* unicast address incl. temp addr */
+		for (ifa = idev->addr_list; ifa;
+		     ifa = ifa->if_next, ip_idx++) {
+			if (ip_idx < s_ip_idx)
+				continue;
+			err = inet6_fill_ifaddr(skb, ifa,
+						NETLINK_CB(cb->skb).pid,
+						cb->nlh->nlmsg_seq,
+						RTM_NEWADDR,
+						NLM_F_MULTI);
+			if (err <= 0)
+				break;
+		}
+		break;
+	case MULTICAST_ADDR:
+		/* multicast address */
+		for (ifmca = idev->mc_list; ifmca;
+		     ifmca = ifmca->next, ip_idx++) {
+			if (ip_idx < s_ip_idx)
+				continue;
+			err = inet6_fill_ifmcaddr(skb, ifmca,
+						  NETLINK_CB(cb->skb).pid,
+						  cb->nlh->nlmsg_seq,
+						  RTM_GETMULTICAST,
+						  NLM_F_MULTI);
+			if (err <= 0)
+				break;
+		}
+		break;
+	case ANYCAST_ADDR:
+		/* anycast address */
+		for (ifaca = idev->ac_list; ifaca;
+		     ifaca = ifaca->aca_next, ip_idx++) {
+			if (ip_idx < s_ip_idx)
+				continue;
+			err = inet6_fill_ifacaddr(skb, ifaca,
+						  NETLINK_CB(cb->skb).pid,
+						  cb->nlh->nlmsg_seq,
+						  RTM_GETANYCAST,
+						  NLM_F_MULTI);
+			if (err <= 0)
+				break;
+		}
+		break;
+	default:
+		break;
+	}
+	read_unlock_bh(&idev->lock);
+	*p_ip_idx = ip_idx;
+	return err;
+}
+
 static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 			   enum addr_type_t type)
 {
+	struct net *net = sock_net(skb->sk);
+	int h, s_h;
 	int idx, ip_idx;
 	int s_idx, s_ip_idx;
-	int err = 1;
 	struct net_device *dev;
-	struct inet6_dev *idev = NULL;
-	struct inet6_ifaddr *ifa;
-	struct ifmcaddr6 *ifmca;
-	struct ifacaddr6 *ifaca;
-	struct net *net = sock_net(skb->sk);
+	struct inet6_dev *idev;
+	struct hlist_head *head;
+	struct hlist_node *node;
 
-	s_idx = cb->args[0];
-	s_ip_idx = ip_idx = cb->args[1];
+	s_h = cb->args[0];
+	s_idx = idx = cb->args[1];
+	s_ip_idx = ip_idx = cb->args[2];
 
-	idx = 0;
-	for_each_netdev(net, dev) {
-		if (idx < s_idx)
-			goto cont;
-		if (idx > s_idx)
-			s_ip_idx = 0;
-		ip_idx = 0;
-		if ((idev = in6_dev_get(dev)) == NULL)
-			goto cont;
-		read_lock_bh(&idev->lock);
-		switch (type) {
-		case UNICAST_ADDR:
-			/* unicast address incl. temp addr */
-			for (ifa = idev->addr_list; ifa;
-			     ifa = ifa->if_next, ip_idx++) {
-				if (ip_idx < s_ip_idx)
-					continue;
-				err = inet6_fill_ifaddr(skb, ifa,
-							NETLINK_CB(cb->skb).pid,
-							cb->nlh->nlmsg_seq,
-							RTM_NEWADDR,
-							NLM_F_MULTI);
-				if (err <= 0)
-					break;
-			}
-			break;
-		case MULTICAST_ADDR:
-			/* multicast address */
-			for (ifmca = idev->mc_list; ifmca;
-			     ifmca = ifmca->next, ip_idx++) {
-				if (ip_idx < s_ip_idx)
-					continue;
-				err = inet6_fill_ifmcaddr(skb, ifmca,
-							  NETLINK_CB(cb->skb).pid,
-							  cb->nlh->nlmsg_seq,
-							  RTM_GETMULTICAST,
-							  NLM_F_MULTI);
-				if (err <= 0)
-					break;
-			}
-			break;
-		case ANYCAST_ADDR:
-			/* anycast address */
-			for (ifaca = idev->ac_list; ifaca;
-			     ifaca = ifaca->aca_next, ip_idx++) {
-				if (ip_idx < s_ip_idx)
-					continue;
-				err = inet6_fill_ifacaddr(skb, ifaca,
-							  NETLINK_CB(cb->skb).pid,
-							  cb->nlh->nlmsg_seq,
-							  RTM_GETANYCAST,
-							  NLM_F_MULTI);
-				if (err <= 0)
-					break;
-			}
-			break;
-		default:
-			break;
-		}
-		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
+	rcu_read_lock();
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry_rcu(dev, node, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			if (idx > s_idx)
+				s_ip_idx = 0;
+			ip_idx = 0;
+			if ((idev = __in6_dev_get(dev)) == NULL)
+				goto cont;
 
-		if (err <= 0)
-			break;
+			if (in6_dump_addrs(idev, skb, cb, type,
+					   s_ip_idx, &ip_idx) <= 0)
+				goto done;
 cont:
-		idx++;
+			idx++;
+		}
 	}
-	cb->args[0] = idx;
-	cb->args[1] = ip_idx;
+done:
+	rcu_read_unlock();
+	cb->args[0] = h;
+	cb->args[1] = idx;
+	cb->args[2] = ip_idx;
+
 	return skb->len;
 }
 
