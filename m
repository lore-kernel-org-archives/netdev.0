From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 15/15] wireless/orinoco: Wireless scanning
	support
Date: Tue, 26 Oct 2004 15:28:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098818888.9874.6.camel@dcbw.boston.redhat.com>
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

o New wireless extensions API and scanning support (patch from
    Moustafa Youssef, updated by Jim Carter and Pavel Roskin)

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco.c	2004-10-26 13:44:23.281599064 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-08-17 17:26:31.000000000 -0400
@@ -1442,6 +1442,80 @@
 	       dev->name, s, status);
 }
 
+/* Search scan results for requested BSSID, join it if found */
+static void orinoco_join_ap(struct net_device *dev)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	struct hermes *hw = &priv->hw;
+	int err;
+	unsigned long flags;
+	struct join_req {
+		u8 bssid[ETH_ALEN];
+		u16 channel;
+	} __attribute__ ((packed)) req;
+	const int atom_len = offsetof(struct prism2_scan_apinfo, atim);
+	struct prism2_scan_apinfo *atom;
+	int offset = 4;
+	int found = 0;
+	u8 *buf = NULL;
+	u16 len;
+
+	/* Allocate buffer for scan results */
+	buf = kmalloc(MAX_SCAN_LEN, GFP_KERNEL);
+	if (!buf)
+		return;
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return;
+
+	/* Sanity checks in case user changed something in the meantime */
+	if (!priv->bssid_fixed)
+		goto out;
+
+	if (strlen(priv->desired_essid) == 0)
+		goto out;
+
+	/* Read scan results from the firmware */
+	err = hermes_read_ltv(hw, USER_BAP,
+			      HERMES_RID_SCANRESULTSTABLE,
+			      MAX_SCAN_LEN, &len, buf);
+	if (err) {
+		printk(KERN_ERR "%s: Cannot read scan results\n",
+		       dev->name);
+		goto out;
+	}
+
+	len = HERMES_RECLEN_TO_BYTES(len);
+
+	/* Go through the scan results looking for the channel of the AP
+	 * we were requested to join */
+	for (; offset + atom_len <= len; offset += atom_len) {
+		atom = (struct prism2_scan_apinfo *) (buf + offset);
+		if (memcmp(&atom->bssid, priv->desired_bssid, ETH_ALEN) == 0) {
+			found = 1;
+			break;
+		}
+	}
+
+	if (!found) {
+		DEBUG(1, "%s: Requested AP not found in scan results\n",
+		      dev->name);
+		goto out;
+	}
+
+	memcpy(req.bssid, priv->desired_bssid, ETH_ALEN);
+	req.channel = atom->channel;	/* both are little-endian */
+	err = HERMES_WRITE_RECORD(hw, USER_BAP, HERMES_RID_CNFJOINREQUEST,
+				  &req);
+	if (err)
+		printk(KERN_ERR "%s: Error issuing join request\n", dev->name);
+
+ out:
+	if (buf)
+		kfree(buf);
+	orinoco_unlock(priv, &flags);
+}
+
 #if WIRELESS_EXT > 13
 /* Send new BSSID to userspace */
 static void orinoco_send_wevents(struct net_device *dev)
@@ -1553,6 +1627,15 @@
 
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
@@ -1565,7 +1648,82 @@
 		if (newstatus != priv->last_linkstatus) {
 			priv->last_linkstatus = newstatus;
 			print_linkstatus(dev, newstatus);
+#if WIRELESS_EXT > 13
+			/* The info frame contains only one word which is the
+			 * status (see hermes.h). The status is pretty boring
+			 * in itself, that's why we export the new BSSID...
+			 * Jean II */
+			schedule_work(&priv->wevent_work);
+#endif
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
+#if WIRELESS_EXT > 13
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
 		}
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
+
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
+#endif /* WIRELESS_EXT > 13 */
 	}
 	break;
 	case HERMES_INQ_SEC_STAT_AGERE:
@@ -2189,6 +2347,13 @@
 
 	orinoco_unlock(priv, &flags);
 
+	/* Scanning support: Cleanup of driver struct */
+	if (priv->scan_result != NULL) {
+		kfree(priv->scan_result);
+		priv->scan_result = NULL;
+	}
+	priv->scan_inprogress = 0;
+
 	if (priv->hard_reset) {
 		err = (*priv->hard_reset)(priv);
 		if (err) {
@@ -2428,6 +2593,7 @@
 		priv->has_mwo = (firmver >= 0x60000);
 		priv->has_pm = (firmver >= 0x40020); /* Don't work in 7.52 ? */
 		priv->ibss_port = 1;
+		priv->has_hostscan = (firmver >= 0x8000a);
 		priv->broken_monitor = (firmver >= 0x80000);
 
 		/* Tested with Agere firmware :
@@ -2474,6 +2640,8 @@
 		priv->ibss_port = 4;
 		priv->broken_disableport = (firmver == 0x25013) ||
 					   (firmver >= 0x30000 && firmver <= 0x31000);
+		priv->has_hostscan = (firmver >= 0x31001) ||
+				     (firmver >= 0x29057 && firmver < 0x30000);
 		/* Tested with Intel firmware : 0x20015 => Jean II */
 		/* Tested with 3Com firmware : 0x15012 & 0x22001 => Jean II */
 		break;
@@ -2493,6 +2661,7 @@
 		priv->has_ibss = (firmver >= 0x000700); /* FIXME */
 		priv->has_big_wep = priv->has_wep = (firmver >= 0x000800);
 		priv->has_pm = (firmver >= 0x000700);
+		priv->has_hostscan = (firmver >= 0x010301);
 
 		if (firmver >= 0x000800)
 			priv->ibss_port = 0;
@@ -2721,6 +2890,7 @@
 				   * before anything else touches the
 				   * hardware */
 	INIT_WORK(&priv->reset_work, (void (*)(void *))orinoco_reset, dev);
+	INIT_WORK(&priv->join_work, (void (*)(void *))orinoco_join_ap, dev);
 #if WIRELESS_EXT > 13
 	INIT_WORK(&priv->wevent_work, (void (*)(void *))orinoco_send_wevents, dev);
 #endif
@@ -2736,6 +2906,9 @@
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 
+	if (priv->scan_result)
+		kfree(priv->scan_result);
+
 	free_netdev(dev);
 }
 
@@ -4175,6 +4348,334 @@
 	return 0;
 }
 
+#if WIRELESS_EXT > 13
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
+#endif	/* WIRELESS_EXT > 13 */
+
 /* Commit handler, called after set operations */
 static int orinoco_ioctl_commit(struct net_device *dev,
 				struct iw_request_info *info,
@@ -4331,8 +4832,8 @@
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) NULL,				/* SIOCGIWAPLIST */
 #if WIRELESS_EXT > 13
-	(iw_handler) NULL,		/* SIOCSIWSCAN */
-	(iw_handler) NULL,		/* SIOCGIWSCAN */
+	(iw_handler) orinoco_ioctl_setscan,		/* SIOCSIWSCAN */
+	(iw_handler) orinoco_ioctl_getscan,		/* SIOCGIWSCAN */
 #else	/* WIRELESS_EXT > 13 */
 	(iw_handler) NULL,				/* SIOCSIWSCAN */
 	(iw_handler) NULL,				/* SIOCGIWSCAN */
--- a/drivers/net/wireless/orinoco.h	2004-10-26 13:35:27.978977432 -0400
+++ b/drivers/net/wireless/orinoco.h	2004-07-28 02:19:49.000000000 -0400
@@ -7,7 +7,7 @@
 #ifndef _ORINOCO_H
 #define _ORINOCO_H
 
-#define DRIVER_VERSION "0.13e"
+#define DRIVER_VERSION "0.15rc2HEAD"
 
 #include <linux/types.h>
 #include <linux/spinlock.h>
@@ -28,6 +29,8 @@
 #endif /* (! defined (WIRELESS_EXT)) || (WIRELESS_EXT < 11) */
 #define WIRELESS_SPY		// enable iwspy support
 
+#define MAX_SCAN_LEN 4096
+
 #define ORINOCO_MAX_KEY_SIZE	14
 #define ORINOCO_MAX_KEYS	4
 
@@ -103,6 +106,7 @@
 	unsigned int has_pm:1;
 	unsigned int has_preamble:1;
 	unsigned int has_sensitivity:1;
+	unsigned int has_hostscan:1;
 	unsigned int broken_disableport:1;
 	unsigned int broken_monitor:1;
 	unsigned int irq_no_disable:1;
@@ -131,6 +135,12 @@
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
