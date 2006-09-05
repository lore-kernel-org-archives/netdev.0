From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 problem on powerpc
Date: Tue, 5 Sep 2006 14:36:54 -0700
Message-ID: <20060905143654.754da8ef@localhost.localdomain>
References: <1157347462.22705.16.camel@localhost.localdomain>
	<1157354470.22705.26.camel@localhost.localdomain>
	<1157355748.22705.32.camel@localhost.localdomain>
	<20060904204148.6f9749b3@localhost.localdomain>
	<1157428072.22705.70.camel@localhost.localdomain>
	<20060904211531.307bbd7f@localhost.localdomain>
	<1157490665.22705.128.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9096 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751305AbWIEVhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 17:37:04 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1157490665.22705.128.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the reduced version of your patch, plus I got rid of the union
in tx_le, it is a nuisance.


--- sky2.orig/drivers/net/sky2.c	2006-09-05 13:39:34.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-09-05 13:57:44.000000000 -0700
@@ -809,7 +809,7 @@
 	struct sky2_rx_le *le;
 
 	le = sky2_next_rx(sky2);
-	le->addr = (ETH_HLEN << 16) | ETH_HLEN;
+	le->addr = cpu_to_le32((ETH_HLEN << 16) | ETH_HLEN);
 	le->ctrl = 0;
 	le->opcode = OP_TCPSTART | HW_OWNER;
 
@@ -1227,7 +1227,7 @@
 	/* Send high bits if changed or crosses boundary */
 	if (addr64 != sky2->tx_addr64 || high32(mapping + len) != sky2->tx_addr64) {
 		le = get_tx_le(sky2);
-		le->tx.addr = cpu_to_le32(addr64);
+		le->addr = cpu_to_le32(addr64);
 		le->ctrl = 0;
 		le->opcode = OP_ADDR64 | HW_OWNER;
 		sky2->tx_addr64 = high32(mapping + len);
@@ -1242,8 +1242,7 @@
 
 		if (mss != sky2->tx_last_mss) {
 			le = get_tx_le(sky2);
-			le->tx.tso.size = cpu_to_le16(mss);
-			le->tx.tso.rsvd = 0;
+			le->addr = cpu_to_le32(mss);
 			le->opcode = OP_LRGLEN | HW_OWNER;
 			le->ctrl = 0;
 			sky2->tx_last_mss = mss;
@@ -1256,7 +1255,7 @@
 	if (sky2->vlgrp && vlan_tx_tag_present(skb)) {
 		if (!le) {
 			le = get_tx_le(sky2);
-			le->tx.addr = 0;
+			le->addr = 0;
 			le->opcode = OP_VLAN|HW_OWNER;
 			le->ctrl = 0;
 		} else
@@ -1268,20 +1267,21 @@
 
 	/* Handle TCP checksum offload */
 	if (skb->ip_summed == CHECKSUM_HW) {
-		u16 hdr = skb->h.raw - skb->data;
-		u16 offset = hdr + skb->csum;
+		unsigned offset = skb->h.raw - skb->data;
+		u32 tcpsum;
+
+		tcpsum = offset << 16;		/* sum start */
+		tcpsum |= offset + skb->csum;	/* sum write */
 
 		ctrl = CALSUM | WR_SUM | INIT_SUM | LOCK_SUM;
 		if (skb->nh.iph->protocol == IPPROTO_UDP)
 			ctrl |= UDPTCP;
 
-		if (hdr != sky2->tx_csum_start || offset != sky2->tx_csum_offset) {
-			sky2->tx_csum_start = hdr;
-			sky2->tx_csum_offset = offset;
+		if (tcpsum != sky2->tx_tcpsum) {
+			sky2->tx_tcpsum = tcpsum;
 
 			le = get_tx_le(sky2);
-			le->tx.csum.start = cpu_to_le16(hdr);
-			le->tx.csum.offset = cpu_to_le16(offset);
+			le->addr = cpu_to_le32(tcpsum);
 			le->length = 0;	/* initial checksum value */
 			le->ctrl = 1;	/* one packet */
 			le->opcode = OP_TCPLISW | HW_OWNER;
@@ -1289,7 +1289,7 @@
 	}
 
 	le = get_tx_le(sky2);
-	le->tx.addr = cpu_to_le32((u32) mapping);
+	le->addr = cpu_to_le32((u32) mapping);
 	le->length = cpu_to_le16(len);
 	le->ctrl = ctrl;
 	le->opcode = mss ? (OP_LARGESEND | HW_OWNER) : (OP_PACKET | HW_OWNER);
@@ -1307,14 +1307,14 @@
 		addr64 = high32(mapping);
 		if (addr64 != sky2->tx_addr64) {
 			le = get_tx_le(sky2);
-			le->tx.addr = cpu_to_le32(addr64);
+			le->addr = cpu_to_le32(addr64);
 			le->ctrl = 0;
 			le->opcode = OP_ADDR64 | HW_OWNER;
 			sky2->tx_addr64 = addr64;
 		}
 
 		le = get_tx_le(sky2);
-		le->tx.addr = cpu_to_le32((u32) mapping);
+		le->addr = cpu_to_le32((u32) mapping);
 		le->length = cpu_to_le16(frag->size);
 		le->ctrl = ctrl;
 		le->opcode = OP_BUFFER | HW_OWNER;
@@ -1919,8 +1919,8 @@
 		dev = hw->dev[le->link];
 
 		sky2 = netdev_priv(dev);
-		length = le->length;
-		status = le->status;
+		length = le16_to_cpu(le->length);
+		status = le32_to_cpu(le->status);
 
 		switch (le->opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
@@ -1964,7 +1964,7 @@
 		case OP_RXCHKS:
 			skb = sky2->rx_ring[sky2->rx_next].skb;
 			skb->ip_summed = CHECKSUM_HW;
-			skb->csum = le16_to_cpu(status);
+			skb->csum = status & 0xffff;
 			break;
 
 		case OP_TXINDEXLE:
@@ -3266,12 +3266,13 @@
 	hw->pm_cap = pm_cap;
 
 #ifdef __BIG_ENDIAN
-	/* byte swap descriptors in hardware */
+	/* The sk98lin vendor driver uses hardware byte swapping but
+	 * this driver uses software swapping.
+	 */
 	{
 		u32 reg;
-
 		reg = sky2_pci_read32(hw, PCI_DEV_REG2);
-		reg |= PCI_REV_DESC;
+		reg &= ~PCI_REV_DESC;
 		sky2_pci_write32(hw, PCI_DEV_REG2, reg);
 	}
 #endif
--- sky2.orig/drivers/net/sky2.h	2006-09-05 12:10:13.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-09-05 13:55:55.000000000 -0700
@@ -1783,21 +1783,9 @@
 	OP_TXINDEXLE	= 0x68,
 };
 
-/* Yukon 2 hardware interface
- * Not tested on big endian
- */
+/* Yukon 2 hardware interface */
 struct sky2_tx_le {
-	union {
-		__le32	addr;
-		struct {
-			__le16	offset;
-			__le16	start;
-		} csum  __attribute((packed));
-		struct {
-			__le16	size;
-			__le16	rsvd;
-		} tso  __attribute((packed));
-	} tx;
+	__le32	addr;
 	__le16	length;	/* also vlan tag or checksum start */
 	u8	ctrl;
 	u8	opcode;
@@ -1843,8 +1831,7 @@
 	u32		     tx_addr64;
 	u16		     tx_pending;
 	u16		     tx_last_mss;
-	u16		     tx_csum_start;
-	u16		     tx_csum_offset;
+	u32		     tx_tcpsum;
 
 	struct ring_info     *rx_ring ____cacheline_aligned_in_smp;
 	struct sky2_rx_le    *rx_le;
