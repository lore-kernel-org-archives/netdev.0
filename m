From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v3 2/5] bridge: notify enslaved devices of headroom changes
Date: Fri, 26 Feb 2016 10:45:38 +0100
Message-ID: <32c7155c413ad98df6fee605ca59f835dfdefaa3.1456412101.git.pabeni@redhat.com>
References: <cover.1456412101.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49890 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922AbcBZJqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 04:46:12 -0500
In-Reply-To: <cover.1456412101.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On bridge needed_headroom changes, the enslaved devices are
notified via the ndo_set_rx_headroom method

Signed-off-by: Paolo Abeni <pabeni@redhat.com>

---
v1 -> v2:
 - use netdev_set_rx_headroom() to update the br ports headroom
 - reset the dev rx headroom upon dev removal from bridge
---
 net/bridge/br_if.c | 37 +++++++++++++++++++++++++++++++++++--
 1 file changed, 35 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c367b3e..e0aedc4 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -223,6 +223,31 @@ static void destroy_nbp_rcu(struct rcu_head *head)
 	destroy_nbp(p);
 }
 
+static unsigned get_max_headroom(struct net_bridge *br)
+{
+	unsigned max_headroom = 0;
+	struct net_bridge_port *p;
+
+	list_for_each_entry(p, &br->port_list, list) {
+		unsigned dev_headroom = netdev_get_fwd_headroom(p->dev);
+
+		if (dev_headroom > max_headroom)
+			max_headroom = dev_headroom;
+	}
+
+	return max_headroom;
+}
+
+static void update_headroom(struct net_bridge *br, int new_hr)
+{
+	struct net_bridge_port *p;
+
+	list_for_each_entry(p, &br->port_list, list)
+		netdev_set_rx_headroom(p->dev, new_hr);
+
+	br->dev->needed_headroom = new_hr;
+}
+
 /* Delete port(interface) from bridge is done in two steps.
  * via RCU. First step, marks device as down. That deletes
  * all the timers and stops new packets from flowing through.
@@ -248,6 +273,9 @@ static void del_nbp(struct net_bridge_port *p)
 	br_ifinfo_notify(RTM_DELLINK, p);
 
 	list_del_rcu(&p->list);
+	if (netdev_get_fwd_headroom(dev) == br->dev->needed_headroom)
+		update_headroom(br, get_max_headroom(br));
+	netdev_reset_rx_headroom(dev);
 
 	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 0, 1);
@@ -438,6 +466,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 {
 	struct net_bridge_port *p;
 	int err = 0;
+	unsigned br_hr, dev_hr;
 	bool changed_addr;
 
 	/* Don't allow bridging non-ethernet like devices, or DSA-enabled
@@ -505,8 +534,12 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	netdev_update_features(br->dev);
 
-	if (br->dev->needed_headroom < dev->needed_headroom)
-		br->dev->needed_headroom = dev->needed_headroom;
+	br_hr = br->dev->needed_headroom;
+	dev_hr = netdev_get_fwd_headroom(dev);
+	if (br_hr < dev_hr)
+		update_headroom(br, dev_hr);
+	else
+		netdev_set_rx_headroom(dev, br_hr);
 
 	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
-- 
1.8.3.1
