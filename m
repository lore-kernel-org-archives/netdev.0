From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 1/4] pci: move pci_assivned_vfs() check while disabling VFs to pci sub-system
Date: Mon, 10 Nov 2014 17:23:27 +0530
Message-ID: <1415620410-4937-2-git-send-email-sathya.perla@emulex.com>
References: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariel.elior@qlogic.com>, <linux.nics@intel.com>,
	<shahed.shaikh@qlogic.com>, <ddutile@redhat.com>
To: <linux-pci@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:51069 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbaKJLwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 06:52:50 -0500
In-Reply-To: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

A user must not be allowed to disable VFs while they are already assigned to
a guest. This check is being made in each individual driver that implements
the sriov_configure PCI method.
This patch fixes this code duplication by moving this check to the
sriov_nuvfs_store() routine just before invoking sriov_configure() when
num_vfs is equal to 0.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/pci/pci-sysfs.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index 2c6643f..6e65b47 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -477,6 +477,11 @@ static ssize_t sriov_numvfs_store(struct device *dev,
 	}
 
 	if (num_vfs == 0) {
+		if (pci_vfs_assigned(pdev)) {
+			dev_warn(&pdev->dev, "Cannot disable VFs while they are assigned\n");
+			return -EBUSY;
+		}
+
 		/* disable VFs */
 		ret = pdev->driver->sriov_configure(pdev, 0);
 		if (ret < 0)
-- 
1.7.1
