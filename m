From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 2/2] 8139cp: Don't receive packets when the napi budget == 0
Date: Tue, 11 Mar 2014 14:31:43 -0700
Message-ID: <87vbvk777k.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<877g808luk.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60689 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822AbaCKVbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:31:50 -0400
In-Reply-To: <877g808luk.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:30:11 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Processing any incoming packets with a with a napi budget of 0
is incorrect driver behavior.

This matters as netpoll will shortly call drivers with a budget of 0
to avoid receive packet processing happening in hard irq context.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com
---
 drivers/net/ethernet/realtek/8139cp.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index a3c1daa7ad5c..2bc728e65e24 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -476,7 +476,7 @@ rx_status_loop:
 	rx = 0;
 	cpw16(IntrStatus, cp_rx_intr_mask);
 
-	while (1) {
+	while (rx < budget) {
 		u32 status, len;
 		dma_addr_t mapping, new_mapping;
 		struct sk_buff *skb, *new_skb;
@@ -554,9 +554,6 @@ rx_next:
 		else
 			desc->opts1 = cpu_to_le32(DescOwn | cp->rx_buf_sz);
 		rx_tail = NEXT_RX(rx_tail);
-
-		if (rx >= budget)
-			break;
 	}
 
 	cp->rx_tail = rx_tail;
-- 
1.7.5.4
