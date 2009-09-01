From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 18/19] wireless: convert drivers to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:57 -0700
Message-ID: <20090901055130.266010870@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57481 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752719AbZIAF66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:58 -0400
Content-Disposition: inline; filename=wireless.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly just simple conversions:
  * ray_cs had bogus return of NET_TX_LOCKED but driver
    was not using NETIF_F_LLTX
  * hostap and ipw2x00 had some code that returned value
    from a called function that also had to change to return netdev_tx_t

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/wimax/i2400m/netdev.c             |   12 ++++++------
 drivers/net/wireless/airo.c                   |   12 +++++++++---
 drivers/net/wireless/arlan-main.c             |    4 ++--
 drivers/net/wireless/atmel.c                  |    2 +-
 drivers/net/wireless/hostap/hostap_80211.h    |   10 +++++++---
 drivers/net/wireless/hostap/hostap_80211_tx.c |   11 +++++++----
 drivers/net/wireless/ipw2x00/ipw2100.c        |   10 +++++-----
 drivers/net/wireless/ipw2x00/ipw2200.c        |    9 +++++----
 drivers/net/wireless/ipw2x00/libipw.h         |    7 ++++---
 drivers/net/wireless/ipw2x00/libipw_tx.c      |    6 +++---
 drivers/net/wireless/libertas/decl.h          |    5 +++--
 drivers/net/wireless/libertas/main.c          |    3 ++-
 drivers/net/wireless/libertas/tx.c            |    6 ++----
 drivers/net/wireless/mac80211_hwsim.c         |    3 ++-
 drivers/net/wireless/netwave_cs.c             |    6 ++++--
 drivers/net/wireless/orinoco/main.c           |    2 +-
 drivers/net/wireless/prism54/islpci_eth.c     |    2 +-
 drivers/net/wireless/prism54/islpci_eth.h     |    2 +-
 drivers/net/wireless/ray_cs.c                 |   14 +++++++++-----
 drivers/net/wireless/strip.c                  |    2 +-
 drivers/net/wireless/wavelan.c                |    3 ++-
 drivers/net/wireless/wavelan.p.h              |    2 +-
 drivers/net/wireless/wavelan_cs.c             |    2 +-
 drivers/net/wireless/wavelan_cs.p.h           |    2 +-
 drivers/net/wireless/wl3501_cs.c              |    3 ++-
 drivers/net/wireless/zd1201.c                 |    3 ++-
 net/mac80211/ieee80211_i.h                    |    6 ++++--
 net/mac80211/tx.c                             |    8 ++++----
 28 files changed, 92 insertions(+), 65 deletions(-)

--- a/drivers/net/wireless/hostap/hostap_80211.h	2009-08-31 16:17:52.221080855 -0700
+++ b/drivers/net/wireless/hostap/hostap_80211.h	2009-08-31 16:33:06.481101881 -0700
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 #include <linux/skbuff.h>
+#include <linux/netdevice.h>
 
 struct hostap_ieee80211_mgmt {
 	__le16 frame_control;
@@ -85,8 +86,11 @@ void hostap_dump_rx_80211(const char *na
 			  struct hostap_80211_rx_status *rx_stats);
 
 void hostap_dump_tx_80211(const char *name, struct sk_buff *skb);
-int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev);
-int hostap_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev);
-int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t hostap_data_start_xmit(struct sk_buff *skb,
+				   struct net_device *dev);
+netdev_tx_t hostap_mgmt_start_xmit(struct sk_buff *skb,
+				   struct net_device *dev);
+netdev_tx_t hostap_master_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev);
 
 #endif /* HOSTAP_80211_H */
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c	2009-08-31 16:17:52.221080855 -0700
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c	2009-08-31 16:33:42.131158031 -0700
@@ -53,7 +53,8 @@ void hostap_dump_tx_80211(const char *na
 /* hard_start_xmit function for data interfaces (wlan#, wlan#wds#, wlan#sta)
  * Convert Ethernet header into a suitable IEEE 802.11 header depending on
  * device configuration. */
-int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t hostap_data_start_xmit(struct sk_buff *skb,
+				   struct net_device *dev)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
@@ -261,7 +262,8 @@ int hostap_data_start_xmit(struct sk_buf
 
 
 /* hard_start_xmit function for hostapd wlan#ap interfaces */
-int hostap_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t hostap_mgmt_start_xmit(struct sk_buff *skb,
+				   struct net_device *dev)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
@@ -373,11 +375,12 @@ static struct sk_buff * hostap_tx_encryp
 /* hard_start_xmit function for master radio interface wifi#.
  * AP processing (TX rate control, power save buffering, etc.).
  * Use hardware TX function to send the frame. */
-int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t hostap_master_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
-	int ret = NETDEV_TX_BUSY;
+	netdev_tx_t ret = NETDEV_TX_BUSY;
 	u16 fc;
 	struct hostap_tx_data tx;
 	ap_tx_ret tx_ret;
--- a/drivers/net/wireless/ipw2x00/ipw2200.c	2009-08-31 16:17:52.321081485 -0700
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c	2009-08-31 16:34:38.021326615 -0700
@@ -10459,12 +10459,12 @@ static void ipw_handle_promiscuous_tx(st
 }
 #endif
 
-static int ipw_net_hard_start_xmit(struct libipw_txb *txb,
-				   struct net_device *dev, int pri)
+static netdev_tx_t ipw_net_hard_start_xmit(struct libipw_txb *txb,
+					   struct net_device *dev, int pri)
 {
 	struct ipw_priv *priv = libipw_priv(dev);
 	unsigned long flags;
-	int ret;
+	netdev_tx_t ret;
 
 	IPW_DEBUG_TX("dev->xmit(%d bytes)\n", txb->payload_size);
 	spin_lock_irqsave(&priv->lock, flags);
@@ -11602,7 +11602,8 @@ static int ipw_prom_stop(struct net_devi
 	return 0;
 }
 
-static int ipw_prom_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ipw_prom_hard_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	IPW_DEBUG_INFO("prom dev->xmit\n");
 	dev_kfree_skb(skb);
--- a/drivers/net/wireless/ipw2x00/libipw.h	2009-08-31 16:17:52.301107927 -0700
+++ b/drivers/net/wireless/ipw2x00/libipw.h	2009-08-31 16:34:56.121117022 -0700
@@ -867,8 +867,8 @@ struct libipw_device {
 	/* Callback functions */
 	void (*set_security) (struct net_device * dev,
 			      struct libipw_security * sec);
-	int (*hard_start_xmit) (struct libipw_txb * txb,
-				struct net_device * dev, int pri);
+	netdev_tx_t (*hard_start_xmit) (struct libipw_txb * txb,
+					struct net_device * dev, int pri);
 	int (*reset_port) (struct net_device * dev);
 	int (*is_queue_full) (struct net_device * dev, int pri);
 
@@ -1028,7 +1028,8 @@ extern void libipw_networks_age(struct l
 extern int libipw_set_encryption(struct libipw_device *ieee);
 
 /* libipw_tx.c */
-extern int libipw_xmit(struct sk_buff *skb, struct net_device *dev);
+extern netdev_tx_t libipw_xmit(struct sk_buff *skb,
+			       struct net_device *dev);
 extern void libipw_txb_free(struct libipw_txb *);
 
 /* libipw_rx.c */
--- a/drivers/net/wireless/ipw2x00/libipw_tx.c	2009-08-31 16:17:52.301107927 -0700
+++ b/drivers/net/wireless/ipw2x00/libipw_tx.c	2009-08-31 16:35:03.781105301 -0700
@@ -252,7 +252,7 @@ static int libipw_classify(struct sk_buf
 
 /* Incoming skb is converted to a txb which consists of
  * a block of 802.11 fragment packets (stored as skbs) */
-int libipw_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t libipw_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct libipw_device *ieee = netdev_priv(dev);
 	struct libipw_txb *txb = NULL;
@@ -523,8 +523,8 @@ int libipw_xmit(struct sk_buff *skb, str
 	dev_kfree_skb_any(skb);
 
 	if (txb) {
-		int ret = (*ieee->hard_start_xmit) (txb, dev, priority);
-		if (ret == 0) {
+		netdev_tx_t ret = (*ieee->hard_start_xmit)(txb, dev, priority);
+		if (ret == NETDEV_TX_OK) {
 			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += txb->payload_size;
 			return NETDEV_TX_OK;
--- a/drivers/net/wimax/i2400m/netdev.c	2009-08-31 16:17:52.191080883 -0700
+++ b/drivers/net/wimax/i2400m/netdev.c	2009-08-31 16:32:16.163627458 -0700
@@ -334,12 +334,12 @@ int i2400m_net_tx(struct i2400m *i2400m,
  * that will sleep. See i2400m_net_wake_tx() for details.
  */
 static
-int i2400m_hard_start_xmit(struct sk_buff *skb,
-			   struct net_device *net_dev)
+netdev_tx_t i2400m_hard_start_xmit(struct sk_buff *skb,
+					 struct net_device *net_dev)
 {
-	int result;
 	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
 	struct device *dev = i2400m_dev(i2400m);
+	int result;
 
 	d_fnstart(3, dev, "(skb %p net_dev %p)\n", skb, net_dev);
 	if (i2400m->state == I2400M_SS_IDLE)
@@ -353,9 +353,9 @@ int i2400m_hard_start_xmit(struct sk_buf
 		net_dev->stats.tx_bytes += skb->len;
 	}
 	kfree_skb(skb);
-	result = NETDEV_TX_OK;
-	d_fnend(3, dev, "(skb %p net_dev %p) = %d\n", skb, net_dev, result);
-	return result;
+
+	d_fnend(3, dev, "(skb %p net_dev %p)\n", skb, net_dev);
+	return NETDEV_TX_OK;
 }
 
 
--- a/drivers/net/wireless/airo.c	2009-08-31 16:17:52.251122313 -0700
+++ b/drivers/net/wireless/airo.c	2009-08-31 16:32:16.163627458 -0700
@@ -1920,7 +1920,9 @@ static int airo_open(struct net_device *
 	return 0;
 }
 
-static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
+static netdev_tx_t mpi_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
+{
 	int npacks, pending;
 	unsigned long flags;
 	struct airo_info *ai = dev->ml_priv;
@@ -2119,7 +2121,9 @@ static void airo_end_xmit(struct net_dev
 	dev_kfree_skb(skb);
 }
 
-static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
+static netdev_tx_t airo_start_xmit(struct sk_buff *skb,
+					 struct net_device *dev)
+{
 	s16 len;
 	int i, j;
 	struct airo_info *priv = dev->ml_priv;
@@ -2184,7 +2188,9 @@ static void airo_end_xmit11(struct net_d
 	dev_kfree_skb(skb);
 }
 
-static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
+static netdev_tx_t airo_start_xmit11(struct sk_buff *skb,
+					   struct net_device *dev)
+{
 	s16 len;
 	int i, j;
 	struct airo_info *priv = dev->ml_priv;
--- a/drivers/net/wireless/arlan-main.c	2009-08-31 16:17:52.201081246 -0700
+++ b/drivers/net/wireless/arlan-main.c	2009-08-31 16:32:16.173591015 -0700
@@ -77,7 +77,7 @@ struct arlan_conf_stru arlan_conf[MAX_AR
 static int arlans_found;
 
 static  int 	arlan_open(struct net_device *dev);
-static  int 	arlan_tx(struct sk_buff *skb, struct net_device *dev);
+static  netdev_tx_t arlan_tx(struct sk_buff *skb, struct net_device *dev);
 static  irqreturn_t arlan_interrupt(int irq, void *dev_id);
 static  int 	arlan_close(struct net_device *dev);
 static  struct net_device_stats *
@@ -1169,7 +1169,7 @@ static void arlan_tx_timeout (struct net
 }
 
 
-static int arlan_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t arlan_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	short length;
 	unsigned char *buf;
--- a/drivers/net/wireless/atmel.c	2009-08-31 16:17:52.351091725 -0700
+++ b/drivers/net/wireless/atmel.c	2009-08-31 16:32:16.173591015 -0700
@@ -781,7 +781,7 @@ static void tx_update_descriptor(struct 
 	priv->tx_free_mem -= len;
 }
 
-static int start_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	static const u8 SNAP_RFC1024[6] = { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
 	struct atmel_private *priv = netdev_priv(dev);
--- a/drivers/net/wireless/libertas/decl.h	2009-08-31 16:17:52.281153994 -0700
+++ b/drivers/net/wireless/libertas/decl.h	2009-08-31 16:35:07.071275355 -0700
@@ -6,7 +6,7 @@
 #ifndef _LBS_DECL_H_
 #define _LBS_DECL_H_
 
-#include <linux/device.h>
+#include <linux/netdevice.h>
 
 #include "defs.h"
 
@@ -41,7 +41,8 @@ u8 lbs_data_rate_to_fw_index(u32 rate);
 int lbs_process_command_response(struct lbs_private *priv, u8 *data, u32 len);
 void lbs_complete_command(struct lbs_private *priv, struct cmd_ctrl_node *cmd,
 			  int result);
-int lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t lbs_hard_start_xmit(struct sk_buff *skb,
+				struct net_device *dev);
 int lbs_set_regiontable(struct lbs_private *priv, u8 region, u8 band);
 
 int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *);
--- a/drivers/net/wireless/libertas/main.c	2009-08-31 16:17:52.291081163 -0700
+++ b/drivers/net/wireless/libertas/main.c	2009-08-31 16:35:10.491118027 -0700
@@ -1647,7 +1647,8 @@ static int lbs_rtap_stop(struct net_devi
 	return 0;
 }
 
-static int lbs_rtap_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t lbs_rtap_hard_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	netif_stop_queue(dev);
 	return NETDEV_TX_BUSY;
--- a/drivers/net/wireless/libertas/tx.c	2009-08-31 16:17:52.281153994 -0700
+++ b/drivers/net/wireless/libertas/tx.c	2009-08-31 16:35:15.351107216 -0700
@@ -57,19 +57,17 @@ static u32 convert_radiotap_rate_to_mv(u
  *  @param skb     A pointer to skb which includes TX packet
  *  @return 	   0 or -1
  */
-int lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	struct lbs_private *priv = dev->ml_priv;
 	struct txpd *txpd;
 	char *p802x_hdr;
 	uint16_t pkt_len;
-	int ret;
+	netdev_tx_t ret = NETDEV_TX_OK;
 
 	lbs_deb_enter(LBS_DEB_TX);
 
-	ret = NETDEV_TX_OK;
-
 	/* We need to protect against the queues being restarted before
 	   we get round to stopping them */
 	spin_lock_irqsave(&priv->driver_lock, flags);
--- a/drivers/net/wireless/mac80211_hwsim.c	2009-08-31 16:17:52.331108249 -0700
+++ b/drivers/net/wireless/mac80211_hwsim.c	2009-08-31 16:32:16.173591015 -0700
@@ -312,7 +312,8 @@ struct hwsim_radiotap_hdr {
 } __attribute__ ((packed));
 
 
-static int hwsim_mon_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t hwsim_mon_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
 	/* TODO: allow packet injection */
 	dev_kfree_skb(skb);
--- a/drivers/net/wireless/netwave_cs.c	2009-08-31 16:17:52.241107004 -0700
+++ b/drivers/net/wireless/netwave_cs.c	2009-08-31 16:32:16.173591015 -0700
@@ -203,7 +203,8 @@ static int netwave_open(struct net_devic
 static int netwave_close(struct net_device *dev); /* Close the device */
 
 /* Packet transmission and Packet reception */
-static int netwave_start_xmit( struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t netwave_start_xmit( struct sk_buff *skb,
+					     struct net_device *dev);
 static int netwave_rx( struct net_device *dev);
 
 /* Interrupt routines */
@@ -1026,7 +1027,8 @@ static int netwave_hw_xmit(unsigned char
     return 0;
 }
 
-static int netwave_start_xmit(struct sk_buff *skb, struct net_device *dev) {
+static netdev_tx_t netwave_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev) {
 	/* This flag indicate that the hardware can't perform a transmission.
 	 * Theoritically, NET3 check it before sending a packet to the driver,
 	 * but in fact it never do that and pool continuously.
--- a/drivers/net/wireless/orinoco/main.c	2009-08-31 16:17:52.291081163 -0700
+++ b/drivers/net/wireless/orinoco/main.c	2009-08-31 16:35:20.123589613 -0700
@@ -337,7 +337,7 @@ static int orinoco_change_mtu(struct net
 /* Tx path                                                          */
 /********************************************************************/
 
-static int orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct orinoco_private *priv = ndev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
--- a/drivers/net/wireless/prism54/islpci_eth.c	2009-08-31 16:17:52.261081191 -0700
+++ b/drivers/net/wireless/prism54/islpci_eth.c	2009-08-31 16:32:16.173591015 -0700
@@ -72,7 +72,7 @@ islpci_eth_cleanup_transmit(islpci_priva
 	}
 }
 
-int
+netdev_tx_t
 islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	islpci_private *priv = netdev_priv(ndev);
--- a/drivers/net/wireless/prism54/islpci_eth.h	2009-08-31 16:17:52.271108094 -0700
+++ b/drivers/net/wireless/prism54/islpci_eth.h	2009-08-31 16:32:16.173591015 -0700
@@ -64,7 +64,7 @@ struct avs_80211_1_header {
 };
 
 void islpci_eth_cleanup_transmit(islpci_private *, isl38xx_control_block *);
-int islpci_eth_transmit(struct sk_buff *, struct net_device *);
+netdev_tx_t islpci_eth_transmit(struct sk_buff *, struct net_device *);
 int islpci_eth_receive(islpci_private *);
 void islpci_eth_tx_timeout(struct net_device *);
 void islpci_do_reset_and_wake(struct work_struct *);
--- a/drivers/net/wireless/ray_cs.c	2009-08-31 16:17:52.361105988 -0700
+++ b/drivers/net/wireless/ray_cs.c	2009-08-31 16:32:16.173591015 -0700
@@ -104,7 +104,8 @@ static int ray_dev_init(struct net_devic
 static const struct ethtool_ops netdev_ethtool_ops;
 
 static int ray_open(struct net_device *dev);
-static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ray_dev_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 static void ray_update_multi_list(struct net_device *dev, int all);
 static int translate_frame(ray_dev_t *local, struct tx_msg __iomem *ptx,
@@ -915,16 +916,19 @@ static int ray_dev_config(struct net_dev
 }
 
 /*===========================================================================*/
-static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ray_dev_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	ray_dev_t *local = netdev_priv(dev);
 	struct pcmcia_device *link = local->finder;
 	short length = skb->len;
 
-	if (!(pcmcia_dev_present(link))) {
+	if (!pcmcia_dev_present(link)) {
 		DEBUG(2, "ray_dev_start_xmit - device not present\n");
-		return NETDEV_TX_LOCKED;
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
+
 	DEBUG(3, "ray_dev_start_xmit(skb=%p, dev=%p)\n", skb, dev);
 	if (local->authentication_state == NEED_TO_AUTH) {
 		DEBUG(0, "ray_cs Sending authentication request.\n");
@@ -951,8 +955,8 @@ static int ray_dev_start_xmit(struct sk_
 	default:
 		dev->trans_start = jiffies;
 		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
 	}
+
 	return NETDEV_TX_OK;
 } /* ray_dev_start_xmit */
 
--- a/drivers/net/wireless/strip.c	2009-08-31 16:17:52.201081246 -0700
+++ b/drivers/net/wireless/strip.c	2009-08-31 16:32:16.183606045 -0700
@@ -1533,7 +1533,7 @@ static void strip_send(struct strip *str
 }
 
 /* Encapsulate a datagram and kick it into a TTY queue. */
-static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t strip_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct strip *strip_info = netdev_priv(dev);
 
--- a/drivers/net/wireless/wavelan.c	2009-08-31 16:17:52.211107939 -0700
+++ b/drivers/net/wireless/wavelan.c	2009-08-31 16:32:16.183606045 -0700
@@ -2841,7 +2841,8 @@ static int wv_packet_write(struct net_de
  * the packet.  We also prevent reentrance.  Then we call the function
  * to send the packet.
  */
-static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
+static netdev_tx_t wavelan_packet_xmit(struct sk_buff *skb,
+					     struct net_device * dev)
 {
 	net_local *lp = netdev_priv(dev);
 	unsigned long flags;
--- a/drivers/net/wireless/wavelan_cs.c	2009-08-31 16:17:52.231081009 -0700
+++ b/drivers/net/wireless/wavelan_cs.c	2009-08-31 16:32:16.183606045 -0700
@@ -3078,7 +3078,7 @@ wv_packet_write(struct net_device *	dev,
  * the packet. We also prevent reentrance. Then, we call the function
  * to send the packet...
  */
-static int
+static netdev_tx_t
 wavelan_packet_xmit(struct sk_buff *	skb,
 		    struct net_device *		dev)
 {
--- a/drivers/net/wireless/wl3501_cs.c	2009-08-31 16:17:52.331108249 -0700
+++ b/drivers/net/wireless/wl3501_cs.c	2009-08-31 16:32:16.183606045 -0700
@@ -1333,7 +1333,8 @@ static void wl3501_tx_timeout(struct net
  *	    1 - Could not transmit (dev_queue_xmit will queue it)
  *		and try to sent it later
  */
-static int wl3501_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t wl3501_hard_start_xmit(struct sk_buff *skb,
+						struct net_device *dev)
 {
 	int enabled, rc;
 	struct wl3501_card *this = netdev_priv(dev);
--- a/drivers/net/wireless/zd1201.c	2009-08-31 16:17:52.341091082 -0700
+++ b/drivers/net/wireless/zd1201.c	2009-08-31 16:32:16.183606045 -0700
@@ -779,7 +779,8 @@ static int zd1201_net_stop(struct net_de
 				(llc+snap+type+payload)
 		zd		1 null byte, zd1201 packet type
  */
-static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t zd1201_hard_start_xmit(struct sk_buff *skb,
+						struct net_device *dev)
 {
 	struct zd1201 *zd = netdev_priv(dev);
 	unsigned char *txbuf = zd->txdata;
--- a/drivers/net/wireless/wavelan.p.h	2009-08-31 16:17:52.251122313 -0700
+++ b/drivers/net/wireless/wavelan.p.h	2009-08-31 16:32:16.183606045 -0700
@@ -611,7 +611,7 @@ static inline int
 	wv_packet_write(struct net_device *,	/* Write a packet to the Tx buffer. */
 			void *,
 			short);
-static int
+static netdev_tx_t
 	wavelan_packet_xmit(struct sk_buff *,	/* Send a packet. */
 			    struct net_device *);
 /* -------------------- HARDWARE CONFIGURATION -------------------- */
--- a/drivers/net/wireless/wavelan_cs.p.h	2009-08-31 16:17:52.341091082 -0700
+++ b/drivers/net/wireless/wavelan_cs.p.h	2009-08-31 16:32:16.183606045 -0700
@@ -707,7 +707,7 @@ static void
 	wv_packet_write(struct net_device *,	/* Write a packet to the Tx buffer */
 			void *,
 			short);
-static int
+static netdev_tx_t
 	wavelan_packet_xmit(struct sk_buff *,	/* Send a packet */
 			    struct net_device *);
 /* -------------------- HARDWARE CONFIGURATION -------------------- */
--- a/drivers/net/wireless/ipw2x00/ipw2100.c	2009-08-31 16:17:52.311180087 -0700
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c	2009-08-31 16:34:41.791081639 -0700
@@ -3330,8 +3330,8 @@ static irqreturn_t ipw2100_interrupt(int
 	return IRQ_NONE;
 }
 
-static int ipw2100_tx(struct libipw_txb *txb, struct net_device *dev,
-		      int pri)
+static netdev_tx_t ipw2100_tx(struct libipw_txb *txb,
+			      struct net_device *dev, int pri)
 {
 	struct ipw2100_priv *priv = libipw_priv(dev);
 	struct list_head *element;
@@ -3369,12 +3369,12 @@ static int ipw2100_tx(struct libipw_txb 
 	ipw2100_tx_send_data(priv);
 
 	spin_unlock_irqrestore(&priv->low_lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 
-      fail_unlock:
+fail_unlock:
 	netif_stop_queue(dev);
 	spin_unlock_irqrestore(&priv->low_lock, flags);
-	return 1;
+	return NETDEV_TX_BUSY;
 }
 
 static int ipw2100_msg_allocate(struct ipw2100_priv *priv)
--- a/net/mac80211/ieee80211_i.h	2009-08-31 16:17:52.181107339 -0700
+++ b/net/mac80211/ieee80211_i.h	2009-08-31 16:36:09.011107509 -0700
@@ -1050,8 +1050,10 @@ void ieee80211_recalc_idle(struct ieee80
 /* tx handling */
 void ieee80211_clear_tx_pending(struct ieee80211_local *local);
 void ieee80211_tx_pending(unsigned long data);
-int ieee80211_monitor_start_xmit(struct sk_buff *skb, struct net_device *dev);
-int ieee80211_subif_start_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t ieee80211_monitor_start_xmit(struct sk_buff *skb,
+					 struct net_device *dev);
+netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
+				       struct net_device *dev);
 
 /* HT */
 void ieee80211_ht_cap_ie_to_sta_ht_cap(struct ieee80211_supported_band *sband,
--- a/net/mac80211/tx.c	2009-08-31 16:17:52.191080883 -0700
+++ b/net/mac80211/tx.c	2009-08-31 16:36:13.706387007 -0700
@@ -1483,8 +1483,8 @@ static void ieee80211_xmit(struct ieee80
 	dev_put(sdata->dev);
 }
 
-int ieee80211_monitor_start_xmit(struct sk_buff *skb,
-				 struct net_device *dev)
+netdev_tx_t ieee80211_monitor_start_xmit(struct sk_buff *skb,
+					 struct net_device *dev)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_channel *chan = local->hw.conf.channel;
@@ -1568,8 +1568,8 @@ fail:
  * encapsulated packet will then be passed to master interface, wlan#.11, for
  * transmission (through low-level driver).
  */
-int ieee80211_subif_start_xmit(struct sk_buff *skb,
-			       struct net_device *dev)
+netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local = sdata->local;

-- 

