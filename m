From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2 net-next 5/9] sunvnet: add memory barrier before check for tx enable
Date: Tue,  7 Feb 2017 14:12:58 -0800
Message-ID: <1486505582-76823-6-git-send-email-shannon.nelson@oracle.com>
References: <1486505582-76823-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39446 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755551AbdBGWQi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 17:16:38 -0500
In-Reply-To: <1486505582-76823-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to allow the underlying LDC and outstanding memory operations
to potentially catch up with the driver's Tx requests, add a memory
barrier before checking again for available tx descriptors.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet_common.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 82273e6..6cb625a 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1453,6 +1453,7 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 	dr->prod = (dr->prod + 1) & (VNET_TX_RING_SIZE - 1);
 	if (unlikely(vnet_tx_dring_avail(dr) < 1)) {
 		netif_tx_stop_queue(txq);
+		smp_rmb();
 		if (vnet_tx_dring_avail(dr) > VNET_TX_WAKEUP_THRESH(dr))
 			netif_tx_wake_queue(txq);
 	}
-- 
1.7.1
