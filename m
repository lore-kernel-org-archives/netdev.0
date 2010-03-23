From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: add IntMode module parameter
Date: Mon, 22 Mar 2010 17:06:20 -0700
Message-ID: <20100323000519.19902.14802.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:57687
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752409Ab0CWAGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 20:06:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This patch adds the IntMode module parameter to igb. This
allows user selection of interrupt mode (MSI-X, MSI, legacy)
on driver load.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/Makefile    |    3 +
 drivers/net/igb/igb.h       |    7 ++
 drivers/net/igb/igb_main.c  |  125 ++++++++++++++++++++++++----------------
 drivers/net/igb/igb_param.c |  133 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 215 insertions(+), 53 deletions(-)
 create mode 100644 drivers/net/igb/igb_param.c

diff --git a/drivers/net/igb/Makefile b/drivers/net/igb/Makefile
index 8372cb9..049255e 100644
--- a/drivers/net/igb/Makefile
+++ b/drivers/net/igb/Makefile
@@ -33,5 +33,6 @@
 obj-$(CONFIG_IGB) += igb.o
 
 igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
-	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o
+	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o \
+	    igb_param.o
 
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index a177570..78a9c28 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -43,6 +43,11 @@ struct igb_adapter;
 /* ((1000000000ns / (6000ints/s * 1024ns)) << 2 = 648 */
 #define IGB_START_ITR 648
 
+/* Interrupt modes, as used by the IntMode paramter */
+#define IGB_INT_MODE_LEGACY                0
+#define IGB_INT_MODE_MSI                   1
+#define IGB_INT_MODE_MSIX                  2
+
 /* TX/RX descriptor defines */
 #define IGB_DEFAULT_TXD                  256
 #define IGB_MIN_TXD                       80
@@ -314,6 +319,7 @@ struct igb_adapter {
 	u16 rx_ring_count;
 	unsigned int vfs_allocated_count;
 	struct vf_data_storage *vf_data;
+	int int_mode;
 	u32 rss_queues;
 };
 
@@ -358,6 +364,7 @@ extern void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
 extern void igb_update_stats(struct igb_adapter *);
 extern bool igb_has_link(struct igb_adapter *adapter);
 extern void igb_set_ethtool_ops(struct net_device *);
+extern void igb_check_options(struct igb_adapter *);
 extern void igb_power_up_link(struct igb_adapter *);
 
 static inline s32 igb_reset_phy(struct e1000_hw *hw)
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 45a0e4f..83431e9 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -679,6 +679,7 @@ static void igb_clear_interrupt_scheme(struct igb_adapter *adapter)
  **/
 static void igb_set_interrupt_capability(struct igb_adapter *adapter)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	int err;
 	int numvecs, i;
 
@@ -686,60 +687,74 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter)
 	adapter->num_rx_queues = adapter->rss_queues;
 	adapter->num_tx_queues = adapter->rss_queues;
 
-	/* start with one vector for every rx queue */
-	numvecs = adapter->num_rx_queues;
-
-	/* if tx handler is separate add 1 for every tx queue */
-	if (!(adapter->flags & IGB_FLAG_QUEUE_PAIRS))
-		numvecs += adapter->num_tx_queues;
-
-	/* store the number of vectors reserved for queues */
-	adapter->num_q_vectors = numvecs;
-
-	/* add 1 vector for link status interrupts */
-	numvecs++;
-	adapter->msix_entries = kcalloc(numvecs, sizeof(struct msix_entry),
-					GFP_KERNEL);
-	if (!adapter->msix_entries)
-		goto msi_only;
-
-	for (i = 0; i < numvecs; i++)
-		adapter->msix_entries[i].entry = i;
-
-	err = pci_enable_msix(adapter->pdev,
-			      adapter->msix_entries,
-			      numvecs);
-	if (err == 0)
-		goto out;
-
-	igb_reset_interrupt_capability(adapter);
-
-	/* If we can't do MSI-X, try MSI */
-msi_only:
+	switch (adapter->int_mode) {
+	case IGB_INT_MODE_MSIX:
+		/* start with one vector for every rx queue */
+		numvecs = adapter->num_rx_queues;
+
+		/* if tx handler is seperate add 1 for every tx queue */
+		if (!(adapter->flags & IGB_FLAG_QUEUE_PAIRS))
+			numvecs += adapter->num_tx_queues;
+
+		/* store the number of vectors reserved for queues */
+		adapter->num_q_vectors = numvecs;
+
+		/* add 1 vecotr for link status interrupts */
+		numvecs++;
+		adapter->msix_entries = kcalloc(numvecs,
+		                                sizeof(struct msix_entry),
+		                                GFP_KERNEL);
+		if (adapter->msix_entries) {
+			for (i = 0; i < numvecs; i++)
+				adapter->msix_entries[i].entry = i;
+
+			err = pci_enable_msix(pdev,
+			                      adapter->msix_entries, numvecs);
+			if (err == 0)
+				break;
+		}
+		/* MSI-X failed, so fall through and try MSI */
+		dev_warn(&pdev->dev, "Failed to initialize MSI-X interrupts. "
+		         "Falling back to MSI interrupts.\n");
+		igb_reset_interrupt_capability(adapter);
+	case IGB_INT_MODE_MSI:
+		if (!pci_enable_msi(pdev))
+			adapter->flags |= IGB_FLAG_HAS_MSI;
+		else
+			dev_warn(&pdev->dev, "Failed to initialize MSI "
+			         "interrupts.  Falling back to legacy "
+			         "interrupts.\n");
+		/* Fall through */
+	case IGB_INT_MODE_LEGACY:
 #ifdef CONFIG_PCI_IOV
-	/* disable SR-IOV for non MSI-X configurations */
-	if (adapter->vf_data) {
-		struct e1000_hw *hw = &adapter->hw;
-		/* disable iov and allow time for transactions to clear */
-		pci_disable_sriov(adapter->pdev);
-		msleep(500);
-
-		kfree(adapter->vf_data);
-		adapter->vf_data = NULL;
-		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
-		msleep(100);
-		dev_info(&adapter->pdev->dev, "IOV Disabled\n");
-	}
+		/* disable SR-IOV for non MSI-X configurations */
+		if (adapter->vf_data) {
+			struct e1000_hw *hw = &adapter->hw;
+			/*
+			 *  disable iov and allow time for transactions
+			 *  to clear
+			*/
+			pci_disable_sriov(adapter->pdev);
+			msleep(500);
+
+			kfree(adapter->vf_data);
+			adapter->vf_data = NULL;
+			wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
+			msleep(100);
+			dev_info(&adapter->pdev->dev, "IOV Disabled\n");
+		}
 #endif
-	adapter->vfs_allocated_count = 0;
-	adapter->rss_queues = 1;
-	adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
-	adapter->num_rx_queues = 1;
-	adapter->num_tx_queues = 1;
-	adapter->num_q_vectors = 1;
-	if (!pci_enable_msi(adapter->pdev))
-		adapter->flags |= IGB_FLAG_HAS_MSI;
-out:
+		/* disable advanced features and set number of queues to 1 */
+		adapter->vfs_allocated_count = 0;
+		adapter->rss_queues = 1;
+		adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
+		adapter->num_rx_queues = 1;
+		adapter->num_tx_queues = 1;
+		adapter->num_q_vectors = 1;
+		/* Don't do anything; this is system default */
+		break;
+	}
+
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
 	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
 	return;
@@ -1411,6 +1426,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
 	int err, pci_using_dac;
+	static int cards_found;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
 
@@ -1477,6 +1493,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
+	adapter->bd_number = cards_found;
+
 	netdev->mem_start = mmio_start;
 	netdev->mem_end = mmio_start + mmio_len;
 
@@ -1675,6 +1693,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		(adapter->flags & IGB_FLAG_HAS_MSI) ? "MSI" : "legacy",
 		adapter->num_rx_queues, adapter->num_tx_queues);
 
+	cards_found++;
 	return 0;
 
 err_register:
@@ -1945,6 +1964,8 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
+	igb_check_options(adapter);
+
 #ifdef CONFIG_PCI_IOV
 	if (hw->mac.type == e1000_82576)
 		adapter->vfs_allocated_count = max_vfs;
diff --git a/drivers/net/igb/igb_param.c b/drivers/net/igb/igb_param.c
new file mode 100644
index 0000000..af9d07f
--- /dev/null
+++ b/drivers/net/igb/igb_param.c
@@ -0,0 +1,133 @@
+/*******************************************************************************
+
+  Intel(R) Gigabit Ethernet Linux driver
+  Copyright(c) 2007-2010 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+
+#include "igb.h"
+
+/*
+ * This is the only thing that needs to be changed to adjust the
+ * maximum number of ports that the driver can manage.
+ */
+
+#define IGB_MAX_NIC 32
+
+#define OPTION_UNSET   -1
+
+/*
+ * All parameters are treated the same, as an integer array of values.
+ * This macro just reduces the need to repeat the same declaration code
+ * over and over (plus this helps to avoid typo bugs).
+ */
+
+#define IGB_PARAM_INIT { [0 ... IGB_MAX_NIC] = OPTION_UNSET }
+#define IGB_PARAM(X, desc)					\
+	static int __devinitdata X[IGB_MAX_NIC+1]		\
+		= IGB_PARAM_INIT;				\
+	static unsigned int num_##X;				\
+	module_param_array_named(X, X, int, &num_##X, 0);	\
+	MODULE_PARM_DESC(X, desc);
+
+/* IntMode (Interrupt Mode)
+ *
+ * Valid Range: 0 - 2
+ *
+ * Default Value: 2 (MSI-X)
+ */
+IGB_PARAM(IntMode, "Interrupt Mode");
+#define MAX_INTMODE		IGB_INT_MODE_MSIX
+#define MIN_INTMODE		IGB_INT_MODE_LEGACY
+
+struct igb_option {
+	const char *name;
+	const char *err;
+	int def;
+	int min;
+	int max;
+};
+
+static int __devinit igb_validate_option(unsigned int *value,
+					   const struct igb_option *opt,
+					   struct igb_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+
+	if (*value == OPTION_UNSET) {
+		*value = opt->def;
+		return 0;
+	}
+
+	if (*value >= opt->min && *value <= opt->max) {
+		dev_info(&pdev->dev, "%s set to %d\n", opt->name, *value);
+		return 0;
+	} else {
+		dev_info(&pdev->dev, "Invalid %s value specified (%d) %s\n",
+		    opt->name, *value, opt->err);
+		*value = opt->def;
+		return -1;
+	}
+}
+
+/**
+ * igb_check_options - Range Checking for Command Line Parameters
+ * @adapter: board private structure
+ *
+ * This routine checks all command line parameters for valid user
+ * input.  If an invalid value is given, or if no user specified
+ * value exists, a default value is used.  The final value is stored
+ * in a variable in the adapter structure.
+ **/
+void __devinit igb_check_options(struct igb_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	int bd = adapter->bd_number;
+
+	if (bd >= IGB_MAX_NIC) {
+		dev_notice(&pdev->dev, "Warning: no configuration for "
+			   "board #%d\n", bd);
+		dev_notice(&pdev->dev, "Using defaults for all values\n");
+	}
+
+	{ /* Interrupt Mode */
+		struct igb_option opt = {
+			.name = "Interrupt Mode",
+			.err  = "defaulting to 2 (MSI-X)",
+			.def  = IGB_INT_MODE_MSIX,
+			.min = MIN_INTMODE,
+			.max = MAX_INTMODE
+		};
+
+		if (num_IntMode > bd) {
+			unsigned int int_mode = IntMode[bd];
+			igb_validate_option(&int_mode, &opt, adapter);
+			adapter->int_mode = int_mode;
+		} else {
+			adapter->int_mode = opt.def;
+		}
+	}
+}

