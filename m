From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 15/16] Host AP: Replaced direct dev->priv references with netdev_priv(dev).
Date: Sat, 13 Nov 2004 21:24:47 -0800
Message-ID: <20041114052447.GG14810@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap.c b/drivers/net/wireless/hostap/hostap.c
--- a/drivers/net/wireless/hostap/hostap.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap.c	2004-11-13 20:56:44 -08:00
@@ -117,7 +117,7 @@
 	if (dev == NULL)
 		return NULL;
 
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 	iface->dev = dev;
 	iface->local = local;
 	iface->type = type;
@@ -169,7 +169,7 @@
 	if (!dev)
 		return;
 
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 
 	if (remove_from_list) {
 		list_del(&iface->list);
@@ -254,7 +254,7 @@
 	if (dev == NULL)
 		return -ENOMEM;
 
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 	memcpy(iface->u.wds.remote_addr, remote_addr, ETH_ALEN);
 
 	local->wds_connections++;
@@ -351,18 +351,20 @@
 /* val is in host byte order */
 int hostap_set_word(struct net_device *dev, int rid, u16 val)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface;
 	u16 tmp = cpu_to_le16(val);
+	iface = netdev_priv(dev);
 	return iface->local->func->set_rid(dev, rid, &tmp, 2);
 }
 
 
 int hostap_set_string(struct net_device *dev, int rid, const char *val)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface;
 	char buf[MAX_SSID_LEN + 2];
 	int len;
 
+	iface = netdev_priv(dev);
 	len = strlen(val);
 	if (len > MAX_SSID_LEN)
 		return -1;
@@ -692,18 +694,22 @@
 
 struct net_device_stats *hostap_get_stats(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface;
+	iface = netdev_priv(dev);
 	return &iface->stats;
 }
 
 
 static int prism2_close(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 
 	PDEBUG(DEBUG_FLOW, "%s: prism2_close\n", dev->name);
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (dev == local->ddev) {
 		prism2_sta_deauth(local, WLAN_REASON_DEAUTH_LEAVING);
 	}
@@ -746,11 +752,14 @@
 
 static int prism2_open(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 
 	PDEBUG(DEBUG_FLOW, "%s: prism2_open\n", dev->name);
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->no_pri) {
 		printk(KERN_DEBUG "%s: could not set interface UP - no PRI "
 		       "f/w\n", dev->name);
@@ -794,11 +803,14 @@
 
 static int prism2_set_mac_address(struct net_device *dev, void *p)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct list_head *ptr;
 	struct sockaddr *addr = p;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->func->set_rid(dev, HFA384X_RID_CNFOWNMACADDR, addr->sa_data,
 				 ETH_ALEN) < 0 || local->func->reset_port(dev))
 		return -EINVAL;
@@ -820,9 +832,11 @@
 void hostap_set_multicast_list_queue(void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	if (hostap_set_word(dev, HFA384X_RID_PROMISCUOUSMODE,
 			    local->is_promisc)) {
 		printk(KERN_INFO "%s: %sabling promiscuous mode failed\n",
@@ -838,9 +852,11 @@
 	 * some station firmware versions (FCSErr frames, invalid MACPort, etc.
 	 * corrupted incoming frames). This code is now commented out while the
 	 * problems are investigated. */
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	if ((dev->flags & IFF_ALLMULTI) || (dev->flags & IFF_PROMISC)) {
 		local->is_promisc = 1;
 	} else {
@@ -864,10 +880,13 @@
 
 static void prism2_tx_timeout(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hfa384x_regs regs;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	printk(KERN_WARNING "%s Tx timed out! Resetting card\n", dev->name);
 	netif_stop_queue(local->dev);
 
@@ -884,8 +903,9 @@
 void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 		      int main_dev)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface;
 
+	iface = netdev_priv(dev);
 	ether_setup(dev);
 
 	/* kernel callbacks */
@@ -1039,11 +1059,13 @@
 
 int prism2_update_comms_qual(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int ret = 0;
 	struct hfa384x_comms_quality sq;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	if (!local->sta_fw_ver)
 		ret = -1;
 	else if (local->sta_fw_ver >= PRISM2_FW_VER(1,3,1)) {
@@ -1099,7 +1121,7 @@
 	meta = (struct hostap_skb_tx_data *) skb->cb;
 	memset(meta, 0, sizeof(*meta));
 	meta->magic = HOSTAP_SKB_TX_DATA_MAGIC;
-	meta->iface = dev->priv;
+	meta->iface = netdev_priv(dev);
 
 	skb->dev = dev;
 	skb->mac.raw = skb->nh.raw = skb->data;
diff -Nru a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-13 20:56:44 -08:00
@@ -46,13 +46,15 @@
 int prism2_rx_80211(struct net_device *dev, struct sk_buff *skb,
 		    struct hostap_80211_rx_status *rx_stats, int type)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int hdrlen, phdrlen, head_need, tail_need;
 	u16 fc;
 	int prism_header, ret;
 	struct hostap_ieee80211_hdr *hdr;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	dev->last_rx = jiffies;
 
 	if (dev->type == ARPHRD_IEEE80211_PRISM) {
@@ -677,8 +679,8 @@
 void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 		     struct hostap_80211_rx_status *rx_stats)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hostap_ieee80211_hdr *hdr;
 	size_t hdrlen;
 	u16 fc, type, stype, sc;
@@ -696,13 +698,15 @@
 	void *sta = NULL;
 	int keyidx = 0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	iface->stats.rx_packets++;
 	iface->stats.rx_bytes += skb->len;
 
 	/* dev is the master radio device; change this to be the default
 	 * virtual interface (this may be changed to WDS device below) */
 	dev = local->ddev;
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 
 	hdr = (struct hostap_ieee80211_hdr *) skb->data;
 	stats = hostap_get_stats(dev);
diff -Nru a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c	2004-11-13 20:56:44 -08:00
@@ -38,8 +38,8 @@
  * device configuration. */
 int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int need_headroom, need_tailroom = 0;
 	struct hostap_ieee80211_hdr hdr;
 	u16 fc, ethertype = 0;
@@ -51,6 +51,9 @@
 	int to_assoc_ap = 0;
 	struct hostap_skb_tx_data *meta;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (skb->len < ETH_HLEN) {
 		printk(KERN_DEBUG "%s: hostap_data_start_xmit: short skb "
 		       "(len=%d)\n", dev->name, skb->len);
@@ -237,12 +240,15 @@
 /* hard_start_xmit function for hostapd wlan#ap interfaces */
 int hostap_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hostap_skb_tx_data *meta;
 	struct hostap_ieee80211_hdr *hdr;
 	u16 fc;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (skb->len < 10) {
 		printk(KERN_DEBUG "%s: hostap_mgmt_start_xmit: short skb "
 		       "(len=%d)\n", dev->name, skb->len);
@@ -280,12 +286,15 @@
 struct sk_buff * hostap_tx_encrypt(struct sk_buff *skb,
 				   struct prism2_crypt_data *crypt)
 {
-	struct hostap_interface *iface = skb->dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hostap_ieee80211_hdr *hdr;
 	u16 fc;
 	int hdr_len, res;
 
+	iface = netdev_priv(skb->dev);
+	local = iface->local;
+
 	if (skb->len < IEEE80211_DATA_HDR3_LEN) {
 		kfree_skb(skb);
 		return NULL;
@@ -342,8 +351,8 @@
  * Use hardware TX function to send the frame. */
 int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int ret = 1;
 	u16 fc;
 	struct hostap_tx_data tx;
@@ -351,6 +360,9 @@
 	struct hostap_skb_tx_data *meta;
 	int no_encrypt = 0;
 	struct hostap_ieee80211_hdr *hdr;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	tx.skb = skb;
 	tx.sta_ptr = NULL;
diff -Nru a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
--- a/drivers/net/wireless/hostap/hostap_ap.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ap.c	2004-11-13 20:56:44 -08:00
@@ -915,16 +915,18 @@
 			     int type, int subtype, char *body,
 			     int body_len, u8 *addr, u16 tx_cb_idx)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hostap_ieee80211_hdr *hdr;
 	u16 fc;
 	struct sk_buff *skb;
 	struct hostap_skb_tx_data *meta;
 	int hdrlen;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	dev = local->dev; /* always use master radio device */
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 
 	if (!(dev->flags & IFF_UP)) {
 		PDEBUG(DEBUG_AP, "%s: prism2_send_mgmt - device is not UP - "
@@ -2252,11 +2254,14 @@
 void hostap_rx(struct net_device *dev, struct sk_buff *skb,
 	       struct hostap_80211_rx_status *rx_stats)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 fc;
 	struct hostap_ieee80211_hdr *hdr;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (skb->len < 16)
 		goto drop;
 
@@ -2359,9 +2364,9 @@
  * format that the Wireless Tools will understand - Jean II */
 static int prism2_ap_translate_scan(struct net_device *dev, char *buffer)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
-	struct ap_data *ap = local->ap;
+	struct hostap_interface *iface;
+	local_info_t *local;
+	struct ap_data *ap;
 	struct list_head *ptr;
 	struct iw_event iwe;
 	char *current_ev = buffer;
@@ -2370,6 +2375,10 @@
 	char buf[64];
 #endif
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+	ap = local->ap;
+
 	spin_lock_bh(&ap->sta_table_lock);
 
 	for (ptr = ap->sta_list.next; ptr != NULL && ptr != &ap->sta_list;
@@ -2601,8 +2610,11 @@
 static int ap_update_sta_tx_rate(struct sta_info *sta, struct net_device *dev)
 {
 	int ret = sta->tx_rate;
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	sta->tx_count[sta->tx_rate_idx]++;
 	sta->tx_since_last_failure++;
diff -Nru a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
--- a/drivers/net/wireless/hostap/hostap_cs.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_cs.c	2004-11-13 20:56:44 -08:00
@@ -51,10 +51,12 @@
 
 static inline void hfa384x_outb_debug(struct net_device *dev, int a, u8 v)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTB, a, v);
 	outb(v, dev->base_addr + a);
@@ -63,11 +65,13 @@
 
 static inline u8 hfa384x_inb_debug(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 	u8 v;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	spin_lock_irqsave(&local->lock, flags);
 	v = inb(dev->base_addr + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INB, a, v);
@@ -77,10 +81,12 @@
 
 static inline void hfa384x_outw_debug(struct net_device *dev, int a, u16 v)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTW, a, v);
 	outw(v, dev->base_addr + a);
@@ -89,11 +95,13 @@
 
 static inline u16 hfa384x_inw_debug(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 	u16 v;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	spin_lock_irqsave(&local->lock, flags);
 	v = inw(dev->base_addr + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INW, a, v);
@@ -104,10 +112,12 @@
 static inline void hfa384x_outsw_debug(struct net_device *dev, int a,
 				       u8 *buf, int wc)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTSW, a, wc);
 	outsw(dev->base_addr + a, buf, wc);
@@ -117,10 +127,12 @@
 static inline void hfa384x_insw_debug(struct net_device *dev, int a,
 				      u8 *buf, int wc)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INSW, a, wc);
 	insw(dev->base_addr + a, buf, wc);
@@ -623,7 +635,7 @@
 	link->state |= DEV_CONFIG;
 	link->state &= ~DEV_CONFIG_PENDING;
 
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 	local = iface->local;
 	local->link = link;
 	strcpy(local->node.dev_name, dev->name);
@@ -656,7 +668,9 @@
 
 	if (link->priv) {
 		struct net_device *dev = link->priv;
-		struct hostap_interface *iface = dev->priv;
+		struct hostap_interface *iface;
+
+		iface = netdev_priv(dev);
 		if (link->state & DEV_CONFIG)
 			prism2_hw_shutdown(dev, 0);
 		iface->local->shutdown = 1;
diff -Nru a/drivers/net/wireless/hostap/hostap_download.c b/drivers/net/wireless/hostap/hostap_download.c
--- a/drivers/net/wireless/hostap/hostap_download.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_download.c	2004-11-13 20:56:44 -08:00
@@ -3,8 +3,11 @@
 	u16 val, reg;
 	int i, tries;
 	unsigned long flags;
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	if (local->no_pri) {
 		if (enable) {
diff -Nru a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
--- a/drivers/net/wireless/hostap/hostap_hw.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_hw.c	2004-11-13 20:56:44 -08:00
@@ -274,12 +274,15 @@
 static inline int hfa384x_cmd_issue(struct net_device *dev,
 				    struct hostap_cmd_queue *entry)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int tries;
 	u16 reg;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->func->card_present && !local->func->card_present(local))
 		return -ENODEV;
 
@@ -338,13 +341,16 @@
 static int hfa384x_cmd(struct net_device *dev, u16 cmd, u16 param0,
 		       u16 *param1, u16 *resp0)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int err, res, issue, issued = 0;
 	unsigned long flags;
 	struct hostap_cmd_queue *entry;
 	DECLARE_WAITQUEUE(wait, current);
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (in_interrupt()) {
 		printk(KERN_DEBUG "%s: hfa384x_cmd called from interrupt "
 		       "context\n", dev->name);
@@ -515,12 +521,15 @@
 						 u16 status),
 				void *context)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int issue, ret;
 	unsigned long flags;
 	struct hostap_cmd_queue *entry;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->cmd_queue_len >= HOSTAP_CMD_QUEUE_MAX_LEN + 2) {
 		printk(KERN_DEBUG "%s: hfa384x_cmd: cmd_queue full\n",
 		       dev->name);
@@ -674,10 +683,13 @@
  */
 static void prism2_cmd_ev(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hostap_cmd_queue *entry = NULL;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock(&local->cmdlock);
 	if (!list_empty(&local->cmd_queue)) {
 		entry = list_entry(local->cmd_queue.next,
@@ -817,11 +829,14 @@
 static int hfa384x_get_rid(struct net_device *dev, u16 rid, void *buf, int len,
 			   int exact_len)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int res, rlen = 0;
 	struct hfa384x_rid_hdr rec;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->no_pri) {
 		printk(KERN_DEBUG "%s: cannot get RID %04x (len=%d) - no PRI "
 		       "f/w\n", dev->name, rid, len);
@@ -887,11 +902,14 @@
 
 static int hfa384x_set_rid(struct net_device *dev, u16 rid, void *buf, int len)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hfa384x_rid_hdr rec;
 	int res;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->no_pri) {
 		printk(KERN_DEBUG "%s: cannot set RID %04x (len=%d) - no PRI "
 		       "f/w\n", dev->name, rid, len);
@@ -1009,10 +1027,13 @@
 
 static int prism2_reset_port(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int res;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (!local->dev_enabled)
 		return 0;
 
@@ -1048,8 +1069,11 @@
 				   const char *txt)
 {
 	struct hfa384x_comp_ident comp;
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	if (local->no_pri) {
 		/* PRI f/w not yet available - cannot read RIDs */
@@ -1069,11 +1093,14 @@
 
 static int prism2_setup_rids(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 tmp;
 	int ret = 0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	hostap_set_word(dev, HFA384X_RID_TICKTIME, 2000);
 
 	if (!local->fw_ap) {
@@ -1288,13 +1315,16 @@
 
 static int prism2_hw_init(struct net_device *dev, int initial)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int ret, first = 1;
 	unsigned long start, delay;
 
 	PDEBUG(DEBUG_FLOW, "prism2_hw_init()\n");
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	clear_bit(HOSTAP_BITS_TRANSMIT, &local->bits);
 
  init:
@@ -1341,10 +1371,13 @@
 
 static int prism2_hw_init2(struct net_device *dev, int initial)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int i;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 #ifdef PRISM2_DOWNLOAD_SUPPORT
 	kfree(local->pda);
 	if (local->no_pri)
@@ -1436,9 +1469,13 @@
 
 static int prism2_hw_enable(struct net_device *dev, int initial)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
-	int was_resetting = local->hw_resetting;
+	struct hostap_interface *iface;
+	local_info_t *local;
+	int was_resetting;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
+	was_resetting = local->hw_resetting;
 
 	if (hfa384x_cmd(dev, HFA384X_CMDCODE_ENABLE, 0, NULL, NULL)) {
 		printk("%s: MAC port 0 enabling failed\n", dev->name);
@@ -1471,8 +1508,12 @@
 
 static int prism2_hw_config(struct net_device *dev, int initial)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->hw_downloading)
 		return 1;
 
@@ -1499,8 +1540,11 @@
 
 static void prism2_hw_shutdown(struct net_device *dev, int no_disable)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	/* Allow only command completion events during disable */
 	hfa384x_events_only_cmd(dev);
@@ -1531,8 +1575,8 @@
 
 static void prism2_hw_reset(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 
 #if 0
 	static long last_reset = 0;
@@ -1544,6 +1588,9 @@
 	last_reset = jiffies;
 #endif
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (in_interrupt()) {
 		printk(KERN_DEBUG "%s: driver bug - prism2_hw_reset() called "
 		       "in interrupt context\n", dev->name);
@@ -1666,10 +1713,13 @@
 static void prism2_transmit_cb(struct net_device *dev, void *context,
 			       u16 resp0, u16 res)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int idx = (int) context;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (res) {
 		printk(KERN_DEBUG "%s: prism2_transmit_cb - res=0x%02x\n",
 		       dev->name, res);
@@ -1730,10 +1780,13 @@
  * this can be called both from software and hardware IRQ) */
 static int prism2_transmit(struct net_device *dev, int idx)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int res;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	/* The driver tries to stop netif queue so that there would not be
 	 * more than one attempt to transmit frames going on; check that this
 	 * is really the case */
@@ -1778,11 +1831,14 @@
 static void prism2_tx_cb(struct net_device *dev, void *context,
 			 u16 resp0, u16 res)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long addr;
 	int buf_len = (int) context;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (res) {
 		printk(KERN_DEBUG "%s: prism2_tx_cb - res=0x%02x\n",
 		       dev->name, res);
@@ -1803,14 +1859,17 @@
 /* Called only from software IRQ */
 static int prism2_tx_80211(struct sk_buff *skb, struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hfa384x_tx_frame txdesc;
 	struct hostap_ieee80211_hdr *hdr;
 	struct hostap_skb_tx_data *meta;
 	int hdr_len, data_len, idx, res, ret = -1;
 	u16 tx_control, fc;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	meta = (struct hostap_skb_tx_data *) skb->cb;
 	hdr = (struct hostap_ieee80211_hdr *) skb->data;
 
@@ -2179,11 +2238,14 @@
 /* Called only from hardware IRQ */
 static void prism2_alloc_ev(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int idx;
 	u16 fid;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	fid = prism2_read_fid_reg(dev, HFA384X_ALLOCFID_OFF);
 
 	PDEBUG(DEBUG_FID, "FID: interrupt: ALLOC - fid=0x%04x\n", fid);
@@ -2595,8 +2657,12 @@
 /* Called only from hardware IRQ */
 static void prism2_bus_master_ev(struct net_device *dev, int bap)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (bap == BAP1) {
 		/* FIX: frame payload was DMA'd to skb->data; might need to
 		 * invalidate data cache for that memory area */
@@ -2640,11 +2706,14 @@
 /* Called only from hardware IRQ */
 static void prism2_ev_tick(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 evstat, inten;
 	static int prev_stuck = 0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (time_after(jiffies, local->last_tick_timer + 5 * HZ) &&
 	    local->last_tick_timer) {
 		evstat = HFA384X_INW(HFA384X_EVSTAT_OFF);
@@ -2710,11 +2779,14 @@
 static irqreturn_t prism2_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int events = 0;
 	u16 ev;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INTERRUPT, 0, 0);
 
 	if (local->func->card_present && !local->func->card_present(local)) {
@@ -3104,8 +3176,11 @@
 {
 	struct list_head *ptr;
 	struct set_tim_data *new_entry;
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	new_entry = (struct set_tim_data *)
 		kmalloc(sizeof(*new_entry), GFP_ATOMIC);
@@ -3216,7 +3291,7 @@
 	if (dev == NULL)
 		return NULL;
 
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 	local = (struct local_info *) ((((long) (iface + 1)) + 3) & ~3);
 	local->ap = (struct ap_data *) ((((long) (local + 1)) + 3) & ~3);
 	local->dev = iface->dev = dev;
@@ -3392,9 +3467,11 @@
 
 static int hostap_hw_ready(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	struct local_info *local = iface->local;
+	struct hostap_interface *iface;
+	struct local_info *local;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
 	local->ddev = hostap_add_interface(local, HOSTAP_INTERFACE_MAIN, 0,
 					   "", dev_template);
 
@@ -3424,7 +3501,7 @@
 	if (dev == NULL)
 		return;
 
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 	local = iface->local;
 
 	flush_scheduled_work();
diff -Nru a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
--- a/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-13 20:56:44 -08:00
@@ -9,10 +9,13 @@
 
 static struct iw_statistics *hostap_get_wireless_stats(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct iw_statistics *wstats;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	/* Why are we doing that ? Jean II */
 	if (iface->type != HOSTAP_INTERFACE_MAIN)
 		return NULL;
@@ -65,12 +68,15 @@
 
 static int prism2_get_datarates(struct net_device *dev, u8 *rates)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u8 buf[12];
 	int len;
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	len = local->func->get_rid(dev, HFA384X_RID_SUPPORTEDDATARATES, buf,
 				   sizeof(buf), 0);
 	if (len < 2)
@@ -138,11 +144,14 @@
 				  struct iw_request_info *info,
 				  struct iw_point *erq, char *keybuf)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int i;
 	struct prism2_crypt_data **crypt;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	i = erq->flags & IW_ENCODE_INDEX;
 	if (i < 1 || i > 4)
 		i = local->tx_keyidx;
@@ -238,12 +247,15 @@
 				  struct iw_request_info *info,
 				  struct iw_point *erq, char *key)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int i, len;
 	u16 val;
 	struct prism2_crypt_data *crypt;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	i = erq->flags & IW_ENCODE_INDEX;
 	if (i < 1 || i > 4)
 		i = local->tx_keyidx;
@@ -295,10 +307,13 @@
 
 static int hostap_set_rate(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int ret, basic_rates;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	basic_rates = local->basic_rates & local->tx_rate_control;
 	if (!basic_rates || basic_rates != local->basic_rates) {
 		printk(KERN_INFO "%s: updating basic rate set automatically "
@@ -338,8 +353,11 @@
 				struct iw_request_info *info,
 				struct iw_param *rrq, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	if (rrq->fixed) {
 		switch (rrq->value) {
@@ -396,10 +414,13 @@
 				struct iw_param *rrq, char *extra)
 {
 	u16 val;
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int ret = 0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->func->get_rid(dev, HFA384X_RID_TXRATECONTROL, &val, 2, 1) <
 	    0)
 		return -EINVAL;
@@ -451,8 +472,11 @@
 				struct iw_request_info *info,
 				struct iw_param *sens, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	/* Set the desired AP density */
 	if (sens->value < 1 || sens->value > 3)
@@ -469,10 +493,13 @@
 				struct iw_request_info *info,
 				struct iw_param *sens, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	/* Get the current AP density */
 	if (local->func->get_rid(dev, HFA384X_RID_CNFSYSTEMSCALE, &val, 2, 1) <
 	    0)
@@ -490,11 +517,14 @@
 				  struct iw_request_info *info,
 				  struct iw_point *data, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct sockaddr addr[IW_MAX_AP];
 	struct iw_quality qual[IW_MAX_AP];
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->iw_mode != IW_MODE_MASTER) {
 		printk(KERN_DEBUG "SIOCGIWAPLIST is currently only supported "
 		       "in Host AP mode\n");
@@ -517,10 +547,13 @@
 			       struct iw_request_info *info,
 			       struct iw_param *rts, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (rts->disabled)
 		val = __constant_cpu_to_le16(2347);
 	else if (rts->value < 0 || rts->value > 2347)
@@ -541,10 +574,13 @@
 			       struct iw_request_info *info,
 			       struct iw_param *rts, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->func->get_rid(dev, HFA384X_RID_RTSTHRESHOLD, &val, 2, 1) <
 	    0)
 		return -EINVAL;
@@ -561,10 +597,13 @@
 				struct iw_request_info *info,
 				struct iw_param *rts, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (rts->disabled)
 		val = __constant_cpu_to_le16(2346);
 	else if (rts->value < 256 || rts->value > 2346)
@@ -585,10 +624,13 @@
 				struct iw_request_info *info,
 				struct iw_param *rts, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->func->get_rid(dev, HFA384X_RID_FRAGMENTATIONTHRESHOLD,
 				 &val, 2, 1) < 0)
 		return -EINVAL;
@@ -604,13 +646,16 @@
 #ifndef PRISM2_NO_STATION_MODES
 static int hostap_join_ap(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hfa384x_join_request req;
 	unsigned long flags;
 	int i;
 	struct hfa384x_scan_result *entry;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	memcpy(req.bssid, local->preferred_ap, ETH_ALEN);
 	req.channel = 0;
 
@@ -649,8 +694,11 @@
 #ifdef PRISM2_NO_STATION_MODES
 	return -EOPNOTSUPP;
 #else /* PRISM2_NO_STATION_MODES */
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	memcpy(local->preferred_ap, &ap_addr->sa_data, ETH_ALEN);
 
@@ -683,8 +731,11 @@
 			      struct iw_request_info *info,
 			      struct sockaddr *ap_addr, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	ap_addr->sa_family = ARPHRD_ETHER;
 	switch (iface->type) {
@@ -716,8 +767,11 @@
 				 struct iw_request_info *info,
 				 struct iw_point *data, char *nickname)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	memset(local->name, 0, sizeof(local->name));
 	memcpy(local->name, nickname, data->length);
@@ -734,12 +788,15 @@
 				 struct iw_request_info *info,
 				 struct iw_point *data, char *nickname)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int len;
 	char name[MAX_NAME_LEN + 3];
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	len = local->func->get_rid(dev, HFA384X_RID_CNFOWNNAME,
 				   &name, MAX_NAME_LEN + 2, 0);
 	val = __le16_to_cpu(*(u16 *) name);
@@ -758,8 +815,11 @@
 				struct iw_request_info *info,
 				struct iw_freq *freq, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	/* freq => chan. */
 	if (freq->e == 1 &&
@@ -792,10 +852,13 @@
 				struct iw_request_info *info,
 				struct iw_freq *freq, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->func->get_rid(dev, HFA384X_RID_CURRENTCHANNEL, &val, 2, 1) <
 	    0)
 		return -EINVAL;
@@ -834,8 +897,11 @@
 				 struct iw_request_info *info,
 				 struct iw_point *data, char *ssid)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	if (iface->type == HOSTAP_INTERFACE_WDS)
 		return -EOPNOTSUPP;
@@ -867,10 +933,13 @@
 				 struct iw_request_info *info,
 				 struct iw_point *data, char *essid)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (iface->type == HOSTAP_INTERFACE_WDS)
 		return -EOPNOTSUPP;
 
@@ -900,13 +969,16 @@
 				 struct iw_request_info *info,
 				 struct iw_point *data, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct iw_range *range = (struct iw_range *) extra;
 	u8 rates[10];
 	u16 val;
 	int i, len, over2;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	data->length = sizeof(struct iw_range);
 	memset(range, 0, sizeof(struct iw_range));
 
@@ -1066,10 +1138,13 @@
 				struct iw_request_info *info,
 				__u32 *mode, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int double_reset = 0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (*mode != IW_MODE_ADHOC && *mode != IW_MODE_INFRA &&
 	    *mode != IW_MODE_MASTER && *mode != IW_MODE_REPEAT &&
 	    *mode != IW_MODE_MONITOR)
@@ -1138,8 +1213,11 @@
 				struct iw_request_info *info,
 				__u32 *mode, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	switch (iface->type) {
 	case HOSTAP_INTERFACE_STA:
@@ -1222,10 +1300,13 @@
 #ifdef PRISM2_NO_STATION_MODES
 	return -EOPNOTSUPP;
 #else /* PRISM2_NO_STATION_MODES */
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 enable, mcast;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->func->get_rid(dev, HFA384X_RID_CNFPMENABLED, &enable, 2, 1)
 	    < 0)
 		return -EINVAL;
@@ -1274,8 +1355,11 @@
 				 struct iw_request_info *info,
 				 struct iw_param *rrq, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	if (rrq->disabled)
 		return -EINVAL;
@@ -1332,10 +1416,13 @@
 				 struct iw_request_info *info,
 				 struct iw_param *rrq, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 shortretry, longretry, lifetime, altretry;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->func->get_rid(dev, HFA384X_RID_SHORTRETRYLIMIT, &shortretry,
 				 2, 1) < 0 ||
 	    local->func->get_rid(dev, HFA384X_RID_LONGRETRYLIMIT, &longretry,
@@ -1427,14 +1514,17 @@
 				 struct iw_request_info *info,
 				 struct iw_param *rrq, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 #ifdef RAW_TXPOWER_SETTING
 	char *tmp;
 #endif
 	u16 val;
 	int ret = 0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (rrq->disabled) {
 		if (local->txpower_type != PRISM2_TXPOWER_OFF) {
 			val = 0xff; /* use all standby and sleep modes */
@@ -1506,10 +1596,13 @@
 				 struct iw_param *rrq, char *extra)
 {
 #ifdef RAW_TXPOWER_SETTING
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 resp0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	rrq->flags = IW_TXPOW_DBM;
 	rrq->disabled = 0;
 	rrq->fixed = 0;
@@ -1548,10 +1641,13 @@
 static int prism2_request_hostscan(struct net_device *dev,
 				   u8 *ssid, u8 ssid_len)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hfa384x_hostscan_request scan_req;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	memset(&scan_req, 0, sizeof(scan_req));
 	scan_req.channel_list = __constant_cpu_to_le16(local->channel_mask);
 	scan_req.txrate = __constant_cpu_to_le16(HFA384X_RATES_1MBPS);
@@ -1573,11 +1669,14 @@
 
 static int prism2_request_scan(struct net_device *dev)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	struct hfa384x_scan_request scan_req;
 	int ret = 0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	memset(&scan_req, 0, sizeof(scan_req));
 	scan_req.channel_list = __constant_cpu_to_le16(local->channel_mask);
 	scan_req.txrate = __constant_cpu_to_le16(HFA384X_RATES_1MBPS);
@@ -1629,10 +1728,13 @@
 				struct iw_request_info *info,
 				struct iw_point *data, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int ret;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->iw_mode == IW_MODE_MASTER) {
 		/* In master mode, we just return the results of our local
 		 * tables, so we don't need to start anything...
@@ -1896,10 +1998,13 @@
 #ifdef PRISM2_NO_STATION_MODES
 	return -EOPNOTSUPP;
 #else /* PRISM2_NO_STATION_MODES */
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int res;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	/* Wait until the scan is finished. We can probably do better
 	 * than that - Jean II */
 	if (local->scan_timestamp &&
@@ -1933,10 +2038,13 @@
 				struct iw_request_info *info,
 				struct iw_point *data, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int res;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->iw_mode == IW_MODE_MASTER) {
 		/* In MASTER mode, it doesn't make sense to go around
 		 * scanning the frequencies and make the stations we serve
@@ -2163,8 +2271,11 @@
 
 static int prism2_ioctl_priv_inquire(struct net_device *dev, int *i)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	if (local->func->cmd(dev, HFA384X_CMDCODE_INQUIRE, *i, NULL, NULL))
 		return -EOPNOTSUPP;
@@ -2177,14 +2288,17 @@
 					  struct iw_request_info *info,
 					  void *wrqu, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int *i = (int *) extra;
 	int param = *i;
 	int value = *(i + 1);
 	int ret = 0;
 	u16 val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	switch (param) {
 	case PRISM2_PARAM_TXRATECTRL:
 		local->fw_tx_rate_control = value;
@@ -2528,11 +2642,14 @@
 					      struct iw_request_info *info,
 					      void *wrqu, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int *param = (int *) extra;
 	int ret = 0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	switch (*param) {
 	case PRISM2_PARAM_TXRATECTRL:
 		*param = local->fw_tx_rate_control;
@@ -2716,10 +2833,13 @@
 				     struct iw_request_info *info,
 				     void *wrqu, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 resp0;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	if (local->func->cmd(dev, HFA384X_CMDCODE_READMIF, *extra, NULL,
 			     &resp0))
 		return -EOPNOTSUPP;
@@ -2734,10 +2854,13 @@
 				      struct iw_request_info *info,
 				      void *wrqu, char *extra)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	u16 cr, val;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	cr = *extra;
 	val = *(extra + 1);
 	if (local->func->cmd(dev, HFA384X_CMDCODE_WRITEMIF, cr, &val, NULL))
@@ -2749,11 +2872,14 @@
 
 static int prism2_ioctl_priv_monitor(struct net_device *dev, int *i)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int ret = 0;
 	u32 mode;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	printk(KERN_DEBUG "%s: process %d (%s) used deprecated iwpriv monitor "
 	       "- update software to use iwconfig mode monitor\n",
 	       dev->name, current->pid, current->comm);
@@ -2792,8 +2918,11 @@
 
 static int prism2_ioctl_priv_reset(struct net_device *dev, int *i)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	printk(KERN_DEBUG "%s: manual reset request(%d)\n", dev->name, *i);
 	switch (*i) {
@@ -3401,9 +3530,12 @@
 int hostap_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct iwreq *wrq = (struct iwreq *) ifr;
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	int ret = 0;
+
+	iface = netdev_priv(dev);
+	local = iface->local;
 
 	switch (cmd) {
 		/* Private ioctls (iwpriv) that have not yet been converted
diff -Nru a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
--- a/drivers/net/wireless/hostap/hostap_pci.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_pci.c	2004-11-13 20:56:44 -08:00
@@ -50,10 +50,13 @@
 
 static inline void hfa384x_outb_debug(struct net_device *dev, int a, u8 v)
 {
-	struct hostap_interface *iface = netdev_priv(dev);
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTB, a, v);
 	writeb(v, local->mem_start + a);
@@ -62,11 +65,14 @@
 
 static inline u8 hfa384x_inb_debug(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = netdev_priv(dev);
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 	u8 v;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	v = readb(local->mem_start + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INB, a, v);
@@ -76,10 +82,13 @@
 
 static inline void hfa384x_outw_debug(struct net_device *dev, int a, u16 v)
 {
-	struct hostap_interface *iface = netdev_priv(dev);
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTW, a, v);
 	writew(v, local->mem_start + a);
@@ -88,11 +97,14 @@
 
 static inline u16 hfa384x_inw_debug(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = netdev_priv(dev);
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 	u16 v;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	v = readw(local->mem_start + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INW, a, v);
@@ -111,29 +123,37 @@
 
 static inline void hfa384x_outb(struct net_device *dev, int a, u8 v)
 {
-	struct hostap_interface *iface = netdev_priv(dev);
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+	iface = netdev_priv(dev);
+	local = iface->local;
 	writeb(v, local->mem_start + a);
 }
 
 static inline u8 hfa384x_inb(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = netdev_priv(dev);
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+	iface = netdev_priv(dev);
+	local = iface->local;
 	return readb(local->mem_start + a);
 }
 
 static inline void hfa384x_outw(struct net_device *dev, int a, u16 v)
 {
-	struct hostap_interface *iface = netdev_priv(dev);
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+	iface = netdev_priv(dev);
+	local = iface->local;
 	writew(v, local->mem_start + a);
 }
 
 static inline u16 hfa384x_inw(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = netdev_priv(dev);
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
+	iface = netdev_priv(dev);
+	local = iface->local;
 	return readw(local->mem_start + a);
 }
 
@@ -290,7 +310,7 @@
 	dev = prism2_init_local_data(&prism2_pci_funcs, cards_found);
 	if (dev == NULL)
 		goto fail;
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 	local = iface->local;
 	cards_found++;
 
@@ -338,9 +358,12 @@
 
 static void prism2_pci_remove(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct hostap_interface *iface = netdev_priv(dev);
+	struct net_device *dev;
+	struct hostap_interface *iface;
 	void __iomem *mem_start;
+
+	dev = pci_get_drvdata(pdev);
+	iface = netdev_priv(dev);
 
 	/* Reset the hardware, and ensure interrupts are disabled. */
 	prism2_pci_cor_sreset(iface->local);
diff -Nru a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
--- a/drivers/net/wireless/hostap/hostap_plx.c	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_plx.c	2004-11-13 20:56:44 -08:00
@@ -100,10 +100,13 @@
 
 static inline void hfa384x_outb_debug(struct net_device *dev, int a, u8 v)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTB, a, v);
 	outb(v, dev->base_addr + a);
@@ -112,11 +115,14 @@
 
 static inline u8 hfa384x_inb_debug(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 	u8 v;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	v = inb(dev->base_addr + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INB, a, v);
@@ -126,10 +132,13 @@
 
 static inline void hfa384x_outw_debug(struct net_device *dev, int a, u16 v)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTW, a, v);
 	outw(v, dev->base_addr + a);
@@ -138,11 +147,14 @@
 
 static inline u16 hfa384x_inw_debug(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 	u16 v;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	v = inw(dev->base_addr + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INW, a, v);
@@ -153,10 +165,13 @@
 static inline void hfa384x_outsw_debug(struct net_device *dev, int a,
 				       u8 *buf, int wc)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTSW, a, wc);
 	outsw(dev->base_addr + a, buf, wc);
@@ -166,10 +181,13 @@
 static inline void hfa384x_insw_debug(struct net_device *dev, int a,
 				      u8 *buf, int wc)
 {
-	struct hostap_interface *iface = dev->priv;
-	local_info_t *local = iface->local;
+	struct hostap_interface *iface;
+	local_info_t *local;
 	unsigned long flags;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INSW, a, wc);
 	insw(dev->base_addr + a, buf, wc);
@@ -498,7 +516,7 @@
 	dev = prism2_init_local_data(&prism2_plx_funcs, cards_found);
 	if (dev == NULL)
 		goto fail;
-	iface = dev->priv;
+	iface = netdev_priv(dev);
 	local = iface->local;
 	cards_found++;
 
@@ -541,8 +559,11 @@
 
 static void prism2_plx_remove(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct hostap_interface *iface = dev->priv;
+	struct net_device *dev;
+	struct hostap_interface *iface;
+
+	dev = pci_get_drvdata(pdev);
+	iface = netdev_priv(dev);
 
 	/* Reset the hardware, and ensure interrupts are disabled. */
 	prism2_plx_cor_sreset(iface->local);
diff -Nru a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
--- a/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-13 20:56:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-13 20:56:44 -08:00
@@ -635,7 +635,8 @@
 
 /* Per radio private Host AP data - shared by all net devices interfaces used
  * by each radio (wlan#, wlan#ap, wlan#sta, WDS).
- * ((struct hostap_interface *) dev->priv)->local points to this structure. */
+ * ((struct hostap_interface *) netdev_priv(dev))->local points to this
+ * structure. */
 struct local_info {
 	struct module *hw_module;
 	int card_idx;
@@ -918,7 +919,7 @@
 
 /* Per interface private Host AP data
  * Allocated for each net device that Host AP uses (wlan#, wlan#ap, wlan#sta,
- * WDS) and dev->priv points to this structure. */
+ * WDS) and netdev_priv(dev) points to this structure. */
 struct hostap_interface {
 	struct list_head list; /* list entry in Host AP interface list */
 	struct net_device *dev; /* pointer to this device */



-- 
Jouni Malinen                                            PGP id EFC895FA
