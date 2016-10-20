From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next v2 3/9] net: use core MTU range checking in wireless drivers
Date: Thu, 20 Oct 2016 13:55:18 -0400
Message-ID: <20161020175524.6184-4-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Maya Erez <qca_merez@qca.qualcomm.com>,
        Simon Kelley <simon@thekelleys.org.uk>,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161020175524.6184-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- set max_mtu in wil6210 driver
- set max_mtu in atmel driver
- set min/max_mtu in cisco airo driver, remove airo_change_mtu
- set min/max_mtu in ipw2100/ipw2200 drivers, remove libipw_change_mtu
- set min/max_mtu in p80211netdev, remove wlan_change_mtu
- set min/max_mtu in net/mac80211/iface.c and remove ieee80211_change_mtu
- set min/max_mtu in wimax/i2400m and remove i2400m_change_mtu
- set min/max_mtu in intersil/hostap and remove prism2_change_mtu
- set min/max_mtu in intersil/orinoco
- set min/max_mtu in tty/n_gsm and remove gsm_change_mtu

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: Maya Erez <qca_merez@qca.qualcomm.com>
CC: Simon Kelley <simon@thekelleys.org.uk>
CC: Stanislav Yakovlev <stas.yakovlev@gmail.com>
CC: Johannes Berg <johannes@sipsolutions.net>
CC: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/wimax/i2400m/netdev.c                  | 22 ++--------------------
 drivers/net/wireless/ath/wil6210/netdev.c          | 17 +----------------
 drivers/net/wireless/atmel/atmel.c                 | 13 ++++---------
 drivers/net/wireless/cisco/airo.c                  | 14 +++-----------
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |  3 ++-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |  8 ++++++--
 drivers/net/wireless/intel/ipw2x00/libipw.h        |  1 -
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |  9 ---------
 drivers/net/wireless/intersil/hostap/hostap_main.c | 15 ++-------------
 drivers/net/wireless/intersil/orinoco/main.c       |  6 +++---
 drivers/staging/wlan-ng/p80211netdev.c             | 18 +++++-------------
 drivers/tty/n_gsm.c                                | 12 ++----------
 net/mac80211/iface.c                               | 15 ++++-----------
 13 files changed, 34 insertions(+), 119 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index bb74f4b..7f64e74 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -395,25 +395,6 @@ netdev_tx_t i2400m_hard_start_xmit(struct sk_buff *skb,
 
 
 static
-int i2400m_change_mtu(struct net_device *net_dev, int new_mtu)
-{
-	int result;
-	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
-	struct device *dev = i2400m_dev(i2400m);
-
-	if (new_mtu >= I2400M_MAX_MTU) {
-		dev_err(dev, "Cannot change MTU to %d (max is %d)\n",
-			new_mtu, I2400M_MAX_MTU);
-		result = -EINVAL;
-	} else {
-		net_dev->mtu = new_mtu;
-		result = 0;
-	}
-	return result;
-}
-
-
-static
 void i2400m_tx_timeout(struct net_device *net_dev)
 {
 	/*
@@ -590,7 +571,6 @@ static const struct net_device_ops i2400m_netdev_ops = {
 	.ndo_stop = i2400m_stop,
 	.ndo_start_xmit = i2400m_hard_start_xmit,
 	.ndo_tx_timeout = i2400m_tx_timeout,
-	.ndo_change_mtu = i2400m_change_mtu,
 };
 
 static void i2400m_get_drvinfo(struct net_device *net_dev,
@@ -621,6 +601,8 @@ void i2400m_netdev_setup(struct net_device *net_dev)
 	d_fnstart(3, NULL, "(net_dev %p)\n", net_dev);
 	ether_setup(net_dev);
 	net_dev->mtu = I2400M_MAX_MTU;
+	net_dev->min_mtu = 0;
+	net_dev->max_mtu = I2400M_MAX_MTU;
 	net_dev->tx_queue_len = I2400M_TX_QLEN;
 	net_dev->features =
 		  NETIF_F_VLAN_CHALLENGED
diff --git a/drivers/net/wireless/ath/wil6210/netdev.c b/drivers/net/wireless/ath/wil6210/netdev.c
index 61de5e9..d18372c 100644
--- a/drivers/net/wireless/ath/wil6210/netdev.c
+++ b/drivers/net/wireless/ath/wil6210/netdev.c
@@ -41,21 +41,6 @@ static int wil_stop(struct net_device *ndev)
 	return wil_down(wil);
 }
 
-static int wil_change_mtu(struct net_device *ndev, int new_mtu)
-{
-	struct wil6210_priv *wil = ndev_to_wil(ndev);
-
-	if (new_mtu < 68 || new_mtu > mtu_max) {
-		wil_err(wil, "invalid MTU %d\n", new_mtu);
-		return -EINVAL;
-	}
-
-	wil_dbg_misc(wil, "change MTU %d -> %d\n", ndev->mtu, new_mtu);
-	ndev->mtu = new_mtu;
-
-	return 0;
-}
-
 static int wil_do_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
 {
 	struct wil6210_priv *wil = ndev_to_wil(ndev);
@@ -69,7 +54,6 @@ static const struct net_device_ops wil_netdev_ops = {
 	.ndo_start_xmit		= wil_start_xmit,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= wil_change_mtu,
 	.ndo_do_ioctl		= wil_do_ioctl,
 };
 
@@ -126,6 +110,7 @@ static int wil6210_netdev_poll_tx(struct napi_struct *napi, int budget)
 static void wil_dev_setup(struct net_device *dev)
 {
 	ether_setup(dev);
+	dev->max_mtu = mtu_max;
 	dev->tx_queue_len = WIL_TX_Q_LEN_DEFAULT;
 }
 
diff --git a/drivers/net/wireless/atmel/atmel.c b/drivers/net/wireless/atmel/atmel.c
index bf2e9a0..eb92d5a 100644
--- a/drivers/net/wireless/atmel/atmel.c
+++ b/drivers/net/wireless/atmel/atmel.c
@@ -1295,14 +1295,6 @@ static struct iw_statistics *atmel_get_wireless_stats(struct net_device *dev)
 	return &priv->wstats;
 }
 
-static int atmel_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > 2312))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static int atmel_set_mac_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
@@ -1506,7 +1498,6 @@ static const struct file_operations atmel_proc_fops = {
 static const struct net_device_ops atmel_netdev_ops = {
 	.ndo_open 		= atmel_open,
 	.ndo_stop		= atmel_close,
-	.ndo_change_mtu 	= atmel_change_mtu,
 	.ndo_set_mac_address 	= atmel_set_mac_address,
 	.ndo_start_xmit 	= start_tx,
 	.ndo_do_ioctl 		= atmel_ioctl,
@@ -1600,6 +1591,10 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 	dev->irq = irq;
 	dev->base_addr = port;
 
+	/* MTU range: 68 - 2312 */
+	dev->min_mtu = 68;
+	dev->max_mtu = MAX_WIRELESS_BODY - ETH_FCS_LEN;
+
 	SET_NETDEV_DEV(dev, sys_dev);
 
 	if ((rc = request_irq(dev->irq, service_interrupt, IRQF_SHARED, dev->name, dev))) {
diff --git a/drivers/net/wireless/cisco/airo.c b/drivers/net/wireless/cisco/airo.c
index 69b826d..4b04045 100644
--- a/drivers/net/wireless/cisco/airo.c
+++ b/drivers/net/wireless/cisco/airo.c
@@ -2329,14 +2329,6 @@ static int airo_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static int airo_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > 2400))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static LIST_HEAD(airo_devices);
 
 static void add_airo_dev(struct airo_info *ai)
@@ -2656,7 +2648,6 @@ static const struct net_device_ops airo11_netdev_ops = {
 	.ndo_get_stats 		= airo_get_stats,
 	.ndo_set_mac_address	= airo_set_mac_address,
 	.ndo_do_ioctl		= airo_ioctl,
-	.ndo_change_mtu		= airo_change_mtu,
 };
 
 static void wifi_setup(struct net_device *dev)
@@ -2668,6 +2659,8 @@ static void wifi_setup(struct net_device *dev)
 	dev->type               = ARPHRD_IEEE80211;
 	dev->hard_header_len    = ETH_HLEN;
 	dev->mtu                = AIRO_DEF_MTU;
+	dev->min_mtu            = 68;
+	dev->max_mtu            = MIC_MSGLEN_MAX;
 	dev->addr_len           = ETH_ALEN;
 	dev->tx_queue_len       = 100; 
 
@@ -2754,7 +2747,6 @@ static const struct net_device_ops airo_netdev_ops = {
 	.ndo_set_rx_mode	= airo_set_multicast_list,
 	.ndo_set_mac_address	= airo_set_mac_address,
 	.ndo_do_ioctl		= airo_ioctl,
-	.ndo_change_mtu		= airo_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -2766,7 +2758,6 @@ static const struct net_device_ops mpi_netdev_ops = {
 	.ndo_set_rx_mode	= airo_set_multicast_list,
 	.ndo_set_mac_address	= airo_set_mac_address,
 	.ndo_do_ioctl		= airo_ioctl,
-	.ndo_change_mtu		= airo_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -2822,6 +2813,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	dev->irq = irq;
 	dev->base_addr = port;
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->max_mtu = MIC_MSGLEN_MAX;
 
 	SET_NETDEV_DEV(dev, dmdev);
 
diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2100.c b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
index bfa542c..6417609 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
@@ -6035,7 +6035,6 @@ static const struct net_device_ops ipw2100_netdev_ops = {
 	.ndo_open		= ipw2100_open,
 	.ndo_stop		= ipw2100_close,
 	.ndo_start_xmit		= libipw_xmit,
-	.ndo_change_mtu		= libipw_change_mtu,
 	.ndo_tx_timeout		= ipw2100_tx_timeout,
 	.ndo_set_mac_address	= ipw2100_set_address,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -6071,6 +6070,8 @@ static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
 	dev->wireless_data = &priv->wireless_data;
 	dev->watchdog_timeo = 3 * HZ;
 	dev->irq = 0;
+	dev->min_mtu = 68;
+	dev->max_mtu = LIBIPW_DATA_LEN;
 
 	/* NOTE: We don't use the wireless_handlers hook
 	 * in dev as the system will start throwing WX requests
diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
index bfd6861..ef9af8a 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
@@ -11561,7 +11561,6 @@ static const struct net_device_ops ipw_prom_netdev_ops = {
 	.ndo_open 		= ipw_prom_open,
 	.ndo_stop		= ipw_prom_stop,
 	.ndo_start_xmit		= ipw_prom_hard_start_xmit,
-	.ndo_change_mtu		= libipw_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
@@ -11587,6 +11586,9 @@ static int ipw_prom_alloc(struct ipw_priv *priv)
 	priv->prom_net_dev->type = ARPHRD_IEEE80211_RADIOTAP;
 	priv->prom_net_dev->netdev_ops = &ipw_prom_netdev_ops;
 
+	priv->prom_net_dev->min_mtu = 68;
+	priv->prom_net_dev->max_mtu = LIBIPW_DATA_LEN;
+
 	priv->prom_priv->ieee->iw_mode = IW_MODE_MONITOR;
 	SET_NETDEV_DEV(priv->prom_net_dev, &priv->pci_dev->dev);
 
@@ -11619,7 +11621,6 @@ static const struct net_device_ops ipw_netdev_ops = {
 	.ndo_set_rx_mode	= ipw_net_set_multicast_list,
 	.ndo_set_mac_address	= ipw_net_set_mac_address,
 	.ndo_start_xmit		= libipw_xmit,
-	.ndo_change_mtu		= libipw_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -11729,6 +11730,9 @@ static int ipw_pci_probe(struct pci_dev *pdev,
 	net_dev->wireless_handlers = &ipw_wx_handler_def;
 	net_dev->ethtool_ops = &ipw_ethtool_ops;
 
+	net_dev->min_mtu = 68;
+	net_dev->max_mtu = LIBIPW_DATA_LEN;
+
 	err = sysfs_create_group(&pdev->dev.kobj, &ipw_attribute_group);
 	if (err) {
 		IPW_ERROR("failed to create sysfs device attributes\n");
diff --git a/drivers/net/wireless/intel/ipw2x00/libipw.h b/drivers/net/wireless/intel/ipw2x00/libipw.h
index b057161..b513551 100644
--- a/drivers/net/wireless/intel/ipw2x00/libipw.h
+++ b/drivers/net/wireless/intel/ipw2x00/libipw.h
@@ -948,7 +948,6 @@ static inline int libipw_is_cck_rate(u8 rate)
 /* libipw.c */
 void free_libipw(struct net_device *dev, int monitor);
 struct net_device *alloc_libipw(int sizeof_priv, int monitor);
-int libipw_change_mtu(struct net_device *dev, int new_mtu);
 
 void libipw_networks_age(struct libipw_device *ieee, unsigned long age_secs);
 
diff --git a/drivers/net/wireless/intel/ipw2x00/libipw_module.c b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
index 60f2874..2332075 100644
--- a/drivers/net/wireless/intel/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/intel/ipw2x00/libipw_module.c
@@ -118,15 +118,6 @@ static void libipw_networks_initialize(struct libipw_device *ieee)
 			      &ieee->network_free_list);
 }
 
-int libipw_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > LIBIPW_DATA_LEN))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-EXPORT_SYMBOL(libipw_change_mtu);
-
 struct net_device *alloc_libipw(int sizeof_priv, int monitor)
 {
 	struct libipw_device *ieee;
diff --git a/drivers/net/wireless/intersil/hostap/hostap_main.c b/drivers/net/wireless/intersil/hostap/hostap_main.c
index 80d4228..1a16b8c 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_main.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_main.c
@@ -765,16 +765,6 @@ static void hostap_set_multicast_list(struct net_device *dev)
 }
 
 
-static int prism2_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < PRISM2_MIN_MTU || new_mtu > PRISM2_MAX_MTU)
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-	return 0;
-}
-
-
 static void prism2_tx_timeout(struct net_device *dev)
 {
 	struct hostap_interface *iface;
@@ -813,7 +803,6 @@ static const struct net_device_ops hostap_netdev_ops = {
 	.ndo_do_ioctl		= hostap_ioctl,
 	.ndo_set_mac_address	= prism2_set_mac_address,
 	.ndo_set_rx_mode	= hostap_set_multicast_list,
-	.ndo_change_mtu 	= prism2_change_mtu,
 	.ndo_tx_timeout 	= prism2_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 };
@@ -826,7 +815,6 @@ static const struct net_device_ops hostap_mgmt_netdev_ops = {
 	.ndo_do_ioctl		= hostap_ioctl,
 	.ndo_set_mac_address	= prism2_set_mac_address,
 	.ndo_set_rx_mode	= hostap_set_multicast_list,
-	.ndo_change_mtu 	= prism2_change_mtu,
 	.ndo_tx_timeout 	= prism2_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 };
@@ -839,7 +827,6 @@ static const struct net_device_ops hostap_master_ops = {
 	.ndo_do_ioctl		= hostap_ioctl,
 	.ndo_set_mac_address	= prism2_set_mac_address,
 	.ndo_set_rx_mode	= hostap_set_multicast_list,
-	.ndo_change_mtu 	= prism2_change_mtu,
 	.ndo_tx_timeout 	= prism2_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 };
@@ -851,6 +838,8 @@ void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 
 	iface = netdev_priv(dev);
 	ether_setup(dev);
+	dev->min_mtu = PRISM2_MIN_MTU;
+	dev->max_mtu = PRISM2_MAX_MTU;
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 
 	/* kernel callbacks */
diff --git a/drivers/net/wireless/intersil/orinoco/main.c b/drivers/net/wireless/intersil/orinoco/main.c
index 7afe200..9d96b7c 100644
--- a/drivers/net/wireless/intersil/orinoco/main.c
+++ b/drivers/net/wireless/intersil/orinoco/main.c
@@ -322,9 +322,6 @@ int orinoco_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct orinoco_private *priv = ndev_priv(dev);
 
-	if ((new_mtu < ORINOCO_MIN_MTU) || (new_mtu > ORINOCO_MAX_MTU))
-		return -EINVAL;
-
 	/* MTU + encapsulation + header length */
 	if ((new_mtu + ENCAPS_OVERHEAD + sizeof(struct ieee80211_hdr)) >
 	     (priv->nicbuf_size - ETH_HLEN))
@@ -2288,6 +2285,9 @@ int orinoco_if_add(struct orinoco_private *priv,
 	dev->base_addr = base_addr;
 	dev->irq = irq;
 
+	dev->min_mtu = ORINOCO_MIN_MTU;
+	dev->max_mtu = ORINOCO_MAX_MTU;
+
 	SET_NETDEV_DEV(dev, priv->dev);
 	ret = register_netdev(dev);
 	if (ret)
diff --git a/drivers/staging/wlan-ng/p80211netdev.c b/drivers/staging/wlan-ng/p80211netdev.c
index 825a63a..4762d38 100644
--- a/drivers/staging/wlan-ng/p80211netdev.c
+++ b/drivers/staging/wlan-ng/p80211netdev.c
@@ -669,18 +669,6 @@ static int p80211knetdev_set_mac_address(struct net_device *dev, void *addr)
 	return result;
 }
 
-static int wlan_change_mtu(struct net_device *dev, int new_mtu)
-{
-	/* 2312 is max 802.11 payload, 20 is overhead, (ether + llc +snap)
-	   and another 8 for wep. */
-	if ((new_mtu < 68) || (new_mtu > (2312 - 20 - 8)))
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-
-	return 0;
-}
-
 static const struct net_device_ops p80211_netdev_ops = {
 	.ndo_init = p80211knetdev_init,
 	.ndo_open = p80211knetdev_open,
@@ -690,7 +678,6 @@ static const struct net_device_ops p80211_netdev_ops = {
 	.ndo_do_ioctl = p80211knetdev_do_ioctl,
 	.ndo_set_mac_address = p80211knetdev_set_mac_address,
 	.ndo_tx_timeout = p80211knetdev_tx_timeout,
-	.ndo_change_mtu = wlan_change_mtu,
 	.ndo_validate_addr = eth_validate_addr,
 };
 
@@ -756,6 +743,11 @@ int wlan_setup(struct wlandevice *wlandev, struct device *physdev)
 		wdev->wiphy = wiphy;
 		wdev->iftype = NL80211_IFTYPE_STATION;
 		netdev->ieee80211_ptr = wdev;
+		netdev->min_mtu = 68;
+		/* 2312 is max 802.11 payload, 20 is overhead,
+		 * (ether + llc + snap) and another 8 for wep.
+		 */
+		netdev->max_mtu = (2312 - 20 - 8);
 
 		netif_stop_queue(netdev);
 		netif_carrier_off(netdev);
diff --git a/drivers/tty/n_gsm.c b/drivers/tty/n_gsm.c
index 54cab59..f3932ba 100644
--- a/drivers/tty/n_gsm.c
+++ b/drivers/tty/n_gsm.c
@@ -2711,15 +2711,6 @@ static void gsm_mux_rx_netchar(struct gsm_dlci *dlci,
 	return;
 }
 
-static int gsm_change_mtu(struct net_device *net, int new_mtu)
-{
-	struct gsm_mux_net *mux_net = netdev_priv(net);
-	if ((new_mtu < 8) || (new_mtu > mux_net->dlci->gsm->mtu))
-		return -EINVAL;
-	net->mtu = new_mtu;
-	return 0;
-}
-
 static void gsm_mux_net_init(struct net_device *net)
 {
 	static const struct net_device_ops gsm_netdev_ops = {
@@ -2728,7 +2719,6 @@ static void gsm_mux_net_init(struct net_device *net)
 		.ndo_start_xmit		= gsm_mux_net_start_xmit,
 		.ndo_tx_timeout		= gsm_mux_net_tx_timeout,
 		.ndo_get_stats		= gsm_mux_net_get_stats,
-		.ndo_change_mtu		= gsm_change_mtu,
 	};
 
 	net->netdev_ops = &gsm_netdev_ops;
@@ -2787,6 +2777,8 @@ static int gsm_create_network(struct gsm_dlci *dlci, struct gsm_netconfig *nc)
 		return -ENOMEM;
 	}
 	net->mtu = dlci->gsm->mtu;
+	net->min_mtu = 8;
+	net->max_mtu = dlci->gsm->mtu;
 	mux_net = netdev_priv(net);
 	mux_net->dlci = dlci;
 	kref_init(&mux_net->ref);
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 638ec07..73e6a8f 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -150,15 +150,6 @@ void ieee80211_recalc_idle(struct ieee80211_local *local)
 		ieee80211_hw_config(local, change);
 }
 
-static int ieee80211_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < 256 || new_mtu > IEEE80211_MAX_DATA_LEN)
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static int ieee80211_verify_mac(struct ieee80211_sub_if_data *sdata, u8 *addr,
 				bool check_dup)
 {
@@ -1166,7 +1157,6 @@ static const struct net_device_ops ieee80211_dataif_ops = {
 	.ndo_uninit		= ieee80211_uninit,
 	.ndo_start_xmit		= ieee80211_subif_start_xmit,
 	.ndo_set_rx_mode	= ieee80211_set_multicast_list,
-	.ndo_change_mtu 	= ieee80211_change_mtu,
 	.ndo_set_mac_address 	= ieee80211_change_mac,
 	.ndo_select_queue	= ieee80211_netdev_select_queue,
 	.ndo_get_stats64	= ieee80211_get_stats64,
@@ -1200,7 +1190,6 @@ static const struct net_device_ops ieee80211_monitorif_ops = {
 	.ndo_uninit		= ieee80211_uninit,
 	.ndo_start_xmit		= ieee80211_monitor_start_xmit,
 	.ndo_set_rx_mode	= ieee80211_set_multicast_list,
-	.ndo_change_mtu 	= ieee80211_change_mtu,
 	.ndo_set_mac_address 	= ieee80211_change_mac,
 	.ndo_select_queue	= ieee80211_monitor_select_queue,
 	.ndo_get_stats64	= ieee80211_get_stats64,
@@ -1884,6 +1873,10 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 
 		netdev_set_default_ethtool_ops(ndev, &ieee80211_ethtool_ops);
 
+		/* MTU range: 256 - 2304 */
+		ndev->min_mtu = 256;
+		ndev->max_mtu = IEEE80211_MAX_DATA_LEN;
+
 		ret = register_netdevice(ndev);
 		if (ret) {
 			ieee80211_if_free(ndev);
-- 
2.10.0
