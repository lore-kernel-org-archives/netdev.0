From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 05/77] PCI/MSI: Convert pci_msix_table_size() to a public interface
Date: Wed,  2 Oct 2013 12:48:21 +0200
Message-ID: <e8b51bd48c24d0fc4ee8adea5c138c9bf84191e9.1380703262.git.agordeev@redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
        linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-devel@lists.sourceforge.ne
To: linux-kernel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <cover.1380703262.git.agordeev@redhat.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Make pci_msix_table_size() to return a error code if the device
does not support MSI-X. This update is needed to facilitate a
forthcoming re-design MSI/MSI-X interrupts enabling pattern.

Device drivers will use this interface to obtain maximum number
of MSI-X interrupts the device supports and use that value in
the following call to pci_enable_msix() interface.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 Documentation/PCI/MSI-HOWTO.txt |   13 +++++++++++++
 drivers/pci/msi.c               |    5 ++++-
 drivers/pci/pcie/portdrv_core.c |    2 ++
 3 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/Documentation/PCI/MSI-HOWTO.txt b/Documentation/PCI/MSI-HOWTO.txt
index a091780..35b2d64 100644
--- a/Documentation/PCI/MSI-HOWTO.txt
+++ b/Documentation/PCI/MSI-HOWTO.txt
@@ -255,6 +255,19 @@ MSI-X Table.  This address is mapped by the PCI subsystem, and should not
 be accessed directly by the device driver.  If the driver wishes to
 mask or unmask an interrupt, it should call disable_irq() / enable_irq().
 
+4.3.4 pci_msix_table_size
+
+int pci_msix_table_size(struct pci_dev *dev)
+
+This function could be used to retrieve number of entries in the device
+MSI-X table.
+
+If this function returns a negative number, it indicates the device is
+not capable of sending MSI-Xs.
+
+If this function returns a positive number, it indicates the maximum
+number of MSI-X interrupt vectors that could be allocated.
+
 4.4 Handling devices implementing both MSI and MSI-X capabilities
 
 If a device implements both MSI and MSI-X capabilities, it can
diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index b43f391..875c353 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -928,11 +928,12 @@ int pci_msix_table_size(struct pci_dev *dev)
 	u16 control;
 
 	if (!dev->msix_cap)
-		return 0;
+		return -EINVAL;
 
 	pci_read_config_word(dev, dev->msix_cap + PCI_MSIX_FLAGS, &control);
 	return msix_table_size(control);
 }
+EXPORT_SYMBOL(pci_msix_table_size);
 
 /**
  * pci_enable_msix - configure device's MSI-X capability structure
@@ -962,6 +963,8 @@ int pci_enable_msix(struct pci_dev *dev, struct msix_entry *entries, int nvec)
 		return status;
 
 	nr_entries = pci_msix_table_size(dev);
+	if (nr_entries < 0)
+		return nr_entries;
 	if (nvec > nr_entries)
 		return nr_entries;
 
diff --git a/drivers/pci/pcie/portdrv_core.c b/drivers/pci/pcie/portdrv_core.c
index 31063ac..b4d86eb 100644
--- a/drivers/pci/pcie/portdrv_core.c
+++ b/drivers/pci/pcie/portdrv_core.c
@@ -80,6 +80,8 @@ static int pcie_port_enable_msix(struct pci_dev *dev, int *vectors, int mask)
 	u32 reg32;
 
 	nr_entries = pci_msix_table_size(dev);
+	if (nr_entries < 0)
+		return nr_entries;
 	if (!nr_entries)
 		return -EINVAL;
 	if (nr_entries > PCIE_PORT_MAX_MSIX_ENTRIES)
-- 
1.7.7.6
