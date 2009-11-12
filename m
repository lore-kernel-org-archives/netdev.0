From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: speedup inet_dump_ifaddr()
Date: Thu, 12 Nov 2009 15:11:36 +0100
Message-ID: <4AFC1798.1060501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37580 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbZKLOLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 09:11:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When handling large number of netdevices, inet_dump_ifaddr()
is very slow because it has O(N^2) complexity.

Instead of scanning one single list, we can use the NETDEV_HASHENTRIES
sub lists of the dev_index hash table, and RCU lookups.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/devinet.c |   57 ++++++++++++++++++++++++++-----------------
 1 files changed, 35 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index c2045f9..a74cb4e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1174,39 +1174,52 @@ nla_put_failure:
 static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-	int idx, ip_idx;
+	int h, s_h;
+	int idx, s_idx;
+	int ip_idx, s_ip_idx;
 	struct net_device *dev;
 	struct in_device *in_dev;
 	struct in_ifaddr *ifa;
-	int s_ip_idx, s_idx = cb->args[0];
+	struct hlist_head *head;
+	struct hlist_node *node;
 
-	s_ip_idx = ip_idx = cb->args[1];
-	idx = 0;
-	for_each_netdev(net, dev) {
-		if (idx < s_idx)
-			goto cont;
-		if (idx > s_idx)
-			s_ip_idx = 0;
-		in_dev = __in_dev_get_rtnl(dev);
-		if (!in_dev)
-			goto cont;
+	s_h = cb->args[0];
+	s_idx = idx = cb->args[1];
+	s_ip_idx = ip_idx = cb->args[2];
 
-		for (ifa = in_dev->ifa_list, ip_idx = 0; ifa;
-		     ifa = ifa->ifa_next, ip_idx++) {
-			if (ip_idx < s_ip_idx)
-				continue;
-			if (inet_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
+	rcu_read_lock();
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry_rcu(dev, node, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			if (idx > s_idx)
+				s_ip_idx = 0;
+			in_dev = __in_dev_get_rcu(dev);
+			if (!in_dev)
+				goto cont;
+
+			for (ifa = in_dev->ifa_list, ip_idx = 0; ifa;
+			     ifa = ifa->ifa_next, ip_idx++) {
+				if (ip_idx < s_ip_idx)
+					continue;
+				if (inet_fill_ifaddr(skb, ifa,
+					     NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq,
 					     RTM_NEWADDR, NLM_F_MULTI) <= 0)
-				goto done;
-		}
+					goto done;
+			}
 cont:
-		idx++;
+			idx++;
+		}
 	}
 
 done:
-	cb->args[0] = idx;
-	cb->args[1] = ip_idx;
+	rcu_read_unlock();
+	cb->args[0] = h;
+	cb->args[1] = idx;
+	cb->args[2] = ip_idx;
 
 	return skb->len;
 }
