From: sfeldma@gmail.com
Subject: [PATCH net-next] bridge: del external_learned fdbs from device on flush or ageout
Date: Sun, 14 Jun 2015 11:33:11 -0700
Message-ID: <1434306791-43364-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37100 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbbFNSbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 14:31:33 -0400
Received: by igbsb11 with SMTP id sb11so37486478igb.0
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 11:31:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

We need to delete from offload the device externally learnded fdbs when any
one of these events happen:

1) Bridge ages out fdb.  (When bridge is doing ageing vs. device doing
ageing.  If device is doing ageing, it would send SWITCHDEV_FDB_DEL
directly).

2) STP state change flushes fdbs on port.

3) User uses sysfs interface to flush fdbs from bridge or bridge port:

	echo 1 >/sys/class/net/BR_DEV/bridge/flush
	echo 1 >/sys/class/net/BR_PORT/brport/flush

4) Offload driver send event SWITCHDEV_FDB_DEL to delete fdb entry.

For rocker, we can now get called to delete fdb entry in wait and nowait
contexts, so set NOWAIT flag when deleting fdb entry.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |   11 ++---------
 drivers/net/ethernet/rocker/rocker.c   |    2 +-
 net/bridge/br_fdb.c                    |   17 +++++++++++++++++
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 4a94ebc..e460007 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -251,15 +251,8 @@ out stale FDB entries.  To keep an FDB entry "alive", the driver should refresh
 the FDB entry by calling call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  The
 notification will reset the FDB entry's last-used time to now.  The driver
 should rate limit refresh notifications, for example, no more than once a
-second.  If the FDB entry expires, ndo_fdb_del is called to remove entry from
-the device.  XXX: this last part isn't currently correct: ndo_fdb_del isn't
-called, so the stale entry remains in device...this need to get fixed.
-
-FDB Flush
-^^^^^^^^^
-
-XXX: Unimplemented.  Need to support FDB flush by bridge driver for port and
-remove both static and learned FDB entries.
+second.  If the FDB entry expires, fdb_delete is called to remove entry from
+the device.
 
 STP State Change on Port
 ^^^^^^^^^^^^^^^^^^^^^^^^
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 3aa6caf..22d68c1 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4392,7 +4392,7 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
-	int flags = ROCKER_OP_FLAG_REMOVE;
+	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
 
 	if (!rocker_port_is_bridged(rocker_port))
 		return -EINVAL;
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 13949a7..be84b7e 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -24,6 +24,7 @@
 #include <linux/atomic.h>
 #include <asm/unaligned.h>
 #include <linux/if_vlan.h>
+#include <net/switchdev.h>
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
@@ -130,11 +131,27 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
 	}
 }
 
+static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
+{
+	struct switchdev_obj obj = {
+		.id = SWITCHDEV_OBJ_PORT_FDB,
+		.u.fdb = {
+			.addr = f->addr.addr,
+			.vid = f->vlan_id,
+		},
+	};
+
+	switchdev_port_obj_del(f->dst->dev, &obj);
+}
+
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 {
 	if (f->is_static)
 		fdb_del_hw_addr(br, f->addr.addr);
 
+	if (f->added_by_external_learn)
+		fdb_del_external_learn(f);
+
 	hlist_del_rcu(&f->hlist);
 	fdb_notify(br, f, RTM_DELNEIGH);
 	call_rcu(&f->rcu, fdb_rcu_free);
-- 
1.7.10.4
