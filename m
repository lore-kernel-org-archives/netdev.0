From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 4/6] net: hip04: Don't free the tx skb when the buffer is not ready for xmit
Date: Wed, 15 Apr 2015 20:30:06 +0800
Message-ID: <1429101008-9464-5-git-send-email-dingtianhong@huawei.com>
References: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sergei.shtylyov@cogentembedded.com>,
	<linux-arm-kernel@lists.infradead.org>, <eric.dumazet@gmail.com>,
	<zhangfei.gao@linaro.org>, <joe@perches.com>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux@arm.linux.org.uk>
To: <arnd@arndb.de>, <davem@davemloft.net>, <grant.likely@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:5806 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227AbbDOMaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 08:30:23 -0400
In-Reply-To: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric pointed out the problem that the tx skb might already have be freed
by tx completion before enter the xmit queue, so don't notice the tx completion
until the skb is ready to be freed.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/hisilicon/hip04_eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 7533858..ff9d19c 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -480,8 +480,6 @@ static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	skb_tx_timestamp(skb);
 
 	hip04_set_xmit_desc(priv, phys);
-	priv->tx_head = TX_NEXT(tx_head);
-	count++;
 	netdev_sent_queue(ndev, skb->len);
 
 	stats->tx_bytes += skb->len;
@@ -489,6 +487,8 @@ static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	/* Ensure tx_head update visible to tx reclaim */
 	smp_wmb();
+	count++;
+	priv->tx_head = TX_NEXT(tx_head);
 
 	/* queue is getting full, better start cleaning up now */
 	if (count >= priv->tx_coalesce_frames) {
-- 
1.8.0
