From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/7 net-next v2] tg3: Disable multiple TX rings by
 default due to hardware flaw
Date: Fri, 28 Sep 2012 10:12:43 -0700
Message-ID: <1348852363-8582-7-git-send-email-mchan@broadcom.com>
References: <1348852363-8582-1-git-send-email-mchan@broadcom.com>
 <1348852363-8582-2-git-send-email-mchan@broadcom.com>
 <1348852363-8582-3-git-send-email-mchan@broadcom.com>
 <1348852363-8582-4-git-send-email-mchan@broadcom.com>
 <1348852363-8582-5-git-send-email-mchan@broadcom.com>
 <1348852363-8582-6-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3008 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355Ab2I2BjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 21:39:06 -0400
In-Reply-To: <1348852363-8582-6-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simple round-robin hardware TX scheduling can cause starvation of TX rings
with small packets when other TX rings have large TSO or jumbo packets.

In the simplest case, consider 2 TCP streams running in opposite
directions.  The TSO TX traffic will hash to one ring and the ACKs for the
incoming data on a different TCP connection will hash to a different TX
ring.  The hardware fetches one complete TSO packet (up to 64K data)
before servicing the other TX ring.  When it gets to the other TX ring, it
will only fetch one packet (64-byte ACK packet in this case).  After that,
it will switch back to the 1st ring filled with more TSO packets.  Because
only one ACK can go out roughly every 500 usec in this case, the incoming
data rate becomes very low.

Update version to 3.125.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 74eea2f..24f6623 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -92,10 +92,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			124
+#define TG3_MIN_NUM			125
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"March 21, 2012"
+#define DRV_MODULE_RELDATE	"September 26, 2012"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
@@ -10245,10 +10245,13 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		tp->rxq_cnt = netif_get_num_default_rss_queues();
 	if (tp->rxq_cnt > tp->rxq_max)
 		tp->rxq_cnt = tp->rxq_max;
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) &&
-	    !tp->txq_req)
-		tp->txq_cnt = min(tp->rxq_cnt, tp->txq_max);
+
+	/* Disable multiple TX rings by default.  Simple round-robin hardware
+	 * scheduling of the TX rings can cause starvation of rings with
+	 * small packets when other rings have TSO or jumbo packets.
+	 */
+	if (!tp->txq_req)
+		tp->txq_cnt = 1;
 
 	tp->irq_cnt = tg3_irq_count(tp);
 
-- 
1.7.1
