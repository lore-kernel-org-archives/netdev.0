From: Patrick McHardy <kaber@trash.net>
Subject: vlan 06/06: Add GVRP support
Date: Thu,  3 Jul 2008 19:04:50 +0200 (MEST)
Message-ID: <20080703170450.6650.67783.sendpatchset@localhost.localdomain>
References: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Cc: shemminger@vyatta.com, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42853 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbYGCREv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 13:04:51 -0400
In-Reply-To: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: Add GVRP support

Add GVRP support for dynamically registering VLANs with switches.

By default GVRP is disabled because we only support the applicant-only
participant model, which means it should not be enabled on vlans that
are members of a bridge. Since there is currently no way to cleanly
determine that, the user is responsible for enabling it.

The code is pretty small and low impact, its wrapped in a config
option though because it depends on the GARP implementation and
the STP core.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 48425f9bd27acfbc92688ac133dac7a536879082
tree f9794528a4352d8f48623495b0e53306f8cc33a7
parent 8f8f9dfb07f7c96492d58488d1aaf670329cc91a
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:11:19 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:11:19 +0200

 include/linux/if_vlan.h  |    1 +
 include/net/garp.h       |    1 +
 net/8021q/Kconfig        |   10 +++++++
 net/8021q/Makefile       |    9 ++----
 net/8021q/vlan.c         |   23 +++++++++++++---
 net/8021q/vlan.h         |   16 +++++++++++
 net/8021q/vlan_dev.c     |   18 +++++++++++--
 net/8021q/vlan_gvrp.c    |   66 ++++++++++++++++++++++++++++++++++++++++++++++
 net/8021q/vlan_netlink.c |    3 +-
 9 files changed, 134 insertions(+), 13 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 15ace02..5190452 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -402,6 +402,7 @@ enum vlan_ioctl_cmds {
 
 enum vlan_flags {
 	VLAN_FLAG_REORDER_HDR	= 0x1,
+	VLAN_FLAG_GVRP		= 0x2,
 };
 
 enum vlan_name_types {
diff --git a/include/net/garp.h b/include/net/garp.h
index 73c7723..825f172 100644
--- a/include/net/garp.h
+++ b/include/net/garp.h
@@ -84,6 +84,7 @@ struct garp_attr {
 };
 
 enum garp_applications {
+	GARP_APPLICATION_GVRP,
 	__GARP_APPLICATION_MAX
 };
 #define GARP_APPLICATION_MAX	(__GARP_APPLICATION_MAX - 1)
diff --git a/net/8021q/Kconfig b/net/8021q/Kconfig
index c4a382e..fa073a5 100644
--- a/net/8021q/Kconfig
+++ b/net/8021q/Kconfig
@@ -17,3 +17,13 @@ config VLAN_8021Q
 	  will be called 8021q.
 
 	  If unsure, say N.
+
+config VLAN_8021Q_GVRP
+	bool "GVRP (GARP VLAN Registration Protocol) support"
+	depends on VLAN_8021Q
+	select GARP
+	help
+	  Select this to enable GVRP end-system support. GVRP is used for
+	  automatic propagation of registered VLANs to switches.
+
+	  If unsure, say N.
diff --git a/net/8021q/Makefile b/net/8021q/Makefile
index 10ca7f4..3006e9e 100644
--- a/net/8021q/Makefile
+++ b/net/8021q/Makefile
@@ -4,9 +4,6 @@
 
 obj-$(CONFIG_VLAN_8021Q) += 8021q.o
 
-8021q-objs := vlan.o vlan_dev.o vlan_netlink.o
-
-ifeq ($(CONFIG_PROC_FS),y)
-8021q-objs += vlanproc.o
-endif
-
+8021q-y				:= vlan.o vlan_dev.o vlan_netlink.o
+8021q-$(CONFIG_VLAN_8021Q_GVRP)	+= vlan_gvrp.o
+8021q-$(CONFIG_PROC_FS)		+= vlanproc.o
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8cae2da..b529110 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -169,6 +169,8 @@ void unregister_vlan_dev(struct net_device *dev)
 
 	/* If the group is now empty, kill off the group. */
 	if (grp->nr_vlans == 0) {
+		vlan_gvrp_uninit_applicant(real_dev);
+
 		if (real_dev->features & NETIF_F_HW_VLAN_RX)
 			real_dev->vlan_rx_register(real_dev, NULL);
 
@@ -249,15 +251,18 @@ int register_vlan_dev(struct net_device *dev)
 		ngrp = grp = vlan_group_alloc(real_dev);
 		if (!grp)
 			return -ENOBUFS;
+		err = vlan_gvrp_init_applicant(real_dev);
+		if (err < 0)
+			goto out_free_group;
 	}
 
 	err = vlan_group_prealloc_vid(grp, vlan_id);
 	if (err < 0)
-		goto out_free_group;
+		goto out_uninit_applicant;
 
 	err = register_netdevice(dev);
 	if (err < 0)
-		goto out_free_group;
+		goto out_uninit_applicant;
 
 	/* Account for reference in struct vlan_dev_info */
 	dev_hold(real_dev);
@@ -278,6 +283,9 @@ int register_vlan_dev(struct net_device *dev)
 
 	return 0;
 
+out_uninit_applicant:
+	if (ngrp)
+		vlan_gvrp_uninit_applicant(real_dev);
 out_free_group:
 	if (ngrp)
 		vlan_group_free(ngrp);
@@ -713,14 +721,20 @@ static int __init vlan_proto_init(void)
 	if (err < 0)
 		goto err2;
 
-	err = vlan_netlink_init();
+	err = vlan_gvrp_init();
 	if (err < 0)
 		goto err3;
 
+	err = vlan_netlink_init();
+	if (err < 0)
+		goto err4;
+
 	dev_add_pack(&vlan_packet_type);
 	vlan_ioctl_set(vlan_ioctl_handler);
 	return 0;
 
+err4:
+	vlan_gvrp_uninit();
 err3:
 	unregister_netdevice_notifier(&vlan_notifier_block);
 err2:
@@ -745,8 +759,9 @@ static void __exit vlan_cleanup_module(void)
 		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
 
 	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
-
 	synchronize_net();
+
+	vlan_gvrp_uninit();
 }
 
 module_init(vlan_proto_init);
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 639e254..097b2e0 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -37,6 +37,22 @@ void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
 void unregister_vlan_dev(struct net_device *dev);
 
+#ifdef CONFIG_VLAN_8021Q_GVRP
+extern int vlan_gvrp_request_join(const struct net_device *dev);
+extern void vlan_gvrp_request_leave(const struct net_device *dev);
+extern int vlan_gvrp_init_applicant(struct net_device *dev);
+extern void vlan_gvrp_uninit_applicant(struct net_device *dev);
+extern int vlan_gvrp_init(void);
+extern void vlan_gvrp_uninit(void);
+#else
+static inline int vlan_gvrp_request_join(const struct net_device *dev) { return 0; }
+static inline void vlan_gvrp_request_leave(const struct net_device *dev) {}
+static inline int vlan_gvrp_init_applicant(struct net_device *dev) { return 0; }
+static inline void vlan_gvrp_uninit_applicant(struct net_device *dev) {}
+static inline int vlan_gvrp_init(void) { return 0; }
+static inline void vlan_gvrp_uninit(void) {}
+#endif
+
 int vlan_netlink_init(void);
 void vlan_netlink_fini(void);
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 76c665c..a0617bf 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -512,10 +512,17 @@ int vlan_dev_change_flags(const struct net_device *dev, u32 flags, u32 mask)
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	u32 old_flags = vlan->flags;
 
-	if (mask & ~VLAN_FLAG_REORDER_HDR)
+	if (mask & ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP))
 		return -EINVAL;
 
 	vlan->flags = (old_flags & ~mask) | (flags & mask);
+
+	if (netif_running(dev) && (vlan->flags ^ old_flags) & VLAN_FLAG_GVRP) {
+		if (vlan->flags & VLAN_FLAG_GVRP)
+			vlan_gvrp_request_join(dev);
+		else
+			vlan_gvrp_request_leave(dev);
+	}
 	return 0;
 }
 
@@ -550,12 +557,19 @@ static int vlan_dev_open(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC)
 		dev_set_promiscuity(real_dev, 1);
 
+	if (vlan->flags & VLAN_FLAG_GVRP)
+		vlan_gvrp_request_join(dev);
+
 	return 0;
 }
 
 static int vlan_dev_stop(struct net_device *dev)
 {
-	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct net_device *real_dev = vlan->real_dev;
+
+	if (vlan->flags & VLAN_FLAG_GVRP)
+		vlan_gvrp_request_leave(dev);
 
 	dev_mc_unsync(real_dev, dev);
 	dev_unicast_unsync(real_dev, dev);
diff --git a/net/8021q/vlan_gvrp.c b/net/8021q/vlan_gvrp.c
new file mode 100644
index 0000000..db97816
--- /dev/null
+++ b/net/8021q/vlan_gvrp.c
@@ -0,0 +1,66 @@
+/*
+ * 	IEEE 802.1Q GARP VLAN Registration Protocol (GVRP)
+ *
+ * 	Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	version 2 as published by the Free Software Foundation.
+ */
+#include <linux/types.h>
+#include <linux/if_vlan.h>
+#include <net/garp.h>
+#include "vlan.h"
+
+#define GARP_GVRP_ADDRESS	{ 0x01, 0x80, 0xc2, 0x00, 0x00, 0x21 }
+
+enum gvrp_attributes {
+	GVRP_ATTR_INVALID,
+	GVRP_ATTR_VID,
+	__GVRP_ATTR_MAX
+};
+#define GVRP_ATTR_MAX	(__GVRP_ATTR_MAX - 1)
+
+static struct garp_application vlan_gvrp_app __read_mostly = {
+	.proto.group_address	= GARP_GVRP_ADDRESS,
+	.maxattr		= GVRP_ATTR_MAX,
+	.type			= GARP_APPLICATION_GVRP,
+};
+
+int vlan_gvrp_request_join(const struct net_device *dev)
+{
+	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	__be16 vid = htons(vlan->vlan_id);
+
+	return garp_request_join(vlan->real_dev, &vlan_gvrp_app,
+				 &vid, sizeof(vid), GVRP_ATTR_VID);
+}
+
+void vlan_gvrp_request_leave(const struct net_device *dev)
+{
+	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	__be16 vid = htons(vlan->vlan_id);
+
+	garp_request_leave(vlan->real_dev, &vlan_gvrp_app,
+			   &vid, sizeof(vid), GVRP_ATTR_VID);
+}
+
+int vlan_gvrp_init_applicant(struct net_device *dev)
+{
+	return garp_init_applicant(dev, &vlan_gvrp_app);
+}
+
+void vlan_gvrp_uninit_applicant(struct net_device *dev)
+{
+	garp_uninit_applicant(dev, &vlan_gvrp_app);
+}
+
+int __init vlan_gvrp_init(void)
+{
+	return garp_register_application(&vlan_gvrp_app);
+}
+
+void vlan_gvrp_uninit(void)
+{
+	garp_unregister_application(&vlan_gvrp_app);
+}
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index fd7cb19..e9c91dc 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -59,7 +59,8 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 	if (data[IFLA_VLAN_FLAGS]) {
 		flags = nla_data(data[IFLA_VLAN_FLAGS]);
-		if ((flags->flags & flags->mask) & ~VLAN_FLAG_REORDER_HDR)
+		if ((flags->flags & flags->mask) &
+		    ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP))
 			return -EINVAL;
 	}
 
