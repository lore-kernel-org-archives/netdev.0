From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/6] net: dsa: Fix SWITCHDEV_ATTR_ID_PORT_PARENT_ID
Date: Wed, 27 Sep 2017 00:25:58 +0200
Message-ID: <1506464764-12699-2-git-send-email-andrew@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:57031 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031080AbdIZW25 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 18:28:57 -0400
In-Reply-To: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
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

Use the tree ID as the parent ID, which is the same for all switches
in a cluster and unique across switch clusters.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Swap from MAC address to dst->tree
---
 net/dsa/slave.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bd51ef56ec5b..ee72aa164956 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -354,13 +354,16 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
 
 	switch (attr->id) {
-	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
-		attr->u.ppid.id_len = sizeof(ds->index);
-		memcpy(&attr->u.ppid.id, &ds->index, attr->u.ppid.id_len);
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID: {
+		struct dsa_switch *ds = p->dp->ds;
+		struct dsa_switch_tree *dst = ds->dst;
+
+		attr->u.ppid.id_len = sizeof(dst->tree);
+		memcpy(&attr->u.ppid.id, &dst->tree, sizeof(dst->tree));
 		break;
+	}
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT:
 		attr->u.brport_flags_support = 0;
 		break;
-- 
2.14.1
