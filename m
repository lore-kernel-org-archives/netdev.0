From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/3] sky2: big endian
Date: Wed, 6 Sep 2006 12:45:02 -0700
Message-ID: <20060906124502.24250684@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:29635 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932095AbWIFTqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 15:46:00 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix support for big endian platforms like PPC.
Still not sure about VLAN acceleration (does it need swapping)?

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 drivers/net/sky2.c |   43 ++++++++++++++++++++++---------------------
 drivers/net/sky2.h |   19 +++----------------
 2 files changed, 25 insertions(+), 37 deletions(-)

2d75a2f60dce8ae3f5568cca42a77c243c76ff80
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 2b9272c..9429859 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -827,7 +827,7 @@ static void rx_set_checksum(struct sky2_
 	struct sky2_rx_le *le;
 
 	le = sky2_next_rx(sky2);
-	le->addr = (ETH_HLEN << 16) | ETH_HLEN;
+	le->addr = cpu_to_le32((ETH_HLEN << 16) | ETH_HLEN);
 	le->ctrl = 0;
 	le->opcode = OP_TCPSTART | HW_OWNER;
 
@@ -1245,7 +1245,7 @@ static int sky2_xmit_frame(struct sk_buf
 	/* Send high bits if changed or crosses boundary */
 	if (addr64 != sky2->tx_addr64 || high32(mapping + len) != sky2->tx_addr64) {
 		le = get_tx_le(sky2);
-		le->tx.addr = cpu_to_le32(addr64);
+		le->addr = cpu_to_le32(addr64);
 		le->ctrl = 0;
 		le->opcode = OP_ADDR64 | HW_OWNER;
 		sky2->tx_addr64 = high32(mapping + len);
@@ -1260,8 +1260,7 @@ static int sky2_xmit_frame(struct sk_buf
 
 		if (mss != sky2->tx_last_mss) {
 			le = get_tx_le(sky2);
-			le->tx.tso.size = cpu_to_le16(mss);
-			le->tx.tso.rsvd = 0;
+			le->addr = cpu_to_le32(mss);
 			le->opcode = OP_LRGLEN | HW_OWNER;
 			le->ctrl = 0;
 			sky2->tx_last_mss = mss;
@@ -1274,7 +1273,7 @@ static int sky2_xmit_frame(struct sk_buf
 	if (sky2->vlgrp && vlan_tx_tag_present(skb)) {
 		if (!le) {
 			le = get_tx_le(sky2);
-			le->tx.addr = 0;
+			le->addr = 0;
 			le->opcode = OP_VLAN|HW_OWNER;
 			le->ctrl = 0;
 		} else
@@ -1286,20 +1285,21 @@ static int sky2_xmit_frame(struct sk_buf
 
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
@@ -1307,7 +1307,7 @@ static int sky2_xmit_frame(struct sk_buf
 	}
 
 	le = get_tx_le(sky2);
-	le->tx.addr = cpu_to_le32((u32) mapping);
+	le->addr = cpu_to_le32((u32) mapping);
 	le->length = cpu_to_le16(len);
 	le->ctrl = ctrl;
 	le->opcode = mss ? (OP_LARGESEND | HW_OWNER) : (OP_PACKET | HW_OWNER);
@@ -1325,14 +1325,14 @@ static int sky2_xmit_frame(struct sk_buf
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
@@ -1938,8 +1938,8 @@ static int sky2_status_intr(struct sky2_
 		dev = hw->dev[le->link];
 
 		sky2 = netdev_priv(dev);
-		length = le->length;
-		status = le->status;
+		length = le16_to_cpu(le->length);
+		status = le32_to_cpu(le->status);
 
 		switch (le->opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
@@ -1983,7 +1983,7 @@ static int sky2_status_intr(struct sky2_
 		case OP_RXCHKS:
 			skb = sky2->rx_ring[sky2->rx_next].skb;
 			skb->ip_summed = CHECKSUM_HW;
-			skb->csum = le16_to_cpu(status);
+			skb->csum = status & 0xffff;
 			break;
 
 		case OP_TXINDEXLE:
@@ -3286,12 +3286,13 @@ static int __devinit sky2_probe(struct p
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
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index be46463..4c13c37 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -1791,21 +1791,9 @@ enum {
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
@@ -1851,8 +1839,7 @@ struct sky2_port {
 	u32		     tx_addr64;
 	u16		     tx_pending;
 	u16		     tx_last_mss;
-	u16		     tx_csum_start;
-	u16		     tx_csum_offset;
+	u32		     tx_tcpsum;
 
 	struct ring_info     *rx_ring ____cacheline_aligned_in_smp;
 	struct sky2_rx_le    *rx_le;
-- 
1.2.4

