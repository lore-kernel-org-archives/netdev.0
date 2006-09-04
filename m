From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sky2 problem on powerpc
Date: Mon, 04 Sep 2006 17:42:27 +1000
Message-ID: <1157355748.22705.32.camel@localhost.localdomain>
References: <1157347462.22705.16.camel@localhost.localdomain>
	 <1157354470.22705.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50339 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S932455AbWIDHmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 03:42:39 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1157354470.22705.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes sky2 driver on big endian machines. I choose not to use the
hardware byteswap facility as it would have required to have a different
definition of the various ring data structures and it looks ugly :) On
powerpc, there is pretty much no overhead at doing byteswap.

The patch has a couple of places where I reversed 2 assignments, they
are harmless, it was before I figured out that the chip will
(apparently) not access a descriptor before it's been told to do so via
MMIO, and thus the order of the writes to the descriptors is irrelevant
(I was also adding wmb's though I removed them).

There is a couple of places where we were doing a BE and not LE
conversion of a descriptor field (typically in the VLAN code). I'm not
sure what's up there but BE "felt" wrong. I have turned them into LE
conversions but then I haven't tested VLAN, and I might just
misudnerstand what's happening there so I'll let you decide what to do
about those.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Index: linux-work/drivers/net/sky2.c
===================================================================
--- linux-work.orig/drivers/net/sky2.c	2006-09-04 17:35:20.000000000 +1000
+++ linux-work/drivers/net/sky2.c	2006-09-04 17:41:50.000000000 +1000
@@ -811,8 +811,9 @@ static void rx_set_checksum(struct sky2_
 	struct sky2_rx_le *le;
 
 	le = sky2_next_rx(sky2);
-	le->addr = (ETH_HLEN << 16) | ETH_HLEN;
+	le->addr = cpu_to_le32((ETH_HLEN << 16) | ETH_HLEN);
 	le->ctrl = 0;
+	le->length = 0;
 	le->opcode = OP_TCPSTART | HW_OWNER;
 
 	sky2_write32(sky2->hw,
@@ -1001,7 +1002,6 @@ static int sky2_rx_start(struct sky2_por
 		sky2_rx_add(sky2, re->mapaddr);
 	}
 
-
 	/*
 	 * The receiver hangs if it receives frames larger than the
 	 * packet buffer. As a workaround, truncate oversize frames, but
@@ -1250,8 +1250,8 @@ static int sky2_xmit_frame(struct sk_buf
 		le = get_tx_le(sky2);
 		le->tx.tso.size = cpu_to_le16(mss);
 		le->tx.tso.rsvd = 0;
-		le->opcode = OP_LRGLEN | HW_OWNER;
 		le->ctrl = 0;
+		le->opcode = OP_LRGLEN | HW_OWNER;
 		sky2->tx_last_mss = mss;
 	}
 
@@ -1262,11 +1262,11 @@ static int sky2_xmit_frame(struct sk_buf
 		if (!le) {
 			le = get_tx_le(sky2);
 			le->tx.addr = 0;
-			le->opcode = OP_VLAN|HW_OWNER;
 			le->ctrl = 0;
+			le->opcode = OP_VLAN|HW_OWNER;
 		} else
 			le->opcode |= OP_VLAN;
-		le->length = cpu_to_be16(vlan_tx_tag_get(skb));
+		le->length = cpu_to_le16(vlan_tx_tag_get(skb));
 		ctrl |= INS_VLAN;
 	}
 #endif
@@ -1955,8 +1955,8 @@ static int sky2_status_intr(struct sky2_
 		dev = hw->dev[le->link];
 
 		sky2 = netdev_priv(dev);
-		length = le->length;
-		status = le->status;
+		length = le16_to_cpu(le->length);
+		status = le32_to_cpu(le->status);
 
 		switch (le->opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
@@ -1972,7 +1972,7 @@ static int sky2_status_intr(struct sky2_
 			if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
 				vlan_hwaccel_receive_skb(skb,
 							 sky2->vlgrp,
-							 be16_to_cpu(sky2->rx_tag));
+							 le16_to_cpu(sky2->rx_tag));
 			} else
 #endif
 				netif_receive_skb(skb);
@@ -2001,7 +2001,7 @@ static int sky2_status_intr(struct sky2_
 		case OP_RXCHKS:
 			skb = sky2->rx_ring[sky2->rx_next].skb;
 			skb->ip_summed = CHECKSUM_HW;
-			skb->csum = le16_to_cpu(status);
+			skb->csum = status & 0xffffu;
 			break;
 
 		case OP_TXINDEXLE:
@@ -3240,6 +3240,7 @@ static int __devinit sky2_probe(struct p
 	struct net_device *dev, *dev1 = NULL;
 	struct sky2_hw *hw;
 	int err, pm_cap, using_dac = 0;
+	u32 reg;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3303,16 +3304,12 @@ static int __devinit sky2_probe(struct p
 	}
 	hw->pm_cap = pm_cap;
 
-#ifdef __BIG_ENDIAN
-	/* byte swap descriptors in hardware */
-	{
-		u32 reg;
-
-		reg = sky2_pci_read32(hw, PCI_DEV_REG2);
-		reg |= PCI_REV_DESC;
-		sky2_pci_write32(hw, PCI_DEV_REG2, reg);
-	}
-#endif
+	/* Don't let it byte swap descriptors in hardware. Clear the bit
+	 * in case a previous driver have set it
+	 */
+	reg = sky2_pci_read32(hw, PCI_DEV_REG2);
+	reg &= ~PCI_REV_DESC;
+	sky2_pci_write32(hw, PCI_DEV_REG2, reg);
 
 	/* ring for status responses */
 	hw->st_le = pci_alloc_consistent(hw->pdev, STATUS_LE_BYTES,
Index: linux-work/drivers/net/sky2.h
===================================================================
--- linux-work.orig/drivers/net/sky2.h	2006-09-04 17:35:20.000000000 +1000
+++ linux-work/drivers/net/sky2.h	2006-09-04 17:36:44.000000000 +1000
@@ -1785,7 +1785,6 @@ enum {
 };
 
 /* Yukon 2 hardware interface
- * Not tested on big endian
  */
 struct sky2_tx_le {
 	union {



-- 
VGER BF report: S 0.992386
