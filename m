From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH 2/2] mv643xx_eth: make eth_port_uc_addr_{get,set}() calls symmetric
Date: Fri, 23 Mar 2007 12:07:26 -0700
Message-ID: <20070323190726.GA4736@xyzzy.farnsworth.org>
References: <20070323123002.GA23436@iram.es> <20070323190351.GB28209@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel Paubert <paubert@iram.es>,
	Manish Lachwani <mlachwani@mvista.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:4601 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753394AbXCWTH1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 15:07:27 -0400
Content-Disposition: inline
In-Reply-To: <20070323190351.GB28209@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gabriel Paubert <paubert@iram.es>

There is no good reason for the asymmetry in the parameters of
eth_port_uc_addr_get() and eth_port_uc_addr_set().  Make them
symmetric.  Remove some gratuitous block comments while we're here.

Signed-off-by: Gabriel Paubert <paubert@iram.es>
Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
---
This is a clean-up patch that needn't be rushed upstream.  -Dale

 drivers/net/mv643xx_eth.c |   59 +++++++-----------------------------
 drivers/net/mv643xx_eth.h |    4 --
 2 files changed, 13 insertions(+), 50 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 643ea31..f58d96e 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -51,8 +51,8 @@ #include <asm/delay.h>
 #include "mv643xx_eth.h"
 
 /* Static function declarations */
-static void eth_port_uc_addr_get(struct net_device *dev,
-						unsigned char *MacAddr);
+static void eth_port_uc_addr_get(unsigned int port_num, unsigned char *p_addr);
+static void eth_port_uc_addr_set(unsigned int port_num, unsigned char *p_addr);
 static void eth_port_set_multicast_list(struct net_device *);
 static void mv643xx_eth_port_enable_tx(unsigned int port_num,
 						unsigned int queues);
@@ -1382,7 +1382,7 @@ #endif
 	port_num = mp->port_num = pd->port_number;
 
 	/* set default config values */
-	eth_port_uc_addr_get(dev, dev->dev_addr);
+	eth_port_uc_addr_get(port_num, dev->dev_addr);
 	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
 	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
@@ -1826,26 +1826,9 @@ static void eth_port_start(struct net_de
 }
 
 /*
- * eth_port_uc_addr_set - This function Set the port Unicast address.
- *
- * DESCRIPTION:
- *		This function Set the port Ethernet MAC address.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Port number.
- *	char *		p_addr		Address to be set
- *
- * OUTPUT:
- *	Set MAC address low and high registers. also calls
- *	eth_port_set_filter_table_entry() to set the unicast
- *	table with the proper information.
- *
- * RETURN:
- *	N/A.
- *
+ * eth_port_uc_addr_set - Write a MAC address into the port's hw registers
  */
-static void eth_port_uc_addr_set(unsigned int eth_port_num,
-							unsigned char *p_addr)
+static void eth_port_uc_addr_set(unsigned int port_num, unsigned char *p_addr)
 {
 	unsigned int mac_h;
 	unsigned int mac_l;
@@ -1855,40 +1838,24 @@ static void eth_port_uc_addr_set(unsigne
 	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
 							(p_addr[3] << 0);
 
-	mv_write(MV643XX_ETH_MAC_ADDR_LOW(eth_port_num), mac_l);
-	mv_write(MV643XX_ETH_MAC_ADDR_HIGH(eth_port_num), mac_h);
+	mv_write(MV643XX_ETH_MAC_ADDR_LOW(port_num), mac_l);
+	mv_write(MV643XX_ETH_MAC_ADDR_HIGH(port_num), mac_h);
 
-	/* Accept frames of this address */
-	table = MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(eth_port_num);
+	/* Accept frames with this address */
+	table = MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port_num);
 	eth_port_set_filter_table_entry(table, p_addr[5] & 0x0f);
 }
 
 /*
- * eth_port_uc_addr_get - This function retrieves the port Unicast address
- * (MAC address) from the ethernet hw registers.
- *
- * DESCRIPTION:
- *		This function retrieves the port Ethernet MAC address.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Port number.
- *	char		*MacAddr	pointer where the MAC address is stored
- *
- * OUTPUT:
- *	Copy the MAC address to the location pointed to by MacAddr
- *
- * RETURN:
- *	N/A.
- *
+ * eth_port_uc_addr_get - Read the MAC address from the port's hw registers
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
diff --git a/drivers/net/mv643xx_eth.h b/drivers/net/mv643xx_eth.h
index 7d4e90c..82f8c0c 100644
--- a/drivers/net/mv643xx_eth.h
+++ b/drivers/net/mv643xx_eth.h
@@ -346,10 +346,6 @@ static void eth_port_init(struct mv643xx
 static void eth_port_reset(unsigned int eth_port_num);
 static void eth_port_start(struct net_device *dev);
 
-/* Port MAC address routines */
-static void eth_port_uc_addr_set(unsigned int eth_port_num,
-				 unsigned char *p_addr);
-
 /* PHY and MIB routines */
 static void ethernet_phy_reset(unsigned int eth_port_num);
 
