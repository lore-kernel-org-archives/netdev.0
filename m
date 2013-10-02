From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 08/77] PCI/MSI: Get rid of pci_enable_msi_block_auto() interface
Date: Wed,  2 Oct 2013 12:48:24 +0200
Message-ID: <ea66a0ceb82b83b4fd78410a32bdbb1f5e54b4d0.1380703262.git.agordeev@redhat.com>
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

As result of recent re-design of MSI/MSI-X interrupts enabling
pattern pci_enable_msi_block_auto() interface became obsolete.

To enable maximum number of MSI interrupts for a device the
driver will first obtain that number from pci_get_msi_cap()
function and then call pci_enable_msi_block() interface.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 Documentation/PCI/MSI-HOWTO.txt |   30 ++----------------------------
 drivers/pci/msi.c               |   20 --------------------
 include/linux/pci.h             |    7 -------
 3 files changed, 2 insertions(+), 55 deletions(-)

diff --git a/Documentation/PCI/MSI-HOWTO.txt b/Documentation/PCI/MSI-HOWTO.txt
index 40abcfb..4d0525f 100644
--- a/Documentation/PCI/MSI-HOWTO.txt
+++ b/Documentation/PCI/MSI-HOWTO.txt
@@ -133,33 +133,7 @@ static int foo_driver_enable_msi(struct foo_adapter *adapter, int nvec)
 	return rc;
 }
 
-4.2.3 pci_enable_msi_block_auto
-
-int pci_enable_msi_block_auto(struct pci_dev *dev, unsigned int *count)
-
-This variation on pci_enable_msi() call allows a device driver to request
-the maximum possible number of MSIs.  The MSI specification only allows
-interrupts to be allocated in powers of two, up to a maximum of 2^5 (32).
-
-If this function returns a positive number, it indicates that it has
-succeeded and the returned value is the number of allocated interrupts. In
-this case, the function enables MSI on this device and updates dev->irq to
-be the lowest of the new interrupts assigned to it.  The other interrupts
-assigned to the device are in the range dev->irq to dev->irq + returned
-value - 1.
-
-If this function returns a negative number, it indicates an error and
-the driver should not attempt to request any more MSI interrupts for
-this device.
-
-If the device driver needs to know the number of interrupts the device
-supports it can pass the pointer count where that number is stored. The
-device driver must decide what action to take if pci_enable_msi_block_auto()
-succeeds, but returns a value less than the number of interrupts supported.
-If the device driver does not need to know the number of interrupts
-supported, it can set the pointer count to NULL.
-
-4.2.4 pci_disable_msi
+4.2.3 pci_disable_msi
 
 void pci_disable_msi(struct pci_dev *dev)
 
@@ -175,7 +149,7 @@ on any interrupt for which it previously called request_irq().
 Failure to do so results in a BUG_ON(), leaving the device with
 MSI enabled and thus leaking its vector.
 
-4.2.5 pci_get_msi_cap
+4.2.4 pci_get_msi_cap
 
 int pci_get_msi_cap(struct pci_dev *dev)
 
diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 583ace1..1934519 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -849,26 +849,6 @@ int pci_enable_msi_block(struct pci_dev *dev, unsigned int nvec)
 }
 EXPORT_SYMBOL(pci_enable_msi_block);
 
-int pci_enable_msi_block_auto(struct pci_dev *dev, unsigned int *maxvec)
-{
-	int ret, nvec;
-
-	ret = pci_get_msi_cap(dev);
-	if (ret < 0)
-		return ret;
-
-	if (maxvec)
-		*maxvec = ret;
-
-	nvec = ret;
-	ret = pci_enable_msi_block(dev, nvec);
-	if (ret)
-		return ret;
-
-	return nvec;
-}
-EXPORT_SYMBOL(pci_enable_msi_block_auto);
-
 void pci_msi_shutdown(struct pci_dev *dev)
 {
 	struct msi_desc *desc;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 2fa92ef..13bf88d 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1154,12 +1154,6 @@ static inline int pci_enable_msi_block(struct pci_dev *dev, unsigned int nvec)
 	return -1;
 }
 
-static inline int
-pci_enable_msi_block_auto(struct pci_dev *dev, unsigned int *maxvec)
-{
-	return -1;
-}
-
 static inline void pci_msi_shutdown(struct pci_dev *dev)
 { }
 static inline void pci_disable_msi(struct pci_dev *dev)
@@ -1192,7 +1186,6 @@ static inline int pci_msi_enabled(void)
 #else
 int pci_get_msi_cap(struct pci_dev *dev);
 int pci_enable_msi_block(struct pci_dev *dev, unsigned int nvec);
-int pci_enable_msi_block_auto(struct pci_dev *dev, unsigned int *maxvec);
 void pci_msi_shutdown(struct pci_dev *dev);
 void pci_disable_msi(struct pci_dev *dev);
 int pci_msix_table_size(struct pci_dev *dev);
-- 
1.7.7.6
