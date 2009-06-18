From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mv643xx_eth: fix unicast filter programming in promiscuous mode
Date: Thu, 18 Jun 2009 23:35:02 +0200
Message-ID: <20090618213502.GM12752@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:54994 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbZFRVVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 17:21:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prabhanjan Sarnaik <sarnaik@marvell.com>

The Unicast Promiscious Mode (UPM) bit in the mv643xx_eth port
configuration register doesn't do exactly what its name would suggest:
setting this bit merely enables reception of all unicast frames with a
destination address that differs from our local MAC address in bits
[47:4].  In particular, it doesn't have any effect on unicast frames
with a destination address that matches our MAC address in bits [47:4]
-- these will still be tested against the 16-entry unicast address
filter table.

Therefore, if the interface is set to promiscuous mode, just setting
the unicast promiscuous bit isn't enough -- we need to set all filter
bits in the unicast filter table to 1 as well.

Reported-by: Sachin Sanap <ssanap@marvell.com>
Signed-off-by: Prabhanjan Sarnaik <sarnaik@marvell.com>
Tested-by: Siddarth Gore <gores@marvell.com>
Tested-by: Mahavir Jain <mjain@marvell.com>
Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Cc: stable@kernel.org
---
This patch is relevant for 2.6.29 and 2.6.30 as well.

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 6bb5af3..305e0d1 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1751,12 +1751,12 @@ static void mv643xx_eth_program_unicast_filter(struct net_device *dev)
 
 	uc_addr_set(mp, dev->dev_addr);
 
-	port_config = rdlp(mp, PORT_CONFIG);
+	port_config = rdlp(mp, PORT_CONFIG) & ~UNICAST_PROMISCUOUS_MODE;
+
 	nibbles = uc_addr_filter_mask(dev);
 	if (!nibbles) {
 		port_config |= UNICAST_PROMISCUOUS_MODE;
-		wrlp(mp, PORT_CONFIG, port_config);
-		return;
+		nibbles = 0xffff;
 	}
 
 	for (i = 0; i < 16; i += 4) {
@@ -1777,7 +1777,6 @@ static void mv643xx_eth_program_unicast_filter(struct net_device *dev)
 		wrl(mp, off, v);
 	}
 
-	port_config &= ~UNICAST_PROMISCUOUS_MODE;
 	wrlp(mp, PORT_CONFIG, port_config);
 }
 
-- 
1.5.6.4
