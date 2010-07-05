From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] sun3_82586: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:13:10 +0400
Message-ID: <1278331992-15792-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:47228 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162Ab0GEMNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 08:13:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/sun3_82586.c |   35 +++++++++++++++++------------------
 1 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index 1513123..b6ae53b 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -142,7 +142,6 @@ static void    sun3_82586_rnr_int(struct net_device *dev);
 
 struct priv
 {
-	struct net_device_stats stats;
 	unsigned long base;
 	char *memtop;
 	long int lock;
@@ -788,10 +787,10 @@ static void sun3_82586_rcv_int(struct net_device *dev)
 						skb_copy_to_linear_data(skb,(char *) p->base+swab32((unsigned long) rbd->buffer),totlen);
 						skb->protocol=eth_type_trans(skb,dev);
 						netif_rx(skb);
-						p->stats.rx_packets++;
+						dev->stats.rx_packets++;
 					}
 					else
-						p->stats.rx_dropped++;
+						dev->stats.rx_dropped++;
 				}
 				else
 				{
@@ -812,13 +811,13 @@ static void sun3_82586_rcv_int(struct net_device *dev)
 					totlen += rstat & RBD_MASK;
 					rbd->status = 0;
 					printk("%s: received oversized frame! length: %d\n",dev->name,totlen);
-					p->stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 			 }
 		}
 		else /* frame !(ok), only with 'save-bad-frames' */
 		{
 			printk("%s: oops! rfd-error-status: %04x\n",dev->name,status);
-			p->stats.rx_errors++;
+			dev->stats.rx_errors++;
 		}
 		p->rfd_top->stat_high = 0;
 		p->rfd_top->last = RFD_SUSP; /* maybe exchange by RFD_LAST */
@@ -885,7 +884,7 @@ static void sun3_82586_rnr_int(struct net_device *dev)
 {
 	struct priv *p = netdev_priv(dev);
 
-	p->stats.rx_errors++;
+	dev->stats.rx_errors++;
 
 	WAIT_4_SCB_CMD();		/* wait for the last cmd, WAIT_4_FULLSTAT?? */
 	p->scb->cmd_ruc = RUC_ABORT; /* usually the RU is in the 'no resource'-state .. abort it now. */
@@ -918,29 +917,29 @@ static void sun3_82586_xmt_int(struct net_device *dev)
 
 	if(status & STAT_OK)
 	{
-		p->stats.tx_packets++;
-		p->stats.collisions += (status & TCMD_MAXCOLLMASK);
+		dev->stats.tx_packets++;
+		dev->stats.collisions += (status & TCMD_MAXCOLLMASK);
 	}
 	else
 	{
-		p->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		if(status & TCMD_LATECOLL) {
 			printk("%s: late collision detected.\n",dev->name);
-			p->stats.collisions++;
+			dev->stats.collisions++;
 		}
 		else if(status & TCMD_NOCARRIER) {
-			p->stats.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 			printk("%s: no carrier detected.\n",dev->name);
 		}
 		else if(status & TCMD_LOSTCTS)
 			printk("%s: loss of CTS detected.\n",dev->name);
 		else if(status & TCMD_UNDERRUN) {
-			p->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			printk("%s: DMA underrun detected.\n",dev->name);
 		}
 		else if(status & TCMD_MAXCOLL) {
 			printk("%s: Max. collisions exceeded.\n",dev->name);
-			p->stats.collisions += 16;
+			dev->stats.collisions += 16;
 		}
 	}
 
@@ -1129,12 +1128,12 @@ static struct net_device_stats *sun3_82586_get_stats(struct net_device *dev)
 	ovrn = swab16(p->scb->ovrn_errs);
 	p->scb->ovrn_errs = 0;
 
-	p->stats.rx_crc_errors += crc;
-	p->stats.rx_fifo_errors += ovrn;
-	p->stats.rx_frame_errors += aln;
-	p->stats.rx_dropped += rsc;
+	dev->stats.rx_crc_errors += crc;
+	dev->stats.rx_fifo_errors += ovrn;
+	dev->stats.rx_frame_errors += aln;
+	dev->stats.rx_dropped += rsc;
 
-	return &p->stats;
+	return &dev->stats;
 }
 
 /********************************************************
-- 
1.7.0.4

