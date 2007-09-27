From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] sky2: fix transmit state on resume
Date: Thu, 27 Sep 2007 12:38:12 -0700
Message-ID: <20070927123812.4e2185f3@freepuppy.rosehill>
References: <20070926175847.706025d0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55670 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754936AbXI0Tis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 15:38:48 -0400
In-Reply-To: <20070926175847.706025d0@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should fix http://bugzilla.kernel.org/show_bug.cgi?id=8667

After resume, driver has reset the chip so the current state
of transmit checksum offload state machine and DMA state machine
will be undefined.

The fix is to set the state so that first Tx will set MSS and offset
values.

Patch is against 2.6.23-rc8 after last patch:
 sky2: FE+ vlan workaround

(Should also work on older releases with minor fuzz).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-27 08:45:13.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-27 09:39:49.000000000 -0700
@@ -910,6 +910,20 @@ static inline struct sky2_tx_le *get_tx_
 	return le;
 }
 
+static void tx_init(struct sky2_port *sky2)
+{
+	struct sky2_tx_le *le;
+
+	sky2->tx_prod = sky2->tx_cons = 0;
+	sky2->tx_tcpsum = 0;
+	sky2->tx_last_mss = 0;
+
+	le = get_tx_le(sky2);
+	le->addr = 0;
+	le->opcode = OP_ADDR64 | HW_OWNER;
+	sky2->tx_addr64 = 0;
+}
+
 static inline struct tx_ring_info *tx_le_re(struct sky2_port *sky2,
 					    struct sky2_tx_le *le)
 {
@@ -1320,7 +1334,8 @@ static int sky2_up(struct net_device *de
 				GFP_KERNEL);
 	if (!sky2->tx_ring)
 		goto err_out;
-	sky2->tx_prod = sky2->tx_cons = 0;
+
+	tx_init(sky2);
 
 	sky2->rx_le = pci_alloc_consistent(hw->pdev, RX_LE_BYTES,
 					   &sky2->rx_le_map);
