From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 2/3] fm10k: Fix handling of napi budget when multiple
 queues are enabled per vector
Date: Tue, 22 Sep 2015 14:35:35 -0700
Message-ID: <20150922213535.2774.9863.stgit@ahduyck-vm-fedora22>
References: <20150922213002.2774.37924.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34512 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934844AbbIVVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 17:35:36 -0400
Received: by padhy16 with SMTP id hy16so20148484pad.1
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 14:35:36 -0700 (PDT)
In-Reply-To: <20150922213002.2774.37924.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch corrects an issue in which the polling routine would increase
the budget for Rx to at least 1 per queue if multiple queues were present.
This would result in Rx packets being processed when the budget was 0 which
is meant to indicate that no Rx can be handled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 92d415584749..b5bcb8255260 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1413,6 +1413,10 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 	fm10k_for_each_ring(ring, q_vector->tx)
 		clean_complete &= fm10k_clean_tx_irq(q_vector, ring);
 
+	/* Handle case where we are called by netpoll with a budget of 0 */
+	if (budget <= 0)
+		return budget;
+
 	/* attempt to distribute budget to each queue fairly, but don't
 	 * allow the budget to go below 1 because we'll exit polling
 	 */
