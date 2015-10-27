From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next] enic: assign affinity hint to interrupts
Date: Tue, 27 Oct 2015 23:28:42 +0530
Message-ID: <1445968722-29523-1-git-send-email-_govind@gmx.com>
Cc: benve@cisco.com, ssujith@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:64873 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754663AbbJ0R7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 13:59:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The affinity hint is used by the user space daemon, irqbalancer, to
indicate a preferred CPU mask for irqs. This patch sets the irq affinity
hint to local numa core first, when exhausted we try non-local numa cores.

Introduce enic module global variable enic_numa_count[] to store the
number of affinity_hints set. If there are more than one enic interfaces,
we do not want them to share same affinity hint cpus. We store the
history of affinity hint assignment of all interfaces in global variable
enic_numa_count. Introduce enic_affinity_hint spinlock to access
enic_numa_count.

Also set tx xps cpus mask based on affinity hint.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      | 27 ++++++++++
 drivers/net/ethernet/cisco/enic/enic_main.c | 81 +++++++++++++++++++++++++++++
 2 files changed, 108 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 6401ba99..1671fa3 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -50,6 +50,7 @@ struct enic_msix_entry {
 	char devname[IFNAMSIZ];
 	irqreturn_t (*isr)(int, void *);
 	void *devid;
+	cpumask_var_t affinity_mask;
 };
 
 /* Store only the lower range.  Higher range is given by fw. */
@@ -263,6 +264,32 @@ static inline unsigned int enic_msix_notify_intr(struct enic *enic)
 	return enic->rq_count + enic->wq_count + 1;
 }
 
+static inline bool enic_is_err_intr(struct enic *enic, int intr)
+{
+	switch (vnic_dev_get_intr_mode(enic->vdev)) {
+	case VNIC_DEV_INTR_MODE_INTX:
+		return intr == enic_legacy_err_intr();
+	case VNIC_DEV_INTR_MODE_MSIX:
+		return intr == enic_msix_err_intr(enic);
+	case VNIC_DEV_INTR_MODE_MSI:
+	default:
+		return false;
+	}
+}
+
+static inline bool enic_is_notify_intr(struct enic *enic, int intr)
+{
+	switch (vnic_dev_get_intr_mode(enic->vdev)) {
+	case VNIC_DEV_INTR_MODE_INTX:
+		return intr == enic_legacy_notify_intr();
+	case VNIC_DEV_INTR_MODE_MSIX:
+		return intr == enic_msix_notify_intr(enic);
+	case VNIC_DEV_INTR_MODE_MSI:
+	default:
+		return false;
+	}
+}
+
 static inline int enic_dma_map_check(struct enic *enic, dma_addr_t dma_addr)
 {
 	if (unlikely(pci_dma_mapping_error(enic->pdev, dma_addr))) {
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 0c22fd0..c39e495 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -39,6 +39,7 @@
 #include <linux/prefetch.h>
 #include <net/ip6_checksum.h>
 #include <linux/ktime.h>
+#include <linux/numa.h>
 #ifdef CONFIG_RFS_ACCEL
 #include <linux/cpu_rmap.h>
 #endif
@@ -69,6 +70,9 @@
 
 #define RX_COPYBREAK_DEFAULT		256
 
+static int enic_numa_count[MAX_NUMNODES];
+DEFINE_SPINLOCK(enic_affinity_hint);
+
 /* Supported devices */
 static const struct pci_device_id enic_id_table[] = {
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET) },
@@ -112,6 +116,77 @@ static struct enic_intr_mod_range mod_range[ENIC_MAX_LINK_SPEEDS] = {
 	{3,  6}, /* 10 - 40 Gbps */
 };
 
+static void enic_init_affinity_hint(struct enic *enic)
+{
+	int numa_node = dev_to_node(&enic->pdev->dev);
+	int numa_idx = numa_node == -1 ? 0 : numa_node;
+	int index;
+	int i;
+
+	spin_lock(&enic_affinity_hint);
+	for (i = 0; i < enic->intr_count; i++) {
+		if (enic_is_err_intr(enic, i) || enic_is_notify_intr(enic, i) ||
+		    (enic->msix[i].affinity_mask &&
+		     !cpumask_empty(enic->msix[i].affinity_mask)))
+			continue;
+		if (zalloc_cpumask_var(&enic->msix[i].affinity_mask,
+				       GFP_KERNEL)) {
+			index = enic_numa_count[numa_idx]++;
+			cpumask_set_cpu(cpumask_local_spread(index, numa_node),
+					enic->msix[i].affinity_mask);
+		}
+	}
+	spin_unlock(&enic_affinity_hint);
+}
+
+static void enic_free_affinity_hint(struct enic *enic)
+{
+	int i;
+
+	for (i = 0; i < enic->intr_count; i++) {
+		if (enic_is_err_intr(enic, i) || enic_is_notify_intr(enic, i))
+			continue;
+		free_cpumask_var(enic->msix[i].affinity_mask);
+	}
+}
+
+static void enic_set_affinity_hint(struct enic *enic)
+{
+	int i;
+	int err;
+
+	for (i = 0; i < enic->intr_count; i++) {
+		if (enic_is_err_intr(enic, i)		||
+		    enic_is_notify_intr(enic, i)	||
+		    !enic->msix[i].affinity_mask	||
+		    cpumask_empty(enic->msix[i].affinity_mask))
+			continue;
+		err = irq_set_affinity_hint(enic->msix_entry[i].vector,
+					    enic->msix[i].affinity_mask);
+		if (err)
+			netdev_warn(enic->netdev, "irq_set_affinity_hint failed, err %d\n",
+				    err);
+	}
+
+	for (i = 0; i < enic->wq_count; i++) {
+		int wq_intr = enic_msix_wq_intr(enic, i);
+
+		if (enic->msix[wq_intr].affinity_mask &&
+		    !cpumask_empty(enic->msix[wq_intr].affinity_mask))
+			netif_set_xps_queue(enic->netdev,
+					    enic->msix[wq_intr].affinity_mask,
+					    i);
+	}
+}
+
+static void enic_unset_affinity_hint(struct enic *enic)
+{
+	int i;
+
+	for (i = 0; i < enic->intr_count; i++)
+		irq_set_affinity_hint(enic->msix_entry[i].vector, NULL);
+}
+
 int enic_is_dynamic(struct enic *enic)
 {
 	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_DYN;
@@ -1649,6 +1724,8 @@ static int enic_open(struct net_device *netdev)
 		netdev_err(netdev, "Unable to request irq.\n");
 		return err;
 	}
+	enic_init_affinity_hint(enic);
+	enic_set_affinity_hint(enic);
 
 	err = enic_dev_notify_set(enic);
 	if (err) {
@@ -1701,6 +1778,7 @@ err_out_free_rq:
 		vnic_rq_clean(&enic->rq[i], enic_free_rq_buf);
 	enic_dev_notify_unset(enic);
 err_out_free_intr:
+	enic_unset_affinity_hint(enic);
 	enic_free_intr(enic);
 
 	return err;
@@ -1754,6 +1832,7 @@ static int enic_stop(struct net_device *netdev)
 	}
 
 	enic_dev_notify_unset(enic);
+	enic_unset_affinity_hint(enic);
 	enic_free_intr(enic);
 
 	for (i = 0; i < enic->wq_count; i++)
@@ -2309,6 +2388,7 @@ static void enic_dev_deinit(struct enic *enic)
 
 	enic_free_vnic_resources(enic);
 	enic_clear_intr_mode(enic);
+	enic_free_affinity_hint(enic);
 }
 
 static void enic_kdump_kernel_config(struct enic *enic)
@@ -2404,6 +2484,7 @@ static int enic_dev_init(struct enic *enic)
 	return 0;
 
 err_out_free_vnic_resources:
+	enic_free_affinity_hint(enic);
 	enic_clear_intr_mode(enic);
 	enic_free_vnic_resources(enic);
 
-- 
2.6.2
