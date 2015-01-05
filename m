From: Hubert Sokolowski <hubert.sokolowski@intel.com>
Subject: [PATCH net-next v4] net: Do not call ndo_dflt_fdb_dump if ndo_fdb_dump
 is defined
Date: Mon, 05 Jan 2015 17:29:21 +0000
Message-ID: <54AAC9F1.9060409@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ray.kinsella@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10943 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533AbbAER3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 12:29:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add checking whether the call to ndo_dflt_fdb_dump is needed.
It is not expected to call ndo_dflt_fdb_dump unconditionally
by some drivers (i.e. qlcnic or macvlan) that defines
own ndo_fdb_dump. Other drivers define own ndo_fdb_dump
and don't want ndo_dflt_fdb_dump to be called at all.
At the same time it is desirable to call the default dump
function on a bridge device.
Fix attributes that are passed to dev->netdev_ops->ndo_fdb_dump.
Add extra checking in br_fdb_dump to avoid duplicate entries
as now filter_dev can be NULL.

Following tests for filtering have been performed before
the change and after the patch was applied to make sure
they are the same and it doesn't break the filtering algorithm.

[root@localhost ~]# cd /root/iproute2-3.18.0/bridge
[root@localhost bridge]# modprobe dummy
[root@localhost bridge]# ./bridge fdb add f1:f2:f3:f4:f5:f6 dev dummy0
[root@localhost bridge]# brctl addbr br0
[root@localhost bridge]# brctl addif  br0 dummy0
[root@localhost bridge]# ip link set dev br0 address 02:00:00:12:01:04
[root@localhost bridge]# # show all
[root@localhost bridge]# ./bridge fdb show
33:33:00:00:00:01 dev p2p1 self permanent
01:00:5e:00:00:01 dev p2p1 self permanent
33:33:ff:ac:ce:32 dev p2p1 self permanent
33:33:00:00:02:02 dev p2p1 self permanent
01:00:5e:00:00:fb dev p2p1 self permanent
33:33:00:00:00:01 dev p7p1 self permanent
01:00:5e:00:00:01 dev p7p1 self permanent
33:33:ff:79:50:53 dev p7p1 self permanent
33:33:00:00:02:02 dev p7p1 self permanent
01:00:5e:00:00:fb dev p7p1 self permanent
f2:46:50:85:6d:d9 dev dummy0 master br0 permanent
f2:46:50:85:6d:d9 dev dummy0 vlan 1 master br0 permanent
33:33:00:00:00:01 dev dummy0 self permanent
f1:f2:f3:f4:f5:f6 dev dummy0 self permanent
33:33:00:00:00:01 dev br0 self permanent
02:00:00:12:01:04 dev br0 vlan 1 master br0 permanent
02:00:00:12:01:04 dev br0 master br0 permanent
[root@localhost bridge]# # filter by bridge
[root@localhost bridge]# ./bridge fdb show br br0
f2:46:50:85:6d:d9 dev dummy0 master br0 permanent
f2:46:50:85:6d:d9 dev dummy0 vlan 1 master br0 permanent
33:33:00:00:00:01 dev dummy0 self permanent
f1:f2:f3:f4:f5:f6 dev dummy0 self permanent
33:33:00:00:00:01 dev br0 self permanent
02:00:00:12:01:04 dev br0 vlan 1 master br0 permanent
02:00:00:12:01:04 dev br0 master br0 permanent
[root@localhost bridge]# # filter by port
[root@localhost bridge]# ./bridge fdb show brport dummy0
f2:46:50:85:6d:d9 master br0 permanent
f2:46:50:85:6d:d9 vlan 1 master br0 permanent
33:33:00:00:00:01 self permanent
f1:f2:f3:f4:f5:f6 self permanent
[root@localhost bridge]# # filter by port + bridge
[root@localhost bridge]# ./bridge fdb show br br0 brport dummy0
f2:46:50:85:6d:d9 master br0 permanent
f2:46:50:85:6d:d9 vlan 1 master br0 permanent
33:33:00:00:00:01 self permanent
f1:f2:f3:f4:f5:f6 self permanent
[root@localhost bridge]#

Signed-off-by: Hubert Sokolowski <hubert.sokolowski@intel.com>
---
 net/bridge/br_fdb.c  | 7 ++++++-
 net/core/rtnetlink.c | 5 +++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index cc36e59..e6e0372 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -686,6 +686,9 @@ int br_fdb_dump(struct sk_buff *skb,
 	if (!(dev->priv_flags & IFF_EBRIDGE))
 		goto out;
 
+	if (!filter_dev)
+		idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+
 	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct net_bridge_fdb_entry *f;
 
@@ -697,7 +700,7 @@ int br_fdb_dump(struct sk_buff *skb,
 			    (!f->dst || f->dst->dev != filter_dev)) {
 				if (filter_dev != dev)
 					goto skip;
-				/* !f->dst is a speacial case for bridge
+				/* !f->dst is a special case for bridge
 				 * It means the MAC belongs to the bridge
 				 * Therefore need a little more filtering
 				 * we only want to dump the !f->dst case
@@ -705,6 +708,8 @@ int br_fdb_dump(struct sk_buff *skb,
 				if (f->dst)
 					goto skip;
 			}
+			if (!filter_dev && f->dst)
+				goto skip;
 
 			if (fdb_fill_info(skb, br, f,
 					  NETLINK_CB(cb->skb).portid,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9cf6fe9..da983d4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2698,10 +2698,11 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 							 idx);
 		}
 
-		idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
 		if (dev->netdev_ops->ndo_fdb_dump)
-			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, bdev, dev,
+			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL,
 							    idx);
+		else
+			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
 
 		cops = NULL;
 	}
-- 
1.9.3
