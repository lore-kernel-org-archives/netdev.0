From: Jiannan Ouyang <ouyangj@fb.com>
Subject: [PATCH net-next v1 3/3] openvswitch: Add GPRS Tunnel Protocol (GTP) vport support
Date: Wed, 12 Jul 2017 17:44:55 -0700
Message-ID: <20170713004455.3946570-4-ouyangj@fb.com>
References: <20170713004455.3946570-1-ouyangj@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <pablo@netfilter.org>, <laforge@gnumonks.org>,
        <pshelar@nicira.com>, <wieger.ijntema.tno@gmail.com>,
        <yi.y.yang@intel.com>, <joe@ovn.org>, <amarpadmanabhan@fb.com>,
        Jiannan Ouyang <ouyangj@fb.com>
To: <osmocom-net-gprs@lists.osmocom.org>, <netdev@vger.kernel.org>,
        <dev@openvswitch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47004 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751192AbdGMApl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 20:45:41 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6D0hiMT005744
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 17:45:40 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bntfdgrve-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 17:45:40 -0700
Received: from facebook.com (2401:db00:21:601e:face:0:45:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 9626f8c2676411e7b8d76f8865c8440f-71edb150 for <netdev@vger.kernel.org>;        Wed,
 12 Jul 2017 17:45:37 -0700
In-Reply-To: <20170713004455.3946570-1-ouyangj@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add OVS_VPORT_TYPE_GTP type and vport-gtp support.

Signed-off-by: Jiannan Ouyang <ouyangj@fb.com>
---
 include/uapi/linux/openvswitch.h |   1 +
 net/openvswitch/Kconfig          |  10 +++
 net/openvswitch/Makefile         |   1 +
 net/openvswitch/vport-gtp.c      | 144 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 156 insertions(+)
 create mode 100644 net/openvswitch/vport-gtp.c

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 156ee4c..82b87b2 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -213,6 +213,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_GRE,      /* GRE tunnel. */
 	OVS_VPORT_TYPE_VXLAN,	 /* VXLAN tunnel. */
 	OVS_VPORT_TYPE_GENEVE,	 /* Geneve tunnel. */
+	OVS_VPORT_TYPE_GTP,	 /* GTP tunnel. */
 	__OVS_VPORT_TYPE_MAX
 };
 
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index ce94729..d30d0ff 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -71,3 +71,13 @@ config OPENVSWITCH_GENEVE
 	  If you say Y here, then the Open vSwitch will be able create geneve vport.
 
 	  Say N to exclude this support and reduce the binary size.
+
+config OPENVSWITCH_GTP
+	tristate "Open vSwitch GTP tunneling support"
+	depends on OPENVSWITCH
+	depends on GTP
+	default OPENVSWITCH
+	---help---
+	  If you say Y here, then the Open vSwitch will be able create gtp vport.
+
+	  Say N to exclude this support and reduce the binary size.
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 60f8090..d77fcc0 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -22,3 +22,4 @@ endif
 obj-$(CONFIG_OPENVSWITCH_VXLAN)+= vport-vxlan.o
 obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
 obj-$(CONFIG_OPENVSWITCH_GRE)	+= vport-gre.o
+obj-$(CONFIG_OPENVSWITCH_GTP)	+= vport-gtp.o
diff --git a/net/openvswitch/vport-gtp.c b/net/openvswitch/vport-gtp.c
new file mode 100644
index 0000000..ed736ef
--- /dev/null
+++ b/net/openvswitch/vport-gtp.c
@@ -0,0 +1,144 @@
+/*
+ * Copyright (c) 2017 Facebook, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/net.h>
+#include <linux/rculist.h>
+#include <linux/udp.h>
+#include <linux/if_vlan.h>
+#include <linux/module.h>
+
+#include <net/gtp.h>
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/route.h>
+#include <net/udp.h>
+#include <net/xfrm.h>
+
+#include "datapath.h"
+#include "vport.h"
+#include "vport-netdev.h"
+
+static struct vport_ops ovs_gtp_vport_ops;
+/**
+ * struct gtp_port - Keeps track of open UDP ports
+ * @dst_port: destination port.
+ */
+struct gtp_port {
+	u16 port_no;
+};
+
+static inline struct gtp_port *gtp_vport(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
+static int gtp_get_options(const struct vport *vport,
+			   struct sk_buff *skb)
+{
+	struct gtp_port *gtp_port = gtp_vport(vport);
+
+	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, gtp_port->port_no))
+		return -EMSGSIZE;
+	return 0;
+}
+
+static struct vport *gtp_tnl_create(const struct vport_parms *parms)
+{
+	struct net *net = ovs_dp_get_net(parms->dp);
+	struct nlattr *options = parms->options;
+	struct gtp_port *gtp_port;
+	struct net_device *dev;
+	struct vport *vport;
+	struct nlattr *a;
+	u16 dst_port;
+	int err;
+
+	if (!options) {
+		err = -EINVAL;
+		goto error;
+	}
+
+	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
+	if (a && nla_len(a) == sizeof(u16)) {
+		dst_port = nla_get_u16(a);
+	} else {
+		/* Require destination port from userspace. */
+		err = -EINVAL;
+		goto error;
+	}
+
+	vport = ovs_vport_alloc(sizeof(struct gtp_port),
+				&ovs_gtp_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	gtp_port = gtp_vport(vport);
+	gtp_port->port_no = dst_port;
+
+	rtnl_lock();
+	dev = gtp_create_flow_based_dev(net, parms->name,
+					NET_NAME_USER, dst_port);
+	if (IS_ERR(dev)) {
+		rtnl_unlock();
+		ovs_vport_free(vport);
+		return ERR_CAST(dev);
+	}
+
+	err = dev_change_flags(dev, dev->flags | IFF_UP);
+	if (err < 0) {
+		rtnl_delete_link(dev);
+		rtnl_unlock();
+		ovs_vport_free(vport);
+		goto error;
+	}
+
+	rtnl_unlock();
+	return vport;
+error:
+	return ERR_PTR(err);
+}
+
+static struct vport *gtp_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+
+	vport = gtp_tnl_create(parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	return ovs_netdev_link(vport, parms->name);
+}
+
+static struct vport_ops ovs_gtp_vport_ops = {
+	.type		     = OVS_VPORT_TYPE_GTP,
+	.create		     = gtp_create,
+	.destroy	     = ovs_netdev_tunnel_destroy,
+	.get_options	     = gtp_get_options,
+	.send		     = dev_queue_xmit,
+};
+
+static int __init ovs_gtp_tnl_init(void)
+{
+	return ovs_vport_ops_register(&ovs_gtp_vport_ops);
+}
+late_initcall(ovs_gtp_tnl_init);
+
+static void __exit ovs_gtp_tnl_exit(void)
+{
+	ovs_vport_ops_unregister(&ovs_gtp_vport_ops);
+}
+module_exit(ovs_gtp_tnl_exit);
+
+MODULE_DESCRIPTION("OVS: GTP switching port");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("vport-type-6");
-- 
2.9.3
