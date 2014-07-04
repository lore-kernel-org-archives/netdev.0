From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next-2.6 PATCH v6 2/2] bridge: netlink dump interface at par with brctl
Date: Fri,  4 Jul 2014 07:58:01 -0400
Message-ID: <1404475081-8611-3-git-send-email-jhs@emojatatu.com>
References: <1404475081-8611-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35289 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbaGDL6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 07:58:42 -0400
Received: by mail-ig0-f177.google.com with SMTP id c1so2274690igq.4
        for <netdev@vger.kernel.org>; Fri, 04 Jul 2014 04:58:41 -0700 (PDT)
In-Reply-To: <1404475081-8611-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Actually better than brctl showmacs because we can filter by bridge
port in the kernel.
The current bridge netlink interface doesnt scale when you have many
bridges each with large fdbs or even bridges with many bridge ports

And now for the science non-fiction novel you have all been
waiting for..

//lets see what bridge ports we have
root@moja-1:/configs/may30-iprt/bridge# ./bridge link show
8: eth1 state DOWN : <BROADCAST,MULTICAST> mtu 1500 master br0 state
disabled priority 32 cost 19
17: sw1-p1 state DOWN : <BROADCAST,NOARP> mtu 1500 master br0 state
disabled priority 32 cost 100

// show all..
root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show
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
da:ac:46:27:d9:53 dev sw1-p1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent

//filter by bridge
root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show br br0
02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:07 dev eth1 self permanent
33:33:00:00:00:01 dev eth1 self permanent
da:ac:46:27:d9:53 dev sw1-p1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent

// bridge sw1 has no ports attached..
root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show br sw1

//filter by port
root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show brport eth1
02:00:00:12:01:02 vlan 0 master br0 permanent
00:17:42:8a:b4:05 vlan 0 master br0 permanent
00:17:42:8a:b4:07 self permanent
33:33:00:00:00:01 self permanent

// filter by port + bridge
root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show br br0 brport
sw1-p1
da:ac:46:27:d9:53 vlan 0 master br0 permanent
33:33:00:00:00:01 self permanent

// for shits and giggles (as they say in New Brunswick), lets
// change the mac that br0 uses
// Note: a magical fdb entry with no brport is added ...
root@moja-1:/configs/may30-iprt/bridge# ip link set dev br0 address
02:00:00:12:01:04

// lets see if we can see the unicorn ..
root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show
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
02:00:00:12:01:04 dev br0 vlan 0 master br0 permanent <=== there it is
da:ac:46:27:d9:53 dev sw1-p1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent

//can we see it if we filter by bridge?
root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show br br0
02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:07 dev eth1 self permanent
33:33:00:00:00:01 dev eth1 self permanent
02:00:00:12:01:04 dev br0 vlan 0 master br0 permanent <=== there it is
da:ac:46:27:d9:53 dev sw1-p1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/bridge/br_fdb.c  |   15 ++++++++--
 net/core/rtnetlink.c |   74 +++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 70 insertions(+), 19 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 6edecd1..0bb9d8b 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -692,9 +692,18 @@ int br_fdb_dump(struct sk_buff *skb,
 			if (idx < cb->args[0])
 				goto skip;
 
-			if (filter_dev && (!f->dst || !f->dst->dev ||
-					   f->dst->dev != filter_dev))
-				goto skip;
+			if (filter_dev &&
+			    (!f->dst || f->dst->dev != filter_dev)) {
+				if (filter_dev != dev)
+					goto skip;
+				/* !f->dst is a speacial case for bridge
+				 * It means the MAC belongs to the bridge
+				 * Therefore need a little more filtering
+				 * we only want to dump the !f->dst case
+				 */
+				if (f->dst)
+					goto skip;
+			}
 
 			if (fdb_fill_info(skb, br, f,
 					  NETLINK_CB(cb->skb).portid,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 90a906e..1f8a59e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2535,30 +2535,72 @@ EXPORT_SYMBOL(ndo_dflt_fdb_dump);
 
 static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int idx = 0;
-	struct net *net = sock_net(skb->sk);
 	struct net_device *dev;
+	struct nlattr *tb[IFLA_MAX+1];
+	struct net_device *bdev = NULL;
+	struct net_device *br_dev = NULL;
+	const struct net_device_ops *ops = NULL;
+	const struct net_device_ops *cops = NULL;
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
+
+	if (br_idx) {
+		br_dev = __dev_get_by_index(net, br_idx);
+		if (!br_dev)
+			return -ENODEV;
+
+		ops = br_dev->netdev_ops;
+		bdev = br_dev;
+	}
+
+	for_each_netdev(net, dev) {
+		if (brport_idx && (dev->ifindex != brport_idx))
+			continue;
+
+		if (!br_idx) { /* user did not specify a specific bridge */
+			if (dev->priv_flags & IFF_BRIDGE_PORT) {
+				br_dev = netdev_master_upper_dev_get(dev);
+				cops = br_dev->netdev_ops;
+			}
+
+			bdev = dev;
+		} else {
+			if (dev != br_dev &&
+			    !(dev->priv_flags & IFF_BRIDGE_PORT))
+				continue;
+
+			if (br_dev != netdev_master_upper_dev_get(dev) &&
+			    !(dev->priv_flags & IFF_EBRIDGE))
+				continue;
+
+			bdev = br_dev;
+			cops = ops;
+		}
 
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
 		if (dev->priv_flags & IFF_BRIDGE_PORT) {
-			struct net_device *br_dev;
-			const struct net_device_ops *ops;
-
-			br_dev = netdev_master_upper_dev_get(dev);
-			ops = br_dev->netdev_ops;
-			if (ops->ndo_fdb_dump)
-				idx = ops->ndo_fdb_dump(skb, cb, dev, NULL,
-							idx);
+			if (cops && cops->ndo_fdb_dump)
+				idx = cops->ndo_fdb_dump(skb, cb, br_dev, dev,
+							 idx);
 		}
 
+		idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
 		if (dev->netdev_ops->ndo_fdb_dump)
-			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL,
+			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, bdev, dev,
 							    idx);
-		else
-			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+
+		cops = NULL;
 	}
-	rcu_read_unlock();
 
 	cb->args[0] = idx;
 	return skb->len;
-- 
1.7.9.5
