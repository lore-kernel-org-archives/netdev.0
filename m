From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] i40e: Fix scheduling while atomic bug during NAPI
Date: Fri, 20 Jun 2014 00:49:42 -0700
Message-ID: <1403250588-14356-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62062 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220AbaFTHt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:49:57 -0400
In-Reply-To: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

The bug is encountered when all the Tx hang recovery mechanisms have
failed and driver tries to bring down the interface in the interrupt context.
The patch defers this and schedules it for next cycle.

Change-ID: Id9cd1da15b0e5c018dce18da4d0eed5ef1e8a809
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 25 +++++++++++++++++++++++--
 2 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index fce7e4d..60f9a73 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -135,6 +135,7 @@ enum i40e_state_t {
 	__I40E_FILTER_OVERFLOW_PROMISC,
 	__I40E_SUSPENDED,
 	__I40E_BAD_EEPROM,
+	__I40E_DOWN_REQUESTED,
 };
 
 enum i40e_interrupt_policy {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 296b3d2..14d7db6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -304,8 +304,8 @@ static void i40e_tx_timeout(struct net_device *netdev)
 		break;
 	default:
 		netdev_err(netdev, "tx_timeout recovery unsuccessful\n");
-		set_bit(__I40E_DOWN, &vsi->state);
-		i40e_down(vsi);
+		set_bit(__I40E_DOWN_REQUESTED, &pf->state);
+		set_bit(__I40E_DOWN_REQUESTED, &vsi->state);
 		break;
 	}
 	i40e_service_event_schedule(pf);
@@ -4692,6 +4692,23 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 
 		/* no further action needed, so return now */
 		return;
+	} else if (reset_flags & (1 << __I40E_DOWN_REQUESTED)) {
+		int v;
+
+		/* Find the VSI(s) that needs to be brought down */
+		dev_info(&pf->pdev->dev, "VSI down requested\n");
+		for (v = 0; v < pf->num_alloc_vsi; v++) {
+			struct i40e_vsi *vsi = pf->vsi[v];
+			if (vsi != NULL &&
+			    test_bit(__I40E_DOWN_REQUESTED, &vsi->state)) {
+				set_bit(__I40E_DOWN, &vsi->state);
+				i40e_down(vsi);
+				clear_bit(__I40E_DOWN_REQUESTED, &vsi->state);
+			}
+		}
+
+		/* no further action needed, so return now */
+		return;
 	} else {
 		dev_info(&pf->pdev->dev,
 			 "bad reset request 0x%08x\n", reset_flags);
@@ -5162,6 +5179,10 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 		reset_flags |= (1 << __I40E_GLOBAL_RESET_REQUESTED);
 		clear_bit(__I40E_GLOBAL_RESET_REQUESTED, &pf->state);
 	}
+	if (test_bit(__I40E_DOWN_REQUESTED, &pf->state)) {
+		reset_flags |= (1 << __I40E_DOWN_REQUESTED);
+		clear_bit(__I40E_DOWN_REQUESTED, &pf->state);
+	}
 
 	/* If there's a recovery already waiting, it takes
 	 * precedence before starting a new reset sequence.
-- 
1.9.3
