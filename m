From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC net 3/3] net: dsa: shorten ageing time on topology change
Date: Wed, 19 Oct 2016 17:38:03 -0400
Message-ID: <20161019213803.22837-4-vivien.didelot@savoirfairelinux.com>
References: <20161019213803.22837-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        cphealy@gmail.com, bridge@lists.linux-foundation.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52159 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753800AbcJSVjE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 17:39:04 -0400
In-Reply-To: <20161019213803.22837-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

802.1D [1] specifies that the bridges must use a short value to age out
dynamic entries in the Filtering Database for a period, once a topology
change has been communicated by the root bridge.

Add a bridge_ageing_time member in the net_bridge structure to store the
bridge ageing time value configured by the user (ioctl/netlink/sysfs).

If we are using in-kernel STP, shorten the ageing time value to twice
the forward delay used by the topology when the topology change flag is
set. When the flag is cleared, restore the configured ageing time.

[1] "8.3.5 Notifying topology changes ",
    http://profesores.elo.utfsm.cl/~agv/elo309/doc/802.1D-1998.pdf

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_device.c  |  2 +-
 net/bridge/br_private.h |  3 ++-
 net/bridge/br_stp.c     | 27 +++++++++++++++++++++++++++
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 89a687f..207318a 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -409,7 +409,7 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_max_age = br->max_age = 20 * HZ;
 	br->bridge_hello_time = br->hello_time = 2 * HZ;
 	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
-	br->ageing_time = BR_DEFAULT_AGEING_TIME;
+	br->bridge_ageing_time = br->ageing_time = BR_DEFAULT_AGEING_TIME;
 
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3c294b4..43efeb9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -300,10 +300,11 @@ struct net_bridge
 	unsigned long			max_age;
 	unsigned long			hello_time;
 	unsigned long			forward_delay;
-	unsigned long			bridge_max_age;
 	unsigned long			ageing_time;
+	unsigned long			bridge_max_age;
 	unsigned long			bridge_hello_time;
 	unsigned long			bridge_forward_delay;
+	unsigned long			bridge_ageing_time;
 
 	u8				group_addr[ETH_ALEN];
 	bool				group_addr_set;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 8d7b4c7..71fd1a4 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -597,7 +597,11 @@ int br_set_ageing_time(struct net_bridge *br, clock_t ageing_time)
 	if (err)
 		return err;
 
+	spin_lock_bh(&br->lock);
+	br->bridge_ageing_time = t;
 	br->ageing_time = t;
+	spin_unlock_bh(&br->lock);
+
 	mod_timer(&br->gc_timer, jiffies);
 
 	return 0;
@@ -606,6 +610,29 @@ int br_set_ageing_time(struct net_bridge *br, clock_t ageing_time)
 /* called under bridge lock */
 void __br_set_topology_change(struct net_bridge *br, unsigned char val)
 {
+	unsigned long t;
+	int err;
+
+	if (br->stp_enabled == BR_KERNEL_STP && br->topology_change != val) {
+		/* On topology change, set the bridge ageing time to twice the
+		 * forward delay. Otherwise, restore its default ageing time.
+		 */
+
+		if (val) {
+			t = 2 * br->forward_delay;
+			br_debug(br, "decreasing ageing time to %lu\n", t);
+		} else {
+			t = br->bridge_ageing_time;
+			br_debug(br, "restoring ageing time to %lu\n", t);
+		}
+
+		err = __set_ageing_time(br->dev, t);
+		if (err)
+			br_warn(br, "error offloading ageing time\n");
+		else
+			br->ageing_time = t;
+	}
+
 	br->topology_change = val;
 }
 
-- 
2.10.0
