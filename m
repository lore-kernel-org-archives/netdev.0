From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(7/20): move static prototypes from header file into driver C file
Date: Mon, 28 Mar 2005 16:47:36 -0700
Message-ID: <20050328234736.GG29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Static function prototypes don't belong in a header file so move them
into the driver C file. Also add a check for valid port number at
device create to catch silly platform data errors.

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.h
+++ linux-2.5-enet/drivers/net/mv643xx_eth.h
@@ -75,6 +75,8 @@
 #define MV643XX_RX_COAL 100
 #endif
 
+#define MV643XX_PORT_MAX	3
+
 /*
  * The second part is the low level driver of the gigE ethernet ports.
  */
@@ -567,40 +569,4 @@
 	struct net_device *netdev;
 };
 
-/* ethernet.h API list */
-
-/* Port operation control routines */
-static void eth_port_init(struct mv643xx_private *mp);
-static void eth_port_reset(unsigned int eth_port_num);
-static void eth_port_start(struct mv643xx_private *mp);
-
-static void ethernet_set_config_reg(unsigned int eth_port_num,
-				    unsigned int value);
-static unsigned int ethernet_get_config_reg(unsigned int eth_port_num);
-
-/* Port MAC address routines */
-static void eth_port_uc_addr_set(unsigned int eth_port_num,
-				 unsigned char *p_addr);
-
-/* PHY and MIB routines */
-static void ethernet_phy_reset(struct mv643xx_private *mp);
-
-static void eth_port_write_smi_reg(struct mv643xx_private *mp,
-				   unsigned int phy_reg, unsigned int value);
-
-static void eth_port_read_smi_reg(struct mv643xx_private *mp,
-				  unsigned int phy_reg, unsigned int *value);
-
-static void eth_clear_mib_counters(unsigned int eth_port_num);
-
-/* Port data flow control routines */
-static ETH_FUNC_RET_STATUS eth_port_send(struct mv643xx_private *mp,
-					 struct pkt_info *p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_tx_return_desc(struct mv643xx_private *mp,
-					      struct pkt_info *p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
-					    struct pkt_info *p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
-					      struct pkt_info *p_pkt_info);
-
 #endif				/* __MV643XX_ETH_H__ */
Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -92,6 +92,40 @@
 static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static struct ethtool_ops mv643xx_ethtool_ops;
 
+/* Port operation control routines */
+static void eth_port_init(struct mv643xx_private *mp);
+static void eth_port_reset(unsigned int eth_port_num);
+static void eth_port_start(struct mv643xx_private *mp);
+
+static void ethernet_set_config_reg(unsigned int eth_port_num,
+				    unsigned int value);
+static unsigned int ethernet_get_config_reg(unsigned int eth_port_num);
+
+/* Port MAC address routines */
+static void eth_port_uc_addr_set(unsigned int eth_port_num,
+				 unsigned char *p_addr);
+
+/* PHY and MIB routines */
+static void ethernet_phy_reset(struct mv643xx_private *mp);
+
+static void eth_port_write_smi_reg(struct mv643xx_private *mp,
+				   unsigned int phy_reg, unsigned int value);
+
+static void eth_port_read_smi_reg(struct mv643xx_private *mp,
+				  unsigned int phy_reg, unsigned int *value);
+
+static void eth_clear_mib_counters(unsigned int eth_port_num);
+
+/* Port data flow control routines */
+static ETH_FUNC_RET_STATUS eth_port_send(struct mv643xx_private *mp,
+					 struct pkt_info *p_pkt_info);
+static ETH_FUNC_RET_STATUS eth_tx_return_desc(struct mv643xx_private *mp,
+					      struct pkt_info *p_pkt_info);
+static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
+					    struct pkt_info *p_pkt_info);
+static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
+					      struct pkt_info *p_pkt_info);
+
 static char mv643xx_driver_name[] = "mv643xx_eth";
 static char mv643xx_driver_version[] = "1.0";
 
@@ -1519,6 +1553,9 @@
 	int err;
 	struct ethtool_cmd *ecmd;
 
+	if (port_num >= MV643XX_PORT_MAX)
+		return -EINVAL;
+
 	dev = alloc_etherdev(sizeof(struct mv643xx_private));
 	if (!dev)
 		return -ENOMEM;
