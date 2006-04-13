From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 11/18] ipw2200: Enable rtap interface for RF promiscuous mode while associated
Date: Thu, 13 Apr 2006 17:20:27 +0800
Message-ID: <20060413092027.GA28780@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:32205 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964848AbWDMJ1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:27:43 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this patch, a new promiscuous mode is enabled. If the module is loaded
with the rtap_iface=1 module parameter, two interfaces will be created
(instead of just one).

The second interface is prefixed 'rtap' and provides received 802.11 frames
on the current channel to user space in a radiotap header format.

Example usage:

        % modprobe ipw2200 rtap_iface=1
        % iwconfig eth1 essid MyNetwork
        % dhcpcd eth1
        % tcpdump -i rtap0

If you do not specify 'rtap_iface=1' then the rtap interface will
not be created and you will need to turn it on via:

        % echo 1 > /sys/bus/pci/drivers/ipw2200/*/rtap_iface

You can filter out what type of information is passed to user space via
the rtap_filter sysfs entry.  Currently you can tell the driver to
transmit just the headers (which will provide the RADIOTAP and IEEE
802.11 header but not the payload), to filter based on frame control
type (Management, Control, or Data), and whether to report transmitted
frames, received frames, or both.

The transmit frame reporting is based on a patch by Stefan Rompf.

Filters can be get and set via a sysfs interface. For example, set the
filter to only send headers (0x7), don't report Tx'd frames (0x10), and
don't report data frames (0x100):

        % echo 0x117 > /sys/bus/pci/drivers/ipw2200/*/rtap_filter

All your packets are belong to us:

        % tethereal -n -i rtap0

Signed-off-by: James Ketrenos <jketreno@linux.intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/Kconfig   |   24 ++
 drivers/net/wireless/ipw2200.c |  599 ++++++++++++++++++++++++++++++++++++++--
 drivers/net/wireless/ipw2200.h |   77 +++++
 3 files changed, 673 insertions(+), 27 deletions(-)

02631c88b57c16ae4989d17ae4ca5babb4b3501a
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index e5ea89e..5cd9c16 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -263,6 +263,30 @@ config IPW2200_DEBUG
 	  If you are not trying to debug or develop the IPW2200 driver, you 
 	  most likely want to say N here.
 
+config IPW2200_PROMISCUOUS
+	bool "Enable creation of a RF radiotap promiscuous interface."
+	depends on IPW2200
+	select IEEE80211_RADIOTAP
+	---help---
+          Enables the creation of a second interface prefixed 'rtap'. 
+          This second interface will provide every received in radiotap
+	  format.
+
+          This is useful for performing wireless network analysis while
+          maintaining an active association.
+
+          Example usage:
+
+            % modprobe ipw2200 rtap_iface=1
+            % ifconfig rtap0 up
+            % tethereal -i rtap0
+
+          If you do not specify 'rtap_iface=1' as a module parameter then 
+          the rtap interface will not be created and you will need to turn 
+          it on via sysfs:
+	
+            % echo 1 > /sys/bus/pci/drivers/ipw2200/*/rtap_iface
+
 config AIRO
 	tristate "Cisco/Aironet 34X/35X/4500/4800 ISA and PCI cards"
  	depends on NET_RADIO && ISA_DMA_API && (PCI || BROKEN)
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 7646def..bbf17f6 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -65,6 +65,11 @@ static const char ipw_modes[] = {
 };
 static int antenna = CFG_SYS_ANTENNA_BOTH;
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+static int rtap_iface = 0;     /* def: 0 -- do not create rtap interface */
+#endif
+
+
 #ifdef CONFIG_IPW_QOS
 static int qos_enable = 0;
 static int qos_burst_enable = 0;
@@ -1272,6 +1277,105 @@ static ssize_t show_cmd_log(struct devic
 
 static DEVICE_ATTR(cmd_log, S_IRUGO, show_cmd_log, NULL);
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+static void ipw_prom_free(struct ipw_priv *priv);
+static int ipw_prom_alloc(struct ipw_priv *priv);
+static ssize_t store_rtap_iface(struct device *d,
+			 struct device_attribute *attr,
+			 const char *buf, size_t count)
+{
+	struct ipw_priv *priv = dev_get_drvdata(d);
+	int rc = 0;
+
+	if (count < 1)
+		return -EINVAL;
+
+	switch (buf[0]) {
+	case '0':
+		if (!rtap_iface)
+			return count;
+
+		if (netif_running(priv->prom_net_dev)) {
+			IPW_WARNING("Interface is up.  Cannot unregister.\n");
+			return count;
+		}
+
+		ipw_prom_free(priv);
+		rtap_iface = 0;
+		break;
+
+	case '1':
+		if (rtap_iface)
+			return count;
+
+		rc = ipw_prom_alloc(priv);
+		if (!rc)
+			rtap_iface = 1;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	if (rc) {
+		IPW_ERROR("Failed to register promiscuous network "
+			  "device (error %d).\n", rc);
+	}
+
+	return count;
+}
+
+static ssize_t show_rtap_iface(struct device *d,
+			struct device_attribute *attr,
+			char *buf)
+{
+	struct ipw_priv *priv = dev_get_drvdata(d);
+	if (rtap_iface)
+		return sprintf(buf, "%s", priv->prom_net_dev->name);
+	else {
+		buf[0] = '-';
+		buf[1] = '1';
+		buf[2] = '\0';
+		return 3;
+	}
+}
+
+static DEVICE_ATTR(rtap_iface, S_IWUSR | S_IRUSR, show_rtap_iface,
+		   store_rtap_iface);
+
+static ssize_t store_rtap_filter(struct device *d,
+			 struct device_attribute *attr,
+			 const char *buf, size_t count)
+{
+	struct ipw_priv *priv = dev_get_drvdata(d);
+
+	if (!priv->prom_priv) {
+		IPW_ERROR("Attempting to set filter without "
+			  "rtap_iface enabled.\n");
+		return -EPERM;
+	}
+
+	priv->prom_priv->filter = simple_strtol(buf, NULL, 0);
+
+	IPW_DEBUG_INFO("Setting rtap filter to " BIT_FMT16 "\n",
+		       BIT_ARG16(priv->prom_priv->filter));
+
+	return count;
+}
+
+static ssize_t show_rtap_filter(struct device *d,
+			struct device_attribute *attr,
+			char *buf)
+{
+	struct ipw_priv *priv = dev_get_drvdata(d);
+	return sprintf(buf, "0x%04X",
+		       priv->prom_priv ? priv->prom_priv->filter : 0);
+}
+
+static DEVICE_ATTR(rtap_filter, S_IWUSR | S_IRUSR, show_rtap_filter,
+		   store_rtap_filter);
+#endif
+
 static ssize_t show_scan_age(struct device *d, struct device_attribute *attr,
 			     char *buf)
 {
@@ -2028,16 +2132,11 @@ static int ipw_send_host_complete(struct
 	return ipw_send_cmd_simple(priv, IPW_CMD_HOST_COMPLETE);
 }
 
-static int ipw_send_system_config(struct ipw_priv *priv,
-				  struct ipw_sys_config *config)
+static int ipw_send_system_config(struct ipw_priv *priv)
 {
-	if (!priv || !config) {
-		IPW_ERROR("Invalid args\n");
-		return -1;
-	}
-
-	return ipw_send_cmd_pdu(priv, IPW_CMD_SYSTEM_CONFIG, sizeof(*config),
-				config);
+	return ipw_send_cmd_pdu(priv, IPW_CMD_SYSTEM_CONFIG,
+				sizeof(priv->sys_config),
+				&priv->sys_config);
 }
 
 static int ipw_send_ssid(struct ipw_priv *priv, u8 * ssid, int len)
@@ -3704,7 +3803,17 @@ static void ipw_bg_disassociate(void *da
 static void ipw_system_config(void *data)
 {
 	struct ipw_priv *priv = data;
-	ipw_send_system_config(priv, &priv->sys_config);
+
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+	if (priv->prom_net_dev && netif_running(priv->prom_net_dev)) {
+		priv->sys_config.accept_all_data_frames = 1;
+		priv->sys_config.accept_non_directed_frames = 1;
+		priv->sys_config.accept_all_mgmt_bcpr = 1;
+		priv->sys_config.accept_all_mgmt_frames = 1;
+	}
+#endif
+
+	ipw_send_system_config(priv);
 }
 
 struct ipw_status_code {
@@ -7141,7 +7250,7 @@ static int ipw_associate_network(struct 
 	else
 		priv->sys_config.answer_broadcast_ssid_probe = 0;
 
-	err = ipw_send_system_config(priv, &priv->sys_config);
+	err = ipw_send_system_config(priv);
 	if (err) {
 		IPW_DEBUG_HC("Attempt to send sys config command failed.\n");
 		return err;
@@ -7457,15 +7566,7 @@ static void ipw_handle_data_packet_monit
 	/* Magic struct that slots into the radiotap header -- no reason
 	 * to build this manually element by element, we can write it much
 	 * more efficiently than we can parse it. ORDER MATTERS HERE */
-	struct ipw_rt_hdr {
-		struct ieee80211_radiotap_header rt_hdr;
-		u8 rt_flags;	/* radiotap packet flags */
-		u8 rt_rate;	/* rate in 500kb/s */
-		u16 rt_channel;	/* channel in mhz */
-		u16 rt_chbitmask;	/* channel bitfield */
-		s8 rt_dbmsignal;	/* signal in dbM, kluged to signed */
-		u8 rt_antenna;	/* antenna number */
-	} *ipw_rt;
+	struct ipw_rt_hdr *ipw_rt;
 
 	short len = le16_to_cpu(pkt->u.frame.length);
 
@@ -7519,9 +7620,11 @@ static void ipw_handle_data_packet_monit
 	/* Big bitfield of all the fields we provide in radiotap */
 	ipw_rt->rt_hdr.it_present =
 	    ((1 << IEEE80211_RADIOTAP_FLAGS) |
+	     (1 << IEEE80211_RADIOTAP_TSFT) |
 	     (1 << IEEE80211_RADIOTAP_RATE) |
 	     (1 << IEEE80211_RADIOTAP_CHANNEL) |
 	     (1 << IEEE80211_RADIOTAP_DBM_ANTSIGNAL) |
+	     (1 << IEEE80211_RADIOTAP_DBM_ANTNOISE) |
 	     (1 << IEEE80211_RADIOTAP_ANTENNA));
 
 	/* Zero the flags, we'll add to them as we go */
@@ -7607,6 +7710,220 @@ static void ipw_handle_data_packet_monit
 }
 #endif
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+#define ieee80211_is_probe_response(fc) \
+   ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT && \
+    (fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP )
+
+#define ieee80211_is_management(fc) \
+   ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT)
+
+#define ieee80211_is_control(fc) \
+   ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL)
+
+#define ieee80211_is_data(fc) \
+   ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA)
+
+#define ieee80211_is_assoc_request(fc) \
+   ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_ASSOC_REQ)
+
+#define ieee80211_is_reassoc_request(fc) \
+   ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_REASSOC_REQ)
+
+static void ipw_handle_promiscuous_rx(struct ipw_priv *priv,
+				      struct ipw_rx_mem_buffer *rxb,
+				      struct ieee80211_rx_stats *stats)
+{
+	struct ipw_rx_packet *pkt = (struct ipw_rx_packet *)rxb->skb->data;
+	struct ipw_rx_frame *frame = &pkt->u.frame;
+	struct ipw_rt_hdr *ipw_rt;
+
+	/* First cache any information we need before we overwrite
+	 * the information provided in the skb from the hardware */
+	struct ieee80211_hdr *hdr;
+	u16 channel = frame->received_channel;
+	u8 phy_flags = frame->antennaAndPhy;
+	s8 signal = frame->rssi_dbm - IPW_RSSI_TO_DBM;
+	s8 noise = frame->noise;
+	u8 rate = frame->rate;
+	short len = le16_to_cpu(pkt->u.frame.length);
+	u64 tsf = 0;
+	struct sk_buff *skb;
+	int hdr_only = 0;
+	u16 filter = priv->prom_priv->filter;
+
+	/* If the filter is set to not include Rx frames then return */
+	if (filter & IPW_PROM_NO_RX)
+		return;
+
+	if (!noise)
+		noise = priv->last_noise;
+
+	/* We received data from the HW, so stop the watchdog */
+	priv->prom_net_dev->trans_start = jiffies;
+
+	if (unlikely((len + IPW_RX_FRAME_SIZE) > skb_tailroom(rxb->skb))) {
+		priv->prom_priv->ieee->stats.rx_errors++;
+		IPW_DEBUG_DROP("Corruption detected! Oh no!\n");
+		return;
+	}
+
+	/* We only process data packets if the interface is open */
+	if (unlikely(!netif_running(priv->prom_net_dev))) {
+		priv->prom_priv->ieee->stats.rx_dropped++;
+		IPW_DEBUG_DROP("Dropping packet while interface is not up.\n");
+		return;
+	}
+
+	/* Libpcap 0.9.3+ can handle variable length radiotap, so we'll use
+	 * that now */
+	if (len > IPW_RX_BUF_SIZE - sizeof(struct ipw_rt_hdr)) {
+		/* FIXME: Should alloc bigger skb instead */
+		priv->prom_priv->ieee->stats.rx_dropped++;
+		IPW_DEBUG_DROP("Dropping too large packet in monitor\n");
+		return;
+	}
+
+	hdr = (void *)rxb->skb->data + IPW_RX_FRAME_SIZE;
+	if (ieee80211_is_management(hdr->frame_ctl)) {
+		if (filter & IPW_PROM_NO_MGMT)
+			return;
+		if (filter & IPW_PROM_MGMT_HEADER_ONLY)
+			hdr_only = 1;
+	} else if (ieee80211_is_control(hdr->frame_ctl)) {
+		if (filter & IPW_PROM_NO_CTL)
+			return;
+		if (filter & IPW_PROM_CTL_HEADER_ONLY)
+			hdr_only = 1;
+	} else if (ieee80211_is_data(hdr->frame_ctl)) {
+		if (filter & IPW_PROM_NO_DATA)
+			return;
+		if (filter & IPW_PROM_DATA_HEADER_ONLY)
+			hdr_only = 1;
+	}
+
+	/* Copy the SKB since this is for the promiscuous side */
+	skb = skb_copy(rxb->skb, GFP_ATOMIC);
+	if (skb == NULL) {
+		IPW_ERROR("skb_clone failed for promiscuous copy.\n");
+		return;
+	}
+
+	/* copy the frame data to write after where the radiotap header goes */
+	ipw_rt = (void *)skb->data;
+
+	if (hdr_only)
+		len = ieee80211_get_hdrlen(hdr->frame_ctl);
+
+	memcpy(ipw_rt->payload, hdr, len);
+
+	/* Zero the radiotap static buffer  ...  We only need to zero the bytes
+	 * NOT part of our real header, saves a little time.
+	 *
+	 * No longer necessary since we fill in all our data.  Purge before
+	 * merging patch officially.
+	 * memset(rxb->skb->data + sizeof(struct ipw_rt_hdr), 0,
+	 *        IEEE80211_RADIOTAP_HDRLEN - sizeof(struct ipw_rt_hdr));
+	 */
+
+	ipw_rt->rt_hdr.it_version = PKTHDR_RADIOTAP_VERSION;
+	ipw_rt->rt_hdr.it_pad = 0;	/* always good to zero */
+	ipw_rt->rt_hdr.it_len = sizeof(*ipw_rt);	/* total header+data */
+
+	/* Set the size of the skb to the size of the frame */
+	skb_put(skb, ipw_rt->rt_hdr.it_len + len);
+
+	/* Big bitfield of all the fields we provide in radiotap */
+	ipw_rt->rt_hdr.it_present =
+	    ((1 << IEEE80211_RADIOTAP_FLAGS) |
+	     (1 << IEEE80211_RADIOTAP_TSFT) |
+	     (1 << IEEE80211_RADIOTAP_RATE) |
+	     (1 << IEEE80211_RADIOTAP_CHANNEL) |
+	     (1 << IEEE80211_RADIOTAP_DBM_ANTSIGNAL) |
+	     (1 << IEEE80211_RADIOTAP_DBM_ANTNOISE) |
+	     (1 << IEEE80211_RADIOTAP_ANTENNA));
+
+	/* Zero the flags, we'll add to them as we go */
+	ipw_rt->rt_flags = 0;
+
+	ipw_rt->rt_tsf = tsf;
+
+	/* Convert to DBM */
+	ipw_rt->rt_dbmsignal = signal;
+	ipw_rt->rt_dbmnoise = noise;
+
+	/* Convert the channel data and set the flags */
+	ipw_rt->rt_channel = cpu_to_le16(ieee80211chan2mhz(channel));
+	if (channel > 14) {	/* 802.11a */
+		ipw_rt->rt_chbitmask =
+		    cpu_to_le16((IEEE80211_CHAN_OFDM | IEEE80211_CHAN_5GHZ));
+	} else if (phy_flags & (1 << 5)) {	/* 802.11b */
+		ipw_rt->rt_chbitmask =
+		    cpu_to_le16((IEEE80211_CHAN_CCK | IEEE80211_CHAN_2GHZ));
+	} else {		/* 802.11g */
+		ipw_rt->rt_chbitmask =
+		    (IEEE80211_CHAN_OFDM | IEEE80211_CHAN_2GHZ);
+	}
+
+	/* set the rate in multiples of 500k/s */
+	switch (rate) {
+	case IPW_TX_RATE_1MB:
+		ipw_rt->rt_rate = 2;
+		break;
+	case IPW_TX_RATE_2MB:
+		ipw_rt->rt_rate = 4;
+		break;
+	case IPW_TX_RATE_5MB:
+		ipw_rt->rt_rate = 10;
+		break;
+	case IPW_TX_RATE_6MB:
+		ipw_rt->rt_rate = 12;
+		break;
+	case IPW_TX_RATE_9MB:
+		ipw_rt->rt_rate = 18;
+		break;
+	case IPW_TX_RATE_11MB:
+		ipw_rt->rt_rate = 22;
+		break;
+	case IPW_TX_RATE_12MB:
+		ipw_rt->rt_rate = 24;
+		break;
+	case IPW_TX_RATE_18MB:
+		ipw_rt->rt_rate = 36;
+		break;
+	case IPW_TX_RATE_24MB:
+		ipw_rt->rt_rate = 48;
+		break;
+	case IPW_TX_RATE_36MB:
+		ipw_rt->rt_rate = 72;
+		break;
+	case IPW_TX_RATE_48MB:
+		ipw_rt->rt_rate = 96;
+		break;
+	case IPW_TX_RATE_54MB:
+		ipw_rt->rt_rate = 108;
+		break;
+	default:
+		ipw_rt->rt_rate = 0;
+		break;
+	}
+
+	/* antenna number */
+	ipw_rt->rt_antenna = (phy_flags & 3);
+
+	/* set the preamble flag if we have it */
+	if (phy_flags & (1 << 6))
+		ipw_rt->rt_flags |= IEEE80211_RADIOTAP_F_SHORTPRE;
+
+	IPW_DEBUG_RX("Rx packet of %d bytes.\n", skb->len);
+
+	if (!ieee80211_rx(priv->prom_priv->ieee, skb, stats)) {
+		priv->prom_priv->ieee->stats.rx_errors++;
+		dev_kfree_skb_any(skb);
+	}
+}
+#endif
+
 static int is_network_packet(struct ipw_priv *priv,
 				    struct ieee80211_hdr_4addr *header)
 {
@@ -7833,15 +8150,21 @@ static void ipw_rx(struct ipw_priv *priv
 
 				priv->rx_packets++;
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+	if (priv->prom_net_dev && netif_running(priv->prom_net_dev))
+		ipw_handle_promiscuous_rx(priv, rxb, &stats);
+#endif
+
 #ifdef CONFIG_IPW2200_MONITOR
 				if (priv->ieee->iw_mode == IW_MODE_MONITOR) {
 #ifdef CONFIG_IEEE80211_RADIOTAP
-					ipw_handle_data_packet_monitor(priv,
-								       rxb,
-								       &stats);
+
+                ipw_handle_data_packet_monitor(priv,
+					       rxb,
+					       &stats);
 #else
-					ipw_handle_data_packet(priv, rxb,
-							       &stats);
+		ipw_handle_data_packet(priv, rxb,
+				       &stats);
 #endif
 					break;
 				}
@@ -9883,6 +10206,88 @@ static int ipw_net_is_queue_full(struct 
 	return 0;
 }
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+static void ipw_handle_promiscuous_tx(struct ipw_priv *priv,
+				      struct ieee80211_txb *txb)
+{
+	struct ieee80211_rx_stats dummystats;
+	struct ieee80211_hdr *hdr;
+	u8 n;
+	u16 filter = priv->prom_priv->filter;
+	int hdr_only = 0;
+
+	if (filter & IPW_PROM_NO_TX)
+		return;
+
+	memset(&dummystats, 0, sizeof(dummystats));
+
+	/* Filtering of fragment chains is done agains the first fragment */
+	hdr = (void *)txb->fragments[0]->data;
+	if (ieee80211_is_management(hdr->frame_ctl)) {
+		if (filter & IPW_PROM_NO_MGMT)
+			return;
+		if (filter & IPW_PROM_MGMT_HEADER_ONLY)
+			hdr_only = 1;
+	} else if (ieee80211_is_control(hdr->frame_ctl)) {
+		if (filter & IPW_PROM_NO_CTL)
+			return;
+		if (filter & IPW_PROM_CTL_HEADER_ONLY)
+			hdr_only = 1;
+	} else if (ieee80211_is_data(hdr->frame_ctl)) {
+		if (filter & IPW_PROM_NO_DATA)
+			return;
+		if (filter & IPW_PROM_DATA_HEADER_ONLY)
+			hdr_only = 1;
+	}
+
+	for(n=0; n<txb->nr_frags; ++n) {
+		struct sk_buff *src = txb->fragments[n];
+		struct sk_buff *dst;
+		struct ieee80211_radiotap_header *rt_hdr;
+		int len;
+
+		if (hdr_only) {
+			hdr = (void *)src->data;
+			len = ieee80211_get_hdrlen(hdr->frame_ctl);
+		} else
+			len = src->len;
+
+		dst = alloc_skb(
+			len + IEEE80211_RADIOTAP_HDRLEN, GFP_ATOMIC);
+		if (!dst) continue;
+
+		rt_hdr = (void *)skb_put(dst, sizeof(*rt_hdr));
+
+		rt_hdr->it_version = PKTHDR_RADIOTAP_VERSION;
+		rt_hdr->it_pad = 0;
+		rt_hdr->it_present = 0; /* after all, it's just an idea */
+		rt_hdr->it_present |=  (1 << IEEE80211_RADIOTAP_CHANNEL);
+
+		*(u16*)skb_put(dst, sizeof(u16)) = cpu_to_le16(
+			ieee80211chan2mhz(priv->channel));
+		if (priv->channel > 14) 	/* 802.11a */
+			*(u16*)skb_put(dst, sizeof(u16)) =
+				cpu_to_le16(IEEE80211_CHAN_OFDM |
+					     IEEE80211_CHAN_5GHZ);
+		else if (priv->ieee->mode == IEEE_B) /* 802.11b */
+			*(u16*)skb_put(dst, sizeof(u16)) =
+				cpu_to_le16(IEEE80211_CHAN_CCK |
+					     IEEE80211_CHAN_2GHZ);
+		else 		/* 802.11g */
+			*(u16*)skb_put(dst, sizeof(u16)) =
+				cpu_to_le16(IEEE80211_CHAN_OFDM |
+				 IEEE80211_CHAN_2GHZ);
+
+		rt_hdr->it_len = dst->len;
+
+		memcpy(skb_put(dst, len), src->data, len);
+
+		if (!ieee80211_rx(priv->prom_priv->ieee, dst, &dummystats))
+			dev_kfree_skb_any(dst);
+	}
+}
+#endif
+
 static int ipw_net_hard_start_xmit(struct ieee80211_txb *txb,
 				   struct net_device *dev, int pri)
 {
@@ -9900,6 +10305,11 @@ static int ipw_net_hard_start_xmit(struc
 		goto fail_unlock;
 	}
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+	if (rtap_iface && netif_running(priv->prom_net_dev))
+		ipw_handle_promiscuous_tx(priv, txb);
+#endif
+
 	ret = ipw_tx_skb(priv, txb, pri);
 	if (ret == NETDEV_TX_OK)
 		__ipw_led_activity_on(priv);
@@ -10347,12 +10757,21 @@ static int ipw_config(struct ipw_priv *p
 			    |= CFG_BT_COEXISTENCE_OOB;
 	}
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+	if (priv->prom_net_dev && netif_running(priv->prom_net_dev)) {
+		priv->sys_config.accept_all_data_frames = 1;
+		priv->sys_config.accept_non_directed_frames = 1;
+		priv->sys_config.accept_all_mgmt_bcpr = 1;
+		priv->sys_config.accept_all_mgmt_frames = 1;
+	}
+#endif
+
 	if (priv->ieee->iw_mode == IW_MODE_ADHOC)
 		priv->sys_config.answer_broadcast_ssid_probe = 1;
 	else
 		priv->sys_config.answer_broadcast_ssid_probe = 0;
 
-	if (ipw_send_system_config(priv, &priv->sys_config))
+	if (ipw_send_system_config(priv))
 		goto error;
 
 	init_supported_rates(priv, &priv->rates);
@@ -10890,6 +11309,10 @@ static struct attribute *ipw_sysfs_entri
 	&dev_attr_led.attr,
 	&dev_attr_speed_scan.attr,
 	&dev_attr_net_stats.attr,
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+	&dev_attr_rtap_iface.attr,
+	&dev_attr_rtap_filter.attr,
+#endif
 	NULL
 };
 
@@ -10898,6 +11321,109 @@ static struct attribute_group ipw_attrib
 	.attrs = ipw_sysfs_entries,
 };
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+static int ipw_prom_open(struct net_device *dev)
+{
+	struct ipw_prom_priv *prom_priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = prom_priv->priv;
+
+	IPW_DEBUG_INFO("prom dev->open\n");
+	netif_carrier_off(dev);
+	netif_stop_queue(dev);
+
+	if (priv->ieee->iw_mode != IW_MODE_MONITOR) {
+		priv->sys_config.accept_all_data_frames = 1;
+		priv->sys_config.accept_non_directed_frames = 1;
+		priv->sys_config.accept_all_mgmt_bcpr = 1;
+		priv->sys_config.accept_all_mgmt_frames = 1;
+
+		ipw_send_system_config(priv);
+	}
+
+	return 0;
+}
+
+static int ipw_prom_stop(struct net_device *dev)
+{
+	struct ipw_prom_priv *prom_priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = prom_priv->priv;
+
+	IPW_DEBUG_INFO("prom dev->stop\n");
+
+	if (priv->ieee->iw_mode != IW_MODE_MONITOR) {
+		priv->sys_config.accept_all_data_frames = 0;
+		priv->sys_config.accept_non_directed_frames = 0;
+		priv->sys_config.accept_all_mgmt_bcpr = 0;
+		priv->sys_config.accept_all_mgmt_frames = 0;
+
+		ipw_send_system_config(priv);
+	}
+
+	return 0;
+}
+
+static int ipw_prom_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	IPW_DEBUG_INFO("prom dev->xmit\n");
+	netif_stop_queue(dev);
+	return -EOPNOTSUPP;
+}
+
+static struct net_device_stats *ipw_prom_get_stats(struct net_device *dev)
+{
+	struct ipw_prom_priv *prom_priv = ieee80211_priv(dev);
+	return &prom_priv->ieee->stats;
+}
+
+static int ipw_prom_alloc(struct ipw_priv *priv)
+{
+	int rc = 0;
+
+	if (priv->prom_net_dev)
+		return -EPERM;
+
+	priv->prom_net_dev = alloc_ieee80211(sizeof(struct ipw_prom_priv));
+	if (priv->prom_net_dev == NULL)
+		return -ENOMEM;
+
+	priv->prom_priv = ieee80211_priv(priv->prom_net_dev);
+	priv->prom_priv->ieee = netdev_priv(priv->prom_net_dev);
+	priv->prom_priv->priv = priv;
+
+	strcpy(priv->prom_net_dev->name, "rtap%d");
+
+	priv->prom_net_dev->type = ARPHRD_IEEE80211_RADIOTAP;
+	priv->prom_net_dev->open = ipw_prom_open;
+	priv->prom_net_dev->stop = ipw_prom_stop;
+	priv->prom_net_dev->get_stats = ipw_prom_get_stats;
+	priv->prom_net_dev->hard_start_xmit = ipw_prom_hard_start_xmit;
+
+	priv->prom_priv->ieee->iw_mode = IW_MODE_MONITOR;
+
+	rc = register_netdev(priv->prom_net_dev);
+	if (rc) {
+		free_ieee80211(priv->prom_net_dev);
+		priv->prom_net_dev = NULL;
+		return rc;
+	}
+
+	return 0;
+}
+
+static void ipw_prom_free(struct ipw_priv *priv)
+{
+	if (!priv->prom_net_dev)
+		return;
+
+	unregister_netdev(priv->prom_net_dev);
+	free_ieee80211(priv->prom_net_dev);
+
+	priv->prom_net_dev = NULL;
+}
+
+#endif
+
+
 static int ipw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int err = 0;
@@ -11028,6 +11554,18 @@ static int ipw_pci_probe(struct pci_dev 
 		goto out_remove_sysfs;
 	}
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+	if (rtap_iface) {
+	        err = ipw_prom_alloc(priv);
+		if (err) {
+			IPW_ERROR("Failed to register promiscuous network "
+				  "device (error %d).\n", err);
+			unregister_netdev(priv->net_dev);
+			goto out_remove_sysfs;
+		}
+	}
+#endif
+
 	printk(KERN_INFO DRV_NAME ": Detected geography %s (%d 802.11bg "
 	       "channels, %d 802.11a channels)\n",
 	       priv->ieee->geo.name, priv->ieee->geo.bg_channels,
@@ -11107,6 +11645,10 @@ static void ipw_pci_remove(struct pci_de
 		priv->error = NULL;
 	}
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+	ipw_prom_free(priv);
+#endif
+
 	free_irq(pdev->irq, priv);
 	iounmap(priv->hw_base);
 	pci_release_regions(pdev);
@@ -11231,6 +11773,11 @@ MODULE_PARM_DESC(debug, "debug output ma
 module_param(channel, int, 0444);
 MODULE_PARM_DESC(channel, "channel to limit associate to (default 0 [ANY])");
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+module_param(rtap_iface, int, 0444);
+MODULE_PARM_DESC(rtap_iface, "create the rtap interface (1 - create, default 0)");
+#endif
+
 #ifdef CONFIG_IPW_QOS
 module_param(qos_enable, int, 0444);
 MODULE_PARM_DESC(qos_enable, "enable all QoS functionalitis");
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index 1f2cab3..14fe79a 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -789,7 +789,7 @@ struct ipw_sys_config {
 	u8 bt_coexist_collision_thr;
 	u8 silence_threshold;
 	u8 accept_all_mgmt_bcpr;
-	u8 accept_all_mgtm_frames;
+	u8 accept_all_mgmt_frames;
 	u8 pass_noise_stats_to_host;
 	u8 reserved3;
 } __attribute__ ((packed));
@@ -1122,6 +1122,52 @@ struct ipw_fw_error {
 	u8 payload[0];
 } __attribute__ ((packed));
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+
+enum ipw_prom_filter {
+	IPW_PROM_CTL_HEADER_ONLY = (1 << 0),
+	IPW_PROM_MGMT_HEADER_ONLY = (1 << 1),
+	IPW_PROM_DATA_HEADER_ONLY = (1 << 2),
+	IPW_PROM_ALL_HEADER_ONLY = 0xf, /* bits 0..3 */
+	IPW_PROM_NO_TX = (1 << 4),
+	IPW_PROM_NO_RX = (1 << 5),
+	IPW_PROM_NO_CTL = (1 << 6),
+	IPW_PROM_NO_MGMT = (1 << 7),
+	IPW_PROM_NO_DATA = (1 << 8),
+};
+
+struct ipw_priv;
+struct ipw_prom_priv {
+	struct ipw_priv *priv;
+	struct ieee80211_device *ieee;
+	enum ipw_prom_filter filter;
+	int tx_packets;
+	int rx_packets;
+};
+#endif
+
+#if defined(CONFIG_IEEE80211_RADIOTAP) || defined(CONFIG_IPW2200_PROMISCUOUS)
+/* Magic struct that slots into the radiotap header -- no reason
+ * to build this manually element by element, we can write it much
+ * more efficiently than we can parse it. ORDER MATTERS HERE
+ *
+ * When sent to us via the simulated Rx interface in sysfs, the entire
+ * structure is provided regardless of any bits unset.
+ */
+struct ipw_rt_hdr {
+	struct ieee80211_radiotap_header rt_hdr;
+	u64 rt_tsf;      /* TSF */
+	u8 rt_flags;	/* radiotap packet flags */
+	u8 rt_rate;	/* rate in 500kb/s */
+	u16 rt_channel;	/* channel in mhz */
+	u16 rt_chbitmask;	/* channel bitfield */
+	s8 rt_dbmsignal;	/* signal in dbM, kluged to signed */
+	s8 rt_dbmnoise;
+	u8 rt_antenna;	/* antenna number */
+	u8 payload[0];  /* payload... */
+} __attribute__ ((packed));
+#endif
+
 struct ipw_priv {
 	/* ieee device used by generic ieee processing code */
 	struct ieee80211_device *ieee;
@@ -1133,6 +1179,12 @@ struct ipw_priv {
 	struct pci_dev *pci_dev;
 	struct net_device *net_dev;
 
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+	/* Promiscuous mode */
+	struct ipw_prom_priv *prom_priv;
+	struct net_device *prom_net_dev;
+#endif
+
 	/* pci hardware address support */
 	void __iomem *hw_base;
 	unsigned long hw_len;
@@ -1306,6 +1358,29 @@ struct ipw_priv {
 
 /* debug macros */
 
+/* Debug and printf string expansion helpers for printing bitfields */
+#define BIT_FMT8 "%c%c%c%c-%c%c%c%c"
+#define BIT_FMT16 BIT_FMT8 ":" BIT_FMT8
+#define BIT_FMT32 BIT_FMT16 " " BIT_FMT16
+
+#define BITC(x,y) (((x>>y)&1)?'1':'0')
+#define BIT_ARG8(x) \
+BITC(x,7),BITC(x,6),BITC(x,5),BITC(x,4),\
+BITC(x,3),BITC(x,2),BITC(x,1),BITC(x,0)
+
+#define BIT_ARG16(x) \
+BITC(x,15),BITC(x,14),BITC(x,13),BITC(x,12),\
+BITC(x,11),BITC(x,10),BITC(x,9),BITC(x,8),\
+BIT_ARG8(x)
+
+#define BIT_ARG32(x) \
+BITC(x,31),BITC(x,30),BITC(x,29),BITC(x,28),\
+BITC(x,27),BITC(x,26),BITC(x,25),BITC(x,24),\
+BITC(x,23),BITC(x,22),BITC(x,21),BITC(x,20),\
+BITC(x,19),BITC(x,18),BITC(x,17),BITC(x,16),\
+BIT_ARG16(x)
+
+
 #ifdef CONFIG_IPW2200_DEBUG
 #define IPW_DEBUG(level, fmt, args...) \
 do { if (ipw_debug_level & (level)) \
-- 
1.2.6

