From: Brice Goglin <brice@myri.com>
Subject: [PATCH 15/16] myri10ge: add Direct Cache Access support
Date: Fri, 09 May 2008 02:22:16 +0200
Message-ID: <48239938.6040002@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1900 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757128AbYEIAV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:21:56 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add I/O AT DCA (Direct Cache Access) support.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  146 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 145 insertions(+), 1 deletion(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:15:17.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:31:15.000000000 +0200
@@ -49,6 +49,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 #include <linux/inet_lro.h>
+#include <linux/dca.h>
 #include <linux/ip.h>
 #include <linux/inet.h>
 #include <linux/in.h>
@@ -185,6 +186,11 @@
 	dma_addr_t fw_stats_bus;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
+#ifdef CONFIG_DCA
+	int cached_dca_tag;
+	int cpu;
+	__be32 __iomem *dca_tag;
+#endif
 	char irq_desc[32];
 };
 
@@ -212,6 +218,9 @@
 	int msi_enabled;
 	int msix_enabled;
 	struct msix_entry *msix_vectors;
+#ifdef CONFIG_DCA
+	int dca_enabled;
+#endif
 	u32 link_state;
 	unsigned int rdma_tags_available;
 	int intr_coal_delay;
@@ -335,6 +344,10 @@
 module_param(myri10ge_rss_hash, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_rss_hash, "Type of RSS hashing to do");
 
+static int myri10ge_dca = 1;
+module_param(myri10ge_dca, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_dca, "Enable DCA if possible");
+
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
 (sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
@@ -878,6 +891,9 @@
 	struct myri10ge_slice_state *ss;
 	int i, status;
 	size_t bytes;
+#ifdef CONFIG_DCA
+	unsigned long dca_tag_off;
+#endif
 
 	/* try to send a reset command to the card to see if it
 	 * is alive */
@@ -970,6 +986,20 @@
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
+#ifdef CONFIG_DCA
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_DCA_OFFSET, &cmd, 0);
+	dca_tag_off = cmd.data0;
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		if (status == 0) {
+			ss->dca_tag = (__iomem __be32 *)
+			    (mgp->sram + dca_tag_off + 4 * i);
+		} else {
+			ss->dca_tag = NULL;
+		}
+	}
+#endif				/* CONFIG_DCA */
+
 	/* reset mcp/driver shared state back to 0 */
 
 	mgp->link_changes = 0;
@@ -995,6 +1025,77 @@
 	return status;
 }
 
+#ifdef CONFIG_DCA
+static void
+myri10ge_write_dca(struct myri10ge_slice_state *ss, int cpu, int tag)
+{
+	ss->cpu = cpu;
+	ss->cached_dca_tag = tag;
+	put_be32(htonl(tag), ss->dca_tag);
+}
+
+static inline void myri10ge_update_dca(struct myri10ge_slice_state *ss)
+{
+	int cpu = get_cpu();
+	int tag;
+
+	if (cpu != ss->cpu) {
+		tag = dca_get_tag(cpu);
+		if (ss->cached_dca_tag != tag)
+			myri10ge_write_dca(ss, cpu, tag);
+	}
+	put_cpu();
+}
+
+static void myri10ge_setup_dca(struct myri10ge_priv *mgp)
+{
+	int err, i;
+	struct pci_dev *pdev = mgp->pdev;
+
+	if (mgp->ss[0].dca_tag == NULL || mgp->dca_enabled)
+		return;
+	if (!myri10ge_dca) {
+		dev_err(&pdev->dev, "dca disabled by administrator\n");
+		return;
+	}
+	err = dca_add_requester(&pdev->dev);
+	if (err) {
+		dev_err(&pdev->dev,
+			"dca_add_requester() failed, err=%d\n", err);
+		return;
+	}
+	mgp->dca_enabled = 1;
+	for (i = 0; i < mgp->num_slices; i++)
+		myri10ge_write_dca(&mgp->ss[i], -1, 0);
+}
+
+static void myri10ge_teardown_dca(struct myri10ge_priv *mgp)
+{
+	struct pci_dev *pdev = mgp->pdev;
+	int err;
+
+	if (!mgp->dca_enabled)
+		return;
+	mgp->dca_enabled = 0;
+	err = dca_remove_requester(&pdev->dev);
+}
+
+static int myri10ge_notify_dca_device(struct device *dev, void *data)
+{
+	struct myri10ge_priv *mgp;
+	unsigned long event;
+
+	mgp = dev_get_drvdata(dev);
+	event = *(unsigned long *)data;
+
+	if (event == DCA_PROVIDER_ADD)
+		myri10ge_setup_dca(mgp);
+	else if (event == DCA_PROVIDER_REMOVE)
+		myri10ge_teardown_dca(mgp);
+	return 0;
+}
+#endif				/* CONFIG_DCA */
+
 static inline void
 myri10ge_submit_8rx(struct mcp_kreq_ether_recv __iomem * dst,
 		    struct mcp_kreq_ether_recv *src)
@@ -1362,6 +1463,11 @@
 	struct net_device *netdev = ss->mgp->dev;
 	int work_done;
 
+#ifdef CONFIG_DCA
+	if (ss->mgp->dca_enabled)
+		myri10ge_update_dca(ss);
+#endif
+
 	/* process as many rx events as NAPI will allow */
 	work_done = myri10ge_clean_rx_done(ss, budget);
 
@@ -1586,6 +1692,9 @@
 	"tx_boundary", "WC", "irq", "MSI", "MSIX",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "watchdog_resets",
+#ifdef CONFIG_DCA
+	"dca_capable", "dca_enabled",
+#endif
 	"link_changes", "link_up", "dropped_link_overflow",
 	"dropped_link_error_or_filtered",
 	"dropped_pause", "dropped_bad_phy", "dropped_bad_crc32",
@@ -1662,6 +1771,10 @@
 	data[i++] = (unsigned int)mgp->read_write_dma;
 	data[i++] = (unsigned int)mgp->serial_number;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
+#ifdef CONFIG_DCA
+	data[i++] = (unsigned int)(mgp->ss[0].dca_tag != NULL);
+	data[i++] = (unsigned int)(mgp->dca_enabled);
+#endif
 	data[i++] = (unsigned int)mgp->link_changes;
 
 	/* firmware stats are useful only in the first slice */
@@ -3687,7 +3800,9 @@
 		dev_err(&pdev->dev, "failed reset\n");
 		goto abort_with_slices;
 	}
-
+#ifdef CONFIG_DCA
+	myri10ge_setup_dca(mgp);
+#endif
 	pci_set_drvdata(pdev, mgp);
 	if ((myri10ge_initial_mtu + ETH_HLEN) > MYRI10GE_MAX_ETHER_MTU)
 		myri10ge_initial_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
@@ -3788,6 +3903,9 @@
 	netdev = mgp->dev;
 	unregister_netdev(netdev);
 
+#ifdef CONFIG_DCA
+	myri10ge_teardown_dca(mgp);
+#endif
 	myri10ge_dummy_rdma(mgp, 0);
 
 	/* avoid a memory leak */
@@ -3830,6 +3948,26 @@
 #endif
 };
 
+#ifdef CONFIG_DCA
+static int
+myri10ge_notify_dca(struct notifier_block *nb, unsigned long event, void *p)
+{
+	int err = driver_for_each_device(&myri10ge_driver.driver,
+					 NULL, &event,
+					 myri10ge_notify_dca_device);
+
+	if (err)
+		return NOTIFY_BAD;
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block myri10ge_dca_notifier = {
+	.notifier_call = myri10ge_notify_dca,
+	.next = NULL,
+	.priority = 0,
+};
+#endif				/* CONFIG_DCA */
+
 static __init int myri10ge_init_module(void)
 {
 	printk(KERN_INFO "%s: Version %s\n", myri10ge_driver.name,
@@ -3842,6 +3980,9 @@
 		       myri10ge_driver.name, myri10ge_rss_hash);
 		myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
 	}
+#ifdef CONFIG_DCA
+	dca_register_notify(&myri10ge_dca_notifier);
+#endif
 
 	return pci_register_driver(&myri10ge_driver);
 }
@@ -3850,6 +3991,9 @@
 
 static __exit void myri10ge_cleanup_module(void)
 {
+#ifdef CONFIG_DCA
+	dca_unregister_notify(&myri10ge_dca_notifier);
+#endif
 	pci_unregister_driver(&myri10ge_driver);
 }
 


