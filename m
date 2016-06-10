From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/5] net: dsa: b53: Add bridge support
Date: Thu,  9 Jun 2016 18:23:56 -0700
Message-ID: <1465521837-30193-5-git-send-email-f.fainelli@gmail.com>
References: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
	jon.mason@broadcom.com, hemal.shah@broadcom.com,
	bandaru.viswanath@broadcom.com, michael.chan@broadcom.com,
	jogo@openwrt.org, cphealy@gmail.com, ardeleanalex@gmail.com,
	jiri@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35646 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbcFJBYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 21:24:11 -0400
Received: by mail-pf0-f194.google.com with SMTP id t190so3873349pfb.2
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 18:24:10 -0700 (PDT)
In-Reply-To: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for HW bridging by tying the ports together in the same port
VLAN mask when they belong to the same bridge, and isolating them to be
alone with the CPU port when they are not.

Propagate STP states from the bridge layer to the switch's HW mapping
when requested.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 162 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/b53/b53_priv.h   |   3 +
 drivers/net/dsa/b53/b53_regs.h   |  12 +++
 3 files changed, 174 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index a9f1de407f57..ad1d68272016 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -27,6 +27,7 @@
 #include <linux/platform_data/b53.h>
 #include <linux/phy.h>
 #include <linux/etherdevice.h>
+#include <linux/if_bridge.h>
 #include <net/dsa.h>
 #include <net/switchdev.h>
 
@@ -339,12 +340,12 @@ static int b53_set_jumbo(struct b53_device *dev, bool enable, bool allow_10_100)
 	return b53_write16(dev, B53_JUMBO_PAGE, dev->jumbo_size_reg, max_size);
 }
 
-static int b53_flush_arl(struct b53_device *dev)
+static int b53_flush_arl(struct b53_device *dev, u8 mask)
 {
 	unsigned int i;
 
 	b53_write8(dev, B53_CTRL_PAGE, B53_FAST_AGE_CTRL,
-		   FAST_AGE_DONE | FAST_AGE_DYNAMIC | FAST_AGE_STATIC);
+		   FAST_AGE_DONE | FAST_AGE_DYNAMIC | mask);
 
 	for (i = 0; i < 10; i++) {
 		u8 fast_age_ctrl;
@@ -365,14 +366,52 @@ out:
 	return 0;
 }
 
+static int b53_fast_age_port(struct b53_device *dev, int port)
+{
+	b53_write8(dev, B53_CTRL_PAGE, B53_FAST_AGE_PORT_CTRL, port);
+
+	return b53_flush_arl(dev, FAST_AGE_PORT);
+}
+
+static void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	unsigned int i;
+	u16 pvlan;
+
+	/* Enable the IMP port to be in the same VLAN as the other ports
+	 * on a per-port basis such that we only have Port i and IMP in
+	 * the same VLAN.
+	 */
+	b53_for_each_port(dev, i) {
+		b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i), &pvlan);
+		pvlan |= BIT(cpu_port);
+		b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i), pvlan);
+	}
+}
+
 static int b53_enable_port(struct dsa_switch *ds, int port,
 			   struct phy_device *phy)
 {
 	struct b53_device *dev = ds_to_priv(ds);
+	unsigned int cpu_port = dev->cpu_port;
+	u16 pvlan;
 
 	/* Clear the Rx and Tx disable bits and set to no spanning tree */
 	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), 0);
 
+	/* Set this port, and only this one to be in the default VLAN,
+	 * if member of a bridge, restore its membership prior to
+	 * bringing down this port.
+	 */
+	b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), &pvlan);
+	pvlan &= ~0x1ff;
+	pvlan |= BIT(port);
+	pvlan |= dev->ports[port].vlan_ctl_mask;
+	b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), pvlan);
+
+	b53_imp_vlan_setup(ds, cpu_port);
+
 	return 0;
 }
 
@@ -482,7 +521,7 @@ static int b53_switch_reset(struct b53_device *dev)
 
 	b53_enable_mib(dev);
 
-	return b53_flush_arl(dev);
+	return b53_flush_arl(dev, FAST_AGE_STATIC);
 }
 
 static int b53_phy_read16(struct dsa_switch *ds, int addr, int reg)
@@ -1019,6 +1058,120 @@ static int b53_fdb_dump(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+static int b53_br_join(struct dsa_switch *ds, int port,
+		       struct net_device *bridge)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	u16 pvlan, reg;
+	unsigned int i;
+
+	dev->ports[port].bridge_dev = bridge;
+	b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), &pvlan);
+
+	b53_for_each_port(dev, i) {
+		if (dev->ports[i].bridge_dev != bridge)
+			continue;
+
+		/* Add this local port to the remote port VLAN control
+		 * membership and update the remote port bitmask
+		 */
+		b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i), &reg);
+		reg |= BIT(port);
+		b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i), reg);
+		dev->ports[i].vlan_ctl_mask = reg;
+
+		pvlan |= BIT(i);
+	}
+
+	/* Configure the local port VLAN control membership to include
+	 * remote ports and update the local port bitmask
+	 */
+	b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), pvlan);
+	dev->ports[port].vlan_ctl_mask = pvlan;
+
+	return 0;
+}
+
+static void b53_br_leave(struct dsa_switch *ds, int port)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	struct net_device *bridge = dev->ports[port].bridge_dev;
+	unsigned int i;
+	u16 pvlan, reg;
+
+	b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), &pvlan);
+
+	b53_for_each_port(dev, i) {
+		/* Don't touch the remaining ports */
+		if (dev->ports[i].bridge_dev != bridge)
+			continue;
+
+		b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i), &reg);
+		reg &= ~BIT(port);
+		b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i), reg);
+		dev->ports[port].vlan_ctl_mask = reg;
+
+		/* Prevent self removal to preserve isolation */
+		if (port != i)
+			pvlan &= ~BIT(i);
+	}
+
+	b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), pvlan);
+	dev->ports[port].vlan_ctl_mask = pvlan;
+	dev->ports[port].bridge_dev = NULL;
+}
+
+static void b53_br_set_stp_state(struct dsa_switch *ds, int port,
+				 u8 state)
+{
+	struct b53_device *dev = ds_to_priv(ds);
+	u8 hw_state, cur_hw_state;
+	u8 reg;
+
+	b53_read8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), &reg);
+	cur_hw_state = reg & PORT_CTRL_STP_STATE_MASK;
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		hw_state = PORT_CTRL_DIS_STATE;
+		break;
+	case BR_STATE_LISTENING:
+		hw_state = PORT_CTRL_LISTEN_STATE;
+		break;
+	case BR_STATE_LEARNING:
+		hw_state = PORT_CTRL_LEARN_STATE;
+		break;
+	case BR_STATE_FORWARDING:
+		hw_state = PORT_CTRL_FWD_STATE;
+		break;
+	case BR_STATE_BLOCKING:
+		hw_state = PORT_CTRL_BLOCK_STATE;
+		break;
+	default:
+		dev_err(ds->dev, "invalid STP state: %d\n", state);
+		return;
+	}
+
+	/* Fast-age ARL entries if we are moving a port from Learning or
+	 * Forwarding (cur_hw_state) state to Disabled, Blocking or Listening
+	 * state (hw_state)
+	 */
+	if (cur_hw_state != hw_state) {
+		if (cur_hw_state >= PORT_CTRL_LEARN_STATE &&
+		    hw_state <= PORT_CTRL_LISTEN_STATE) {
+			if (b53_fast_age_port(dev, port)) {
+				dev_err(ds->dev, "fast ageing failed\n");
+				return;
+			}
+		}
+	}
+
+	b53_read8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), &reg);
+	reg &= ~PORT_CTRL_STP_STATE_MASK;
+	reg |= hw_state;
+	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), reg);
+}
+
 static struct dsa_switch_driver b53_switch_ops = {
 	.tag_protocol		= DSA_TAG_PROTO_NONE,
 	.setup			= b53_setup,
@@ -1031,6 +1184,9 @@ static struct dsa_switch_driver b53_switch_ops = {
 	.adjust_link		= b53_adjust_link,
 	.port_enable		= b53_enable_port,
 	.port_disable		= b53_disable_port,
+	.port_bridge_join	= b53_br_join,
+	.port_bridge_leave	= b53_br_leave,
+	.port_stp_state_set	= b53_br_set_stp_state,
 	.port_fdb_prepare	= b53_fdb_prepare,
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 1ee4e8016642..c19842960f28 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -27,6 +27,7 @@
 #include "b53_regs.h"
 
 struct b53_device;
+struct net_device;
 
 struct b53_io_ops {
 	int (*read8)(struct b53_device *dev, u8 page, u8 reg, u8 *value);
@@ -64,6 +65,8 @@ enum {
 #define B53_N_PORTS_25	6
 
 struct b53_port {
+	u16		vlan_ctl_mask;
+	struct net_device *bridge_dev;
 };
 
 struct b53_device {
diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index 441d2b4121c4..8f12bddd5dc9 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -65,6 +65,12 @@
 #define   PORT_CTRL_RX_MCST_EN		BIT(3) /* Multicast RX (P8 only) */
 #define   PORT_CTRL_RX_UCST_EN		BIT(4) /* Unicast RX (P8 only) */
 #define	  PORT_CTRL_STP_STATE_S		5
+#define   PORT_CTRL_NO_STP		(0 << PORT_CTRL_STP_STATE_S)
+#define   PORT_CTRL_DIS_STATE		(1 << PORT_CTRL_STP_STATE_S)
+#define   PORT_CTRL_BLOCK_STATE		(2 << PORT_CTRL_STP_STATE_S)
+#define   PORT_CTRL_LISTEN_STATE	(3 << PORT_CTRL_STP_STATE_S)
+#define   PORT_CTRL_LEARN_STATE		(4 << PORT_CTRL_STP_STATE_S)
+#define   PORT_CTRL_FWD_STATE		(5 << PORT_CTRL_STP_STATE_S)
 #define   PORT_CTRL_STP_STATE_MASK	(0x7 << PORT_CTRL_STP_STATE_S)
 
 /* SMP Control Register (8 bit) */
@@ -145,6 +151,12 @@
 #define   FAST_AGE_MC			BIT(5)
 #define   FAST_AGE_DONE			BIT(7)
 
+/* Fast Aging Port Control register (8 bit) */
+#define B53_FAST_AGE_PORT_CTRL		0x89
+
+/* Fast Aging VID Control register (16 bit) */
+#define B53_FAST_AGE_VID_CTRL		0x8a
+
 /*************************************************************************
  * Status Page registers
  *************************************************************************/
-- 
2.7.4
