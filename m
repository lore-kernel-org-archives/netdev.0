From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 RFC PATCH] e1000e: NUMA changes, add Node= parameter
Date: Wed, 22 Sep 2010 20:28:10 -0700
Message-ID: <20100923032534.11274.77976.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.westchester.pa.mail.comcast.net ([76.96.59.228]:41437
	"EHLO qmta15.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751900Ab0IWD2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 23:28:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

NUMA changes associated with routing performance on 82571 and
x58/S5500 chipsets. Patch allows user to set new Node= parameter
that controls driver memory allocations for any port to a single
cpu/memory complex.  Since e1000e does not support multiple
queues this is a (relatively) simple implementation.

Although a module parameter is not the preferred way for
in-tree modules, this problem is not solvable in ethtool without
mod params because of needing the information at probe time to
control early allocations of memory.  Ideally there would even be
a way to control the node where the memory of the netdev struct
would be allocated also.

Special thanks to Emil Tantilov for testing, review and suggestions.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ethtool.c |    6 ++++--
 drivers/net/e1000e/netdev.c  |   41 ++++++++++++++++++++++++++++-------------
 drivers/net/e1000e/param.c   |   36 ++++++++++++++++++++++++++++++++++++
 4 files changed, 69 insertions(+), 15 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index f9a31c8..6378da7 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -370,6 +370,7 @@ struct e1000_adapter {
 	struct work_struct print_hang_task;
 
 	bool idle_check;
+	int node; /* store the node to allocate memory on */
 };
 
 struct e1000_info {
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 6355a1b..1f7fe31 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -690,7 +690,8 @@ static int e1000_set_ringparam(struct net_device *netdev,
 	rx_old = adapter->rx_ring;
 
 	err = -ENOMEM;
-	tx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	tx_ring = kzalloc_node(sizeof(struct e1000_ring), GFP_KERNEL,
+			       adapter->node);
 	if (!tx_ring)
 		goto err_alloc_tx;
 	/*
@@ -700,7 +701,8 @@ static int e1000_set_ringparam(struct net_device *netdev,
 	 */
 	memcpy(tx_ring, tx_old, sizeof(struct e1000_ring));
 
-	rx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	rx_ring = kzalloc_node(sizeof(struct e1000_ring), GFP_KERNEL,
+			       adapter->node);
 	if (!rx_ring)
 		goto err_alloc_rx;
 	memcpy(rx_ring, rx_old, sizeof(struct e1000_ring));
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e2c7e0d..0af7cf2 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -605,7 +605,8 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 				continue;
 			}
 			if (!ps_page->page) {
-				ps_page->page = alloc_page(GFP_ATOMIC);
+				ps_page->page = alloc_pages_node(adapter->node,
+								 GFP_ATOMIC, 0);
 				if (!ps_page->page) {
 					adapter->alloc_rx_buff_failed++;
 					goto no_buffers;
@@ -714,7 +715,8 @@ static void e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
 check_page:
 		/* allocate a new page if necessary */
 		if (!buffer_info->page) {
-			buffer_info->page = alloc_page(GFP_ATOMIC);
+			buffer_info->page = alloc_pages_node(adapter->node,
+							     GFP_ATOMIC, 0);
 			if (unlikely(!buffer_info->page)) {
 				adapter->alloc_rx_buff_failed++;
 				break;
@@ -1796,9 +1798,9 @@ void e1000e_set_interrupt_capability(struct e1000_adapter *adapter)
 	case E1000E_INT_MODE_MSIX:
 		if (adapter->flags & FLAG_HAS_MSIX) {
 			adapter->num_vectors = 3; /* RxQ0, TxQ0 and other */
-			adapter->msix_entries = kcalloc(adapter->num_vectors,
-						      sizeof(struct msix_entry),
-						      GFP_KERNEL);
+			adapter->msix_entries = kzalloc_node(adapter->num_vectors *
+						     sizeof(struct msix_entry),
+						     GFP_KERNEL, adapter->node);
 			if (adapter->msix_entries) {
 				for (i = 0; i < adapter->num_vectors; i++)
 					adapter->msix_entries[i].entry = i;
@@ -2038,13 +2040,23 @@ static int e1000_alloc_ring_dma(struct e1000_adapter *adapter,
 				struct e1000_ring *ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
+	int old_node = dev_to_node(&pdev->dev);
+	int retval = 0;
 
+	/*
+	 * must use set_dev_node here to work around the lack of a
+	 * dma_alloc_coherent_node function call
+	 */
+	if (adapter->node != -1)
+		set_dev_node(&pdev->dev, adapter->node);
 	ring->desc = dma_alloc_coherent(&pdev->dev, ring->size, &ring->dma,
 					GFP_KERNEL);
 	if (!ring->desc)
-		return -ENOMEM;
+		retval = -ENOMEM;
 
-	return 0;
+	if (adapter->node != -1)
+		set_dev_node(&pdev->dev, old_node);
+	return retval;
 }
 
 /**
@@ -2059,7 +2071,7 @@ int e1000e_setup_tx_resources(struct e1000_adapter *adapter)
 	int err = -ENOMEM, size;
 
 	size = sizeof(struct e1000_buffer) * tx_ring->count;
-	tx_ring->buffer_info = vmalloc(size);
+	tx_ring->buffer_info = vmalloc_node(size, adapter->node);
 	if (!tx_ring->buffer_info)
 		goto err;
 	memset(tx_ring->buffer_info, 0, size);
@@ -2095,16 +2107,16 @@ int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 	int i, size, desc_len, err = -ENOMEM;
 
 	size = sizeof(struct e1000_buffer) * rx_ring->count;
-	rx_ring->buffer_info = vmalloc(size);
+	rx_ring->buffer_info = vmalloc_node(size, adapter->node);
 	if (!rx_ring->buffer_info)
 		goto err;
 	memset(rx_ring->buffer_info, 0, size);
 
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
-		buffer_info->ps_pages = kcalloc(PS_PAGE_BUFFERS,
+		buffer_info->ps_pages = kzalloc_node(PS_PAGE_BUFFERS *
 						sizeof(struct e1000_ps_page),
-						GFP_KERNEL);
+						GFP_KERNEL, adapter->node);
 		if (!buffer_info->ps_pages)
 			goto err_pages;
 	}
@@ -2348,11 +2360,13 @@ set_itr_now:
  **/
 static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
 {
-	adapter->tx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	adapter->tx_ring = kzalloc_node(sizeof(struct e1000_ring), GFP_KERNEL,
+					adapter->node);
 	if (!adapter->tx_ring)
 		goto err;
 
-	adapter->rx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	adapter->rx_ring = kzalloc_node(sizeof(struct e1000_ring), GFP_KERNEL,
+					adapter->node);
 	if (!adapter->rx_ring)
 		goto err;
 
@@ -5594,6 +5608,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
 	hw = &adapter->hw;
+	adapter->node = -1;
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->ei = ei;
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 34aeec1..9351ab0 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -28,6 +28,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/pci.h>
+#include <linux/nodemask.h>
 
 #include "e1000.h"
 
@@ -161,6 +162,17 @@ E1000_PARAM(WriteProtectNVM, "Write-protect NVM [WARNING: disabling this can lea
 E1000_PARAM(CrcStripping, "Enable CRC Stripping, disable if your BMC needs " \
                           "the CRC");
 
+/* Enable node specific allocation of all data structures, typically
+ *  specific to routing setups, not generally useful.
+ *
+ *  Depends on: NUMA configuration
+ *
+ * Valid Range: -1 or 0 to (MAX_NUMNODES - 1)
+ *
+ * Default Value: -1 (disabled, default to kernel choice of node)
+ */
+E1000_PARAM(Node, "[ROUTING] Node to allocate memory on, default -1");
+
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
 	const char *name;
@@ -477,4 +489,28 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 			}
 		}
 	}
+	{ /* configure node specific allocation */
+		static struct e1000_option opt = {
+			.type = range_option,
+			.name = "Node used to allocate memory",
+			.err  = "defaulting to -1 (disabled)",
+			.def  = -1,
+			.arg  = { .r = { .min = 0,
+					 .max = MAX_NUMNODES - 1 } }
+		};
+		int node = opt.def;
+
+		if (num_Node > bd) {
+			node = Node[bd];
+			e1000_validate_option((uint *)&node, &opt, adapter);
+		}
+
+		/* check sanity of the value */
+		if ((node != -1) && !node_online(node)) {
+			e_info("ignoring node set to invalid value %d\n", node);
+			node = opt.def;
+		}
+
+		adapter->node = node;
+	}
 }

