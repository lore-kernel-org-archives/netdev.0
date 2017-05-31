From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 7/9] nfp: move bpf offload code to the BPF app
Date: Wed, 31 May 2017 08:06:49 -0700
Message-ID: <20170531150651.16873-8-jakub.kicinski@netronome.com>
References: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34519 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdEaPLx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:11:53 -0400
Received: by mail-pf0-f177.google.com with SMTP id 9so11985535pfj.1
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 08:11:53 -0700 (PDT)
In-Reply-To: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move bulk of the eBPF offload code out of common vNIC code into
app-specific callbacks.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c      | 84 ++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/bpf/main.h      |  5 ++
 drivers/net/ethernet/netronome/nfp/nfp_app.h       | 61 ++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  1 -
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 66 +++--------------
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  1 +
 6 files changed, 159 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index d91d72e22dc8..a7478b5d1854 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -31,11 +31,57 @@
  * SOFTWARE.
  */
 
+#include <net/pkt_cls.h>
+
 #include "../nfpcore/nfp_cpp.h"
 #include "../nfp_app.h"
 #include "../nfp_main.h"
 #include "../nfp_net.h"
 #include "../nfp_port.h"
+#include "main.h"
+
+static bool nfp_net_ebpf_capable(struct nfp_net *nn)
+{
+	if (nn->cap & NFP_NET_CFG_CTRL_BPF &&
+	    nn_readb(nn, NFP_NET_CFG_BPF_ABI) == NFP_NET_BPF_ABI)
+		return true;
+	return false;
+}
+
+static int
+nfp_bpf_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
+		    struct bpf_prog *prog)
+{
+	struct tc_cls_bpf_offload cmd = {
+		.prog = prog,
+	};
+	int ret;
+
+	if (!nfp_net_ebpf_capable(nn))
+		return -EINVAL;
+
+	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF) {
+		if (!nn->dp.bpf_offload_xdp)
+			return prog ? -EBUSY : 0;
+		cmd.command = prog ? TC_CLSBPF_REPLACE : TC_CLSBPF_DESTROY;
+	} else {
+		if (!prog)
+			return 0;
+		cmd.command = TC_CLSBPF_ADD;
+	}
+
+	ret = nfp_net_bpf_offload(nn, &cmd);
+	/* Stop offload if replace not possible */
+	if (ret && cmd.command == TC_CLSBPF_REPLACE)
+		nfp_bpf_xdp_offload(app, nn, NULL);
+	nn->dp.bpf_offload_xdp = prog && !ret;
+	return ret;
+}
+
+static const char *nfp_bpf_extra_cap(struct nfp_app *app, struct nfp_net *nn)
+{
+	return nfp_net_ebpf_capable(nn) ? "BPF" : "";
+}
 
 static int
 nfp_bpf_vnic_init(struct nfp_app *app, struct nfp_net *nn, unsigned int id)
@@ -51,9 +97,47 @@ nfp_bpf_vnic_init(struct nfp_app *app, struct nfp_net *nn, unsigned int id)
 	return nfp_app_nic_vnic_init(app, nn, id);
 }
 
+static void nfp_bpf_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
+{
+	if (nn->dp.bpf_offload_xdp)
+		nfp_bpf_xdp_offload(app, nn, NULL);
+}
+
+static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
+			    u32 handle, __be16 proto, struct tc_to_netdev *tc)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
+		return -EOPNOTSUPP;
+	if (proto != htons(ETH_P_ALL))
+		return -EOPNOTSUPP;
+
+	if (tc->type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn)) {
+		if (!nn->dp.bpf_offload_xdp)
+			return nfp_net_bpf_offload(nn, tc->cls_bpf);
+		else
+			return -EBUSY;
+	}
+
+	return -EINVAL;
+}
+
+static bool nfp_bpf_tc_busy(struct nfp_app *app, struct nfp_net *nn)
+{
+	return nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF;
+}
+
 const struct nfp_app_type app_bpf = {
 	.id		= NFP_APP_BPF_NIC,
 	.name		= "ebpf",
 
+	.extra_cap	= nfp_bpf_extra_cap,
+
 	.vnic_init	= nfp_bpf_vnic_init,
+	.vnic_clean	= nfp_bpf_vnic_clean,
+
+	.setup_tc	= nfp_bpf_setup_tc,
+	.tc_busy	= nfp_bpf_tc_busy,
+	.xdp_offload	= nfp_bpf_xdp_offload,
 };
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index 9513c80f7be5..9b526698e47d 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -198,4 +198,9 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog, enum nfp_bpf_action_type act,
 
 int nfp_prog_verify(struct nfp_prog *nfp_prog, struct bpf_prog *prog);
 
+struct nfp_net;
+struct tc_cls_bpf_offload;
+
+int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf);
+
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index b5426398f29e..13efdefffa1a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -34,7 +34,10 @@
 #ifndef _NFP_APP_H
 #define _NFP_APP_H 1
 
+struct bpf_prog;
+struct net_device;
 struct pci_dev;
+struct tc_to_netdev;
 struct nfp_app;
 struct nfp_cpp;
 struct nfp_pf;
@@ -55,7 +58,12 @@ extern const struct nfp_app_type app_bpf;
  *
  * Callbacks
  * @init:	perform basic app checks
+ * @extra_cap:	extra capabilities string
  * @vnic_init:	init vNICs (assign port types, etc.)
+ * @vnic_clean:	clean up app's vNIC state
+ * @setup_tc:	setup TC ndo
+ * @tc_busy:	TC HW offload busy (rules loaded)
+ * @xdp_offload:    offload an XDP program
  */
 struct nfp_app_type {
 	enum nfp_app_id id;
@@ -63,8 +71,17 @@ struct nfp_app_type {
 
 	int (*init)(struct nfp_app *app);
 
+	const char *(*extra_cap)(struct nfp_app *app, struct nfp_net *nn);
+
 	int (*vnic_init)(struct nfp_app *app, struct nfp_net *nn,
 			 unsigned int id);
+	void (*vnic_clean)(struct nfp_app *app, struct nfp_net *nn);
+
+	int (*setup_tc)(struct nfp_app *app, struct net_device *netdev,
+			u32 handle, __be16 proto, struct tc_to_netdev *tc);
+	bool (*tc_busy)(struct nfp_app *app, struct nfp_net *nn);
+	int (*xdp_offload)(struct nfp_app *app, struct nfp_net *nn,
+			   struct bpf_prog *prog);
 };
 
 /**
@@ -95,6 +112,12 @@ static inline int nfp_app_vnic_init(struct nfp_app *app, struct nfp_net *nn,
 	return app->type->vnic_init(app, nn, id);
 }
 
+static inline void nfp_app_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
+{
+	if (app->type->vnic_clean)
+		app->type->vnic_clean(app, nn);
+}
+
 static inline const char *nfp_app_name(struct nfp_app *app)
 {
 	if (!app)
@@ -102,6 +125,44 @@ static inline const char *nfp_app_name(struct nfp_app *app)
 	return app->type->name;
 }
 
+static inline const char *nfp_app_extra_cap(struct nfp_app *app,
+					    struct nfp_net *nn)
+{
+	if (!app || !app->type->extra_cap)
+		return "";
+	return app->type->extra_cap(app, nn);
+}
+
+static inline bool nfp_app_has_tc(struct nfp_app *app)
+{
+	return app && app->type->setup_tc;
+}
+
+static inline bool nfp_app_tc_busy(struct nfp_app *app, struct nfp_net *nn)
+{
+	if (!app || !app->type->tc_busy)
+		return false;
+	return app->type->tc_busy(app, nn);
+}
+
+static inline int nfp_app_setup_tc(struct nfp_app *app,
+				   struct net_device *netdev,
+				   u32 handle, __be16 proto,
+				   struct tc_to_netdev *tc)
+{
+	if (!app || !app->type->setup_tc)
+		return -EOPNOTSUPP;
+	return app->type->setup_tc(app, netdev, handle, proto, tc);
+}
+
+static inline int nfp_app_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
+				      struct bpf_prog *prog)
+{
+	if (!app || !app->type->xdp_offload)
+		return -EOPNOTSUPP;
+	return app->type->xdp_offload(app, nn, prog);
+}
+
 struct nfp_app *nfp_app_alloc(struct nfp_pf *pf, enum nfp_app_id id);
 void nfp_app_free(struct nfp_app *app);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index cb7114309656..883cc6be02c1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -868,6 +868,5 @@ static inline void nfp_net_debugfs_dir_clean(struct dentry **dir)
 #endif /* CONFIG_NFP_DEBUG */
 
 void nfp_net_filter_stats_timer(unsigned long data);
-int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf);
 
 #endif /* _NFP_NET_H_ */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2bcf3e8330ea..e0ece2de5841 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -64,10 +64,10 @@
 
 #include <linux/ktime.h>
 
-#include <net/pkt_cls.h>
 #include <net/vxlan.h>
 
 #include "nfpcore/nfp_nsp.h"
+#include "nfp_app.h"
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 #include "nfp_port.h"
@@ -2681,33 +2681,13 @@ static void nfp_net_stat64(struct net_device *netdev,
 	}
 }
 
-static bool nfp_net_ebpf_capable(struct nfp_net *nn)
-{
-	if (nn->cap & NFP_NET_CFG_CTRL_BPF &&
-	    nn_readb(nn, NFP_NET_CFG_BPF_ABI) == NFP_NET_BPF_ABI)
-		return true;
-	return false;
-}
-
 static int
 nfp_net_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
 		 struct tc_to_netdev *tc)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
-		return -EOPNOTSUPP;
-	if (proto != htons(ETH_P_ALL))
-		return -EOPNOTSUPP;
-
-	if (tc->type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn)) {
-		if (!nn->dp.bpf_offload_xdp)
-			return nfp_net_bpf_offload(nn, tc->cls_bpf);
-		else
-			return -EBUSY;
-	}
-
-	return -EINVAL;
+	return nfp_app_setup_tc(nn->app, netdev, handle, proto, tc);
 }
 
 static int nfp_net_set_features(struct net_device *netdev,
@@ -2765,7 +2745,7 @@ static int nfp_net_set_features(struct net_device *netdev,
 			new_ctrl &= ~NFP_NET_CFG_CTRL_GATHER;
 	}
 
-	if (changed & NETIF_F_HW_TC && nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF) {
+	if (changed & NETIF_F_HW_TC && nfp_app_tc_busy(nn->app, nn)) {
 		nn_err(nn, "Cannot disable HW TC offload while in use\n");
 		return -EBUSY;
 	}
@@ -2914,34 +2894,6 @@ static void nfp_net_del_vxlan_port(struct net_device *netdev,
 		nfp_net_set_vxlan_port(nn, idx, 0);
 }
 
-static int nfp_net_xdp_offload(struct nfp_net *nn, struct bpf_prog *prog)
-{
-	struct tc_cls_bpf_offload cmd = {
-		.prog = prog,
-	};
-	int ret;
-
-	if (!nfp_net_ebpf_capable(nn))
-		return -EINVAL;
-
-	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF) {
-		if (!nn->dp.bpf_offload_xdp)
-			return prog ? -EBUSY : 0;
-		cmd.command = prog ? TC_CLSBPF_REPLACE : TC_CLSBPF_DESTROY;
-	} else {
-		if (!prog)
-			return 0;
-		cmd.command = TC_CLSBPF_ADD;
-	}
-
-	ret = nfp_net_bpf_offload(nn, &cmd);
-	/* Stop offload if replace not possible */
-	if (ret && cmd.command == TC_CLSBPF_REPLACE)
-		nfp_net_xdp_offload(nn, NULL);
-	nn->dp.bpf_offload_xdp = prog && !ret;
-	return ret;
-}
-
 static int nfp_net_xdp_setup(struct nfp_net *nn, struct netdev_xdp *xdp)
 {
 	struct bpf_prog *old_prog = nn->dp.xdp_prog;
@@ -2954,7 +2906,7 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct netdev_xdp *xdp)
 	if (prog && nn->dp.xdp_prog) {
 		prog = xchg(&nn->dp.xdp_prog, prog);
 		bpf_prog_put(prog);
-		nfp_net_xdp_offload(nn, nn->dp.xdp_prog);
+		nfp_app_xdp_offload(nn->app, nn, nn->dp.xdp_prog);
 		return 0;
 	}
 
@@ -2975,7 +2927,7 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct netdev_xdp *xdp)
 	if (old_prog)
 		bpf_prog_put(old_prog);
 
-	nfp_net_xdp_offload(nn, nn->dp.xdp_prog);
+	nfp_app_xdp_offload(nn->app, nn, nn->dp.xdp_prog);
 
 	return 0;
 }
@@ -3068,10 +3020,10 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->cap & NFP_NET_CFG_CTRL_IRQMOD   ? "IRQMOD "   : "",
 		nn->cap & NFP_NET_CFG_CTRL_VXLAN    ? "VXLAN "    : "",
 		nn->cap & NFP_NET_CFG_CTRL_NVGRE    ? "NVGRE "	  : "",
-		nfp_net_ebpf_capable(nn)            ? "BPF "	  : "",
 		nn->cap & NFP_NET_CFG_CTRL_CSUM_COMPLETE ?
 						      "RXCSUM_COMPLETE " : "",
-		nn->cap & NFP_NET_CFG_CTRL_LIVE_ADDR ? "LIVE_ADDR " : "");
+		nn->cap & NFP_NET_CFG_CTRL_LIVE_ADDR ? "LIVE_ADDR " : "",
+		nfp_app_extra_cap(nn->app, nn));
 }
 
 /**
@@ -3316,7 +3268,7 @@ int nfp_net_init(struct nfp_net *nn)
 
 	netdev->features = netdev->hw_features;
 
-	if (nfp_net_ebpf_capable(nn))
+	if (nfp_app_has_tc(nn->app))
 		netdev->hw_features |= NETIF_F_HW_TC;
 
 	/* Advertise but disable TSO by default. */
@@ -3373,6 +3325,4 @@ void nfp_net_clean(struct nfp_net *nn)
 
 	if (nn->dp.xdp_prog)
 		bpf_prog_put(nn->dp.xdp_prog);
-	if (nn->dp.bpf_offload_xdp)
-		nfp_net_xdp_offload(nn, NULL);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 28782bf3ce68..7dd310911d9f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -427,6 +427,7 @@ static void nfp_net_pf_clean_vnic(struct nfp_pf *pf, struct nfp_net *nn)
 		nfp_devlink_port_unregister(nn->port);
 	nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
 	nfp_net_clean(nn);
+	nfp_app_vnic_clean(pf->app, nn);
 }
 
 static int
-- 
2.11.0
