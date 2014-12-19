From: Hubert Sokolowski <hubert.sokolowski@intel.com>
Subject: [PATCH net-next v3] net: Do not call ndo_dflt_fdb_dump if ndo_fdb_dump
 is defined
Date: Fri, 19 Dec 2014 12:14:01 +0000
Message-ID: <54941689.7060100@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ray.kinsella@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50315 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752545AbaLSMOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 07:14:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add checking whether the call to ndo_dflt_fdb_dump is needed.
It is not expected to call ndo_dflt_fdb_dump unconditionally
by some drivers (i.e. qlcnic or macvlan) that defines
own ndo_fdb_dump. Other drivers define own ndo_fdb_dump
and don't want ndo_dflt_fdb_dump to be called at all.
At the same time it is desirable to call the default dump
function on a bridge device.

Following tests for filtering have been performed before
the change and after the patch was applied to make sure
they are the same and it doesn't break the filtering algorithm.

[root@localhost ~]# cd /root/iproute2-3.17.0/bridge
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
7e:0c:8b:b1:59:da dev dummy0 master br0 permanent
7e:0c:8b:b1:59:da dev dummy0 vlan 1 master br0 permanent
33:33:00:00:00:01 dev dummy0 self permanent
f1:f2:f3:f4:f5:f6 dev dummy0 self permanent
33:33:00:00:00:01 dev br0 self permanent
02:00:00:12:01:04 dev br0 vlan 1 master br0 permanent
02:00:00:12:01:04 dev br0 master br0 permanent
[root@localhost bridge]# # filter by bridge
[root@localhost bridge]# ./bridge fdb show br br0
7e:0c:8b:b1:59:da dev dummy0 master br0 permanent
7e:0c:8b:b1:59:da dev dummy0 vlan 1 master br0 permanent
33:33:00:00:00:01 dev dummy0 self permanent
f1:f2:f3:f4:f5:f6 dev dummy0 self permanent
33:33:00:00:00:01 dev br0 self permanent
02:00:00:12:01:04 dev br0 vlan 1 master br0 permanent
02:00:00:12:01:04 dev br0 master br0 permanent
[root@localhost bridge]# # filter by port
[root@localhost bridge]# ./bridge fdb show brport dummy0
7e:0c:8b:b1:59:da master br0 permanent
7e:0c:8b:b1:59:da vlan 1 master br0 permanent
33:33:00:00:00:01 self permanent
f1:f2:f3:f4:f5:f6 self permanent
[root@localhost bridge]# # filter by port + bridge
[root@localhost bridge]# ./bridge fdb show br br0 brport dummy0
7e:0c:8b:b1:59:da master br0 permanent
7e:0c:8b:b1:59:da vlan 1 master br0 permanent
33:33:00:00:00:01 self permanent
f1:f2:f3:f4:f5:f6 self permanent
[root@localhost bridge]#

Also following test was performed to proove it fixes the problem
with macvlan driver where dflt_fdb_dump was called twice showing
duplicate self entries:
[root@localhost bridge]# modprobe dummy
[root@localhost bridge]# ip li add link dummy0 mac0 type macvlan
[root@localhost bridge]# ./bridge fdb show dev mac0
33:33:00:00:00:01 self permanent
[root@localhost bridge]#

Signed-off-by: Hubert Sokolowski <hubert.sokolowski@intel.com>
---
 net/core/rtnetlink.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d06107d..d32518c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2693,7 +2693,10 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 							 idx);
 		}
 
-		idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+		if ((dev->priv_flags & IFF_EBRIDGE) ||
+		    !(dev->netdev_ops->ndo_fdb_dump))
+			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+
 		if (dev->netdev_ops->ndo_fdb_dump)
 			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, bdev, dev,
 							    idx);
-- 
1.9.3
