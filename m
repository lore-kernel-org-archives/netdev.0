From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net] net: dsa: mv88e6xxx: Fix opps when adding vlan bridge
Date: Sun, 11 Dec 2016 21:07:19 +0100
Message-ID: <1481486839-19502-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51934 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753620AbcLKUHg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 11 Dec 2016 15:07:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A port is not necessarily assigned to a netdev. And a port does not
need to be a member of a bridge. So when iterating over all ports,
check before using the netdev and bridge_dev for a port. Otherwise we
dereference a NULL pointer.

Fixes: da9c359e19f0 ("net: dsa: mv88e6xxx: check hardware VLAN in use")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 883fd9809dd2..4e5ab856b87a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1796,6 +1796,9 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
 				continue;
 
+			if (!ds->ports[port].netdev)
+				continue;
+
 			if (vlan.data[i] ==
 			    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 				continue;
@@ -1804,6 +1807,9 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			    chip->ports[port].bridge_dev)
 				break; /* same bridge, check next VLAN */
 
+			if (!chip->ports[i].bridge_dev)
+				continue;
+
 			netdev_warn(ds->ports[port].netdev,
 				    "hardware VLAN %d already used by %s\n",
 				    vlan.vid,
-- 
2.10.2
