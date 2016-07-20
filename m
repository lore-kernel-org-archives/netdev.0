From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/20] fm10k: no need to continue in fm10k_down if __FM10K_DOWN already set
Date: Wed, 20 Jul 2016 15:23:39 -0700
Message-ID: <1469053438-85381-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4181 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754898AbcGTWYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:00 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Return early from fm10k_down() when we are already down, since that
means another thread is either already finished or has started going
down, so shouldn't conflict with them.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index e05aca9..610c313 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1601,7 +1601,8 @@ void fm10k_down(struct fm10k_intfc *interface)
 	int err;
 
 	/* signal that we are down to the interrupt handler and service task */
-	set_bit(__FM10K_DOWN, &interface->state);
+	if (test_and_set_bit(__FM10K_DOWN, &interface->state))
+		return;
 
 	/* call carrier off first to avoid false dev_watchdog timeouts */
 	netif_carrier_off(netdev);
-- 
2.5.5
