From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [RFC] PCI: Allow sysfs control over totalvfs
Date: Tue, 20 Sep 2016 18:49:48 +0300
Message-ID: <1474386588-16337-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <derek.chickles@caviumnetworks.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: <linux-pci@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Sorry in advance if this was already discussed in the past]

Some of the HW capable of SRIOV has resource limitations, where the
PF and VFs resources are drawn from a common pool.
In some cases, these limitations have to be considered early during
chip initialization and can only be changed by tearing down the
configuration and re-initializing.
As a result, drivers for such HWs sometimes have to make unfavorable
compromises where they reserve sufficient resources to accomadate
the maximal number of VFs that can be created - at the expanse of
resources that could have been used by the PF.

If users were able to provide 'hints' regarding the required number
of VFs *prior* to driver attachment, then such compromises could be
avoided. As we already have sysfs nodes that can be queried for the
number of totalvfs, it makes sense to let the user reduce the number
of said totalvfs using same infrastrucure.
Then, we can have drivers supporting SRIOV take that value into account
when deciding how much resources to reserve, allowing the PF to benefit
from the difference between the configuration space value and the actual
number needed by user.

Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
---
 drivers/pci/pci-sysfs.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index bcd10c7..c1546f8 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -449,6 +449,30 @@ static ssize_t sriov_totalvfs_show(struct device *dev,
 	return sprintf(buf, "%u\n", pci_sriov_get_totalvfs(pdev));
 }
 
+static ssize_t sriov_totalvfs_store(struct device *dev,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	u16 max_vfs;
+	int ret;
+
+	ret = kstrtou16(buf, 0, &max_vfs);
+	if (ret < 0)
+		return ret;
+
+	if (pdev->driver) {
+		dev_info(&pdev->dev,
+			 "Can't change totalvfs while driver is attached\n");
+		return -EUSERS;
+	}
+
+	ret = pci_sriov_set_totalvfs(pdev, max_vfs);
+	if (ret)
+		return ret;
+
+	return count;
+}
 
 static ssize_t sriov_numvfs_show(struct device *dev,
 				 struct device_attribute *attr,
@@ -516,7 +540,9 @@ static ssize_t sriov_numvfs_store(struct device *dev,
 	return count;
 }
 
-static struct device_attribute sriov_totalvfs_attr = __ATTR_RO(sriov_totalvfs);
+static struct device_attribute sriov_totalvfs_attr =
+		__ATTR(sriov_totalvfs, (S_IRUGO|S_IWUSR|S_IWGRP),
+		       sriov_totalvfs_show, sriov_totalvfs_store);
 static struct device_attribute sriov_numvfs_attr =
 		__ATTR(sriov_numvfs, (S_IRUGO|S_IWUSR|S_IWGRP),
 		       sriov_numvfs_show, sriov_numvfs_store);
-- 
1.9.3
