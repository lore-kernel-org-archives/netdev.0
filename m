From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/7] fm10k: allow service task to reschedule itself
Date: Thu,  6 Apr 2017 00:54:53 -0700
Message-ID: <20170406075456.27757-5-jeffrey.t.kirsher@intel.com>
References: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52098 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756760AbdDFHzI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 03:55:08 -0400
In-Reply-To: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

If some code path executes fm10k_service_event_schedule(), it is
guaranteed that we only queue the service task once, since we use
__FM10K_SERVICE_SCHED flag. Unfortunately this has a side effect that if
a service request occurs while we are currently running the watchdog, it
is possible that we will fail to notice the request and ignore it until
the next time the request occurs.

This can cause problems with pf/vf mailbox communication and other
service event tasks. To avoid this, introduce a FM10K_SERVICE_REQUEST
bit. When we successfully schedule (and set the _SCHED bit) the service
task, we will clear this bit. However, if we are unable to currently
schedule the service event, we just set the new SERVICE_REQUEST bit.

Finally, after the service event completes, we will re-schedule if the
request bit has been set.

This should ensure that we do not miss any service event schedules,
since we will re-schedule it once the currently running task finishes.
This means that for each request, we will always schedule the service
task to run at least once in full after the request came in.

This will avoid timing issues that can occur with the service event
scheduling. We do pay a cost in re-running many tasks, but all the
service event tasks use either flags to avoid duplicate work, or are
tolerant of being run multiple times.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h     |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index b496300d0268..689c413b7782 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -272,6 +272,7 @@ enum fm10k_state_t {
 	__FM10K_RESETTING,
 	__FM10K_DOWN,
 	__FM10K_SERVICE_SCHED,
+	__FM10K_SERVICE_REQUEST,
 	__FM10K_SERVICE_DISABLE,
 	__FM10K_MBX_LOCK,
 	__FM10K_LINK_DOWN,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 2a54372975f6..c62d1884f75b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -94,8 +94,12 @@ static int fm10k_hw_ready(struct fm10k_intfc *interface)
 void fm10k_service_event_schedule(struct fm10k_intfc *interface)
 {
 	if (!test_bit(__FM10K_SERVICE_DISABLE, interface->state) &&
-	    !test_and_set_bit(__FM10K_SERVICE_SCHED, interface->state))
+	    !test_and_set_bit(__FM10K_SERVICE_SCHED, interface->state)) {
+		clear_bit(__FM10K_SERVICE_REQUEST, interface->state);
 		queue_work(fm10k_workqueue, &interface->service_task);
+	} else {
+		set_bit(__FM10K_SERVICE_REQUEST, interface->state);
+	}
 }
 
 static void fm10k_service_event_complete(struct fm10k_intfc *interface)
@@ -105,6 +109,13 @@ static void fm10k_service_event_complete(struct fm10k_intfc *interface)
 	/* flush memory to make sure state is correct before next watchog */
 	smp_mb__before_atomic();
 	clear_bit(__FM10K_SERVICE_SCHED, interface->state);
+
+	/* If a service event was requested since we started, immediately
+	 * re-schedule now. This ensures we don't drop a request until the
+	 * next timer event.
+	 */
+	if (test_bit(__FM10K_SERVICE_REQUEST, interface->state))
+		fm10k_service_event_schedule(interface);
 }
 
 /**
-- 
2.12.2
