From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/20] fm10k: force link to remain down for at least a second on resume events
Date: Wed, 20 Jul 2016 15:23:56 -0700
Message-ID: <1469053438-85381-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44560 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755461AbcGTWYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:09 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When we resume from an AER recovery with many active VFs, the PF sees
many spurious link up and link down events. Prevent this by delaying
link down for at least one second after the resume event.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index d4ccb2a..b8245c7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2158,6 +2158,10 @@ static int fm10k_handle_resume(struct fm10k_intfc *interface)
 	interface->host_ready = false;
 	fm10k_watchdog_host_not_ready(interface);
 
+	/* force link to stay down for a second to prevent link flutter */
+	interface->link_down_event = jiffies + (HZ);
+	set_bit(__FM10K_LINK_DOWN, &interface->state);
+
 	/* clear the service task disable bit to allow service task to start */
 	clear_bit(__FM10K_SERVICE_DISABLE, &interface->state);
 	fm10k_service_event_schedule(interface);
-- 
2.5.5
