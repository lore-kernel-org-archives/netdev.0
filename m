From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/3] sky2: fix transmit state on resume
Date: Fri, 28 Sep 2007 09:48:14 -0700
Message-ID: <20070928164858.593540259@linux-foundation.org>
References: <20070928164811.387831540@linux-foundation.org>
Cc: stable@kernel.org, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53530 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751313AbXI1QwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 12:52:00 -0400
Content-Disposition: inline; filename=sky2-tx-sum-resume.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After resume, driver has reset the chip so the current state
of transmit checksum offload state machine and DMA state machine
will be undefined.

The fix is to set the state so that first Tx will set MSS and offset
values.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-28 09:21:26.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-28 09:21:37.000000000 -0700
@@ -831,6 +831,20 @@ static inline struct sky2_tx_le *get_tx_
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
@@ -1244,7 +1258,8 @@ static int sky2_up(struct net_device *de
 				GFP_KERNEL);
 	if (!sky2->tx_ring)
 		goto err_out;
-	sky2->tx_prod = sky2->tx_cons = 0;
+
+	tx_init(sky2);
 
 	sky2->rx_le = pci_alloc_consistent(hw->pdev, RX_LE_BYTES,
 					   &sky2->rx_le_map);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

