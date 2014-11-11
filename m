From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/10] i40e: don't do link_status or stats collection on every ARQ
Date: Tue, 11 Nov 2014 06:44:38 -0800
Message-ID: <1415717086-3441-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3085 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbaKKOp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 09:45:29 -0500
In-Reply-To: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The ARQ events cause a service_task execution, and we do a link_status
check and full stats gathering for each service_task.  However, when
there are a lot of ARQ events, such as when doing an NVM update, we end up
doing 10's if not 100's of these per second, thereby heavily abusing the
PCI bus and especially the Firmware.  This patch adds a check to keep the
service_task from running these periodic tasks more than once per second,
while still allowing quick action to service the events.

Change-ID: Iec7670c37bfae9791c43fec26df48aea7f70b33e
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  3 ++-
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++++----
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f1e33f8..b7a807b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -269,7 +269,8 @@ struct i40e_pf {
 	u16 msg_enable;
 	char misc_int_name[IFNAMSIZ + 9];
 	u16 adminq_work_limit; /* num of admin receive queue desc to process */
-	int service_timer_period;
+	unsigned long service_timer_period;
+	unsigned long service_timer_previous;
 	struct timer_list service_timer;
 	struct work_struct service_task;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1a98e23..de66463 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5449,7 +5449,7 @@ static void i40e_check_hang_subtask(struct i40e_pf *pf)
 }
 
 /**
- * i40e_watchdog_subtask - Check and bring link up
+ * i40e_watchdog_subtask - periodic checks not using event driven response
  * @pf: board private structure
  **/
 static void i40e_watchdog_subtask(struct i40e_pf *pf)
@@ -5461,6 +5461,15 @@ static void i40e_watchdog_subtask(struct i40e_pf *pf)
 	    test_bit(__I40E_CONFIG_BUSY, &pf->state))
 		return;
 
+	/* make sure we don't do these things too often */
+	if (time_before(jiffies, (pf->service_timer_previous +
+				  pf->service_timer_period)))
+		return;
+	pf->service_timer_previous = jiffies;
+
+	i40e_check_hang_subtask(pf);
+	i40e_link_event(pf);
+
 	/* Update the stats for active netdevs so the network stack
 	 * can look at updated numbers whenever it cares to
 	 */
@@ -6325,15 +6334,12 @@ static void i40e_service_task(struct work_struct *work)
 	i40e_vc_process_vflr_event(pf);
 	i40e_watchdog_subtask(pf);
 	i40e_fdir_reinit_subtask(pf);
-	i40e_check_hang_subtask(pf);
 	i40e_sync_filters_subtask(pf);
 #ifdef CONFIG_I40E_VXLAN
 	i40e_sync_vxlan_filters_subtask(pf);
 #endif
 	i40e_clean_adminq_subtask(pf);
 
-	i40e_link_event(pf);
-
 	i40e_service_event_complete(pf);
 
 	/* If the tasks have taken longer than one timer cycle or there
-- 
1.9.3
