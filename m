From: Gabriel Paubert <paubert@iram.es>
Subject: [PATCH] Fix use of uninitialized field in mv643xx_eth
Date: Fri, 23 Mar 2007 13:30:02 +0100
Message-ID: <20070323123002.GA23436@iram.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>,
	Manish Lachwani <mlachwani@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gra-lx1.iram.es ([150.214.224.41]:48084 "EHLO gra-lx1.iram.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422844AbXCWMsN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 08:48:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In this driver, the default ethernet address is first set by by calling
eth_port_uc_addr_get() which reads the relevant registers of the 
corresponding port as initially set by firmware. However that function 
used the port_num field accessed through the private area of net_dev 
before it was set.  

The result was that one board I have ended up with the unicast address 
set to 00:00:00:00:00:00 (only port 1 is connected on this board). The
problem appeared after commit 84dd619e4dc3b0b1c40dafd98c90fd950bce7bc5.

This patch fixes the bug by making eth_port_uc_get_addr() more similar 
to eth_port_uc_set_addr(), i.e., by using the port number as the first
parameter instead of a pointer to struct net_device.

Signed-off-by: Gabriel Paubert <paubert@iram.es>

--

The minimal patch I first tried consisted in just moving mp->port_num
to before the call to eth_port_uc_get_addr(). The other question is why
the driver never gets the info from the device tree on this PPC board,
but that's for another list despite the fact I lost some time looking 
for bugs in the OF interface before stumbling on this use of a field
before it was initialized.


diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1ee27c3..ca459e0 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -51,7 +51,7 @@
 #include "mv643xx_eth.h"
 
 /* Static function declarations */
-static void eth_port_uc_addr_get(struct net_device *dev,
+static void eth_port_uc_addr_get(unsigned int port_num, 
 						unsigned char *MacAddr);
 static void eth_port_set_multicast_list(struct net_device *);
 static void mv643xx_eth_port_enable_tx(unsigned int port_num,
@@ -1382,7 +1382,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	port_num = pd->port_number;
 
 	/* set default config values */
-	eth_port_uc_addr_get(dev, dev->dev_addr);
+	eth_port_uc_addr_get(port_num, dev->dev_addr);
 	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
 	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
@@ -1883,14 +1883,13 @@ static void eth_port_uc_addr_set(unsigned int eth_port_num,
  *	N/A.
  *
  */
-static void eth_port_uc_addr_get(struct net_device *dev, unsigned char *p_addr)
+static void eth_port_uc_addr_get(unsigned int port_num, unsigned char *p_addr)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int mac_h;
 	unsigned int mac_l;
 
-	mac_h = mv_read(MV643XX_ETH_MAC_ADDR_HIGH(mp->port_num));
-	mac_l = mv_read(MV643XX_ETH_MAC_ADDR_LOW(mp->port_num));
+	mac_h = mv_read(MV643XX_ETH_MAC_ADDR_HIGH(port_num));
+	mac_l = mv_read(MV643XX_ETH_MAC_ADDR_LOW(port_num));
 
 	p_addr[0] = (mac_h >> 24) & 0xff;
 	p_addr[1] = (mac_h >> 16) & 0xff;
