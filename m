From: Emil Tantilov <emil.s.tantilov@intel.com>
Subject: [PATCH v2] PCI: lock each enable/disable num_vfs operation in sysfs
Date: Fri, 06 Jan 2017 13:59:08 -0800
Message-ID: <20170106215908.20736.34632.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling/disabling SRIOV via sysfs by echo-ing multiple values
simultaneously:

echo 63 > /sys/class/net/ethX/device/sriov_numvfs&
echo 63 > /sys/class/net/ethX/device/sriov_numvfs

sleep 5

echo 0 > /sys/class/net/ethX/device/sriov_numvfs&
echo 0 > /sys/class/net/ethX/device/sriov_numvfs

Results in the following bug:

kernel BUG at drivers/pci/iov.c:495!
invalid opcode: 0000 [#1] SMP
CPU: 1 PID: 8050 Comm: bash Tainted: G   W   4.9.0-rc7-net-next #2092
RIP: 0010:[<ffffffff813b1647>]
	  [<ffffffff813b1647>] pci_iov_release+0x57/0x60

Call Trace:
 [<ffffffff81391726>] pci_release_dev+0x26/0x70
 [<ffffffff8155be6e>] device_release+0x3e/0xb0
 [<ffffffff81365ee7>] kobject_cleanup+0x67/0x180
 [<ffffffff81365d9d>] kobject_put+0x2d/0x60
 [<ffffffff8155bc27>] put_device+0x17/0x20
 [<ffffffff8139c08a>] pci_dev_put+0x1a/0x20
 [<ffffffff8139cb6b>] pci_get_dev_by_id+0x5b/0x90
 [<ffffffff8139cca5>] pci_get_subsys+0x35/0x40
 [<ffffffff8139ccc8>] pci_get_device+0x18/0x20
 [<ffffffff8139ccfb>] pci_get_domain_bus_and_slot+0x2b/0x60
 [<ffffffff813b09e7>] pci_iov_remove_virtfn+0x57/0x180
 [<ffffffff813b0b95>] pci_disable_sriov+0x65/0x140
 [<ffffffffa00a1af7>] ixgbe_disable_sriov+0xc7/0x1d0 [ixgbe]
 [<ffffffffa00a1e9d>] ixgbe_pci_sriov_configure+0x3d/0x170 [ixgbe]
 [<ffffffff8139d28c>] sriov_numvfs_store+0xdc/0x130
...
RIP  [<ffffffff813b1647>] pci_iov_release+0x57/0x60

Use the existing mutex lock to protect each enable/disable operation.

-v2: move the existing lock from protecting the config of the IOV bus
to protecting the writes to sriov_numvfs in sysfs without maintaining
a "locked" version of pci_iov_add/remove_virtfn().
As suggested by Gavin Shan <gwshan@linux.vnet.ibm.com>

CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
---
 drivers/pci/iov.c       |    7 -------
 drivers/pci/pci-sysfs.c |   23 ++++++++++++++++-------
 drivers/pci/pci.h       |    2 +-
 3 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index 4722782..2479ae8 100644
--- a/drivers/pci/iov.c
+++ b/drivers/pci/iov.c
@@ -124,7 +124,6 @@ int pci_iov_add_virtfn(struct pci_dev *dev, int id, int reset)
 	struct pci_sriov *iov = dev->sriov;
 	struct pci_bus *bus;
 
-	mutex_lock(&iov->dev->sriov->lock);
 	bus = virtfn_add_bus(dev->bus, pci_iov_virtfn_bus(dev, id));
 	if (!bus)
 		goto failed;
@@ -162,7 +161,6 @@ int pci_iov_add_virtfn(struct pci_dev *dev, int id, int reset)
 		__pci_reset_function(virtfn);
 
 	pci_device_add(virtfn, virtfn->bus);
-	mutex_unlock(&iov->dev->sriov->lock);
 
 	pci_bus_add_device(virtfn);
 	sprintf(buf, "virtfn%u", id);
@@ -181,12 +179,10 @@ int pci_iov_add_virtfn(struct pci_dev *dev, int id, int reset)
 	sysfs_remove_link(&dev->dev.kobj, buf);
 failed1:
 	pci_dev_put(dev);
-	mutex_lock(&iov->dev->sriov->lock);
 	pci_stop_and_remove_bus_device(virtfn);
 failed0:
 	virtfn_remove_bus(dev->bus, bus);
 failed:
-	mutex_unlock(&iov->dev->sriov->lock);
 
 	return rc;
 }
@@ -195,7 +191,6 @@ void pci_iov_remove_virtfn(struct pci_dev *dev, int id, int reset)
 {
 	char buf[VIRTFN_ID_LEN];
 	struct pci_dev *virtfn;
-	struct pci_sriov *iov = dev->sriov;
 
 	virtfn = pci_get_domain_bus_and_slot(pci_domain_nr(dev->bus),
 					     pci_iov_virtfn_bus(dev, id),
@@ -218,10 +213,8 @@ void pci_iov_remove_virtfn(struct pci_dev *dev, int id, int reset)
 	if (virtfn->dev.kobj.sd)
 		sysfs_remove_link(&virtfn->dev.kobj, "physfn");
 
-	mutex_lock(&iov->dev->sriov->lock);
 	pci_stop_and_remove_bus_device(virtfn);
 	virtfn_remove_bus(dev->bus, virtfn->bus);
-	mutex_unlock(&iov->dev->sriov->lock);
 
 	/* balance pci_get_domain_bus_and_slot() */
 	pci_dev_put(virtfn);
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index 0666287..25d010d 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -472,6 +472,7 @@ static ssize_t sriov_numvfs_store(struct device *dev,
 				  const char *buf, size_t count)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
+	struct pci_sriov *iov = pdev->sriov;
 	int ret;
 	u16 num_vfs;
 
@@ -482,38 +483,46 @@ static ssize_t sriov_numvfs_store(struct device *dev,
 	if (num_vfs > pci_sriov_get_totalvfs(pdev))
 		return -ERANGE;
 
+	mutex_lock(&iov->dev->sriov->lock);
+
 	if (num_vfs == pdev->sriov->num_VFs)
-		return count;		/* no change */
+		goto exit;
 
 	/* is PF driver loaded w/callback */
 	if (!pdev->driver || !pdev->driver->sriov_configure) {
 		dev_info(&pdev->dev, "Driver doesn't support SRIOV configuration via sysfs\n");
-		return -ENOSYS;
+		ret = -ENOENT;
+		goto exit;
 	}
 
 	if (num_vfs == 0) {
 		/* disable VFs */
 		ret = pdev->driver->sriov_configure(pdev, 0);
-		if (ret < 0)
-			return ret;
-		return count;
+		goto exit;
 	}
 
 	/* enable VFs */
 	if (pdev->sriov->num_VFs) {
 		dev_warn(&pdev->dev, "%d VFs already enabled. Disable before enabling %d VFs\n",
 			 pdev->sriov->num_VFs, num_vfs);
-		return -EBUSY;
+		ret = -EBUSY;
+		goto exit;
 	}
 
 	ret = pdev->driver->sriov_configure(pdev, num_vfs);
 	if (ret < 0)
-		return ret;
+		goto exit;
 
 	if (ret != num_vfs)
 		dev_warn(&pdev->dev, "%d VFs requested; only %d enabled\n",
 			 num_vfs, ret);
 
+exit:
+	mutex_unlock(&iov->dev->sriov->lock);
+
+	if (ret < 0)
+		return ret;
+
 	return count;
 }
 
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index cb17db2..8dd38e6 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -270,7 +270,7 @@ struct pci_sriov {
 	u16 driver_max_VFs;	/* max num VFs driver supports */
 	struct pci_dev *dev;	/* lowest numbered PF */
 	struct pci_dev *self;	/* this PF */
-	struct mutex lock;	/* lock for VF bus */
+	struct mutex lock;	/* lock for setting sriov_numvfs in sysfs */
 	resource_size_t barsz[PCI_SRIOV_NUM_BARS];	/* VF BAR size */
 };
 
