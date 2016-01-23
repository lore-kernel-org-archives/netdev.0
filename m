From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sat, 23 Jan 2016 10:51:16 +0000
Message-ID: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:58278 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbcAWKvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2016 05:51:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 76e398a62712 ("net: dsa: use switchdev obj for VLAN add/del
ops"), the Marvell 88E6xxx switch has been unable to pass traffic
between ports - any received traffic is discarded by the switch.
Taking a port out of bridge mode and configuring a vlan on it also the
port to start passing traffic.

With the debugfs files re-instated to allow debug of this issue by
comparing the register settings between the working and non-working
case, the reason becomes clear:

     GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6
- 7:  1111    707f    2001     2    2    2    2    2    0    2
+ 7:  1111    707f    2001     1    1    1    1    1    0    1

Register 7 for the ports is the default vlan tag register, and in the
non-working setup, it has been set to 2, despite vlan 2 not being
configured.  This causes the switch to drop all packets coming in to
these ports.  The working setup has the default vlan tag register set
to 1, which is the default vlan when none is configured.

Inspection of the code reveals why.  The code prior to this commit
was:

-		for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
...
-			if (!err && vlan->flags & BRIDGE_VLAN_INFO_PVID)
-				err = ds->drv->port_pvid_set(ds, p->port, vid);

but the new code is:

+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
...
+	}
...
+	if (pvid)
+		err = _mv88e6xxx_port_pvid_set(ds, port, vid);

This causes the new code to always set the default vlan to one higher
than the old code.

Fix this.

Fixes: 76e398a62712 ("net: dsa: use switchdev obj for VLAN add/del ops")
Cc: <stable@vger.kernel.org>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
As this is a regression on 4.4 compared to 4.3, I've added the stable
tag.

 drivers/net/dsa/mv88e6xxx.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b06dba05594a..bf622675397d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1515,11 +1515,12 @@ int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 		err = _mv88e6xxx_port_vlan_add(ds, port, vid, untagged);
 		if (err)
 			goto unlock;
+
+		/* no PVID with ranges, otherwise it's a bug */
+		if (pvid)
+			err = _mv88e6xxx_port_pvid_set(ds, port, vid);
 	}
 
-	/* no PVID with ranges, otherwise it's a bug */
-	if (pvid)
-		err = _mv88e6xxx_port_pvid_set(ds, port, vid);
 unlock:
 	mutex_unlock(&ps->smi_mutex);
 
-- 
2.1.0
