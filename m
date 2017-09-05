From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 rfc 8/8] net: dsa: Fix SWITCHDEV_ATTR_ID_PORT_PARENT_ID
Date: Wed,  6 Sep 2017 01:35:10 +0200
Message-ID: <1504654510-31004-9-git-send-email-andrew@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58213 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753545AbdIEXhH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 19:37:07 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SWITCHDEV_ATTR_ID_PORT_PARENT_ID is used by the software bridge when
determining which ports to flood a packet out. If the packet
originated from a switch, it assumes the switch has already flooded
the packet out the switches ports, so the bridge should not flood the
packet itself out switch ports. Ports on the same switch are expected
to return the same parent ID when SWITCHDEV_ATTR_ID_PORT_PARENT_ID is
called.

DSA gets this wrong with clusters of switches. As far as the software
bridge is concerned, the cluster is all one switch. A packet from any
switch in the cluster can be assumed to of been flooded as needed out
all ports of the cluster, not just the switch it originated
from. Hence all ports of a cluster should return the same parent. The
old implementation did not, each switch in the cluster had its own ID.

Also wrong was that the ID was not unique if multiple DSA instances
are in operation.

Use the MAC address of the master interface as the parent ID. This is
the same for all switches in a cluster, and should be unique if there
are multiple clusters.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/slave.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2e07be149415..d2744b0dad6e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -374,13 +374,15 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
 
 	switch (attr->id) {
-	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
-		attr->u.ppid.id_len = sizeof(ds->index);
-		memcpy(&attr->u.ppid.id, &ds->index, attr->u.ppid.id_len);
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID: {
+		struct net_device *master = dsa_master_netdev(p);
+
+		attr->u.ppid.id_len = ETH_ALEN;
+		ether_addr_copy(attr->u.ppid.id, master->dev_addr);
 		break;
+	}
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT:
 		attr->u.brport_flags_support = 0;
 		break;
-- 
2.14.1
