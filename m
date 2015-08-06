From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 4/7] net: dsa: mv88e6xxx: extend fid mask
Date: Thu,  6 Aug 2015 01:44:05 -0400
Message-ID: <1438839848-505-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver currently manages one FID per port (or bridge group), with a
mask of DSA_MAX_PORTS bits, where 0 means that the FID is in use.

The Marvell 88E6xxx switches support up to 4094 FIDs (from 1 to 0xfff;
FID 0 means that multiple address databases are not being used).

This patch changes the fid_mask for an fid_bitmap of 4096 bits.

>From now on, FIDs 1 to num_ports are reserved for non-bridged ports and
bridge groups (a bridge group gets the FID of its first member). The
remaining bits will be reserved for VLAN entries.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 20 +++++++++++++-------
 drivers/net/dsa/mv88e6xxx.h |  8 +++++---
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 438c73e..b051576 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1091,7 +1091,7 @@ int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 	ps->bridge_mask[fid] = br_port_mask;
 
 	if (fid != ps->fid[port]) {
-		ps->fid_mask |= 1 << ps->fid[port];
+		clear_bit(ps->fid[port], ps->fid_bitmap);
 		ps->fid[port] = fid;
 		ret = _mv88e6xxx_update_bridge_config(ds, fid);
 	}
@@ -1125,9 +1125,16 @@ int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 
 	mutex_lock(&ps->smi_mutex);
 
-	newfid = __ffs(ps->fid_mask);
+	newfid = find_next_zero_bit(ps->fid_bitmap, VLAN_N_VID, 1);
+	if (unlikely(newfid > ps->num_ports)) {
+		netdev_err(ds->ports[port], "all first %d FIDs are used\n",
+			   ps->num_ports);
+		ret = -ENOSPC;
+		goto unlock;
+	}
+
 	ps->fid[port] = newfid;
-	ps->fid_mask &= ~(1 << newfid);
+	set_bit(newfid, ps->fid_bitmap);
 	ps->bridge_mask[fid] &= ~(1 << port);
 	ps->bridge_mask[newfid] = 1 << port;
 
@@ -1135,6 +1142,7 @@ int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 	if (!ret)
 		ret = _mv88e6xxx_update_bridge_config(ds, newfid);
 
+unlock:
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -1554,9 +1562,9 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * ports, and allow each of the 'real' ports to only talk to
 	 * the upstream port.
 	 */
-	fid = __ffs(ps->fid_mask);
+	fid = port + 1;
 	ps->fid[port] = fid;
-	ps->fid_mask &= ~(1 << fid);
+	set_bit(fid, ps->fid_bitmap);
 
 	if (!dsa_is_cpu_port(ds, port))
 		ps->bridge_mask[fid] = 1 << port;
@@ -1855,8 +1863,6 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 
 	ps->id = REG_READ(REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
 
-	ps->fid_mask = (1 << DSA_MAX_PORTS) - 1;
-
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
 	name = kasprintf(GFP_KERNEL, "dsa%d", ds->index);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6a66b4b..6d65b99 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -11,6 +11,8 @@
 #ifndef __MV88E6XXX_H
 #define __MV88E6XXX_H
 
+#include <linux/if_vlan.h>
+
 #ifndef UINT64_MAX
 #define UINT64_MAX		(u64)(~((u64)0))
 #endif
@@ -348,9 +350,9 @@ struct mv88e6xxx_priv_state {
 
 	/* hw bridging */
 
-	u32 fid_mask;
-	u8 fid[DSA_MAX_PORTS];
-	u16 bridge_mask[DSA_MAX_PORTS];
+	DECLARE_BITMAP(fid_bitmap, VLAN_N_VID);	/* FIDs 1 to 4095 available */
+	u16 fid[DSA_MAX_PORTS];			/* per (non-bridged) port FID */
+	u16 bridge_mask[DSA_MAX_PORTS];		/* br groups (indexed by FID) */
 
 	unsigned long port_state_update_mask;
 	u8 port_state[DSA_MAX_PORTS];
-- 
2.4.6
