From: shemminger@osdl.org
Subject: [PATCH 5/9] sky2: TSO mss optimization
Date: Mon, 28 Aug 2006 10:00:49 -0700
Message-ID: <20060828170217.969201733@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55682 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751292AbWH1SRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:17:05 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-only-change.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MSS in the transmit engine only has to change if TSO mtu changes. This
means less commands to the chip when mixing TSO and regular data.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- sky2.orig/drivers/net/sky2.c	2006-08-28 10:00:07.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-28 10:00:08.000000000 -0700
@@ -1244,15 +1244,15 @@
 		mss += ((skb->h.th->doff - 5) * 4);	/* TCP options */
 		mss += (skb->nh.iph->ihl * 4) + sizeof(struct tcphdr);
 		mss += ETH_HLEN;
-	}
 
-	if (mss != sky2->tx_last_mss) {
-		le = get_tx_le(sky2);
-		le->tx.tso.size = cpu_to_le16(mss);
-		le->tx.tso.rsvd = 0;
-		le->opcode = OP_LRGLEN | HW_OWNER;
-		le->ctrl = 0;
-		sky2->tx_last_mss = mss;
+		if (mss != sky2->tx_last_mss) {
+			le = get_tx_le(sky2);
+			le->tx.tso.size = cpu_to_le16(mss);
+			le->tx.tso.rsvd = 0;
+			le->opcode = OP_LRGLEN | HW_OWNER;
+			le->ctrl = 0;
+			sky2->tx_last_mss = mss;
+		}
 	}
 
 	ctrl = 0;
@@ -1320,7 +1320,7 @@
 		le->opcode = OP_BUFFER | HW_OWNER;
 
 		fre = sky2->tx_ring
-		    + RING_NEXT((re - sky2->tx_ring) + i, TX_RING_SIZE);
+			+ RING_NEXT((re - sky2->tx_ring) + i, TX_RING_SIZE);
 		pci_unmap_addr_set(fre, mapaddr, mapping);
 	}
 

--
Stephen Hemminger <shemminger@osdl.org>

