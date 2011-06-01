From: "Aries Lee" <arieslee@jmicron.com>
Subject: [PATCH 1/1] Fix 802.3az compatible issue
Date: Wed, 1 Jun 2011 20:50:50 +0800
Message-ID: <201106011250.p51Coox8031239@jmr105.jmicron.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Guo-Fu Tseng'" <cooldavid@cooldavid.org>,
	<netdev@vger.kernel.org>, <devinchiu@jmicron.com>
To: "'David Rehner'" <dave@daveonline.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spamfilter.jmicron.com ([220.130.51.235]:33483 "EHLO
	jmsspam.jmicron.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750968Ab1FANE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 09:04:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The older JMicron NIC chip -- Jme251A, can NOT connect with a linking
partner with "802.3az" feature in 1000M speed.
More specifically speaking, it's HW design has a problem in
auto-negotiation if the linking partner is running 802.3az function.

This "Auto speed down" patch is a software workaround to avoid the user
of older jme chip unable to connect with the linking partner with
802.3az function.
If the NIC is down speed to 100M, everything is fine. But if the NIC is
running by 1000M speed, this problem makes it unable to link up.

The algorithm of this workaround is as following:
Setup a timer to polling when the PHY link status is down, If the
ethernet cable was attached but auto-negotiation has not been
accomplished for a long time (default 11 second), that mean the linking
partner maybe running 802.3az function, driver will try to
connect by 100M speed.
If the link is up, then stop the timer.

Signed-off-by: arieslee <arieslee@jmicron.com>
---
 drivers/net/jme.c |  193
++++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/jme.h |   14 ++++
 2 files changed, 206 insertions(+), 1 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index b5b174a..b76d213 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -47,6 +47,7 @@
 static int force_pseudohp = -1;
 static int no_pseudohp = -1;
 static int no_extplug = -1;
+static int delay_time = 11;
 module_param(force_pseudohp, int, 0);
 MODULE_PARM_DESC(force_pseudohp,
 	"Enable pseudo hot-plug feature manually by driver instead of
BIOS.");
@@ -55,6 +56,9 @@ MODULE_PARM_DESC(no_pseudohp, "Disable pseudo hot-plug
feature.");
 module_param(no_extplug, int, 0);
 MODULE_PARM_DESC(no_extplug,
 	"Do not use external plug signal for pseudo hot-plug.");
+module_param(delay_time, uint, 0);
+MODULE_PARM_DESC(delay_time,
+	"Seconds to delay before switching lower speed; default = 11
seconds");
 
 static int
 jme_mdio_read(struct net_device *netdev, int phy, int reg)
@@ -1289,6 +1293,151 @@ jme_stop_shutdown_timer(struct jme_adapter *jme)
 }
 
 static void
+jme_set_physpeed_capability(struct jme_adapter *jme, u16 speed)
+{
+	u32  advert, advert2;
+
+	spin_lock_bh(&jme->phy_lock);
+	if (speed == SPEED_1000) {
+		advert2 = jme_mdio_read(jme->dev,
+					jme->mii_if.phy_id,
+					MII_CTRL1000);
+		advert2  = (advert2|ADVERTISE_1000HALF|ADVERTISE_1000FULL);
+		jme_mdio_write(jme->dev,
+				jme->mii_if.phy_id,
+				MII_CTRL1000,
+				advert2);
+		advert  = jme_mdio_read(jme->dev,
+					jme->mii_if.phy_id,
+					MII_ADVERTISE);
+		advert  = (advert|ADVERTISE_100HALF|ADVERTISE_100FULL);
+		jme_mdio_write(jme->dev,
+				jme->mii_if.phy_id,
+				MII_ADVERTISE,
+				advert);
+	} else if (speed == SPEED_100) {
+		advert2 = jme_mdio_read(jme->dev,
+					jme->mii_if.phy_id,
+					MII_CTRL1000);
+		advert2 = advert2 &
~(ADVERTISE_1000HALF|ADVERTISE_1000FULL);
+		jme_mdio_write(jme->dev,
+				jme->mii_if.phy_id,
+				MII_CTRL1000,
+				advert2);
+		advert  = jme_mdio_read(jme->dev,
+					jme->mii_if.phy_id,
+					MII_ADVERTISE);
+		advert  = (advert|ADVERTISE_100HALF|ADVERTISE_100FULL);
+		jme_mdio_write(jme->dev,
+				jme->mii_if.phy_id,
+				MII_ADVERTISE,
+				advert);
+	} else{
+		advert2 = jme_mdio_read(jme->dev,
+					jme->mii_if.phy_id,
+					MII_CTRL1000);
+		advert2 = advert2 &
~(ADVERTISE_1000HALF|ADVERTISE_1000FULL);
+		jme_mdio_write(jme->dev,
+				jme->mii_if.phy_id,
+				MII_CTRL1000,
+				advert2);
+		advert  = jme_mdio_read(jme->dev,
+					jme->mii_if.phy_id,
+					MII_ADVERTISE);
+		advert  = advert & ~(ADVERTISE_100HALF|ADVERTISE_100FULL);
+		jme_mdio_write(jme->dev,
+				jme->mii_if.phy_id,
+				MII_ADVERTISE,
+				advert);
+	}
+	spin_unlock_bh(&jme->phy_lock);
+	return;
+}
+
+/*	PHY reg: MII_FCSCOUNTER is read and clear, we have to continuing
read
+	until RJ45 is attached, then cache this result.			*/
+static int
+jme_check_ANcomplete(struct jme_adapter *jme)
+{
+	u32 val;
+
+	val = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_FCSCOUNTER);
+	return ((val&(PHY_SPEC_STATUS_AN_FAIL|PHY_SPEC_STATUS_AN_COMPLETE))
==
+			 PHY_SPEC_STATUS_AN_COMPLETE) ? true : false;
+}
+
+static int
+jme_media_connected(struct jme_adapter *jme)
+{
+	if (jme->flag_media_connected == true)
+		return true;
+
+	jme->flag_media_connected = jme_check_ANcomplete(jme);
+
+	return jme->flag_media_connected;
+}
+
+static void
+asd_polling_func(unsigned long data)
+{
+	struct jme_adapter *jme = (struct jme_adapter *)data;
+
+	/*
+		check condition term by term.
+		1. link is up()
+		==>	reset all thing, exit the process.
+		2. there is no RJ45 cable attached.
+		==>	do nothing but polling.
+		3. RJ45 cable attached. but link is down
+		==>	downspeed if the timeing is over [delay_time]
second.
+	*/
+	if (jme->flag_run_asd) {
+		if (jme_media_connected(jme)) {
+			jme->mc_count++;
+			if (jme->mc_count == (delay_time*3 - 5)) {
+		/* RJ45 is attached but unable to link anyway, it CANT
+		 be resolved by speed, restore the capability		*/
+				jme_set_physpeed_capability(jme,
SPEED_1000);
+				jme->flag_media_connected = false;
+				jme->mc_count = 0;
+			} else if (jme->mc_count == (delay_time*2 - 5)) {
+				if (jme_check_ANcomplete(jme))
+					jme_set_physpeed_capability(jme,
SPEED_10);
+				else{
+					jme->flag_media_connected = false;
+					jme->mc_count = 0;
+				}
+			} else if (jme->mc_count == delay_time - 5) {
+				if (jme_check_ANcomplete(jme))
+					jme_set_physpeed_capability(jme,
SPEED_100);
+				else{
+					jme->flag_media_connected = false;
+					jme->mc_count = 0;
+				}
+			}
+		}
+		mod_timer(&jme->asd_timer, jiffies+HZ);
+		return ;
+	}
+
+		jme->flag_media_connected = false;
+		jme->mc_count = 0;
+		return;
+}
+
+static int jme_check_linkup(struct jme_adapter *jme)
+{
+	u32 phylink;
+
+	if (jme->fpgaver)
+		phylink = jme_linkstat_from_phy(jme);
+	else
+		phylink = jread32(jme, JME_PHY_LINK);
+
+	return	(phylink & PHY_LINK_UP) ? true : false;
+}
+
+static void
 jme_link_change_tasklet(unsigned long arg)
 {
 	struct jme_adapter *jme = (struct jme_adapter *)arg;
@@ -1302,6 +1451,27 @@ jme_link_change_tasklet(unsigned long arg)
 			netif_info(jme, intr, jme->dev, "Waiting link change
lock\n");
 	}
 
+	if (jme_check_linkup(jme)) {
+		if (jme->flag_run_asd) {
+			/*	stop asd_polling_timer();		*/
+			jme->flag_run_asd = false;
+			del_timer_sync(&jme->asd_timer);
+		}
+	} else {
+		if (!jme->flag_run_asd) {
+		/* start asd_polling_timer() if doesn't linkup in 5 seconds
*/
+			jme_set_physpeed_capability(jme, SPEED_1000);
+			jme_check_ANcomplete(jme);
+			jme->flag_media_connected = false;
+			jme->flag_run_asd = true;
+			jme->mc_count = 0;
+			jme->asd_timer.expires  = jiffies + 5*HZ;
+			jme->asd_timer.function = &asd_polling_func;
+			jme->asd_timer.data     = (unsigned long)jme;
+			add_timer(&jme->asd_timer);
+		}
+	}
+
 	if (jme_check_link(netdev, 1) && jme->old_mtu == netdev->mtu)
 		goto out;
 
@@ -3086,6 +3256,11 @@ jme_init_one(struct pci_dev *pdev,
 		goto err_out_unmap;
 	}
 
+	init_timer(&(jme->asd_timer));
+	jme->mc_count = 0;
+	jme->flag_run_asd = false;
+	jme->flag_media_connected = false;
+
 	netif_info(jme, probe, jme->dev, "%s%s chiprev:%x pcirev:%x
macaddr:%pM\n",
 		   (jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC250) ?
 		   "JMC250 Gigabit Ethernet" :
@@ -3116,6 +3291,9 @@ jme_remove_one(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct jme_adapter *jme = netdev_priv(netdev);
 
+	if (jme->flag_run_asd)
+		del_timer_sync(&jme->asd_timer);
+
 	unregister_netdev(netdev);
 	iounmap(jme->regs);
 	pci_set_drvdata(pdev, NULL);
@@ -3148,6 +3326,9 @@ static int jme_suspend(struct device *dev)
 	netif_stop_queue(netdev);
 	jme_stop_irq(jme);
 
+	if (jme->flag_run_asd)
+		del_timer_sync(&jme->asd_timer);
+
 	tasklet_disable(&jme->txclean_task);
 	tasklet_disable(&jme->rxclean_task);
 	tasklet_disable(&jme->rxempty_task);
@@ -3171,6 +3352,8 @@ static int jme_suspend(struct device *dev)
 	tasklet_hi_enable(&jme->rxempty_task);
 
 	jme_powersave_phy(jme);
+	jme->mc_count = 0;
+	jme->flag_media_connected = false;
 
 	return 0;
 }
@@ -3196,6 +3379,15 @@ static int jme_resume(struct device *dev)
 
 	jme_reset_link(jme);
 
+	if (jme->flag_run_asd) {
+		jme_set_physpeed_capability(jme, SPEED_1000);
+		jme_check_ANcomplete(jme);
+		jme->asd_timer.expires  = jiffies + 5*HZ;
+		jme->asd_timer.function = &asd_polling_func;
+		jme->asd_timer.data     = (unsigned long)jme;
+		add_timer(&jme->asd_timer);
+	}
+
 	return 0;
 }
 
@@ -3243,4 +3435,3 @@ MODULE_DESCRIPTION("JMicron JMC2x0 PCI Express
Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DEVICE_TABLE(pci, jme_pci_tbl);
-
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index e9aaeca..fee2da2 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -461,6 +461,13 @@ struct jme_adapter {
 	int			(*jme_vlan_rx)(struct sk_buff *skb,
 					  struct vlan_group *grp,
 					  unsigned short vlan_tag);
+	/* Is Auto Speed Down polling function running*/
+	u8			flag_run_asd;
+	/*     second counter as RJ45 is attached      */
+	u32			mc_count;
+	/* Because PHY 0x13 is read and clear, we need to record it */
+	u8			flag_media_connected;
+	struct timer_list		asd_timer;
 	DECLARE_NAPI_STRUCT
 	DECLARE_NET_DEVICE_STATS
 };
@@ -889,6 +896,13 @@ enum jme_phy_pwr_bit_masks {
 				       * 1: xtl_out = phy_giga.PD_OSC
 				       */
 };
+/*
+ * False carrier Counter
+ */
+enum jme_phy_an_status {
+	PHY_SPEC_STATUS_AN_COMPLETE		= 0x00000800,
+	PHY_SPEC_STATUS_AN_FAIL			= 0x00008000,
+};
 
 /*
  * Giga PHY Status Registers
-- 
1.7.3.4



