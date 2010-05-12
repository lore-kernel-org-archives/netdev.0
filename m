From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC PATCH] bnx2: use netif_carrier_off to prevent tx timeout
Date: Wed, 12 May 2010 13:06:28 +0200
Message-ID: <20100512130628.69bc3890@dhcp-lab-109.englab.brq.redhat.com>
References: <20100512110921.0e3f45fc@dhcp-lab-109.englab.brq.redhat.com>
	<1273656458.2621.22.camel@edumazet-laptop>
	<20100512125815.0dad8ad0@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755661Ab0ELLE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 07:04:27 -0400
In-Reply-To: <20100512125815.0dad8ad0@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Touching ->trans_start make netdev watchdog timeouts only less probable.
Use netif_carrier_off to prevent timeout, lately we take care of tuning
carrier on.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
Patch was not tested!

 drivers/net/bnx2.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 667f419..44fc392 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -656,17 +656,9 @@ bnx2_netif_stop(struct bnx2 *bp, bool stop_cnic)
 	if (stop_cnic)
 		bnx2_cnic_stop(bp);
 	if (netif_running(bp->dev)) {
-		int i;
-
 		bnx2_napi_disable(bp);
 		netif_tx_disable(bp->dev);
-		/* prevent tx timeout */
-		for (i = 0; i <  bp->dev->num_tx_queues; i++) {
-			struct netdev_queue *txq;
-
-			txq = netdev_get_tx_queue(bp->dev, i);
-			txq->trans_start = jiffies;
-		}
+		netif_carrier_off(bp->dev);
 	}
 	bnx2_disable_int_sync(bp);
 }
@@ -6346,6 +6338,8 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
 	if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
 		bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
 
+	if (bp->link_up)
+		netif_carrier_on(bp->dev);
 	bnx2_netif_start(bp, false);
 }
 #endif
-- 
1.5.5.6


