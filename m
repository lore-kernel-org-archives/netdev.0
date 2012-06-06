From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Wed, 6 Jun 2012 17:43:55 +0900
Message-ID: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38708 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143Ab2FFIn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 04:43:58 -0400
Received: by pbbrp8 with SMTP id rp8so8643713pbb.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 01:43:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko reported Tx stalls on e1000e with BQL enabled.

e1000e has WTHRESH which determines when Tx descripters are written
back and successive Tx interrupts are generated, and setting WTHRESH
to 5 gives efficient bus utilization but this cause possible Tx stalls,
especially on BQL enabled system.

To avoid possible Tx stalls, change WTHRESH to 1.

Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  |    6 +++---
 drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 6e6fffb..dc28078 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -175,13 +175,13 @@ struct e1000_info;
 /*
  * in the case of WTHRESH, it appears at least the 82571/2 hardware
  * writes back 4 descriptors when WTHRESH=5, and 3 descriptors when
- * WTHRESH=4, and since we want 64 bytes at a time written back, set
- * it to 5
+ * WTHRESH=4, so setting 5 gives most efficient bus utilization but
+ * to avoid possible Tx hangs, set it to 1
  */
 #define E1000_TXDCTL_DMA_BURST_ENABLE                          \
 	(E1000_TXDCTL_GRAN | /* set descriptor granularity */  \
 	 E1000_TXDCTL_COUNT_DESC |                             \
-	 (5 << 16) | /* wthresh must be +1 more than desired */\
+	 (1 << 16) | /* wthresh must be +1 more than desired */\
 	 (1 << 8)  | /* hthresh */                             \
 	 0x1f)       /* pthresh */
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a4b0435..b031312 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2806,7 +2806,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		 * set up some performance related parameters to encourage the
 		 * hardware to use the bus more efficiently in bursts, depends
 		 * on the tx_int_delay to be enabled,
-		 * wthresh = 5 ==> burst write a cacheline (64 bytes) at a time
+		 * wthresh = 1 ==> burst write is disabled to consider Tx hangs
 		 * hthresh = 1 ==> prefetch when one or more available
 		 * pthresh = 0x1f ==> prefetch if internal cache 31 or less
 		 * BEWARE: this seems to work but should be considered first if
-- 
1.7.8.6
