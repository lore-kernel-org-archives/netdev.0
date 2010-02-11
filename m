From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] ixgbe: prevent speculative processing of descriptors
 before ready
Date: Fri, 12 Feb 2010 10:23:14 +1100
Message-ID: <20100211232314.GI3399@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiew
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52573 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756788Ab0BKXX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2010 18:23:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Milton Miller <miltonm@bga.com>

The PowerPC architecture does not require loads to independent bytes to be
ordered without adding an explicit barrier.

In ixgbe_clean_rx_irq we load the status bit then load the packet data.
With packet split disabled if these loads go out of order we get a
stale packet, but we will notice the bad sequence numbers and drop it.

The problem occurs with packet split enabled where the TCP/IP header and data
are in different descriptors. If the reads go out of order we may have data
that doesn't match the TCP/IP header. Since we use hardware checksumming this
bad data is never verified and it makes it all the way to the application.

This bug was found during stress testing and adding this barrier has been shown
to fix it.

Signed-off-by: Milton Miller <miltonm@bga.com>
Signed-off-by: Anton Blanchard <anton@samba.org>
---

This was a nasty bug to hunt down, if people agree with the fix I think
it's a candidate for stable.

Index: work.git/drivers/net/ixgbe/ixgbe_main.c
===================================================================
--- work.git.orig/drivers/net/ixgbe/ixgbe_main.c	2010-02-11 16:24:27.000000000 -0600
+++ work.git/drivers/net/ixgbe/ixgbe_main.c	2010-02-11 16:49:27.000000000 -0600
@@ -806,6 +806,7 @@ static bool ixgbe_clean_rx_irq(struct ix
 			break;
 		(*work_done)++;
 
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 		if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
 			hdr_info = le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
 			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
