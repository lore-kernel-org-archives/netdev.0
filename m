From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 03/23] e100: Add debugging code for cb cleaning and csum failures.
Date: Tue, 19 Sep 2006 10:28:38 -0700
Message-ID: <20060919172838.4605.35958.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:12045 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030338AbWISRTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:19:43 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Refine cb cleaning debug printout and print out all cleaned cbs' status. Add
debug flag for EEPROM csum failures that were overridden by the user.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index ab0868c..ae93c62 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -761,6 +761,8 @@ static int e100_eeprom_load(struct nic *
 		DPRINTK(PROBE, ERR, "EEPROM corrupted\n");
 		if (!eeprom_bad_csum_allow)
 			return -EAGAIN;
+		else
+			add_taint(TAINT_MACHINE_CHECK);
 	}
 
 	return 0;
@@ -1657,13 +1659,14 @@ static int e100_tx_clean(struct nic *nic
 
 	spin_lock(&nic->cb_lock);
 
-	DPRINTK(TX_DONE, DEBUG, "cb->status = 0x%04X\n",
-		nic->cb_to_clean->status);
-
 	/* Clean CBs marked complete */
 	for(cb = nic->cb_to_clean;
 	    cb->status & cpu_to_le16(cb_complete);
 	    cb = nic->cb_to_clean = cb->next) {
+		DPRINTK(TX_DONE, DEBUG, "cb[%d]->status = 0x%04X\n",
+		        (int)(((void*)cb - (void*)nic->cbs)/sizeof(struct cb)),
+		        cb->status);
+
 		if(likely(cb->skb != NULL)) {
 			nic->net_stats.tx_packets++;
 			nic->net_stats.tx_bytes += cb->skb->len;



---
Auke Kok <auke-jan.h.kok@intel.com>
