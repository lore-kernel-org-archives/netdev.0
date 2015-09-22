From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 3/3] ixgbe: Fix handling of napi budget when multiple
 queues are enabled per vector
Date: Tue, 22 Sep 2015 14:35:41 -0700
Message-ID: <20150922213541.2774.70538.stgit@ahduyck-vm-fedora22>
References: <20150922213002.2774.37924.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36481 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934844AbbIVVfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 17:35:42 -0400
Received: by pacbt3 with SMTP id bt3so1789789pac.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 14:35:42 -0700 (PDT)
In-Reply-To: <20150922213002.2774.37924.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch corrects an issue in which the polling routine would increase
the budget for Rx to at least 1 per queue if multiple queues were present.
This would result in Rx packets being processed when the budget was 0 which
is meant to indicate that no Rx can be handled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index acb1b91408ec..506b0944253c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2772,7 +2772,8 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 	ixgbe_for_each_ring(ring, q_vector->tx)
 		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
 
-	if (!ixgbe_qv_lock_napi(q_vector))
+	/* Exit if we are called by netpoll or busy polling is active */
+	if ((budget <= 0) || !ixgbe_qv_lock_napi(q_vector))
 		return budget;
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
