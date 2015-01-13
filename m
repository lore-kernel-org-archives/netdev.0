From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/15] i40evf: don't fire traffic IRQs when the interface is down
Date: Tue, 13 Jan 2015 11:58:04 -0800
Message-ID: <1421179093-10932-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46651 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753840AbbAMT6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:58:18 -0500
In-Reply-To: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

There is always a possibility that MSI-X interrupts can get lost. To
keep this problem from stalling the driver, we fire all of our MSI-X
vectors during the watchdog routine. However, we should not fire the
traffic vectors when the interface is closed. In this case, just fire
vector 0, which is used for admin queue events.

As a result, we do not enable the interrupt cause for vector 0. This
can cause the admin queue handler to be called reentrantly, which
causes a scary "critical section violation" message to be logged,
even though no real damage is done.

Change-ID: Ic43a5184708ab2cb9a23fca7dedd808a46717795
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 994ae4e..c960ef5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1385,11 +1385,14 @@ static void i40evf_watchdog_task(struct work_struct *work)
 
 	if (adapter->state == __I40EVF_RUNNING)
 		i40evf_request_stats(adapter);
-
-	i40evf_irq_enable(adapter, true);
-	i40evf_fire_sw_int(adapter, 0xFF);
-
 watchdog_done:
+	if (adapter->state == __I40EVF_RUNNING) {
+		i40evf_irq_enable_queues(adapter, ~0);
+		i40evf_fire_sw_int(adapter, 0xFF);
+	} else {
+		i40evf_fire_sw_int(adapter, 0x1);
+	}
+
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 restart_watchdog:
 	if (adapter->state == __I40EVF_REMOVE)
-- 
1.9.3
