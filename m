From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 2/2] bridge netlink dump interface at par with brctl Actually better than brctl showmacs because we can filter by bridge port in the kernel
Date: Sun,  1 Jun 2014 07:56:20 -0400
Message-ID: <1401623780-4297-2-git-send-email-jhs@emojatatu.com>
References: <1401623780-4297-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:61455 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbaFAL4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 07:56:45 -0400
Received: by mail-ie0-f181.google.com with SMTP id rp18so3390657iec.40
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 04:56:44 -0700 (PDT)
In-Reply-To: <1401623780-4297-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

The current bridge netlink interface doesnt scale when you have many bridges each
with large fdbs or even bridges with many bridge ports

Example usage:

Lets start with two bridges each with a port...

root@moja-mojo:bridge# ./bridge link
8: eth1 state DOWN : <BROADCAST,MULTICAST> mtu 1500 master br0 state disabled priority 32 cost 19
17: sw1-p1 state DOWN : <BROADCAST,NOARP> mtu 1500 master sw1 state disabled priority 32 cost 100

show all...
root@moja-mojo:bridge# ./bridge fdb show
33:33:00:00:00:01 dev bond0 self permanent
33:33:00:00:00:01 dev dummy0 self permanent
33:33:00:00:00:01 dev ifb0 self permanent
33:33:00:00:00:01 dev ifb1 self permanent
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:22:01:01 dev eth0 self permanent
02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:07 dev eth1 self permanent
33:33:00:00:00:01 dev eth1 self permanent
33:33:00:00:00:01 dev gretap0 self permanent
33:33:00:00:00:01 dev br0 self permanent
33:33:00:00:00:01 dev sw1 self permanent
a2:fb:21:4c:47:25 dev sw1-p1 vlan 0 master sw1 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent

Lets see a port that is not attached to a bridge
root@moja-mojo:bridge# ./bridge fdb show brport eth0
33:33:00:00:00:01 self permanent
01:00:5e:00:00:01 self permanent
33:33:ff:22:01:01 self permanent

Lets see a port that is attached to a bridge
root@moja-mojo:bridge# ./bridge fdb show brport eth1
02:00:00:12:01:02 vlan 0 master br0 permanent
00:17:42:8a:b4:05 vlan 0 master br0 permanent
00:17:42:8a:b4:07 self permanent
33:33:00:00:00:01 self permanent

Specify the correct bridge and you get good stuff
root@moja-mojo:bridge# ./bridge fdb show brport eth1 br br0
02:00:00:12:01:02 vlan 0 master br0 permanent
00:17:42:8a:b4:05 vlan 0 master br0 permanent
00:17:42:8a:b4:07 self permanent
33:33:00:00:00:01 self permanent

Specify the wrong bridge and you get good nada
root@moja-mojo:bridge# ./bridge fdb show brport eth1 br sw1

dump only br0
root@moja-mojo:bridge# ./bridge fdb show br br0
02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:07 dev eth1 self permanent
33:33:00:00:00:01 dev eth1 self permanent

Lets move a port from one bridge to another for shits-and-giggles
(as they say in New Brunswick)
root@moja-mojo:bridge# ip link set sw1-p1 master br0

Now dump again br0
root@moja-mojo:bridge# ./bridge fdb show br br0
02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:07 dev eth1 self permanent
33:33:00:00:00:01 dev eth1 self permanent
a2:fb:21:4c:47:25 dev sw1-p1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/core/rtnetlink.c |   68 +++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 56 insertions(+), 12 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 064418e..71e6bc8 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2508,26 +2508,70 @@ EXPORT_SYMBOL(ndo_dflt_fdb_dump);
 
 static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int idx = 0;
-	struct net *net = sock_net(skb->sk);
 	struct net_device *dev;
+	struct net_device *br_dev;
+	struct nlattr *tb[IFLA_MAX+1];
+	const struct net_device_ops *ops;
+	struct ifinfomsg *ifm = nlmsg_data(cb->nlh);
+	struct net *net = sock_net(skb->sk);
+	int brport_idx = 0;
+	int br_idx = 0;
+	int idx = 0;
+
+	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
+			ifla_policy) == 0) {
+		if (tb[IFLA_MASTER])
+			br_idx = nla_get_u32(tb[IFLA_MASTER]);
+	}
+	
+	brport_idx = ifm->ifi_index;
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-		if (dev->priv_flags & IFF_BRIDGE_PORT) {
-			struct net_device *br_dev;
-			const struct net_device_ops *ops;
 
-			br_dev = netdev_master_upper_dev_get(dev);
+		if (brport_idx && (dev->ifindex != brport_idx))
+			continue;
+
+		if (!br_idx) {
+			if (dev->priv_flags & IFF_BRIDGE_PORT) {
+				br_dev = netdev_master_upper_dev_get(dev);
+				ops = br_dev->netdev_ops;
+				if (ops->ndo_fdb_dump)
+					idx = ops->ndo_fdb_dump(skb, cb, br_dev,
+								dev, idx);
+			}
+
+			/* all of bridge fdb entries are dumped via brports fdb
+			 * therefore only allow for selfies for bridges
+			*/
+			if (!(dev->priv_flags & IFF_EBRIDGE) &&
+			      dev->netdev_ops->ndo_fdb_dump)
+				idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev,
+								    NULL, idx);
+			else
+				idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+
+		} else {
+			if (!(dev->priv_flags & IFF_BRIDGE_PORT))
+				continue;
+
+			br_dev = __dev_get_by_index(net, br_idx);
+			if (!br_dev)
+				return -ENODEV;
+
+			if (br_dev != netdev_master_upper_dev_get(dev))
+				continue;
+
 			ops = br_dev->netdev_ops;
 			if (ops->ndo_fdb_dump)
-				idx = ops->ndo_fdb_dump(skb, cb, dev, NULL, idx);
-		}
+				idx = ops->ndo_fdb_dump(skb, cb, br_dev, dev, idx);
 
-		if (dev->netdev_ops->ndo_fdb_dump)
-			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL, idx);
-		else
-			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+			if (dev->netdev_ops->ndo_fdb_dump)
+				idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev,
+								    NULL, idx);
+			else
+				idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+		}
 	}
 	rcu_read_unlock();
 
-- 
1.7.9.5
