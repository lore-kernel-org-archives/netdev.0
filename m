From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 7/9] orinoco: always use 802.11 header for rx processing
Date: Sun, 19 Jun 2005 01:28:02 +0200
Message-ID: <20050618232802.GH9918@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, proski@gnu.org, hermes@gibson.dropbear.id.au
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


If the frame has ToDS flag set, mark it by setting skb->pkt_type to
PACKET_OTHERHOST, so that applications unaware of promiscous mode won't get
uplink (STA->AP) packets for STA->STA transmissions relayed by the AP.
Thanks to John Denker and David Gibson for finding the problem and the
solution.

Patch from Pavel Roskin


Index: linux-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/orinoco.c	2005-06-19 01:03:51.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.c	2005-06-19 01:04:28.000000000 +0200
@@ -619,7 +619,9 @@
 	u16 ethertype;
 } __attribute__ ((packed));
 
+/* Rx frame header except compatibility 802.3 header */
 struct hermes_rx_descriptor {
+	/* Control */
 	u16 status;
 	u32 time;
 	u8 silence;
@@ -627,6 +629,18 @@
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
@@ -1110,12 +1124,10 @@
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
@@ -1140,24 +1152,14 @@
 			stats->rx_crc_errors++;
 			DEBUG(1, "%s: Bad CRC on Rx. Frame dropped.\n", dev->name);
 		}
-		stats->rx_errors++;
-		goto drop;
-	}
-
-	/* For now we ignore the 802.11 header completely, assuming
-           that the card's firmware has handled anything vital */
 
-	err = hermes_bap_pread(hw, IRQ_BAP, &hdr, sizeof(hdr),
-			       rxfid, HERMES_802_3_OFFSET);
-	if (err) {
-		printk(KERN_ERR "%s: error %d reading frame header. "
-		       "Frame dropped.\n", dev->name, err);
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
@@ -1186,57 +1188,51 @@
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
+	if (fc & IEEE80211_FCTL_FROMDS)
+		memcpy(hdr->h_source, desc.addr3, ETH_ALEN);
+	else
+		memcpy(hdr->h_source, desc.addr2, ETH_ALEN);
 
 	dev->last_rx = jiffies;
 	skb->dev = dev;
 	skb->protocol = eth_type_trans(skb, dev);
 	skb->ip_summed = CHECKSUM_NONE;
+	if (fc & IEEE80211_FCTL_TODS)
+		skb->pkt_type = PACKET_OTHERHOST;
 	
 	/* Process the wireless stats if needed */
 	orinoco_stat_gather(dev, skb, &desc);
@@ -1457,6 +1453,9 @@
 		u16 newstatus;
 		int connected;
 
+		if (priv->iw_mode == IW_MODE_MONITOR)
+			break;
+
 		if (len != sizeof(linkstatus)) {
 			printk(KERN_WARNING "%s: Unexpected size for linkstatus frame (%d bytes)\n",
 			       dev->name, len);
