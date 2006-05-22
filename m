From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: fix jumbo packet support
Date: Mon, 22 May 2006 12:03:42 -0700
Message-ID: <20060522120342.20f752e5@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54952 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750852AbWEVTE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 15:04:27 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The truncate threshold calculation to prevent receiver from getting stuck
was incorrect, and it didn't take into account the upper limit on bits
in the register so the jumbo packet support was broken.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- sky2.orig/drivers/net/sky2.c
+++ sky2/drivers/net/sky2.c
@@ -979,6 +979,7 @@ static int sky2_rx_start(struct sky2_por
 	struct sky2_hw *hw = sky2->hw;
 	unsigned rxq = rxqaddr[sky2->port];
 	int i;
+	unsigned thresh;
 
 	sky2->rx_put = sky2->rx_next = 0;
 	sky2_qset(hw, rxq);
@@ -1003,9 +1004,21 @@ static int sky2_rx_start(struct sky2_por
 		sky2_rx_add(sky2, re->mapaddr);
 	}
 
- 	/* Truncate oversize frames */
- 	sky2_write16(hw, SK_REG(sky2->port, RX_GMF_TR_THR), sky2->rx_bufsize - 8);
- 	sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_TRUNC_ON);
+
+	/*
+	 * The receiver hangs if it receives frames larger than the
+	 * packet buffer. As a workaround, truncate oversize frames, but
+	 * the register is limited to 9 bits, so if you do frames > 2052
+	 * you better get the MTU right!
+	 */
+	thresh = (sky2->rx_bufsize - 8) / sizeof(u32);
+	if (thresh > 0x1ff)
+		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_TRUNC_OFF);
+	else {
+		sky2_write16(hw, SK_REG(sky2->port, RX_GMF_TR_THR), thresh);
+		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_TRUNC_ON);
+	}
+
 
 	/* Tell chip about available buffers */
 	sky2_write16(hw, Y2_QADDR(rxq, PREF_UNIT_PUT_IDX), sky2->rx_put);
