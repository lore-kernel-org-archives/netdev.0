From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tg3: use napi_complete_done()
Date: Thu, 05 Mar 2015 10:41:34 -0800
Message-ID: <1425580894.5130.263.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:41489 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756892AbbCESlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 13:41:36 -0500
Received: by iecrd18 with SMTP id rd18so78935309iec.8
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 10:41:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Using napi_complete_done() instead of napi_complete() allows
us to use /sys/class/net/ethX/gro_flush_timeout

GRO layer can aggregate more packets if the flush is delayed a bit,
without having to set too big coalescing parameters that impact
latencies.

Tested:

lpx:~# echo 0 >/sys/class/net/eth1/gro_flush_timeout

lpx:~# sar -n DEV 1 10 | grep eth1
10:36:25 AM      eth1  81290.00  40617.00 120479.67   2777.01      0.00      0.00      0.00
10:36:26 AM      eth1  81283.00  40608.00 120481.81   2778.13      0.00      0.00      1.00
10:36:27 AM      eth1  81304.00  40639.00 120518.42   2778.28      0.00      0.00      0.00
10:36:28 AM      eth1  81255.00  40605.00 120437.34   2775.95      0.00      0.00      1.00
10:36:29 AM      eth1  81306.00  40630.00 120521.44   2777.70      0.00      0.00      0.00
10:36:30 AM      eth1  81286.00  40564.00 120480.20   2773.31      0.00      0.00      0.00
10:36:31 AM      eth1  81256.00  40599.00 120438.81   2776.27      0.00      0.00      0.00
10:36:32 AM      eth1  81287.00  40594.00 120480.69   2776.69      0.00      0.00      0.00
10:36:33 AM      eth1  81279.00  40601.00 120478.53   2775.84      0.00      0.00      0.00
10:36:34 AM      eth1  81277.00  40610.00 120476.94   2776.25      0.00      0.00      0.00
Average:         eth1  81282.30  40606.70 120479.39   2776.54      0.00      0.00      0.20

lpx:~# echo 13000 >/sys/class/net/eth1/gro_flush_timeout

lpx:~# sar -n DEV 1 10 | grep eth1
10:36:43 AM      eth1  81257.00   7747.00 120437.44    530.00      0.00      0.00      0.00
10:36:44 AM      eth1  81278.00   7748.00 120480.00    529.85      0.00      0.00      0.00
10:36:45 AM      eth1  81282.00   7752.00 120479.09    531.09      0.00      0.00      0.00
10:36:46 AM      eth1  81282.00   7751.00 120478.80    530.90      0.00      0.00      0.00
10:36:47 AM      eth1  81276.00   7745.00 120478.31    529.64      0.00      0.00      0.00
10:36:48 AM      eth1  81278.00   7747.00 120478.50    529.81      0.00      0.00      0.00
10:36:49 AM      eth1  81282.00   7749.00 120478.88    530.01      0.00      0.00      0.00
10:36:50 AM      eth1  81284.00   7751.00 120481.52    530.20      0.00      0.00      0.00
10:36:51 AM      eth1  81299.00   7769.00 120481.74    533.81      0.00      0.00      0.00
10:36:52 AM      eth1  81281.00   7748.00 120478.62    529.96      0.00      0.00      0.00
Average:         eth1  81279.90   7750.70 120475.29    530.53      0.00      0.00      0.00

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 23a019cee279af1e502d05dc5f2363372d35b2ce..22b33da32ba46204beb1cb5fd7c725bfaa1dfc71 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7244,7 +7244,7 @@ static int tg3_poll_msix(struct napi_struct *napi, int budget)
 			if (tnapi == &tp->napi[1] && tp->rx_refill)
 				continue;
 
-			napi_complete(napi);
+			napi_complete_done(napi, work_done);
 			/* Reenable interrupts. */
 			tw32_mailbox(tnapi->int_mbox, tnapi->last_tag << 24);
 
@@ -7337,7 +7337,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 			sblk->status &= ~SD_STATUS_UPDATED;
 
 		if (likely(!tg3_has_work(tnapi))) {
-			napi_complete(napi);
+			napi_complete_done(napi, work_done);
 			tg3_int_reenable(tnapi);
 			break;
 		}
