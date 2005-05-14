From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/12] orinoco: monitor mode support
Date: Sat, 14 May 2005 17:31:00 +0200
Message-ID: <20050514153100.GL3643@lst.de>
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
--- linux-2.6.orig/drivers/net/wireless/orinoco.c	2005-05-14 17:07:45.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.c	2005-05-14 17:08:39.000000000 +0200
@@ -499,6 +499,10 @@
 module_param(ignore_disconnect, int, 0644);
 MODULE_PARM_DESC(ignore_disconnect, "Don't report lost link to the network layer");
 
+static int force_monitor; /* = 0 */
+module_param(force_monitor, int, 0644);
+MODULE_PARM_DESC(force_monitor, "Allow monitor mode for all firmware versions");
+
 /********************************************************************/
 /* Compile time configuration and compatibility stuff               */
 /********************************************************************/
@@ -670,6 +674,10 @@
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
@@ -856,7 +864,7 @@
 		return 1;
 	}
 
-	if (! netif_carrier_ok(dev)) {
+	if (! netif_carrier_ok(dev) || (priv->iw_mode == IW_MODE_MONITOR)) {
 		/* Oops, the firmware hasn't established a connection,
                    silently drop the packet (this seems to be the
                    safest approach). */
@@ -1118,6 +1126,114 @@
 	}
 }
 
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
+	switch (fc & IEEE80211_FCTL_FTYPE) {
+	case IEEE80211_FTYPE_DATA:
+		if ((fc & IEEE80211_FCTL_TODS)
+		    && (fc & IEEE80211_FCTL_FROMDS))
+			hdrlen = 30;
+		else
+			hdrlen = 24;
+		datalen = len;
+		break;
+	case IEEE80211_FTYPE_MGMT:
+		hdrlen = 24;
+		datalen = len;
+		break;
+	case IEEE80211_FTYPE_CTL:
+		switch (fc & IEEE80211_FCTL_STYPE) {
+		case IEEE80211_STYPE_PSPOLL:
+		case IEEE80211_STYPE_RTS:
+		case IEEE80211_STYPE_CFEND:
+		case IEEE80211_STYPE_CFENDACK:
+			hdrlen = 16;
+			break;
+		case IEEE80211_STYPE_CTS:
+		case IEEE80211_STYPE_ACK:
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
+	if (datalen > IEEE80211_DATA_LEN + 12) {
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
 static void __orinoco_ev_rx(struct net_device *dev, hermes_t *hw)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
@@ -1143,16 +1259,24 @@
 
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
+		stats->rx_errors++;
+		goto drop;
+	}
 
+	/* Handle frames in monitor mode */
+	if (priv->iw_mode == IW_MODE_MONITOR) {
+		orinoco_rx_monitor(dev, rxfid, &desc);
+		return;
+	}
+
+	if (status & HERMES_RXSTAT_UNDECRYPTABLE) {
+		DEBUG(1, "%s: Undecryptable frame on Rx. Frame dropped.\n",
+		      dev->name);
+		wstats->discard.code++;
 		stats->rx_errors++;
 		goto drop;
 	}
@@ -2065,6 +2189,20 @@
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
@@ -2413,6 +2551,7 @@
 		priv->has_pm = (firmver >= 0x40020); /* Don't work in 7.52 ? */
 		priv->ibss_port = 1;
 		priv->has_hostscan = (firmver >= 0x8000a);
+		priv->broken_monitor = (firmver >= 0x80000);
 
 		/* Tested with Agere firmware :
 		 *	1.16 ; 4.08 ; 4.52 ; 6.04 ; 6.16 ; 7.28 => Jean II
@@ -2980,6 +3119,15 @@
 	case IW_MODE_INFRA:
 		break;
 
+	case IW_MODE_MONITOR:
+		if (priv->broken_monitor && !force_monitor) {
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
@@ -3355,11 +3503,9 @@
 	unsigned long flags;
 	int err = -EINPROGRESS;		/* Call commit handler */
 
-	/* We can only use this in Ad-Hoc demo mode to set the operating
-	 * frequency, or in IBSS mode to set the frequency where the IBSS
-	 * will be created - Jean II */
-	if (priv->iw_mode != IW_MODE_ADHOC)
-		return -EOPNOTSUPP;
+	/* In infrastructure mode the AP sets the channel */
+	if (priv->iw_mode == IW_MODE_INFRA)
+		return -EBUSY;
 
 	if ( (frq->e == 0) && (frq->m <= 1000) ) {
 		/* Setting by channel number */
@@ -3383,7 +3529,15 @@
 
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
+
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
Index: linux-2.6/drivers/net/wireless/orinoco.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/orinoco.h	2005-05-14 17:05:42.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.h	2005-05-14 17:07:57.000000000 +0200
@@ -94,6 +94,7 @@
 	unsigned int has_sensitivity:1;
 	unsigned int has_hostscan:1;
 	unsigned int broken_disableport:1;
+	unsigned int broken_monitor:1;
 
 	/* Configuration paramaters */
 	u32 iw_mode;
