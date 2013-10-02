From: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC 07/77] PCI/MSI: Re-design MSI/MSI-X interrupts enablement pattern
Date: Wed,  2 Oct 2013 12:48:23 +0200
Message-ID: <d8c36203ada6efbfa9f7ce92c2f713ee3b6d6b8d.1380703262.git.agordeev@redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andy King <acking-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, Jon Mason <jon.mason-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Matt Porter <mporter-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iss_storagedev-VXdhtT5mjnY@public.gmane.org,
	linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	Solarflare linux maintainers <linux-net-drivers@
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1380703262.git.agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently pci_enable_msi_block() and pci_enable_msix() interfaces
return a error code in case of failure, 0 in case of success and a
positive value which indicates the number of MSI-X/MSI interrupts
that could have been allocated. The latter value should be passed
to a repeated call to the interfaces until a failure or success.

This technique proved to be confusing and error-prone. Vast share
of device drivers simply fail to follow the described guidelines.

This update converts pci_enable_msix() and pci_enable_msi_block()
interfaces to canonical kernel functions and makes them return a
error code in case of failure or 0 in case of success.

As result, device drivers will cease to use the overcomplicated
repeated fallbacks technique and resort to a straightforward
pattern - determine the number of MSI/MSI-X interrupts required
before calling pci_enable_msix() and pci_enable_msi_block()
interfaces.

Device drivers will use their knowledge of underlying hardware
to determine the number of MSI/MSI-X interrupts required.

The simplest case would be requesting all available interrupts -
to obtain that value device drivers will use pci_get_msi_cap()
interface for MSI and pci_msix_table_size() for MSI-X.

More complex cases would entail matching device capabilities
with the system environment, i.e. limiting number of hardware
queues (and hence associated MSI/MSI-X interrupts) to the number
of online CPUs.

Suggested-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 Documentation/PCI/MSI-HOWTO.txt      |   71 ++++++++++++++++++---------------
 arch/mips/pci/msi-octeon.c           |    2 +-
 arch/powerpc/kernel/msi.c            |    2 +-
 arch/powerpc/platforms/pseries/msi.c |    2 +-
 arch/s390/pci/pci.c                  |    2 +-
 arch/x86/kernel/apic/io_apic.c       |    2 +-
 drivers/pci/msi.c                    |   52 +++++++------------------
 7 files changed, 58 insertions(+), 75 deletions(-)

diff --git a/Documentation/PCI/MSI-HOWTO.txt b/Documentation/PCI/MSI-HOWTO.txt
index 1f37ce2..40abcfb 100644
--- a/Documentation/PCI/MSI-HOWTO.txt
+++ b/Documentation/PCI/MSI-HOWTO.txt
@@ -111,21 +111,27 @@ the device are in the range dev->irq to dev->irq + count - 1.
 
 If this function returns a negative number, it indicates an error and
 the driver should not attempt to request any more MSI interrupts for
-this device.  If this function returns a positive number, it is
-less than 'count' and indicates the number of interrupts that could have
-been allocated.  In neither case is the irq value updated or the device
-switched into MSI mode.
-
-The device driver must decide what action to take if
-pci_enable_msi_block() returns a value less than the number requested.
-For instance, the driver could still make use of fewer interrupts;
-in this case the driver should call pci_enable_msi_block()
-again.  Note that it is not guaranteed to succeed, even when the
-'count' has been reduced to the value returned from a previous call to
-pci_enable_msi_block().  This is because there are multiple constraints
-on the number of vectors that can be allocated; pci_enable_msi_block()
-returns as soon as it finds any constraint that doesn't allow the
-call to succeed.
+this device.
+
+Device drivers should normally call pci_get_msi_cap() function before
+calling this function to determine maximum number of MSI interrupts
+a device can send.
+
+A sequence to achieve that might look like:
+
+static int foo_driver_enable_msi(struct foo_adapter *adapter, int nvec)
+{
+	rc = pci_get_msi_cap(adapter->pdev);
+	if (rc < 0)
+		return rc;
+
+	nvec = min(nvec, rc);
+	if (nvec < FOO_DRIVER_MINIMUM_NVEC) {
+		return -ENOSPC;
+
+	rc = pci_enable_msi_block(adapter->pdev, nvec);
+	return rc;
+}
 
 4.2.3 pci_enable_msi_block_auto
 
@@ -218,9 +224,7 @@ interrupts assigned to the MSI-X vectors so it can free them again later.
 
 If this function returns a negative number, it indicates an error and
 the driver should not attempt to allocate any more MSI-X interrupts for
-this device.  If it returns a positive number, it indicates the maximum
-number of interrupt vectors that could have been allocated. See example
-below.
+this device.
 
 This function, in contrast with pci_enable_msi(), does not adjust
 dev->irq.  The device will not generate interrupts for this interrupt
@@ -229,24 +233,27 @@ number once MSI-X is enabled.
 Device drivers should normally call this function once per device
 during the initialization phase.
 
-It is ideal if drivers can cope with a variable number of MSI-X interrupts;
-there are many reasons why the platform may not be able to provide the
-exact number that a driver asks for.
+Device drivers should normally call pci_msix_table_size() function before
+calling this function to determine maximum number of MSI-X interrupts
+a device can send.
 
-A request loop to achieve that might look like:
+A sequence to achieve that might look like:
 
 static int foo_driver_enable_msix(struct foo_adapter *adapter, int nvec)
 {
-	while (nvec >= FOO_DRIVER_MINIMUM_NVEC) {
-		rc = pci_enable_msix(adapter->pdev,
-				     adapter->msix_entries, nvec);
-		if (rc > 0)
-			nvec = rc;
-		else
-			return rc;
-	}
-
-	return -ENOSPC;
+	rc = pci_msix_table_size(adapter->pdev);
+	if (rc < 0)
+		return rc;
+
+	nvec = min(nvec, rc);
+	if (nvec < FOO_DRIVER_MINIMUM_NVEC) {
+		return -ENOSPC;
+
+	for (i = 0; i < nvec; i++)
+		adapter->msix_entries[i].entry = i;
+
+	rc = pci_enable_msix(adapter->pdev, adapter->msix_entries, nvec);
+	return rc;
 }
 
 4.3.2 pci_disable_msix
diff --git a/arch/mips/pci/msi-octeon.c b/arch/mips/pci/msi-octeon.c
index d37be36..0ee5f4d 100644
--- a/arch/mips/pci/msi-octeon.c
+++ b/arch/mips/pci/msi-octeon.c
@@ -193,7 +193,7 @@ int arch_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 	 * override arch_setup_msi_irqs()
 	 */
 	if (type == PCI_CAP_ID_MSI && nvec > 1)
-		return 1;
+		return -EINVAL;
 
 	list_for_each_entry(entry, &dev->msi_list, list) {
 		ret = arch_setup_msi_irq(dev, entry);
diff --git a/arch/powerpc/kernel/msi.c b/arch/powerpc/kernel/msi.c
index 8bbc12d..36d70b9 100644
--- a/arch/powerpc/kernel/msi.c
+++ b/arch/powerpc/kernel/msi.c
@@ -22,7 +22,7 @@ int arch_msi_check_device(struct pci_dev* dev, int nvec, int type)
 
 	/* PowerPC doesn't support multiple MSI yet */
 	if (type == PCI_CAP_ID_MSI && nvec > 1)
-		return 1;
+		return -EINVAL;
 
 	if (ppc_md.msi_check_device) {
 		pr_debug("msi: Using platform check routine.\n");
diff --git a/arch/powerpc/platforms/pseries/msi.c b/arch/powerpc/platforms/pseries/msi.c
index 009ec73..89648c1 100644
--- a/arch/powerpc/platforms/pseries/msi.c
+++ b/arch/powerpc/platforms/pseries/msi.c
@@ -348,7 +348,7 @@ static int rtas_msi_check_device(struct pci_dev *pdev, int nvec, int type)
 	quota = msi_quota_for_device(pdev, nvec);
 
 	if (quota && quota < nvec)
-		return quota;
+		return -ENOSPC;
 
 	return 0;
 }
diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
index 61a3c2c..45a1875 100644
--- a/arch/s390/pci/pci.c
+++ b/arch/s390/pci/pci.c
@@ -426,7 +426,7 @@ int arch_setup_msi_irqs(struct pci_dev *pdev, int nvec, int type)
 
 	pr_debug("%s: requesting %d MSI-X interrupts...", __func__, nvec);
 	if (type == PCI_CAP_ID_MSI && nvec > 1)
-		return 1;
+		return -EINVAL;
 	msi_vecs = min(nvec, ZPCI_MSI_VEC_MAX);
 	msi_vecs = min_t(unsigned int, msi_vecs, CONFIG_PCI_NR_MSI);
 
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index e63a5bd..6126eaf 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -3145,7 +3145,7 @@ int native_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 
 	/* Multiple MSI vectors only supported with interrupt remapping */
 	if (type == PCI_CAP_ID_MSI && nvec > 1)
-		return 1;
+		return -EINVAL;
 
 	node = dev_to_node(&dev->dev);
 	irq_want = nr_irqs_gsi;
diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index ca59bfc..583ace1 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -719,7 +719,7 @@ static int msix_capability_init(struct pci_dev *dev,
 
 	ret = arch_setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSIX);
 	if (ret)
-		goto out_avail;
+		goto error;
 
 	/*
 	 * Some devices require MSI-X to be enabled before we can touch the
@@ -733,7 +733,7 @@ static int msix_capability_init(struct pci_dev *dev,
 
 	ret = populate_msi_sysfs(dev);
 	if (ret)
-		goto out_free;
+		goto error;
 
 	/* Set MSI-X enabled bits and unmask the function */
 	pci_intx_for_msi(dev, 0);
@@ -744,24 +744,7 @@ static int msix_capability_init(struct pci_dev *dev,
 
 	return 0;
 
-out_avail:
-	if (ret < 0) {
-		/*
-		 * If we had some success, report the number of irqs
-		 * we succeeded in setting up.
-		 */
-		struct msi_desc *entry;
-		int avail = 0;
-
-		list_for_each_entry(entry, &dev->msi_list, list) {
-			if (entry->irq != 0)
-				avail++;
-		}
-		if (avail != 0)
-			ret = avail;
-	}
-
-out_free:
+error:
 	free_msi_irqs(dev);
 
 	return ret;
@@ -832,13 +815,11 @@ EXPORT_SYMBOL(pci_get_msi_cap);
  * @dev: device to configure
  * @nvec: number of interrupts to configure
  *
- * Allocate IRQs for a device with the MSI capability.
- * This function returns a negative errno if an error occurs.  If it
- * is unable to allocate the number of interrupts requested, it returns
- * the number of interrupts it might be able to allocate.  If it successfully
- * allocates at least the number of interrupts requested, it returns 0 and
- * updates the @dev's irq member to the lowest new interrupt number; the
- * other interrupt numbers allocated to this device are consecutive.
+ * Allocate IRQs for a device with the MSI capability. This function returns
+ * a negative errno if an error occurs. If it successfully allocates at least
+ * the number of interrupts requested, it returns 0 and updates the @dev's
+ * irq member to the lowest new interrupt number; the other interrupt numbers
+ * allocated to this device are consecutive.
  */
 int pci_enable_msi_block(struct pci_dev *dev, unsigned int nvec)
 {
@@ -848,7 +829,7 @@ int pci_enable_msi_block(struct pci_dev *dev, unsigned int nvec)
 	if (maxvec < 0)
 		return maxvec;
 	if (nvec > maxvec)
-		return maxvec;
+		return -EINVAL;
 
 	status = pci_msi_check_device(dev, nvec, PCI_CAP_ID_MSI);
 	if (status)
@@ -879,13 +860,11 @@ int pci_enable_msi_block_auto(struct pci_dev *dev, unsigned int *maxvec)
 	if (maxvec)
 		*maxvec = ret;
 
-	do {
-		nvec = ret;
-		ret = pci_enable_msi_block(dev, nvec);
-	} while (ret > 0);
-
-	if (ret < 0)
+	nvec = ret;
+	ret = pci_enable_msi_block(dev, nvec);
+	if (ret)
 		return ret;
+
 	return nvec;
 }
 EXPORT_SYMBOL(pci_enable_msi_block_auto);
@@ -955,9 +934,6 @@ EXPORT_SYMBOL(pci_msix_table_size);
  * MSI-X mode enabled on its hardware device function. A return of zero
  * indicates the successful configuration of MSI-X capability structure
  * with new allocated MSI-X irqs. A return of < 0 indicates a failure.
- * Or a return of > 0 indicates that driver request is exceeding the number
- * of irqs or MSI-X vectors available. Driver should use the returned value to
- * re-send its request.
  **/
 int pci_enable_msix(struct pci_dev *dev, struct msix_entry *entries, int nvec)
 {
@@ -975,7 +951,7 @@ int pci_enable_msix(struct pci_dev *dev, struct msix_entry *entries, int nvec)
 	if (nr_entries < 0)
 		return nr_entries;
 	if (nvec > nr_entries)
-		return nr_entries;
+		return -EINVAL;
 
 	/* Check for any invalid entries */
 	for (i = 0; i < nvec; i++) {
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
