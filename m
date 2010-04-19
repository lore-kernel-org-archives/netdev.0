From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: add IntMode module parameter
Date: Sun, 18 Apr 2010 22:03:59 -0700
Message-ID: <20100419050315.24758.62479.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:40574
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750920Ab0DSFEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 01:04:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

The 82598 has an erratum where some system designs can increase the
likelihood of a system hang due to a PCIe resource contention between the
82598 and another device in legacy INTx mode.

This issue can happen in any number of configurations with the 82598
and another device in legacy interrupt mode.  While we know of a
specific case where this is happening, this can happen with other
devices as well if configured in a certain way depending on the
system's slot configuration among other things.  This is alos why we
need to have the flexibility to disable MSI-X interrupts for the 82598
when these configurations are found having this deadlock situation.

The errata being worked - around with this patch - has to do with
any type of device that has a pending legacy INTx to the IOH's
internal IOAPIC which has priority from the shared resources
(round-robin to ensure forward progress / fairness).  The internal
IOAPIC is a PCI-E endpoint hence transactions to it are viewed as
peer-to-peer from a shared resource perspective.  To make forward
progress on the legacy INTx, the outbound completion FIFOs for the
IOU (resource pool1) are checked for available space due to shared
resources.  The IOH is allowed to have in/out dependency as a root
is full and not making forward progress because the 82598 has entered
its "erratum window"  where the 82598 is throttling the release of posted
credits back to the IOH as it has pending MSI-X interrupts to the IOH.
The 82598 will only release the posted credits back to IOH after the
inbound posted writes are serviced and the IOH releases the posted
credits back to the 82598 (i.e., the 82598 in/out dependency
erratum).  Since the priority is on the other device's legacy INTx,
the 82598 inbound posted transaction cannot make forward progress
that results in a link/forward progress deadlock condition.

The 82598 Specification Update has the errata list and can be found
here, it's erratum 38:
http://www.intel.com/design/network/specupdt/321040.pdf

This patch adds the IntMode module parameter to ixgbe to allow
user selection of interrupt mode (MSI-X, MSI, legacy) on driver
load.  To work around the errata described above, ixgbe needs to
be able to disable MSI-X for affected configurations.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/Makefile      |    2 -
 drivers/net/ixgbe/ixgbe.h       |    1 
 drivers/net/ixgbe/ixgbe_main.c  |   26 ++++---
 drivers/net/ixgbe/ixgbe_param.c |  153 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 172 insertions(+), 10 deletions(-)
 create mode 100644 drivers/net/ixgbe/ixgbe_param.c

diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
index 8f81efb..820491f 100644
--- a/drivers/net/ixgbe/Makefile
+++ b/drivers/net/ixgbe/Makefile
@@ -34,7 +34,7 @@ obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
               ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
-              ixgbe_mbx.o
+              ixgbe_mbx.o ixgbe_param.o
 
 ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 79c35ae..106f197 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -436,6 +436,7 @@ extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
 extern char ixgbe_driver_name[];
 extern const char ixgbe_driver_version[];
 
+extern void ixgbe_check_options(struct ixgbe_adapter *adapter);
 extern int ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
 extern void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a98ff0e..d04e095 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3949,6 +3949,9 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	int err = 0;
 	int vector, v_budget;
 
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_CAPABLE))
+		goto try_msi;
+
 	/*
 	 * It's easy to be greedy for MSI-X vectors, but it really
 	 * doesn't do us much good if we have a lot more vectors
@@ -3981,16 +3984,10 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 			goto out;
 	}
 
-	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-	adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
-	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-	adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-	adapter->atr_sample_rate = 0;
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
-		ixgbe_disable_sriov(adapter);
-
-	ixgbe_set_num_queues(adapter);
 
+try_msi:
+	if (!(adapter->flags & IXGBE_FLAG_MSI_CAPABLE))
+		goto legacy;
 	err = pci_enable_msi(adapter->pdev);
 	if (!err) {
 		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
@@ -4000,7 +3997,16 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 		/* reset err */
 		err = 0;
 	}
+legacy:
+	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
+	adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+	adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+	adapter->atr_sample_rate = 0;
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		ixgbe_disable_sriov(adapter);
 
+	ixgbe_set_num_queues(adapter);
 out:
 	return err;
 }
@@ -6199,6 +6205,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_sw_init;
 	}
 
+	ixgbe_check_options(adapter);
+
 	ixgbe_probe_vf(adapter, ii);
 
 	netdev->features = NETIF_F_SG |
diff --git a/drivers/net/ixgbe/ixgbe_param.c b/drivers/net/ixgbe/ixgbe_param.c
new file mode 100644
index 0000000..98c5626
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_param.c
@@ -0,0 +1,153 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2010 Intel Corporation.
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
+#include <linux/types.h>
+#include <linux/module.h>
+
+#include "ixgbe.h"
+
+/* This is the only thing that needs to be changed to adjust the
+ * maximum number of ports that the driver can manage.
+ */
+
+#define IXGBE_MAX_NIC 32
+
+#define OPTION_UNSET    -1
+
+/* All parameters are treated the same, as an integer array of values.
+ * This macro just reduces the need to repeat the same declaration code
+ * over and over (plus this helps to avoid typo bugs).
+ */
+
+#define IXGBE_PARAM_INIT { [0 ... IXGBE_MAX_NIC] = OPTION_UNSET }
+#define IXGBE_PARAM(X, desc) \
+	static int __devinitdata X[IXGBE_MAX_NIC+1] = IXGBE_PARAM_INIT; \
+	static unsigned int num_##X; \
+	module_param_array_named(X, X, int, &num_##X, 0); \
+	MODULE_PARM_DESC(X, desc);
+
+/* IntMode (Interrupt Mode)
+ *
+ * Valid Range: 0-2
+ *  - 0 - Legacy Interrupt
+ *  - 1 - MSI Interrupt
+ *  - 2 - MSI-X Interrupt(s)
+ *
+ * Default Value: 2
+ */
+IXGBE_PARAM(IntMode, "Change Interrupt Mode (0=Legacy, 1=MSI, 2=MSI-X), default 2");
+#define IXGBE_INT_LEGACY		      0
+#define IXGBE_INT_MSI			      1
+#define IXGBE_INT_MSIX			      2
+#define IXGBE_DEFAULT_INT	 IXGBE_INT_MSIX
+
+struct ixgbe_option {
+	const char *name;
+	const char *err;
+	int def;
+	int min;
+	int max;
+};
+
+static int __devinit ixgbe_validate_option(unsigned int *value,
+					   struct ixgbe_option *opt,
+					   struct ixgbe_adapter *adapter)
+{
+	if (*value == OPTION_UNSET) {
+		*value = opt->def;
+		return 0;
+	}
+
+	if (*value >= opt->min && *value <= opt->max) {
+		dev_info(&adapter->pdev->dev,
+			 "%s set to %d\n", opt->name, *value);
+		return 0;
+	} else {
+		dev_info(&adapter->pdev->dev,
+			 "Invalid %s specified (%d),  %s\n",
+			 opt->name, *value, opt->err);
+		*value = opt->def;
+		return -1;
+	}
+}
+
+/**
+ * ixgbe_check_options - Range Checking for Command Line Parameters
+ * @adapter: board private structure
+ *
+ * This routine checks all command line parameters for valid user
+ * input.  If an invalid value is given, or if no user specified
+ * value exists, a default value is used.  The final value is stored
+ * in a variable in the adapter structure.
+ **/
+void __devinit ixgbe_check_options(struct ixgbe_adapter *adapter)
+{
+	int bd = adapter->bd_number;
+	u32 *aflags = &adapter->flags;
+
+	if (bd >= IXGBE_MAX_NIC) {
+		dev_notice(&adapter->pdev->dev,
+			   "Warning: no configuration for board #%d\n", bd);
+		dev_notice(&adapter->pdev->dev,
+			   "Using defaults for all values\n");
+	}
+
+	{ /* Interrupt Mode */
+		unsigned int int_mode;
+		static struct ixgbe_option opt = {
+			.name = "Interrupt Mode",
+			.err =
+			  "using default of "__MODULE_STRING(IXGBE_DEFAULT_INT),
+			.def = IXGBE_DEFAULT_INT,
+			.min = IXGBE_INT_LEGACY,
+			.max = IXGBE_INT_MSIX
+		};
+
+		if (num_IntMode > bd) {
+			int_mode = IntMode[bd];
+			ixgbe_validate_option(&int_mode, &opt, adapter);
+			switch (int_mode) {
+			case IXGBE_INT_MSIX:
+				*aflags |= IXGBE_FLAG_MSIX_CAPABLE;
+				*aflags |= IXGBE_FLAG_MSI_CAPABLE;
+				break;
+			case IXGBE_INT_MSI:
+				*aflags &= ~IXGBE_FLAG_MSIX_CAPABLE;
+				*aflags |= IXGBE_FLAG_MSI_CAPABLE;
+				break;
+			case IXGBE_INT_LEGACY:
+			default:
+				*aflags &= ~IXGBE_FLAG_MSIX_CAPABLE;
+				*aflags &= ~IXGBE_FLAG_MSI_CAPABLE;
+				break;
+			}
+		} else {
+			*aflags |= IXGBE_FLAG_MSIX_CAPABLE;
+			*aflags |= IXGBE_FLAG_MSI_CAPABLE;
+		}
+	}
+}

