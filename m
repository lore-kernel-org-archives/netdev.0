From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 1/2] More ethtool support for sis900 and warning fix
Date: Sat, 12 Mar 2005 11:39:40 +0100 (CET)
Message-ID: <20050312103939.27851.24067@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; charset="us-ascii";
	boundary="===============1842727395=="
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com, jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME message, see the first attachment for the text
and the second for the patch
--===============1842727395==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit


Add support to sis900 for the following ethtool ops:
	- get_link
	- get_settings
	- set_settings
	- nway_reset

Rediff against Linus' 2.6.11-bk7 of the patches sent some days ago.


Signed-off-by: Daniele Venzano <webvenza@libero.it>


--===============1842727395==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 101)
+++ b/drivers/net/sis900.c	(revision 102)
@@ -162,6 +162,7 @@ struct sis900_private {
 	struct mii_phy * mii;
 	struct mii_phy * first_mii; /* record the first mii structure */
 	unsigned int cur_phy;
+	struct mii_if_info mii_info;
 
 	struct timer_list timer; /* Link status detection timer. */
 	u8 autong_complete; /* 1: auto-negotiate complete  */
@@ -201,7 +202,7 @@ static int sis900_open(struct net_device
 static int sis900_mii_probe (struct net_device * net_dev);
 static void sis900_init_rxfilter (struct net_device * net_dev);
 static u16 read_eeprom(long ioaddr, int location);
-static u16 mdio_read(struct net_device *net_dev, int phy_id, int location);
+static int mdio_read(struct net_device *net_dev, int phy_id, int location);
 static void mdio_write(struct net_device *net_dev, int phy_id, int location, int val);
 static void sis900_timer(unsigned long data);
 static void sis900_check_mode (struct net_device *net_dev, struct mii_phy *mii_phy);
@@ -476,7 +477,13 @@ static int __devinit sis900_probe(struct
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
 	/* Get Mac address according to the chip revision */
 	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &(sis_priv->chipset_rev));
 	if(netif_msg_probe(sis_priv))
@@ -723,6 +730,8 @@ static u16 sis900_default_phy(struct net
 		       pci_name(sis_priv->pci_dev), sis_priv->cur_phy);
 	}
 	
+	sis_priv->mii_info.phy_id = sis_priv->cur_phy;
+
 	status = mdio_read(net_dev, sis_priv->cur_phy, MII_CONTROL);
 	status &= (~MII_CNTL_ISOLATE);
 
@@ -850,7 +859,7 @@ static void mdio_reset(long mdio_addr)
  *	Please see SiS7014 or ICS spec
  */
 
-static u16 mdio_read(struct net_device *net_dev, int phy_id, int location)
+static int mdio_read(struct net_device *net_dev, int phy_id, int location)
 {
 	long mdio_addr = net_dev->base_addr + mear;
 	int mii_cmd = MIIread|(phy_id<<MIIpmdShift)|(location<<MIIregShift);
@@ -1964,10 +1973,47 @@ static void sis900_set_msglevel(struct n
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
+	spin_lock_irq(&sis_priv->lock);
+	mii_ethtool_gset(&sis_priv->mii_info, cmd);
+	spin_unlock_irq(&sis_priv->lock);
+	return 0;
+}
+
+static int sis900_set_settings(struct net_device *net_dev,
+				struct ethtool_cmd *cmd)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	int rt;
+	spin_lock_irq(&sis_priv->lock);
+	rt = mii_ethtool_sset(&sis_priv->mii_info, cmd);
+	spin_unlock_irq(&sis_priv->lock);
+	return rt;
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

--===============1842727395==--
