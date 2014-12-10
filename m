From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 6/6] ethernet/broadcom: Use napi_alloc_skb instead
 of netdev_alloc_skb_ip_align
Date: Tue, 09 Dec 2014 19:41:17 -0800
Message-ID: <20141210034117.2114.50589.stgit@ahduyck-vm-fedora20>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, eric.dumazet@gmail.com,
	Ariel Elior <ariel.elior@qlogic.com>, brouer@redhat.com,
	Gary Zambrano <zambrano@broadcom.com>, davem@davemloft.net,
	ast@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51227 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755217AbaLJEOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 23:14:37 -0500
In-Reply-To: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the calls to netdev_alloc_skb_ip_align in the
copybreak paths.

Cc: Gary Zambrano <zambrano@broadcom.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Ariel Elior <ariel.elior@qlogic.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/broadcom/b44.c             |    2 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index ffeaf47..d86d6ba 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -836,7 +836,7 @@ static int b44_rx(struct b44 *bp, int budget)
 			struct sk_buff *copy_skb;
 
 			b44_recycle_rx(bp, cons, bp->rx_prod);
-			copy_skb = netdev_alloc_skb_ip_align(bp->dev, len);
+			copy_skb = napi_alloc_skb(&bp->napi, len);
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 3e8d1a8..21206d3 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -385,7 +385,7 @@ static int bcm_enet_receive_queue(struct net_device *dev, int budget)
 		if (len < copybreak) {
 			struct sk_buff *nskb;
 
-			nskb = netdev_alloc_skb_ip_align(dev, len);
+			nskb = napi_alloc_skb(&priv->napi, len);
 			if (!nskb) {
 				/* forget packet, just rearm desc */
 				dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index b4d71fd..1d1147c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1015,7 +1015,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		 */
 		if ((bp->dev->mtu > ETH_MAX_PACKET_SIZE) &&
 		    (len <= RX_COPY_THRESH)) {
-			skb = netdev_alloc_skb_ip_align(bp->dev, len);
+			skb = napi_alloc_skb(&fp->napi, len);
 			if (skb == NULL) {
 				DP(NETIF_MSG_RX_ERR | NETIF_MSG_RX_STATUS,
 				   "ERROR  packet dropped because of alloc failure\n");
