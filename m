From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 1/1] net/hyperv: Fix the code handling tx busy
Date: Mon, 19 Mar 2012 10:02:29 -0700
Message-ID: <1332176549-30960-2-git-send-email-haiyangz@microsoft.com>
References: <1332176549-30960-1-git-send-email-haiyangz@microsoft.com>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332176549-30960-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of dropping the packet, we keep the skb buffer, and return
NETDEV_TX_BUSY to let upper layer retry send. This will not cause
endless loop, because the host is taking data away from ring buffer.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 2517d20..dd29478 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -223,13 +223,10 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		net->stats.tx_bytes += skb->len;
 		net->stats.tx_packets++;
 	} else {
-		/* we are shutting down or bus overloaded, just drop packet */
-		net->stats.tx_dropped++;
 		kfree(packet);
-		dev_kfree_skb_any(skb);
 	}
 
-	return NETDEV_TX_OK;
+	return ret ? NETDEV_TX_BUSY : NETDEV_TX_OK;
 }
 
 /*
-- 
1.7.4.1
