From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 1/6] sky2: dual port NAPI problem
Date: Wed, 20 Dec 2006 13:06:33 -0800
Message-ID: <20061220210922.633505172@osdl.org>
References: <20061220210632.183204605@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58262 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423156AbWLVAlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 19:41:10 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-dual-port-napi.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shutting down port 0 disables the NAPI poll used by both ports.
The long term fix will be to separate NAPI object from net device
until then just reenable if needed.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2-2.6.orig/drivers/net/sky2.c	2006-12-18 12:46:59.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2006-12-18 12:47:30.000000000 -0800
@@ -1511,6 +1511,13 @@
 	imask &= ~portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
+	/*
+	 * Both ports share the NAPI poll on port 0, so if necessary undo the
+	 * the disable that is done in dev_close.
+	 */
+	if (sky2->port == 0 && hw->ports > 1)
+		netif_poll_enable(dev);
+
 	sky2_gmac_reset(hw, port);
 
 	/* Stop transmitter */

--
Stephen Hemminger <shemminger@osdl.org>

