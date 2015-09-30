From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/17] i40evf: tweak init timing
Date: Wed, 30 Sep 2015 05:52:39 -0700
Message-ID: <1443617561-40490-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48753 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932558AbbI3Mws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:48 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This patch tweaks the init timing of the driver just a little bit to
increase stability on load/unload and SR-IOV enable/disable cycles.

First, run the init_task loop a little quicker in order to reduce
overall init time.

Second, stagger the start of the init task based on the device's
PCIe function ID. This lessens the impact on the firmware when a
whole bunch of VFs are initialized simultaneously, e.g. enabling
SR-IOV without the VF driver blacklisted. For single VFs assigned
to VMs this will have no effect as the function ID will always be 0.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 49fa71c..76df6b2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2300,8 +2300,7 @@ static void i40evf_init_task(struct work_struct *work)
 	}
 	return;
 restart:
-	schedule_delayed_work(&adapter->init_task,
-			      msecs_to_jiffies(50));
+	schedule_delayed_work(&adapter->init_task, msecs_to_jiffies(30));
 	return;
 
 err_register:
@@ -2434,7 +2433,8 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	INIT_WORK(&adapter->adminq_task, i40evf_adminq_task);
 	INIT_WORK(&adapter->watchdog_task, i40evf_watchdog_task);
 	INIT_DELAYED_WORK(&adapter->init_task, i40evf_init_task);
-	schedule_delayed_work(&adapter->init_task, 10);
+	schedule_delayed_work(&adapter->init_task,
+			      msecs_to_jiffies(5 * (pdev->devfn & 0x07)));
 
 	return 0;
 
-- 
2.4.3
