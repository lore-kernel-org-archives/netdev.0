From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 06/12] nfp: add hardware cls_bpf offload
Date: Wed,  1 Jun 2016 17:50:08 +0100
Message-ID: <1464799814-4453-7-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36796 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbcFAQwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:52:09 -0400
Received: by mail-wm0-f41.google.com with SMTP id n184so41574219wmn.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:52:03 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add hardware cls_bpf offload on our smart NICs.  Detect if
capable firmware is loaded and use it to load the code JITed
with just added translator onto programmable engines.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  13 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  30 +++-
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  18 +-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   | 191 +++++++++++++++++++++
 5 files changed, 249 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_offload.c

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 46648404e750..6d1a83cd17e8 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -3,6 +3,7 @@ obj-$(CONFIG_NFP_NETVF)	+= nfp_netvf.o
 nfp_netvf-objs := \
 	    nfp_net_common.o \
 	    nfp_net_ethtool.o \
+	    nfp_net_offload.o \
 	    nfp_netvf_main.o \
 	    nfp_bpf_jit.o
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index e744acc18ef4..784287e9ccaa 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -413,6 +413,7 @@ static inline bool nfp_net_fw_ver_eq(struct nfp_net_fw_version *fw_ver,
  * @is_vf:              Is the driver attached to a VF?
  * @is_nfp3200:         Is the driver for a NFP-3200 card?
  * @fw_loaded:          Is the firmware loaded?
+ * @bpf_offload_skip_sw:    Offloaded BPF program will not be rerun by cls_bpf
  * @ctrl:               Local copy of the control register/word.
  * @fl_bufsz:           Currently configured size of the freelist buffers
  * @rx_offset:		Offset in the RX buffers where packet data starts
@@ -473,6 +474,7 @@ struct nfp_net {
 	unsigned is_vf:1;
 	unsigned is_nfp3200:1;
 	unsigned fw_loaded:1;
+	unsigned bpf_offload_skip_sw:1;
 
 	u32 ctrl;
 	u32 fl_bufsz;
@@ -566,7 +568,12 @@ static inline void nn_writeb(struct nfp_net *nn, int off, u8 val)
 	writeb(val, nn->ctrl_bar + off);
 }
 
-/* NFP-3200 can't handle 16-bit accesses too well - hence no readw/writew */
+/* NFP-3200 can't handle 16-bit accesses too well */
+static inline u16 nn_readw(struct nfp_net *nn, int off)
+{
+	WARN_ON_ONCE(nn->is_nfp3200);
+	return readw(nn->ctrl_bar + off);
+}
 
 static inline u32 nn_readl(struct nfp_net *nn, int off)
 {
@@ -734,6 +741,10 @@ int nfp_net_irqs_alloc(struct nfp_net *nn);
 void nfp_net_irqs_disable(struct nfp_net *nn);
 int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt);
 
+int
+nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
+		    struct tc_cls_bpf_offload *cls_bpf);
+
 #ifdef CONFIG_NFP_NET_DEBUG
 void nfp_net_debugfs_create(void);
 void nfp_net_debugfs_destroy(void);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index fa47c14c743a..c5acdf703b7f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -61,6 +61,7 @@
 
 #include <linux/ktime.h>
 
+#include <net/pkt_cls.h>
 #include <net/vxlan.h>
 
 #include "nfp_net_ctrl.h"
@@ -2386,6 +2387,21 @@ static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
 	return stats;
 }
 
+static int
+nfp_net_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
+		 struct tc_to_netdev *tc)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
+		return -EINVAL;
+
+	if (tc->type == TC_SETUP_CLSBPF && nn->cap & NFP_NET_CFG_CTRL_BPF)
+		return nfp_net_bpf_offload(nn, handle, proto, tc->cls_bpf);
+
+	return -EINVAL;
+}
+
 static int nfp_net_set_features(struct net_device *netdev,
 				netdev_features_t features)
 {
@@ -2440,6 +2456,11 @@ static int nfp_net_set_features(struct net_device *netdev,
 			new_ctrl &= ~NFP_NET_CFG_CTRL_GATHER;
 	}
 
+	if (changed & NETIF_F_HW_TC && nn->ctrl & NFP_NET_CFG_CTRL_BPF) {
+		nn_err(nn, "Cannot disable HW TC offload while in use\n");
+		return -EBUSY;
+	}
+
 	nn_dbg(nn, "Feature change 0x%llx -> 0x%llx (changed=0x%llx)\n",
 	       netdev->features, features, changed);
 
@@ -2583,6 +2604,7 @@ static const struct net_device_ops nfp_net_netdev_ops = {
 	.ndo_stop		= nfp_net_netdev_close,
 	.ndo_start_xmit		= nfp_net_tx,
 	.ndo_get_stats64	= nfp_net_stat64,
+	.ndo_setup_tc		= nfp_net_setup_tc,
 	.ndo_tx_timeout		= nfp_net_tx_timeout,
 	.ndo_set_rx_mode	= nfp_net_set_rx_mode,
 	.ndo_change_mtu		= nfp_net_change_mtu,
@@ -2608,7 +2630,7 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->fw_ver.resv, nn->fw_ver.class,
 		nn->fw_ver.major, nn->fw_ver.minor,
 		nn->max_mtu);
-	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
+	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
 		nn->cap,
 		nn->cap & NFP_NET_CFG_CTRL_PROMISC  ? "PROMISC "  : "",
 		nn->cap & NFP_NET_CFG_CTRL_L2BC     ? "L2BCFILT " : "",
@@ -2625,7 +2647,8 @@ void nfp_net_info(struct nfp_net *nn)
 		nn->cap & NFP_NET_CFG_CTRL_MSIXAUTO ? "AUTOMASK " : "",
 		nn->cap & NFP_NET_CFG_CTRL_IRQMOD   ? "IRQMOD "   : "",
 		nn->cap & NFP_NET_CFG_CTRL_VXLAN    ? "VXLAN "    : "",
-		nn->cap & NFP_NET_CFG_CTRL_NVGRE    ? "NVGRE "	  : "");
+		nn->cap & NFP_NET_CFG_CTRL_NVGRE    ? "NVGRE "	  : "",
+		nn->cap & NFP_NET_CFG_CTRL_BPF      ? "BPF "	  : "");
 }
 
 /**
@@ -2793,6 +2816,9 @@ int nfp_net_netdev_init(struct net_device *netdev)
 
 	netdev->features = netdev->hw_features;
 
+	if (nn->cap & NFP_NET_CFG_CTRL_BPF)
+		netdev->hw_features |= NETIF_F_HW_TC;
+
 	/* Advertise but disable TSO by default. */
 	netdev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index ad6c4e31cedd..c26449655419 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -123,6 +123,7 @@
 #define   NFP_NET_CFG_CTRL_L2SWITCH_LOCAL (0x1 << 23) /* Switch to local */
 #define   NFP_NET_CFG_CTRL_VXLAN	  (0x1 << 24) /* VXLAN tunnel support */
 #define   NFP_NET_CFG_CTRL_NVGRE	  (0x1 << 25) /* NVGRE tunnel support */
+#define   NFP_NET_CFG_CTRL_BPF		  (0x1 << 27) /* BPF offload */
 #define NFP_NET_CFG_UPDATE              0x0004
 #define   NFP_NET_CFG_UPDATE_GEN          (0x1 <<  0) /* General update */
 #define   NFP_NET_CFG_UPDATE_RING         (0x1 <<  1) /* Ring config change */
@@ -134,6 +135,7 @@
 #define   NFP_NET_CFG_UPDATE_RESET        (0x1 <<  7) /* Update due to FLR */
 #define   NFP_NET_CFG_UPDATE_IRQMOD       (0x1 <<  8) /* IRQ mod change */
 #define   NFP_NET_CFG_UPDATE_VXLAN	  (0x1 <<  9) /* VXLAN port change */
+#define   NFP_NET_CFG_UPDATE_BPF	  (0x1 << 10) /* BPF program load */
 #define   NFP_NET_CFG_UPDATE_ERR          (0x1 << 31) /* A error occurred */
 #define NFP_NET_CFG_TXRS_ENABLE         0x0008
 #define NFP_NET_CFG_RXRS_ENABLE         0x0010
@@ -196,7 +198,21 @@
 #define NFP_NET_CFG_VXLAN_SZ		  0x0008
 
 /**
- * 64B reserved for future use (0x0080 - 0x00c0)
+ * NFP6000 - BPF loading
+ * @NFP_NET_CFG_BPF_SIZE:	Size of the JITed BPF code in bytes
+ * @NFP_NET_CFG_BPF_ADDR:	DMA address of the buffer with JITed BPF code
+ * @NFP_NET_CFG_BPF_START:	Offset at which BPF will be loaded
+ * @NFP_NET_CFG_BPF_MAX_LEN:	Maximum size of JITed BPF code in bytes
+ */
+#define NFP_NET_CFG_BPF_MAX_LEN		0x0080
+#define NFP_NET_CFG_BPF_START		0x0082
+#define NFP_NET_CFG_BPF_TGT_OUT		0x0084
+#define NFP_NET_CFG_BPF_TGT_ABORT	0x0086
+#define NFP_NET_CFG_BPF_SIZE		0x0088
+#define NFP_NET_CFG_BPF_ADDR		0x008c
+
+/**
+ * 48B reserved for future use (0x0090 - 0x00c0)
  */
 #define NFP_NET_CFG_RESERVED            0x0080
 #define NFP_NET_CFG_RESERVED_SZ         0x0040
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
new file mode 100644
index 000000000000..dd2e428fd35a
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -0,0 +1,191 @@
+/*
+ * Copyright (C) 2016 Netronome Systems, Inc.
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
+/*
+ * nfp_net_offload.c
+ * Netronome network device driver: TC offload functions for PF and VF
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+
+#include <net/pkt_cls.h>
+#include <net/tc_act/tc_gact.h>
+
+#include "nfp_bpf.h"
+#include "nfp_net_ctrl.h"
+#include "nfp_net.h"
+
+static int
+nfp_net_bpf_offload_prepare(struct nfp_net *nn,
+			    struct tc_cls_bpf_offload *cls_bpf,
+			    struct nfp_bpf_result *res,
+			    void **code, dma_addr_t *dma_addr, u16 max_instr)
+{
+	unsigned int code_sz = max_instr * sizeof(u64);
+	u16 start_off, tgt_out, tgt_abort;
+	const struct tc_action *a;
+	int err;
+
+	if (tc_no_actions(cls_bpf->exts))
+		return -EINVAL;
+
+	tc_for_each_action(a, cls_bpf->exts) {
+		if (!is_tcf_gact_shot(a))
+			return -EINVAL;
+	}
+
+	if (cls_bpf->exts_integrated)
+		return -EINVAL;
+
+	start_off = nn_readw(nn, NFP_NET_CFG_BPF_START);
+	tgt_out = nn_readw(nn, NFP_NET_CFG_BPF_TGT_OUT);
+	tgt_abort = nn_readw(nn, NFP_NET_CFG_BPF_TGT_ABORT);
+
+	*code = dma_zalloc_coherent(&nn->pdev->dev, code_sz, dma_addr,
+				    GFP_KERNEL);
+	if (!*code)
+		return -ENOMEM;
+
+	err = nfp_bpf_jit(cls_bpf->filter, *code, start_off, tgt_out, tgt_abort,
+			  max_instr, res);
+	if (err)
+		goto out;
+
+	return 0;
+
+out:
+	dma_free_coherent(&nn->pdev->dev, code_sz, *code, *dma_addr);
+	return err;
+}
+
+static void
+nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
+			   void *code, dma_addr_t dma_addr,
+			   unsigned int code_sz, unsigned int n_instr)
+{
+	int err;
+
+	nn->bpf_offload_skip_sw = !!(tc_flags & TCA_CLS_FLAGS_SKIP_SW);
+
+	nn_writel(nn, NFP_NET_CFG_BPF_SIZE, n_instr * sizeof(u64));
+	nn_writeq(nn, NFP_NET_CFG_BPF_ADDR, dma_addr);
+
+	/* Load up the JITed code */
+	nn_info(nn, "Reloading BPF code (%d instr)\n", n_instr);
+	err = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_BPF);
+	if (err)
+		nn_err(nn, "FW command error while loading BPF: %d\n", err);
+
+	/* Enable passing packets through BPF function */
+	nn->ctrl |= NFP_NET_CFG_CTRL_BPF;
+	nn_writel(nn, NFP_NET_CFG_CTRL, nn->ctrl);
+	err = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
+	if (err)
+		nn_err(nn, "FW command error while enabling BPF: %d\n", err);
+
+	dma_free_coherent(&nn->pdev->dev, code_sz, code, dma_addr);
+}
+
+static int nfp_net_bpf_stop(struct nfp_net *nn)
+{
+	if (!(nn->ctrl & NFP_NET_CFG_CTRL_BPF))
+		return 0;
+
+	nn->ctrl &= ~NFP_NET_CFG_CTRL_BPF;
+	nn_writel(nn, NFP_NET_CFG_CTRL, nn->ctrl);
+
+	nn->bpf_offload_skip_sw = 0;
+
+	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
+}
+
+int
+nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
+		    struct tc_cls_bpf_offload *cls_bpf)
+{
+	struct nfp_bpf_result res;
+	dma_addr_t dma_addr;
+	u16 max_instr;
+	void *code;
+	int err;
+
+	max_instr = nn_readw(nn, NFP_NET_CFG_BPF_MAX_LEN);
+
+	switch (cls_bpf->command) {
+	case TC_CLSBPF_REPLACE:
+		/* There is nothing stopping us from implementing seamless
+		 * replace but the simple method of loading I adopted in
+		 * the firmware does not handle atomic replace (i.e. we have to
+		 * stop the BPF offload and re-enable it).  Leaking-in a few
+		 * frames which didn't have BPF applied in the hardware should
+		 * be fine if software fallback is available, though.
+		 */
+		if (nn->bpf_offload_skip_sw) {
+			nn_info(nn, "can't do atomic replace, yet, sorry!\n");
+			return -EBUSY;
+		}
+
+		err = nfp_net_bpf_offload_prepare(nn, cls_bpf, &res, &code,
+						  &dma_addr, max_instr);
+		if (err)
+			return err;
+
+		nfp_net_bpf_stop(nn);
+		nfp_net_bpf_load_and_start(nn, cls_bpf->gen_flags, code,
+					   dma_addr, max_instr * sizeof(u64),
+					   res.n_instr);
+		return 0;
+
+	case TC_CLSBPF_ADD:
+		if (nn->ctrl & NFP_NET_CFG_CTRL_BPF)
+			return -EBUSY;
+
+		err = nfp_net_bpf_offload_prepare(nn, cls_bpf, &res, &code,
+						  &dma_addr, max_instr);
+		if (err)
+			return err;
+
+		nfp_net_bpf_load_and_start(nn, cls_bpf->gen_flags, code,
+					   dma_addr, max_instr * sizeof(u64),
+					   res.n_instr);
+		return 0;
+
+	case TC_CLSBPF_DESTROY:
+		return nfp_net_bpf_stop(nn);
+
+	default:
+		return -ENOTSUPP;
+	}
+}
-- 
1.9.1
