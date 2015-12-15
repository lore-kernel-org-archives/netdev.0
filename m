From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/14] switchdev: Pass original device to port netdev driver
Date: Tue, 15 Dec 2015 16:03:35 +0100
Message-ID: <1450191827-6679-3-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34219 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933457AbbLOPDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:03:54 -0500
Received: by mail-wm0-f49.google.com with SMTP id p66so114401862wmp.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:03:53 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

switchdev drivers need to know the netdev on which the switchdev op was
invoked. For example, the STP state of a VLAN interface configured on top
of a port can change while being member in a bridge. In this case, the
underlying driver should only change the STP state of that particular
VLAN and not of all the VLANs configured on the port.

However, current switchdev infrastructure only passes the port netdev down
to the driver. Solve that by passing the original device down to the
driver as part of the required switchdev object / attribute.

This doesn't entail any change in current switchdev drivers. It simply
enables those supporting stacked devices to know the originating device
and act accordingly.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |  2 ++
 net/bridge/br_fdb.c       |  1 +
 net/bridge/br_stp.c       |  2 ++
 net/bridge/br_stp_if.c    |  1 +
 net/bridge/br_vlan.c      |  2 ++
 net/core/net-sysfs.c      |  1 +
 net/core/rtnetlink.c      |  1 +
 net/switchdev/switchdev.c | 12 ++++++++++++
 8 files changed, 22 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 1d22ce9..6612946 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -50,6 +50,7 @@ enum switchdev_attr_id {
 };
 
 struct switchdev_attr {
+	struct net_device *orig_dev;
 	enum switchdev_attr_id id;
 	u32 flags;
 	union {
@@ -68,6 +69,7 @@ enum switchdev_obj_id {
 };
 
 struct switchdev_obj {
+	struct net_device *orig_dev;
 	enum switchdev_obj_id id;
 	u32 flags;
 };
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index a642bb8..82e3e97 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -135,6 +135,7 @@ static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 {
 	struct switchdev_obj_port_fdb fdb = {
 		.obj = {
+			.orig_dev = f->dst->dev,
 			.id = SWITCHDEV_OBJ_ID_PORT_FDB,
 			.flags = SWITCHDEV_F_DEFER,
 		},
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 5f3f645..b3cca12 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -40,6 +40,7 @@ void br_log_state(const struct net_bridge_port *p)
 void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
 	struct switchdev_attr attr = {
+		.orig_dev = p->dev,
 		.id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
 		.flags = SWITCHDEV_F_DEFER,
 		.u.stp_state = state,
@@ -570,6 +571,7 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)
 int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
 {
 	struct switchdev_attr attr = {
+		.orig_dev = br->dev,
 		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
 		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
 		.u.ageing_time = ageing_time,
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 5396ff08..775e00f 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -37,6 +37,7 @@ static inline port_id br_make_port_id(__u8 priority, __u16 port_no)
 void br_init_port(struct net_bridge_port *p)
 {
 	struct switchdev_attr attr = {
+		.orig_dev = p->dev,
 		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
 		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP | SWITCHDEV_F_DEFER,
 		.u.ageing_time = p->br->ageing_time,
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 1394da6..66c4549 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -73,6 +73,7 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 			  u16 vid, u16 flags)
 {
 	struct switchdev_obj_port_vlan v = {
+		.obj.orig_dev = dev,
 		.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
 		.flags = flags,
 		.vid_begin = vid,
@@ -120,6 +121,7 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 			  u16 vid)
 {
 	struct switchdev_obj_port_vlan v = {
+		.obj.orig_dev = dev,
 		.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
 		.vid_begin = vid,
 		.vid_end = vid,
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index f88a62a..bca8c35 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -471,6 +471,7 @@ static ssize_t phys_switch_id_show(struct device *dev,
 
 	if (dev_isalive(netdev)) {
 		struct switchdev_attr attr = {
+			.orig_dev = netdev,
 			.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 			.flags = SWITCHDEV_F_NO_RECURSE,
 		};
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 34ba7a0..d8b0113 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1027,6 +1027,7 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 {
 	int err;
 	struct switchdev_attr attr = {
+		.orig_dev = dev,
 		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 		.flags = SWITCHDEV_F_NO_RECURSE,
 	};
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index f34e535..df790d3 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -723,6 +723,7 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
 				    u32 filter_mask)
 {
 	struct switchdev_vlan_dump dump = {
+		.vlan.obj.orig_dev = dev,
 		.vlan.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
 		.skb = skb,
 		.filter_mask = filter_mask,
@@ -757,6 +758,7 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				  int nlflags)
 {
 	struct switchdev_attr attr = {
+		.orig_dev = dev,
 		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 	};
 	u16 mode = BRIDGE_MODE_UNDEF;
@@ -778,6 +780,7 @@ static int switchdev_port_br_setflag(struct net_device *dev,
 				     unsigned long brport_flag)
 {
 	struct switchdev_attr attr = {
+		.orig_dev = dev,
 		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 	};
 	u8 flag = nla_get_u8(nlattr);
@@ -853,6 +856,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 	struct nlattr *attr;
 	struct bridge_vlan_info *vinfo;
 	struct switchdev_obj_port_vlan vlan = {
+		.obj.orig_dev = dev,
 		.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
 	};
 	int rem;
@@ -975,6 +979,7 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			   u16 vid, u16 nlm_flags)
 {
 	struct switchdev_obj_port_fdb fdb = {
+		.obj.orig_dev = dev,
 		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
 		.vid = vid,
 	};
@@ -1000,6 +1005,7 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   u16 vid)
 {
 	struct switchdev_obj_port_fdb fdb = {
+		.obj.orig_dev = dev,
 		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
 		.vid = vid,
 	};
@@ -1077,6 +1083,7 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *filter_dev, int idx)
 {
 	struct switchdev_fdb_dump dump = {
+		.fdb.obj.orig_dev = dev,
 		.fdb.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
 		.dev = dev,
 		.skb = skb,
@@ -1135,6 +1142,7 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 		if (!dev)
 			return NULL;
 
+		attr.orig_dev = dev;
 		if (switchdev_port_attr_get(dev, &attr))
 			return NULL;
 
@@ -1194,6 +1202,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
+	ipv4_fib.obj.orig_dev = dev;
 	err = switchdev_port_obj_add(dev, &ipv4_fib.obj);
 	if (!err)
 		fi->fib_flags |= RTNH_F_OFFLOAD;
@@ -1238,6 +1247,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
+	ipv4_fib.obj.orig_dev = dev;
 	err = switchdev_port_obj_del(dev, &ipv4_fib.obj);
 	if (!err)
 		fi->fib_flags &= ~RTNH_F_OFFLOAD;
@@ -1270,10 +1280,12 @@ static bool switchdev_port_same_parent_id(struct net_device *a,
 					  struct net_device *b)
 {
 	struct switchdev_attr a_attr = {
+		.orig_dev = a,
 		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 		.flags = SWITCHDEV_F_NO_RECURSE,
 	};
 	struct switchdev_attr b_attr = {
+		.orig_dev = b,
 		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 		.flags = SWITCHDEV_F_NO_RECURSE,
 	};
-- 
1.9.3
