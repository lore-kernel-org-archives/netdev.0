From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 06/16] enic: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 18:02:08 -0700
Message-ID: <874n30z33j.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<877g808luk.fsf_-_@xmission.com> <871ty41dps.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58110 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbaCOBCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:02:14 -0400
In-Reply-To: <871ty41dps.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 17:56:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Processing any incoming packets with a with a napi budget of 0
is incorrect driver behavior.

This matters as netpoll will shortly call drivers with a budget of 0
to avoid receive packet processing happening in hard irq context.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index dcd58f23834a..4c35fc8fad99 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1086,14 +1086,15 @@ static int enic_poll(struct napi_struct *napi, int budget)
 	unsigned int intr = enic_legacy_io_intr();
 	unsigned int rq_work_to_do = budget;
 	unsigned int wq_work_to_do = -1; /* no limit */
-	unsigned int  work_done, rq_work_done, wq_work_done;
+	unsigned int  work_done, rq_work_done = 0, wq_work_done;
 	int err;
 
 	/* Service RQ (first) and WQ
 	 */
 
-	rq_work_done = vnic_cq_service(&enic->cq[cq_rq],
-		rq_work_to_do, enic_rq_service, NULL);
+	if (budget > 0)
+		rq_work_done = vnic_cq_service(&enic->cq[cq_rq],
+			rq_work_to_do, enic_rq_service, NULL);
 
 	wq_work_done = vnic_cq_service(&enic->cq[cq_wq],
 		wq_work_to_do, enic_wq_service, NULL);
@@ -1141,14 +1142,15 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 	unsigned int cq = enic_cq_rq(enic, rq);
 	unsigned int intr = enic_msix_rq_intr(enic, rq);
 	unsigned int work_to_do = budget;
-	unsigned int work_done;
+	unsigned int work_done = 0;
 	int err;
 
 	/* Service RQ
 	 */
 
-	work_done = vnic_cq_service(&enic->cq[cq],
-		work_to_do, enic_rq_service, NULL);
+	if (budget > 0)
+		work_done = vnic_cq_service(&enic->cq[cq],
+			work_to_do, enic_rq_service, NULL);
 
 	/* Return intr event credits for this polling
 	 * cycle.  An intr event is the completion of a
-- 
1.7.5.4
