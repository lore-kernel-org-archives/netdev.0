From: fgao@ikuai8.com
Subject: [PATCH v1 1/1 net-next] 8139cp: Fix one possible deadloop in cp_rx_poll
Date: Thu, 25 Aug 2016 09:45:39 +0800
Message-ID: <1472089539-11543-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: dwmw2@infradead.org, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg340.qq.com ([14.17.44.35]:42379 "EHLO smtpbg340.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753521AbcHYEvV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 00:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When cp_rx_poll does not get enough packet, it will check the rx
interrupt status again. If so, it will jumpt to rx_status_loop again.
But the goto jump resets the rx variable as zero too.

As a result, it causes one possible deadloop. Assume this case,
rx_status_loop only gets the packet count which is less than budget,
and (cpr16(IntrStatus) & cp_rx_intr_mask) condition is always true.
It causes the deadloop happens and system is blocked.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/ethernet/realtek/8139cp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index deae10d..5297bf7 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -467,8 +467,8 @@ static int cp_rx_poll(struct napi_struct *napi, int budget)
 	unsigned int rx_tail = cp->rx_tail;
 	int rx;
 
-rx_status_loop:
 	rx = 0;
+rx_status_loop:
 	cpw16(IntrStatus, cp_rx_intr_mask);
 
 	while (rx < budget) {
-- 
1.9.1
