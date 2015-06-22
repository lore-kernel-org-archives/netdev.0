From: sfeldma@gmail.com
Subject: [PATCH net-next 2/2] switchdev; add VLAN support for port's bridge_getlink
Date: Mon, 22 Jun 2015 00:27:17 -0700
Message-ID: <1434958037-26057-3-git-send-email-sfeldma@gmail.com>
References: <1434958037-26057-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	vivien.didelot@savoirfairelinux.com, ronen.arad@intel.com,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33580 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755007AbbFVHZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 03:25:46 -0400
Received: by padev16 with SMTP id ev16so128473347pad.0
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2015 00:25:46 -0700 (PDT)
In-Reply-To: <1434958037-26057-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

One more missing piece of the puzzle.  Add vlan dump support to switchdev
port's bridge_getlink.  iproute2 "bridge vlan show" cmd already knows how
to show the vlans installed on the bridge and the device , but (until now)
no one implemented the port vlan part of the netlink PF_BRIDGE:RTM_GETLINK
msg.  Before this patch, "bridge vlan show":

	$ bridge -c vlan show
	port    vlan ids
	sw1p1    30-34			<< bridge side vlans
		 57

	sw1p1				<< device side vlans (missing)

	sw1p2    57

	sw1p2

	sw1p3

	sw1p4

	br0     None

(When the port is bridged, the output repeats the vlan list for the vlans
on the bridge side of the port and the vlans on the device side of the
port.  The listing above show no vlans for the device side even though they
are installed).

After this patch:

	$ bridge -c vlan show
	port    vlan ids
	sw1p1    30-34			<< bridge side vlan
		 57

	sw1p1    30-34			<< device side vlans
		 57
		 3840 PVID

	sw1p2    57

	sw1p2    57
		 3840 PVID

	sw1p3    3842 PVID

	sw1p4    3843 PVID

	br0     None

I re-used ndo_dflt_bridge_getlink to add vlan fill call-back func.
switchdev support adds an obj dump for VLAN objects, using the same
call-back scheme as FDB dump.  Support included for both compressed and
un-compressed vlan dumps.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c   |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c   |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +-
 drivers/net/ethernet/rocker/rocker.c          |   25 +++++
 include/linux/rtnetlink.h                     |    6 +-
 net/core/rtnetlink.c                          |   18 +++-
 net/switchdev/switchdev.c                     |  123 ++++++++++++++++++++++++-
 7 files changed, 172 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c0f3484..6f64242 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5096,7 +5096,7 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev,
 				       hsw_mode == PORT_FWD_TYPE_VEPA ?
 				       BRIDGE_MODE_VEPA : BRIDGE_MODE_VEB,
-				       0, 0, nlflags);
+				       0, 0, nlflags, filter_mask, NULL);
 }
 
 #ifdef CONFIG_BE2NET_VXLAN
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 52d7d8b..48a52b3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8069,7 +8069,7 @@ static int i40e_ndo_bridge_setlink(struct net_device *dev,
 #ifdef HAVE_BRIDGE_FILTER
 static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				   struct net_device *dev,
-				   u32 __always_unused filter_mask, int nlflags)
+				   u32 filter_mask, int nlflags)
 #else
 static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				   struct net_device *dev, int nlflags)
@@ -8095,7 +8095,7 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 		return 0;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, veb->bridge_mode,
-				       nlflags);
+				       nlflags, 0, 0, filter_mask, NULL);
 }
 #endif /* HAVE_BRIDGE_ATTRIBS */
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3bf2f3c..9aa6104 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8095,7 +8095,8 @@ static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 		return 0;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev,
-				       adapter->bridge_mode, 0, 0, nlflags);
+				       adapter->bridge_mode, 0, 0, nlflags,
+				       filter_mask, NULL);
 }
 
 static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 76c3086..e6ae0a1 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4456,6 +4456,28 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 	return err;
 }
 
+static int rocker_port_vlan_dump(const struct rocker_port *rocker_port,
+				 struct switchdev_obj *obj)
+{
+	struct switchdev_obj_vlan *vlan = &obj->u.vlan;
+	u16 vid;
+	int err = 0;
+
+	for (vid = 1; vid < VLAN_N_VID; vid++) {
+		if (!test_bit(vid, rocker_port->vlan_bitmap))
+			continue;
+		vlan->flags = 0;
+		if (rocker_vlan_id_is_internal(htons(vid)))
+			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
+		vlan->vid_begin = vlan->vid_end = vid;
+		err = obj->cb(rocker_port->dev, obj);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
 static int rocker_port_obj_dump(struct net_device *dev,
 				struct switchdev_obj *obj)
 {
@@ -4466,6 +4488,9 @@ static int rocker_port_obj_dump(struct net_device *dev,
 	case SWITCHDEV_OBJ_PORT_FDB:
 		err = rocker_port_fdb_dump(rocker_port, obj);
 		break;
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = rocker_port_vlan_dump(rocker_port, obj);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index a2324fb..39adaa9 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -114,5 +114,9 @@ extern int ndo_dflt_fdb_del(struct ndmsg *ndm,
 
 extern int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				   struct net_device *dev, u16 mode,
-				   u32 flags, u32 mask, int nlflags);
+				   u32 flags, u32 mask, int nlflags,
+				   u32 filter_mask,
+				   int (*vlan_fill)(struct sk_buff *skb,
+						    struct net_device *dev,
+						    u32 filter_mask));
 #endif	/* __LINUX_RTNETLINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2d102ce..01ced4a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2908,7 +2908,11 @@ static int brport_nla_put_flag(struct sk_buff *skb, u32 flags, u32 mask,
 
 int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 			    struct net_device *dev, u16 mode,
-			    u32 flags, u32 mask, int nlflags)
+			    u32 flags, u32 mask, int nlflags,
+			    u32 filter_mask,
+			    int (*vlan_fill)(struct sk_buff *skb,
+					     struct net_device *dev,
+					     u32 filter_mask))
 {
 	struct nlmsghdr *nlh;
 	struct ifinfomsg *ifm;
@@ -2916,6 +2920,7 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	struct nlattr *protinfo;
 	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
 	struct net_device *br_dev = netdev_master_upper_dev_get(dev);
+	int err = 0;
 
 	nlh = nlmsg_put(skb, pid, seq, RTM_NEWLINK, sizeof(*ifm), nlflags);
 	if (nlh == NULL)
@@ -2956,6 +2961,13 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 			goto nla_put_failure;
 		}
 	}
+	if (vlan_fill) {
+		err = vlan_fill(skb, dev, filter_mask);
+		if (err) {
+			nla_nest_cancel(skb, br_afspec);
+			goto nla_put_failure;
+		}
+	}
 	nla_nest_end(skb, br_afspec);
 
 	protinfo = nla_nest_start(skb, IFLA_PROTINFO | NLA_F_NESTED);
@@ -2989,9 +3001,9 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	return 0;
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
+	return err ? err : -EMSGSIZE;
 }
-EXPORT_SYMBOL(ndo_dflt_bridge_getlink);
+EXPORT_SYMBOL_GPL(ndo_dflt_bridge_getlink);
 
 static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 70764c5..eaf4713 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -392,6 +392,126 @@ int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
 
+struct switchdev_vlan_dump {
+	struct switchdev_obj obj;
+	struct sk_buff *skb;
+	u32 filter_mask;
+	u16 flags;
+	u16 begin;
+	u16 end;
+};
+
+static int switchdev_port_vlan_dump_put(struct net_device *dev,
+					struct switchdev_vlan_dump *dump)
+{
+	struct bridge_vlan_info vinfo;
+
+	vinfo.flags = dump->flags;
+
+	if (dump->begin == 0 && dump->end == 0) {
+		return 0;
+	} else if (dump->begin == dump->end) {
+		vinfo.vid = dump->begin;
+		if (nla_put(dump->skb, IFLA_BRIDGE_VLAN_INFO,
+			    sizeof(vinfo), &vinfo))
+			return -EMSGSIZE;
+	} else {
+		vinfo.vid = dump->begin;
+		vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_BEGIN;
+		if (nla_put(dump->skb, IFLA_BRIDGE_VLAN_INFO,
+			    sizeof(vinfo), &vinfo))
+			return -EMSGSIZE;
+		vinfo.vid = dump->end;
+		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
+		vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_END;
+		if (nla_put(dump->skb, IFLA_BRIDGE_VLAN_INFO,
+			    sizeof(vinfo), &vinfo))
+			return -EMSGSIZE;
+	}
+
+	return 0;
+}
+
+static int switchdev_port_vlan_dump_cb(struct net_device *dev,
+				       struct switchdev_obj *obj)
+{
+	struct switchdev_vlan_dump *dump =
+		container_of(obj, struct switchdev_vlan_dump, obj);
+	struct switchdev_obj_vlan *vlan = &dump->obj.u.vlan;
+	int err = 0;
+
+	if (vlan->vid_begin > vlan->vid_end)
+		return -EINVAL;
+
+	if (dump->filter_mask & RTEXT_FILTER_BRVLAN) {
+		dump->flags = vlan->flags;
+		for (dump->begin = dump->end = vlan->vid_begin;
+		     dump->begin <= vlan->vid_end;
+		     dump->begin++, dump->end++) {
+			err = switchdev_port_vlan_dump_put(dev, dump);
+			if (err)
+				return err;
+		}
+	} else if (dump->filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED) {
+		if (dump->begin > vlan->vid_begin &&
+		    dump->begin >= vlan->vid_end) {
+			if ((dump->begin - 1) == vlan->vid_end &&
+			    dump->flags == vlan->flags) {
+				/* prepend */
+				dump->begin = vlan->vid_begin;
+			} else {
+				err = switchdev_port_vlan_dump_put(dev, dump);
+				dump->flags = vlan->flags;
+				dump->begin = vlan->vid_begin;
+				dump->end = vlan->vid_end;
+			}
+		} else if (dump->end <= vlan->vid_begin &&
+		           dump->end < vlan->vid_end) {
+			if ((dump->end  + 1) == vlan->vid_begin &&
+			    dump->flags == vlan->flags) {
+				/* append */
+				dump->end = vlan->vid_end;
+			} else {
+				err = switchdev_port_vlan_dump_put(dev, dump);
+				dump->flags = vlan->flags;
+				dump->begin = vlan->vid_begin;
+				dump->end = vlan->vid_end;
+			}
+		} else {
+			err = -EINVAL;
+		}
+	}
+
+	return err;
+}
+
+static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
+				    u32 filter_mask)
+{
+	struct switchdev_vlan_dump dump = {
+		.obj = {
+			.id = SWITCHDEV_OBJ_PORT_VLAN,
+			.cb = switchdev_port_vlan_dump_cb,
+		},
+		.skb = skb,
+		.filter_mask = filter_mask,
+	};
+	int err = 0;
+
+	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
+	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
+		err = switchdev_port_obj_dump(dev, &dump.obj);
+		if (err)
+			goto err_out;
+		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
+			/* last one */
+			err = switchdev_port_vlan_dump_put(dev, &dump);
+	}
+
+err_out:
+	return err == -EOPNOTSUPP ? 0 : err;
+}
+
 /**
  *	switchdev_port_bridge_getlink - Get bridge port attributes
  *
@@ -416,7 +536,8 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 		return err;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
-				       attr.u.brport_flags, mask, nlflags);
+				       attr.u.brport_flags, mask, nlflags,
+				       filter_mask, switchdev_port_vlan_fill);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_getlink);
 
-- 
1.7.10.4
