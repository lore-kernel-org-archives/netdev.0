From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: Fix a race between sky2_down and sky2_poll
Date: Tue, 16 Jun 2009 14:54:43 +0900
Message-ID: <392fb48f0906152254o6e8a757fl758d2b183777969b@mail.gmail.com>
References: <392fb48f0906090703q66fbaf56wbf1157f90b97df0f@mail.gmail.com>
	 <20090611100448.09a9b730@nehalam>
	 <392fb48f0906120616n123d8b57h9ef7c8e1735d26bf@mail.gmail.com>
	 <20090612071614.312e715d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:54307 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936318AbZFPFym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 01:54:42 -0400
Received: by bwz9 with SMTP id 9so3798298bwz.37
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 22:54:43 -0700 (PDT)
In-Reply-To: <20090612071614.312e715d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/6/12 Stephen Hemminger <shemminger@linux-foundation.org>:

> This breaks on 2 port boards. On dual port boards, both ports share
> the same IRQ.

Hi Stephen,

OK, I can see the status ring is shared, and my previous patch will
interfere with the second port's operation.

As far as I can tell from testing here, the status buffer is updated
after the Rx shutdown procedure is complete. i.e. After sky2_rx_stop()
is complete and after the Rx chain is reset, I check that the status
buffer is empty (and it is), but at some time later see an
sky2_status_intr reporting status updates for the port that we've shut
down.

Does the following patch look better?

The msleep() could be removed if there's a way to make sure any
pending status updates have been flushed to the status ring buffer,
but that doesn't seem to be the case with the current code.

Calling sky2_status_intr() directly seems to hang the receiver in a
way that is unrecoverable by doing ifup/ifdown, so I have refactored
sky2_status_intr into a function that doesn't do the SC_STAT_CLR_IRQ.

thanks,

Mike



------------------

Subject: [PATCH] sky2: Fix race condition in sky2_down

Empty the status ring after shutting down the receiver in sky2_down.
Refactor sky2_status_intr into sky2_process_status to allow calling
from outside an interrupt context.
---
 drivers/net/sky2.c |  254 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 142 insertions(+), 112 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 6b5946f..670cf52 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -148,6 +148,7 @@ static const unsigned rxqaddr[] = { Q_R1, Q_R2 };
 static const u32 portirq_msk[] = { Y2_IS_PORT_1, Y2_IS_PORT_2 };

 static void sky2_set_multicast(struct net_device *dev);
+static void sky2_synchronize(struct sky2_hw *hw);

 /* Access to PHY via serial interconnect */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
@@ -1806,7 +1807,8 @@ static int sky2_down(struct net_device *dev)
 	imask &= ~portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);

-	synchronize_irq(hw->pdev->irq);
+	/* disable soft interrupts */
+	napi_disable(&hw->napi);

 	sky2_gmac_reset(hw, port);

@@ -1821,9 +1823,6 @@ static int sky2_down(struct net_device *dev)
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);

-	/* Make sure no packets are pending */
-	napi_synchronize(&hw->napi);
-
 	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);

 	/* Workaround shared GMAC reset */
@@ -1859,6 +1858,10 @@ static int sky2_down(struct net_device *dev)
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);

+	/* flush the status ring */
+	msleep(1);
+	sky2_synchronize(hw);
+
 	sky2_tx_clean(dev);
 	sky2_rx_clean(sky2);

@@ -1877,6 +1880,9 @@ static int sky2_down(struct net_device *dev)
 	sky2->rx_ring = NULL;
 	sky2->tx_ring = NULL;

+	/* re-enable soft interrupts */
+	napi_enable(&hw->napi);
+
 	return 0;
 }

@@ -2344,135 +2350,150 @@ static inline void sky2_tx_done(struct
net_device *dev, u16 last)
 }

 /* Process status response ring */
-static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
+static int sky2_process_status(struct sky2_hw *hw, unsigned *rx)
 {
+	struct sky2_port *sky2;
+	struct sky2_status_le *le  = hw->st_le + hw->st_idx;
+	unsigned port;
+	struct net_device *dev;
+	struct sk_buff *skb;
+	u32 status;
+	u16 length;
+	u8 opcode = le->opcode;
 	int work_done = 0;
-	unsigned rx[2] = { 0, 0 };

-	rmb();
-	do {
-		struct sky2_port *sky2;
-		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
-		unsigned port;
-		struct net_device *dev;
-		struct sk_buff *skb;
-		u32 status;
-		u16 length;
-		u8 opcode = le->opcode;
-
-		if (!(opcode & HW_OWNER))
-			break;
+	hw->st_idx = RING_NEXT(hw->st_idx, STATUS_RING_SIZE);

-		hw->st_idx = RING_NEXT(hw->st_idx, STATUS_RING_SIZE);
-
-		port = le->css & CSS_LINK_BIT;
-		dev = hw->dev[port];
-		sky2 = netdev_priv(dev);
-		length = le16_to_cpu(le->length);
-		status = le32_to_cpu(le->status);
-
-		le->opcode = 0;
-		switch (opcode & ~HW_OWNER) {
-		case OP_RXSTAT:
-			++rx[port];
-			skb = sky2_receive(dev, length, status);
-			if (unlikely(!skb)) {
-				dev->stats.rx_dropped++;
-				break;
-			}
+	if (!(opcode & HW_OWNER))
+		goto error;

-			/* This chip reports checksum status differently */
-			if (hw->flags & SKY2_HW_NEW_LE) {
-				if (sky2->rx_csum &&
-				    (le->css & (CSS_ISIPV4 | CSS_ISIPV6)) &&
-				    (le->css & CSS_TCPUDPCSOK))
-					skb->ip_summed = CHECKSUM_UNNECESSARY;
-				else
-					skb->ip_summed = CHECKSUM_NONE;
-			}
+	port = le->css & CSS_LINK_BIT;
+	dev = hw->dev[port];
+	sky2 = netdev_priv(dev);
+	length = le16_to_cpu(le->length);
+	status = le32_to_cpu(le->status);

-			skb->protocol = eth_type_trans(skb, dev);
-			dev->stats.rx_packets++;
-			dev->stats.rx_bytes += skb->len;
-			dev->last_rx = jiffies;
+	/* rx_ring may have been free'd in sky2_down */
+	if (unlikely(!sky2->rx_ring)) {
+		printk(KERN_INFO "sky2_status_intr: rx_ring NULL opcode %02x\n", opcode);
+		goto error;
+	}
+
+	le->opcode = 0;
+	switch (opcode & ~HW_OWNER) {
+	case OP_RXSTAT:
+		++rx[port];
+		skb = sky2_receive(dev, length, status);
+		if (unlikely(!skb)) {
+			dev->stats.rx_dropped++;
+			break;
+		}
+
+		/* This chip reports checksum status differently */
+		if (hw->flags & SKY2_HW_NEW_LE) {
+			if (sky2->rx_csum &&
+			    (le->css & (CSS_ISIPV4 | CSS_ISIPV6)) &&
+			    (le->css & CSS_TCPUDPCSOK))
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			else
+				skb->ip_summed = CHECKSUM_NONE;
+		}
+
+		skb->protocol = eth_type_trans(skb, dev);
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
+		dev->last_rx = jiffies;

 #ifdef SKY2_VLAN_TAG_USED
-			if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
-				vlan_hwaccel_receive_skb(skb,
-							 sky2->vlgrp,
-							 be16_to_cpu(sky2->rx_tag));
-			} else
+		if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
+			vlan_hwaccel_receive_skb(skb,
+						 sky2->vlgrp,
+						 be16_to_cpu(sky2->rx_tag));
+		} else
 #endif
-				netif_receive_skb(skb);
+			netif_receive_skb(skb);

-			/* Stop after net poll weight */
-			if (++work_done >= to_do)
-				goto exit_loop;
-			break;
+		/* Stop after net poll weight */
+		work_done++;
+		break;

 #ifdef SKY2_VLAN_TAG_USED
-		case OP_RXVLAN:
-			sky2->rx_tag = length;
-			break;
+	case OP_RXVLAN:
+		sky2->rx_tag = length;
+		break;

-		case OP_RXCHKSVLAN:
-			sky2->rx_tag = length;
-			/* fall through */
+	case OP_RXCHKSVLAN:
+		sky2->rx_tag = length;
+		/* fall through */
 #endif
-		case OP_RXCHKS:
-			if (!sky2->rx_csum)
-				break;
-
-			/* If this happens then driver assuming wrong format */
-			if (unlikely(hw->flags & SKY2_HW_NEW_LE)) {
-				if (net_ratelimit())
-					printk(KERN_NOTICE "%s: unexpected"
-					       " checksum status\n",
-					       dev->name);
-				break;
-			}
-
-			/* Both checksum counters are programmed to start at
-			 * the same offset, so unless there is a problem they
-			 * should match. This failure is an early indication that
-			 * hardware receive checksumming won't work.
-			 */
-			if (likely(status >> 16 == (status & 0xffff))) {
-				skb = sky2->rx_ring[sky2->rx_next].skb;
-				skb->ip_summed = CHECKSUM_COMPLETE;
-				skb->csum = status & 0xffff;
-			} else {
-				printk(KERN_NOTICE PFX "%s: hardware receive "
-				       "checksum problem (status = %#x)\n",
-				       dev->name, status);
-				sky2->rx_csum = 0;
-				sky2_write32(sky2->hw,
-					     Q_ADDR(rxqaddr[port], Q_CSR),
-					     BMU_DIS_RX_CHKSUM);
-			}
+	case OP_RXCHKS:
+		if (!sky2->rx_csum)
 			break;

-		case OP_TXINDEXLE:
-			/* TX index reports status for both ports */
-			BUILD_BUG_ON(TX_RING_SIZE > 0x1000);
-			sky2_tx_done(hw->dev[0], status & 0xfff);
-			if (hw->dev[1])
-				sky2_tx_done(hw->dev[1],
-				     ((status >> 24) & 0xff)
-					     | (u16)(length & 0xf) << 8);
+		/* If this happens then driver assuming wrong format */
+		if (unlikely(hw->flags & SKY2_HW_NEW_LE)) {
+			if (net_ratelimit())
+				printk(KERN_NOTICE "%s: unexpected"
+				       " checksum status\n",
+				       dev->name);
 			break;
+		}

-		default:
-			if (net_ratelimit())
-				printk(KERN_WARNING PFX
-				       "unknown status opcode 0x%x\n", opcode);
+		/* Both checksum counters are programmed to start at
+		 * the same offset, so unless there is a problem they
+		 * should match. This failure is an early indication that
+		 * hardware receive checksumming won't work.
+		 */
+		if (likely(status >> 16 == (status & 0xffff))) {
+			skb = sky2->rx_ring[sky2->rx_next].skb;
+			skb->ip_summed = CHECKSUM_COMPLETE;
+			skb->csum = status & 0xffff;
+		} else {
+			printk(KERN_NOTICE PFX "%s: hardware receive "
+			       "checksum problem (status = %#x)\n",
+			       dev->name, status);
+			sky2->rx_csum = 0;
+			sky2_write32(sky2->hw,
+				     Q_ADDR(rxqaddr[port], Q_CSR),
+				     BMU_DIS_RX_CHKSUM);
 		}
-	} while (hw->st_idx != idx);
+		break;

-	/* Fully processed status ring so clear irq */
-	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+	case OP_TXINDEXLE:
+		/* TX index reports status for both ports */
+		BUILD_BUG_ON(TX_RING_SIZE > 0x1000);
+		sky2_tx_done(hw->dev[0], status & 0xfff);
+		if (hw->dev[1])
+			sky2_tx_done(hw->dev[1],
+			     ((status >> 24) & 0xff)
+				     | (u16)(length & 0xf) << 8);
+		break;
+
+	default:
+		if (net_ratelimit())
+			printk(KERN_WARNING PFX
+			       "unknown status opcode 0x%x\n", opcode);
+	}
+error:
+	return work_done;
+}
+
+static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
+{
+	int work_done = 0;
+	unsigned rx[2] = { 0, 0 };
+
+	rmb();
+
+	while (work_done < to_do) {
+		work_done += sky2_process_status(hw, rx);
+		if (hw->st_idx == idx) {
+			/* Fully processed status ring so clear irq */
+			sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+			break;
+		}
+	}

-exit_loop:
 	if (rx[0])
 		sky2_rx_update(netdev_priv(hw->dev[0]), Q_R1);

@@ -2741,6 +2762,15 @@ done:
 	return work_done;
 }

+/* Process all pending status entries */
+static void sky2_synchronize(struct sky2_hw *hw)
+{
+	unsigned rx[2];
+	while (sky2_read16(hw, STAT_PUT_IDX) != hw->st_idx) {
+		sky2_process_status(hw, rx);
+	}
+}
+
 static irqreturn_t sky2_intr(int irq, void *dev_id)
 {
 	struct sky2_hw *hw = dev_id;
-- 
1.5.6.5
