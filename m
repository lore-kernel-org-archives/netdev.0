From: Jon Maxwell <jmaxwell37@gmail.com>
Subject: [PATCH net] bridge: notify user space after fdb update
Date: Wed, 28 May 2014 08:45:49 +1000
Message-ID: <1401230749-19507-1-git-send-email-jmaxwell37@gmail.com>
Cc: davem@davemloft.net, makita.toshiaki@lab.ntt.co.jp,
	vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jpirko@redhat.com, jmaxwell37@gmail.com, jmaxwell@redhat.com
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There has been a number incidents recently where customers running KVM have
reported that VM hosts on different Hypervisors are unreachable. Based on
pcap traces we found that the bridge was broadcasting the ARP request out
onto the network. However some NICs have an inbuilt switch which on occasions
were broadcasting the VMs ARP request back through the physical NIC on the
Hypervisor. This resulted in the bridge changing ports and incorrectly learning
that the VMs mac address was external. As a result the ARP reply was directed
back onto the external network and VM never updated it's ARP cache. This patch
will notify the bridge command, after a fdb has been updated to identify such
port toggling.

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
---
 net/bridge/br_fdb.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9203d5a..f3ee2da 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -487,6 +487,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
+	bool fdb_modified = 0;
 
 	/* some users want to always flood. */
 	if (hold_time(br) == 0)
@@ -507,10 +508,15 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 					source->dev->name);
 		} else {
 			/* fastpath: update of existing entry */
-			fdb->dst = source;
+			if (unlikely(source != fdb->dst)) {
+					fdb->dst = source;
+					fdb_modified = 1;
+				}
 			fdb->updated = jiffies;
 			if (unlikely(added_by_user))
 				fdb->added_by_user = 1;
+			if (unlikely(fdb_modified))
+				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
 	} else {
 		spin_lock(&br->hash_lock);
-- 
1.8.3.1
