From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] fm10k: avoid possible truncation of q_vector->name
Date: Mon,  2 Oct 2017 08:42:29 -0700
Message-ID: <20171002154236.84043-7-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3420 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751430AbdJBPm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:42:58 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

New versions of GCC since version 7 began warning about possible
truncation of calls to snprintf. We can fix this and avoid false
positives. First, we should pass the full buffer size to snprintf,
because it guarantees a NULL character as part of its passed length, so
passing len-1 is simply wasting a byte of possible storage.

Second, if we make the ri and ti variables unsigned, the compiler is
able to correctly reason that the value never gets larger than 256, so
it doesn't need to warn about the full space required to print a signed
integer.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 63784576ae8b..9212b3fa3b62 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1544,7 +1544,7 @@ int fm10k_qv_request_irq(struct fm10k_intfc *interface)
 	struct net_device *dev = interface->netdev;
 	struct fm10k_hw *hw = &interface->hw;
 	struct msix_entry *entry;
-	int ri = 0, ti = 0;
+	unsigned int ri = 0, ti = 0;
 	int vector, err;
 
 	entry = &interface->msix_entries[NON_Q_VECTORS(hw)];
@@ -1554,15 +1554,15 @@ int fm10k_qv_request_irq(struct fm10k_intfc *interface)
 
 		/* name the vector */
 		if (q_vector->tx.count && q_vector->rx.count) {
-			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-				 "%s-TxRx-%d", dev->name, ri++);
+			snprintf(q_vector->name, sizeof(q_vector->name),
+				 "%s-TxRx-%u", dev->name, ri++);
 			ti++;
 		} else if (q_vector->rx.count) {
-			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-				 "%s-rx-%d", dev->name, ri++);
+			snprintf(q_vector->name, sizeof(q_vector->name),
+				 "%s-rx-%u", dev->name, ri++);
 		} else if (q_vector->tx.count) {
-			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-				 "%s-tx-%d", dev->name, ti++);
+			snprintf(q_vector->name, sizeof(q_vector->name),
+				 "%s-tx-%u", dev->name, ti++);
 		} else {
 			/* skip this unused q_vector */
 			continue;
-- 
2.14.2
