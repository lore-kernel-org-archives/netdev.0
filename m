From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 15/17] i40evf: relax and stagger init timing a bit
Date: Fri, 16 Oct 2015 05:10:23 -0700
Message-ID: <1444997425-3396-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:36264 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865AbbJPMKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:32 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

On some devices, in some systems, in some configurations, the VFs would
fail to initialize the first time you loaded the driver.

To correct this, increase the delay time for the init task slightly, and
wait longer before giving up.

If we enable VFs and load the VF driver in the same kernel as the PF
driver, we can totally overwhelm the PF driver with AQ requests because
all of the instances try to initialize at the same time.

To help alleviate this, stagger the initial scheduling of the init task
using the PCIe function as a multiplier. We mask off the function to
only three bits so no instance has to wait too long.

With these two changes, initializing 128 VFs on a single device goes
from four minutes to just a few seconds.

Change-ID: If3d8720c1c4e838ab36d8781d9ec295a62380936
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h      | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index c74f614..22841c6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -87,7 +87,7 @@ struct i40e_vsi {
 #define I40EVF_MAX_RXBUFFER   16384  /* largest size for single descriptor */
 #define I40EVF_MAX_AQ_BUF_SIZE    4096
 #define I40EVF_AQ_LEN             32
-#define I40EVF_AQ_MAX_ERR         10 /* times to try before resetting AQ */
+#define I40EVF_AQ_MAX_ERR         20 /* times to try before resetting AQ */
 
 #define MAXIMUM_ETHERNET_VLAN_SIZE (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 46af35f..4f3d571 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2344,7 +2344,7 @@ static void i40evf_init_task(struct work_struct *work)
 	}
 	return;
 restart:
-	schedule_delayed_work(&adapter->init_task, msecs_to_jiffies(20));
+	schedule_delayed_work(&adapter->init_task, msecs_to_jiffies(30));
 	return;
 
 err_register:
@@ -2361,7 +2361,7 @@ err:
 		adapter->flags |= I40EVF_FLAG_PF_COMMS_FAILED;
 		return; /* do not reschedule */
 	}
-	schedule_delayed_work(&adapter->init_task, HZ / 2);
+	schedule_delayed_work(&adapter->init_task, HZ);
 }
 
 /**
-- 
2.4.3
