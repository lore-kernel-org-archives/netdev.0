From: shemminger@osdl.org
Subject: [PATCH 6/9] sky2: optimize checksum offload information
Date: Mon, 28 Aug 2006 10:00:50 -0700
Message-ID: <20060828170218.769180424@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56962 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751295AbWH1SRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:17:05 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-csum-off-cache.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since many packets have the same checksum starting offset and insertion
location; the driver can save the last information and only tell hardware
when it changes.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-08-28 10:00:08.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-28 10:00:13.000000000 -0700
@@ -1280,12 +1280,17 @@
 		if (skb->nh.iph->protocol == IPPROTO_UDP)
 			ctrl |= UDPTCP;
 
-		le = get_tx_le(sky2);
-		le->tx.csum.start = cpu_to_le16(hdr);
-		le->tx.csum.offset = cpu_to_le16(offset);
-		le->length = 0;	/* initial checksum value */
-		le->ctrl = 1;	/* one packet */
-		le->opcode = OP_TCPLISW | HW_OWNER;
+		if (hdr != sky2->tx_csum_start || offset != sky2->tx_csum_offset) {
+			sky2->tx_csum_start = hdr;
+			sky2->tx_csum_offset = offset;
+
+			le = get_tx_le(sky2);
+			le->tx.csum.start = cpu_to_le16(hdr);
+			le->tx.csum.offset = cpu_to_le16(offset);
+			le->length = 0;	/* initial checksum value */
+			le->ctrl = 1;	/* one packet */
+			le->opcode = OP_TCPLISW | HW_OWNER;
+		}
 	}
 
 	le = get_tx_le(sky2);
--- sky2.orig/drivers/net/sky2.h	2006-08-28 09:59:36.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-08-28 10:00:13.000000000 -0700
@@ -1843,6 +1843,8 @@
 	u32		     tx_addr64;
 	u16		     tx_pending;
 	u16		     tx_last_mss;
+	u16		     tx_csum_start;
+	u16		     tx_csum_offset;
 
 	struct ring_info     *rx_ring ____cacheline_aligned_in_smp;
 	struct sky2_rx_le    *rx_le;

--
Stephen Hemminger <shemminger@osdl.org>

