From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: speedup inet6_dump_ifinfo()
Date: Mon, 09 Nov 2009 23:11:28 +0100
Message-ID: <4AF89390.4000902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54235 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbZKIWL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 17:11:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When handling large number of netdevice, inet6_dump_ifinfo()
is very slow because it has O(N^2) complexity.

Instead of scanning one single list, we can use the 256 sub lists
of the dev_index hash table, and RCU lookups.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/addrconf.c |   45 ++++++++++++++++++++++++++----------------
 1 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 024bba3..f9f7fd6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3823,28 +3823,39 @@ nla_put_failure:
 static int inet6_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-	int idx, err;
-	int s_idx = cb->args[0];
+	int h, s_h;
+	int idx = 0, err, s_idx;
 	struct net_device *dev;
 	struct inet6_dev *idev;
+	struct hlist_head *head;
+	struct hlist_node *node;
 
-	read_lock(&dev_base_lock);
-	idx = 0;
-	for_each_netdev(net, dev) {
-		if (idx < s_idx)
-			goto cont;
-		if ((idev = in6_dev_get(dev)) == NULL)
-			goto cont;
-		err = inet6_fill_ifinfo(skb, idev, NETLINK_CB(cb->skb).pid,
-				cb->nlh->nlmsg_seq, RTM_NEWLINK, NLM_F_MULTI);
-		in6_dev_put(idev);
-		if (err <= 0)
-			break;
+	s_h = cb->args[0];
+	s_idx = cb->args[1];
+
+	rcu_read_lock();
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry_rcu(dev, node, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			idev = __in6_dev_get(dev);
+			if (!idev)
+				goto cont;
+			if (inet6_fill_ifinfo(skb, idev,
+					      NETLINK_CB(cb->skb).pid,
+					      cb->nlh->nlmsg_seq,
+					      RTM_NEWLINK, NLM_F_MULTI) <= 0)
+				goto out;
 cont:
-		idx++;
+			idx++;
+		}
 	}
-	read_unlock(&dev_base_lock);
-	cb->args[0] = idx;
+out:
+	rcu_read_unlock();
+	cb->args[1] = idx;
+	cb->args[0] = h;
 
 	return skb->len;
 }
