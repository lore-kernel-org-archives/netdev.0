From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH net-next] enic: unmask intr only when napi is complete
Date: Mon, 22 May 2017 12:19:48 -0700
Message-ID: <20170522191948.1397-1-gvaradar@cisco.com>
Cc: benve@cisco.com, Govindarajulu Varadarajan <gvaradar@cisco.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-7.cisco.com ([173.37.142.94]:25905 "EHLO
        alln-iport-7.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758710AbdEVT3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 15:29:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of busy poll, napi_complete_done returns false and does not
dequeue napi. In this case do not unmask the intr. We are guaranteed
napi is called again. This reduces unnecessary iowrites.

Signed-off-by: Govindarajulu Varadarajan <gvaradar@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 4b87beeabce1..6a9c8878aca0 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1537,13 +1537,12 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		 */
 		enic_calc_int_moderation(enic, &enic->rq[0]);
 
-	if (rq_work_done < rq_work_to_do) {
+	if ((rq_work_done < budget) && napi_complete_done(napi, rq_work_done)) {
 
 		/* Some work done, but not enough to stay in polling,
 		 * exit polling
 		 */
 
-		napi_complete_done(napi, rq_work_done);
 		if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
 			enic_set_int_moderation(enic, &enic->rq[0]);
 		vnic_intr_unmask(&enic->intr[intr]);
@@ -1663,13 +1662,12 @@ static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
 		 */
 		enic_calc_int_moderation(enic, &enic->rq[rq]);
 
-	if (work_done < work_to_do) {
+	if ((work_done < budget) && napi_complete_done(napi, work_done)) {
 
 		/* Some work done, but not enough to stay in polling,
 		 * exit polling
 		 */
 
-		napi_complete_done(napi, work_done);
 		if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
 			enic_set_int_moderation(enic, &enic->rq[rq]);
 		vnic_intr_unmask(&enic->intr[intr]);
-- 
2.13.0
