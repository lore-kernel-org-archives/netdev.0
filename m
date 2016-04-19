From: sunil.kovvuri@gmail.com
Subject: [PATCH 3/4] net: thunderx: add sysfs attribute for SQS/SVF assigments
Date: Tue, 19 Apr 2016 19:03:31 +0530
Message-ID: <1461072812-44239-4-git-send-email-sunil.kovvuri@gmail.com>
References: <1461072812-44239-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com,
	Radoslaw Biernacki <rad@semihalf.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461072812-44239-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Radoslaw Biernacki <rad@semihalf.com>

With this sysfs attribute (sriov_sqs_assignment) administrator will be
able to read the current assigment of SQS/SVF for a given VF. This is
useful to decide which VFs needs to be attached to UIO for a successful
allocation of secondary Qsets

Signed-off-by: Radoslaw Biernacki <rad@semihalf.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c |   67 +++++++++++++++++++++++-
 1 files changed, 66 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index d6a6914..e2d8db9 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -1159,6 +1159,60 @@ static void nic_poll_for_link(struct work_struct *work)
 	queue_delayed_work(nic->check_link, &nic->dwork, HZ * 2);
 }
 
+ssize_t sriov_sqs_assignment_show(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct pci_dev *vf_dev;
+	struct pci_driver *vf_drv;
+	struct nicpf *nic = pci_get_drvdata(pdev);
+	size_t vf, off, svf_idx;
+
+	off = scnprintf(buf, PAGE_SIZE, "%u\n", nic->num_vf_en);
+
+	for (vf = 0; vf < nic->num_vf_en; vf++) {
+		vf_dev = nic->vf_pdev[vf];
+		vf_drv = vf_dev ? pci_dev_driver(vf_dev) : NULL;
+		if (off >= PAGE_SIZE)
+			break;
+		off += scnprintf(&buf[off], PAGE_SIZE - off,
+				 "%zu %04x:%02x:%02x.%d %s %c:",
+				 vf, pci_domain_nr(vf_dev->bus),
+				 vf_dev->bus->number, PCI_SLOT(vf_dev->devfn),
+				 PCI_FUNC(vf_dev->devfn),
+				 vf_drv ? vf_drv->name : "no-driver",
+				 nic->vf_enabled[vf] ? '+' : '-');
+		for (svf_idx = 0; svf_idx < MAX_SQS_PER_VF; svf_idx++) {
+			if (off >= PAGE_SIZE)
+				break;
+			if (nic->vf_sqs[vf][svf_idx] == NIC_VF_UNASSIGNED)
+				break;
+			off += scnprintf(&buf[off], PAGE_SIZE - off, " %d",
+					 nic->vf_sqs[vf][svf_idx]);
+		}
+		if (off >= PAGE_SIZE)
+			break;
+		off += scnprintf(&buf[off], PAGE_SIZE - off, "\n");
+	}
+
+	for (vf = nic->num_vf_en; vf < nic->num_vf_en + nic->num_sqs_en; vf++) {
+		vf_dev = nic->vf_pdev[vf];
+		vf_drv = vf_dev ? pci_dev_driver(vf_dev) : NULL;
+		if (off >= PAGE_SIZE)
+			break;
+		off += scnprintf(&buf[off], PAGE_SIZE - off,
+				 "%zu %04x:%02x:%02x.%d %s: %u\n",
+				 vf, pci_domain_nr(vf_dev->bus),
+				 vf_dev->bus->number, PCI_SLOT(vf_dev->devfn),
+				 PCI_FUNC(vf_dev->devfn),
+				 vf_drv ? vf_drv->name : "no-driver",
+				 nic->pqs_vf[vf]);
+	}
+
+	return off;
+}
+DEVICE_ATTR_RO(sriov_sqs_assignment);
+
 static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct device *dev = &pdev->dev;
@@ -1235,12 +1289,18 @@ static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_unregister_interrupts;
 
+	err = device_create_file(dev, &dev_attr_sriov_sqs_assignment);
+	if (err) {
+		err = -ENOMEM;
+		goto err_disable_sriov;
+	}
+
 	/* Register a physical link status poll fn() */
 	nic->check_link = alloc_workqueue("check_link_status",
 					  WQ_UNBOUND | WQ_MEM_RECLAIM, 1);
 	if (!nic->check_link) {
 		err = -ENOMEM;
-		goto err_disable_sriov;
+		goto err_remove_sysfs_attr;
 	}
 
 	INIT_DELAYED_WORK(&nic->dwork, nic_poll_for_link);
@@ -1248,6 +1308,8 @@ static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	return 0;
 
+err_remove_sysfs_attr:
+	device_remove_file(dev, &dev_attr_sriov_sqs_assignment);
 err_disable_sriov:
 	if (nic->flags & NIC_SRIOV_ENABLED) {
 		nic_put_vf_pdev(nic);
@@ -1266,6 +1328,9 @@ err_disable_device:
 static void nic_remove(struct pci_dev *pdev)
 {
 	struct nicpf *nic = pci_get_drvdata(pdev);
+	struct device *dev = &pdev->dev;
+
+	device_remove_file(dev, &dev_attr_sriov_sqs_assignment);
 
 	if (nic->flags & NIC_SRIOV_ENABLED) {
 		nic_put_vf_pdev(nic);
-- 
1.7.1
