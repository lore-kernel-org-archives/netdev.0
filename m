From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 1/1] More ethtool support for sis900
Date: Sat,  5 Mar 2005 14:40:11 +0100 (CET)
Message-ID: <20050305134011.23638.68926@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; charset="us-ascii";
	boundary="===============0651636773=="
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com, jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME message, see the first attachment for the text
and the second for the patch
--===============0651636773==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit



Add support for using generic mii interface
Add support for the following ethtool ops:
	- get_link
	- get_settings
	- set_settings
	- nway_reset



Signed-off-by: Daniele Venzano <webvenza@libero.it>


--===============0651636773==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 95)
+++ b/drivers/net/sis900.c	(revision 97)
@@ -161,6 +161,7 @@
 	struct mii_phy * mii;
 	struct mii_phy * first_mii; /* record the first mii structure */
 	unsigned int cur_phy;
+	struct mii_if_info mii_info;
 
 	struct timer_list timer; /* Link status detection timer. */
 	u8 autong_complete; /* 1: auto-negotiate complete  */
@@ -199,7 +200,7 @@
 static int sis900_mii_probe (struct net_device * net_dev);
 static void sis900_init_rxfilter (struct net_device * net_dev);
 static u16 read_eeprom(long ioaddr, int location);
-static u16 mdio_read(struct net_device *net_dev, int phy_id, int location);
+static int mdio_read(struct net_device *net_dev, int phy_id, int location);
 static void mdio_write(struct net_device *net_dev, int phy_id, int location, int val);
 static void sis900_timer(unsigned long data);
 static void sis900_check_mode (struct net_device *net_dev, struct mii_phy *mii_phy);
@@ -468,7 +469,13 @@
 		sis_priv->msg_enable = sis900_debug;
 	else
 		sis_priv->msg_enable = SIS900_DEF_MSG;
-	
+
+	sis_priv->mii_info.dev = net_dev;
+	sis_priv->mii_info.mdio_read = mdio_read;
+	sis_priv->mii_info.mdio_write = mdio_write;
+	sis_priv->mii_info.phy_id_mask = 0x1f;
+	sis_priv->mii_info.reg_num_mask = 0x1f;
+
 	ret = register_netdev(net_dev);
 	if (ret)
 		goto err_unmap_rx;
@@ -507,6 +514,8 @@
 		goto err_out_unregister;
 	}
 
+	sis_priv->mii_info.phy_id = sis_priv->cur_phy;
+
 	/* save our host bridge revision */
 	dev = pci_get_device(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_630, NULL);
 	if (dev) {
@@ -843,7 +852,7 @@
  *	Please see SiS7014 or ICS spec
  */
 
-static u16 mdio_read(struct net_device *net_dev, int phy_id, int location)
+static int mdio_read(struct net_device *net_dev, int phy_id, int location)
 {
 	long mdio_addr = net_dev->base_addr + mear;
 	int mii_cmd = MIIread|(phy_id<<MIIpmdShift)|(location<<MIIregShift);
@@ -1943,10 +1952,41 @@
 	sis_priv->msg_enable = value;
 }
 
+static u32 sis900_get_link(struct net_device *net_dev)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	return mii_link_ok(&sis_priv->mii_info);
+}
+
+static int sis900_get_settings(struct net_device *net_dev,
+				struct ethtool_cmd *cmd)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	mii_ethtool_gset(&sis_priv->mii_info, cmd);
+	return 0;
+}
+
+static int sis900_set_settings(struct net_device *net_dev,
+				struct ethtool_cmd *cmd)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	return mii_ethtool_sset(&sis_priv->mii_info, cmd);
+}
+
+static int sis900_nway_reset(struct net_device *net_dev)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	return mii_nway_restart(&sis_priv->mii_info);
+}
+
 static struct ethtool_ops sis900_ethtool_ops = {
 	.get_drvinfo 	= sis900_get_drvinfo,
 	.get_msglevel	= sis900_get_msglevel,
 	.set_msglevel	= sis900_set_msglevel,
+	.get_link	= sis900_get_link,
+	.get_settings	= sis900_get_settings,
+	.set_settings	= sis900_set_settings,
+	.nway_reset	= sis900_nway_reset,
 };
 
 /**

--===============0651636773==--
