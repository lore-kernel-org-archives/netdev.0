From: Willem de Bruijn <willemb@google.com>
Subject: [net-next 1/4] octeon: remove deprecated syststamp timestamp
Date: Fri, 25 Jul 2014 18:01:29 -0400
Message-ID: <1406325692-616-2-git-send-email-willemb@google.com>
References: <1406325692-616-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	kreese@caviumnetworks.com, ddaney@caviumnetworks.com,
	dborkman@redhat.com, jdmason@kudzu.us,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:58364 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbaGYWBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 18:01:45 -0400
Received: by mail-qa0-f74.google.com with SMTP id j15so826587qaq.1
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 15:01:44 -0700 (PDT)
In-Reply-To: <1406325692-616-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware timestamps can be exposed to userspace in raw hardware format
(hwtstamp) as well as converted to system time (syststamp). The second
variant is deprecated and only implemented by this driver.

The preferred method of hardware timestamp generation is to combine
hwtstamp with a device PTP clock. Octeon has its own PTP library
that relies on a shared memory interface to the PTP clock device.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 25 +------------------------
 1 file changed, 1 insertion(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 7dc3e9b..979c698 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -247,28 +247,6 @@ static void octeon_mgmt_rx_fill_ring(struct net_device *netdev)
 	}
 }
 
-static ktime_t ptp_to_ktime(u64 ptptime)
-{
-	ktime_t ktimebase;
-	u64 ptpbase;
-	unsigned long flags;
-
-	local_irq_save(flags);
-	/* Fill the icache with the code */
-	ktime_get_real();
-	/* Flush all pending operations */
-	mb();
-	/* Read the time and PTP clock as close together as
-	 * possible. It is important that this sequence take the same
-	 * amount of time to reduce jitter
-	 */
-	ktimebase = ktime_get_real();
-	ptpbase = cvmx_read_csr(CVMX_MIO_PTP_CLOCK_HI);
-	local_irq_restore(flags);
-
-	return ktime_sub_ns(ktimebase, ptpbase - ptptime);
-}
-
 static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
 {
 	union cvmx_mixx_orcnt mix_orcnt;
@@ -312,12 +290,12 @@ static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
 		/* Read the hardware TX timestamp if one was recorded */
 		if (unlikely(re.s.tstamp)) {
 			struct skb_shared_hwtstamps ts;
+			memset(&ts, 0, sizeof(ts));
 			/* Read the timestamp */
 			u64 ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
 			/* Remove the timestamp from the FIFO */
 			cvmx_write_csr(CVMX_MIXX_TSCTL(p->port), 0);
 			/* Tell the kernel about the timestamp */
-			ts.syststamp = ptp_to_ktime(ns);
 			ts.hwtstamp = ns_to_ktime(ns);
 			skb_tstamp_tx(skb, &ts);
 		}
@@ -429,7 +407,6 @@ good:
 			struct skb_shared_hwtstamps *ts;
 			ts = skb_hwtstamps(skb);
 			ts->hwtstamp = ns_to_ktime(ns);
-			ts->syststamp = ptp_to_ktime(ns);
 			__skb_pull(skb, 8);
 		}
 		skb->protocol = eth_type_trans(skb, netdev);
-- 
2.0.0.526.g5318336
