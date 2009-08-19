From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/7] sky2: simplify list element error
Date: Tue, 18 Aug 2009 18:17:07 -0700
Message-ID: <20090819011738.760531366@vyatta.com>
References: <20090819011704.685802801@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:50669 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbZHSBWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 21:22:45 -0400
Content-Disposition: inline; filename=sky2-le-error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for list element error (which should only happen on hardware
errors) should be cleaner and safer. Gets rid of unused ring_size
argument, which makes next patch easier.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-08-18 09:33:15.490426779 -0700
+++ b/drivers/net/sky2.c	2009-08-18 09:34:30.664368374 -0700
@@ -2661,19 +2661,15 @@ static void sky2_mac_intr(struct sky2_hw
 }
 
 /* This should never happen it is a bug. */
-static void sky2_le_error(struct sky2_hw *hw, unsigned port,
-			  u16 q, unsigned ring_size)
+static void sky2_le_error(struct sky2_hw *hw, unsigned port, u16 q)
 {
 	struct net_device *dev = hw->dev[port];
-	struct sky2_port *sky2 = netdev_priv(dev);
-	unsigned idx;
-	const u64 *le = (q == Q_R1 || q == Q_R2)
-		? (u64 *) sky2->rx_le : (u64 *) sky2->tx_le;
-
-	idx = sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_GET_IDX));
-	printk(KERN_ERR PFX "%s: descriptor error q=%#x get=%u [%llx] put=%u\n",
-	       dev->name, (unsigned) q, idx, (unsigned long long) le[idx],
-	       (unsigned) sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_PUT_IDX)));
+	u16 idx = sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_GET_IDX));
+
+	dev_err(&hw->pdev->dev, PFX
+		"%s: descriptor error q=%#x get=%u put=%u\n",
+		dev->name, (unsigned) q, (unsigned) idx,
+		(unsigned) sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_PUT_IDX)));
 
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
@@ -2759,16 +2755,16 @@ static void sky2_err_intr(struct sky2_hw
 		sky2_mac_intr(hw, 1);
 
 	if (status & Y2_IS_CHK_RX1)
-		sky2_le_error(hw, 0, Q_R1, RX_LE_SIZE);
+		sky2_le_error(hw, 0, Q_R1);
 
 	if (status & Y2_IS_CHK_RX2)
-		sky2_le_error(hw, 1, Q_R2, RX_LE_SIZE);
+		sky2_le_error(hw, 1, Q_R2);
 
 	if (status & Y2_IS_CHK_TXA1)
-		sky2_le_error(hw, 0, Q_XA1, TX_RING_SIZE);
+		sky2_le_error(hw, 0, Q_XA1);
 
 	if (status & Y2_IS_CHK_TXA2)
-		sky2_le_error(hw, 1, Q_XA2, TX_RING_SIZE);
+		sky2_le_error(hw, 1, Q_XA2);
 }
 
 static int sky2_poll(struct napi_struct *napi, int work_limit)

-- 

