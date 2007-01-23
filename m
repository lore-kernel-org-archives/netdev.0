From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] mv643xx_eth: Fix race condition in mv643xx_eth_free_tx_descs
Date: Tue, 23 Jan 2007 09:52:25 -0700
Message-ID: <20070123165225.GA20153@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thibaut VARENE <T-Bone@parisc-linux.org>,
	Jarek Poplawski <jarkao2@o2.pl>, mlachwani@mvista.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:3594 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932920AbXAWQw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 11:52:26 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Dale Farnsworth <dale@farnsworth.org>

mv643xx_eth: Fix race condition in mv643xx_eth_free_tx_descs

This bug was found and isolated by Thibaut VARENE <T-Bone@parisc-linux.org>
and Jarek Poplawski <jarkao2@o2.pl>.  This patch is a modification of their
fixes.  We acquire and release the lock for each descriptor that is freed
to minimize the time the lock is held.

---

 drivers/net/mv643xx_eth.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index c41ae42..b3bf864 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -314,6 +314,13 @@ int mv643xx_eth_free_tx_descs(struct net
 
 	while (mp->tx_desc_count > 0) {
 		spin_lock_irqsave(&mp->lock, flags);
+
+		/* tx_desc_count might have changed before acquiring the lock */
+		if (mp->tx_desc_count <= 0) {
+			spin_unlock_irqrestore(&mp->lock, flags);
+			return released;
+		}
+
 		tx_index = mp->tx_used_desc_q;
 		desc = &mp->p_tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
@@ -332,13 +339,13 @@ int mv643xx_eth_free_tx_descs(struct net
 		if (skb)
 			mp->tx_skb[tx_index] = NULL;
 
-		spin_unlock_irqrestore(&mp->lock, flags);
-
 		if (cmd_sts & ETH_ERROR_SUMMARY) {
 			printk("%s: Error in TX\n", dev->name);
 			mp->stats.tx_errors++;
 		}
 
+		spin_unlock_irqrestore(&mp->lock, flags);
+
 		if (cmd_sts & ETH_TX_FIRST_DESC)
 			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
 		else
