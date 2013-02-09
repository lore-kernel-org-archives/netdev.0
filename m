From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 2/2] net/8021q: Implement Multiple VLAN Registration Protocol (MVRP)
Date: Fri, 8 Feb 2013 22:17:07 -0500
Message-ID: <1360379828-16302-3-git-send-email-david.ward@ll.mit.edu>
References: <1360379828-16302-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:45781 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760584Ab3BIDo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 22:44:58 -0500
Received: from LLE2K7-HUB02.mitll.ad.local (LLE2K7-HUB02.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id r193HB4T006498 for <netdev@vger.kernel.org>; Fri, 8 Feb 2013 22:17:12 -0500
In-Reply-To: <1360379828-16302-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial implementation of the Multiple VLAN Registration Protocol
(MVRP) from IEEE 802.1Q-2011, based on the existing implementation
of the GARP VLAN Registration Protocol (GVRP).

Signed-off-by: David Ward <david.ward@ll.mit.edu>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 include/uapi/linux/if_ether.h |    1 +
 include/uapi/linux/if_vlan.h  |    1 +
 net/8021q/Kconfig             |   11 ++++++
 net/8021q/Makefile            |    1 +
 net/8021q/vlan.c              |   27 ++++++++++++---
 net/8021q/vlan.h              |   16 +++++++++
 net/8021q/vlan_dev.c          |   12 ++++++-
 net/8021q/vlan_mvrp.c         |   72 +++++++++++++++++++++++++++++++++++++++++
 net/8021q/vlan_netlink.c      |    2 +-
 9 files changed, 136 insertions(+), 7 deletions(-)
 create mode 100644 net/8021q/vlan_mvrp.c

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 67fb87c..798032d 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -83,6 +83,7 @@
 #define ETH_P_802_EX1	0x88B5		/* 802.1 Local Experimental 1.  */
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
 #define ETH_P_8021AH	0x88E7          /* 802.1ah Backbone Service Tag */
+#define ETH_P_MVRP	0x88F5          /* 802.1Q MVRP                  */
 #define ETH_P_1588	0x88F7		/* IEEE 1588 Timesync */
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_TDLS	0x890D          /* TDLS */
diff --git a/include/uapi/linux/if_vlan.h b/include/uapi/linux/if_vlan.h
index 0744f8e..7e5e6b3 100644
--- a/include/uapi/linux/if_vlan.h
+++ b/include/uapi/linux/if_vlan.h
@@ -34,6 +34,7 @@ enum vlan_flags {
 	VLAN_FLAG_REORDER_HDR	= 0x1,
 	VLAN_FLAG_GVRP		= 0x2,
 	VLAN_FLAG_LOOSE_BINDING	= 0x4,
+	VLAN_FLAG_MVRP		= 0x8,
 };
 
 enum vlan_name_types {
diff --git a/net/8021q/Kconfig b/net/8021q/Kconfig
index fa073a5..8f7517d 100644
--- a/net/8021q/Kconfig
+++ b/net/8021q/Kconfig
@@ -27,3 +27,14 @@ config VLAN_8021Q_GVRP
 	  automatic propagation of registered VLANs to switches.
 
 	  If unsure, say N.
+
+config VLAN_8021Q_MVRP
+	bool "MVRP (Multiple VLAN Registration Protocol) support"
+	depends on VLAN_8021Q
+	select MRP
+	help
+	  Select this to enable MVRP end-system support. MVRP is used for
+	  automatic propagation of registered VLANs to switches; it
+	  supersedes GVRP and is not backwards-compatible.
+
+	  If unsure, say N.
diff --git a/net/8021q/Makefile b/net/8021q/Makefile
index 9f4f174..7bc8db0 100644
--- a/net/8021q/Makefile
+++ b/net/8021q/Makefile
@@ -6,5 +6,6 @@ obj-$(CONFIG_VLAN_8021Q)		+= 8021q.o
 
 8021q-y					:= vlan.o vlan_dev.o vlan_netlink.o
 8021q-$(CONFIG_VLAN_8021Q_GVRP)		+= vlan_gvrp.o
+8021q-$(CONFIG_VLAN_8021Q_MVRP)		+= vlan_mvrp.o
 8021q-$(CONFIG_PROC_FS)			+= vlanproc.o
 
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index addc578..a187144 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -95,6 +95,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 
 	grp->nr_vlan_devs--;
 
+	if (vlan->flags & VLAN_FLAG_MVRP)
+		vlan_mvrp_request_leave(dev);
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_leave(dev);
 
@@ -107,8 +109,10 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 
 	netdev_upper_dev_unlink(real_dev, dev);
 
-	if (grp->nr_vlan_devs == 0)
+	if (grp->nr_vlan_devs == 0) {
+		vlan_mvrp_uninit_applicant(real_dev);
 		vlan_gvrp_uninit_applicant(real_dev);
+	}
 
 	/* Get rid of the vlan's reference to real_dev */
 	dev_put(real_dev);
@@ -151,15 +155,18 @@ int register_vlan_dev(struct net_device *dev)
 		err = vlan_gvrp_init_applicant(real_dev);
 		if (err < 0)
 			goto out_vid_del;
+		err = vlan_mvrp_init_applicant(real_dev);
+		if (err < 0)
+			goto out_uninit_gvrp;
 	}
 
 	err = vlan_group_prealloc_vid(grp, vlan_id);
 	if (err < 0)
-		goto out_uninit_applicant;
+		goto out_uninit_mvrp;
 
 	err = netdev_upper_dev_link(real_dev, dev);
 	if (err)
-		goto out_uninit_applicant;
+		goto out_uninit_mvrp;
 
 	err = register_netdevice(dev);
 	if (err < 0)
@@ -181,7 +188,10 @@ int register_vlan_dev(struct net_device *dev)
 
 out_upper_dev_unlink:
 	netdev_upper_dev_unlink(real_dev, dev);
-out_uninit_applicant:
+out_uninit_mvrp:
+	if (grp->nr_vlan_devs == 0)
+		vlan_mvrp_uninit_applicant(real_dev);
+out_uninit_gvrp:
 	if (grp->nr_vlan_devs == 0)
 		vlan_gvrp_uninit_applicant(real_dev);
 out_vid_del:
@@ -655,13 +665,19 @@ static int __init vlan_proto_init(void)
 	if (err < 0)
 		goto err3;
 
-	err = vlan_netlink_init();
+	err = vlan_mvrp_init();
 	if (err < 0)
 		goto err4;
 
+	err = vlan_netlink_init();
+	if (err < 0)
+		goto err5;
+
 	vlan_ioctl_set(vlan_ioctl_handler);
 	return 0;
 
+err5:
+	vlan_mvrp_uninit();
 err4:
 	vlan_gvrp_uninit();
 err3:
@@ -682,6 +698,7 @@ static void __exit vlan_cleanup_module(void)
 	unregister_pernet_subsys(&vlan_net_ops);
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
+	vlan_mvrp_uninit();
 	vlan_gvrp_uninit();
 }
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index a4886d9..670f1e8 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -171,6 +171,22 @@ static inline int vlan_gvrp_init(void) { return 0; }
 static inline void vlan_gvrp_uninit(void) {}
 #endif
 
+#ifdef CONFIG_VLAN_8021Q_MVRP
+extern int vlan_mvrp_request_join(const struct net_device *dev);
+extern void vlan_mvrp_request_leave(const struct net_device *dev);
+extern int vlan_mvrp_init_applicant(struct net_device *dev);
+extern void vlan_mvrp_uninit_applicant(struct net_device *dev);
+extern int vlan_mvrp_init(void);
+extern void vlan_mvrp_uninit(void);
+#else
+static inline int vlan_mvrp_request_join(const struct net_device *dev) { return 0; }
+static inline void vlan_mvrp_request_leave(const struct net_device *dev) {}
+static inline int vlan_mvrp_init_applicant(struct net_device *dev) { return 0; }
+static inline void vlan_mvrp_uninit_applicant(struct net_device *dev) {}
+static inline int vlan_mvrp_init(void) { return 0; }
+static inline void vlan_mvrp_uninit(void) {}
+#endif
+
 extern const char vlan_fullname[];
 extern const char vlan_version[];
 extern int vlan_netlink_init(void);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 09f9108..34df5b3 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -261,7 +261,7 @@ int vlan_dev_change_flags(const struct net_device *dev, u32 flags, u32 mask)
 	u32 old_flags = vlan->flags;
 
 	if (mask & ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP |
-		     VLAN_FLAG_LOOSE_BINDING))
+		     VLAN_FLAG_LOOSE_BINDING | VLAN_FLAG_MVRP))
 		return -EINVAL;
 
 	vlan->flags = (old_flags & ~mask) | (flags & mask);
@@ -272,6 +272,13 @@ int vlan_dev_change_flags(const struct net_device *dev, u32 flags, u32 mask)
 		else
 			vlan_gvrp_request_leave(dev);
 	}
+
+	if (netif_running(dev) && (vlan->flags ^ old_flags) & VLAN_FLAG_MVRP) {
+		if (vlan->flags & VLAN_FLAG_MVRP)
+			vlan_mvrp_request_join(dev);
+		else
+			vlan_mvrp_request_leave(dev);
+	}
 	return 0;
 }
 
@@ -312,6 +319,9 @@ static int vlan_dev_open(struct net_device *dev)
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_join(dev);
 
+	if (vlan->flags & VLAN_FLAG_MVRP)
+		vlan_mvrp_request_join(dev);
+
 	if (netif_carrier_ok(real_dev))
 		netif_carrier_on(dev);
 	return 0;
diff --git a/net/8021q/vlan_mvrp.c b/net/8021q/vlan_mvrp.c
new file mode 100644
index 0000000..d9ec1d5
--- /dev/null
+++ b/net/8021q/vlan_mvrp.c
@@ -0,0 +1,72 @@
+/*
+ *	IEEE 802.1Q Multiple VLAN Registration Protocol (MVRP)
+ *
+ *	Copyright (c) 2012 Massachusetts Institute of Technology
+ *
+ *	Adapted from code in net/8021q/vlan_gvrp.c
+ *	Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	version 2 as published by the Free Software Foundation.
+ */
+#include <linux/types.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <net/mrp.h>
+#include "vlan.h"
+
+#define MRP_MVRP_ADDRESS	{ 0x01, 0x80, 0xc2, 0x00, 0x00, 0x21 }
+
+enum mvrp_attributes {
+	MVRP_ATTR_INVALID,
+	MVRP_ATTR_VID,
+	__MVRP_ATTR_MAX
+};
+#define MVRP_ATTR_MAX	(__MVRP_ATTR_MAX - 1)
+
+static struct mrp_application vlan_mrp_app __read_mostly = {
+	.type		= MRP_APPLICATION_MVRP,
+	.maxattr	= MVRP_ATTR_MAX,
+	.pkttype.type	= htons(ETH_P_MVRP),
+	.group_address	= MRP_MVRP_ADDRESS,
+	.version	= 0,
+};
+
+int vlan_mvrp_request_join(const struct net_device *dev)
+{
+	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+	__be16 vlan_id = htons(vlan->vlan_id);
+
+	return mrp_request_join(vlan->real_dev, &vlan_mrp_app,
+				&vlan_id, sizeof(vlan_id), MVRP_ATTR_VID);
+}
+
+void vlan_mvrp_request_leave(const struct net_device *dev)
+{
+	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+	__be16 vlan_id = htons(vlan->vlan_id);
+
+	mrp_request_leave(vlan->real_dev, &vlan_mrp_app,
+			  &vlan_id, sizeof(vlan_id), MVRP_ATTR_VID);
+}
+
+int vlan_mvrp_init_applicant(struct net_device *dev)
+{
+	return mrp_init_applicant(dev, &vlan_mrp_app);
+}
+
+void vlan_mvrp_uninit_applicant(struct net_device *dev)
+{
+	mrp_uninit_applicant(dev, &vlan_mrp_app);
+}
+
+int __init vlan_mvrp_init(void)
+{
+	return mrp_register_application(&vlan_mrp_app);
+}
+
+void vlan_mvrp_uninit(void)
+{
+	mrp_unregister_application(&vlan_mrp_app);
+}
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 708c80e..1789658 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -62,7 +62,7 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		flags = nla_data(data[IFLA_VLAN_FLAGS]);
 		if ((flags->flags & flags->mask) &
 		    ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP |
-		      VLAN_FLAG_LOOSE_BINDING))
+		      VLAN_FLAG_LOOSE_BINDING | VLAN_FLAG_MVRP))
 			return -EINVAL;
 	}
 
-- 
1.7.1
