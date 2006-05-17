From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] sky2: force NAPI repoll if busy
Date: Wed, 17 May 2006 14:37:06 -0700
Message-ID: <20060517213802.471236000@localhost.localdomain>
References: <20060517213702.322762000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55480 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751151AbWEQVll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 17:41:41 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-morework.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the status ring processing can't keep up with the incoming frames,
it is more efficient to have NAPI keep scheduling the poll routine
rather than causing another interrupt.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-05-17 08:55:54.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-17 08:56:03.000000000 -0700
@@ -1920,6 +1920,12 @@
 	}
 }
 
+/* Is status ring empty or is there more to do? */
+static inline int sky2_more_work(const struct sky2_hw *hw)
+{
+	return (hw->st_idx != sky2_read16(hw, STAT_PUT_IDX));
+}
+
 /* Process status response ring */
 static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 {
@@ -2192,19 +2198,19 @@
 	if (status & Y2_IS_CHK_TXA2)
 		sky2_descriptor_error(hw, 1, "transmit", Y2_IS_CHK_TXA2);
 
-	if (status & Y2_IS_STAT_BMU)
-		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
-
 	work_done = sky2_status_intr(hw, work_limit);
 	*budget -= work_done;
 	dev0->quota -= work_done;
 
-	if (work_done >= work_limit)
+	if (status & Y2_IS_STAT_BMU)
+		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+
+	if (sky2_more_work(hw))
 		return 1;
 
 	netif_rx_complete(dev0);
 
-	status = sky2_read32(hw, B0_Y2_SP_LISR);
+	sky2_read32(hw, B0_Y2_SP_LISR);
 	return 0;
 }
 

--

