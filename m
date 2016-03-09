From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 1/2] net: bridge: add switchdev attr for port bridging
Date: Wed,  9 Mar 2016 12:42:47 -0500
Message-ID: <1457545368-20647-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	nikolay@cumulusnetworks.com, Elad Raz <eladr@mellanox.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58639 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273AbcCIRnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:43:08 -0500
In-Reply-To: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF switchdev attribute which is
set before adding a port to a bridge and deleting a port from a bridge.

The main purpose for this attribute is to provide switchdev users a
simple and common way to retrieve bridging information, instead of
implementing complex notifier blocks to listen to global netdev events.

We can also imagine a switchdev user returning an error different from
-EOPNOTSUPP in the prepare phase to prevent a port from being bridged.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/switchdev.h |  2 ++
 net/bridge/br_if.c      | 27 +++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d451122..65f8514 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -46,6 +46,7 @@ enum switchdev_attr_id {
 	SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 	SWITCHDEV_ATTR_ID_PORT_STP_STATE,
 	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
+	SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF,
 	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
 	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
 };
@@ -58,6 +59,7 @@ struct switchdev_attr {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
 		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
+		bool join;				/* PORT_BRIDGE_IF */
 		u32 ageing_time;			/* BRIDGE_AGEING_TIME */
 		bool vlan_filtering;			/* BRIDGE_VLAN_FILTERING */
 	} u;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index a73df33..105b9fd 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -28,6 +28,24 @@
 
 #include "br_private.h"
 
+static int switchdev_bridge_if(struct net_device *dev, struct net_bridge *br,
+			       bool join)
+{
+	struct switchdev_attr attr = {
+		.orig_dev = br->dev,
+		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF,
+		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
+		.u.join = join,
+	};
+	int err;
+
+	err = switchdev_port_attr_set(dev, &attr);
+	if (err && err != -EOPNOTSUPP)
+		return err;
+
+	return 0;
+}
+
 /*
  * Determine initial path cost based on speed.
  * using recommendations from 802.1d standard
@@ -297,6 +315,10 @@ static void del_nbp(struct net_bridge_port *p)
 	br_netpoll_disable(p);
 
 	call_rcu(&p->rcu, destroy_nbp_rcu);
+
+	if (switchdev_bridge_if(dev, br, false))
+		br_warn(br, "error unbridging port %u(%s)\n",
+			(unsigned int) p->port_no, dev->name);
 }
 
 /* Delete bridge device */
@@ -347,6 +369,11 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 {
 	int index;
 	struct net_bridge_port *p;
+	int err;
+
+	err = switchdev_bridge_if(dev, br, true);
+	if (err)
+		return ERR_PTR(err);
 
 	index = find_portno(br);
 	if (index < 0)
-- 
2.7.2
