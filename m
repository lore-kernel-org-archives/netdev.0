From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 3/3] net: dsa: bcm_sf2: add HW bridging support
Date: Tue, 24 Feb 2015 13:15:34 -0800
Message-ID: <1424812534-8936-4-git-send-email-f.fainelli@gmail.com>
References: <1424812534-8936-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:46456 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbbBXVT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:19:28 -0500
Received: by pabkx10 with SMTP id kx10so38914956pab.13
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 13:19:27 -0800 (PST)
In-Reply-To: <1424812534-8936-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the bridge join, leave and set_stp callbacks by making that
we do the following:

- when a port joins the bridge, all existing ports in the bridge get
  their VLAN control register updated with that joining port
- the joining port is including all existing bridge ports in its own
  VLAN control register

The leave operation is fairly similar, special care must be taken to
make sure that port leaving the bridging is not removing itself from its
own VLAN control register.

Since the various BR_* states apply directly to our HW semantics, we
just need to translate these constants into their corresponding HW
settings, and voila!

We make sure to trigger a fast-ageing process for ports that are
joining/leaving the bridge and transition from incompatible states, this
is equivalent to triggering an ARL flush for that port.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 155 ++++++++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/bcm_sf2.h      |   2 +
 drivers/net/dsa/bcm_sf2_regs.h |  15 ++++
 3 files changed, 171 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 4daffb284931..cedb572bf25a 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -23,6 +23,7 @@
 #include <linux/of_address.h>
 #include <net/dsa.h>
 #include <linux/ethtool.h>
+#include <linux/if_bridge.h>
 
 #include "bcm_sf2.h"
 #include "bcm_sf2_regs.h"
@@ -299,10 +300,14 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	if (port == 7)
 		intrl2_1_mask_clear(priv, P_IRQ_MASK(P7_IRQ_OFF));
 
-	/* Set this port, and only this one to be in the default VLAN */
+	/* Set this port, and only this one to be in the default VLAN,
+	 * if member of a bridge, restore its membership prior to
+	 * bringing down this port.
+	 */
 	reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
 	reg &= ~PORT_VLAN_CTRL_MASK;
 	reg |= (1 << port);
+	reg |= priv->port_sts[port].vlan_ctl_mask;
 	core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(port));
 
 	bcm_sf2_imp_vlan_setup(ds, cpu_port);
@@ -400,6 +405,151 @@ static int bcm_sf2_sw_set_eee(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+/* Fast-ageing of ARL entries for a given port, equivalent to an ARL
+ * flush for that port.
+ */
+static int bcm_sf2_sw_fast_age_port(struct dsa_switch  *ds, int port)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	unsigned int timeout = 1000;
+	u32 reg;
+
+	core_writel(priv, port, CORE_FAST_AGE_PORT);
+
+	reg = core_readl(priv, CORE_FAST_AGE_CTRL);
+	reg |= EN_AGE_PORT | FAST_AGE_STR_DONE;
+	core_writel(priv, reg, CORE_FAST_AGE_CTRL);
+
+	do {
+		reg = core_readl(priv, CORE_FAST_AGE_CTRL);
+		if (!(reg & FAST_AGE_STR_DONE))
+			break;
+
+		cpu_relax();
+	} while (timeout--);
+
+	if (!timeout)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
+			      u32 br_port_mask)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	unsigned int i;
+	u32 reg, p_ctl;
+
+	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
+
+	for (i = 0; i < priv->hw_params.num_ports; i++) {
+		if (!((1 << i) & br_port_mask))
+			continue;
+
+		/* Add this local port to the remote port VLAN control
+		 * membership and update the remote port bitmask
+		 */
+		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
+		reg |= 1 << port;
+		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
+		priv->port_sts[i].vlan_ctl_mask = reg;
+
+		p_ctl |= 1 << i;
+	}
+
+	/* Configure the local port VLAN control membership to include
+	 * remote ports and update the local port bitmask
+	 */
+	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
+	priv->port_sts[port].vlan_ctl_mask = p_ctl;
+
+	return 0;
+}
+
+static int bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port,
+			       u32 br_port_mask)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	unsigned int i;
+	u32 reg, p_ctl;
+
+	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
+
+	for (i = 0; i < priv->hw_params.num_ports; i++) {
+		/* Don't touch the remaining ports */
+		if (!((1 << i) & br_port_mask))
+			continue;
+
+		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
+		reg &= ~(1 << port);
+		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
+		priv->port_sts[port].vlan_ctl_mask = reg;
+
+		/* Prevent self removal to preserve isolation */
+		if (port != i)
+			p_ctl &= ~(1 << i);
+	}
+
+	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
+	priv->port_sts[port].vlan_ctl_mask = p_ctl;
+
+	return 0;
+}
+
+static int bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
+				       u8 state)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	u8 hw_state, cur_hw_state;
+	int ret = 0;
+	u32 reg;
+
+	reg = core_readl(priv, CORE_G_PCTL_PORT(port));
+	cur_hw_state = reg >> G_MISTP_STATE_SHIFT;
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		hw_state = G_MISTP_DIS_STATE;
+		break;
+	case BR_STATE_LISTENING:
+		hw_state = G_MISTP_LISTEN_STATE;
+		break;
+	case BR_STATE_LEARNING:
+		hw_state = G_MISTP_LEARN_STATE;
+		break;
+	case BR_STATE_FORWARDING:
+		hw_state = G_MISTP_FWD_STATE;
+		break;
+	case BR_STATE_BLOCKING:
+		hw_state = G_MISTP_BLOCK_STATE;
+		break;
+	default:
+		pr_err("%s: invalid STP state: %d\n", __func__, state);
+		return -EINVAL;
+	}
+
+	/* Fast-age ARL entries if we are moving a port from Learning or
+	 * Forwarding state to Disabled, Blocking or Listening state
+	 */
+	if (cur_hw_state != hw_state) {
+		if (cur_hw_state & 4 && !(hw_state & 4)) {
+			ret = bcm_sf2_sw_fast_age_port(ds, port);
+			if (ret) {
+				pr_err("%s: fast-ageing failed\n", __func__);
+				return ret;
+			}
+		}
+	}
+
+	reg = core_readl(priv, CORE_G_PCTL_PORT(port));
+	reg &= ~(G_MISTP_STATE_MASK << G_MISTP_STATE_SHIFT);
+	reg |= hw_state;
+	core_writel(priv, reg, CORE_G_PCTL_PORT(port));
+
+	return 0;
+}
+
 static irqreturn_t bcm_sf2_switch_0_isr(int irq, void *dev_id)
 {
 	struct bcm_sf2_priv *priv = dev_id;
@@ -916,6 +1066,9 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.port_disable		= bcm_sf2_port_disable,
 	.get_eee		= bcm_sf2_sw_get_eee,
 	.set_eee		= bcm_sf2_sw_set_eee,
+	.port_join_bridge	= bcm_sf2_sw_br_join,
+	.port_leave_bridge	= bcm_sf2_sw_br_leave,
+	.port_stp_update	= bcm_sf2_sw_br_set_stp_state,
 };
 
 static int __init bcm_sf2_init(void)
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index ee9f650d5026..0f217e99904f 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -46,6 +46,8 @@ struct bcm_sf2_port_status {
 	unsigned int link;
 
 	struct ethtool_eee eee;
+
+	u32 vlan_ctl_mask;
 };
 
 struct bcm_sf2_priv {
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index cabdfa5e217a..fa4e6e78c9ea 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -163,6 +163,21 @@
 #define  EN_CHIP_RST			(1 << 6)
 #define  EN_SW_RESET			(1 << 4)
 
+#define CORE_FAST_AGE_CTRL		0x00220
+#define  EN_FAST_AGE_STATIC		(1 << 0)
+#define  EN_AGE_DYNAMIC			(1 << 1)
+#define  EN_AGE_PORT			(1 << 2)
+#define  EN_AGE_VLAN			(1 << 3)
+#define  EN_AGE_SPT			(1 << 4)
+#define  EN_AGE_MCAST			(1 << 5)
+#define  FAST_AGE_STR_DONE		(1 << 7)
+
+#define CORE_FAST_AGE_PORT		0x00224
+#define  AGE_PORT_MASK			0xf
+
+#define CORE_FAST_AGE_VID		0x00228
+#define  AGE_VID_MASK			0x3fff
+
 #define CORE_LNKSTS			0x00400
 #define  LNK_STS_MASK			0x1ff
 
-- 
2.1.0
