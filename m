From: Jon Maxwell <jmaxwell37@gmail.com>
Subject: [PATCH net] bridge: notify user space of fdb port change
Date: Fri, 16 May 2014 17:28:44 +1000
Message-ID: <1400225324-17748-1-git-send-email-jmaxwell@redhat.com>
Cc: davem@davemloft.net, makita.toshiaki@lab.ntt.co.jp,
	vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jpirko@redhat.com, jmaxwell@redhat.com,
	Jon Maxwell <jmaxwell37@gmail.com>
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Maxwell <jmaxwell37@gmail.com>

There has been a number incidents recently where customers running KVM have 
reported that VM hosts on different Hypervisors are unreachable. Based on 
pcap traces we found that the bridge was broadcasting the ARP request out 
onto the network. However some NICs have an inbuilt switch which on occasions 
were broadcasting the VMs ARP request back through the physical NIC on the 
Hypervisor. This resulted in the bridge changing ports and incorrectly learning
that the VMs mac address was external. As a result the ARP reply was directed 
back onto the external network and VM never updated it's ARP cache. This patch 
will notify the bridge command to identify such port toggling.

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
---
 net/bridge/br_fdb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9203d5a..c2642f5 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -509,6 +509,8 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 			/* fastpath: update of existing entry */
 			fdb->dst = source;
 			fdb->updated = jiffies;
+			if (unlikely(source->port_no != fdb->dst->port_no))
+				fdb_notify(br, fdb, RTM_NEWNEIGH);
 			if (unlikely(added_by_user))
 				fdb->added_by_user = 1;
 		}
-- 
1.8.3.1
