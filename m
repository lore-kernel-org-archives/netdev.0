From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/5] e1000e: Guarantee descriptor writeback flush success.
Date: Tue,  3 Apr 2012 15:18:08 -0700
Message-ID: <1333491489-29933-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1333491489-29933-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33957 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754866Ab2DCWSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 18:18:13 -0400
In-Reply-To: <1333491489-29933-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

In rare circumstances, a descriptor writeback flush may not work if it
arrives on a specific clock cycle as a writeback request is going out.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 6878601..19ab215 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1059,6 +1059,13 @@ static void e1000_print_hw_hang(struct work_struct *work)
 		ew32(TIDV, adapter->tx_int_delay | E1000_TIDV_FPD);
 		/* execute the writes immediately */
 		e1e_flush();
+		/*
+		 * Due to rare timing issues, write to TIDV again to ensure
+		 * the write is successful
+		 */
+		ew32(TIDV, adapter->tx_int_delay | E1000_TIDV_FPD);
+		/* execute the writes immediately */
+		e1e_flush();
 		adapter->tx_hang_recheck = true;
 		return;
 	}
@@ -3616,6 +3623,16 @@ static void e1000e_flush_descriptors(struct e1000_adapter *adapter)
 
 	/* execute the writes immediately */
 	e1e_flush();
+
+	/*
+	 * due to rare timing issues, write to TIDV/RDTR again to ensure the
+	 * write is successful
+	 */
+	ew32(TIDV, adapter->tx_int_delay | E1000_TIDV_FPD);
+	ew32(RDTR, adapter->rx_int_delay | E1000_RDTR_FPD);
+
+	/* execute the writes immediately */
+	e1e_flush();
 }
 
 static void e1000e_update_stats(struct e1000_adapter *adapter);
-- 
1.7.7.6
