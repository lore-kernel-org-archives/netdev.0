From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 3/9] nfp: provide infrastructure for offloading flower based TC filters
Date: Wed, 28 Jun 2017 01:21:43 +0200
Message-ID: <1498605709-22574-4-git-send-email-simon.horman@netronome.com>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36543 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754012AbdF0XWR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:22:17 -0400
Received: by mail-qk0-f177.google.com with SMTP id p21so38315881qke.3
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:22:16 -0700 (PDT)
In-Reply-To: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Adds a flower based TC offload handler for representor devices, this
is in addition to the bpf based offload handler. The changes in this
patch will be used in a follow-up patch to add tc flower offload to
the NFP.

The flower app enables tc offloads on representors by default.

Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile        |   3 +-
 drivers/net/ethernet/netronome/nfp/flower/main.c   |   9 ++
 drivers/net/ethernet/netronome/nfp/flower/main.h   |  48 +++++++
 .../net/ethernet/netronome/nfp/flower/offload.c    | 144 +++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  |  18 +++
 5 files changed, 221 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/main.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/offload.c

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 43bdbc228969..d7afd2b410fe 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -32,7 +32,8 @@ nfp-objs := \
 ifeq ($(CONFIG_NFP_APP_FLOWER),y)
 nfp-objs += \
 	    flower/cmsg.o \
-	    flower/main.o
+	    flower/main.o \
+	    flower/offload.o
 endif
 
 ifeq ($(CONFIG_BPF_SYSCALL),y)
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index ab68a8f58862..7b27871f489c 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -37,6 +37,7 @@
 #include <net/devlink.h>
 #include <net/dst_metadata.h>
 
+#include "main.h"
 #include "../nfpcore/nfp_cpp.h"
 #include "../nfpcore/nfp_nsp.h"
 #include "../nfp_app.h"
@@ -303,8 +304,14 @@ static int nfp_flower_vnic_init(struct nfp_app *app, struct nfp_net *nn,
 	eth_hw_addr_random(nn->dp.netdev);
 	netif_keep_dst(nn->dp.netdev);
 
+	if (nfp_flower_repr_init(app))
+		goto err_free_priv;
+
 	return 0;
 
+err_free_priv:
+	kfree(app->priv);
+	app->priv = NULL;
 err_invalid_port:
 	nn->port = nfp_port_alloc(app, NFP_PORT_INVALID, nn->dp.netdev);
 	return PTR_ERR_OR_ZERO(nn->port);
@@ -367,4 +374,6 @@ const struct nfp_app_type app_flower = {
 
 	.eswitch_mode_get  = eswitch_mode_get,
 	.repr_get	= nfp_flower_repr_get,
+
+	.setup_tc	= nfp_flower_setup_tc,
 };
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
new file mode 100644
index 000000000000..119f66068c2b
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
@@ -0,0 +1,48 @@
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
+#ifndef __NFP_FLOWER_H__
+#define __NFP_FLOWER_H__ 1
+
+#include <linux/types.h>
+
+#define NFP_FLOWER_ALLOWED_VER 0x0001000000010000UL
+
+struct tc_to_netdev;
+struct net_device;
+struct nfp_app;
+
+int nfp_flower_repr_init(struct nfp_app *app);
+int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
+			u32 handle, __be16 proto, struct tc_to_netdev *tc);
+#endif
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
new file mode 100644
index 000000000000..9127c28ea9c3
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -0,0 +1,144 @@
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
+#include <linux/skbuff.h>
+#include <net/devlink.h>
+#include <net/pkt_cls.h>
+
+#include "main.h"
+#include "cmsg.h"
+#include "../nfpcore/nfp_cpp.h"
+#include "../nfpcore/nfp_nffw.h"
+#include "../nfpcore/nfp_nsp.h"
+#include "../nfp_app.h"
+#include "../nfp_main.h"
+#include "../nfp_net.h"
+#include "../nfp_port.h"
+
+/**
+ * nfp_flower_add_offload() - Adds a new flow to hardware.
+ * @app:	Pointer to the APP handle
+ * @netdev:	netdev structure.
+ * @flow:	TC flower classifier offload structure.
+ *
+ * Adds a new flow to the repeated hash structure and action payload.
+ *
+ * Return: negative value on error, 0 if configured successfully.
+ */
+static int
+nfp_flower_add_offload(struct nfp_app *app, struct net_device *netdev,
+		       struct tc_cls_flower_offload *flow)
+{
+	return -EOPNOTSUPP;
+}
+
+/**
+ * nfp_flower_del_offload() - Removes a flow from hardware.
+ * @app:	Pointer to the APP handle
+ * @netdev:	netdev structure.
+ * @flow:       TC flower classifier offload structure
+ *
+ * Removes a flow from the repeated hash structure and clears the
+ * action payload.
+ *
+ * Return: negative value on error, 0 if removed successfully.
+ */
+static int
+nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
+		       struct tc_cls_flower_offload *flow)
+{
+	return -EOPNOTSUPP;
+}
+
+/**
+ * nfp_flower_get_stats() - Populates flow stats obatain from hardware.
+ * @app:	Pointer to the APP handle
+ * @flow:       TC flower classifier offload structure
+ *
+ * Populates a flow statistics structure which which corresponds to a
+ * specific flow.
+ *
+ * Return: negative value on error, 0 if stats populated successfully.
+ */
+static int
+nfp_flower_get_stats(struct nfp_app *app, struct tc_cls_flower_offload *flow)
+{
+	return -EOPNOTSUPP;
+}
+
+static int
+nfp_flower_repr_offload(struct nfp_app *app, struct net_device *netdev,
+			struct tc_cls_flower_offload *flower)
+{
+	switch (flower->command) {
+	case TC_CLSFLOWER_REPLACE:
+		return nfp_flower_add_offload(app, netdev, flower);
+	case TC_CLSFLOWER_DESTROY:
+		return nfp_flower_del_offload(app, netdev, flower);
+	case TC_CLSFLOWER_STATS:
+		return nfp_flower_get_stats(app, flower);
+	}
+
+	return -EOPNOTSUPP;
+}
+
+int nfp_flower_repr_init(struct nfp_app *app)
+{
+	u64 version;
+	int err;
+
+	version = nfp_rtsym_read_le(app->pf->rtbl, "hw_flower_version", &err);
+	if (err)
+		return -EINVAL;
+
+	/* We need to ensure hardware has enough flower capabilities. */
+	if (version != NFP_FLOWER_ALLOWED_VER)
+		return -EINVAL;
+
+	return 0;
+}
+
+int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
+			u32 handle, __be16 proto, struct tc_to_netdev *tc)
+{
+	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
+		return -EOPNOTSUPP;
+
+	if (!eth_proto_is_802_3(proto))
+		return -EOPNOTSUPP;
+
+	if (tc->type != TC_SETUP_CLSFLOWER)
+		return -EINVAL;
+
+	return nfp_flower_repr_offload(app, netdev, tc->cls_flower);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index bc9108071e5b..a73b311c1f75 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -250,6 +250,18 @@ static int nfp_repr_open(struct net_device *netdev)
 	return nfp_app_repr_open(repr->app, repr);
 }
 
+static int
+nfp_repr_setup_tc(struct net_device *netdev, u32 handle, u32 chain_index,
+		  __be16 proto, struct tc_to_netdev *tc)
+{
+	struct nfp_repr *repr = netdev_priv(netdev);
+
+	if (chain_index)
+		return -EOPNOTSUPP;
+
+	return nfp_app_setup_tc(repr->app, netdev, handle, proto, tc);
+}
+
 const struct net_device_ops nfp_repr_netdev_ops = {
 	.ndo_open		= nfp_repr_open,
 	.ndo_stop		= nfp_repr_stop,
@@ -258,6 +270,7 @@ const struct net_device_ops nfp_repr_netdev_ops = {
 	.ndo_has_offload_stats	= nfp_repr_has_offload_stats,
 	.ndo_get_offload_stats	= nfp_repr_get_offload_stats,
 	.ndo_get_phys_port_name	= nfp_port_get_phys_port_name,
+	.ndo_setup_tc		= nfp_repr_setup_tc,
 };
 
 static void nfp_repr_clean(struct nfp_repr *repr)
@@ -302,6 +315,11 @@ int nfp_repr_init(struct nfp_app *app, struct net_device *netdev,
 	netdev->netdev_ops = &nfp_repr_netdev_ops;
 	SWITCHDEV_SET_OPS(netdev, &nfp_port_switchdev_ops);
 
+	if (nfp_app_has_tc(app)) {
+		netdev->features |= NETIF_F_HW_TC;
+		netdev->hw_features |= NETIF_F_HW_TC;
+	}
+
 	err = register_netdev(netdev);
 	if (err)
 		goto err_clean;
-- 
2.1.4
