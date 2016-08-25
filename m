From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/6] net: dsa: bcm_sf2: Remove duplicate code
Date: Wed, 24 Aug 2016 18:33:45 -0700
Message-ID: <1472088825-20181-7-git-send-email-f.fainelli@gmail.com>
References: <1472088825-20181-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, jon.mason@broadcom.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36021 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758561AbcHYHzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 03:55:49 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so2769825pfg.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 00:55:49 -0700 (PDT)
In-Reply-To: <1472088825-20181-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we are using b53_common for most VLAN, FDB and bridge
operations, delete all the redundant code that we had in bcm_sf2.c to
keep only the integration specific logic that we have to deal with:
power management, link management and the external interfaces (RGMII,
MDIO).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 772 +----------------------------------------
 drivers/net/dsa/bcm_sf2.h      |  73 +---
 drivers/net/dsa/bcm_sf2_regs.h | 122 -------
 3 files changed, 17 insertions(+), 950 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 56e898f01c0f..6aee184b2963 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -36,109 +36,6 @@
 #include "b53/b53_priv.h"
 #include "b53/b53_regs.h"
 
-/* String, offset, and register size in bytes if different from 4 bytes */
-static const struct bcm_sf2_hw_stats bcm_sf2_mib[] = {
-	{ "TxOctets",		0x000, 8	},
-	{ "TxDropPkts",		0x020		},
-	{ "TxQPKTQ0",		0x030		},
-	{ "TxBroadcastPkts",	0x040		},
-	{ "TxMulticastPkts",	0x050		},
-	{ "TxUnicastPKts",	0x060		},
-	{ "TxCollisions",	0x070		},
-	{ "TxSingleCollision",	0x080		},
-	{ "TxMultipleCollision", 0x090		},
-	{ "TxDeferredCollision", 0x0a0		},
-	{ "TxLateCollision",	0x0b0		},
-	{ "TxExcessiveCollision", 0x0c0		},
-	{ "TxFrameInDisc",	0x0d0		},
-	{ "TxPausePkts",	0x0e0		},
-	{ "TxQPKTQ1",		0x0f0		},
-	{ "TxQPKTQ2",		0x100		},
-	{ "TxQPKTQ3",		0x110		},
-	{ "TxQPKTQ4",		0x120		},
-	{ "TxQPKTQ5",		0x130		},
-	{ "RxOctets",		0x140, 8	},
-	{ "RxUndersizePkts",	0x160		},
-	{ "RxPausePkts",	0x170		},
-	{ "RxPkts64Octets",	0x180		},
-	{ "RxPkts65to127Octets", 0x190		},
-	{ "RxPkts128to255Octets", 0x1a0		},
-	{ "RxPkts256to511Octets", 0x1b0		},
-	{ "RxPkts512to1023Octets", 0x1c0	},
-	{ "RxPkts1024toMaxPktsOctets", 0x1d0	},
-	{ "RxOversizePkts",	0x1e0		},
-	{ "RxJabbers",		0x1f0		},
-	{ "RxAlignmentErrors",	0x200		},
-	{ "RxFCSErrors",	0x210		},
-	{ "RxGoodOctets",	0x220, 8	},
-	{ "RxDropPkts",		0x240		},
-	{ "RxUnicastPkts",	0x250		},
-	{ "RxMulticastPkts",	0x260		},
-	{ "RxBroadcastPkts",	0x270		},
-	{ "RxSAChanges",	0x280		},
-	{ "RxFragments",	0x290		},
-	{ "RxJumboPkt",		0x2a0		},
-	{ "RxSymblErr",		0x2b0		},
-	{ "InRangeErrCount",	0x2c0		},
-	{ "OutRangeErrCount",	0x2d0		},
-	{ "EEELpiEvent",	0x2e0		},
-	{ "EEELpiDuration",	0x2f0		},
-	{ "RxDiscard",		0x300, 8	},
-	{ "TxQPKTQ6",		0x320		},
-	{ "TxQPKTQ7",		0x330		},
-	{ "TxPkts64Octets",	0x340		},
-	{ "TxPkts65to127Octets", 0x350		},
-	{ "TxPkts128to255Octets", 0x360		},
-	{ "TxPkts256to511Ocets", 0x370		},
-	{ "TxPkts512to1023Ocets", 0x380		},
-	{ "TxPkts1024toMaxPktOcets", 0x390	},
-};
-
-#define BCM_SF2_STATS_SIZE	ARRAY_SIZE(bcm_sf2_mib)
-
-static void bcm_sf2_sw_get_strings(struct dsa_switch *ds,
-				   int port, uint8_t *data)
-{
-	unsigned int i;
-
-	for (i = 0; i < BCM_SF2_STATS_SIZE; i++)
-		memcpy(data + i * ETH_GSTRING_LEN,
-		       bcm_sf2_mib[i].string, ETH_GSTRING_LEN);
-}
-
-static void bcm_sf2_sw_get_ethtool_stats(struct dsa_switch *ds,
-					 int port, uint64_t *data)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	const struct bcm_sf2_hw_stats *s;
-	unsigned int i;
-	u64 val = 0;
-	u32 offset;
-
-	mutex_lock(&priv->stats_mutex);
-
-	/* Now fetch the per-port counters */
-	for (i = 0; i < BCM_SF2_STATS_SIZE; i++) {
-		s = &bcm_sf2_mib[i];
-
-		/* Do a latched 64-bit read if needed */
-		offset = s->reg + CORE_P_MIB_OFFSET(port);
-		if (s->sizeof_stat == 8)
-			val = core_readq(priv, offset);
-		else
-			val = core_readl(priv, offset);
-
-		data[i] = (u64)val;
-	}
-
-	mutex_unlock(&priv->stats_mutex);
-}
-
-static int bcm_sf2_sw_get_sset_count(struct dsa_switch *ds)
-{
-	return BCM_SF2_STATS_SIZE;
-}
-
 static enum dsa_tag_protocol bcm_sf2_sw_get_tag_protocol(struct dsa_switch *ds)
 {
 	return DSA_TAG_PROTO_BRCM;
@@ -455,469 +352,6 @@ static int bcm_sf2_sw_set_eee(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static int bcm_sf2_fast_age_op(struct bcm_sf2_priv *priv)
-{
-	unsigned int timeout = 1000;
-	u32 reg;
-
-	reg = core_readl(priv, CORE_FAST_AGE_CTRL);
-	reg |= EN_AGE_PORT | EN_AGE_VLAN | EN_AGE_DYNAMIC | FAST_AGE_STR_DONE;
-	core_writel(priv, reg, CORE_FAST_AGE_CTRL);
-
-	do {
-		reg = core_readl(priv, CORE_FAST_AGE_CTRL);
-		if (!(reg & FAST_AGE_STR_DONE))
-			break;
-
-		cpu_relax();
-	} while (timeout--);
-
-	if (!timeout)
-		return -ETIMEDOUT;
-
-	core_writel(priv, 0, CORE_FAST_AGE_CTRL);
-
-	return 0;
-}
-
-/* Fast-ageing of ARL entries for a given port, equivalent to an ARL
- * flush for that port.
- */
-static int bcm_sf2_sw_fast_age_port(struct dsa_switch *ds, int port)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-
-	core_writel(priv, port, CORE_FAST_AGE_PORT);
-
-	return bcm_sf2_fast_age_op(priv);
-}
-
-static int bcm_sf2_sw_fast_age_vlan(struct bcm_sf2_priv *priv, u16 vid)
-{
-	core_writel(priv, vid, CORE_FAST_AGE_VID);
-
-	return bcm_sf2_fast_age_op(priv);
-}
-
-static int bcm_sf2_vlan_op_wait(struct bcm_sf2_priv *priv)
-{
-	unsigned int timeout = 10;
-	u32 reg;
-
-	do {
-		reg = core_readl(priv, CORE_ARLA_VTBL_RWCTRL);
-		if (!(reg & ARLA_VTBL_STDN))
-			return 0;
-
-		usleep_range(1000, 2000);
-	} while (timeout--);
-
-	return -ETIMEDOUT;
-}
-
-static int bcm_sf2_vlan_op(struct bcm_sf2_priv *priv, u8 op)
-{
-	core_writel(priv, ARLA_VTBL_STDN | op, CORE_ARLA_VTBL_RWCTRL);
-
-	return bcm_sf2_vlan_op_wait(priv);
-}
-
-static void bcm_sf2_set_vlan_entry(struct bcm_sf2_priv *priv, u16 vid,
-				   struct bcm_sf2_vlan *vlan)
-{
-	int ret;
-
-	core_writel(priv, vid & VTBL_ADDR_INDEX_MASK, CORE_ARLA_VTBL_ADDR);
-	core_writel(priv, vlan->untag << UNTAG_MAP_SHIFT | vlan->members,
-		    CORE_ARLA_VTBL_ENTRY);
-
-	ret = bcm_sf2_vlan_op(priv, ARLA_VTBL_CMD_WRITE);
-	if (ret)
-		pr_err("failed to write VLAN entry\n");
-}
-
-static int bcm_sf2_get_vlan_entry(struct bcm_sf2_priv *priv, u16 vid,
-				  struct bcm_sf2_vlan *vlan)
-{
-	u32 entry;
-	int ret;
-
-	core_writel(priv, vid & VTBL_ADDR_INDEX_MASK, CORE_ARLA_VTBL_ADDR);
-
-	ret = bcm_sf2_vlan_op(priv, ARLA_VTBL_CMD_READ);
-	if (ret)
-		return ret;
-
-	entry = core_readl(priv, CORE_ARLA_VTBL_ENTRY);
-	vlan->members = entry & FWD_MAP_MASK;
-	vlan->untag = (entry >> UNTAG_MAP_SHIFT) & UNTAG_MAP_MASK;
-
-	return 0;
-}
-
-static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
-			      struct net_device *bridge)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	s8 cpu_port = ds->dst->cpu_port;
-	unsigned int i;
-	u32 reg, p_ctl;
-
-	/* Make this port leave the all VLANs join since we will have proper
-	 * VLAN entries from now on
-	 */
-	reg = core_readl(priv, CORE_JOIN_ALL_VLAN_EN);
-	reg &= ~BIT(port);
-	if ((reg & BIT(cpu_port)) == BIT(cpu_port))
-		reg &= ~BIT(cpu_port);
-	core_writel(priv, reg, CORE_JOIN_ALL_VLAN_EN);
-
-	priv->port_sts[port].bridge_dev = bridge;
-	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
-
-	for (i = 0; i < priv->hw_params.num_ports; i++) {
-		if (priv->port_sts[i].bridge_dev != bridge)
-			continue;
-
-		/* Add this local port to the remote port VLAN control
-		 * membership and update the remote port bitmask
-		 */
-		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
-		reg |= 1 << port;
-		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
-		priv->port_sts[i].vlan_ctl_mask = reg;
-
-		p_ctl |= 1 << i;
-	}
-
-	/* Configure the local port VLAN control membership to include
-	 * remote ports and update the local port bitmask
-	 */
-	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
-	priv->port_sts[port].vlan_ctl_mask = p_ctl;
-
-	return 0;
-}
-
-static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	struct net_device *bridge = priv->port_sts[port].bridge_dev;
-	s8 cpu_port = ds->dst->cpu_port;
-	unsigned int i;
-	u32 reg, p_ctl;
-
-	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
-
-	for (i = 0; i < priv->hw_params.num_ports; i++) {
-		/* Don't touch the remaining ports */
-		if (priv->port_sts[i].bridge_dev != bridge)
-			continue;
-
-		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
-		reg &= ~(1 << port);
-		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
-		priv->port_sts[port].vlan_ctl_mask = reg;
-
-		/* Prevent self removal to preserve isolation */
-		if (port != i)
-			p_ctl &= ~(1 << i);
-	}
-
-	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
-	priv->port_sts[port].vlan_ctl_mask = p_ctl;
-	priv->port_sts[port].bridge_dev = NULL;
-
-	/* Make this port join all VLANs without VLAN entries */
-	reg = core_readl(priv, CORE_JOIN_ALL_VLAN_EN);
-	reg |= BIT(port);
-	if (!(reg & BIT(cpu_port)))
-		reg |= BIT(cpu_port);
-	core_writel(priv, reg, CORE_JOIN_ALL_VLAN_EN);
-}
-
-static void bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
-					u8 state)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	u8 hw_state, cur_hw_state;
-	u32 reg;
-
-	reg = core_readl(priv, CORE_G_PCTL_PORT(port));
-	cur_hw_state = reg & (G_MISTP_STATE_MASK << G_MISTP_STATE_SHIFT);
-
-	switch (state) {
-	case BR_STATE_DISABLED:
-		hw_state = G_MISTP_DIS_STATE;
-		break;
-	case BR_STATE_LISTENING:
-		hw_state = G_MISTP_LISTEN_STATE;
-		break;
-	case BR_STATE_LEARNING:
-		hw_state = G_MISTP_LEARN_STATE;
-		break;
-	case BR_STATE_FORWARDING:
-		hw_state = G_MISTP_FWD_STATE;
-		break;
-	case BR_STATE_BLOCKING:
-		hw_state = G_MISTP_BLOCK_STATE;
-		break;
-	default:
-		pr_err("%s: invalid STP state: %d\n", __func__, state);
-		return;
-	}
-
-	/* Fast-age ARL entries if we are moving a port from Learning or
-	 * Forwarding (cur_hw_state) state to Disabled, Blocking or Listening
-	 * state (hw_state)
-	 */
-	if (cur_hw_state != hw_state) {
-		if (cur_hw_state >= G_MISTP_LEARN_STATE &&
-		    hw_state <= G_MISTP_LISTEN_STATE) {
-			if (bcm_sf2_sw_fast_age_port(ds, port)) {
-				pr_err("%s: fast-ageing failed\n", __func__);
-				return;
-			}
-		}
-	}
-
-	reg = core_readl(priv, CORE_G_PCTL_PORT(port));
-	reg &= ~(G_MISTP_STATE_MASK << G_MISTP_STATE_SHIFT);
-	reg |= hw_state;
-	core_writel(priv, reg, CORE_G_PCTL_PORT(port));
-}
-
-/* Address Resolution Logic routines */
-static int bcm_sf2_arl_op_wait(struct bcm_sf2_priv *priv)
-{
-	unsigned int timeout = 10;
-	u32 reg;
-
-	do {
-		reg = core_readl(priv, CORE_ARLA_RWCTL);
-		if (!(reg & ARL_STRTDN))
-			return 0;
-
-		usleep_range(1000, 2000);
-	} while (timeout--);
-
-	return -ETIMEDOUT;
-}
-
-static int bcm_sf2_arl_rw_op(struct bcm_sf2_priv *priv, unsigned int op)
-{
-	u32 cmd;
-
-	if (op > ARL_RW)
-		return -EINVAL;
-
-	cmd = core_readl(priv, CORE_ARLA_RWCTL);
-	cmd &= ~IVL_SVL_SELECT;
-	cmd |= ARL_STRTDN;
-	if (op)
-		cmd |= ARL_RW;
-	else
-		cmd &= ~ARL_RW;
-	core_writel(priv, cmd, CORE_ARLA_RWCTL);
-
-	return bcm_sf2_arl_op_wait(priv);
-}
-
-static int bcm_sf2_arl_read(struct bcm_sf2_priv *priv, u64 mac,
-			    u16 vid, struct bcm_sf2_arl_entry *ent, u8 *idx,
-			    bool is_valid)
-{
-	unsigned int i;
-	int ret;
-
-	ret = bcm_sf2_arl_op_wait(priv);
-	if (ret)
-		return ret;
-
-	/* Read the 4 bins */
-	for (i = 0; i < 4; i++) {
-		u64 mac_vid;
-		u32 fwd_entry;
-
-		mac_vid = core_readq(priv, CORE_ARLA_MACVID_ENTRY(i));
-		fwd_entry = core_readl(priv, CORE_ARLA_FWD_ENTRY(i));
-		bcm_sf2_arl_to_entry(ent, mac_vid, fwd_entry);
-
-		if (ent->is_valid && is_valid) {
-			*idx = i;
-			return 0;
-		}
-
-		/* This is the MAC we just deleted */
-		if (!is_valid && (mac_vid & mac))
-			return 0;
-	}
-
-	return -ENOENT;
-}
-
-static int bcm_sf2_arl_op(struct bcm_sf2_priv *priv, int op, int port,
-			  const unsigned char *addr, u16 vid, bool is_valid)
-{
-	struct bcm_sf2_arl_entry ent;
-	u32 fwd_entry;
-	u64 mac, mac_vid = 0;
-	u8 idx = 0;
-	int ret;
-
-	/* Convert the array into a 64-bit MAC */
-	mac = bcm_sf2_mac_to_u64(addr);
-
-	/* Perform a read for the given MAC and VID */
-	core_writeq(priv, mac, CORE_ARLA_MAC);
-	core_writel(priv, vid, CORE_ARLA_VID);
-
-	/* Issue a read operation for this MAC */
-	ret = bcm_sf2_arl_rw_op(priv, 1);
-	if (ret)
-		return ret;
-
-	ret = bcm_sf2_arl_read(priv, mac, vid, &ent, &idx, is_valid);
-	/* If this is a read, just finish now */
-	if (op)
-		return ret;
-
-	/* We could not find a matching MAC, so reset to a new entry */
-	if (ret) {
-		fwd_entry = 0;
-		idx = 0;
-	}
-
-	memset(&ent, 0, sizeof(ent));
-	ent.port = port;
-	ent.is_valid = is_valid;
-	ent.vid = vid;
-	ent.is_static = true;
-	memcpy(ent.mac, addr, ETH_ALEN);
-	bcm_sf2_arl_from_entry(&mac_vid, &fwd_entry, &ent);
-
-	core_writeq(priv, mac_vid, CORE_ARLA_MACVID_ENTRY(idx));
-	core_writel(priv, fwd_entry, CORE_ARLA_FWD_ENTRY(idx));
-
-	ret = bcm_sf2_arl_rw_op(priv, 0);
-	if (ret)
-		return ret;
-
-	/* Re-read the entry to check */
-	return bcm_sf2_arl_read(priv, mac, vid, &ent, &idx, is_valid);
-}
-
-static int bcm_sf2_sw_fdb_prepare(struct dsa_switch *ds, int port,
-				  const struct switchdev_obj_port_fdb *fdb,
-				  struct switchdev_trans *trans)
-{
-	/* We do not need to do anything specific here yet */
-	return 0;
-}
-
-static void bcm_sf2_sw_fdb_add(struct dsa_switch *ds, int port,
-			       const struct switchdev_obj_port_fdb *fdb,
-			       struct switchdev_trans *trans)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-
-	if (bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, true))
-		pr_err("%s: failed to add MAC address\n", __func__);
-}
-
-static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, int port,
-			      const struct switchdev_obj_port_fdb *fdb)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-
-	return bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
-}
-
-static int bcm_sf2_arl_search_wait(struct bcm_sf2_priv *priv)
-{
-	unsigned timeout = 1000;
-	u32 reg;
-
-	do {
-		reg = core_readl(priv, CORE_ARLA_SRCH_CTL);
-		if (!(reg & ARLA_SRCH_STDN))
-			return 0;
-
-		if (reg & ARLA_SRCH_VLID)
-			return 0;
-
-		usleep_range(1000, 2000);
-	} while (timeout--);
-
-	return -ETIMEDOUT;
-}
-
-static void bcm_sf2_arl_search_rd(struct bcm_sf2_priv *priv, u8 idx,
-				  struct bcm_sf2_arl_entry *ent)
-{
-	u64 mac_vid;
-	u32 fwd_entry;
-
-	mac_vid = core_readq(priv, CORE_ARLA_SRCH_RSLT_MACVID(idx));
-	fwd_entry = core_readl(priv, CORE_ARLA_SRCH_RSLT(idx));
-	bcm_sf2_arl_to_entry(ent, mac_vid, fwd_entry);
-}
-
-static int bcm_sf2_sw_fdb_copy(struct net_device *dev, int port,
-			       const struct bcm_sf2_arl_entry *ent,
-			       struct switchdev_obj_port_fdb *fdb,
-			       int (*cb)(struct switchdev_obj *obj))
-{
-	if (!ent->is_valid)
-		return 0;
-
-	if (port != ent->port)
-		return 0;
-
-	ether_addr_copy(fdb->addr, ent->mac);
-	fdb->vid = ent->vid;
-	fdb->ndm_state = ent->is_static ? NUD_NOARP : NUD_REACHABLE;
-
-	return cb(&fdb->obj);
-}
-
-static int bcm_sf2_sw_fdb_dump(struct dsa_switch *ds, int port,
-			       struct switchdev_obj_port_fdb *fdb,
-			       int (*cb)(struct switchdev_obj *obj))
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	struct net_device *dev = ds->ports[port].netdev;
-	struct bcm_sf2_arl_entry results[2];
-	unsigned int count = 0;
-	int ret;
-
-	/* Start search operation */
-	core_writel(priv, ARLA_SRCH_STDN, CORE_ARLA_SRCH_CTL);
-
-	do {
-		ret = bcm_sf2_arl_search_wait(priv);
-		if (ret)
-			return ret;
-
-		/* Read both entries, then return their values back */
-		bcm_sf2_arl_search_rd(priv, 0, &results[0]);
-		ret = bcm_sf2_sw_fdb_copy(dev, port, &results[0], fdb, cb);
-		if (ret)
-			return ret;
-
-		bcm_sf2_arl_search_rd(priv, 1, &results[1]);
-		ret = bcm_sf2_sw_fdb_copy(dev, port, &results[1], fdb, cb);
-		if (ret)
-			return ret;
-
-		if (!results[0].is_valid && !results[1].is_valid)
-			break;
-
-	} while (count++ < CORE_ARLA_NUM_ENTRIES);
-
-	return 0;
-}
-
 static int bcm_sf2_sw_indir_rw(struct bcm_sf2_priv *priv, int op, int addr,
 			       int regnum, u16 val)
 {
@@ -1140,11 +574,6 @@ static void bcm_sf2_mdio_unregister(struct bcm_sf2_priv *priv)
 		of_node_put(priv->master_mii_dn);
 }
 
-static int bcm_sf2_sw_set_addr(struct dsa_switch *ds, u8 *addr)
-{
-	return 0;
-}
-
 static u32 bcm_sf2_sw_get_phy_flags(struct dsa_switch *ds, int port)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
@@ -1387,38 +816,27 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 	return p->ethtool_ops->set_wol(p, wol);
 }
 
-static void bcm_sf2_enable_vlan(struct bcm_sf2_priv *priv, bool enable)
+static int bcm_sf2_vlan_op_wait(struct bcm_sf2_priv *priv)
 {
-	u32 mgmt, vc0, vc1, vc4, vc5;
+	unsigned int timeout = 10;
+	u32 reg;
 
-	mgmt = core_readl(priv, CORE_SWMODE);
-	vc0 = core_readl(priv, CORE_VLAN_CTRL0);
-	vc1 = core_readl(priv, CORE_VLAN_CTRL1);
-	vc4 = core_readl(priv, CORE_VLAN_CTRL4);
-	vc5 = core_readl(priv, CORE_VLAN_CTRL5);
+	do {
+		reg = core_readl(priv, CORE_ARLA_VTBL_RWCTRL);
+		if (!(reg & ARLA_VTBL_STDN))
+			return 0;
 
-	mgmt &= ~SW_FWDG_MODE;
+		usleep_range(1000, 2000);
+	} while (timeout--);
 
-	if (enable) {
-		vc0 |= VLAN_EN | VLAN_LEARN_MODE_IVL;
-		vc1 |= EN_RSV_MCAST_UNTAG | EN_RSV_MCAST_FWDMAP;
-		vc4 &= ~(INGR_VID_CHK_MASK << INGR_VID_CHK_SHIFT);
-		vc4 |= INGR_VID_CHK_DROP;
-		vc5 |= DROP_VTABLE_MISS | EN_VID_FFF_FWD;
-	} else {
-		vc0 &= ~(VLAN_EN | VLAN_LEARN_MODE_IVL);
-		vc1 &= ~(EN_RSV_MCAST_UNTAG | EN_RSV_MCAST_FWDMAP);
-		vc4 &= ~(INGR_VID_CHK_MASK << INGR_VID_CHK_SHIFT);
-		vc5 &= ~(DROP_VTABLE_MISS | EN_VID_FFF_FWD);
-		vc4 |= INGR_VID_CHK_VID_VIOL_IMP;
-	}
+	return -ETIMEDOUT;
+}
 
-	core_writel(priv, vc0, CORE_VLAN_CTRL0);
-	core_writel(priv, vc1, CORE_VLAN_CTRL1);
-	core_writel(priv, 0, CORE_VLAN_CTRL3);
-	core_writel(priv, vc4, CORE_VLAN_CTRL4);
-	core_writel(priv, vc5, CORE_VLAN_CTRL5);
-	core_writel(priv, mgmt, CORE_SWMODE);
+static int bcm_sf2_vlan_op(struct bcm_sf2_priv *priv, u8 op)
+{
+	core_writel(priv, ARLA_VTBL_STDN | op, CORE_ARLA_VTBL_RWCTRL);
+
+	return bcm_sf2_vlan_op_wait(priv);
 }
 
 static void bcm_sf2_sw_configure_vlan(struct dsa_switch *ds)
@@ -1437,132 +855,6 @@ static void bcm_sf2_sw_configure_vlan(struct dsa_switch *ds)
 	}
 }
 
-static int bcm_sf2_sw_vlan_filtering(struct dsa_switch *ds, int port,
-				     bool vlan_filtering)
-{
-	return 0;
-}
-
-static int bcm_sf2_sw_vlan_prepare(struct dsa_switch *ds, int port,
-				   const struct switchdev_obj_port_vlan *vlan,
-				   struct switchdev_trans *trans)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-
-	bcm_sf2_enable_vlan(priv, true);
-
-	return 0;
-}
-
-static void bcm_sf2_sw_vlan_add(struct dsa_switch *ds, int port,
-				const struct switchdev_obj_port_vlan *vlan,
-				struct switchdev_trans *trans)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
-	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
-	s8 cpu_port = ds->dst->cpu_port;
-	struct bcm_sf2_vlan *vl;
-	u16 vid;
-
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
-		vl = &priv->vlans[vid];
-
-		bcm_sf2_get_vlan_entry(priv, vid, vl);
-
-		vl->members |= BIT(port) | BIT(cpu_port);
-		if (untagged)
-			vl->untag |= BIT(port) | BIT(cpu_port);
-		else
-			vl->untag &= ~(BIT(port) | BIT(cpu_port));
-
-		bcm_sf2_set_vlan_entry(priv, vid, vl);
-		bcm_sf2_sw_fast_age_vlan(priv, vid);
-	}
-
-	if (pvid) {
-		core_writel(priv, vlan->vid_end, CORE_DEFAULT_1Q_TAG_P(port));
-		core_writel(priv, vlan->vid_end,
-			    CORE_DEFAULT_1Q_TAG_P(cpu_port));
-		bcm_sf2_sw_fast_age_vlan(priv, vid);
-	}
-}
-
-static int bcm_sf2_sw_vlan_del(struct dsa_switch *ds, int port,
-			       const struct switchdev_obj_port_vlan *vlan)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
-	s8 cpu_port = ds->dst->cpu_port;
-	struct bcm_sf2_vlan *vl;
-	u16 vid, pvid;
-	int ret;
-
-	pvid = core_readl(priv, CORE_DEFAULT_1Q_TAG_P(port));
-
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
-		vl = &priv->vlans[vid];
-
-		ret = bcm_sf2_get_vlan_entry(priv, vid, vl);
-		if (ret)
-			return ret;
-
-		vl->members &= ~BIT(port);
-		if ((vl->members & BIT(cpu_port)) == BIT(cpu_port))
-			vl->members = 0;
-		if (pvid == vid)
-			pvid = 0;
-		if (untagged) {
-			vl->untag &= ~BIT(port);
-			if ((vl->untag & BIT(port)) == BIT(cpu_port))
-				vl->untag = 0;
-		}
-
-		bcm_sf2_set_vlan_entry(priv, vid, vl);
-		bcm_sf2_sw_fast_age_vlan(priv, vid);
-	}
-
-	core_writel(priv, pvid, CORE_DEFAULT_1Q_TAG_P(port));
-	core_writel(priv, pvid, CORE_DEFAULT_1Q_TAG_P(cpu_port));
-	bcm_sf2_sw_fast_age_vlan(priv, vid);
-
-	return 0;
-}
-
-static int bcm_sf2_sw_vlan_dump(struct dsa_switch *ds, int port,
-				struct switchdev_obj_port_vlan *vlan,
-				int (*cb)(struct switchdev_obj *obj))
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	struct bcm_sf2_port_status *p = &priv->port_sts[port];
-	struct bcm_sf2_vlan *vl;
-	u16 vid, pvid;
-	int err = 0;
-
-	pvid = core_readl(priv, CORE_DEFAULT_1Q_TAG_P(port));
-
-	for (vid = 0; vid < VLAN_N_VID; vid++) {
-		vl = &priv->vlans[vid];
-
-		if (!(vl->members & BIT(port)))
-			continue;
-
-		vlan->vid_begin = vlan->vid_end = vid;
-		vlan->flags = 0;
-
-		if (vl->untag & BIT(port))
-			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
-		if (p->pvid == vid)
-			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
-
-		err = cb(&vlan->obj);
-		if (err)
-			break;
-	}
-
-	return err;
-}
-
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
@@ -1584,38 +876,6 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static struct dsa_switch_driver bcm_sf2_switch_driver = {
-	.setup			= bcm_sf2_sw_setup,
-	.get_tag_protocol	= bcm_sf2_sw_get_tag_protocol,
-	.set_addr		= bcm_sf2_sw_set_addr,
-	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
-	.get_strings		= bcm_sf2_sw_get_strings,
-	.get_ethtool_stats	= bcm_sf2_sw_get_ethtool_stats,
-	.get_sset_count		= bcm_sf2_sw_get_sset_count,
-	.adjust_link		= bcm_sf2_sw_adjust_link,
-	.fixed_link_update	= bcm_sf2_sw_fixed_link_update,
-	.suspend		= bcm_sf2_sw_suspend,
-	.resume			= bcm_sf2_sw_resume,
-	.get_wol		= bcm_sf2_sw_get_wol,
-	.set_wol		= bcm_sf2_sw_set_wol,
-	.port_enable		= bcm_sf2_port_setup,
-	.port_disable		= bcm_sf2_port_disable,
-	.get_eee		= bcm_sf2_sw_get_eee,
-	.set_eee		= bcm_sf2_sw_set_eee,
-	.port_bridge_join	= bcm_sf2_sw_br_join,
-	.port_bridge_leave	= bcm_sf2_sw_br_leave,
-	.port_stp_state_set	= bcm_sf2_sw_br_set_stp_state,
-	.port_fdb_prepare	= bcm_sf2_sw_fdb_prepare,
-	.port_fdb_add		= bcm_sf2_sw_fdb_add,
-	.port_fdb_del		= bcm_sf2_sw_fdb_del,
-	.port_fdb_dump		= bcm_sf2_sw_fdb_dump,
-	.port_vlan_filtering	= bcm_sf2_sw_vlan_filtering,
-	.port_vlan_prepare	= bcm_sf2_sw_vlan_prepare,
-	.port_vlan_add		= bcm_sf2_sw_vlan_add,
-	.port_vlan_del		= bcm_sf2_sw_vlan_del,
-	.port_vlan_dump		= bcm_sf2_sw_vlan_dump,
-};
-
 /* The SWITCH_CORE register space is managed by b53 but operates on a page +
  * register basis so we need to translate that into an address that the
  * bus-glue understands.
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 7e95fb7d5d2e..c4c12d9d6956 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -51,71 +51,9 @@ struct bcm_sf2_port_status {
 
 	struct ethtool_eee eee;
 
-	u32 vlan_ctl_mask;
-	u16 pvid;
-
-	struct net_device *bridge_dev;
-};
-
-struct bcm_sf2_arl_entry {
-	u8 port;
-	u8 mac[ETH_ALEN];
-	u16 vid;
-	u8 is_valid:1;
-	u8 is_age:1;
-	u8 is_static:1;
+	u16 vlan_ctl_mask;
 };
 
-struct bcm_sf2_vlan {
-	u16 members;
-	u16 untag;
-};
-
-static inline void bcm_sf2_mac_from_u64(u64 src, u8 *dst)
-{
-	unsigned int i;
-
-	for (i = 0; i < ETH_ALEN; i++)
-		dst[ETH_ALEN - 1 - i] = (src >> (8 * i)) & 0xff;
-}
-
-static inline u64 bcm_sf2_mac_to_u64(const u8 *src)
-{
-	unsigned int i;
-	u64 dst = 0;
-
-	for (i = 0; i < ETH_ALEN; i++)
-		dst |= (u64)src[ETH_ALEN - 1 - i] << (8 * i);
-
-	return dst;
-}
-
-static inline void bcm_sf2_arl_to_entry(struct bcm_sf2_arl_entry *ent,
-					u64 mac_vid, u32 fwd_entry)
-{
-	memset(ent, 0, sizeof(*ent));
-	ent->port = fwd_entry & PORTID_MASK;
-	ent->is_valid = !!(fwd_entry & ARL_VALID);
-	ent->is_age = !!(fwd_entry & ARL_AGE);
-	ent->is_static = !!(fwd_entry & ARL_STATIC);
-	bcm_sf2_mac_from_u64(mac_vid, ent->mac);
-	ent->vid = mac_vid >> VID_SHIFT;
-}
-
-static inline void bcm_sf2_arl_from_entry(u64 *mac_vid, u32 *fwd_entry,
-					  const struct bcm_sf2_arl_entry *ent)
-{
-	*mac_vid = bcm_sf2_mac_to_u64(ent->mac);
-	*mac_vid |= (u64)(ent->vid & VID_MASK) << VID_SHIFT;
-	*fwd_entry = ent->port & PORTID_MASK;
-	if (ent->is_valid)
-		*fwd_entry |= ARL_VALID;
-	if (ent->is_static)
-		*fwd_entry |= ARL_STATIC;
-	if (ent->is_age)
-		*fwd_entry |= ARL_AGE;
-}
-
 struct bcm_sf2_priv {
 	/* Base registers, keep those in order with BCM_SF2_REGS_NAME */
 	void __iomem			*core;
@@ -159,9 +97,6 @@ struct bcm_sf2_priv {
 	struct device_node		*master_mii_dn;
 	struct mii_bus			*slave_mii_bus;
 	struct mii_bus			*master_mii_bus;
-
-	/* Cache of programmed VLANs */
-	struct bcm_sf2_vlan		vlans[VLAN_N_VID];
 };
 
 static inline struct bcm_sf2_priv *bcm_sf2_to_priv(struct dsa_switch *ds)
@@ -171,12 +106,6 @@ static inline struct bcm_sf2_priv *bcm_sf2_to_priv(struct dsa_switch *ds)
 	return dev->priv;
 }
 
-struct bcm_sf2_hw_stats {
-	const char	*string;
-	u16		reg;
-	u8		sizeof_stat;
-};
-
 #define SF2_IO_MACRO(name) \
 static inline u32 name##_readl(struct bcm_sf2_priv *priv, u32 off)	\
 {									\
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 9f2a9cb42074..838fe373cd6f 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -115,14 +115,6 @@
 #define  RX_BCST_EN			(1 << 2)
 #define  RX_MCST_EN			(1 << 3)
 #define  RX_UCST_EN			(1 << 4)
-#define  G_MISTP_STATE_SHIFT		5
-#define  G_MISTP_NO_STP			(0 << G_MISTP_STATE_SHIFT)
-#define  G_MISTP_DIS_STATE		(1 << G_MISTP_STATE_SHIFT)
-#define  G_MISTP_BLOCK_STATE		(2 << G_MISTP_STATE_SHIFT)
-#define  G_MISTP_LISTEN_STATE		(3 << G_MISTP_STATE_SHIFT)
-#define  G_MISTP_LEARN_STATE		(4 << G_MISTP_STATE_SHIFT)
-#define  G_MISTP_FWD_STATE		(5 << G_MISTP_STATE_SHIFT)
-#define  G_MISTP_STATE_MASK		0x7
 
 #define CORE_SWMODE			0x0002c
 #define  SW_FWDG_MODE			(1 << 0)
@@ -205,75 +197,11 @@
 #define  BRCM_HDR_EN_P5			(1 << 1)
 #define  BRCM_HDR_EN_P7			(1 << 2)
 
-#define CORE_BRCM_HDR_CTRL2		0x0828
-
-#define CORE_HL_PRTC_CTRL		0x0940
-#define  ARP_EN				(1 << 0)
-#define  RARP_EN			(1 << 1)
-#define  DHCP_EN			(1 << 2)
-#define  ICMPV4_EN			(1 << 3)
-#define  ICMPV6_EN			(1 << 4)
-#define  ICMPV6_FWD_MODE		(1 << 5)
-#define  IGMP_DIP_EN			(1 << 8)
-#define  IGMP_RPTLVE_EN			(1 << 9)
-#define  IGMP_RTPLVE_FWD_MODE		(1 << 10)
-#define  IGMP_QRY_EN			(1 << 11)
-#define  IGMP_QRY_FWD_MODE		(1 << 12)
-#define  IGMP_UKN_EN			(1 << 13)
-#define  IGMP_UKN_FWD_MODE		(1 << 14)
-#define  MLD_RPTDONE_EN			(1 << 15)
-#define  MLD_RPTDONE_FWD_MODE		(1 << 16)
-#define  MLD_QRY_EN			(1 << 17)
-#define  MLD_QRY_FWD_MODE		(1 << 18)
-
 #define CORE_RST_MIB_CNT_EN		0x0950
 
 #define CORE_BRCM_HDR_RX_DIS		0x0980
 #define CORE_BRCM_HDR_TX_DIS		0x0988
 
-#define CORE_ARLA_NUM_ENTRIES		1024
-
-#define CORE_ARLA_RWCTL			0x1400
-#define  ARL_RW				(1 << 0)
-#define  IVL_SVL_SELECT			(1 << 6)
-#define  ARL_STRTDN			(1 << 7)
-
-#define CORE_ARLA_MAC			0x1408
-#define CORE_ARLA_VID			0x1420
-#define  ARLA_VIDTAB_INDX_MASK		0x1fff
-
-#define CORE_ARLA_MACVID0		0x1440
-#define  MAC_MASK			0xffffffffff
-#define  VID_SHIFT			48
-#define  VID_MASK			0xfff
-
-#define CORE_ARLA_FWD_ENTRY0		0x1460
-#define  PORTID_MASK			0x1ff
-#define  ARL_CON_SHIFT			9
-#define  ARL_CON_MASK			0x3
-#define  ARL_PRI_SHIFT			11
-#define  ARL_PRI_MASK			0x7
-#define  ARL_AGE			(1 << 14)
-#define  ARL_STATIC			(1 << 15)
-#define  ARL_VALID			(1 << 16)
-
-#define CORE_ARLA_MACVID_ENTRY(x)	(CORE_ARLA_MACVID0 + ((x) * 0x40))
-#define CORE_ARLA_FWD_ENTRY(x)		(CORE_ARLA_FWD_ENTRY0 + ((x) * 0x40))
-
-#define CORE_ARLA_SRCH_CTL		0x1540
-#define  ARLA_SRCH_VLID			(1 << 0)
-#define  IVL_SVL_SELECT			(1 << 6)
-#define  ARLA_SRCH_STDN			(1 << 7)
-
-#define CORE_ARLA_SRCH_ADR		0x1544
-#define  ARLA_SRCH_ADR_VALID		(1 << 15)
-
-#define CORE_ARLA_SRCH_RSLT_0_MACVID	0x1580
-#define CORE_ARLA_SRCH_RSLT_0		0x15a0
-
-#define CORE_ARLA_SRCH_RSLT_MACVID(x)	(CORE_ARLA_SRCH_RSLT_0_MACVID + ((x) * 0x40))
-#define CORE_ARLA_SRCH_RSLT(x)		(CORE_ARLA_SRCH_RSLT_0 + ((x) * 0x40))
-
 #define CORE_ARLA_VTBL_RWCTRL		0x1600
 #define  ARLA_VTBL_CMD_WRITE		0
 #define  ARLA_VTBL_CMD_READ		1
@@ -297,59 +225,9 @@
 #define  P_TXQ_PSM_VDD(x)		(P_TXQ_PSM_VDD_MASK << \
 					((x) * P_TXQ_PSM_VDD_SHIFT))
 
-#define	CORE_P0_MIB_OFFSET		0x8000
-#define P_MIB_SIZE			0x400
-#define CORE_P_MIB_OFFSET(x)		(CORE_P0_MIB_OFFSET + (x) * P_MIB_SIZE)
-
 #define CORE_PORT_VLAN_CTL_PORT(x)	(0xc400 + ((x) * 0x8))
 #define  PORT_VLAN_CTRL_MASK		0x1ff
 
-#define CORE_VLAN_CTRL0			0xd000
-#define  CHANGE_1P_VID_INNER		(1 << 0)
-#define  CHANGE_1P_VID_OUTER		(1 << 1)
-#define  CHANGE_1Q_VID			(1 << 3)
-#define  VLAN_LEARN_MODE_SVL		(0 << 5)
-#define  VLAN_LEARN_MODE_IVL		(3 << 5)
-#define  VLAN_EN			(1 << 7)
-
-#define CORE_VLAN_CTRL1			0xd004
-#define  EN_RSV_MCAST_FWDMAP		(1 << 2)
-#define  EN_RSV_MCAST_UNTAG		(1 << 3)
-#define  EN_IPMC_BYPASS_FWDMAP		(1 << 5)
-#define  EN_IPMC_BYPASS_UNTAG		(1 << 6)
-
-#define CORE_VLAN_CTRL2			0xd008
-#define  EN_MIIM_BYPASS_V_FWDMAP	(1 << 2)
-#define  EN_GMRP_GVRP_V_FWDMAP		(1 << 5)
-#define  EN_GMRP_GVRP_UNTAG_MAP		(1 << 6)
-
-#define CORE_VLAN_CTRL3			0xd00c
-#define  EN_DROP_NON1Q_MASK		0x1ff
-
-#define CORE_VLAN_CTRL4			0xd014
-#define  RESV_MCAST_FLOOD		(1 << 1)
-#define  EN_DOUBLE_TAG_MASK		0x3
-#define  EN_DOUBLE_TAG_SHIFT		2
-#define  EN_MGE_REV_GMRP		(1 << 4)
-#define  EN_MGE_REV_GVRP		(1 << 5)
-#define  INGR_VID_CHK_SHIFT		6
-#define  INGR_VID_CHK_MASK		0x3
-#define  INGR_VID_CHK_FWD		(0 << INGR_VID_CHK_SHIFT)
-#define  INGR_VID_CHK_DROP		(1 << INGR_VID_CHK_SHIFT)
-#define  INGR_VID_CHK_NO_CHK		(2 << INGR_VID_CHK_SHIFT)
-#define  INGR_VID_CHK_VID_VIOL_IMP	(3 << INGR_VID_CHK_SHIFT)
-
-#define CORE_VLAN_CTRL5			0xd018
-#define  EN_CPU_RX_BYP_INNER_CRCCHCK	(1 << 0)
-#define  EN_VID_FFF_FWD			(1 << 2)
-#define  DROP_VTABLE_MISS		(1 << 3)
-#define  EGRESS_DIR_FRM_BYP_TRUNK_EN	(1 << 4)
-#define  PRESV_NON1Q			(1 << 6)
-
-#define CORE_VLAN_CTRL6			0xd01c
-#define  STRICT_SFD_DETECT		(1 << 0)
-#define  DIS_ARL_BUST_LMIT		(1 << 4)
-
 #define CORE_DEFAULT_1Q_TAG_P(x)	(0xd040 + ((x) * 8))
 #define  CFI_SHIFT			12
 #define  PRI_SHIFT			13
-- 
2.7.4
