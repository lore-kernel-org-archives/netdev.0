From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 03/16] igb: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 18:00:06 -0700
Message-ID: <87k3bwz36x.fsf_-_@xmission.com>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:57783 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319AbaCOBAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:00:12 -0400
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
 drivers/net/ethernet/intel/igb/igb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 340a3449e1e9..973224e43b11 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6946,7 +6946,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 	unsigned int total_bytes = 0, total_packets = 0;
 	u16 cleaned_count = igb_desc_unused(rx_ring);
 
-	do {
+	while (likely(total_packets < budget)) {
 		union e1000_adv_rx_desc *rx_desc;
 
 		/* return some buffers to hardware, one at a time is too slow */
@@ -6998,7 +6998,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 
 		/* update budget accounting */
 		total_packets++;
-	} while (likely(total_packets < budget));
+	}
 
 	/* place incomplete frames back on ring for completion */
 	rx_ring->skb = skb;
-- 
1.7.5.4
