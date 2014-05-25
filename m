From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 1/1] bring netlink interface to par with brctl show macs
Date: Sun, 25 May 2014 09:15:55 -0400
Message-ID: <1401023755-8174-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	vyasevic@redhat.com, john.r.fastabend@intel.com,
	sfeldma@cumulusnetworks.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:38518 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbaEYNQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 09:16:05 -0400
Received: by mail-pa0-f45.google.com with SMTP id ey11so6286158pad.4
        for <netdev@vger.kernel.org>; Sun, 25 May 2014 06:16:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This patch allows something equivalent to
"brctl showmacs <bridge device>" with iproute2
syntax "bridge fdb show br <bridge device>"
Filtering by bridge is done in the kernel.
The current setup doesnt scale when you have many bridges each
with large fdbs (preliminary fix with the kernel patch).

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/core/rtnetlink.c |   49 ++++++++++++++++++++++++++++++++++---------------
 1 file changed, 34 insertions(+), 15 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f31268d..1ad4828 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2509,26 +2509,45 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx = 0;
 	struct net *net = sock_net(skb->sk);
+	const struct net_device_ops *ops;
 	struct net_device *dev;
+	struct ndmsg *ndm;
 
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
-		if (dev->priv_flags & IFF_BRIDGE_PORT) {
-			struct net_device *br_dev;
-			const struct net_device_ops *ops;
-
-			br_dev = netdev_master_upper_dev_get(dev);
-			ops = br_dev->netdev_ops;
-			if (ops->ndo_fdb_dump)
-				idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
+	ndm = nlmsg_data(cb->nlh);
+	if (ndm->ndm_ifindex) {
+		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
+		if (dev == NULL) {
+			pr_info("PF_BRIDGE: RTM_GETNEIGH with unknown ifindex\n");
+			return -ENODEV;
 		}
 
-		if (dev->netdev_ops->ndo_fdb_dump)
-			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, idx);
-		else
-			idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
+		ops = dev->netdev_ops;
+		if (ops->ndo_fdb_dump) {
+			idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
+		} else {
+			pr_info("PF_BRIDGE: RTM_GETNEIGH %s no dumper\n",
+				dev->name);
+			return -EINVAL;
+		}
+	} else {
+		rcu_read_lock();
+		for_each_netdev_rcu(net, dev) {
+			if (dev->priv_flags & IFF_BRIDGE_PORT) {
+				struct net_device *br_dev;
+				br_dev = netdev_master_upper_dev_get(dev);
+				ops = br_dev->netdev_ops;
+				if (ops->ndo_fdb_dump)
+					idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
+			}
+
+			if (dev->netdev_ops->ndo_fdb_dump)
+				idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev,
+								    idx);
+			else
+				idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
+		}
+		rcu_read_unlock();
 	}
-	rcu_read_unlock();
 
 	cb->args[0] = idx;
 	return skb->len;
-- 
1.7.9.5
