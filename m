From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 13/15] wireless/orinoco: RF monitor mode support
Date: Tue, 26 Oct 2004 15:22:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098818547.3663.87.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o o RF monitor mode support (Pavel Roskin)

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco.c.13-monitor-mode	2004-10-26 13:22:02.674402336 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-10-26 13:38:35.020542792 -0400
@@ -612,26 +612,45 @@
 /* Data types                                                       */
 /********************************************************************/
 
-struct header_struct {
-	/* 802.3 */
-	u8 dest[ETH_ALEN];
-	u8 src[ETH_ALEN];
-	u16 len;
-	/* 802.2 */
+/* Used in Event handling.
+ * We avoid nested structres as they break on ARM -- Moustafa */
+struct hermes_tx_descriptor_802_11 {
+	/* hermes_tx_descriptor */        
+	u16 status;
+	u16 reserved1;
+	u16 reserved2;
+	u32 sw_support;
+	u8 retry_count;
+	u8 tx_rate;
+	u16 tx_control;
+
+	/* ieee802_11_hdr */
+	u16 frame_ctl;
+	u16 duration_id;
+	u8 addr1[ETH_ALEN];
+	u8 addr2[ETH_ALEN];
+	u8 addr3[ETH_ALEN];
+	u16 seq_ctl;
+	u8 addr4[ETH_ALEN];
+	u16 data_len;
+
+	/* ethhdr */
+	unsigned char   h_dest[ETH_ALEN];       /* destination eth addr */
+	unsigned char   h_source[ETH_ALEN];     /* source ether addr    */
+	unsigned short  h_proto;                /* packet type ID field */
+
+	/* p8022_hdr */
 	u8 dsap;
 	u8 ssap;
 	u8 ctrl;
-	/* SNAP */
 	u8 oui[3];
+
 	u16 ethertype;
 } __attribute__ ((packed));
 
-/* 802.2 LLC/SNAP header used for Ethernet encapsulation over 802.11 */
-u8 encaps_hdr[] = {0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00};
-
-#define ENCAPS_OVERHEAD		(sizeof(encaps_hdr) + 2)
-
+/* Rx frame header except compatibility 802.3 header */
 struct hermes_rx_descriptor {
+	/* Control */
 	u16 status;
 	u32 time;
 	u8 silence;
@@ -639,6 +658,18 @@
 	u8 rate;
 	u8 rxflow;
 	u32 reserved;
+
+	/* 802.11 header */
+	u16 frame_ctl;
+	u16 duration_id;
+	u8 addr1[ETH_ALEN];
+	u8 addr2[ETH_ALEN];
+	u8 addr3[ETH_ALEN];
+	u16 seq_ctl;
+	u8 addr4[ETH_ALEN];
+
+	/* Data length */
+	u16 data_len;
 } __attribute__ ((packed));
 
 /********************************************************************/
@@ -669,6 +700,10 @@
 			priv->createibss = 1;
 		}
 		break;
+	case IW_MODE_MONITOR:
+		priv->port_type = 3;
+		priv->createibss = 0;
+		break;
 	default:
 		printk(KERN_ERR "%s: Invalid priv->iw_mode in set_port_type()\n",
 		       priv->ndev->name);
@@ -851,7 +886,7 @@
 		return 1;
 	}
 
-	if (! netif_carrier_ok(dev)) {
+	if (! netif_carrier_ok(dev) || (priv->iw_mode == IW_MODE_MONITOR)) {
 		/* Oops, the firmware hasn't established a connection,
                    silently drop the packet (this seems to be the
                    safest approach). */
@@ -988,27 +1023,57 @@
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
 	u16 fid = hermes_read_regn(hw, TXCOMPLFID);
-	struct hermes_tx_descriptor desc;
+	struct hermes_tx_descriptor_802_11 hdr;
 	int err = 0;
 
 	if (fid == DUMMY_FID)
 		return; /* Nothing's really happened */
 
-	err = hermes_bap_pread(hw, IRQ_BAP, &desc, sizeof(desc), fid, 0);
+	/* Read the frame header */
+	err = hermes_bap_pread(hw, IRQ_BAP, &hdr,
+			       sizeof(struct hermes_tx_descriptor) +
+			       sizeof(struct ieee802_11_hdr),
+			       fid, 0);
+
+	hermes_write_regn(hw, TXCOMPLFID, DUMMY_FID);
+	stats->tx_errors++;
+
 	if (err) {
 		printk(KERN_WARNING "%s: Unable to read descriptor on Tx error "
 		       "(FID=%04X error %d)\n",
 		       dev->name, fid, err);
-	} else {
-		DEBUG(1, "%s: Tx error, status %d\n",
-		      dev->name, le16_to_cpu(desc.status));
+		return;
 	}
 	
-	stats->tx_errors++;
+	DEBUG(1, "%s: Tx error, err %d (FID=%04X)\n", dev->name,
+	      err, fid);
+    
+#if WIRELESS_EXT > 13
+	/* We produce a TXDROP event only for retry or lifetime
+	 * exceeded, because that's the only status that really mean
+	 * that this particular node went away.
+	 * Other errors means that *we* screwed up. - Jean II */
+	hdr.status = le16_to_cpu(hdr.status);
+	if (hdr.status & (HERMES_TXSTAT_RETRYERR | HERMES_TXSTAT_AGEDERR)) {
+		union iwreq_data	wrqu;
+
+		/* Copy 802.11 dest address.
+		 * We use the 802.11 header because the frame may
+		 * not be 802.3 or may be mangled...
+		 * In Ad-Hoc mode, it will be the node address.
+		 * In managed mode, it will be most likely the AP addr
+		 * User space will figure out how to convert it to
+		 * whatever it needs (IP address or else).
+		 * - Jean II */
+		memcpy(wrqu.addr.sa_data, hdr.addr1, ETH_ALEN);
+		wrqu.addr.sa_family = ARPHRD_ETHER;
 
-	netif_wake_queue(dev);
+		/* Send event to user space */
+		wireless_send_event(dev, IWEVTXDROP, &wrqu, NULL);
+	}
+#endif /* WIRELESS_EXT > 13 */
 
-	hermes_write_regn(hw, TXCOMPLFID, DUMMY_FID);
+	netif_wake_queue(dev);
 }
 
 static void orinoco_tx_timeout(struct net_device *dev)
@@ -1033,15 +1098,17 @@
 
 /* Does the frame have a SNAP header indicating it should be
  * de-encapsulated to Ethernet-II? */
-static inline int is_ethersnap(struct header_struct *hdr)
+static inline int is_ethersnap(void *_hdr)
 {
+	u8 *hdr = _hdr;
+
 	/* We de-encapsulate all packets which, a) have SNAP headers
 	 * (i.e. SSAP=DSAP=0xaa and CTRL=0x3 in the 802.2 LLC header
 	 * and where b) the OUI of the SNAP header is 00:00:00 or
 	 * 00:00:f8 - we need both because different APs appear to use
 	 * different OUIs for some reason */
-	return (memcmp(&hdr->dsap, &encaps_hdr, 5) == 0)
-		&& ( (hdr->oui[2] == 0x00) || (hdr->oui[2] == 0xf8) );
+	return (memcmp(hdr, &encaps_hdr, 5) == 0)
+		&& ( (hdr[5] == 0x00) || (hdr[5] == 0xf8) );
 }
 
 static inline void orinoco_spy_gather(struct net_device *dev, u_char *mac,
@@ -1083,18 +1150,124 @@
 	}
 }
 
-static void __orinoco_ev_rx(struct net_device *dev, hermes_t *hw)
+/*
+ * orinoco_rx_monitor - handle received monitor frames.
+ *
+ * Arguments:
+ *	dev		network device
+ *	rxfid		received FID
+ *	desc		rx descriptor of the frame
+ *
+ * Call context: interrupt
+ */
+static void orinoco_rx_monitor(struct net_device *dev, u16 rxfid,
+			       struct hermes_rx_descriptor *desc)
+{
+	u32 hdrlen = 30;	/* return full header by default */
+	u32 datalen = 0;
+	u16 fc;
+	int err;
+	int len;
+	struct sk_buff *skb;
+	struct orinoco_private *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &priv->stats;
+	hermes_t *hw = &priv->hw;
+
+	len = le16_to_cpu(desc->data_len);
+
+	/* Determine the size of the header and the data */
+	fc = le16_to_cpu(desc->frame_ctl);
+	switch (fc & IEEE802_11_FCTL_FTYPE) {
+	case IEEE802_11_FTYPE_DATA:
+		if ((fc & IEEE802_11_FCTL_TODS)
+		    && (fc & IEEE802_11_FCTL_FROMDS))
+			hdrlen = 30;
+		else
+			hdrlen = 24;
+		datalen = len;
+		break;
+	case IEEE802_11_FTYPE_MGMT:
+		hdrlen = 24;
+		datalen = len;
+		break;
+	case IEEE802_11_FTYPE_CTL:
+		switch (fc & IEEE802_11_FCTL_STYPE) {
+		case IEEE802_11_STYPE_PSPOLL:
+		case IEEE802_11_STYPE_RTS:
+		case IEEE802_11_STYPE_CFEND:
+		case IEEE802_11_STYPE_CFENDACK:
+			hdrlen = 16;
+			break;
+		case IEEE802_11_STYPE_CTS:
+		case IEEE802_11_STYPE_ACK:
+			hdrlen = 10;
+			break;
+		}
+		break;
+	default:
+		/* Unknown frame type */
+		break;
+	}
+
+	/* sanity check the length */
+	if (datalen > IEEE802_11_DATA_LEN + 12) {
+		printk(KERN_DEBUG "%s: oversized monitor frame, "
+		       "data length = %d\n", dev->name, datalen);
+		err = -EIO;
+		goto drop;
+	}
+
+	skb = dev_alloc_skb(hdrlen + datalen);
+	if (!skb) {
+		printk(KERN_WARNING "%s: Cannot allocate skb for monitor frame\n",
+		       dev->name);
+		err = -ENOMEM;
+		goto drop;
+	}
+
+	/* Copy the 802.11 header to the skb */
+	memcpy(skb_put(skb, hdrlen), &(desc->frame_ctl), hdrlen);
+	skb->mac.raw = skb->data;
+
+	/* If any, copy the data from the card to the skb */
+	if (datalen > 0) {
+		err = hermes_bap_pread(hw, IRQ_BAP, skb_put(skb, datalen),
+				       ALIGN(datalen, 2), rxfid,
+				       HERMES_802_2_OFFSET);
+		if (err) {
+			printk(KERN_ERR "%s: error %d reading monitor frame\n",
+			       dev->name, err);
+			goto drop;
+		}
+	}
+
+	skb->dev = dev;
+	skb->ip_summed = CHECKSUM_NONE;
+	skb->pkt_type = PACKET_OTHERHOST;
+	skb->protocol = __constant_htons(ETH_P_802_2);
+	
+	dev->last_rx = jiffies;
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+
+	netif_rx(skb);
+	return;
+
+ drop:
+	stats->rx_errors++;
+	stats->rx_dropped++;
+}
+
+void __orinoco_ev_rx(struct net_device *dev, hermes_t *hw)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
 	struct iw_statistics *wstats = &priv->wstats;
 	struct sk_buff *skb = NULL;
-	u16 rxfid, status;
-	int length, data_len, data_off;
-	char *p;
+	u16 rxfid, status, fc;
+	int length;
 	struct hermes_rx_descriptor desc;
-	struct header_struct hdr;
-	struct ethhdr *eh;
+	struct ethhdr *hdr;
 	int err;
 
 	rxfid = hermes_read_regn(hw, RXFID);
@@ -1110,33 +1283,31 @@
 
 	status = le16_to_cpu(desc.status);
 
-	if (status & HERMES_RXSTAT_ERR) {
-		if (status & HERMES_RXSTAT_UNDECRYPTABLE) {
-			wstats->discard.code++;
-			DEBUG(1, "%s: Undecryptable frame on Rx. Frame dropped.\n",
-			       dev->name);
-		} else {
-			stats->rx_crc_errors++;
-			DEBUG(1, "%s: Bad CRC on Rx. Frame dropped.\n", dev->name);
-		}
+	if (status & HERMES_RXSTAT_BADCRC) {
+		DEBUG(1, "%s: Bad CRC on Rx. Frame dropped.\n",
+		      dev->name);
+		stats->rx_crc_errors++;
 		stats->rx_errors++;
 		goto drop;
 	}
 
-	/* For now we ignore the 802.11 header completely, assuming
-           that the card's firmware has handled anything vital */
+	/* Handle frames in monitor mode */
+	if (priv->iw_mode == IW_MODE_MONITOR) {
+		orinoco_rx_monitor(dev, rxfid, &desc);
+		return;
+	}
 
-	err = hermes_bap_pread(hw, IRQ_BAP, &hdr, sizeof(hdr),
-			       rxfid, HERMES_802_3_OFFSET);
-	if (err) {
-		printk(KERN_ERR "%s: error %d reading frame header. "
-		       "Frame dropped.\n", dev->name, err);
+	if (status & HERMES_RXSTAT_UNDECRYPTABLE) {
+		DEBUG(1, "%s: Undecryptable frame on Rx. Frame dropped.\n",
+		      dev->name);
+		wstats->discard.code++;
 		stats->rx_errors++;
 		goto drop;
 	}
 
-	length = ntohs(hdr.len);
-	
+	length = le16_to_cpu(desc.data_len);
+	fc = le16_to_cpu(desc.frame_ctl);
+
 	/* Sanity checks */
 	if (length < 3) { /* No for even an 802.2 LLC header */
 		/* At least on Symbol firmware with PCF we get quite a
@@ -1165,57 +1336,51 @@
 		goto drop;
 	}
 
-	skb_reserve(skb, 2); /* This way the IP header is aligned */
+	/* We'll prepend the header, so reserve space for it.  The worst
+	   case is no decapsulation, when 802.3 header is prepended and
+	   nothing is removed.  2 is for aligning the IP header.  */
+	skb_reserve(skb, ETH_HLEN + 2);
+
+	err = hermes_bap_pread(hw, IRQ_BAP, skb_put(skb, length),
+			       ALIGN(length, 2), rxfid,
+			       HERMES_802_2_OFFSET);
+	if (err) {
+		printk(KERN_ERR "%s: error %d reading frame. "
+		       "Frame dropped.\n", dev->name, err);
+		stats->rx_errors++;
+		goto drop;
+	}
 
 	/* Handle decapsulation
 	 * In most cases, the firmware tell us about SNAP frames.
 	 * For some reason, the SNAP frames sent by LinkSys APs
 	 * are not properly recognised by most firmwares.
 	 * So, check ourselves */
-	if (((status & HERMES_RXSTAT_MSGTYPE) == HERMES_RXSTAT_1042) ||
-	    ((status & HERMES_RXSTAT_MSGTYPE) == HERMES_RXSTAT_TUNNEL) ||
-	    is_ethersnap(&hdr)) {
+	if (length >= ENCAPS_OVERHEAD &&
+	    (((status & HERMES_RXSTAT_MSGTYPE) == HERMES_RXSTAT_1042) ||
+	     ((status & HERMES_RXSTAT_MSGTYPE) == HERMES_RXSTAT_TUNNEL) ||
+	     is_ethersnap(skb->data))) {
 		/* These indicate a SNAP within 802.2 LLC within
 		   802.11 frame which we'll need to de-encapsulate to
 		   the original EthernetII frame. */
-
-		if (length < ENCAPS_OVERHEAD) { /* No room for full LLC+SNAP */
-			stats->rx_length_errors++;
-			goto drop;
-		}
-
-		/* Remove SNAP header, reconstruct EthernetII frame */
-		data_len = length - ENCAPS_OVERHEAD;
-		data_off = HERMES_802_3_OFFSET + sizeof(hdr);
-
-		eh = (struct ethhdr *)skb_put(skb, ETH_HLEN);
-
-		memcpy(eh, &hdr, 2 * ETH_ALEN);
-		eh->h_proto = hdr.ethertype;
+		hdr = (struct ethhdr *)skb_push(skb, ETH_HLEN - ENCAPS_OVERHEAD);
 	} else {
-		/* All other cases indicate a genuine 802.3 frame.  No
-		   decapsulation needed.  We just throw the whole
-		   thing in, and hope the protocol layer can deal with
-		   it as 802.3 */
-		data_len = length;
-		data_off = HERMES_802_3_OFFSET;
-		/* FIXME: we re-read from the card data we already read here */
-	}
-
-	p = skb_put(skb, data_len);
-	err = hermes_bap_pread(hw, IRQ_BAP, p, ALIGN(data_len, 2),
-			       rxfid, data_off);
-	if (err) {
-		printk(KERN_ERR "%s: error %d reading frame. "
-		       "Frame dropped.\n", dev->name, err);
-		stats->rx_errors++;
-		goto drop;
-	}
+		/* 802.3 frame - prepend 802.3 header as is */
+		hdr = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+		hdr->h_proto = htons(length);
+	}
+	memcpy(hdr->h_dest, desc.addr1, ETH_ALEN);
+	if (fc & IEEE802_11_FCTL_FROMDS)
+		memcpy(hdr->h_source, desc.addr3, ETH_ALEN);
+	else
+		memcpy(hdr->h_source, desc.addr2, ETH_ALEN);
 
 	dev->last_rx = jiffies;
 	skb->dev = dev;
 	skb->protocol = eth_type_trans(skb, dev);
 	skb->ip_summed = CHECKSUM_NONE;
+	if (fc & IEEE802_11_FCTL_TODS)
+		skb->pkt_type = PACKET_OTHERHOST;
 	
 	/* Process the wireless stats if needed */
 	orinoco_stat_gather(dev, skb, &desc);
@@ -1276,7 +1441,33 @@
 	       dev->name, s, status);
 }
 
-static void __orinoco_ev_info(struct net_device *dev, hermes_t *hw)
+#if WIRELESS_EXT > 13
+/* Send new BSSID to userspace */
+static void orinoco_send_wevents(struct net_device *dev)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	struct hermes *hw = &priv->hw;
+	union iwreq_data wrqu;
+	int err;
+	unsigned long flags;
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return;
+
+	err = hermes_read_ltv(hw, IRQ_BAP, HERMES_RID_CURRENTBSSID,
+			      ETH_ALEN, NULL, wrqu.ap_addr.sa_data);
+	if (err != 0)
+		return;
+
+	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
+
+	/* Send event to user space */
+	wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
+	orinoco_unlock(priv, &flags);
+}
+#endif
+
+void __orinoco_ev_info(struct net_device *dev, hermes_t *hw)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	u16 infofid;
@@ -1316,10 +1507,11 @@
 			len = sizeof(tallies);
 		}
 		
-		/* Read directly the data (no seek) */
-		hermes_read_words(hw, HERMES_DATA1, (void *) &tallies,
-				  len / 2); /* FIXME: blech! */
-		
+		err = hermes_bap_pread(hw, IRQ_BAP, &tallies, len,
+				       infofid, sizeof(info));
+		if (err)
+			break;
+
 		/* Increment our various counters */
 		/* wstats->discard.nwid - no wrong BSSID stuff */
 		wstats->discard.code +=
@@ -1330,11 +1522,13 @@
 				le16_to_cpu(tallies.RxDiscards_WEPExcluded);
 		wstats->discard.misc +=
 			le16_to_cpu(tallies.TxDiscardsWrongSA);
+#if WIRELESS_EXT > 11
 		wstats->discard.fragment +=
 			le16_to_cpu(tallies.RxMsgInBadMsgFragments);
 		wstats->discard.retries +=
 			le16_to_cpu(tallies.TxRetryLimitExceeded);
 		/* wstats->miss.beacon - no match */
+#endif /* WIRELESS_EXT > 11 */
 	}
 	break;
 	case HERMES_INQ_LINKSTATUS: {
@@ -1342,6 +1536,9 @@
 		u16 newstatus;
 		int connected;
 
+		if (priv->iw_mode == IW_MODE_MONITOR)
+			break;
+
 		if (len != sizeof(linkstatus)) {
 			printk(KERN_WARNING "%s: Unexpected size for linkstatus frame (%d bytes)\n",
 			       dev->name, len);
@@ -1370,6 +1567,12 @@
 		}
 	}
 	break;
+	case HERMES_INQ_SEC_STAT_AGERE:
+		/* Security status (Agere specific) */
+		/* Ignore this frame for now */
+		if (priv->firmware_type == FIRMWARE_TYPE_AGERE)
+			break;
+		/* fall through */
 	default:
 		printk(KERN_DEBUG "%s: Unknown information frame received: "
 		       "type 0x%04x, length %d\n", dev->name, type, len);
@@ -1645,6 +1848,9 @@
 		} else
 			master_wep_flag = 0;
 
+		if (priv->iw_mode == IW_MODE_MONITOR)
+			master_wep_flag |= HERMES_WEP_HOST_DECRYPT;
+
 		/* Master WEP setting : on/off */
 		err = hermes_write_wordrec(hw, USER_BAP,
 					   HERMES_RID_CNFWEPFLAGS_INTERSIL,
@@ -1864,6 +2070,20 @@
 		}
 	}
 
+	if (priv->iw_mode == IW_MODE_MONITOR) {
+		/* Enable monitor mode */
+		dev->type = ARPHRD_IEEE80211;
+		err = hermes_docmd_wait(hw, HERMES_CMD_TEST | 
+					    HERMES_TEST_MONITOR, 0, NULL);
+	} else {
+		/* Disable monitor mode */
+		dev->type = ARPHRD_ETHER;
+		err = hermes_docmd_wait(hw, HERMES_CMD_TEST |
+					    HERMES_TEST_STOP, 0, NULL);
+	}
+	if (err)
+		return err;
+
 	/* Set promiscuity / multicast*/
 	priv->promiscuous = 0;
 	priv->mc_count = 0;
@@ -2091,7 +2311,7 @@
 		if (events & HERMES_EV_ALLOC)
 			__orinoco_ev_alloc(dev, hw);
 		
-		hermes_write_regn(hw, EVACK, events);
+		hermes_write_regn(hw, EVACK, evstat);
 
 		evstat = hermes_read_regn(hw, EVSTAT);
 		events = evstat & hw->inten;
@@ -2207,6 +2427,7 @@
 		priv->has_mwo = (firmver >= 0x60000);
 		priv->has_pm = (firmver >= 0x40020); /* Don't work in 7.52 ? */
 		priv->ibss_port = 1;
+		priv->broken_monitor = (firmver >= 0x80000);
 
 		/* Tested with Agere firmware :
 		 *	1.16 ; 4.08 ; 4.52 ; 6.04 ; 6.16 ; 7.28 => Jean II
@@ -2499,6 +2720,9 @@
 				   * before anything else touches the
 				   * hardware */
 	INIT_WORK(&priv->reset_work, (void (*)(void *))orinoco_reset, dev);
+#if WIRELESS_EXT > 13
+	INIT_WORK(&priv->wevent_work, (void (*)(void *))orinoco_send_wevents, dev);
+#endif
 
 	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
@@ -2770,6 +2994,15 @@
 	case IW_MODE_INFRA:
 		break;
 
+	case IW_MODE_MONITOR:
+		if (priv->broken_monitor) {
+			printk(KERN_WARNING "%s: Monitor mode support is "
+			       "buggy in this firmware, not enabling\n",
+			       dev->name);
+			err = -EOPNOTSUPP;
+		}
+		break;
+
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -3177,6 +3410,13 @@
 		return -EBUSY;
 
 	priv->channel = chan;
+	if (priv->iw_mode == IW_MODE_MONITOR) {
+		/* Fast channel change - no commit if successful */
+		hermes_t *hw = &priv->hw;
+		err = hermes_docmd_wait(hw, HERMES_CMD_TEST |
+					    HERMES_TEST_SET_CHANNEL,
+					chan, NULL);
+	}
 	orinoco_unlock(priv, &flags);
 
 	return err;
@@ -4544,6 +4784,8 @@
 EXPORT_SYMBOL(orinoco_reinit_firmware);
 
 EXPORT_SYMBOL(orinoco_interrupt);
+EXPORT_SYMBOL(__orinoco_ev_rx);
+EXPORT_SYMBOL(__orinoco_ev_info);
 
 /* Can't be declared "const" or the whole __initdata section will
  * become const */
--- a/drivers/net/wireless/orinoco.h.13-monitor-mode	2004-10-26 13:22:08.011590960 -0400
+++ b/drivers/net/wireless/orinoco.h	2004-10-26 13:35:27.978977432 -0400
@@ -36,6 +36,25 @@
 	char data[ORINOCO_MAX_KEY_SIZE];
 } __attribute__ ((packed));
 
+struct header_struct {
+	/* 802.3 */
+	u8 dest[ETH_ALEN];
+	u8 src[ETH_ALEN];
+	u16 len;
+	/* 802.2 */
+	u8 dsap;
+	u8 ssap;
+	u8 ctrl;
+	/* SNAP */
+	u8 oui[3];
+	u16 ethertype;
+} __attribute__ ((packed));
+
+/* 802.2 LLC/SNAP header used for Ethernet encapsulation over 802.11 */
+#define encaps_hdr ((u8[]){0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00})
+
+#define ENCAPS_OVERHEAD		(sizeof(encaps_hdr) + 2)
+
 typedef enum {
 	FIRMWARE_TYPE_AGERE,
 	FIRMWARE_TYPE_INTERSIL,
@@ -54,6 +73,10 @@
 	/* driver state */
 	int open;
 	u16 last_linkstatus;
+	struct work_struct join_work;
+#if WIRELESS_EXT > 13
+	struct work_struct wevent_work;
+#endif
 
 	/* Net device stuff */
 	struct net_device *ndev;
@@ -81,6 +104,7 @@
 	unsigned int has_preamble:1;
 	unsigned int has_sensitivity:1;
 	unsigned int broken_disableport:1;
+	unsigned int broken_monitor:1;
 	unsigned int irq_no_disable:1;
 
 	/* Configuration paramaters */
@@ -131,6 +155,8 @@
 extern int orinoco_stop(struct net_device *dev);
 extern int orinoco_reinit_firmware(struct net_device *dev);
 extern irqreturn_t orinoco_interrupt(int irq, void * dev_id, struct pt_regs *regs);
+extern void __orinoco_ev_info(struct net_device *dev, hermes_t *hw);
+extern void __orinoco_ev_rx(struct net_device *dev, hermes_t *hw);
 
 /********************************************************************/
 /* Locking and synchronization functions                            */
