From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 01/10] net: dsa: Centralise global and port setup code into mv88e6xxx.
Date: Wed,  6 May 2015 01:09:47 +0200
Message-ID: <1430867396-2268-2-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44535 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486AbbEEXPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:15:49 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The port setup code in the individual drivers is identical for 6123,
6171, and 6352, and very similar in 6131. Move it all into mv88e6xxx,
using the chip families to differentiate on features.

Similarly, the global setup is also very similar. Move the majority
into mv8e6xxx.

The chips themselves fall into families. Add helpers which uses the
device IDs to determine if a device is a member of a family or not.
Add some additional device IDs to the existing list, to make these
helper functions more complete. However these IDs are not yet added to
the probe functions.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123_61_65.c | 168 +---------------
 drivers/net/dsa/mv88e6131.c       | 149 +-------------
 drivers/net/dsa/mv88e6171.c       | 170 +---------------
 drivers/net/dsa/mv88e6352.c       | 168 +---------------
 drivers/net/dsa/mv88e6xxx.c       | 405 ++++++++++++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx.h       |  86 +++++++-
 6 files changed, 486 insertions(+), 660 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index b4af6d5aff7c..73325ab520f2 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -55,7 +55,10 @@ static char *mv88e6123_61_65_probe(struct device *host_dev, int sw_addr)
 static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 {
 	int ret;
-	int i;
+
+	ret = mv88e6xxx_setup_global(ds);
+	if (ret)
+		return ret;
 
 	/* Disable the PHY polling unit (since there won't be any
 	 * external PHYs to poll), don't discard packets with
@@ -63,17 +66,6 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 	 */
 	REG_WRITE(REG_GLOBAL, 0x04, 0x0000);
 
-	/* Set the default address aging time to 5 minutes, and
-	 * enable address learn messages to be sent to all message
-	 * ports.
-	 */
-	REG_WRITE(REG_GLOBAL, 0x0a, 0x0148);
-
-	/* Configure the priority mapping registers. */
-	ret = mv88e6xxx_config_prio(ds);
-	if (ret < 0)
-		return ret;
-
 	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
@@ -85,157 +77,9 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 	 */
 	REG_WRITE(REG_GLOBAL, 0x1c, ds->index & 0x1f);
 
-	/* Send all frames with destination addresses matching
-	 * 01:80:c2:00:00:2x to the CPU port.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x02, 0xffff);
-
-	/* Send all frames with destination addresses matching
-	 * 01:80:c2:00:00:0x to the CPU port.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x03, 0xffff);
-
-	/* Disable the loopback filter, disable flow control
-	 * messages, disable flood broadcast override, disable
-	 * removing of provider tags, disable ATU age violation
-	 * interrupts, disable tag flow control, force flow
-	 * control priority to the highest, and send all special
-	 * multicast frames to the CPU at the highest priority.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x05, 0x00ff);
-
-	/* Program the DSA routing table. */
-	for (i = 0; i < 32; i++) {
-		int nexthop;
-
-		nexthop = 0x1f;
-		if (i != ds->index && i < ds->dst->pd->nr_chips)
-			nexthop = ds->pd->rtable[i] & 0x1f;
-
-		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
-	}
-
-	/* Clear all trunk masks. */
-	for (i = 0; i < 8; i++)
-		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0xff);
-
-	/* Clear all trunk mappings. */
-	for (i = 0; i < 16; i++)
-		REG_WRITE(REG_GLOBAL2, 0x08, 0x8000 | (i << 11));
-
-	/* Disable ingress rate limiting by resetting all ingress
-	 * rate limit registers to their initial state.
-	 */
-	for (i = 0; i < 6; i++)
-		REG_WRITE(REG_GLOBAL2, 0x09, 0x9000 | (i << 8));
-
-	/* Initialise cross-chip port VLAN table to reset defaults. */
-	REG_WRITE(REG_GLOBAL2, 0x0b, 0x9000);
-
-	/* Clear the priority override table. */
-	for (i = 0; i < 16; i++)
-		REG_WRITE(REG_GLOBAL2, 0x0f, 0x8000 | (i << 8));
-
-	/* @@@ initialise AVB (22/23) watchdog (27) sdet (29) registers */
-
 	return 0;
 }
 
-static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
-{
-	int addr = REG_PORT(p);
-	u16 val;
-
-	/* MAC Forcing register: don't force link, speed, duplex
-	 * or flow control state to any particular values on physical
-	 * ports, but force the CPU port and all DSA ports to 1000 Mb/s
-	 * full duplex.
-	 */
-	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
-		REG_WRITE(addr, 0x01, 0x003e);
-	else
-		REG_WRITE(addr, 0x01, 0x0003);
-
-	/* Do not limit the period of time that this port can be
-	 * paused for by the remote end or the period of time that
-	 * this port can pause the remote end.
-	 */
-	REG_WRITE(addr, 0x02, 0x0000);
-
-	/* Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
-	 * disable Header mode, enable IGMP/MLD snooping, disable VLAN
-	 * tunneling, determine priority by looking at 802.1p and IP
-	 * priority fields (IP prio has precedence), and set STP state
-	 * to Forwarding.
-	 *
-	 * If this is the CPU link, use DSA or EDSA tagging depending
-	 * on which tagging mode was configured.
-	 *
-	 * If this is a link to another switch, use DSA tagging mode.
-	 *
-	 * If this is the upstream port for this switch, enable
-	 * forwarding of unknown unicasts and multicasts.
-	 */
-	val = 0x0433;
-	if (dsa_is_cpu_port(ds, p)) {
-		if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
-			val |= 0x3300;
-		else
-			val |= 0x0100;
-	}
-	if (ds->dsa_port_mask & (1 << p))
-		val |= 0x0100;
-	if (p == dsa_upstream_port(ds))
-		val |= 0x000c;
-	REG_WRITE(addr, 0x04, val);
-
-	/* Port Control 2: don't force a good FCS, set the maximum
-	 * frame size to 10240 bytes, don't let the switch add or
-	 * strip 802.1q tags, don't discard tagged or untagged frames
-	 * on this port, do a destination address lookup on all
-	 * received packets as usual, disable ARP mirroring and don't
-	 * send a copy of all transmitted/received frames on this port
-	 * to the CPU.
-	 */
-	REG_WRITE(addr, 0x08, 0x2080);
-
-	/* Egress rate control: disable egress rate control. */
-	REG_WRITE(addr, 0x09, 0x0001);
-
-	/* Egress rate control 2: disable egress rate control. */
-	REG_WRITE(addr, 0x0a, 0x0000);
-
-	/* Port Association Vector: when learning source addresses
-	 * of packets, add the address to the address database using
-	 * a port bitmap that has only the bit for this port set and
-	 * the other bits clear.
-	 */
-	REG_WRITE(addr, 0x0b, 1 << p);
-
-	/* Port ATU control: disable limiting the number of address
-	 * database entries that this port is allowed to use.
-	 */
-	REG_WRITE(addr, 0x0c, 0x0000);
-
-	/* Priority Override: disable DA, SA and VTU priority override. */
-	REG_WRITE(addr, 0x0d, 0x0000);
-
-	/* Port Ethertype: use the Ethertype DSA Ethertype value. */
-	REG_WRITE(addr, 0x0f, ETH_P_EDSA);
-
-	/* Tag Remap: use an identity 802.1p prio -> switch prio
-	 * mapping.
-	 */
-	REG_WRITE(addr, 0x18, 0x3210);
-
-	/* Tag Remap 2: use an identity 802.1p prio -> switch prio
-	 * mapping.
-	 */
-	REG_WRITE(addr, 0x19, 0x7654);
-
-	return mv88e6xxx_setup_port_common(ds, p);
-}
-
 static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -262,14 +106,12 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	/* @@@ initialise vtu and atu */
-
 	ret = mv88e6123_61_65_setup_global(ds);
 	if (ret < 0)
 		return ret;
 
 	for (i = 0; i < ps->num_ports; i++) {
-		ret = mv88e6123_61_65_setup_port(ds, i);
+		ret = mv88e6xxx_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
 	}
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index e54824fa0d95..310c1cf37830 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -45,7 +45,10 @@ static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 static int mv88e6131_setup_global(struct dsa_switch *ds)
 {
 	int ret;
-	int i;
+
+	ret = mv88e6xxx_setup_global(ds);
+	if (ret)
+		return ret;
 
 	/* Enable the PHY polling unit, don't discard packets with
 	 * excessive collisions, use a weighted fair queueing scheme
@@ -54,17 +57,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	 */
 	REG_WRITE(REG_GLOBAL, 0x04, 0x4400);
 
-	/* Set the default address aging time to 5 minutes, and
-	 * enable address learn messages to be sent to all message
-	 * ports.
-	 */
-	REG_WRITE(REG_GLOBAL, 0x0a, 0x0148);
-
-	/* Configure the priority mapping registers. */
-	ret = mv88e6xxx_config_prio(ds);
-	if (ret < 0)
-		return ret;
-
 	/* Set the VLAN ethertype to 0x8100. */
 	REG_WRITE(REG_GLOBAL, 0x19, 0x8100);
 
@@ -83,38 +75,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	else
 		REG_WRITE(REG_GLOBAL, 0x1c, 0xe000 | (ds->index & 0x1f));
 
-	/* Send all frames with destination addresses matching
-	 * 01:80:c2:00:00:0x to the CPU port.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x03, 0xffff);
-
-	/* Ignore removed tag data on doubly tagged packets, disable
-	 * flow control messages, force flow control priority to the
-	 * highest, and send all special multicast frames to the CPU
-	 * port at the highest priority.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x05, 0x00ff);
-
-	/* Program the DSA routing table. */
-	for (i = 0; i < 32; i++) {
-		int nexthop;
-
-		nexthop = 0x1f;
-		if (ds->pd->rtable &&
-		    i != ds->index && i < ds->dst->pd->nr_chips)
-			nexthop = ds->pd->rtable[i] & 0x1f;
-
-		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
-	}
-
-	/* Clear all trunk masks. */
-	for (i = 0; i < 8; i++)
-		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0x7ff);
-
-	/* Clear all trunk mappings. */
-	for (i = 0; i < 16; i++)
-		REG_WRITE(REG_GLOBAL2, 0x08, 0x8000 | (i << 11));
-
 	/* Force the priority of IGMP/MLD snoop frames and ARP frames
 	 * to the highest setting.
 	 */
@@ -123,103 +83,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = REG_PORT(p);
-	u16 val;
-
-	/* MAC Forcing register: don't force link, speed, duplex
-	 * or flow control state to any particular values on physical
-	 * ports, but force the CPU port and all DSA ports to 1000 Mb/s
-	 * (100 Mb/s on 6085) full duplex.
-	 */
-	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
-		if (ps->id == PORT_SWITCH_ID_6085)
-			REG_WRITE(addr, 0x01, 0x003d); /* 100 Mb/s */
-		else
-			REG_WRITE(addr, 0x01, 0x003e); /* 1000 Mb/s */
-	else
-		REG_WRITE(addr, 0x01, 0x0003);
-
-	/* Port Control: disable Core Tag, disable Drop-on-Lock,
-	 * transmit frames unmodified, disable Header mode,
-	 * enable IGMP/MLD snoop, disable DoubleTag, disable VLAN
-	 * tunneling, determine priority by looking at 802.1p and
-	 * IP priority fields (IP prio has precedence), and set STP
-	 * state to Forwarding.
-	 *
-	 * If this is the upstream port for this switch, enable
-	 * forwarding of unknown unicasts, and enable DSA tagging
-	 * mode.
-	 *
-	 * If this is the link to another switch, use DSA tagging
-	 * mode, but do not enable forwarding of unknown unicasts.
-	 */
-	val = 0x0433;
-	if (p == dsa_upstream_port(ds)) {
-		val |= 0x0104;
-		/* On 6085, unknown multicast forward is controlled
-		 * here rather than in Port Control 2 register.
-		 */
-		if (ps->id == PORT_SWITCH_ID_6085)
-			val |= 0x0008;
-	}
-	if (ds->dsa_port_mask & (1 << p))
-		val |= 0x0100;
-	REG_WRITE(addr, 0x04, val);
-
-	/* Port Control 2: don't force a good FCS, don't use
-	 * VLAN-based, source address-based or destination
-	 * address-based priority overrides, don't let the switch
-	 * add or strip 802.1q tags, don't discard tagged or
-	 * untagged frames on this port, do a destination address
-	 * lookup on received packets as usual, don't send a copy
-	 * of all transmitted/received frames on this port to the
-	 * CPU, and configure the upstream port number.
-	 *
-	 * If this is the upstream port for this switch, enable
-	 * forwarding of unknown multicast addresses.
-	 */
-	if (ps->id == PORT_SWITCH_ID_6085)
-		/* on 6085, bits 3:0 are reserved, bit 6 control ARP
-		 * mirroring, and multicast forward is handled in
-		 * Port Control register.
-		 */
-		REG_WRITE(addr, 0x08, 0x0080);
-	else {
-		val = 0x0080 | dsa_upstream_port(ds);
-		if (p == dsa_upstream_port(ds))
-			val |= 0x0040;
-		REG_WRITE(addr, 0x08, val);
-	}
-
-	/* Rate Control: disable ingress rate limiting. */
-	REG_WRITE(addr, 0x09, 0x0000);
-
-	/* Rate Control 2: disable egress rate limiting. */
-	REG_WRITE(addr, 0x0a, 0x0000);
-
-	/* Port Association Vector: when learning source addresses
-	 * of packets, add the address to the address database using
-	 * a port bitmap that has only the bit for this port set and
-	 * the other bits clear.
-	 */
-	REG_WRITE(addr, 0x0b, 1 << p);
-
-	/* Tag Remap: use an identity 802.1p prio -> switch prio
-	 * mapping.
-	 */
-	REG_WRITE(addr, 0x18, 0x3210);
-
-	/* Tag Remap 2: use an identity 802.1p prio -> switch prio
-	 * mapping.
-	 */
-	REG_WRITE(addr, 0x19, 0x7654);
-
-	return mv88e6xxx_setup_port_common(ds, p);
-}
-
 static int mv88e6131_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -251,14 +114,12 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	/* @@@ initialise vtu and atu */
-
 	ret = mv88e6131_setup_global(ds);
 	if (ret < 0)
 		return ret;
 
 	for (i = 0; i < ps->num_ports; i++) {
-		ret = mv88e6131_setup_port(ds, i);
+		ret = mv88e6xxx_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
 	}
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 9104efea0e3e..2b733f0cd6b9 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -38,26 +38,17 @@ static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6171_setup_global(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
-	int i;
+
+	ret = mv88e6xxx_setup_global(ds);
+	if (ret)
+		return ret;
 
 	/* Discard packets with excessive collisions, mask all
 	 * interrupt sources, enable PPU.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x04, 0x6000);
 
-	/* Set the default address aging time to 5 minutes, and
-	 * enable address learn messages to be sent to all message
-	 * ports.
-	 */
-	REG_WRITE(REG_GLOBAL, 0x0a, 0x0148);
-
-	/* Configure the priority mapping registers. */
-	ret = mv88e6xxx_config_prio(ds);
-	if (ret < 0)
-		return ret;
-
 	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
@@ -72,158 +63,9 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 	 */
 	REG_WRITE(REG_GLOBAL, 0x1c, ds->index & 0x1f);
 
-	/* Send all frames with destination addresses matching
-	 * 01:80:c2:00:00:2x to the CPU port.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x02, 0xffff);
-
-	/* Send all frames with destination addresses matching
-	 * 01:80:c2:00:00:0x to the CPU port.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x03, 0xffff);
-
-	/* Disable the loopback filter, disable flow control
-	 * messages, disable flood broadcast override, disable
-	 * removing of provider tags, disable ATU age violation
-	 * interrupts, disable tag flow control, force flow
-	 * control priority to the highest, and send all special
-	 * multicast frames to the CPU at the highest priority.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x05, 0x00ff);
-
-	/* Program the DSA routing table. */
-	for (i = 0; i < 32; i++) {
-		int nexthop;
-
-		nexthop = 0x1f;
-		if (i != ds->index && i < ds->dst->pd->nr_chips)
-			nexthop = ds->pd->rtable[i] & 0x1f;
-
-		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
-	}
-
-	/* Clear all trunk masks. */
-	for (i = 0; i < ps->num_ports; i++)
-		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0xff);
-
-	/* Clear all trunk mappings. */
-	for (i = 0; i < 16; i++)
-		REG_WRITE(REG_GLOBAL2, 0x08, 0x8000 | (i << 11));
-
-	/* Disable ingress rate limiting by resetting all ingress
-	 * rate limit registers to their initial state.
-	 */
-	for (i = 0; i < 6; i++)
-		REG_WRITE(REG_GLOBAL2, 0x09, 0x9000 | (i << 8));
-
-	/* Initialise cross-chip port VLAN table to reset defaults. */
-	REG_WRITE(REG_GLOBAL2, 0x0b, 0x9000);
-
-	/* Clear the priority override table. */
-	for (i = 0; i < 16; i++)
-		REG_WRITE(REG_GLOBAL2, 0x0f, 0x8000 | (i << 8));
-
-	/* @@@ initialise AVB (22/23) watchdog (27) sdet (29) registers */
-
 	return 0;
 }
 
-static int mv88e6171_setup_port(struct dsa_switch *ds, int p)
-{
-	int addr = REG_PORT(p);
-	u16 val;
-
-	/* MAC Forcing register: don't force link, speed, duplex
-	 * or flow control state to any particular values on physical
-	 * ports, but force the CPU port and all DSA ports to 1000 Mb/s
-	 * full duplex.
-	 */
-	val = REG_READ(addr, 0x01);
-	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
-		REG_WRITE(addr, 0x01, val | 0x003e);
-	else
-		REG_WRITE(addr, 0x01, val | 0x0003);
-
-	/* Do not limit the period of time that this port can be
-	 * paused for by the remote end or the period of time that
-	 * this port can pause the remote end.
-	 */
-	REG_WRITE(addr, 0x02, 0x0000);
-
-	/* Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
-	 * disable Header mode, enable IGMP/MLD snooping, disable VLAN
-	 * tunneling, determine priority by looking at 802.1p and IP
-	 * priority fields (IP prio has precedence), and set STP state
-	 * to Forwarding.
-	 *
-	 * If this is the CPU link, use DSA or EDSA tagging depending
-	 * on which tagging mode was configured.
-	 *
-	 * If this is a link to another switch, use DSA tagging mode.
-	 *
-	 * If this is the upstream port for this switch, enable
-	 * forwarding of unknown unicasts and multicasts.
-	 */
-	val = 0x0433;
-	if (dsa_is_cpu_port(ds, p)) {
-		if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
-			val |= 0x3300;
-		else
-			val |= 0x0100;
-	}
-	if (ds->dsa_port_mask & (1 << p))
-		val |= 0x0100;
-	if (p == dsa_upstream_port(ds))
-		val |= 0x000c;
-	REG_WRITE(addr, 0x04, val);
-
-	/* Port Control 2: don't force a good FCS, set the maximum
-	 * frame size to 10240 bytes, don't let the switch add or
-	 * strip 802.1q tags, don't discard tagged or untagged frames
-	 * on this port, do a destination address lookup on all
-	 * received packets as usual, disable ARP mirroring and don't
-	 * send a copy of all transmitted/received frames on this port
-	 * to the CPU.
-	 */
-	REG_WRITE(addr, 0x08, 0x2080);
-
-	/* Egress rate control: disable egress rate control. */
-	REG_WRITE(addr, 0x09, 0x0001);
-
-	/* Egress rate control 2: disable egress rate control. */
-	REG_WRITE(addr, 0x0a, 0x0000);
-
-	/* Port Association Vector: when learning source addresses
-	 * of packets, add the address to the address database using
-	 * a port bitmap that has only the bit for this port set and
-	 * the other bits clear.
-	 */
-	REG_WRITE(addr, 0x0b, 1 << p);
-
-	/* Port ATU control: disable limiting the number of address
-	 * database entries that this port is allowed to use.
-	 */
-	REG_WRITE(addr, 0x0c, 0x0000);
-
-	/* Priority Override: disable DA, SA and VTU priority override. */
-	REG_WRITE(addr, 0x0d, 0x0000);
-
-	/* Port Ethertype: use the Ethertype DSA Ethertype value. */
-	REG_WRITE(addr, 0x0f, ETH_P_EDSA);
-
-	/* Tag Remap: use an identity 802.1p prio -> switch prio
-	 * mapping.
-	 */
-	REG_WRITE(addr, 0x18, 0x3210);
-
-	/* Tag Remap 2: use an identity 802.1p prio -> switch prio
-	 * mapping.
-	 */
-	REG_WRITE(addr, 0x19, 0x7654);
-
-	return mv88e6xxx_setup_port_common(ds, p);
-}
-
 static int mv88e6171_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -240,8 +82,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	/* @@@ initialise vtu and atu */
-
 	ret = mv88e6171_setup_global(ds);
 	if (ret < 0)
 		return ret;
@@ -250,7 +90,7 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 		if (!(dsa_is_cpu_port(ds, i) || ds->phys_port_mask & (1 << i)))
 			continue;
 
-		ret = mv88e6171_setup_port(ds, i);
+		ret = mv88e6xxx_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
 	}
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 126c11b81e75..b32ec3e9bd6d 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -47,26 +47,17 @@ static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6352_setup_global(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
-	int i;
+
+	ret = mv88e6xxx_setup_global(ds);
+	if (ret)
+		return ret;
 
 	/* Discard packets with excessive collisions,
 	 * mask all interrupt sources, enable PPU (bit 14, undocumented).
 	 */
 	REG_WRITE(REG_GLOBAL, 0x04, 0x6000);
 
-	/* Set the default address aging time to 5 minutes, and
-	 * enable address learn messages to be sent to all message
-	 * ports.
-	 */
-	REG_WRITE(REG_GLOBAL, 0x0a, 0x0148);
-
-	/* Configure the priority mapping registers. */
-	ret = mv88e6xxx_config_prio(ds);
-	if (ret < 0)
-		return ret;
-
 	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
@@ -78,156 +69,9 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	 */
 	REG_WRITE(REG_GLOBAL, 0x1c, ds->index & 0x1f);
 
-	/* Send all frames with destination addresses matching
-	 * 01:80:c2:00:00:2x to the CPU port.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x02, 0xffff);
-
-	/* Send all frames with destination addresses matching
-	 * 01:80:c2:00:00:0x to the CPU port.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x03, 0xffff);
-
-	/* Disable the loopback filter, disable flow control
-	 * messages, disable flood broadcast override, disable
-	 * removing of provider tags, disable ATU age violation
-	 * interrupts, disable tag flow control, force flow
-	 * control priority to the highest, and send all special
-	 * multicast frames to the CPU at the highest priority.
-	 */
-	REG_WRITE(REG_GLOBAL2, 0x05, 0x00ff);
-
-	/* Program the DSA routing table. */
-	for (i = 0; i < 32; i++) {
-		int nexthop = 0x1f;
-
-		if (i != ds->index && i < ds->dst->pd->nr_chips)
-			nexthop = ds->pd->rtable[i] & 0x1f;
-
-		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
-	}
-
-	/* Clear all trunk masks. */
-	for (i = 0; i < 8; i++)
-		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0x7f);
-
-	/* Clear all trunk mappings. */
-	for (i = 0; i < 16; i++)
-		REG_WRITE(REG_GLOBAL2, 0x08, 0x8000 | (i << 11));
-
-	/* Disable ingress rate limiting by resetting all ingress
-	 * rate limit registers to their initial state.
-	 */
-	for (i = 0; i < ps->num_ports; i++)
-		REG_WRITE(REG_GLOBAL2, 0x09, 0x9000 | (i << 8));
-
-	/* Initialise cross-chip port VLAN table to reset defaults. */
-	REG_WRITE(REG_GLOBAL2, 0x0b, 0x9000);
-
-	/* Clear the priority override table. */
-	for (i = 0; i < 16; i++)
-		REG_WRITE(REG_GLOBAL2, 0x0f, 0x8000 | (i << 8));
-
-	/* @@@ initialise AVB (22/23) watchdog (27) sdet (29) registers */
-
 	return 0;
 }
 
-static int mv88e6352_setup_port(struct dsa_switch *ds, int p)
-{
-	int addr = REG_PORT(p);
-	u16 val;
-
-	/* MAC Forcing register: don't force link, speed, duplex
-	 * or flow control state to any particular values on physical
-	 * ports, but force the CPU port and all DSA ports to 1000 Mb/s
-	 * full duplex.
-	 */
-	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
-		REG_WRITE(addr, 0x01, 0x003e);
-	else
-		REG_WRITE(addr, 0x01, 0x0003);
-
-	/* Do not limit the period of time that this port can be
-	 * paused for by the remote end or the period of time that
-	 * this port can pause the remote end.
-	 */
-	REG_WRITE(addr, 0x02, 0x0000);
-
-	/* Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
-	 * disable Header mode, enable IGMP/MLD snooping, disable VLAN
-	 * tunneling, determine priority by looking at 802.1p and IP
-	 * priority fields (IP prio has precedence), and set STP state
-	 * to Forwarding.
-	 *
-	 * If this is the CPU link, use DSA or EDSA tagging depending
-	 * on which tagging mode was configured.
-	 *
-	 * If this is a link to another switch, use DSA tagging mode.
-	 *
-	 * If this is the upstream port for this switch, enable
-	 * forwarding of unknown unicasts and multicasts.
-	 */
-	val = 0x0433;
-	if (dsa_is_cpu_port(ds, p)) {
-		if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
-			val |= 0x3300;
-		else
-			val |= 0x0100;
-	}
-	if (ds->dsa_port_mask & (1 << p))
-		val |= 0x0100;
-	if (p == dsa_upstream_port(ds))
-		val |= 0x000c;
-	REG_WRITE(addr, 0x04, val);
-
-	/* Port Control 2: don't force a good FCS, set the maximum
-	 * frame size to 10240 bytes, don't let the switch add or
-	 * strip 802.1q tags, don't discard tagged or untagged frames
-	 * on this port, do a destination address lookup on all
-	 * received packets as usual, disable ARP mirroring and don't
-	 * send a copy of all transmitted/received frames on this port
-	 * to the CPU.
-	 */
-	REG_WRITE(addr, 0x08, 0x2080);
-
-	/* Egress rate control: disable egress rate control. */
-	REG_WRITE(addr, 0x09, 0x0001);
-
-	/* Egress rate control 2: disable egress rate control. */
-	REG_WRITE(addr, 0x0a, 0x0000);
-
-	/* Port Association Vector: when learning source addresses
-	 * of packets, add the address to the address database using
-	 * a port bitmap that has only the bit for this port set and
-	 * the other bits clear.
-	 */
-	REG_WRITE(addr, 0x0b, 1 << p);
-
-	/* Port ATU control: disable limiting the number of address
-	 * database entries that this port is allowed to use.
-	 */
-	REG_WRITE(addr, 0x0c, 0x0000);
-
-	/* Priority Override: disable DA, SA and VTU priority override. */
-	REG_WRITE(addr, 0x0d, 0x0000);
-
-	/* Port Ethertype: use the Ethertype DSA Ethertype value. */
-	REG_WRITE(addr, 0x0f, ETH_P_EDSA);
-
-	/* Tag Remap: use an identity 802.1p prio -> switch prio
-	 * mapping.
-	 */
-	REG_WRITE(addr, 0x18, 0x3210);
-
-	/* Tag Remap 2: use an identity 802.1p prio -> switch prio
-	 * mapping.
-	 */
-	REG_WRITE(addr, 0x19, 0x7654);
-
-	return mv88e6xxx_setup_port_common(ds, p);
-}
-
 #ifdef CONFIG_NET_DSA_HWMON
 
 static int mv88e6352_get_temp(struct dsa_switch *ds, int *temp)
@@ -306,14 +150,12 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	/* @@@ initialise vtu and atu */
-
 	ret = mv88e6352_setup_global(ds);
 	if (ret < 0)
 		return ret;
 
 	for (i = 0; i < ps->num_ports; i++) {
-		ret = mv88e6352_setup_port(ds, i);
+		ret = mv88e6xxx_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
 	}
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index af639ab4c55b..84496066f21b 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -165,24 +165,6 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 	return ret;
 }
 
-int mv88e6xxx_config_prio(struct dsa_switch *ds)
-{
-	/* Configure the IP ToS mapping registers. */
-	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
-	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
-	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
-	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
-	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
-	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
-	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
-	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
-
-	/* Configure the IEEE 802.1p priority mapping register. */
-	REG_WRITE(REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
-
-	return 0;
-}
-
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 {
 	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, (addr[0] << 8) | addr[1]);
@@ -434,14 +416,100 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 	}
 }
 
+static bool mv88e6xxx_6065_family(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	switch (ps->id) {
+	case PORT_SWITCH_ID_6031:
+	case PORT_SWITCH_ID_6061:
+	case PORT_SWITCH_ID_6035:
+	case PORT_SWITCH_ID_6065:
+		return true;
+	}
+	return false;
+}
+
+static bool mv88e6xxx_6095_family(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	switch (ps->id) {
+	case PORT_SWITCH_ID_6092:
+	case PORT_SWITCH_ID_6095:
+		return true;
+	}
+	return false;
+}
+
+static bool mv88e6xxx_6097_family(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	switch (ps->id) {
+	case PORT_SWITCH_ID_6046:
+	case PORT_SWITCH_ID_6085:
+	case PORT_SWITCH_ID_6096:
+	case PORT_SWITCH_ID_6097:
+		return true;
+	}
+	return false;
+}
+
+static bool mv88e6xxx_6165_family(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	switch (ps->id) {
+	case PORT_SWITCH_ID_6123:
+	case PORT_SWITCH_ID_6161:
+	case PORT_SWITCH_ID_6165:
+		return true;
+	}
+	return false;
+}
+
+static bool mv88e6xxx_6185_family(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	switch (ps->id) {
+	case PORT_SWITCH_ID_6121:
+	case PORT_SWITCH_ID_6122:
+	case PORT_SWITCH_ID_6152:
+	case PORT_SWITCH_ID_6155:
+	case PORT_SWITCH_ID_6182:
+	case PORT_SWITCH_ID_6185:
+	case PORT_SWITCH_ID_6108:
+	case PORT_SWITCH_ID_6131:
+		return true;
+	}
+	return false;
+}
+
+static bool mv88e6xxx_6351_family(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	switch (ps->id) {
+	case PORT_SWITCH_ID_6171:
+	case PORT_SWITCH_ID_6175:
+	case PORT_SWITCH_ID_6350:
+	case PORT_SWITCH_ID_6351:
+		return true;
+	}
+	return false;
+}
+
 static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	switch (ps->id) {
-	case PORT_SWITCH_ID_6352:
 	case PORT_SWITCH_ID_6172:
 	case PORT_SWITCH_ID_6176:
+	case PORT_SWITCH_ID_6240:
+	case PORT_SWITCH_ID_6352:
 		return true;
 	}
 	return false;
@@ -1241,13 +1309,212 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
 	}
 }
 
-int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
+int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret, fid;
+	u16 reg;
 
 	mutex_lock(&ps->smi_mutex);
 
+	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
+	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds) ||
+	    mv88e6xxx_6065_family(ds)) {
+		/* MAC Forcing register: don't force link, speed,
+		 * duplex or flow control state to any particular
+		 * values on physical ports, but force the CPU port
+		 * and all DSA ports to their maximum bandwidth and
+		 * full duplex.
+		 */
+		reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
+		if (dsa_is_cpu_port(ds, port) ||
+		    ds->dsa_port_mask & (1 << port)) {
+			reg |= PORT_PCS_CTRL_FORCE_LINK |
+				PORT_PCS_CTRL_LINK_UP |
+				PORT_PCS_CTRL_DUPLEX_FULL |
+				PORT_PCS_CTRL_FORCE_DUPLEX;
+			if (mv88e6xxx_6065_family(ds))
+				reg |= PORT_PCS_CTRL_100;
+			else
+				reg |= PORT_PCS_CTRL_1000;
+		} else {
+			reg |= PORT_PCS_CTRL_UNFORCED;
+		}
+
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_PCS_CTRL, reg);
+		if (ret)
+			goto abort;
+	}
+
+	/* Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
+	 * disable Header mode, enable IGMP/MLD snooping, disable VLAN
+	 * tunneling, determine priority by looking at 802.1p and IP
+	 * priority fields (IP prio has precedence), and set STP state
+	 * to Forwarding.
+	 *
+	 * If this is the CPU link, use DSA or EDSA tagging depending
+	 * on which tagging mode was configured.
+	 *
+	 * If this is a link to another switch, use DSA tagging mode.
+	 *
+	 * If this is the upstream port for this switch, enable
+	 * forwarding of unknown unicasts and multicasts.
+	 */
+	reg = 0;
+	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
+	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds) ||
+	    mv88e6xxx_6185_family(ds))
+		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
+		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
+		PORT_CONTROL_STATE_FORWARDING;
+	if (dsa_is_cpu_port(ds, port)) {
+		if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
+			reg |= PORT_CONTROL_DSA_TAG;
+		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+		    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds)) {
+			if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
+				reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA;
+			else
+				reg |= PORT_CONTROL_FRAME_MODE_DSA;
+		}
+
+		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+		    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
+		    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds) ||
+		    mv88e6xxx_6185_family(ds)) {
+			if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
+				reg |= PORT_CONTROL_EGRESS_ADD_TAG;
+		}
+	}
+	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
+	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds)) {
+		if (ds->dsa_port_mask & (1 << port))
+			reg |= PORT_CONTROL_FRAME_MODE_DSA;
+		if (port == dsa_upstream_port(ds))
+			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
+				PORT_CONTROL_FORWARD_UNKNOWN_MC;
+	}
+	if (reg) {
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_CONTROL, reg);
+		if (ret)
+			goto abort;
+	}
+
+	/* Port Control 2: don't force a good FCS, set the maximum
+	 * frame size to 10240 bytes, don't let the switch add or
+	 * strip 802.1q tags, don't discard tagged or untagged frames
+	 * on this port, do a destination address lookup on all
+	 * received packets as usual, disable ARP mirroring and don't
+	 * send a copy of all transmitted/received frames on this port
+	 * to the CPU.
+	 */
+	reg = 0;
+	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
+	    mv88e6xxx_6095_family(ds))
+		reg = PORT_CONTROL_2_MAP_DA;
+
+	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6165_family(ds))
+		reg |= PORT_CONTROL_2_JUMBO_10240;
+
+	if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds)) {
+		/* Set the upstream port this port should use */
+		reg |= dsa_upstream_port(ds);
+		/* enable forwarding of unknown multicast addresses to
+		 * the upstream port
+		 */
+		if (port == dsa_upstream_port(ds))
+			reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
+	}
+
+	if (reg) {
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_CONTROL_2, reg);
+		if (ret)
+			goto abort;
+	}
+
+	/* Port Association Vector: when learning source addresses
+	 * of packets, add the address to the address database using
+	 * a port bitmap that has only the bit for this port set and
+	 * the other bits clear.
+	 */
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR,
+				   1 << port);
+	if (ret)
+		goto abort;
+
+	/* Egress rate control 2: disable egress rate control. */
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_RATE_CONTROL_2,
+				   0x0000);
+	if (ret)
+		goto abort;
+
+	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds)) {
+		/* Do not limit the period of time that this port can
+		 * be paused for by the remote end or the period of
+		 * time that this port can pause the remote end.
+		 */
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_PAUSE_CTRL, 0x0000);
+		if (ret)
+			goto abort;
+
+		/* Port ATU control: disable limiting the number of
+		 * address database entries that this port is allowed
+		 * to use.
+		 */
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_ATU_CONTROL, 0x0000);
+		/* Priority Override: disable DA, SA and VTU priority
+		 * override.
+		 */
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_PRI_OVERRIDE, 0x0000);
+		if (ret)
+			goto abort;
+
+		/* Port Ethertype: use the Ethertype DSA Ethertype
+		 * value.
+		 */
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_ETH_TYPE, ETH_P_EDSA);
+		if (ret)
+			goto abort;
+		/* Tag Remap: use an identity 802.1p prio -> switch
+		 * prio mapping.
+		 */
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_TAG_REGMAP_0123, 0x3210);
+		if (ret)
+			goto abort;
+
+		/* Tag Remap 2: use an identity 802.1p prio -> switch
+		 * prio mapping.
+		 */
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_TAG_REGMAP_4567, 0x7654);
+		if (ret)
+			goto abort;
+	}
+
+	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
+	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds)) {
+		/* Rate Control: disable ingress rate limiting. */
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_RATE_CONTROL, 0x0001);
+		if (ret)
+			goto abort;
+	}
+
 	/* Port Control 1: disable trunking, disable sending
 	 * learning messages to this port.
 	 */
@@ -1298,6 +1565,104 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	return 0;
 }
 
+int mv88e6xxx_setup_global(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int i;
+
+	/* Set the default address aging time to 5 minutes, and
+	 * enable address learn messages to be sent to all message
+	 * ports.
+	 */
+	REG_WRITE(REG_GLOBAL, GLOBAL_ATU_CONTROL,
+		  0x0140 | GLOBAL_ATU_CONTROL_LEARN2ALL);
+
+	/* Configure the IP ToS mapping registers. */
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
+	REG_WRITE(REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
+
+	/* Configure the IEEE 802.1p priority mapping register. */
+	REG_WRITE(REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
+
+	/* Send all frames with destination addresses matching
+	 * 01:80:c2:00:00:0x to the CPU port.
+	 */
+	REG_WRITE(REG_GLOBAL2, GLOBAL2_MGMT_EN_0X, 0xffff);
+
+	/* Ignore removed tag data on doubly tagged packets, disable
+	 * flow control messages, force flow control priority to the
+	 * highest, and send all special multicast frames to the CPU
+	 * port at the highest priority.
+	 */
+	REG_WRITE(REG_GLOBAL2, GLOBAL2_SWITCH_MGMT,
+		  0x7 | GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x70 |
+		  GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI);
+
+	/* Program the DSA routing table. */
+	for (i = 0; i < 32; i++) {
+		int nexthop = 0x1f;
+
+		if (ds->pd->rtable &&
+		    i != ds->index && i < ds->dst->pd->nr_chips)
+			nexthop = ds->pd->rtable[i] & 0x1f;
+
+		REG_WRITE(REG_GLOBAL2, GLOBAL2_DEVICE_MAPPING,
+			  GLOBAL2_DEVICE_MAPPING_UPDATE |
+			  (i << GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT) |
+			  nexthop);
+	}
+
+	/* Clear all trunk masks. */
+	for (i = 0; i < 8; i++)
+		REG_WRITE(REG_GLOBAL2, GLOBAL2_TRUNK_MASK,
+			  0x8000 | (i << GLOBAL2_TRUNK_MASK_NUM_SHIFT) |
+			  ((1 << ps->num_ports) - 1));
+
+	/* Clear all trunk mappings. */
+	for (i = 0; i < 16; i++)
+		REG_WRITE(REG_GLOBAL2, GLOBAL2_TRUNK_MAPPING,
+			  GLOBAL2_TRUNK_MAPPING_UPDATE |
+			  (i << GLOBAL2_TRUNK_MAPPING_ID_SHIFT));
+
+	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds)) {
+		/* Send all frames with destination addresses matching
+		 * 01:80:c2:00:00:2x to the CPU port.
+		 */
+		REG_WRITE(REG_GLOBAL2, GLOBAL2_MGMT_EN_2X, 0xffff);
+
+		/* Initialise cross-chip port VLAN table to reset
+		 * defaults.
+		 */
+		REG_WRITE(REG_GLOBAL2, GLOBAL2_PVT_ADDR, 0x9000);
+
+		/* Clear the priority override table. */
+		for (i = 0; i < 16; i++)
+			REG_WRITE(REG_GLOBAL2, GLOBAL2_PRIO_OVERRIDE,
+				  0x8000 | (i << 8));
+	}
+
+	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
+	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds)) {
+		/* Disable ingress rate limiting by resetting all
+		 * ingress rate limit registers to their initial
+		 * state.
+		 */
+		for (i = 0; i < ps->num_ports; i++)
+			REG_WRITE(REG_GLOBAL2, GLOBAL2_INGRESS_OP,
+				  0x9000 | (i << 8));
+	}
+
+	return 0;
+}
+
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index e045154f3364..2aa1a6b31980 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -40,9 +40,31 @@
 #define PORT_STATUS_TX_PAUSED	BIT(5)
 #define PORT_STATUS_FLOW_CTRL	BIT(4)
 #define PORT_PCS_CTRL		0x01
+#define PORT_PCS_CTRL_FC		BIT(7)
+#define PORT_PCS_CTRL_FORCE_FC		BIT(6)
+#define PORT_PCS_CTRL_LINK_UP		BIT(5)
+#define PORT_PCS_CTRL_FORCE_LINK	BIT(4)
+#define PORT_PCS_CTRL_DUPLEX_FULL	BIT(3)
+#define PORT_PCS_CTRL_FORCE_DUPLEX	BIT(2)
+#define PORT_PCS_CTRL_10		0x00
+#define PORT_PCS_CTRL_100		0x01
+#define PORT_PCS_CTRL_1000		0x02
+#define PORT_PCS_CTRL_UNFORCED		0x03
+#define PORT_PAUSE_CTRL		0x02
 #define PORT_SWITCH_ID		0x03
+#define PORT_SWITCH_ID_6031	0x0310
+#define PORT_SWITCH_ID_6035	0x0350
+#define PORT_SWITCH_ID_6046	0x0480
+#define PORT_SWITCH_ID_6061	0x0610
+#define PORT_SWITCH_ID_6065	0x0650
 #define PORT_SWITCH_ID_6085	0x04a0
+#define PORT_SWITCH_ID_6092	0x0970
 #define PORT_SWITCH_ID_6095	0x0950
+#define PORT_SWITCH_ID_6096	0x0980
+#define PORT_SWITCH_ID_6097	0x0990
+#define PORT_SWITCH_ID_6108	0x1070
+#define PORT_SWITCH_ID_6121	0x1040
+#define PORT_SWITCH_ID_6122	0x1050
 #define PORT_SWITCH_ID_6123	0x1210
 #define PORT_SWITCH_ID_6123_A1	0x1212
 #define PORT_SWITCH_ID_6123_A2	0x1213
@@ -58,13 +80,38 @@
 #define PORT_SWITCH_ID_6165_A2	0x1653
 #define PORT_SWITCH_ID_6171	0x1710
 #define PORT_SWITCH_ID_6172	0x1720
+#define PORT_SWITCH_ID_6175	0x1750
 #define PORT_SWITCH_ID_6176	0x1760
 #define PORT_SWITCH_ID_6182	0x1a60
 #define PORT_SWITCH_ID_6185	0x1a70
+#define PORT_SWITCH_ID_6240	0x2400
+#define PORT_SWITCH_ID_6320	0x1250
+#define PORT_SWITCH_ID_6350	0x3710
+#define PORT_SWITCH_ID_6351	0x3750
 #define PORT_SWITCH_ID_6352	0x3520
 #define PORT_SWITCH_ID_6352_A0	0x3521
 #define PORT_SWITCH_ID_6352_A1	0x3522
 #define PORT_CONTROL		0x04
+#define PORT_CONTROL_USE_CORE_TAG	BIT(15)
+#define PORT_CONTROL_DROP_ON_LOCK	BIT(14)
+#define PORT_CONTROL_EGRESS_UNMODIFIED	(0x0 << 12)
+#define PORT_CONTROL_EGRESS_UNTAGGED	(0x1 << 12)
+#define PORT_CONTROL_EGRESS_TAGGED	(0x2 << 12)
+#define PORT_CONTROL_EGRESS_ADD_TAG	(0x3 << 12)
+#define PORT_CONTROL_HEADER		BIT(11)
+#define PORT_CONTROL_IGMP_MLD_SNOOP	BIT(10)
+#define PORT_CONTROL_DOUBLE_TAG		BIT(9)
+#define PORT_CONTROL_FRAME_MODE_NORMAL		(0x0 << 8)
+#define PORT_CONTROL_FRAME_MODE_DSA		(0x1 << 8)
+#define PORT_CONTROL_FRAME_MODE_PROVIDER	(0x2 << 8)
+#define PORT_CONTROL_FRAME_ETHER_TYPE_DSA	(0x3 << 8)
+#define PORT_CONTROL_DSA_TAG		BIT(8)
+#define PORT_CONTROL_VLAN_TUNNEL	BIT(7)
+#define PORT_CONTROL_TAG_IF_BOTH	BIT(6)
+#define PORT_CONTROL_USE_IP		BIT(5)
+#define PORT_CONTROL_USE_TAG		BIT(4)
+#define PORT_CONTROL_FORWARD_UNKNOWN_MC	BIT(3)
+#define PORT_CONTROL_FORWARD_UNKNOWN	BIT(2)
 #define PORT_CONTROL_STATE_MASK		0x03
 #define PORT_CONTROL_STATE_DISABLED	0x00
 #define PORT_CONTROL_STATE_BLOCKING	0x01
@@ -74,15 +121,32 @@
 #define PORT_BASE_VLAN		0x06
 #define PORT_DEFAULT_VLAN	0x07
 #define PORT_CONTROL_2		0x08
+#define PORT_CONTROL_2_IGNORE_FCS	BIT(15)
+#define PORT_CONTROL_2_VTU_PRI_OVERRIDE	BIT(14)
+#define PORT_CONTROL_2_SA_PRIO_OVERRIDE	BIT(13)
+#define PORT_CONTROL_2_DA_PRIO_OVERRIDE	BIT(12)
+#define PORT_CONTROL_2_JUMBO_1522	(0x00 << 12)
+#define PORT_CONTROL_2_JUMBO_2048	(0x01 << 12)
+#define PORT_CONTROL_2_JUMBO_10240	(0x02 << 12)
+#define PORT_CONTROL_2_DISCARD_TAGGED	BIT(9)
+#define PORT_CONTROL_2_DISCARD_UNTAGGED	BIT(8)
+#define PORT_CONTROL_2_MAP_DA		BIT(7)
+#define PORT_CONTROL_2_DEFAULT_FORWARD	BIT(6)
+#define PORT_CONTROL_2_FORWARD_UNKNOWN	BIT(6)
+#define PORT_CONTROL_2_EGRESS_MONITOR	BIT(5)
+#define PORT_CONTROL_2_INGRESS_MONITOR	BIT(4)
 #define PORT_RATE_CONTROL	0x09
 #define PORT_RATE_CONTROL_2	0x0a
 #define PORT_ASSOC_VECTOR	0x0b
+#define PORT_ATU_CONTROL	0x0c
+#define PORT_PRI_OVERRIDE	0x0d
+#define PORT_ETH_TYPE		0x0f
 #define PORT_IN_DISCARD_LO	0x10
 #define PORT_IN_DISCARD_HI	0x11
 #define PORT_IN_FILTERED	0x12
 #define PORT_OUT_FILTERED	0x13
-#define PORT_TAG_REGMAP_0123	0x19
-#define PORT_TAG_REGMAP_4567	0x1a
+#define PORT_TAG_REGMAP_0123	0x18
+#define PORT_TAG_REGMAP_4567	0x19
 
 #define REG_GLOBAL		0x1b
 #define GLOBAL_STATUS		0x00
@@ -102,7 +166,7 @@
 #define GLOBAL_CONTROL_DISCARD_EXCESS	BIT(13) /* 6352 */
 #define GLOBAL_CONTROL_SCHED_PRIO	BIT(11) /* 6152 */
 #define GLOBAL_CONTROL_MAX_FRAME_1632	BIT(10) /* 6152 */
-#define GLOBAL_CONTROL_RELOAD_EEPROM	BIT(9)  /* 6152 */
+#define GLOBAL_CONTROL_RELOAD_EEPROM	BIT(9)	/* 6152 */
 #define GLOBAL_CONTROL_DEVICE_EN	BIT(7)
 #define GLOBAL_CONTROL_STATS_DONE_EN	BIT(6)
 #define GLOBAL_CONTROL_VTU_PROBLEM_EN	BIT(5)
@@ -117,6 +181,7 @@
 #define GLOBAL_VTU_DATA_4_7	0x08
 #define GLOBAL_VTU_DATA_8_11	0x09
 #define GLOBAL_ATU_CONTROL	0x0a
+#define GLOBAL_ATU_CONTROL_LEARN2ALL	BIT(3)
 #define GLOBAL_ATU_OP		0x0b
 #define GLOBAL_ATU_OP_BUSY	BIT(15)
 #define GLOBAL_ATU_OP_NOP		(0 << 12)
@@ -172,9 +237,20 @@
 #define GLOBAL2_MGMT_EN_0X	0x03
 #define GLOBAL2_FLOW_CONTROL	0x04
 #define GLOBAL2_SWITCH_MGMT	0x05
+#define GLOBAL2_SWITCH_MGMT_USE_DOUBLE_TAG_DATA	BIT(15)
+#define GLOBAL2_SWITCH_MGMT_PREVENT_LOOPS	BIT(14)
+#define GLOBAL2_SWITCH_MGMT_FLOW_CONTROL_MSG	BIT(13)
+#define GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI	BIT(7)
+#define GLOBAL2_SWITCH_MGMT_RSVD2CPU		BIT(3)
 #define GLOBAL2_DEVICE_MAPPING	0x06
+#define GLOBAL2_DEVICE_MAPPING_UPDATE		BIT(15)
+#define GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT	8
 #define GLOBAL2_TRUNK_MASK	0x07
+#define GLOBAL2_TRUNK_MASK_UPDATE		BIT(15)
+#define GLOBAL2_TRUNK_MASK_NUM_SHIFT		12
 #define GLOBAL2_TRUNK_MAPPING	0x08
+#define GLOBAL2_TRUNK_MAPPING_UPDATE		BIT(15)
+#define GLOBAL2_TRUNK_MAPPING_ID_SHIFT		11
 #define GLOBAL2_INGRESS_OP	0x09
 #define GLOBAL2_INGRESS_DATA	0x0a
 #define GLOBAL2_PVT_ADDR	0x0b
@@ -260,14 +336,14 @@ struct mv88e6xxx_hw_stat {
 };
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
-int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port);
+int mv88e6xxx_setup_port(struct dsa_switch *ds, int port);
 int mv88e6xxx_setup_common(struct dsa_switch *ds);
+int mv88e6xxx_setup_global(struct dsa_switch *ds);
 int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg);
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
 int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 			  int reg, u16 val);
 int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val);
-int mv88e6xxx_config_prio(struct dsa_switch *ds);
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum);
-- 
2.1.4
