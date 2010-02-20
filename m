From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: prevent speculative processing of
	descriptors before ready
Date: Fri, 19 Feb 2010 19:44:42 -0800
Message-ID: <20100220034419.31030.5083.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Milton Miller <miltonm@bga.com>,
	Anton Blanchard <anton@samba.org>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:44929 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751993Ab0BTDpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 22:45:05 -0500
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
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 43a8de3..3308790 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -849,6 +849,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			break;
 		(*work_done)++;
 
+		rmb(); /* read descriptor and rx_buffer_info after status DD */
 		if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
 			hdr_info = le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
 			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>

