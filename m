From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 15/16] vxge: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 18:10:50 -0700
Message-ID: <87pplow9k5.fsf_-_@xmission.com>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:57419 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091AbaCOBK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:10:56 -0400
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
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index c83cedd26dec..9eb49edf4d5a 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -368,6 +368,9 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d",
 		ring->ndev->name, __func__, __LINE__);
 
+	if (ring->budget <= 0)
+		goto out;
+
 	do {
 		prefetch((char *)dtr + L1_CACHE_BYTES);
 		rx_priv = vxge_hw_ring_rxd_private_get(dtr);
@@ -525,6 +528,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 	if (first_dtr)
 		vxge_hw_ring_rxd_post_post_wmb(ringh, first_dtr);
 
+out:
 	vxge_debug_entryexit(VXGE_TRACE,
 				"%s:%d  Exiting...",
 				__func__, __LINE__);
-- 
1.7.5.4
