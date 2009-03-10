From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mv643xx_eth: fix unicast address filter corruption on mtu change
Date: Tue, 10 Mar 2009 09:22:48 +0100
Message-ID: <20090310082248.GF4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:42850 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbZCJIWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 04:22:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When mv643xx_eth_open() is called to up an interface, port_start()
will first re-program the unicast address filter, and then
re-initialise the PORT_CONFIG register, but that will disable unicast
promiscuous mode if it was enabled by the unicast address filter setup.

This isn't a problem on ifconfig up, as ->set_rx_mode() will be called
shortly afterwards which will program the filters again, but it does
trigger when changing the MTU, which calls mv643xx_eth_stop() and then
mv643xx_eth_open() by hand to repopulate the receive rings with skbuffs
of the new size.

Swap the initialisation of the PORT_START register and the call to
the unicast filter setup function to fix this.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index e920198..19ceeac 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2289,11 +2289,6 @@ static void port_start(struct mv643xx_eth_private *mp)
 	}
 
 	/*
-	 * Add configured unicast address to address filter table.
-	 */
-	mv643xx_eth_program_unicast_filter(mp->dev);
-
-	/*
 	 * Receive all unmatched unicast, TCP, UDP, BPDU and broadcast
 	 * frames to RX queue #0, and include the pseudo-header when
 	 * calculating receive checksums.
@@ -2306,6 +2301,11 @@ static void port_start(struct mv643xx_eth_private *mp)
 	wrlp(mp, PORT_CONFIG_EXT, 0x00000000);
 
 	/*
+	 * Add configured unicast addresses to address filter table.
+	 */
+	mv643xx_eth_program_unicast_filter(mp->dev);
+
+	/*
 	 * Enable the receive queues.
 	 */
 	for (i = 0; i < mp->rxq_count; i++) {
-- 
1.5.6.4
