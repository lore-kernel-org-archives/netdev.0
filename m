From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/4] net: dsa: mv88e6xxx: fix hardware bridging
Date: Sun, 11 Oct 2015 18:08:38 -0400
Message-ID: <1444601318-20561-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Playing with the VLAN map of every port to implement "hardware bridging"
in the 88E6352 driver was a hack until full 802.1Q was supported.

Indeed with 802.1Q port mode "Disabled" or "Fallback", this feature is
used to restrict which output ports an input port can egress frames to.

A Linux bridge is an untagged VLAN. With full 802.1Q support, we don't
need this hack anymore and can use the "Secure" strict 802.1Q port mode.

With this mode, the port-based VLAN map still needs to be configured,
but all the logic is VTU-centric. This means that the switch only cares
about rules described in its hardware VLAN table, which is exactly what
Linux bridge expects and what we want.

Note also that the hardware bridging was broken with the previous
flexible "Fallback" 802.1Q port mode. Here's an example:

Port0 and Port1 belong to the same bridge. If Port0 sends crafted tagged
frames with VID 200 to Port1, Port1 receives it. Even if Port1 is in
hardware VLAN 200, but not Port0, Port1 will still receive it, because
Fallback mode doesn't care about invalid VID or non-member source port.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |  2 --
 drivers/net/dsa/mv88e6352.c |  2 --
 drivers/net/dsa/mv88e6xxx.c | 47 +++------------------------------------------
 drivers/net/dsa/mv88e6xxx.h |  2 --
 4 files changed, 3 insertions(+), 50 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index ca3330a..dfca352 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -113,8 +113,6 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 #endif
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
-	.port_join_bridge       = mv88e6xxx_join_bridge,
-	.port_leave_bridge      = mv88e6xxx_leave_bridge,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
 	.port_pvid_get		= mv88e6xxx_port_pvid_get,
 	.port_pvid_set		= mv88e6xxx_port_pvid_set,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 078a358..796fdcb 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -340,8 +340,6 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.set_eeprom		= mv88e6352_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
-	.port_join_bridge	= mv88e6xxx_join_bridge,
-	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
 	.port_pvid_get		= mv88e6xxx_port_pvid_get,
 	.port_pvid_set		= mv88e6xxx_port_pvid_set,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 787352df..63736f9 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1124,41 +1124,6 @@ static int _mv88e6xxx_port_vlan_map_set(struct dsa_switch *ds, int port,
 	return _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_BASE_VLAN, reg);
 }
 
-/* Bridge handling functions */
-
-static int mv88e6xxx_map_bridge(struct dsa_switch *ds, u16 members)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	const unsigned long output = members | BIT(dsa_upstream_port(ds));
-	int port, err = 0;
-
-	mutex_lock(&ps->smi_mutex);
-
-	for_each_set_bit(port, &output, ps->num_ports) {
-		if (dsa_is_cpu_port(ds, port))
-			continue;
-
-		err = _mv88e6xxx_port_vlan_map_set(ds, port, output & ~port);
-		if (err)
-			break;
-	}
-
-	mutex_unlock(&ps->smi_mutex);
-
-	return err;
-}
-
-
-int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
-{
-	return mv88e6xxx_map_bridge(ds, br_port_mask);
-}
-
-int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
-{
-	return mv88e6xxx_map_bridge(ds, br_port_mask & ~port);
-}
-
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -2007,7 +1972,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 			reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
 	}
 
-	reg |= PORT_CONTROL_2_8021Q_FALLBACK;
+	reg |= PORT_CONTROL_2_8021Q_SECURE;
 
 	if (reg) {
 		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
@@ -2103,15 +2068,9 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		goto abort;
 
 	/* Port based VLAN map: do not give each port its own address
-	 * database, allow the CPU port to talk to each of the 'real'
-	 * ports, and allow each of the 'real' ports to only talk to
-	 * the upstream port.
+	 * database, and allow every port to egress frames on all other ports.
 	 */
-	if (dsa_is_cpu_port(ds, port))
-		reg = BIT(ps->num_ports) - 1;
-	else
-		reg = BIT(dsa_upstream_port(ds));
-
+	reg = BIT(ps->num_ports) - 1; /* all ports */
 	ret = _mv88e6xxx_port_vlan_map_set(ds, port, reg & ~port);
 	if (ret)
 		goto abort;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index d5ee01a..ba94f17 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -463,8 +463,6 @@ int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
 int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
 int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e);
-int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
-int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
 int mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *vid);
 int mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 vid);
-- 
2.6.0
