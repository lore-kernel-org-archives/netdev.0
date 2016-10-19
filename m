From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC net 2/3] net: bridge: add helper to set topology change
Date: Wed, 19 Oct 2016 17:38:02 -0400
Message-ID: <20161019213803.22837-3-vivien.didelot@savoirfairelinux.com>
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
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52170 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754240AbcJSVjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 17:39:07 -0400
In-Reply-To: <20161019213803.22837-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a __br_set_topology_change helper to set the topology change value.

This can be later extended to add actions when the topology change flag
is set or cleared.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_private_stp.h |  1 +
 net/bridge/br_stp.c         | 10 ++++++++--
 net/bridge/br_stp_if.c      |  2 +-
 net/bridge/br_stp_timer.c   |  2 +-
 4 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_private_stp.h b/net/bridge/br_private_stp.h
index 2fe910c..3f7543a 100644
--- a/net/bridge/br_private_stp.h
+++ b/net/bridge/br_private_stp.h
@@ -61,6 +61,7 @@ void br_received_tcn_bpdu(struct net_bridge_port *p);
 void br_transmit_config(struct net_bridge_port *p);
 void br_transmit_tcn(struct net_bridge *br);
 void br_topology_change_detection(struct net_bridge *br);
+void __br_set_topology_change(struct net_bridge *br, unsigned char val);
 
 /* br_stp_bpdu.c */
 void br_send_config_bpdu(struct net_bridge_port *, struct br_config_bpdu *);
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 6ebe2a0..8d7b4c7 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -234,7 +234,7 @@ static void br_record_config_timeout_values(struct net_bridge *br,
 	br->max_age = bpdu->max_age;
 	br->hello_time = bpdu->hello_time;
 	br->forward_delay = bpdu->forward_delay;
-	br->topology_change = bpdu->topology_change;
+	__br_set_topology_change(br, bpdu->topology_change);
 }
 
 /* called under bridge lock */
@@ -344,7 +344,7 @@ void br_topology_change_detection(struct net_bridge *br)
 		isroot ? "propagating" : "sending tcn bpdu");
 
 	if (isroot) {
-		br->topology_change = 1;
+		__br_set_topology_change(br, 1);
 		mod_timer(&br->topology_change_timer, jiffies
 			  + br->bridge_forward_delay + br->bridge_max_age);
 	} else if (!br->topology_change_detected) {
@@ -603,6 +603,12 @@ int br_set_ageing_time(struct net_bridge *br, clock_t ageing_time)
 	return 0;
 }
 
+/* called under bridge lock */
+void __br_set_topology_change(struct net_bridge *br, unsigned char val)
+{
+	br->topology_change = val;
+}
+
 void __br_set_forward_delay(struct net_bridge *br, unsigned long t)
 {
 	br->bridge_forward_delay = t;
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 2efbba5..6c1e214 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -81,7 +81,7 @@ void br_stp_disable_bridge(struct net_bridge *br)
 
 	}
 
-	br->topology_change = 0;
+	__br_set_topology_change(br, 0);
 	br->topology_change_detected = 0;
 	spin_unlock_bh(&br->lock);
 
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index da058b8..7ddb38e 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -125,7 +125,7 @@ static void br_topology_change_timer_expired(unsigned long arg)
 	br_debug(br, "topo change timer expired\n");
 	spin_lock(&br->lock);
 	br->topology_change_detected = 0;
-	br->topology_change = 0;
+	__br_set_topology_change(br, 0);
 	spin_unlock(&br->lock);
 }
 
-- 
2.10.0
