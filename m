From: Mark D Rustad <mark.d.rustad@intel.com>
Subject: [PATCH] pci: Use a bus-global mutex to protect VPD operations
Date: Mon, 18 May 2015 17:00:37 -0700
Message-ID: <20150519000037.56109.68356.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39489 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755271AbbESAAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 20:00:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices have a problem with concurrent VPD access to different
functions of the same physical device, so move the protecting mutex
from the pci_vpd structure to the pci_bus structure. There are a
number of reports on support sites for a variety of devices from
various vendors getting the "vpd r/w failed" message. This is likely
to at least fix some of them. Thanks to Shannon Nelson for helping
to come up with this approach.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/pci/access.c |   10 ++++------
 drivers/pci/probe.c  |    1 +
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/pci/access.c b/drivers/pci/access.c
index d9b64a175990..6a1c8d6f95f1 100644
--- a/drivers/pci/access.c
+++ b/drivers/pci/access.c
@@ -281,7 +281,6 @@ PCI_USER_WRITE_CONFIG(dword, u32)
 
 struct pci_vpd_pci22 {
 	struct pci_vpd base;
-	struct mutex lock;
 	u16	flag;
 	bool	busy;
 	u8	cap;
@@ -340,7 +339,7 @@ static ssize_t pci_vpd_pci22_read(struct pci_dev *dev, loff_t pos, size_t count,
 	if (pos < 0 || pos > vpd->base.len || end > vpd->base.len)
 		return -EINVAL;
 
-	if (mutex_lock_killable(&vpd->lock))
+	if (mutex_lock_killable(&dev->bus->vpd_mutex))
 		return -EINTR;
 
 	ret = pci_vpd_pci22_wait(dev);
@@ -376,7 +375,7 @@ static ssize_t pci_vpd_pci22_read(struct pci_dev *dev, loff_t pos, size_t count,
 		}
 	}
 out:
-	mutex_unlock(&vpd->lock);
+	mutex_unlock(&dev->bus->vpd_mutex);
 	return ret ? ret : count;
 }
 
@@ -392,7 +391,7 @@ static ssize_t pci_vpd_pci22_write(struct pci_dev *dev, loff_t pos, size_t count
 	if (pos < 0 || (pos & 3) || (count & 3) || end > vpd->base.len)
 		return -EINVAL;
 
-	if (mutex_lock_killable(&vpd->lock))
+	if (mutex_lock_killable(&dev->bus->vpd_mutex))
 		return -EINTR;
 
 	ret = pci_vpd_pci22_wait(dev);
@@ -424,7 +423,7 @@ static ssize_t pci_vpd_pci22_write(struct pci_dev *dev, loff_t pos, size_t count
 		pos += sizeof(u32);
 	}
 out:
-	mutex_unlock(&vpd->lock);
+	mutex_unlock(&dev->bus->vpd_mutex);
 	return ret ? ret : count;
 }
 
@@ -453,7 +452,6 @@ int pci_vpd_pci22_init(struct pci_dev *dev)
 
 	vpd->base.len = PCI_VPD_PCI22_SIZE;
 	vpd->base.ops = &pci_vpd_pci22_ops;
-	mutex_init(&vpd->lock);
 	vpd->cap = cap;
 	vpd->busy = false;
 	dev->vpd = &vpd->base;
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 6675a7a1b9fc..40c2a5a751d0 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -494,6 +494,7 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
 	INIT_LIST_HEAD(&b->devices);
 	INIT_LIST_HEAD(&b->slots);
 	INIT_LIST_HEAD(&b->resources);
+	mutex_init(&b->vpd_mutex);
 	b->max_bus_speed = PCI_SPEED_UNKNOWN;
 	b->cur_bus_speed = PCI_SPEED_UNKNOWN;
 #ifdef CONFIG_PCI_DOMAINS_GENERIC
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 353db8dc4c6e..f8a51d172255 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -454,6 +454,7 @@ struct pci_bus {
 	struct msi_controller *msi;	/* MSI controller */
 	void		*sysdata;	/* hook for sys-specific extension */
 	struct proc_dir_entry *procdir;	/* directory entry in /proc/bus/pci */
+	struct mutex	vpd_mutex;	/* bus-wide VPD access mutex */
 
 	unsigned char	number;		/* bus number */
 	unsigned char	primary;	/* number of primary bridge */
