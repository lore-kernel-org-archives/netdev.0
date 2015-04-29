From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [RFC,v3 09/10] dpaa_eth: add debugfs entries
Date: Wed, 29 Apr 2015 17:56:44 +0300
Message-ID: <1430319405-31280-8-git-send-email-madalin.bucur@freescale.com>
References: <1430319405-31280-1-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-2-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-3-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-4-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-5-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-6-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-7-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0135.outbound.protection.outlook.com ([207.46.100.135]:2014
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423352AbbD2O5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 10:57:03 -0400
In-Reply-To: <1430319405-31280-7-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export per CPU counters through debugfs.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/dpaa/Kconfig        |   7 +
 drivers/net/ethernet/freescale/dpaa/Makefile       |   3 +
 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.c | 273 +++++++++++++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.h |  43 ++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  11 +
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |   4 +
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  |  17 ++
 7 files changed, 358 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.c
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.h

diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig b/drivers/net/ethernet/freescale/dpaa/Kconfig
index 3fa7925..ddc9d9b 100644
--- a/drivers/net/ethernet/freescale/dpaa/Kconfig
+++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
@@ -71,4 +71,11 @@ config FSL_DPAA_INGRESS_CS_THRESHOLD
 	  The size in bytes of the ingress tail-drop threshold on FMan ports.
 	  Traffic piling up above this value will be rejected by QMan and discarded by FMan.
 
+config FSL_DPAA_ETH_DEBUGFS
+	bool "DPAA Ethernet debugfs interface"
+	depends on DEBUG_FS
+	default y
+	---help---
+	  This option compiles debugfs code for the DPAA Ethernet driver.
+
 endif # FSL_DPAA_ETH
diff --git a/drivers/net/ethernet/freescale/dpaa/Makefile b/drivers/net/ethernet/freescale/dpaa/Makefile
index 3a276d5..3427de4 100644
--- a/drivers/net/ethernet/freescale/dpaa/Makefile
+++ b/drivers/net/ethernet/freescale/dpaa/Makefile
@@ -11,3 +11,6 @@ ccflags-y += -I$(FMAN)/flib
 obj-$(CONFIG_FSL_DPAA_ETH) += fsl_dpa.o
 
 fsl_dpa-objs += dpaa_eth.o dpaa_eth_sg.o dpaa_eth_common.o dpaa_ethtool.o dpaa_eth_sysfs.o
+ifeq ($(CONFIG_FSL_DPAA_ETH_DEBUGFS),y)
+fsl_dpa-objs += dpaa_debugfs.o
+endif
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.c b/drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.c
new file mode 100644
index 0000000..2687980
--- /dev/null
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.c
@@ -0,0 +1,273 @@
+/* Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/module.h>
+#include <soc/fsl/qman.h>
+#include <linux/debugfs.h>
+#include <asm/debug.h>
+#include "dpaa_debugfs.h"
+#include "dpaa_eth.h"
+
+#define DPA_DEBUGFS_DESCRIPTION "FSL DPAA Ethernet debugfs entries"
+#define DPA_ETH_DEBUGFS_ROOT "fsl_dpa"
+
+static int dpa_debugfs_open(struct inode *inode, struct file *file);
+
+static struct dentry *dpa_debugfs_root;
+static const struct file_operations dpa_debugfs_fops = {
+	.open		= dpa_debugfs_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int dpa_debugfs_show(struct seq_file *file, void *offset)
+{
+	int				 i;
+	struct dpa_priv_s		*priv;
+	struct dpa_percpu_priv_s	*percpu_priv, total;
+	struct dpa_bp *dpa_bp;
+	unsigned int dpa_bp_count = 0;
+	unsigned int count_total = 0;
+	struct qm_mcr_querycgr query_cgr;
+
+	BUG_ON(!offset);
+
+	priv = netdev_priv((struct net_device *)file->private);
+
+	dpa_bp = priv->dpa_bp;
+
+	memset(&total, 0, sizeof(total));
+
+	/* "Standard" counters */
+	seq_printf(file, "\nDPA counters for %s:\n", priv->net_dev->name);
+	seq_puts(file, "CPU           irqs        rx        tx   recycle   ");
+	seq_puts(file, "confirm     tx sg    tx err    rx err   bp count\n");
+
+	for_each_online_cpu(i) {
+		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
+
+		if (dpa_bp->percpu_count)
+			dpa_bp_count = *(per_cpu_ptr(dpa_bp->percpu_count, i));
+
+		total.in_interrupt += percpu_priv->in_interrupt;
+		total.stats.rx_packets += percpu_priv->stats.rx_packets;
+		total.stats.tx_packets += percpu_priv->stats.tx_packets;
+		total.tx_confirm += percpu_priv->tx_confirm;
+		total.tx_frag_skbuffs += percpu_priv->tx_frag_skbuffs;
+		total.stats.tx_errors += percpu_priv->stats.tx_errors;
+		total.stats.rx_errors += percpu_priv->stats.rx_errors;
+		count_total += dpa_bp_count;
+
+		seq_printf(file, "     %hu  %8llu  %8llu  %8llu  ",
+			   i,
+			   percpu_priv->in_interrupt,
+			   percpu_priv->stats.rx_packets,
+			   percpu_priv->stats.tx_packets);
+		seq_printf(file, "%8llu  %8llu  %8llu  %8llu     %8d\n",
+			   percpu_priv->tx_confirm,
+			   percpu_priv->tx_frag_skbuffs,
+			   percpu_priv->stats.tx_errors,
+			   percpu_priv->stats.rx_errors,
+			   dpa_bp_count);
+	}
+	seq_printf(file, "Total     %8llu  %8llu  %8llu  ",
+		   total.in_interrupt,
+		   total.stats.rx_packets,
+		   total.stats.tx_packets);
+	seq_printf(file, "%8llu  %8llu  %8llu  %8llu     %8d\n",
+		   total.tx_confirm,
+		   total.tx_frag_skbuffs,
+		   total.stats.tx_errors,
+		   total.stats.rx_errors,
+		   count_total);
+
+	/* Congestion stats */
+	seq_puts(file, "\nDevice congestion stats:\n");
+	seq_printf(file, "Device has been congested for %d ms.\n",
+		   jiffies_to_msecs(priv->cgr_data.congested_jiffies));
+
+	if (qman_query_cgr(&priv->cgr_data.cgr, &query_cgr) != 0) {
+		seq_printf(file, "CGR id %d - failed to query values\n",
+			   priv->cgr_data.cgr.cgrid);
+	} else {
+		seq_printf(file, "CGR id %d avg count: %llu\n",
+			   priv->cgr_data.cgr.cgrid,
+			   qm_mcr_querycgr_a_get64(&query_cgr));
+		seq_printf(file, "Device entered congestion %u times. ",
+			   priv->cgr_data.cgr_congested_count);
+		seq_printf(file, "Current congestion state is: %s.\n",
+			   query_cgr.cgr.cs ? "congested" : "not congested");
+		/* Reset congestion stats (like QMan CGR API does) */
+		priv->cgr_data.congested_jiffies = 0;
+		priv->cgr_data.cgr_congested_count = 0;
+	}
+
+	/* Rx Errors demultiplexing */
+	seq_puts(file, "\nDPA RX Errors:\nCPU        dma err  phys err");
+	seq_puts(file, "  size err   hdr err  csum err\n");
+	for_each_online_cpu(i) {
+		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
+
+		total.rx_errors.dme += percpu_priv->rx_errors.dme;
+		total.rx_errors.fpe += percpu_priv->rx_errors.fpe;
+		total.rx_errors.fse += percpu_priv->rx_errors.fse;
+		total.rx_errors.phe += percpu_priv->rx_errors.phe;
+
+		seq_printf(file, "     %hu  %8llu  %8llu  ",
+			   i,
+			   percpu_priv->rx_errors.dme,
+			   percpu_priv->rx_errors.fpe);
+		seq_printf(file, "%8llu  %8llu\n",
+			   percpu_priv->rx_errors.fse,
+			   percpu_priv->rx_errors.phe);
+	}
+	seq_printf(file, "Total     %8llu  %8llu  %8llu  %8llu\n",
+		   total.rx_errors.dme,
+		   total.rx_errors.fpe,
+		   total.rx_errors.fse,
+		   total.rx_errors.phe);
+
+	/* ERN demultiplexing */
+	seq_puts(file, "\nDPA ERN counters:\n  CPU     cg_td      wred  ");
+	seq_puts(file, "err_cond   early_w    late_w     fq_td    fq_ret");
+	seq_puts(file, "     orp_z\n");
+	for_each_online_cpu(i) {
+		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
+
+		total.ern_cnt.cg_tdrop += percpu_priv->ern_cnt.cg_tdrop;
+		total.ern_cnt.wred += percpu_priv->ern_cnt.wred;
+		total.ern_cnt.err_cond += percpu_priv->ern_cnt.err_cond;
+		total.ern_cnt.early_window += percpu_priv->ern_cnt.early_window;
+		total.ern_cnt.late_window += percpu_priv->ern_cnt.late_window;
+		total.ern_cnt.fq_tdrop += percpu_priv->ern_cnt.fq_tdrop;
+		total.ern_cnt.fq_retired += percpu_priv->ern_cnt.fq_retired;
+		total.ern_cnt.orp_zero += percpu_priv->ern_cnt.orp_zero;
+
+		seq_printf(file, "  %hu  %8llu  %8llu  %8llu  %8llu  ",
+			   i,
+			   percpu_priv->ern_cnt.cg_tdrop,
+			   percpu_priv->ern_cnt.wred,
+			   percpu_priv->ern_cnt.err_cond,
+			   percpu_priv->ern_cnt.early_window);
+		seq_printf(file, "%8llu  %8llu  %8llu  %8llu\n",
+			   percpu_priv->ern_cnt.late_window,
+			   percpu_priv->ern_cnt.fq_tdrop,
+			   percpu_priv->ern_cnt.fq_retired,
+			   percpu_priv->ern_cnt.orp_zero);
+	}
+	seq_printf(file, "Total  %8llu  %8llu  %8llu  %8llu  ",
+		   total.ern_cnt.cg_tdrop,
+		   total.ern_cnt.wred,
+		   total.ern_cnt.err_cond,
+		   total.ern_cnt.early_window);
+	seq_printf(file, "%8llu  %8llu  %8llu  %8llu\n",
+		   total.ern_cnt.late_window,
+		   total.ern_cnt.fq_tdrop,
+		   total.ern_cnt.fq_retired,
+		   total.ern_cnt.orp_zero);
+
+	return 0;
+}
+
+static int dpa_debugfs_open(struct inode *inode, struct file *file)
+{
+	int			 err;
+	const struct net_device	*net_dev;
+	struct dpa_priv_s	*priv;
+
+	err = single_open(file, dpa_debugfs_show, inode->i_private);
+	if (unlikely(err < 0)) {
+		net_dev = (struct net_device *)inode->i_private;
+		priv = (struct dpa_priv_s *)netdev_priv(net_dev);
+
+		netif_err(priv, drv, net_dev, "single_open() = %d\n", err);
+	}
+	return err;
+}
+
+int dpa_netdev_debugfs_create(struct net_device *net_dev)
+{
+	struct dpa_priv_s *priv = netdev_priv(net_dev);
+
+	if (unlikely(!dpa_debugfs_root)) {
+		pr_err(KBUILD_MODNAME ": %s:%hu:%s(): \t%s\n",
+		       KBUILD_BASENAME ".c", __LINE__, __func__,
+		       "root debugfs missing, possible module ordering issue");
+		return -ENOMEM;
+	}
+
+	priv->debugfs_file = debugfs_create_file(net_dev->name,
+							 S_IRUGO,
+							 dpa_debugfs_root,
+							 net_dev,
+							 &dpa_debugfs_fops);
+	if (unlikely(!priv->debugfs_file)) {
+		netdev_err(net_dev, "debugfs_create_file(%s/%s/%s)",
+			   powerpc_debugfs_root->d_iname,
+			   dpa_debugfs_root->d_iname,
+			   net_dev->name);
+
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+void dpa_netdev_debugfs_remove(struct net_device *net_dev)
+{
+	struct dpa_priv_s *priv = netdev_priv(net_dev);
+
+	debugfs_remove(priv->debugfs_file);
+}
+
+int __init dpa_debugfs_module_init(void)
+{
+	int	 err = 0;
+
+	pr_info(KBUILD_MODNAME ": " DPA_DEBUGFS_DESCRIPTION "\n");
+
+	dpa_debugfs_root = debugfs_create_dir(DPA_ETH_DEBUGFS_ROOT,
+					      powerpc_debugfs_root);
+	if (unlikely(!dpa_debugfs_root)) {
+		err = -ENOMEM;
+		pr_err(KBUILD_MODNAME ": %s:%hu:%s():\n",
+		       KBUILD_BASENAME ".c", __LINE__, __func__);
+		pr_err("\tdebugfs_create_dir(%s/" KBUILD_MODNAME ") = %d\n",
+		       powerpc_debugfs_root->d_iname, err);
+	}
+
+	return err;
+}
+
+void __exit dpa_debugfs_module_exit(void)
+{
+	debugfs_remove(dpa_debugfs_root);
+}
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.h b/drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.h
new file mode 100644
index 0000000..c4c6582
--- /dev/null
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_debugfs.h
@@ -0,0 +1,43 @@
+/* Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef DPAA_DEBUGFS_H_
+#define DPAA_DEBUGFS_H_
+
+#include <linux/netdevice.h>
+#include <linux/dcache.h>
+
+int dpa_netdev_debugfs_create(struct net_device *net_dev);
+void dpa_netdev_debugfs_remove(struct net_device *net_dev);
+int __init dpa_debugfs_module_init(void);
+void __exit dpa_debugfs_module_exit(void);
+
+#endif /* DPAA_DEBUGFS_H_ */
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 3a36594..0d28421 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -57,6 +57,9 @@
 #include "mac.h"
 #include "dpaa_eth.h"
 #include "dpaa_eth_common.h"
+#ifdef CONFIG_FSL_DPAA_ETH_DEBUGFS
+#include "dpaa_debugfs.h"
+#endif /* CONFIG_FSL_DPAA_ETH_DEBUGFS */
 
 #define DPA_NAPI_WEIGHT		64
 
@@ -812,6 +815,10 @@ static int __init dpa_load(void)
 
 	pr_info(DPA_DESCRIPTION "\n");
 
+#ifdef CONFIG_FSL_DPAA_ETH_DEBUGFS
+	dpa_debugfs_module_init();
+#endif /* CONFIG_FSL_DPAA_ETH_DEBUGFS */
+
 	/* initialise dpaa_eth mirror values */
 	dpa_rx_extra_headroom = fm_get_rx_extra_headroom();
 	dpa_max_frm = fm_get_max_frm();
@@ -837,6 +844,10 @@ static void __exit dpa_unload(void)
 
 	platform_driver_unregister(&dpa_driver);
 
+#ifdef CONFIG_FSL_DPAA_ETH_DEBUGFS
+	dpa_debugfs_module_exit();
+#endif /* CONFIG_FSL_DPAA_ETH_DEBUGFS */
+
 	/* Only one channel is used and needs to be relased after all
 	 * interfaces are removed
 	 */
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
index e6b6630..ad0fce7 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -252,6 +252,10 @@ struct dpa_priv_s {
 	u16 channel;	/* "fsl,qman-channel-id" */
 	struct list_head	 dpa_fq_list;
 
+#ifdef CONFIG_FSL_DPAA_ETH_DEBUGFS
+	struct dentry		*debugfs_file;
+#endif /* CONFIG_FSL_DPAA_ETH_DEBUGFS */
+
 	u32 msg_enable;	/* net_device message level */
 
 	struct {
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
index fc90285..712d2f3 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
@@ -43,6 +43,9 @@
 #include <linux/if_vlan.h>
 #include "dpaa_eth.h"
 #include "dpaa_eth_common.h"
+#ifdef CONFIG_FSL_DPAA_ETH_DEBUGFS
+#include "dpaa_debugfs.h"
+#endif /* CONFIG_FSL_DPAA_ETH_DEBUGFS */
 #include "mac.h"
 
 /* Size in bytes of the FQ taildrop threshold */
@@ -92,6 +95,15 @@ int dpa_netdev_init(struct net_device *net_dev,
 		return err;
 	}
 
+#ifdef CONFIG_FSL_DPAA_ETH_DEBUGFS
+	/* create debugfs entry for this net_device */
+	err = dpa_netdev_debugfs_create(net_dev);
+	if (err) {
+		unregister_netdev(net_dev);
+		return err;
+	}
+#endif /* CONFIG_FSL_DPAA_ETH_DEBUGFS */
+
 	return 0;
 }
 EXPORT_SYMBOL(dpa_netdev_init);
@@ -309,6 +321,11 @@ int dpa_remove(struct platform_device *pdev)
 	if (priv->buf_layout)
 		devm_kfree(dev, priv->buf_layout);
 
+#ifdef CONFIG_FSL_DPAA_ETH_DEBUGFS
+	/* remove debugfs entry for this net_device */
+	dpa_netdev_debugfs_remove(net_dev);
+#endif /* CONFIG_FSL_DPAA_ETH_DEBUGFS */
+
 	free_netdev(net_dev);
 
 	return err;
-- 
1.7.11.7
