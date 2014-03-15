From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 04/16] ixgbe: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 18:00:41 -0700
Message-ID: <87eh24z35y.fsf_-_@xmission.com>
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
Received: from out03.mta.xmission.com ([166.70.13.233]:34376 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319AbaCOBAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:00:47 -0400
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 851c41377b47..04b8f0a5b0ce 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2076,7 +2076,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 #endif /* IXGBE_FCOE */
 	u16 cleaned_count = ixgbe_desc_unused(rx_ring);
 
-	do {
+	while (likely(total_rx_packets < budget)) {
 		union ixgbe_adv_rx_desc *rx_desc;
 		struct sk_buff *skb;
 
@@ -2151,7 +2151,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		/* update budget accounting */
 		total_rx_packets++;
-	} while (likely(total_rx_packets < budget));
+	}
 
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
-- 
1.7.5.4
