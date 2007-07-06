From: Philippe De Muyter <phdm@macqel.be>
Subject: [PATCH] 7990 : Various fixes and cleanups
Date: Fri, 6 Jul 2007 11:58:28 +0200
Message-ID: <20070706095828.GA12270@muff.macqel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.macqel.be ([194.78.208.39]:11430 "EHLO mail.macqel.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760024AbXGFKVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 06:21:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This patch
- avoids 7990 blocking when no tx buffer is available,
- implements tx_bytes statistic that was missing
- sets skb->dev before calling netix_rx()
- improves readability and code efficiency in buffer rings initialisation
- avoids useless memset part for tx packets smaller than ETH_ZLEN

Signed-off-by: Philippe De Muyter <phdm@macqel.be>

diff -r 6c0a10cc415a drivers/net/7990.c
--- a/drivers/net/7990.c	Thu Jul  5 16:10:16 2007 -0700
+++ b/drivers/net/7990.c	Fri Jul  6 11:27:20 2007 +0200
@@ -179,12 +179,14 @@ static void lance_init_ring (struct net_
 	lp->tx_full = 0;
         /* Setup the Tx ring entries */
         for (i = 0; i < (1<<lp->lance_log_tx_bufs); i++) {
+		volatile struct lance_tx_desc *td;
+                td = &ib->btx_ring [i];
                 leptr = LANCE_ADDR(&aib->tx_buf[i][0]);
-                ib->btx_ring [i].tmd0      = leptr;
-                ib->btx_ring [i].tmd1_hadr = leptr >> 16;
-                ib->btx_ring [i].tmd1_bits = 0;
-                ib->btx_ring [i].length    = 0xf000; /* The ones required by tmd2 */
-                ib->btx_ring [i].misc      = 0;
+                td->tmd0      = leptr;
+                td->tmd1_hadr = leptr >> 16;
+                td->tmd1_bits = 0;
+                td->length    = 0xf000; /* The ones required by tmd2 */
+                td->misc      = 0;
                 if (DEBUG_IRING)
                    printk ("%d: 0x%8.8x\n", i, leptr);
         }
@@ -193,14 +195,16 @@ static void lance_init_ring (struct net_
         if (DEBUG_IRING)
                 printk ("RX rings:\n");
         for (i = 0; i < (1<<lp->lance_log_rx_bufs); i++) {
+		volatile struct lance_rx_desc *rd;
+                rd = &ib->brx_ring [i];
                 leptr = LANCE_ADDR(&aib->rx_buf[i][0]);
 
-                ib->brx_ring [i].rmd0      = leptr;
-                ib->brx_ring [i].rmd1_hadr = leptr >> 16;
-                ib->brx_ring [i].rmd1_bits = LE_R1_OWN;
+                rd->rmd0      = leptr;
+                rd->rmd1_hadr = leptr >> 16;
+                rd->rmd1_bits = LE_R1_OWN;
                 /* 0xf000 == bits that must be one (reserved, presumably) */
-                ib->brx_ring [i].length    = -RX_BUFF_SIZE | 0xf000;
-                ib->brx_ring [i].mblength  = 0;
+                rd->length    = -RX_BUFF_SIZE | 0xf000;
+                rd->mblength  = 0;
                 if (DEBUG_IRING)
                         printk ("%d: 0x%8.8x\n", i, leptr);
         }
@@ -331,6 +335,7 @@ static int lance_rx (struct net_device *
                                 return 0;
                         }
 
+                        skb->dev = dev;
                         skb_reserve (skb, 2);           /* 16 byte align */
                         skb_put (skb, len);             /* make room */
                         eth_copy_and_sum(skb,
@@ -541,9 +546,6 @@ int lance_start_xmit (struct sk_buff *sk
         static int outs;
 	unsigned long flags;
 
-        if (!TX_BUFFS_AVAIL)
-                return -1;
-
 	netif_stop_queue (dev);
 
         skblen = skb->len;
@@ -565,9 +567,11 @@ int lance_start_xmit (struct sk_buff *sk
         ib->btx_ring [entry].length = (-len) | 0xf000;
         ib->btx_ring [entry].misc = 0;
 
-	if (skb->len < ETH_ZLEN)
-		memset((void *)&ib->tx_buf[entry][0], 0, ETH_ZLEN);
         skb_copy_from_linear_data(skb, (void *)&ib->tx_buf[entry][0], skblen);
+    	if (skblen < ETH_ZLEN)
+    		memset((char *)&ib->tx_buf[entry][0] + skblen, 0, ETH_ZLEN - skblen);
+
+	lp->stats.tx_bytes += skblen;
 
         /* Now, give the packet to the lance */
         ib->btx_ring [entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
