From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] tg3 shutdown sequence update (try 2)
Date: Mon, 25 Nov 2002 01:48:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE1C7A1.7000701@pobox.com>
References: <3DE1C468.1060806@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030408030209010408020802"
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <3DE1C468.1060806@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030408030209010408020802
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Re-sending correct patch :)

--------------030408030209010408020802
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

===== drivers/net/tg3.c 1.41 vs 1.43 =====
--- 1.41/drivers/net/tg3.c	Wed Nov 20 00:49:23 2002
+++ 1.43/drivers/net/tg3.c	Mon Nov 25 01:10:05 2002
@@ -3088,6 +3088,9 @@
 	u32 val;
 
 	val = tr32(ofs);
+	if ((val & enable_bit) == 0)
+		return 0;
+
 	val &= ~enable_bit;
 	tw32(ofs, val);
 	tr32(ofs);
@@ -3112,16 +3115,12 @@
 /* tp->lock is held. */
 static int tg3_abort_hw(struct tg3 *tp)
 {
-	int i, err;
+	int err;
 
 	tg3_disable_ints(tp);
 
-	tp->rx_mode &= ~RX_MODE_ENABLE;
-	tw32(MAC_RX_MODE, tp->rx_mode);
-	tr32(MAC_RX_MODE);
-	udelay(10);
-
-	err  = tg3_stop_block(tp, RCVBDI_MODE, RCVBDI_MODE_ENABLE);
+	err  = tg3_stop_block(tp, MAC_RX_MODE, RX_MODE_ENABLE);
+	err |= tg3_stop_block(tp, RCVBDI_MODE, RCVBDI_MODE_ENABLE);
 	err |= tg3_stop_block(tp, RCVLPC_MODE, RCVLPC_MODE_ENABLE);
 	err |= tg3_stop_block(tp, RCVLSC_MODE, RCVLSC_MODE_ENABLE);
 	err |= tg3_stop_block(tp, RCVDBDI_MODE, RCVDBDI_MODE_ENABLE);
@@ -3133,40 +3132,21 @@
 	err |= tg3_stop_block(tp, SNDDATAI_MODE, SNDDATAI_MODE_ENABLE);
 	err |= tg3_stop_block(tp, RDMAC_MODE, RDMAC_MODE_ENABLE);
 	err |= tg3_stop_block(tp, SNDDATAC_MODE, SNDDATAC_MODE_ENABLE);
+	err |= tg3_stop_block(tp, DMAC_MODE, DMAC_MODE_ENABLE);
 	err |= tg3_stop_block(tp, SNDBDC_MODE, SNDBDC_MODE_ENABLE);
-	if (err)
-		goto out;
-
-	tp->mac_mode &= ~MAC_MODE_TDE_ENABLE;
-	tw32(MAC_MODE, tp->mac_mode);
-	tr32(MAC_MODE);
-	udelay(40);
-
-	tp->tx_mode &= ~TX_MODE_ENABLE;
-	tw32(MAC_TX_MODE, tp->tx_mode);
-	tr32(MAC_TX_MODE);
+	err |= tg3_stop_block(tp, MAC_TX_MODE, TX_MODE_ENABLE);
 
-	for (i = 0; i < MAX_WAIT_CNT; i++) {
-		udelay(100);
-		if (!(tr32(MAC_TX_MODE) & TX_MODE_ENABLE))
-			break;
-	}
-	if (i >= MAX_WAIT_CNT) {
-		printk(KERN_ERR PFX "tg3_abort_hw timed out for %s, "
-		       "TX_MODE_ENABLE will not clear MAC_TX_MODE=%08x\n",
-		       tp->dev->name, tr32(MAC_TX_MODE));
-		return -ENODEV;
-	}
-
-	err  = tg3_stop_block(tp, HOSTCC_MODE, HOSTCC_MODE_ENABLE);
+	err |= tg3_stop_block(tp, HOSTCC_MODE, HOSTCC_MODE_ENABLE);
 	err |= tg3_stop_block(tp, WDMAC_MODE, WDMAC_MODE_ENABLE);
 	err |= tg3_stop_block(tp, MBFREE_MODE, MBFREE_MODE_ENABLE);
 
 	tw32(FTQ_RESET, 0xffffffff);
 	tw32(FTQ_RESET, 0x00000000);
+	tr32(FTQ_RESET);
 
 	err |= tg3_stop_block(tp, BUFMGR_MODE, BUFMGR_MODE_ENABLE);
 	err |= tg3_stop_block(tp, MEMARB_MODE, MEMARB_MODE_ENABLE);
+
 	if (err)
 		goto out;
 

--------------030408030209010408020802--
