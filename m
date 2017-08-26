From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC WIP 4/5] net: dsa: HACK: Handle MDB add/remove for none-switch ports
Date: Sat, 26 Aug 2017 22:56:09 +0200
Message-ID: <1503780970-10312-5-git-send-email-andrew@lunn.ch>
References: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        nikolay@cumulusnetworks.com, jiri@mellanox.com,
        roopa@cumulusnetworks.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45166 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdHZU7T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Aug 2017 16:59:19 -0400
In-Reply-To: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is a mdb added to a port which is not in the switch, we
need the switch to forward traffic for the group to the software
bridge, so it can forward it out the none-switch port.

The current implementation is a hack and will be replaced. Currently
only the bridge soft interface is supported. When there is a
join/leave on the soft interface, switchdev calls are made on the soft
interface device, brX. This does not have a switchdev ops structure
registered, so all lower interfaces of brX get there switchdev
function called. These are switch ports, and do have switchdev ops. By
comparing the original interface to the called interface, we can
determine this is not for a switch port, and add/remove the mdb to the
CPU port.
---
 net/dsa/port.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/dsa/port.c b/net/dsa/port.c
index d6e07176df3f..d8e4bfefd97d 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -194,8 +194,15 @@ int dsa_port_mdb_add(struct dsa_port *dp,
 		.mdb = mdb,
 	};
 
-	pr_info("dsa_port_mdb_add: %d %d", info.sw_index, info.port);
-
+	if (dp->netdev != mdb->obj.orig_dev) {
+		/* Not a port for this switch, so forward
+		 * multicast out the CPU port to the bridge.
+		 */
+		struct dsa_switch_tree *dst = dp->ds->dst;
+		struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+		info.port = cpu_dp->index;
+		return dsa_port_notify(cpu_dp, DSA_NOTIFIER_MDB_ADD, &info);
+	}
 	return dsa_port_notify(dp, DSA_NOTIFIER_MDB_ADD, &info);
 }
 
@@ -208,6 +215,14 @@ int dsa_port_mdb_del(struct dsa_port *dp,
 		.mdb = mdb,
 	};
 
+	if (dp->netdev != mdb->obj.orig_dev) {
+		struct dsa_switch_tree *dst = dp->ds->dst;
+		struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+
+		info.port = cpu_dp->index;
+		return dsa_port_notify(cpu_dp, DSA_NOTIFIER_MDB_DEL, &info);
+	}
+
 	return dsa_port_notify(dp, DSA_NOTIFIER_MDB_DEL, &info);
 }
 
-- 
2.14.1
