From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 1/5] sis900 printk audit
Date: Sat, 22 Jan 2005 22:46:57 +0100 (CET)
Message-ID: <20050122214657.18649.66345@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; charset="us-ascii";
	boundary="===============1085356003=="
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME message, see the first attachment for the text
and the second for the patch
--===============1085356003==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit



Infrastructure needed for standard netif messages
 - add msg_level to sis900_private
 - define default msg level
 - set default value for sis900_debug
Update module parameter description
Ethtool support for debugging output level
   


Signed-off-by: Daniele Venzano <webvenza@libero.it>


--===============1085356003==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 83)
+++ b/drivers/net/sis900.c	(revision 84)
@@ -82,9 +82,14 @@
 static int max_interrupt_work = 40;
 static int multicast_filter_limit = 128;
 
-#define sis900_debug debug
-static int sis900_debug;
+static int sis900_debug = -1; /* Use SIS900_DEF_MSG as value */
 
+#define SIS900_DEF_MSG \
+	(NETIF_MSG_DRV		| \
+	 NETIF_MSG_LINK		| \
+	 NETIF_MSG_RX_ERR	| \
+	 NETIF_MSG_TX_ERR)
+
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (4*HZ)
 /* SiS 900 is capable of 32 bits BM DMA */
@@ -160,6 +165,8 @@
 	struct timer_list timer; /* Link status detection timer. */
 	u8 autong_complete; /* 1: auto-negotiate complete  */
 
+	u32 msg_enable;
+
 	unsigned int cur_rx, dirty_rx; /* producer/comsumer pointers for Tx/Rx ring */
 	unsigned int cur_tx, dirty_tx;
 
@@ -182,10 +189,10 @@
 
 module_param(multicast_filter_limit, int, 0444);
 module_param(max_interrupt_work, int, 0444);
-module_param(debug, int, 0444);
+module_param(sis900_debug, int, 0444);
 MODULE_PARM_DESC(multicast_filter_limit, "SiS 900/7016 maximum number of filtered multicast addresses");
 MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled per interrupt");
-MODULE_PARM_DESC(debug, "SiS 900/7016 debug level (2-4)");
+MODULE_PARM_DESC(sis900_debug, "SiS 900/7016 bitmapped debugging message level");
 
 static int sis900_open(struct net_device *net_dev);
 static int sis900_mii_probe (struct net_device * net_dev);
@@ -456,6 +463,11 @@
 	net_dev->tx_timeout = sis900_tx_timeout;
 	net_dev->watchdog_timeo = TX_TIMEOUT;
 	net_dev->ethtool_ops = &sis900_ethtool_ops;
+
+	if (sis900_debug > 0)
+		sis_priv->msg_enable = sis900_debug;
+	else
+		sis_priv->msg_enable = SIS900_DEF_MSG;
 	
 	ret = register_netdev(net_dev);
 	if (ret)
@@ -1906,8 +1918,22 @@
 	strcpy (info->bus_info, pci_name(sis_priv->pci_dev));
 }
 
+static u32 sis900_get_msglevel(struct net_device *net_dev)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	return sis_priv->msg_enable;
+}
+  
+static void sis900_set_msglevel(struct net_device *net_dev, u32 value)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	sis_priv->msg_enable = value;
+}
+
 static struct ethtool_ops sis900_ethtool_ops = {
-	.get_drvinfo =		sis900_get_drvinfo,
+	.get_drvinfo 	= sis900_get_drvinfo,
+	.get_msglevel	= sis900_get_msglevel,
+	.set_msglevel	= sis900_set_msglevel,
 };
 
 /**

--===============1085356003==--
