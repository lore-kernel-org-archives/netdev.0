From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 1/5] sis900 debugging and revision code
Date: Sun, 12 Dec 2004 13:30:31 +0100
Message-ID: <20041212123031.GB16325@gateway.milesteg.arr>
References: <20041212121852.GA16325@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NU0Ex4SbNnrxsi6C"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041212121852.GA16325@gateway.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--NU0Ex4SbNnrxsi6C
Content-Type: multipart/mixed; boundary="1UWUbFP1cBYEclgG"
Content-Disposition: inline


--1UWUbFP1cBYEclgG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Infrastructure needed for standard netif messages
 - add msg_level to sis900_private
 - define default msg level
 - set default value for sis900_debug
Update module parameter description
Ethtool support for debugging output level

Signed-off-by: Daniele Venzano <webvenza@libero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--1UWUbFP1cBYEclgG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_60.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 59)
+++ b/drivers/net/sis900.c	(revision 60)
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
 
@@ -183,10 +190,10 @@
 
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
@@ -457,6 +464,11 @@
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
@@ -1905,8 +1917,22 @@
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

--1UWUbFP1cBYEclgG--

--NU0Ex4SbNnrxsi6C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBvDnn2rmHZCWzV+0RAvilAJ9v02B0ef2GT+U9lxckHAZd9vGFOQCgm4U3
qB5B5edZOzRJG48ybGFZkCQ=
=t0zt
-----END PGP SIGNATURE-----

--NU0Ex4SbNnrxsi6C--
