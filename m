From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] bridge: switchdev: Add forward mark support for stacked devices
Date: Thu, 25 Aug 2016 18:42:37 +0200
Message-ID: <1472143360-15796-3-git-send-email-jiri@resnulli.us>
References: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        gospo@cumulusnetworks.com, ast@plumgrid.com, edumazet@google.com,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35462 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759384AbcHYQnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:43:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id i5so8153920wmg.2
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:42:46 -0700 (PDT)
In-Reply-To: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

switchdev_port_fwd_mark_set() is used to set the 'offload_fwd_mark' of
port netdevs so that packets being flooded by the device won't be
flooded twice.

It works by assigning a unique identifier (the ifindex of the first
bridge port) to bridge ports sharing the same parent ID. This prevents
packets from being flooded twice by the same switch, but will flood
packets through bridge ports belonging to a different switch.

This method is problematic when stacked devices are taken into account,
such as VLANs. In such cases, a physical port netdev can have upper
devices being members in two different bridges, thus requiring two
different 'offload_fwd_mark's to be configured on the port netdev, which
is impossible.

The main problem is that packet and netdev marking is performed at the
physical netdev level, whereas flooding occurs between bridge ports,
which are not necessarily port netdevs.

Instead, packet and netdev marking should really be done in the bridge
driver with the switch driver only telling it which packets it already
forwarded. The bridge driver will mark such packets using the mark
assigned to the ingress bridge port and will prevent the packet from
being forwarded through any bridge port sharing the same mark (i.e.
having the same parent ID).

Remove the current switchdev 'offload_fwd_mark' implementation and
instead implement the proposed method. In addition, make rocker - the
sole user of the mark - use the proposed method.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 Documentation/networking/switchdev.txt     | 13 ++---
 drivers/net/ethernet/rocker/rocker_main.c  |  2 +-
 drivers/net/ethernet/rocker/rocker_ofdpa.c |  4 --
 include/linux/netdevice.h                  |  5 --
 include/linux/skbuff.h                     | 13 ++---
 include/net/switchdev.h                    |  6 ---
 net/bridge/Makefile                        |  2 +
 net/bridge/br_forward.c                    |  3 +-
 net/bridge/br_if.c                         | 10 ++--
 net/bridge/br_input.c                      |  2 +
 net/bridge/br_private.h                    | 37 +++++++++++++
 net/bridge/br_switchdev.c                  | 57 ++++++++++++++++++++
 net/core/dev.c                             | 10 ----
 net/switchdev/switchdev.c                  | 85 ------------------------------
 14 files changed, 117 insertions(+), 132 deletions(-)
 create mode 100644 net/bridge/br_switchdev.c

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 31c3911..44235e8 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -283,15 +283,10 @@ be sent to the port netdev for processing by the bridge driver.  The
 bridge should not reflood the packet to the same ports the device flooded,
 otherwise there will be duplicate packets on the wire.
 
-To avoid duplicate packets, the device/driver should mark a packet as already
-forwarded using skb->offload_fwd_mark.  The same mark is set on the device
-ports in the domain using dev->offload_fwd_mark.  If the skb->offload_fwd_mark
-is non-zero and matches the forwarding egress port's dev->skb_mark, the kernel
-will drop the skb right before transmit on the egress port, with the
-understanding that the device already forwarded the packet on same egress port.
-The driver can use switchdev_port_fwd_mark_set() to set a globally unique mark
-for port's dev->offload_fwd_mark, based on the port's parent ID (switch ID) and
-a group ifindex.
+To avoid duplicate packets, the switch driver should mark a packet as already
+forwarded by setting the skb->offload_fwd_mark bit. The bridge driver will mark
+the skb using the ingress bridge port's mark and prevent it from being forwarded
+through any bridge port with the same mark.
 
 It is possible for the switch device to not handle flooding and push the
 packets up to the bridge driver for flooding.  This is not ideal as the number
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index f0b09b0..1f0c086 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2412,7 +2412,7 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
 	skb->protocol = eth_type_trans(skb, rocker_port->dev);
 
 	if (rx_flags & ROCKER_RX_FLAGS_FWD_OFFLOAD)
-		skb->offload_fwd_mark = rocker_port->dev->offload_fwd_mark;
+		skb->offload_fwd_mark = 1;
 
 	rocker_port->dev->stats.rx_packets++;
 	rocker_port->dev->stats.rx_bytes += skb->len;
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 1ca7963..fcad907 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -2558,7 +2558,6 @@ static int ofdpa_port_init(struct rocker_port *rocker_port)
 	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
 	int err;
 
-	switchdev_port_fwd_mark_set(ofdpa_port->dev, NULL, false);
 	rocker_port_set_learning(rocker_port,
 				 !!(ofdpa_port->brport_flags & BR_LEARNING));
 
@@ -2817,7 +2816,6 @@ static int ofdpa_port_bridge_join(struct ofdpa_port *ofdpa_port,
 		ofdpa_port_internal_vlan_id_get(ofdpa_port, bridge->ifindex);
 
 	ofdpa_port->bridge_dev = bridge;
-	switchdev_port_fwd_mark_set(ofdpa_port->dev, bridge, true);
 
 	return ofdpa_port_vlan_add(ofdpa_port, NULL, OFDPA_UNTAGGED_VID, 0);
 }
@@ -2836,8 +2834,6 @@ static int ofdpa_port_bridge_leave(struct ofdpa_port *ofdpa_port)
 		ofdpa_port_internal_vlan_id_get(ofdpa_port,
 						ofdpa_port->dev->ifindex);
 
-	switchdev_port_fwd_mark_set(ofdpa_port->dev, ofdpa_port->bridge_dev,
-				    false);
 	ofdpa_port->bridge_dev = NULL;
 
 	err = ofdpa_port_vlan_add(ofdpa_port, NULL, OFDPA_UNTAGGED_VID, 0);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 794bb07..d122be9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1562,8 +1562,6 @@ enum netdev_priv_flags {
  *
  *	@xps_maps:	XXX: need comments on this one
  *
- *	@offload_fwd_mark:	Offload device fwding mark
- *
  *	@watchdog_timeo:	Represents the timeout that is used by
  *				the watchdog (see dev_watchdog())
  *	@watchdog_timer:	List of timers
@@ -1814,9 +1812,6 @@ struct net_device {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto __rcu  *egress_cl_list;
 #endif
-#ifdef CONFIG_NET_SWITCHDEV
-	u32			offload_fwd_mark;
-#endif
 
 	/* These may be needed for future network-power-down code. */
 	struct timer_list	watchdog_timer;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7047448..cfb7219 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -612,7 +612,6 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
   *	@napi_id: id of the NAPI struct this skb came from
  *	@secmark: security marking
- *	@offload_fwd_mark: fwding offload mark
  *	@mark: Generic packet mark
  *	@vlan_proto: vlan encapsulation protocol
  *	@vlan_tci: vlan tag control information
@@ -730,7 +729,10 @@ struct sk_buff {
 	__u8			ipvs_property:1;
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
-	/* 3 or 5 bit hole */
+#ifdef CONFIG_NET_SWITCHDEV
+	__u8			offload_fwd_mark:1;
+#endif
+	/* 2, 4 or 5 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
@@ -757,14 +759,9 @@ struct sk_buff {
 		unsigned int	sender_cpu;
 	};
 #endif
-	union {
 #ifdef CONFIG_NETWORK_SECMARK
-		__u32		secmark;
+	__u32		secmark;
 #endif
-#ifdef CONFIG_NET_SWITCHDEV
-		__u32		offload_fwd_mark;
-#endif
-	};
 
 	union {
 		__u32		mark;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 62f6a96..82f5e04 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -347,12 +347,6 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
        return idx;
 }
 
-static inline void switchdev_port_fwd_mark_set(struct net_device *dev,
-					       struct net_device *group_dev,
-					       bool joining)
-{
-}
-
 static inline bool switchdev_port_same_parent_id(struct net_device *a,
 						 struct net_device *b)
 {
diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index a1cda5d..0aefc01 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -20,4 +20,6 @@ bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
 
 bridge-$(CONFIG_BRIDGE_VLAN_FILTERING) += br_vlan.o
 
+bridge-$(CONFIG_NET_SWITCHDEV) += br_switchdev.o
+
 obj-$(CONFIG_NETFILTER) += netfilter/
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 63a83d8..32a02de 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -29,7 +29,8 @@ static inline int should_deliver(const struct net_bridge_port *p,
 
 	vg = nbp_vlan_group_rcu(p);
 	return ((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
-		br_allowed_egress(vg, skb) && p->state == BR_STATE_FORWARDING;
+		br_allowed_egress(vg, skb) && p->state == BR_STATE_FORWARDING &&
+		nbp_switchdev_allowed_egress(p, skb);
 }
 
 int br_dev_queue_push_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f2fede0..1da3221 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -545,6 +545,10 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err5;
 
+	err = nbp_switchdev_mark_set(p);
+	if (err)
+		goto err6;
+
 	dev_disable_lro(dev);
 
 	list_add_rcu(&p->list, &br->port_list);
@@ -566,7 +570,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	err = nbp_vlan_init(p);
 	if (err) {
 		netdev_err(dev, "failed to initialize vlan filtering on this port\n");
-		goto err6;
+		goto err7;
 	}
 
 	spin_lock_bh(&br->lock);
@@ -589,12 +593,12 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	return 0;
 
-err6:
+err7:
 	list_del_rcu(&p->list);
 	br_fdb_delete_by_port(br, p, 0, 1);
 	nbp_update_port_count(br);
+err6:
 	netdev_upper_dev_unlink(dev, br->dev);
-
 err5:
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 	netdev_rx_handler_unregister(dev);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 8e48620..3132cfc 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -145,6 +145,8 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	if (!br_allowed_ingress(p->br, nbp_vlan_group_rcu(p), skb, &vid))
 		goto out;
 
+	nbp_switchdev_frame_mark(p, skb);
+
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
 	if (p->flags & BR_LEARNING)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index aac2a6e..2379b2b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -251,6 +251,9 @@ struct net_bridge_port
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	struct net_bridge_vlan_group	__rcu *vlgrp;
 #endif
+#ifdef CONFIG_NET_SWITCHDEV
+	int				offload_fwd_mark;
+#endif
 };
 
 #define br_auto_port(p) ((p)->flags & BR_AUTO_MASK)
@@ -359,6 +362,11 @@ struct net_bridge
 	struct timer_list		gc_timer;
 	struct kobject			*ifobj;
 	u32				auto_cnt;
+
+#ifdef CONFIG_NET_SWITCHDEV
+	int offload_fwd_mark;
+#endif
+
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	struct net_bridge_vlan_group	__rcu *vlgrp;
 	u8				vlan_enabled;
@@ -381,6 +389,10 @@ struct br_input_skb_cb {
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	bool vlan_filtered;
 #endif
+
+#ifdef CONFIG_NET_SWITCHDEV
+	int offload_fwd_mark;
+#endif
 };
 
 #define BR_INPUT_SKB_CB(__skb)	((struct br_input_skb_cb *)(__skb)->cb)
@@ -1034,4 +1046,29 @@ static inline int br_sysfs_addbr(struct net_device *dev) { return 0; }
 static inline void br_sysfs_delbr(struct net_device *dev) { return; }
 #endif /* CONFIG_SYSFS */
 
+/* br_switchdev.c */
+#ifdef CONFIG_NET_SWITCHDEV
+int nbp_switchdev_mark_set(struct net_bridge_port *p);
+void nbp_switchdev_frame_mark(const struct net_bridge_port *p,
+			      struct sk_buff *skb);
+bool nbp_switchdev_allowed_egress(const struct net_bridge_port *p,
+				  const struct sk_buff *skb);
+#else
+static inline int nbp_switchdev_mark_set(struct net_bridge_port *p)
+{
+	return 0;
+}
+
+static inline void nbp_switchdev_frame_mark(const struct net_bridge_port *p,
+					    struct sk_buff *skb)
+{
+}
+
+static inline bool nbp_switchdev_allowed_egress(const struct net_bridge_port *p,
+						const struct sk_buff *skb)
+{
+	return true;
+}
+#endif /* CONFIG_NET_SWITCHDEV */
+
 #endif
diff --git a/net/bridge/br_switchdev.c b/net/bridge/br_switchdev.c
new file mode 100644
index 0000000..f4097b9
--- /dev/null
+++ b/net/bridge/br_switchdev.c
@@ -0,0 +1,57 @@
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/skbuff.h>
+#include <net/switchdev.h>
+
+#include "br_private.h"
+
+static int br_switchdev_mark_get(struct net_bridge *br, struct net_device *dev)
+{
+	struct net_bridge_port *p;
+
+	/* dev is yet to be added to the port list. */
+	list_for_each_entry(p, &br->port_list, list) {
+		if (switchdev_port_same_parent_id(dev, p->dev))
+			return p->offload_fwd_mark;
+	}
+
+	return ++br->offload_fwd_mark;
+}
+
+int nbp_switchdev_mark_set(struct net_bridge_port *p)
+{
+	struct switchdev_attr attr = {
+		.orig_dev = p->dev,
+		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
+	};
+	int err;
+
+	ASSERT_RTNL();
+
+	err = switchdev_port_attr_get(p->dev, &attr);
+	if (err) {
+		if (err == -EOPNOTSUPP)
+			return 0;
+		return err;
+	}
+
+	p->offload_fwd_mark = br_switchdev_mark_get(p->br, p->dev);
+
+	return 0;
+}
+
+void nbp_switchdev_frame_mark(const struct net_bridge_port *p,
+			      struct sk_buff *skb)
+{
+	if (skb->offload_fwd_mark && !WARN_ON_ONCE(!p->offload_fwd_mark))
+		BR_INPUT_SKB_CB(skb)->offload_fwd_mark = p->offload_fwd_mark;
+}
+
+bool nbp_switchdev_allowed_egress(const struct net_bridge_port *p,
+				  const struct sk_buff *skb)
+{
+	return !skb->offload_fwd_mark ||
+	       BR_INPUT_SKB_CB(skb)->offload_fwd_mark != p->offload_fwd_mark;
+}
diff --git a/net/core/dev.c b/net/core/dev.c
index a75df86..6ff6316 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3355,16 +3355,6 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	else
 		skb_dst_force(skb);
 
-#ifdef CONFIG_NET_SWITCHDEV
-	/* Don't forward if offload device already forwarded */
-	if (skb->offload_fwd_mark &&
-	    skb->offload_fwd_mark == dev->offload_fwd_mark) {
-		consume_skb(skb);
-		rc = NET_XMIT_SUCCESS;
-		goto out;
-	}
-#endif
-
 	txq = netdev_pick_tx(dev, skb, accel_priv);
 	q = rcu_dereference_bh(txq->qdisc);
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 2c683f2..1031a03 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1305,88 +1305,3 @@ bool switchdev_port_same_parent_id(struct net_device *a,
 	return netdev_phys_item_id_same(&a_attr.u.ppid, &b_attr.u.ppid);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_same_parent_id);
-
-static u32 switchdev_port_fwd_mark_get(struct net_device *dev,
-				       struct net_device *group_dev)
-{
-	struct net_device *lower_dev;
-	struct list_head *iter;
-
-	netdev_for_each_lower_dev(group_dev, lower_dev, iter) {
-		if (lower_dev == dev)
-			continue;
-		if (switchdev_port_same_parent_id(dev, lower_dev))
-			return lower_dev->offload_fwd_mark;
-		return switchdev_port_fwd_mark_get(dev, lower_dev);
-	}
-
-	return dev->ifindex;
-}
-
-static void switchdev_port_fwd_mark_reset(struct net_device *group_dev,
-					  u32 old_mark, u32 *reset_mark)
-{
-	struct net_device *lower_dev;
-	struct list_head *iter;
-
-	netdev_for_each_lower_dev(group_dev, lower_dev, iter) {
-		if (lower_dev->offload_fwd_mark == old_mark) {
-			if (!*reset_mark)
-				*reset_mark = lower_dev->ifindex;
-			lower_dev->offload_fwd_mark = *reset_mark;
-		}
-		switchdev_port_fwd_mark_reset(lower_dev, old_mark, reset_mark);
-	}
-}
-
-/**
- *	switchdev_port_fwd_mark_set - Set port offload forwarding mark
- *
- *	@dev: port device
- *	@group_dev: containing device
- *	@joining: true if dev is joining group; false if leaving group
- *
- *	An ungrouped port's offload mark is just its ifindex.  A grouped
- *	port's (member of a bridge, for example) offload mark is the ifindex
- *	of one of the ports in the group with the same parent (switch) ID.
- *	Ports on the same device in the same group will have the same mark.
- *
- *	Example:
- *
- *		br0		ifindex=9
- *		  sw1p1		ifindex=2	mark=2
- *		  sw1p2		ifindex=3	mark=2
- *		  sw2p1		ifindex=4	mark=5
- *		  sw2p2		ifindex=5	mark=5
- *
- *	If sw2p2 leaves the bridge, we'll have:
- *
- *		br0		ifindex=9
- *		  sw1p1		ifindex=2	mark=2
- *		  sw1p2		ifindex=3	mark=2
- *		  sw2p1		ifindex=4	mark=4
- *		sw2p2		ifindex=5	mark=5
- */
-void switchdev_port_fwd_mark_set(struct net_device *dev,
-				 struct net_device *group_dev,
-				 bool joining)
-{
-	u32 mark = dev->ifindex;
-	u32 reset_mark = 0;
-
-	if (group_dev) {
-		ASSERT_RTNL();
-		if (joining)
-			mark = switchdev_port_fwd_mark_get(dev, group_dev);
-		else if (dev->offload_fwd_mark == mark)
-			/* Ohoh, this port was the mark reference port,
-			 * but it's leaving the group, so reset the
-			 * mark for the remaining ports in the group.
-			 */
-			switchdev_port_fwd_mark_reset(group_dev, mark,
-						      &reset_mark);
-	}
-
-	dev->offload_fwd_mark = mark;
-}
-EXPORT_SYMBOL_GPL(switchdev_port_fwd_mark_set);
-- 
2.5.5
