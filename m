From: Daniel J Blueman <daniel@numascale.com>
Subject: [PATCH 1/2] PCI: Add mechanism to find topologically near cores
Date: Wed, 23 Dec 2015 18:01:40 +0800
Message-ID: <1450864901-16712-1-git-send-email-daniel@numascale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel J Blueman <daniel@numascale.com>,
	<intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Steffen Persvold <sp@numascale.com>,
	Jiang Liu <jiang.liu@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Bjorn Helgaas <bhelgaas@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some devices (eg ixgbe) make assumptions about device to core locality when
specifying interrupts locality hints and allocate starting from core 0.
Moreover, interrupts may not be routable to distant NUMA nodes due to the
8-bit APIC ID space limitations.

Provide a mechanism drivers can use to find cores with reasonable locality
to a device; use the existing precendent of RECLAIM_DISTANCE (30), wrapping
the offset.

Signed-off-by: Daniel J Blueman <daniel@numascale.com>
---
 drivers/pci/pci.c   | 15 +++++++++++++++
 include/linux/pci.h |  1 +
 2 files changed, 16 insertions(+)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 314db8c..d5535d1 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4833,6 +4833,22 @@ void __weak pci_fixup_cardbus(struct pci_bus *bus)
 }
 EXPORT_SYMBOL(pci_fixup_cardbus);

+int cpu_near_dev(const struct pci_dev *pdev, unsigned offset)
+{
+	/* Start search from node device is on for optimal locality */
+	int localnode = pcibus_to_node(pdev->bus);
+	int cpu = cpumask_first(cpumask_of_node(localnode));
+
+	while (offset--) {
+		do {
+			cpu = (cpu + 1) % nr_cpu_ids;
+		} while (!cpu_online(cpu) || node_distance(cpu_to_node(cpu),
+			localnode) > RECLAIM_DISTANCE);
+	}
+
+	return cpu;
+}
+
 static int __init pci_setup(char *str)
 {
 	while (str) {
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 6ae25aa..f7491bd 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -842,6 +842,7 @@ void pci_stop_root_bus(struct pci_bus *bus);
 void pci_remove_root_bus(struct pci_bus *bus);
 void pci_setup_cardbus(struct pci_bus *bus);
 void pci_sort_breadthfirst(void);
+int cpu_near_dev(const struct pci_dev *pdev, unsigned offset);
 #define dev_is_pci(d) ((d)->bus == &pci_bus_type)
 #define dev_is_pf(d) ((dev_is_pci(d) ? to_pci_dev(d)->is_physfn : false))
 #define dev_num_vf(d) ((dev_is_pci(d) ? pci_num_vf(to_pci_dev(d)) : 0))
--
2.5.0
