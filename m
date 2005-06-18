From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 6/9] orinoco: scanning support
Date: Sun, 19 Jun 2005 01:27:56 +0200
Message-ID: <20050618232756.GG9918@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, proski@gnu.org, hermes@gibson.dropbear.id.au
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Patch from Pavel Roskin


Index: linux-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/orinoco.c	2005-06-19 01:03:47.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.c	2005-06-19 01:03:51.000000000 +0200
@@ -514,6 +514,10 @@
 /* Internal constants                                               */
 /********************************************************************/
 
+/* 802.2 LLC/SNAP header used for Ethernet encapsulation over 802.11 */
+static const u8 encaps_hdr[] = {0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00};
+#define ENCAPS_OVERHEAD		(sizeof(encaps_hdr) + 2)
+
 #define ORINOCO_MIN_MTU		256
 #define ORINOCO_MAX_MTU		(IEEE802_11_DATA_LEN - ENCAPS_OVERHEAD)
 
@@ -579,25 +583,42 @@
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
 struct hermes_rx_descriptor {
 	u16 status;
 	u32 time;
@@ -958,26 +979,55 @@
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
+			       sizeof(struct ieee80211_hdr),
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
+
+		/* Send event to user space */
+		wireless_send_event(dev, IWEVTXDROP, &wrqu, NULL);
+	}
 
 	netif_wake_queue(dev);
-	hermes_write_regn(hw, TXCOMPLFID, DUMMY_FID);
 }
 
 static void orinoco_tx_timeout(struct net_device *dev)
@@ -1316,6 +1366,30 @@
 	orinoco_unlock(priv, &flags);
 }
 
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
+
 static void __orinoco_ev_info(struct net_device *dev, hermes_t *hw)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
@@ -1395,6 +1469,15 @@
 			break;
 		newstatus = le16_to_cpu(linkstatus.linkstatus);
 
+		/* Symbol firmware uses "out of range" to signal that
+		 * the hostscan frame can be requested.  */
+		if (newstatus == HERMES_LINKSTATUS_AP_OUT_OF_RANGE &&
+		    priv->firmware_type == FIRMWARE_TYPE_SYMBOL &&
+		    priv->has_hostscan && priv->scan_inprogress) {
+			hermes_inquire(hw, HERMES_INQ_HOSTSCAN_SYMBOL);
+			break;
+		}
+
 		connected = (newstatus == HERMES_LINKSTATUS_CONNECTED)
 			|| (newstatus == HERMES_LINKSTATUS_AP_CHANGE)
 			|| (newstatus == HERMES_LINKSTATUS_AP_IN_RANGE);
@@ -1404,12 +1487,89 @@
 		else if (!ignore_disconnect)
 			netif_carrier_off(dev);
 
-		if (newstatus != priv->last_linkstatus)
+		if (newstatus != priv->last_linkstatus) {
+			priv->last_linkstatus = newstatus;
 			print_linkstatus(dev, newstatus);
+			/* The info frame contains only one word which is the
+			 * status (see hermes.h). The status is pretty boring
+			 * in itself, that's why we export the new BSSID...
+			 * Jean II */
+			schedule_work(&priv->wevent_work);
+		}
+	}
+	break;
+	case HERMES_INQ_SCAN:
+		if (!priv->scan_inprogress && priv->bssid_fixed &&
+		    priv->firmware_type == FIRMWARE_TYPE_INTERSIL) {
+			schedule_work(&priv->join_work);
+			break;
+		}
+		/* fall through */
+	case HERMES_INQ_HOSTSCAN:
+	case HERMES_INQ_HOSTSCAN_SYMBOL: {
+		/* Result of a scanning. Contains information about
+		 * cells in the vicinity - Jean II */
+		union iwreq_data	wrqu;
+		unsigned char *buf;
+
+		/* Sanity check */
+		if (len > 4096) {
+			printk(KERN_WARNING "%s: Scan results too large (%d bytes)\n",
+			       dev->name, len);
+			break;
+		}
+
+		/* We are a strict producer. If the previous scan results
+		 * have not been consumed, we just have to drop this
+		 * frame. We can't remove the previous results ourselves,
+		 * that would be *very* racy... Jean II */
+		if (priv->scan_result != NULL) {
+			printk(KERN_WARNING "%s: Previous scan results not consumed, dropping info frame.\n", dev->name);
+			break;
+		}
+
+		/* Allocate buffer for results */
+		buf = kmalloc(len, GFP_ATOMIC);
+		if (buf == NULL)
+			/* No memory, so can't printk()... */
+			break;
+
+		/* Read scan data */
+		err = hermes_bap_pread(hw, IRQ_BAP, (void *) buf, len,
+				       infofid, sizeof(info));
+		if (err)
+			break;
 
-		priv->last_linkstatus = newstatus;
+#ifdef ORINOCO_DEBUG
+		{
+			int	i;
+			printk(KERN_DEBUG "Scan result [%02X", buf[0]);
+			for(i = 1; i < (len * 2); i++)
+				printk(":%02X", buf[i]);
+			printk("]\n");
+		}
+#endif	/* ORINOCO_DEBUG */
+
+		/* Allow the clients to access the results */
+		priv->scan_len = len;
+		priv->scan_result = buf;
+
+		/* Send an empty event to user space.
+		 * We don't send the received data on the event because
+		 * it would require us to do complex transcoding, and
+		 * we want to minimise the work done in the irq handler
+		 * Use a request to extract the data - Jean II */
+		wrqu.data.length = 0;
+		wrqu.data.flags = 0;
+		wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
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
@@ -2010,6 +2170,11 @@
 
 	orinoco_unlock(priv, &flags);
 
+ 	/* Scanning support: Cleanup of driver struct */
+	kfree(priv->scan_result);
+	priv->scan_result = NULL;
+	priv->scan_inprogress = 0;
+
 	if (priv->hard_reset) {
 		err = (*priv->hard_reset)(priv);
 		if (err) {
@@ -2248,6 +2413,7 @@
 		priv->has_mwo = (firmver >= 0x60000);
 		priv->has_pm = (firmver >= 0x40020); /* Don't work in 7.52 ? */
 		priv->ibss_port = 1;
+		priv->has_hostscan = (firmver >= 0x8000a);
 
 		/* Tested with Agere firmware :
 		 *	1.16 ; 4.08 ; 4.52 ; 6.04 ; 6.16 ; 7.28 => Jean II
@@ -2293,6 +2459,8 @@
 		priv->ibss_port = 4;
  		priv->broken_disableport = (firmver == 0x25013) ||
  					   (firmver >= 0x30000 && firmver <= 0x31000);
+		priv->has_hostscan = (firmver >= 0x31001) ||
+				     (firmver >= 0x29057 && firmver < 0x30000);
 		/* Tested with Intel firmware : 0x20015 => Jean II */
 		/* Tested with 3Com firmware : 0x15012 & 0x22001 => Jean II */
 		break;
@@ -2312,6 +2480,7 @@
 		priv->has_ibss = (firmver >= 0x000700); /* FIXME */
 		priv->has_big_wep = priv->has_wep = (firmver >= 0x000800);
 		priv->has_pm = (firmver >= 0x000700);
+		priv->has_hostscan = (firmver >= 0x010301);
 
 		if (firmver >= 0x000800)
 			priv->ibss_port = 0;
@@ -2539,6 +2708,7 @@
 				   * hardware */
 	INIT_WORK(&priv->reset_work, (void (*)(void *))orinoco_reset, dev);
 	INIT_WORK(&priv->join_work, (void (*)(void *))orinoco_join_ap, dev);
+	INIT_WORK(&priv->wevent_work, (void (*)(void *))orinoco_send_wevents, dev);
 
 	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
@@ -2549,6 +2719,9 @@
 
 void free_orinocodev(struct net_device *dev)
 {
+	struct orinoco_private *priv = netdev_priv(dev);
+
+	kfree(priv->scan_result);
 	free_netdev(dev);
 }
 
@@ -3967,6 +4140,332 @@
 	return 0;
 }
 
+/* Trigger a scan (look for other cells in the vicinity */
+static int orinoco_ioctl_setscan(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_param *srq,
+				 char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	hermes_t *hw = &priv->hw;
+	int err = 0;
+	unsigned long flags;
+
+	/* Note : you may have realised that, as this is a SET operation,
+	 * this is priviledged and therefore a normal user can't
+	 * perform scanning.
+	 * This is not an error, while the device perform scanning,
+	 * traffic doesn't flow, so it's a perfect DoS...
+	 * Jean II */
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
+	/* Scanning with port 0 disabled would fail */
+	if (!netif_running(dev)) {
+		err = -ENETDOWN;
+		goto out;
+	}
+
+	/* In monitor mode, the scan results are always empty.
+	 * Probe responses are passed to the driver as received
+	 * frames and could be processed in software. */
+	if (priv->iw_mode == IW_MODE_MONITOR) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	/* Note : because we don't lock out the irq handler, the way
+	 * we access scan variables in priv is critical.
+	 *	o scan_inprogress : not touched by irq handler
+	 *	o scan_mode : not touched by irq handler
+	 *	o scan_result : irq is strict producer, non-irq is strict
+	 *		consumer.
+	 *	o scan_len : synchronised with scan_result
+	 * Before modifying anything on those variables, please think hard !
+	 * Jean II */
+
+	/* If there is still some left-over scan results, get rid of it */
+	if (priv->scan_result != NULL) {
+		/* What's likely is that a client did crash or was killed
+		 * between triggering the scan request and reading the
+		 * results, so we need to reset everything.
+		 * Some clients that are too slow may suffer from that...
+		 * Jean II */
+		kfree(priv->scan_result);
+		priv->scan_result = NULL;
+	}
+
+	/* Save flags */
+	priv->scan_mode = srq->flags;
+
+	/* Always trigger scanning, even if it's in progress.
+	 * This way, if the info frame get lost, we will recover somewhat
+	 * gracefully  - Jean II */
+
+	if (priv->has_hostscan) {
+		switch (priv->firmware_type) {
+		case FIRMWARE_TYPE_SYMBOL:
+			err = hermes_write_wordrec(hw, USER_BAP,
+						   HERMES_RID_CNFHOSTSCAN_SYMBOL,
+						   HERMES_HOSTSCAN_SYMBOL_ONCE |
+						   HERMES_HOSTSCAN_SYMBOL_BCAST);
+			break;
+		case FIRMWARE_TYPE_INTERSIL: {
+			u16 req[3];
+
+			req[0] = cpu_to_le16(0x3fff);	/* All channels */
+			req[1] = cpu_to_le16(0x0001);	/* rate 1 Mbps */
+			req[2] = 0;			/* Any ESSID */
+			err = HERMES_WRITE_RECORD(hw, USER_BAP,
+						  HERMES_RID_CNFHOSTSCAN, &req);
+		}
+		break;
+		case FIRMWARE_TYPE_AGERE:
+			err = hermes_write_wordrec(hw, USER_BAP,
+						   HERMES_RID_CNFSCANSSID_AGERE,
+						   0);	/* Any ESSID */
+			if (err)
+				break;
+
+			err = hermes_inquire(hw, HERMES_INQ_SCAN);
+			break;
+		}
+	} else
+		err = hermes_inquire(hw, HERMES_INQ_SCAN);
+
+	/* One more client */
+	if (! err)
+		priv->scan_inprogress = 1;
+
+ out:
+	orinoco_unlock(priv, &flags);
+	return err;
+}
+
+/* Translate scan data returned from the card to a card independant
+ * format that the Wireless Tools will understand - Jean II */
+static inline int orinoco_translate_scan(struct net_device *dev,
+					 char *buffer,
+					 char *scan,
+					 int scan_len)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int			offset;		/* In the scan data */
+	union hermes_scan_info *atom;
+	int			atom_len;
+	u16			capabilities;
+	u16			channel;
+	struct iw_event		iwe;		/* Temporary buffer */
+	char *			current_ev = buffer;
+	char *			end_buf = buffer + IW_SCAN_MAX_DATA;
+
+	switch (priv->firmware_type) {
+	case FIRMWARE_TYPE_AGERE:
+		atom_len = sizeof(struct agere_scan_apinfo);
+ 		offset = 0;
+		break;
+	case FIRMWARE_TYPE_SYMBOL:
+		/* Lack of documentation necessitates this hack.
+		 * Different firmwares have 68 or 76 byte long atoms.
+		 * We try modulo first.  If the length divides by both,
+		 * we check what would be the channel in the second
+		 * frame for a 68-byte atom.  76-byte atoms have 0 there.
+		 * Valid channel cannot be 0.  */
+		if (scan_len % 76)
+			atom_len = 68;
+		else if (scan_len % 68)
+			atom_len = 76;
+		else if (scan_len >= 1292 && scan[68] == 0)
+			atom_len = 76;
+		else
+			atom_len = 68;
+		offset = 0;
+		break;
+	case FIRMWARE_TYPE_INTERSIL:
+		offset = 4;
+		if (priv->has_hostscan)
+			atom_len = scan[0] + (scan[1] << 8);
+		else
+			atom_len = offsetof(struct prism2_scan_apinfo, atim);
+		break;
+	default:
+		return 0;
+	}
+
+	/* Check that we got an whole number of atoms */
+	if ((scan_len - offset) % atom_len) {
+		printk(KERN_ERR "%s: Unexpected scan data length %d, "
+		       "atom_len %d, offset %d\n", dev->name, scan_len,
+		       atom_len, offset);
+		return 0;
+	}
+
+	/* Read the entries one by one */
+	for (; offset + atom_len <= scan_len; offset += atom_len) {
+		/* Get next atom */
+		atom = (union hermes_scan_info *) (scan + offset);
+
+		/* First entry *MUST* be the AP MAC address */
+		iwe.cmd = SIOCGIWAP;
+		iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
+		memcpy(iwe.u.ap_addr.sa_data, atom->a.bssid, ETH_ALEN);
+		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
+
+		/* Other entries will be displayed in the order we give them */
+
+		/* Add the ESSID */
+		iwe.u.data.length = le16_to_cpu(atom->a.essid_len);
+		if (iwe.u.data.length > 32)
+			iwe.u.data.length = 32;
+		iwe.cmd = SIOCGIWESSID;
+		iwe.u.data.flags = 1;
+		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, atom->a.essid);
+
+		/* Add mode */
+		iwe.cmd = SIOCGIWMODE;
+		capabilities = le16_to_cpu(atom->a.capabilities);
+		if (capabilities & 0x3) {
+			if (capabilities & 0x1)
+				iwe.u.mode = IW_MODE_MASTER;
+			else
+				iwe.u.mode = IW_MODE_ADHOC;
+			current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_UINT_LEN);
+		}
+
+		channel = atom->s.channel;
+		if ( (channel >= 1) && (channel <= NUM_CHANNELS) ) {
+			/* Add frequency */
+			iwe.cmd = SIOCGIWFREQ;
+			iwe.u.freq.m = channel_frequency[channel-1] * 100000;
+			iwe.u.freq.e = 1;
+			current_ev = iwe_stream_add_event(current_ev, end_buf,
+							  &iwe, IW_EV_FREQ_LEN);
+		}
+
+		/* Add quality statistics */
+		iwe.cmd = IWEVQUAL;
+		iwe.u.qual.updated = 0x10;	/* no link quality */
+		iwe.u.qual.level = (__u8) le16_to_cpu(atom->a.level) - 0x95;
+		iwe.u.qual.noise = (__u8) le16_to_cpu(atom->a.noise) - 0x95;
+		/* Wireless tools prior to 27.pre22 will show link quality
+		 * anyway, so we provide a reasonable value. */
+		if (iwe.u.qual.level > iwe.u.qual.noise)
+			iwe.u.qual.qual = iwe.u.qual.level - iwe.u.qual.noise;
+		else
+			iwe.u.qual.qual = 0;
+		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
+
+		/* Add encryption capability */
+		iwe.cmd = SIOCGIWENCODE;
+		if (capabilities & 0x10)
+			iwe.u.data.flags = IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
+		else
+			iwe.u.data.flags = IW_ENCODE_DISABLED;
+		iwe.u.data.length = 0;
+		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, atom->a.essid);
+
+		/* Bit rate is not available in Lucent/Agere firmwares */
+		if (priv->firmware_type != FIRMWARE_TYPE_AGERE) {
+			char *	current_val = current_ev + IW_EV_LCP_LEN;
+			int	i;
+			int	step;
+
+			if (priv->firmware_type == FIRMWARE_TYPE_SYMBOL)
+				step = 2;
+			else
+				step = 1;
+
+			iwe.cmd = SIOCGIWRATE;
+			/* Those two flags are ignored... */
+			iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+			/* Max 10 values */
+			for (i = 0; i < 10; i += step) {
+				/* NULL terminated */
+				if (atom->p.rates[i] == 0x0)
+					break;
+				/* Bit rate given in 500 kb/s units (+ 0x80) */
+				iwe.u.bitrate.value = ((atom->p.rates[i] & 0x7f) * 500000);
+				current_val = iwe_stream_add_value(current_ev, current_val,
+								   end_buf, &iwe,
+								   IW_EV_PARAM_LEN);
+			}
+			/* Check if we added any event */
+			if ((current_val - current_ev) > IW_EV_LCP_LEN)
+				current_ev = current_val;
+		}
+
+		/* The other data in the scan result are not really
+		 * interesting, so for now drop it - Jean II */
+	}
+	return current_ev - buffer;
+}
+
+/* Return results of a scan */
+static int orinoco_ioctl_getscan(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_point *srq,
+				 char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int err = 0;
+	unsigned long flags;
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
+	/* If no results yet, ask to try again later */
+	if (priv->scan_result == NULL) {
+		if (priv->scan_inprogress)
+			/* Important note : we don't want to block the caller
+			 * until results are ready for various reasons.
+			 * First, managing wait queues is complex and racy.
+			 * Second, we grab some rtnetlink lock before comming
+			 * here (in dev_ioctl()).
+			 * Third, we generate an Wireless Event, so the
+			 * caller can wait itself on that - Jean II */
+			err = -EAGAIN;
+		else
+			/* Client error, no scan results...
+			 * The caller need to restart the scan. */
+			err = -ENODATA;
+	} else {
+		/* We have some results to push back to user space */
+
+		/* Translate to WE format */
+		srq->length = orinoco_translate_scan(dev, extra,
+						     priv->scan_result,
+						     priv->scan_len);
+
+		/* Return flags */
+		srq->flags = (__u16) priv->scan_mode;
+
+		/* Results are here, so scan no longer in progress */
+		priv->scan_inprogress = 0;
+
+		/* In any case, Scan results will be cleaned up in the
+		 * reset function and when exiting the driver.
+		 * The person triggering the scanning may never come to
+		 * pick the results, so we need to do it in those places.
+		 * Jean II */
+
+#ifdef SCAN_SINGLE_READ
+		/* If you enable this option, only one client (the first
+		 * one) will be able to read the result (and only one
+		 * time). If there is multiple concurent clients that
+		 * want to read scan results, this behavior is not
+		 * advisable - Jean II */
+		kfree(priv->scan_result);
+		priv->scan_result = NULL;
+#endif /* SCAN_SINGLE_READ */
+		/* Here, if too much time has elapsed since last scan,
+		 * we may want to clean up scan results... - Jean II */
+	}
+	  
+	orinoco_unlock(priv, &flags);
+	return err;
+}
+
 /* Commit handler, called after set operations */
 static int orinoco_ioctl_commit(struct net_device *dev,
 				struct iw_request_info *info,
@@ -4060,6 +4559,8 @@
 	[SIOCGIWSPY   -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getspy,
 	[SIOCSIWAP    -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setwap,
 	[SIOCGIWAP    -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getwap,
+	[SIOCSIWSCAN  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setscan,
+	[SIOCGIWSCAN  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getscan,
 	[SIOCSIWESSID -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setessid,
 	[SIOCGIWESSID -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getessid,
 	[SIOCSIWNICKN -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setnick,
Index: linux-2.6/drivers/net/wireless/orinoco.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/orinoco.h	2005-06-19 01:03:47.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.h	2005-06-19 01:03:51.000000000 +0200
@@ -32,6 +32,20 @@
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
 typedef enum {
 	FIRMWARE_TYPE_AGERE,
 	FIRMWARE_TYPE_INTERSIL,
@@ -51,6 +65,7 @@
 	int open;
 	u16 last_linkstatus;
 	struct work_struct join_work;
+	struct work_struct wevent_work;
 
 	/* Net device stuff */
 	struct net_device *ndev;
@@ -77,6 +92,7 @@
 	unsigned int has_pm:1;
 	unsigned int has_preamble:1;
 	unsigned int has_sensitivity:1;
+	unsigned int has_hostscan:1;
 	unsigned int broken_disableport:1;
 
 	/* Configuration paramaters */
@@ -103,6 +119,12 @@
 	/* Configuration dependent variables */
 	int port_type, createibss;
 	int promiscuous, mc_count;
+
+	/* Scanning support */
+	int	scan_inprogress;	/* Scan pending... */
+	u32	scan_mode;		/* Type of scan done */
+	char *	scan_result;		/* Result of previous scan */
+	int	scan_len;		/* Lenght of result */
 };
 
 #ifdef ORINOCO_DEBUG
