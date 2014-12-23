From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH v3] 3c59x: Fix memory leaks in vortex_open
Date: Tue, 23 Dec 2014 10:54:50 +0800
Message-ID: <1419303290-27565-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: davem@davemloft.net, nhorman@tuxdriver.com, ebiederm@xmission.com,
	dingtianhong@huawei.com, paul.gortmaker@windriver.com,
	justinvanwijngaarden@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:44870 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753970AbaLWCy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 21:54:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For linux-3.18.0
The driver calls __netdev_alloc_skb in vortex_open but lacks dev_kfree_skb
when vortex_up is failed, so memory leaks may occur in this situation.
This patch fixes this problem.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/3com/3c59x.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 41095eb..d0c5bee 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1782,6 +1782,16 @@ vortex_open(struct net_device *dev)
 	if (!retval)
 		goto out;
 
+	if (vp->full_bus_master_rx) {
+		for (i = 0; i < RX_RING_SIZE; i++) {
+			if (vp->rx_skbuff[i]) {
+				dev_kfree_skb(vp->rx_skbuff[i]);
+				vp->rx_skbuff[i] = NULL;
+			}
+		}
+		retval = -ENOMEM;
+	}
+
 err_free_irq:
 	free_irq(dev->irq, dev);
 err:
-- 
1.7.9.5
