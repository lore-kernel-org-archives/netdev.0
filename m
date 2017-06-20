From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 11/12] nfp: add flower app
Date: Tue, 20 Jun 2017 23:36:19 +0200
Message-ID: <1497994580-6271-12-git-send-email-simon.horman@netronome.com>
References: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:34581 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752758AbdFTVhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 17:37:05 -0400
Received: by mail-qt0-f170.google.com with SMTP id v20so27894384qtg.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 14:37:04 -0700 (PDT)
In-Reply-To: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add app for flower offload. At this point the PF netdev and phys port
representor netdevs are initialised. Follow-up work will add support for
VF and PF representors and beyond that offloading the flower classifier.

Based in part on work by Benjamin LaHaise and Bert van Leeuwen.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile      |   1 +
 drivers/net/ethernet/netronome/nfp/flower/main.c | 294 +++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_app.c     |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_app.h     |   4 +
 4 files changed, 300 insertions(+)
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/main.c

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index e14f62863add..10b556b2c59d 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -28,6 +28,7 @@ nfp-objs := \
 	    bpf/main.o \
 	    bpf/offload.o \
 	    flower/cmsg.o \
+	    flower/main.o \
 	    nic/main.o
 
 ifeq ($(CONFIG_BPF_SYSCALL),y)
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
new file mode 100644
index 000000000000..d1d905727c54
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -0,0 +1,294 @@
+/*
+ * Copyright (C) 2017 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/pci.h>
+#include <linux/skbuff.h>
+#include <net/devlink.h>
+#include <net/dst_metadata.h>
+
+#include "../nfpcore/nfp_cpp.h"
+#include "../nfpcore/nfp_nsp.h"
+#include "../nfp_app.h"
+#include "../nfp_main.h"
+#include "../nfp_net.h"
+#include "../nfp_net_repr.h"
+#include "../nfp_port.h"
+#include "./cmsg.h"
+
+/**
+ * struct nfp_flower_priv - Flower APP per-vNIC priv data
+ * @nn:		     Pointer to vNIC
+ */
+struct nfp_flower_priv {
+	struct nfp_net *nn;
+};
+
+static const char *nfp_flower_extra_cap(struct nfp_app *app, struct nfp_net *nn)
+{
+	return "FLOWER";
+}
+
+static enum devlink_eswitch_mode eswitch_mode_get(struct nfp_app *app)
+{
+	return DEVLINK_ESWITCH_MODE_SWITCHDEV;
+}
+
+static enum nfp_repr_type
+nfp_flower_repr_get_type_and_port(struct nfp_app *app, u32 port_id, u8 *port)
+{
+	switch (FIELD_GET(NFP_FLOWER_CMSG_PORT_TYPE, port_id)) {
+	case NFP_FLOWER_CMSG_PORT_TYPE_PHYS_PORT:
+		*port = FIELD_GET(NFP_FLOWER_CMSG_PORT_PHYS_PORT_NUM,
+				  port_id);
+		return NFP_REPR_TYPE_PHYS_PORT;
+
+	case NFP_FLOWER_CMSG_PORT_TYPE_PCIE_PORT:
+		*port = FIELD_GET(NFP_FLOWER_CMSG_PORT_VNIC, port_id);
+		if (FIELD_GET(NFP_FLOWER_CMSG_PORT_VNIC_TYPE, port_id) ==
+		    NFP_FLOWER_CMSG_PORT_VNIC_TYPE_PF)
+			return NFP_REPR_TYPE_PF;
+		else
+			return NFP_REPR_TYPE_VF;
+	}
+
+	return NFP_FLOWER_CMSG_PORT_TYPE_UNSPEC;
+}
+
+static struct net_device *
+nfp_flower_repr_get(struct nfp_app *app, u32 port_id)
+{
+	enum nfp_repr_type repr_type;
+	struct nfp_reprs *reprs;
+	u8 port = 0;
+
+	repr_type = nfp_flower_repr_get_type_and_port(app, port_id, &port);
+
+	reprs = rcu_dereference(app->reprs[repr_type]);
+	if (!reprs)
+		return NULL;
+
+	if (port >= reprs->num_reprs)
+		return NULL;
+
+	return reprs->reprs[port];
+}
+
+static void
+nfp_flower_repr_netdev_get_stats64(struct net_device *netdev,
+				   struct rtnl_link_stats64 *stats)
+{
+	struct nfp_repr *repr = netdev_priv(netdev);
+	enum nfp_repr_type type;
+	u32 port_id;
+	u8 port = 0;
+
+	port_id = repr->dst->u.port_info.port_id;
+	type = nfp_flower_repr_get_type_and_port(repr->app, port_id, &port);
+	nfp_repr_get_stats64(repr->app, type, port, stats);
+}
+
+static int nfp_flower_repr_netdev_open(struct net_device *netdev)
+{
+	int err;
+
+	err = nfp_flower_cmsg_portmod(netdev);
+	if (err)
+		return err;
+
+	netif_carrier_on(netdev);
+	netif_tx_wake_all_queues(netdev);
+
+	return 0;
+}
+
+static int nfp_flower_repr_netdev_stop(struct net_device *netdev)
+{
+	netif_carrier_off(netdev);
+	netif_tx_disable(netdev);
+
+	return nfp_flower_cmsg_portmod(netdev);
+}
+
+static const struct net_device_ops nfp_flower_repr_netdev_ops = {
+	.ndo_open		= nfp_flower_repr_netdev_open,
+	.ndo_stop		= nfp_flower_repr_netdev_stop,
+	.ndo_start_xmit		= nfp_repr_xmit,
+	.ndo_get_stats64	= nfp_flower_repr_netdev_get_stats64,
+	.ndo_has_offload_stats	= nfp_repr_has_offload_stats,
+	.ndo_get_offload_stats	= nfp_repr_get_offload_stats,
+};
+
+static void nfp_flower_stop(struct nfp_app *app)
+{
+	nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_PHYS_PORT);
+}
+
+static int nfp_flower_start(struct nfp_app *app)
+{
+	struct nfp_eth_table *eth_tbl = app->pf->eth_tbl;
+	struct nfp_flower_priv *priv = app->priv;
+	struct nfp_reprs *reprs, *old_reprs;
+	unsigned int i;
+	int err;
+
+	reprs = nfp_reprs_alloc(eth_tbl->max_index + 1);
+	if (!reprs)
+		return -ENOMEM;
+
+	for (i = 0; i < eth_tbl->count; i++) {
+		int phys_port = eth_tbl->ports[i].index;
+		struct nfp_port *port;
+		u32 cmsg_port_id;
+
+		reprs->reprs[phys_port] = nfp_repr_alloc(app);
+		if (!reprs->reprs[phys_port]) {
+			err = -ENOMEM;
+			goto err_reprs_clean;
+		}
+
+		port = nfp_port_alloc(app, NFP_PORT_PHYS_PORT,
+				      reprs->reprs[phys_port]);
+		if (IS_ERR(port)) {
+			err = PTR_ERR(port);
+			goto err_reprs_clean;
+		}
+		err = nfp_port_init_phy_port(app->pf, app, port, i);
+		if (err) {
+			nfp_port_free(port);
+			goto err_reprs_clean;
+		}
+
+		SET_NETDEV_DEV(reprs->reprs[phys_port], &priv->nn->pdev->dev);
+		nfp_net_get_mac_addr(app->pf, port,
+				     eth_tbl->ports[i].eth_index);
+
+		cmsg_port_id = nfp_flower_cmsg_phys_port(phys_port);
+		err = nfp_repr_init(app, reprs->reprs[phys_port],
+				    &nfp_flower_repr_netdev_ops,
+				    cmsg_port_id, port, priv->nn->dp.netdev);
+		if (err) {
+			nfp_port_free(port);
+			goto err_reprs_clean;
+		}
+
+		nfp_info(app->cpp, "Phys Port %d Representor(%s) created\n",
+			 phys_port, reprs->reprs[phys_port]->name);
+	}
+
+	old_reprs = nfp_app_reprs_set(app, NFP_REPR_TYPE_PHYS_PORT, reprs);
+	if (IS_ERR(old_reprs)) {
+		err = PTR_ERR(old_reprs);
+		goto err_reprs_clean;
+	}
+
+	return 0;
+err_reprs_clean:
+	nfp_reprs_clean_and_free(reprs);
+	return err;
+}
+
+static void nfp_flower_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
+{
+	kfree(app->priv);
+	app->priv = NULL;
+}
+
+static int nfp_flower_vnic_init(struct nfp_app *app, struct nfp_net *nn,
+				unsigned int id)
+{
+	struct nfp_flower_priv *priv;
+
+	if (id > 0) {
+		nfp_warn(app->cpp, "FlowerNIC doesn't support more than one data vNIC\n");
+		goto err_invalid_port;
+	}
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+	app->priv = priv;
+	priv->nn = nn;
+
+	eth_hw_addr_random(nn->dp.netdev);
+	netif_keep_dst(nn->dp.netdev);
+
+	return 0;
+
+err_invalid_port:
+	nn->port = nfp_port_alloc(app, NFP_PORT_INVALID, nn->dp.netdev);
+	return PTR_ERR_OR_ZERO(nn->port);
+}
+
+static int nfp_flower_init(struct nfp_app *app)
+{
+	const struct nfp_pf *pf = app->pf;
+
+	if (!pf->eth_tbl) {
+		nfp_warn(app->cpp, "FlowerNIC requires eth table\n");
+		return -EINVAL;
+	}
+
+	if (!pf->mac_stats_bar) {
+		nfp_warn(app->cpp, "FlowerNIC requires mac_stats BAR\n");
+		return -EINVAL;
+	}
+
+	if (!pf->vf_cfg_bar) {
+		nfp_warn(app->cpp, "FlowerNIC requires vf_cfg BAR\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+const struct nfp_app_type app_flower = {
+	.id		= NFP_APP_FLOWER_NIC,
+	.name		= "flower",
+	.ctrl_has_meta	= true,
+
+	.extra_cap	= nfp_flower_extra_cap,
+
+	.init		= nfp_flower_init,
+
+	.vnic_init	= nfp_flower_vnic_init,
+	.vnic_clean	= nfp_flower_vnic_clean,
+
+	.start		= nfp_flower_start,
+	.stop		= nfp_flower_stop,
+
+	.ctrl_msg_rx	= nfp_flower_cmsg_rx,
+
+	.eswitch_mode_get  = eswitch_mode_get,
+	.repr_get	= nfp_flower_repr_get,
+};
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.c b/drivers/net/ethernet/netronome/nfp/nfp_app.c
index 2b71050dc5e4..5620de05c996 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.c
@@ -43,6 +43,7 @@
 static const struct nfp_app_type *apps[] = {
 	&app_nic,
 	&app_bpf,
+	&app_flower,
 };
 
 const char *nfp_app_mip_name(struct nfp_app *app)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index 36949b3e91c1..ae2d02753d1a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -52,10 +52,12 @@ struct nfp_net;
 enum nfp_app_id {
 	NFP_APP_CORE_NIC	= 0x1,
 	NFP_APP_BPF_NIC		= 0x2,
+	NFP_APP_FLOWER_NIC	= 0x3,
 };
 
 extern const struct nfp_app_type app_nic;
 extern const struct nfp_app_type app_bpf;
+extern const struct nfp_app_type app_flower;
 
 /**
  * struct nfp_app_type - application definition
@@ -119,6 +121,7 @@ struct nfp_app_type {
  * @ctrl:	pointer to ctrl vNIC struct
  * @reprs:	array of pointers to representors
  * @type:	pointer to const application ops and info
+ * @priv:	app-specific priv data
  */
 struct nfp_app {
 	struct pci_dev *pdev;
@@ -129,6 +132,7 @@ struct nfp_app {
 	struct nfp_reprs __rcu *reprs[NFP_REPR_TYPE_MAX + 1];
 
 	const struct nfp_app_type *type;
+	void *priv;
 };
 
 bool nfp_ctrl_tx(struct nfp_net *nn, struct sk_buff *skb);
-- 
2.1.4
