From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 10/15] wireless/orinoco: Use wireless handlers
	rather than ioctl()s
Date: Tue, 26 Oct 2004 15:13:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098818025.3663.78.camel@dcbw.boston.redhat.com>
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

o Convert to use wireless handler API rather than ioctl() calls.
o Clean up the locking and return -EBUSY if we can't lock the device
o Move some of our driver private data into bitfields rather than 'int's
o Add more flexible get_rid() debug method in place of dump_recs

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco.c.10-wireless-handlers	2004-10-26 11:06:54.294063512 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-10-26 12:55:37.443394080 -0400
@@ -495,6 +495,9 @@
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#if WIRELESS_EXT > 12
+#include <net/iw_handler.h>
+#endif	/* WIRELESS_EXT > 12 */
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -569,6 +572,12 @@
 				 | HERMES_EV_WTERR | HERMES_EV_INFO \
 				 | HERMES_EV_INFDROP )
 
+#define MAX_RID_LEN 1024
+
+#if WIRELESS_EXT > 12
+static const struct iw_handler_def orinoco_handler_def;
+#endif
+
 /********************************************************************/
 /* Data tables                                                      */
 /********************************************************************/
@@ -676,9 +685,8 @@
 	unsigned long flags;
 	int err;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	err = __orinoco_up(dev);
 
@@ -721,7 +729,7 @@
 	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	struct iw_statistics *wstats = &priv->wstats;
-	int err = 0;
+	int err;
 	unsigned long flags;
 
 	if (! netif_device_present(dev)) {
@@ -730,10 +738,17 @@
 		return NULL; /* FIXME: Can we do better than this? */
 	}
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return NULL; /* FIXME: Erg, we've been signalled, how
-			      * do we propagate this back up? */
+	/* If busy, return the old stats.  Returning NULL may cause
+	 * the interface to disappear from /proc/net/wireless */
+	if (orinoco_lock(priv, &flags) != 0)
+		return wstats;
+
+	/* We can't really wait for the tallies inquiry command to
+	 * complete, so we just use the previous results and trigger
+	 * a new tallies inquiry command for next time - Jean II */
+	/* FIXME: We're in user context (I think?), so we should just
+           wait for the tallies to come through */
+	hermes_inquire(hw, HERMES_INQ_TALLIES);
 
 	if (priv->iw_mode == IW_MODE_ADHOC) {
 		memset(&wstats->qual, 0, sizeof(wstats->qual));
@@ -752,25 +767,16 @@
 
 		err = HERMES_READ_RECORD(hw, USER_BAP,
 					 HERMES_RID_COMMSQUALITY, &cq);
-		
-		wstats->qual.qual = (int)le16_to_cpu(cq.qual);
-		wstats->qual.level = (int)le16_to_cpu(cq.signal) - 0x95;
-		wstats->qual.noise = (int)le16_to_cpu(cq.noise) - 0x95;
-		wstats->qual.updated = 7;
+
+		if (!err) {
+			wstats->qual.qual = (int)le16_to_cpu(cq.qual);
+			wstats->qual.level = (int)le16_to_cpu(cq.signal) - 0x95;
+			wstats->qual.noise = (int)le16_to_cpu(cq.noise) - 0x95;
+			wstats->qual.updated = 7;
+		}
 	}
 
-	/* We can't really wait for the tallies inquiry command to
-	 * complete, so we just use the previous results and trigger
-	 * a new tallies inquiry command for next time - Jean II */
-	/* FIXME: We're in user context (I think?), so we should just
-           wait for the tallies to come through */
-	err = hermes_inquire(hw, HERMES_INQ_TALLIES);
-               
 	orinoco_unlock(priv, &flags);
-
-	if (err)
-		return NULL;
-		
 	return wstats;
 }
 
@@ -1493,55 +1499,76 @@
 	return err;
 }
 
-static int __orinoco_hw_setup_wep(struct orinoco_private *priv)
+/* Set fixed AP address */
+static int __orinoco_hw_set_wap(struct orinoco_private *priv)
+{
+	int roaming_flag;
+	int err = 0;
+	hermes_t *hw = &priv->hw;
+
+	switch (priv->firmware_type) {
+	case FIRMWARE_TYPE_AGERE:
+		/* not supported */
+		break;
+	case FIRMWARE_TYPE_INTERSIL:
+		if (priv->bssid_fixed)
+			roaming_flag = 2;
+		else
+			roaming_flag = 1;
+
+		err = hermes_write_wordrec(hw, USER_BAP,
+					   HERMES_RID_CNFROAMINGMODE,
+					   roaming_flag);
+		break;
+	case FIRMWARE_TYPE_SYMBOL:
+		err = HERMES_WRITE_RECORD(hw, USER_BAP,
+					  HERMES_RID_CNFMANDATORYBSSID_SYMBOL,
+					  &priv->desired_bssid);
+		break;
+	}
+	return err;
+}
+
+/* Change the WEP keys and/or the current keys.  Can be called
+ * either from __orinoco_hw_setup_wep() or directly from
+ * orinoco_ioctl_setiwencode().  In the later case the association
+ * with the AP is not broken (if the firmware can handle it),
+ * which is needed for 802.1x implementations. */
+static int __orinoco_hw_setup_wepkeys(struct orinoco_private *priv)
 {
 	hermes_t *hw = &priv->hw;
 	int err = 0;
-	int	master_wep_flag;
-	int	auth_flag;
 
 	switch (priv->firmware_type) {
-	case FIRMWARE_TYPE_AGERE: /* Agere style WEP */
-		if (priv->wep_on) {
-			err = hermes_write_wordrec(hw, USER_BAP,
-						   HERMES_RID_CNFTXKEY_AGERE,
-						   priv->tx_key);
-			if (err)
-				return err;
-			
-			err = HERMES_WRITE_RECORD(hw, USER_BAP,
-						  HERMES_RID_CNFWEPKEYS_AGERE,
-						  &priv->keys);
-			if (err)
-				return err;
-		}
+	case FIRMWARE_TYPE_AGERE:
+		err = HERMES_WRITE_RECORD(hw, USER_BAP,
+					  HERMES_RID_CNFWEPKEYS_AGERE,
+					  &priv->keys);
+		if (err)
+			return err;
 		err = hermes_write_wordrec(hw, USER_BAP,
-					   HERMES_RID_CNFWEPENABLED_AGERE,
-					   priv->wep_on);
+					   HERMES_RID_CNFTXKEY_AGERE,
+					   priv->tx_key);
 		if (err)
 			return err;
 		break;
-
-	case FIRMWARE_TYPE_INTERSIL: /* Intersil style WEP */
-	case FIRMWARE_TYPE_SYMBOL: /* Symbol style WEP */
-		master_wep_flag = 0;		/* Off */
-		if (priv->wep_on) {
+	case FIRMWARE_TYPE_INTERSIL:
+	case FIRMWARE_TYPE_SYMBOL:
+		{
 			int keylen;
 			int i;
 
-			/* Fudge around firmware weirdness */
+			/* Force uniform key length to work around firmware bugs */
 			keylen = le16_to_cpu(priv->keys[priv->tx_key].len);
 			
+			if (keylen > LARGE_KEY_SIZE) {
+				printk(KERN_ERR "%s: BUG: Key %d has oversize length %d.\n",
+				       priv->ndev->name, priv->tx_key, keylen);
+				return -E2BIG;
+			}
+
 			/* Write all 4 keys */
 			for(i = 0; i < ORINOCO_MAX_KEYS; i++) {
-/*  				int keylen = le16_to_cpu(priv->keys[i].len); */
-				
-				if (keylen > LARGE_KEY_SIZE) {
-					printk(KERN_ERR "%s: BUG: Key %d has oversize length %d.\n",
-					       priv->ndev->name, i, keylen);
-					return -E2BIG;
-				}
-
 				err = hermes_write_ltv(hw, USER_BAP,
 						       HERMES_RID_CNFDEFAULTKEY0 + i,
 						       HERMES_BYTES_TO_RECLEN(keylen),
@@ -1556,27 +1583,60 @@
 						   priv->tx_key);
 			if (err)
 				return err;
-			
-			if (priv->wep_restrict) {
-				auth_flag = 2;
-				master_wep_flag = 3;
-			} else {
-				/* Authentication is where Intersil and Symbol
-				 * firmware differ... */
-				auth_flag = 1;
-				if (priv->firmware_type == FIRMWARE_TYPE_SYMBOL)
-					master_wep_flag = 3; /* Symbol */ 
-				else 
-					master_wep_flag = 1; /* Intersil */
-			}
+		}
+		break;
+	}
+
+	return 0;
+}
+
+static int __orinoco_hw_setup_wep(struct orinoco_private *priv)
+{
+	hermes_t *hw = &priv->hw;
+	int err = 0;
+	int master_wep_flag;
+	int auth_flag;
+
+	if (priv->wep_on)
+		__orinoco_hw_setup_wepkeys(priv);
+
+	if (priv->wep_restrict)
+		auth_flag = HERMES_AUTH_SHARED_KEY;
+	else
+		auth_flag = HERMES_AUTH_OPEN;
+
+	switch (priv->firmware_type) {
+	case FIRMWARE_TYPE_AGERE: /* Agere style WEP */
+		if (priv->wep_on) {
+			/* Enable the shared-key authentication. */
+			err = hermes_write_wordrec(hw, USER_BAP,
+						   HERMES_RID_CNFAUTHENTICATION_AGERE,
+						   auth_flag);
+		}
+		err = hermes_write_wordrec(hw, USER_BAP,
+					   HERMES_RID_CNFWEPENABLED_AGERE,
+					   priv->wep_on);
+		if (err)
+			return err;
+		break;
 
+	case FIRMWARE_TYPE_INTERSIL: /* Intersil style WEP */
+	case FIRMWARE_TYPE_SYMBOL: /* Symbol style WEP */
+		if (priv->wep_on) {
+			if (priv->wep_restrict ||
+			    (priv->firmware_type == FIRMWARE_TYPE_SYMBOL))
+				master_wep_flag = HERMES_WEP_PRIVACY_INVOKED |
+						  HERMES_WEP_EXCL_UNENCRYPTED;
+			else
+				master_wep_flag = HERMES_WEP_PRIVACY_INVOKED;
 
 			err = hermes_write_wordrec(hw, USER_BAP,
 						   HERMES_RID_CNFAUTHENTICATION,
 						   auth_flag);
 			if (err)
 				return err;
-		}
+		} else
+			master_wep_flag = 0;
 
 		/* Master WEP setting : on/off */
 		err = hermes_write_wordrec(hw, USER_BAP,
@@ -1586,13 +1646,6 @@
 			return err;	
 
 		break;
-
-	default:
-		if (priv->wep_on) {
-			printk(KERN_ERR "%s: WEP enabled, although not supported!\n",
-			       priv->ndev->name);
-			return -EINVAL;
-		}
 	}
 
 	return 0;
@@ -1623,38 +1676,49 @@
 		return err;
 	}
 	/* Set the channel/frequency */
-	if (priv->channel == 0) {
-		printk(KERN_DEBUG "%s: Channel is 0 in __orinoco_program_rids()\n", dev->name);
-		if (priv->createibss)
-			priv->channel = 10;
-	}
-	err = hermes_write_wordrec(hw, USER_BAP, HERMES_RID_CNFOWNCHANNEL,
-				   priv->channel);
-	if (err) {
-		printk(KERN_ERR "%s: Error %d setting channel\n",
-		       dev->name, err);
-		return err;
-	}
-
-	if (priv->has_ibss) {
+	if (priv->channel != 0 && priv->iw_mode != IW_MODE_INFRA) {
 		err = hermes_write_wordrec(hw, USER_BAP,
-					   HERMES_RID_CNFCREATEIBSS,
-					   priv->createibss);
+					   HERMES_RID_CNFOWNCHANNEL,
+					   priv->channel);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d setting CREATEIBSS\n", dev->name, err);
+			printk(KERN_ERR "%s: Error %d setting channel %d\n",
+			       dev->name, err, priv->channel);
 			return err;
 		}
+	}
+
+	if (priv->has_ibss) {
+		u16 createibss;
 
-		if ((strlen(priv->desired_essid) == 0) && (priv->createibss)
-		   && (!priv->has_ibss_any)) {
+		if ((strlen(priv->desired_essid) == 0) && (priv->createibss)) {
 			printk(KERN_WARNING "%s: This firmware requires an "
 			       "ESSID in IBSS-Ad-Hoc mode.\n", dev->name);
 			/* With wvlan_cs, in this case, we would crash.
 			 * hopefully, this driver will behave better...
 			 * Jean II */
+			createibss = 0;
+		} else {
+			createibss = priv->createibss;
+		}
+		
+		err = hermes_write_wordrec(hw, USER_BAP,
+					   HERMES_RID_CNFCREATEIBSS,
+					   createibss);
+		if (err) {
+			printk(KERN_ERR "%s: Error %d setting CREATEIBSS\n",
+			       dev->name, err);
+			return err;
 		}
 	}
 
+	/* Set the desired BSSID */
+	err = __orinoco_hw_set_wap(priv);
+	if (err) {
+		printk(KERN_ERR "%s: Error %d setting AP address\n",
+		       dev->name, err);
+		return err;
+	}
+
 	/* Set the desired ESSID */
 	idbuf.len = cpu_to_le16(strlen(priv->desired_essid));
 	memcpy(&idbuf.val, priv->desired_essid, sizeof(idbuf.val));
@@ -1869,57 +1933,6 @@
 		dev->flags &= ~IFF_PROMISC;
 }
 
-static int orinoco_reconfigure(struct net_device *dev)
-{
-	struct orinoco_private *priv = netdev_priv(dev);
-	struct hermes *hw = &priv->hw;
-	unsigned long flags;
-	int err = 0;
-
-	if (priv->broken_disableport) {
-		schedule_work(&priv->reset_work);
-		return 0;
-	}
-
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
-
-		
-	err = hermes_disable_port(hw, 0);
-	if (err) {
-		printk(KERN_WARNING "%s: Unable to disable port while reconfiguring card\n",
-		       dev->name);
-		priv->broken_disableport = 1;
-		goto out;
-	}
-
-	err = __orinoco_program_rids(dev);
-	if (err) {
-		printk(KERN_WARNING "%s: Unable to reconfigure card\n",
-		       dev->name);
-		goto out;
-	}
-
-	err = hermes_enable_port(hw, 0);
-	if (err) {
-		printk(KERN_WARNING "%s: Unable to enable port while reconfiguring card\n",
-		       dev->name);
-		goto out;
-	}
-
- out:
-	if (err) {
-		printk(KERN_WARNING "%s: Resetting instead...\n", dev->name);
-		schedule_work(&priv->reset_work);
-		err = 0;
-	}
-
-	orinoco_unlock(priv, &flags);
-	return err;
-
-}
-
 /* This must be called from user context, without locks held - use
  * schedule_work() */
 static void orinoco_reset(struct net_device *dev)
@@ -1929,8 +1942,7 @@
 	int err;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
+	if (orinoco_lock(priv, &flags) != 0)
 		/* When the hardware becomes available again, whatever
 		 * detects that is responsible for re-initializing
 		 * it. So no need for anything further */
@@ -1949,20 +1961,20 @@
 
 	orinoco_unlock(priv, &flags);
 
-	if (priv->hard_reset)
+	if (priv->hard_reset) {
 		err = (*priv->hard_reset)(priv);
-	if (err) {
-		printk(KERN_ERR "%s: orinoco_reset: Error %d "
-		       "performing  hard reset\n", dev->name, err);
-		/* FIXME: shutdown of some sort */
-		return;
+		if (err) {
+			printk(KERN_ERR "%s: orinoco_reset: Error %d "
+			       "performing hard reset\n", dev->name, err);
+			goto disable;
+		}
 	}
 
 	err = orinoco_reinit_firmware(dev);
 	if (err) {
 		printk(KERN_ERR "%s: orinoco_reset: Error %d re-initializing firmware\n",
 		       dev->name, err);
-		return;
+		goto disable;
 	}
 
 	orinoco_spin_lock(priv); /* This has to be called from user context */
@@ -1983,6 +1995,11 @@
 	orinoco_spin_unlock(priv);
 
 	return;
+
+ disable:
+	hermes_set_irqmask(hw, 0);
+	netif_device_detach(dev);
+	printk(KERN_ERR "%s: Device has been disabled!\n", dev->name);
 }
 
 /********************************************************************/
@@ -2133,7 +2150,6 @@
 	priv->has_preamble = 0;
 	priv->has_port3 = 1;
 	priv->has_ibss = 1;
-	priv->has_ibss_any = 0;
 	priv->has_wep = 0;
 	priv->has_big_wep = 0;
 
@@ -2149,7 +2165,6 @@
 		firmver = ((unsigned long)sta_id.major << 16) | sta_id.minor;
 
 		priv->has_ibss = (firmver >= 0x60006);
-		priv->has_ibss_any = (firmver >= 0x60010);
 		priv->has_wep = (firmver >= 0x40020);
 		priv->has_big_wep = 1; /* FIXME: this is wrong - how do we tell
 					  Gold cards from the others? */
@@ -2426,7 +2441,7 @@
 	priv = netdev_priv(dev);
 	priv->ndev = dev;
 	if (sizeof_card)
-		priv->card = (void *)((unsigned long)netdev_priv(dev)
+		priv->card = (void *)((unsigned long)priv
 				      + sizeof(struct orinoco_private));
 	else
 		priv->card = NULL;
@@ -2438,6 +2453,9 @@
 	dev->watchdog_timeo = HZ; /* 1 second timeout */
 	dev->get_stats = orinoco_get_stats;
 	dev->get_wireless_stats = orinoco_get_wireless_stats;
+#if WIRELESS_EXT > 12
+	dev->wireless_handlers = (struct iw_handler_def *)&orinoco_handler_def;
+#endif
 	dev->do_ioctl = orinoco_ioctl;
 	dev->change_mtu = orinoco_change_mtu;
 	dev->set_multicast_list = orinoco_set_multicast_list;
@@ -2473,25 +2491,6 @@
 /* Wireless extensions                                              */
 /********************************************************************/
 
-static int orinoco_hw_get_bssid(struct orinoco_private *priv,
-				char buf[ETH_ALEN])
-{
-	hermes_t *hw = &priv->hw;
-	int err = 0;
-	unsigned long flags;
-
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
-
-	err = hermes_read_ltv(hw, USER_BAP, HERMES_RID_CURRENTBSSID,
-			      ETH_ALEN, NULL, buf);
-
-	orinoco_unlock(priv, &flags);
-
-	return err;
-}
-
 static int orinoco_hw_get_essid(struct orinoco_private *priv, int *active,
 				char buf[IW_ESSID_MAX_SIZE+1])
 {
@@ -2502,9 +2501,8 @@
 	int len;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	if (strlen(priv->desired_essid) > 0) {
 		/* We read the desired SSID from the hardware rather
@@ -2535,6 +2533,7 @@
 	}
 
 	len = le16_to_cpu(essidbuf.len);
+	BUG_ON(len > IW_ESSID_MAX_SIZE);
 
 	memset(buf, 0, IW_ESSID_MAX_SIZE+1);
 	memcpy(buf, p, len);
@@ -2555,9 +2554,8 @@
 	long freq = 0;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	
 	err = hermes_read_wordrec(hw, USER_BAP, HERMES_RID_CURRENTCHANNEL, &channel);
 	if (err)
@@ -2597,9 +2595,8 @@
 	int i;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	err = hermes_read_ltv(hw, USER_BAP, HERMES_RID_SUPPORTEDDATARATES,
 			      sizeof(list), NULL, &list);
@@ -2619,143 +2616,265 @@
 	return 0;
 }
 
-static int orinoco_ioctl_getiwrange(struct net_device *dev, struct iw_point *rrq)
+static int orinoco_ioctl_getname(struct net_device *dev,
+				 struct iw_request_info *info,
+				 char *name,
+				 char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int err = 0;
-	int mode;
-	struct iw_range range;
 	int numrates;
-	int i, k;
-	unsigned long flags;
-
-	TRACE_ENTER(dev->name);
-
-	err = verify_area(VERIFY_WRITE, rrq->pointer, sizeof(range));
-	if (err)
-		return err;
+	int err;
 
-	rrq->length = sizeof(range);
+	err = orinoco_hw_get_bitratelist(priv, &numrates, NULL, 0);
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (!err && (numrates > 2))
+		strcpy(name, "IEEE 802.11b");
+	else
+		strcpy(name, "IEEE 802.11-DS");
 
-	mode = priv->iw_mode;
-	orinoco_unlock(priv, &flags);
+	return 0;
+}
 
-	memset(&range, 0, sizeof(range));
+static int orinoco_ioctl_setwap(struct net_device *dev,
+				struct iw_request_info *info,
+				struct sockaddr *ap_addr,
+				char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int err = -EINPROGRESS;		/* Call commit handler */
+	unsigned long flags;
+	static const u8 off_addr[] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
+	static const u8 any_addr[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 
-	/* Much of this shamelessly taken from wvlan_cs.c. No idea
-	 * what it all means -dgibson */
-	range.we_version_compiled = WIRELESS_EXT;
-	range.we_version_source = 11;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
-	range.min_nwid = range.max_nwid = 0; /* We don't use nwids */
+	/* Enable automatic roaming - no sanity checks are needed */
+	if (memcmp(&ap_addr->sa_data, off_addr, ETH_ALEN) == 0 ||
+	    memcmp(&ap_addr->sa_data, any_addr, ETH_ALEN) == 0) {
+		priv->bssid_fixed = 0;
+		memset(priv->desired_bssid, 0, ETH_ALEN);
 
-	/* Set available channels/frequencies */
-	range.num_channels = NUM_CHANNELS;
-	k = 0;
-	for (i = 0; i < NUM_CHANNELS; i++) {
-		if (priv->channel_mask & (1 << i)) {
-			range.freq[k].i = i + 1;
-			range.freq[k].m = channel_frequency[i] * 100000;
-			range.freq[k].e = 1;
-			k++;
+		/* "off" means keep existing connection */
+		if (ap_addr->sa_data[0] == 0) {
+			__orinoco_hw_set_wap(priv);
+			err = 0;
 		}
-		
-		if (k >= IW_MAX_FREQUENCIES)
-			break;
+		goto out;
 	}
-	range.num_frequency = k;
 
-	range.sensitivity = 3;
+	if (priv->firmware_type == FIRMWARE_TYPE_AGERE) {
+		printk(KERN_WARNING "%s: Lucent/Agere firmware doesn't "
+		       "support manual roaming\n",
+		       dev->name);
+		err = -EOPNOTSUPP;
+		goto out;
+	}
 
-	if ((mode == IW_MODE_ADHOC) && (priv->spy_number == 0)){
-		/* Quality stats meaningless in ad-hoc mode */
-		range.max_qual.qual = 0;
-		range.max_qual.level = 0;
-		range.max_qual.noise = 0;
-		range.avg_qual.qual = 0;
-		range.avg_qual.level = 0;
-		range.avg_qual.noise = 0;
-	} else {
-		range.max_qual.qual = 0x8b - 0x2f;
-		range.max_qual.level = 0x2f - 0x95 - 1;
-		range.max_qual.noise = 0x2f - 0x95 - 1;
-		/* Need to get better values */
-		range.avg_qual.qual = 0x24;
-		range.avg_qual.level = 0xC2;
-		range.avg_qual.noise = 0x9E;
+	if (priv->iw_mode != IW_MODE_INFRA) {
+		printk(KERN_WARNING "%s: Manual roaming supported only in "
+		       "managed mode\n", dev->name);
+		err = -EOPNOTSUPP;
+		goto out;
 	}
 
-	err = orinoco_hw_get_bitratelist(priv, &numrates,
-					 range.bitrate, IW_MAX_BITRATES);
-	if (err)
-		return err;
-	range.num_bitrates = numrates;
-	
-	/* Set an indication of the max TCP throughput in bit/s that we can
-	 * expect using this interface. May be use for QoS stuff...
-	 * Jean II */
-	if(numrates > 2)
-		range.throughput = 5 * 1000 * 1000;	/* ~5 Mb/s */
-	else
-		range.throughput = 1.5 * 1000 * 1000;	/* ~1.5 Mb/s */
+	/* Intersil firmware hangs without Desired ESSID */
+	if (priv->firmware_type == FIRMWARE_TYPE_INTERSIL &&
+	    strlen(priv->desired_essid) == 0) {
+		printk(KERN_WARNING "%s: Desired ESSID must be set for "
+		       "manual roaming\n", dev->name);
+		err = -EOPNOTSUPP;
+		goto out;
+	}
 
-	range.min_rts = 0;
-	range.max_rts = 2347;
-	range.min_frag = 256;
-	range.max_frag = 2346;
+	/* Finally, enable manual roaming */
+	priv->bssid_fixed = 1;
+	memcpy(priv->desired_bssid, &ap_addr->sa_data, ETH_ALEN);
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
-	if (priv->has_wep) {
-		range.max_encoding_tokens = ORINOCO_MAX_KEYS;
+ out:
+	orinoco_unlock(priv, &flags);
+	return err;
+}
+
+static int orinoco_ioctl_getwap(struct net_device *dev,
+				struct iw_request_info *info,
+				struct sockaddr *ap_addr,
+				char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+
+	hermes_t *hw = &priv->hw;
+	int err = 0;
+	unsigned long flags;
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
+	ap_addr->sa_family = ARPHRD_ETHER;
+	err = hermes_read_ltv(hw, USER_BAP, HERMES_RID_CURRENTBSSID,
+			      ETH_ALEN, NULL, ap_addr->sa_data);
+
+	orinoco_unlock(priv, &flags);
+
+	return err;
+}
+
+static int orinoco_ioctl_setmode(struct net_device *dev,
+				 struct iw_request_info *info,
+				 u32 *mode,
+				 char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int err = -EINPROGRESS;		/* Call commit handler */
+	unsigned long flags;
+
+	if (priv->iw_mode == *mode)
+		return 0;
 
-		range.encoding_size[0] = SMALL_KEY_SIZE;
-		range.num_encoding_sizes = 1;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
+	switch (*mode) {
+	case IW_MODE_ADHOC:
+		if (!priv->has_ibss && !priv->has_port3)
+			err = -EOPNOTSUPP;
+		break;
+
+	case IW_MODE_INFRA:
+		break;
+
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	if (err == -EINPROGRESS) {
+		priv->iw_mode = *mode;
+		set_port_type(priv);
+	}
+
+	orinoco_unlock(priv, &flags);
+
+	return err;
+}
+
+static int orinoco_ioctl_getmode(struct net_device *dev,
+				 struct iw_request_info *info,
+				 u32 *mode,
+				 char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+
+	*mode = priv->iw_mode;
+	return 0;
+}
+
+
+static int orinoco_ioctl_getiwrange(struct net_device *dev,
+				    struct iw_request_info *info,
+				    struct iw_point *rrq,
+				    char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int err = 0;
+	struct iw_range *range = (struct iw_range *) extra;
+	int numrates;
+	int i, k;
+
+	TRACE_ENTER(dev->name);
+
+	rrq->length = sizeof(struct iw_range);
+	memset(range, 0, sizeof(struct iw_range));
+
+	range->we_version_compiled = WIRELESS_EXT;
+	range->we_version_source = 14;
+
+	/* Set available channels/frequencies */
+	range->num_channels = NUM_CHANNELS;
+	k = 0;
+	for (i = 0; i < NUM_CHANNELS; i++) {
+		if (priv->channel_mask & (1 << i)) {
+			range->freq[k].i = i + 1;
+			range->freq[k].m = channel_frequency[i] * 100000;
+			range->freq[k].e = 1;
+			k++;
+		}
+		
+		if (k >= IW_MAX_FREQUENCIES)
+			break;
+	}
+	range->num_frequency = k;
+	range->sensitivity = 3;
+
+	if (priv->has_wep) {
+		range->max_encoding_tokens = ORINOCO_MAX_KEYS;
+		range->encoding_size[0] = SMALL_KEY_SIZE;
+		range->num_encoding_sizes = 1;
 
 		if (priv->has_big_wep) {
-			range.encoding_size[1] = LARGE_KEY_SIZE;
-			range.num_encoding_sizes = 2;
+			range->encoding_size[1] = LARGE_KEY_SIZE;
+			range->num_encoding_sizes = 2;
 		}
+	}
+
+	if ((priv->iw_mode == IW_MODE_ADHOC) && (priv->spy_number == 0)){
+		/* Quality stats meaningless in ad-hoc mode */
 	} else {
-		range.num_encoding_sizes = 0;
-		range.max_encoding_tokens = 0;
+		range->max_qual.qual = 0x8b - 0x2f;
+		range->max_qual.level = 0x2f - 0x95 - 1;
+		range->max_qual.noise = 0x2f - 0x95 - 1;
+#if WIRELESS_EXT > 11
+		/* Need to get better values */
+		range->avg_qual.qual = 0x24;
+		range->avg_qual.level = 0xC2;
+		range->avg_qual.noise = 0x9E;
+#endif /* WIRELESS_EXT > 11 */
 	}
-	orinoco_unlock(priv, &flags);
-		
-	range.min_pmp = 0;
-	range.max_pmp = 65535000;
-	range.min_pmt = 0;
-	range.max_pmt = 65535 * 1000;	/* ??? */
-	range.pmp_flags = IW_POWER_PERIOD;
-	range.pmt_flags = IW_POWER_TIMEOUT;
-	range.pm_capa = IW_POWER_PERIOD | IW_POWER_TIMEOUT | IW_POWER_UNICAST_R;
-
-	range.num_txpower = 1;
-	range.txpower[0] = 15; /* 15dBm */
-	range.txpower_capa = IW_TXPOW_DBM;
-
-	range.retry_capa = IW_RETRY_LIMIT | IW_RETRY_LIFETIME;
-	range.retry_flags = IW_RETRY_LIMIT;
-	range.r_time_flags = IW_RETRY_LIFETIME;
-	range.min_retry = 0;
-	range.max_retry = 65535;	/* ??? */
-	range.min_r_time = 0;
-	range.max_r_time = 65535 * 1000;	/* ??? */
 
-	if (copy_to_user(rrq->pointer, &range, sizeof(range)))
-		return -EFAULT;
+	err = orinoco_hw_get_bitratelist(priv, &numrates,
+					 range->bitrate, IW_MAX_BITRATES);
+	if (err)
+		return err;
+	range->num_bitrates = numrates;
+
+	/* Set an indication of the max TCP throughput in bit/s that we can
+	 * expect using this interface. May be use for QoS stuff...
+	 * Jean II */
+	if (numrates > 2)
+		range->throughput = 5 * 1000 * 1000;	/* ~5 Mb/s */
+	else
+		range->throughput = 1.5 * 1000 * 1000;	/* ~1.5 Mb/s */
+
+	range->min_rts = 0;
+	range->max_rts = 2347;
+	range->min_frag = 256;
+	range->max_frag = 2346;
+
+	range->min_pmp = 0;
+	range->max_pmp = 65535000;
+	range->min_pmt = 0;
+	range->max_pmt = 65535 * 1000;	/* ??? */
+	range->pmp_flags = IW_POWER_PERIOD;
+	range->pmt_flags = IW_POWER_TIMEOUT;
+	range->pm_capa = IW_POWER_PERIOD | IW_POWER_TIMEOUT | IW_POWER_UNICAST_R;
+
+	range->retry_capa = IW_RETRY_LIMIT | IW_RETRY_LIFETIME;
+	range->retry_flags = IW_RETRY_LIMIT;
+	range->r_time_flags = IW_RETRY_LIFETIME;
+	range->min_retry = 0;
+	range->max_retry = 65535;	/* ??? */
+	range->min_r_time = 0;
+	range->max_r_time = 65535 * 1000;	/* ??? */
 
 	TRACE_EXIT(dev->name);
 
 	return 0;
 }
 
-static int orinoco_ioctl_setiwencode(struct net_device *dev, struct iw_point *erq)
+static int orinoco_ioctl_setiwencode(struct net_device *dev,
+				     struct iw_request_info *info,
+				     struct iw_point *erq,
+				     char *keybuf)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int index = (erq->flags & IW_ENCODE_INDEX) - 1;
@@ -2763,35 +2882,25 @@
 	int enable = priv->wep_on;
 	int restricted = priv->wep_restrict;
 	u16 xlen = 0;
-	int err = 0;
-	char keybuf[ORINOCO_MAX_KEY_SIZE];
+	int err = -EINPROGRESS;		/* Call commit handler */
 	unsigned long flags;
 	
+	if (! priv->has_wep)
+		return -EOPNOTSUPP;
+
 	if (erq->pointer) {
-		/* We actually have a key to set */
-		if ( (erq->length < SMALL_KEY_SIZE) || (erq->length > ORINOCO_MAX_KEY_SIZE) )
-			return -EINVAL;
-		
-		if (copy_from_user(keybuf, erq->pointer, erq->length))
-			return -EFAULT;
+		/* We actually have a key to set - check its length */
+		if (erq->length > LARGE_KEY_SIZE)
+			return -E2BIG;
+
+		if ( (erq->length > SMALL_KEY_SIZE) && !priv->has_big_wep )
+			return -E2BIG;
 	}
 	
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	
 	if (erq->pointer) {
-		if (erq->length > ORINOCO_MAX_KEY_SIZE) {
-			err = -E2BIG;
-			goto out;
-		}
-		
-		if ( (erq->length > LARGE_KEY_SIZE)
-		     || ( ! priv->has_big_wep && (erq->length > SMALL_KEY_SIZE))  ) {
-			err = -EINVAL;
-			goto out;
-		}
-		
 		if ((index < 0) || (index >= ORINOCO_MAX_KEYS))
 			index = priv->tx_key;
 
@@ -2829,7 +2938,6 @@
 	
 	if (erq->flags & IW_ENCODE_DISABLED)
 		enable = 0;
-	/* Only for Prism2 & Symbol cards (so far) - Jean II */
 	if (erq->flags & IW_ENCODE_OPEN)
 		restricted = 0;
 	if (erq->flags & IW_ENCODE_RESTRICTED)
@@ -2842,6 +2950,15 @@
 		memcpy(priv->keys[index].data, keybuf, erq->length);
 	}
 	priv->tx_key = setindex;
+
+	/* Try fast key change if connected and only keys are changed */
+	if (priv->wep_on && enable && (priv->wep_restrict == restricted) &&
+	    netif_carrier_ok(dev)) {
+		err = __orinoco_hw_setup_wepkeys(priv);
+		/* No need to commit if successful */
+		goto out;
+	}
+
 	priv->wep_on = enable;
 	priv->wep_restrict = restricted;
 
@@ -2851,18 +2968,21 @@
 	return err;
 }
 
-static int orinoco_ioctl_getiwencode(struct net_device *dev, struct iw_point *erq)
+static int orinoco_ioctl_getiwencode(struct net_device *dev,
+				     struct iw_request_info *info,
+				     struct iw_point *erq,
+				     char *keybuf)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int index = (erq->flags & IW_ENCODE_INDEX) - 1;
 	u16 xlen = 0;
-	char keybuf[ORINOCO_MAX_KEY_SIZE];
-	int err;
 	unsigned long flags;
-	
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+
+	if (! priv->has_wep)
+		return -EOPNOTSUPP;
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	if ((index < 0) || (index >= ORINOCO_MAX_KEYS))
 		index = priv->tx_key;
@@ -2872,69 +2992,60 @@
 		erq->flags |= IW_ENCODE_DISABLED;
 	erq->flags |= index + 1;
 	
-	/* Only for symbol cards - Jean II */
-	if (priv->firmware_type != FIRMWARE_TYPE_AGERE) {
-		if(priv->wep_restrict)
-			erq->flags |= IW_ENCODE_RESTRICTED;
-		else
-			erq->flags |= IW_ENCODE_OPEN;
-	}
+	if (priv->wep_restrict)
+		erq->flags |= IW_ENCODE_RESTRICTED;
+	else
+		erq->flags |= IW_ENCODE_OPEN;
 
 	xlen = le16_to_cpu(priv->keys[index].len);
 
 	erq->length = xlen;
 
-	if (erq->pointer) {
-		memcpy(keybuf, priv->keys[index].data, ORINOCO_MAX_KEY_SIZE);
-	}
-	
-	orinoco_unlock(priv, &flags);
+	memcpy(keybuf, priv->keys[index].data, ORINOCO_MAX_KEY_SIZE);
 
-	if (erq->pointer) {
-		if (copy_to_user(erq->pointer, keybuf, xlen))
-			return -EFAULT;
-	}
+	orinoco_unlock(priv, &flags);
 
 	return 0;
 }
 
-static int orinoco_ioctl_setessid(struct net_device *dev, struct iw_point *erq)
+static int orinoco_ioctl_setessid(struct net_device *dev,
+				  struct iw_request_info *info,
+				  struct iw_point *erq,
+				  char *essidbuf)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	char essidbuf[IW_ESSID_MAX_SIZE+1];
-	int err;
 	unsigned long flags;
 
 	/* Note : ESSID is ignored in Ad-Hoc demo mode, but we can set it
 	 * anyway... - Jean II */
 
-	memset(&essidbuf, 0, sizeof(essidbuf));
-
-	if (erq->flags) {
-		if (erq->length > IW_ESSID_MAX_SIZE)
-			return -E2BIG;
-		
-		if (copy_from_user(&essidbuf, erq->pointer, erq->length))
-			return -EFAULT;
+	/* Hum... Should not use Wireless Extension constant (may change),
+	 * should use our own... - Jean II */
+	if (erq->length > IW_ESSID_MAX_SIZE)
+		return -E2BIG;
 
-		essidbuf[erq->length] = '\0';
-	}
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	/* NULL the string (for NULL termination & ESSID = ANY) - Jean II */
+	memset(priv->desired_essid, 0, sizeof(priv->desired_essid));
 
-	memcpy(priv->desired_essid, essidbuf, sizeof(priv->desired_essid));
+	/* If not ANY, get the new ESSID */
+	if (erq->flags) {
+		memcpy(priv->desired_essid, essidbuf, erq->length);
+	}
 
 	orinoco_unlock(priv, &flags);
 
-	return 0;
+	return -EINPROGRESS;		/* Call commit handler */
 }
 
-static int orinoco_ioctl_getessid(struct net_device *dev, struct iw_point *erq)
+static int orinoco_ioctl_getessid(struct net_device *dev,
+				  struct iw_request_info *info,
+				  struct iw_point *erq,
+				  char *essidbuf)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	char essidbuf[IW_ESSID_MAX_SIZE+1];
 	int active;
 	int err = 0;
 	unsigned long flags;
@@ -2946,86 +3057,74 @@
 		if (err)
 			return err;
 	} else {
-		err = orinoco_lock(priv, &flags);
-		if (err)
-			return err;
-		memcpy(essidbuf, priv->desired_essid, sizeof(essidbuf));
+		if (orinoco_lock(priv, &flags) != 0)
+			return -EBUSY;
+		memcpy(essidbuf, priv->desired_essid, IW_ESSID_MAX_SIZE + 1);
 		orinoco_unlock(priv, &flags);
 	}
 
 	erq->flags = 1;
 	erq->length = strlen(essidbuf) + 1;
-	if (erq->pointer)
-		if (copy_to_user(erq->pointer, essidbuf, erq->length))
-			return -EFAULT;
 
 	TRACE_EXIT(dev->name);
 	
 	return 0;
 }
 
-static int orinoco_ioctl_setnick(struct net_device *dev, struct iw_point *nrq)
+static int orinoco_ioctl_setnick(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_point *nrq,
+				 char *nickbuf)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	char nickbuf[IW_ESSID_MAX_SIZE+1];
-	int err;
 	unsigned long flags;
 
 	if (nrq->length > IW_ESSID_MAX_SIZE)
 		return -E2BIG;
 
-	memset(nickbuf, 0, sizeof(nickbuf));
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
-	if (copy_from_user(nickbuf, nrq->pointer, nrq->length))
-		return -EFAULT;
-
-	nickbuf[nrq->length] = '\0';
-	
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
-
-	memcpy(priv->nick, nickbuf, sizeof(priv->nick));
+	memset(priv->nick, 0, sizeof(priv->nick));
+	memcpy(priv->nick, nickbuf, nrq->length);
 
 	orinoco_unlock(priv, &flags);
 
-	return 0;
+	return -EINPROGRESS;		/* Call commit handler */
 }
 
-static int orinoco_ioctl_getnick(struct net_device *dev, struct iw_point *nrq)
+static int orinoco_ioctl_getnick(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_point *nrq,
+				 char *nickbuf)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	char nickbuf[IW_ESSID_MAX_SIZE+1];
-	int err;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	memcpy(nickbuf, priv->nick, IW_ESSID_MAX_SIZE+1);
 	orinoco_unlock(priv, &flags);
 
 	nrq->length = strlen(nickbuf)+1;
 
-	if (copy_to_user(nrq->pointer, nickbuf, sizeof(nickbuf)))
-		return -EFAULT;
-
 	return 0;
 }
 
-static int orinoco_ioctl_setfreq(struct net_device *dev, struct iw_freq *frq)
+static int orinoco_ioctl_setfreq(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_freq *frq,
+				 char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int chan = -1;
-	int err;
 	unsigned long flags;
+	int err = -EINPROGRESS;		/* Call commit handler */
 
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
@@ -3047,16 +3146,39 @@
 	     ! (priv->channel_mask & (1 << (chan-1)) ) )
 		return -EINVAL;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
 	priv->channel = chan;
 	orinoco_unlock(priv, &flags);
 
+	return err;
+}
+
+static int orinoco_ioctl_getfreq(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_freq *frq,
+				 char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int tmp;
+
+	/* Locking done in there */
+	tmp = orinoco_hw_get_freq(priv);
+	if (tmp < 0) {
+		return tmp;
+	}
+
+	frq->m = tmp;
+	frq->e = 1;
+
 	return 0;
 }
 
-static int orinoco_ioctl_getsens(struct net_device *dev, struct iw_param *srq)
+static int orinoco_ioctl_getsens(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_param *srq,
+				 char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
@@ -3067,9 +3189,9 @@
 	if (!priv->has_sensitivity)
 		return -EOPNOTSUPP;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
 	err = hermes_read_wordrec(hw, USER_BAP,
 				  HERMES_RID_CNFSYSTEMSCALE, &val);
 	orinoco_unlock(priv, &flags);
@@ -3083,11 +3205,13 @@
 	return 0;
 }
 
-static int orinoco_ioctl_setsens(struct net_device *dev, struct iw_param *srq)
+static int orinoco_ioctl_setsens(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_param *srq,
+				 char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int val = srq->value;
-	int err;
 	unsigned long flags;
 
 	if (!priv->has_sensitivity)
@@ -3096,20 +3220,22 @@
 	if ((val < 1) || (val > 3))
 		return -EINVAL;
 	
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
 	priv->ap_density = val;
 	orinoco_unlock(priv, &flags);
 
-	return 0;
+	return -EINPROGRESS;		/* Call commit handler */
 }
 
-static int orinoco_ioctl_setrts(struct net_device *dev, struct iw_param *rrq)
+static int orinoco_ioctl_setrts(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_param *rrq,
+				char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	int val = rrq->value;
-	int err;
 	unsigned long flags;
 
 	if (rrq->disabled)
@@ -3118,25 +3244,39 @@
 	if ( (val < 0) || (val > 2347) )
 		return -EINVAL;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	priv->rts_thresh = val;
 	orinoco_unlock(priv, &flags);
 
+	return -EINPROGRESS;		/* Call commit handler */
+}
+
+static int orinoco_ioctl_getrts(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_param *rrq,
+				char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+
+	rrq->value = priv->rts_thresh;
+	rrq->disabled = (rrq->value == 2347);
+	rrq->fixed = 1;
 	return 0;
 }
 
-static int orinoco_ioctl_setfrag(struct net_device *dev, struct iw_param *frq)
+static int orinoco_ioctl_setfrag(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_param *frq,
+				 char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int err = 0;
+	int err = -EINPROGRESS;		/* Call commit handler */
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	if (priv->has_mwo) {
 		if (frq->disabled)
@@ -3164,18 +3304,20 @@
 	return err;
 }
 
-static int orinoco_ioctl_getfrag(struct net_device *dev, struct iw_param *frq)
+static int orinoco_ioctl_getfrag(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_param *frq,
+				 char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
-	int err = 0;
+	int err;
 	u16 val;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
-	
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
 	if (priv->has_mwo) {
 		err = hermes_read_wordrec(hw, USER_BAP,
 					  HERMES_RID_CNFMWOROBUST_AGERE,
@@ -3187,7 +3329,8 @@
 		frq->disabled = ! val;
 		frq->fixed = 0;
 	} else {
-		err = hermes_read_wordrec(hw, USER_BAP, HERMES_RID_CNFFRAGMENTATIONTHRESHOLD,
+		err = hermes_read_wordrec(hw, USER_BAP,
+					  HERMES_RID_CNFFRAGMENTATIONTHRESHOLD,
 					  &val);
 		if (err)
 			val = 0;
@@ -3202,10 +3345,12 @@
 	return err;
 }
 
-static int orinoco_ioctl_setrate(struct net_device *dev, struct iw_param *rrq)
+static int orinoco_ioctl_setrate(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_param *rrq,
+				 char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int err = 0;
 	int ratemode = -1;
 	int bitrate; /* 100s of kilobits */
 	int i;
@@ -3236,16 +3381,19 @@
 	if (ratemode == -1)
 		return -EINVAL;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
 	priv->bitratemode = ratemode;
 	orinoco_unlock(priv, &flags);
 
-	return err;
+	return -EINPROGRESS;
 }
 
-static int orinoco_ioctl_getrate(struct net_device *dev, struct iw_param *rrq)
+static int orinoco_ioctl_getrate(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_param *rrq,
+				 char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
@@ -3255,9 +3403,8 @@
 	u16 val;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	ratemode = priv->bitratemode;
 
@@ -3311,15 +3458,17 @@
 	return err;
 }
 
-static int orinoco_ioctl_setpower(struct net_device *dev, struct iw_param *prq)
+static int orinoco_ioctl_setpower(struct net_device *dev,
+				  struct iw_request_info *info,
+				  struct iw_param *prq,
+				  char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int err = 0;
+	int err = -EINPROGRESS;		/* Call commit handler */
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	if (prq->disabled) {
 		priv->pm_on = 0;
@@ -3364,7 +3513,10 @@
 	return err;
 }
 
-static int orinoco_ioctl_getpower(struct net_device *dev, struct iw_param *prq)
+static int orinoco_ioctl_getpower(struct net_device *dev,
+				  struct iw_request_info *info,
+				  struct iw_param *prq,
+				  char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
@@ -3372,9 +3524,8 @@
 	u16 enable, period, timeout, mcast;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	
 	err = hermes_read_wordrec(hw, USER_BAP, HERMES_RID_CNFPMENABLED, &enable);
 	if (err)
@@ -3413,7 +3564,10 @@
 	return err;
 }
 
-static int orinoco_ioctl_getretry(struct net_device *dev, struct iw_param *rrq)
+static int orinoco_ioctl_getretry(struct net_device *dev,
+				  struct iw_request_info *info,
+				  struct iw_param *rrq,
+				  char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
@@ -3421,9 +3575,8 @@
 	u16 short_limit, long_limit, lifetime;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 	
 	err = hermes_read_wordrec(hw, USER_BAP, HERMES_RID_SHORTRETRYLIMIT,
 				  &short_limit);
@@ -3465,16 +3618,41 @@
 	return err;
 }
 
-static int orinoco_ioctl_setibssport(struct net_device *dev, struct iwreq *wrq)
+static int orinoco_ioctl_reset(struct net_device *dev,
+			       struct iw_request_info *info,
+			       void *wrqu,
+			       char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int val = *( (int *) wrq->u.name );
-	int err;
+
+	if (! capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (info->cmd == (SIOCIWFIRSTPRIV + 0x1)) {
+		printk(KERN_DEBUG "%s: Forcing reset!\n", dev->name);
+
+		/* Firmware reset */
+		orinoco_reset(dev);
+	} else {
+		printk(KERN_DEBUG "%s: Force scheduling reset!\n", dev->name);
+
+		schedule_work(&priv->reset_work);
+	}
+
+	return 0;
+}
+
+static int orinoco_ioctl_setibssport(struct net_device *dev,
+				     struct iw_request_info *info,
+				     void *wrqu,
+				     char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int val = *( (int *) extra );
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	priv->ibss_port = val ;
 
@@ -3482,36 +3660,33 @@
 	set_port_type(priv);
 
 	orinoco_unlock(priv, &flags);
-	return 0;
+	return -EINPROGRESS;		/* Call commit handler */
 }
 
-static int orinoco_ioctl_getibssport(struct net_device *dev, struct iwreq *wrq)
+static int orinoco_ioctl_getibssport(struct net_device *dev,
+				     struct iw_request_info *info,
+				     void *wrqu,
+				     char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int *val = (int *)wrq->u.name;
-	int err;
-	unsigned long flags;
-
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	int *val = (int *) extra;
 
 	*val = priv->ibss_port;
-	orinoco_unlock(priv, &flags);
-
 	return 0;
 }
 
-static int orinoco_ioctl_setport3(struct net_device *dev, struct iwreq *wrq)
+static int orinoco_ioctl_setport3(struct net_device *dev,
+				  struct iw_request_info *info,
+				  void *wrqu,
+				  char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int val = *( (int *) wrq->u.name );
+	int val = *( (int *) extra );
 	int err = 0;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	switch (val) {
 	case 0: /* Try to do IEEE ad-hoc mode */
@@ -3535,57 +3710,133 @@
 		err = -EINVAL;
 	}
 
-	if (! err)
+	if (! err) {
 		/* Actually update the mode we are using */
 		set_port_type(priv);
+		err = -EINPROGRESS;
+	}
 
 	orinoco_unlock(priv, &flags);
 
 	return err;
 }
 
-static int orinoco_ioctl_getport3(struct net_device *dev, struct iwreq *wrq)
+static int orinoco_ioctl_getport3(struct net_device *dev,
+				  struct iw_request_info *info,
+				  void *wrqu,
+				  char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int *val = (int *) extra;
+
+	*val = priv->prefer_port3;
+	return 0;
+}
+
+static int orinoco_ioctl_setpreamble(struct net_device *dev,
+				     struct iw_request_info *info,
+				     void *wrqu,
+				     char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	unsigned long flags;
+	int val;
+
+	if (! priv->has_preamble)
+		return -EOPNOTSUPP;
+
+	/* 802.11b has recently defined some short preamble.
+	 * Basically, the Phy header has been reduced in size.
+	 * This increase performance, especially at high rates
+	 * (the preamble is transmitted at 1Mb/s), unfortunately
+	 * this give compatibility troubles... - Jean II */
+	val = *( (int *) extra );
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
+	if (val)
+		priv->preamble = 1;
+	else
+		priv->preamble = 0;
+
+	orinoco_unlock(priv, &flags);
+
+	return -EINPROGRESS;		/* Call commit handler */
+}
+
+static int orinoco_ioctl_getpreamble(struct net_device *dev,
+				     struct iw_request_info *info,
+				     void *wrqu,
+				     char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int *val = (int *) extra;
+
+	if (! priv->has_preamble)
+		return -EOPNOTSUPP;
+
+	*val = priv->preamble;
+	return 0;
+}
+
+/* ioctl interface to hermes_read_ltv()
+ * To use with iwpriv, pass the RID as the token argument, e.g.
+ * iwpriv get_rid [0xfc00]
+ * At least Wireless Tools 25 is required to use iwpriv.
+ * For Wireless Tools 25 and 26 append "dummy" are the end. */
+static int orinoco_ioctl_getrid(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_point *data,
+				char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int *val = (int *)wrq->u.name;
+	hermes_t *hw = &priv->hw;
+	int rid = data->flags;
+	u16 length;
 	int err;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
+	/* It's a "get" function, but we don't want users to access the
+	 * WEP key and other raw firmware data */
+	if (! capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (rid < 0xfc00 || rid > 0xffff)
+		return -EINVAL;
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
+	err = hermes_read_ltv(hw, USER_BAP, rid, MAX_RID_LEN, &length,
+			      extra);
 	if (err)
-		return err;
+		goto out;
 
-	*val = priv->prefer_port3;
+	data->length = min_t(u16, HERMES_RECLEN_TO_BYTES(length),
+			     MAX_RID_LEN);
+
+ out:
 	orinoco_unlock(priv, &flags);
-	return 0;
+	return err;
 }
 
 /* Spy is used for link quality/strength measurements in Ad-Hoc mode
  * Jean II */
-static int orinoco_ioctl_setspy(struct net_device *dev, struct iw_point *srq)
+static int orinoco_ioctl_setspy(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_point *srq,
+				char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	struct sockaddr address[IW_MAX_SPY];
+	struct sockaddr *address = (struct sockaddr *) extra;
 	int number = srq->length;
 	int i;
-	int err = 0;
 	unsigned long flags;
 
-	/* Check the number of addresses */
-	if (number > IW_MAX_SPY)
-		return -E2BIG;
-
-	/* Get the data in the driver */
-	if (srq->pointer) {
-		if (copy_from_user(address, srq->pointer,
-				   sizeof(struct sockaddr) * number))
-			return -EFAULT;
-	}
-
 	/* Make sure nobody mess with the structure while we do */
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	/* orinoco_lock() doesn't disable interrupts, so make sure the
 	 * interrupt rx path don't get confused while we copy */
@@ -3606,25 +3857,32 @@
 	/* Now, let the others play */
 	orinoco_unlock(priv, &flags);
 
-	return err;
+	/* Do NOT call commit handler */
+	return 0;
 }
 
-static int orinoco_ioctl_getspy(struct net_device *dev, struct iw_point *srq)
+static int orinoco_ioctl_getspy(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_point *srq,
+				char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	struct sockaddr address[IW_MAX_SPY];
-	struct iw_quality spy_stat[IW_MAX_SPY];
+	struct sockaddr *address = (struct sockaddr *) extra;
 	int number;
 	int i;
-	int err;
 	unsigned long flags;
 
-	err = orinoco_lock(priv, &flags);
-	if (err)
-		return err;
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
 	number = priv->spy_number;
-	if ((number > 0) && (srq->pointer)) {
+	/* Create address struct */
+	for (i = 0; i < number; i++) {
+		memcpy(address[i].sa_data, priv->spy_address[i],
+		       ETH_ALEN);
+		address[i].sa_family = AF_UNIX;
+	}
+	if (number > 0) {
 		/* Create address struct */
 		for (i = 0; i < number; i++) {
 			memcpy(address[i].sa_data, priv->spy_address[i],
@@ -3633,217 +3891,380 @@
 		}
 		/* Copy stats */
 		/* In theory, we should disable irqs while copying the stats
-		 * because the rx path migh update it in the middle...
+		 * because the rx path might update it in the middle...
 		 * Bah, who care ? - Jean II */
-		memcpy(&spy_stat, priv->spy_stat,
-		       sizeof(struct iw_quality) * IW_MAX_SPY);
-		for (i=0; i < number; i++)
-			priv->spy_stat[i].updated = 0;
+		memcpy(extra  + (sizeof(struct sockaddr) * number),
+		       priv->spy_stat, sizeof(struct iw_quality) * number);
 	}
+	/* Reset updated flags. */
+	for (i = 0; i < number; i++)
+		priv->spy_stat[i].updated = 0;
 
 	orinoco_unlock(priv, &flags);
 
-	/* Push stuff to user space */
 	srq->length = number;
-	if(copy_to_user(srq->pointer, address,
-			 sizeof(struct sockaddr) * number))
-		return -EFAULT;
-	if(copy_to_user(srq->pointer + (sizeof(struct sockaddr)*number),
-			&spy_stat, sizeof(struct iw_quality) * number))
-		return -EFAULT;
 
 	return 0;
 }
 
-static int
-orinoco_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+/* Commit handler, called after set operations */
+static int orinoco_ioctl_commit(struct net_device *dev,
+				struct iw_request_info *info,
+				void *wrqu,
+				char *extra)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
+	struct hermes *hw = &priv->hw;
+	unsigned long flags;
+	int err = 0;
+
+	if (!priv->open)
+		return 0;
+
+	if (priv->broken_disableport) {
+		orinoco_reset(dev);
+		return 0;
+	}
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return err;
+
+	err = hermes_disable_port(hw, 0);
+	if (err) {
+		printk(KERN_WARNING "%s: Unable to disable port "
+		       "while reconfiguring card\n", dev->name);
+		priv->broken_disableport = 1;
+		goto out;
+	}
+
+	err = __orinoco_program_rids(dev);
+	if (err) {
+		printk(KERN_WARNING "%s: Unable to reconfigure card\n",
+		       dev->name);
+		goto out;
+	}
+
+	err = hermes_enable_port(hw, 0);
+	if (err) {
+		printk(KERN_WARNING "%s: Unable to enable port while reconfiguring card\n",
+		       dev->name);
+		goto out;
+	}
+
+ out:
+	if (err) {
+		printk(KERN_WARNING "%s: Resetting instead...\n", dev->name);
+		schedule_work(&priv->reset_work);
+		err = 0;
+	}
+
+	orinoco_unlock(priv, &flags);
+	return err;
+}
+
+static const struct iw_priv_args orinoco_privtab[] = {
+	{ SIOCIWFIRSTPRIV + 0x0, 0, 0, "force_reset" },
+	{ SIOCIWFIRSTPRIV + 0x1, 0, 0, "card_reset" },
+	{ SIOCIWFIRSTPRIV + 0x2,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  0, "set_port3" },
+	{ SIOCIWFIRSTPRIV + 0x3, 0,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  "get_port3" },
+	{ SIOCIWFIRSTPRIV + 0x4,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  0, "set_preamble" },
+	{ SIOCIWFIRSTPRIV + 0x5, 0,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  "get_preamble" },
+	{ SIOCIWFIRSTPRIV + 0x6,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  0, "set_ibssport" },
+	{ SIOCIWFIRSTPRIV + 0x7, 0,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  "get_ibssport" },
+	{ SIOCIWFIRSTPRIV + 0x9, 0,
+	  IW_PRIV_TYPE_BYTE | MAX_RID_LEN,
+	  "get_rid" },
+};
+
+#if WIRELESS_EXT > 12
+
+/*
+ * Structures to export the Wireless Handlers
+ */
+
+static const iw_handler		orinoco_handler[] =
+{
+	(iw_handler) orinoco_ioctl_commit,		/* SIOCSIWCOMMIT */
+	(iw_handler) orinoco_ioctl_getname,		/* SIOCGIWNAME */
+	(iw_handler) NULL,				/* SIOCSIWNWID */
+	(iw_handler) NULL,				/* SIOCGIWNWID */
+	(iw_handler) orinoco_ioctl_setfreq,		/* SIOCSIWFREQ */
+	(iw_handler) orinoco_ioctl_getfreq,		/* SIOCGIWFREQ */
+	(iw_handler) orinoco_ioctl_setmode,		/* SIOCSIWMODE */
+	(iw_handler) orinoco_ioctl_getmode,		/* SIOCGIWMODE */
+	(iw_handler) orinoco_ioctl_setsens,		/* SIOCSIWSENS */
+	(iw_handler) orinoco_ioctl_getsens,		/* SIOCGIWSENS */
+	(iw_handler) NULL,				/* SIOCSIWRANGE */
+	(iw_handler) orinoco_ioctl_getiwrange,		/* SIOCGIWRANGE */
+	(iw_handler) NULL,				/* SIOCSIWPRIV */
+	(iw_handler) NULL,				/* SIOCGIWPRIV */
+	(iw_handler) NULL,				/* SIOCSIWSTATS */
+	(iw_handler) NULL,				/* SIOCGIWSTATS */
+	(iw_handler) orinoco_ioctl_setspy,		/* SIOCSIWSPY */
+	(iw_handler) orinoco_ioctl_getspy,		/* SIOCGIWSPY */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) orinoco_ioctl_setwap,		/* SIOCSIWAP */
+	(iw_handler) orinoco_ioctl_getwap,		/* SIOCGIWAP */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) NULL,				/* SIOCGIWAPLIST */
+#if WIRELESS_EXT > 13
+	(iw_handler) NULL,		/* SIOCSIWSCAN */
+	(iw_handler) NULL,		/* SIOCGIWSCAN */
+#else	/* WIRELESS_EXT > 13 */
+	(iw_handler) NULL,				/* SIOCSIWSCAN */
+	(iw_handler) NULL,				/* SIOCGIWSCAN */
+#endif	/* WIRELESS_EXT > 13 */
+	(iw_handler) orinoco_ioctl_setessid,		/* SIOCSIWESSID */
+	(iw_handler) orinoco_ioctl_getessid,		/* SIOCGIWESSID */
+	(iw_handler) orinoco_ioctl_setnick,		/* SIOCSIWNICKN */
+	(iw_handler) orinoco_ioctl_getnick,		/* SIOCGIWNICKN */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) orinoco_ioctl_setrate,		/* SIOCSIWRATE */
+	(iw_handler) orinoco_ioctl_getrate,		/* SIOCGIWRATE */
+	(iw_handler) orinoco_ioctl_setrts,		/* SIOCSIWRTS */
+	(iw_handler) orinoco_ioctl_getrts,		/* SIOCGIWRTS */
+	(iw_handler) orinoco_ioctl_setfrag,		/* SIOCSIWFRAG */
+	(iw_handler) orinoco_ioctl_getfrag,		/* SIOCGIWFRAG */
+	(iw_handler) NULL,				/* SIOCSIWTXPOW */
+	(iw_handler) NULL,				/* SIOCGIWTXPOW */
+	(iw_handler) NULL,				/* SIOCSIWRETRY */
+	(iw_handler) orinoco_ioctl_getretry,		/* SIOCGIWRETRY */
+	(iw_handler) orinoco_ioctl_setiwencode,		/* SIOCSIWENCODE */
+	(iw_handler) orinoco_ioctl_getiwencode,		/* SIOCGIWENCODE */
+	(iw_handler) orinoco_ioctl_setpower,		/* SIOCSIWPOWER */
+	(iw_handler) orinoco_ioctl_getpower,		/* SIOCGIWPOWER */
+};
+
+/*
+  Added typecasting since we no longer use iwreq_data -- Moustafa
+ */
+static const iw_handler		orinoco_private_handler[] =
+{
+	(iw_handler) orinoco_ioctl_reset,		/* SIOCIWFIRSTPRIV */
+	(iw_handler) orinoco_ioctl_reset,		/* SIOCIWFIRSTPRIV + 1 */
+	(iw_handler) orinoco_ioctl_setport3,		/* SIOCIWFIRSTPRIV + 2 */
+	(iw_handler) orinoco_ioctl_getport3,		/* SIOCIWFIRSTPRIV + 3 */
+	(iw_handler) orinoco_ioctl_setpreamble,		/* SIOCIWFIRSTPRIV + 4 */
+	(iw_handler) orinoco_ioctl_getpreamble,		/* SIOCIWFIRSTPRIV + 5 */
+	(iw_handler) orinoco_ioctl_setibssport,		/* SIOCIWFIRSTPRIV + 6 */
+	(iw_handler) orinoco_ioctl_getibssport,		/* SIOCIWFIRSTPRIV + 7 */
+	(iw_handler) NULL,				/* SIOCIWFIRSTPRIV + 8 */
+	(iw_handler) orinoco_ioctl_getrid		/* SIOCIWFIRSTPRIV + 9 */
+};
+
+static const struct iw_handler_def	orinoco_handler_def =
+{
+	.num_standard = sizeof(orinoco_handler) / sizeof(iw_handler),
+	.num_private = sizeof(orinoco_private_handler) 	/ sizeof(iw_handler),
+	.num_private_args = sizeof(orinoco_privtab) / sizeof(struct iw_priv_args),
+	.standard = (iw_handler *) orinoco_handler,
+	.private = (iw_handler *) orinoco_private_handler,
+	.private_args = (struct iw_priv_args *) orinoco_privtab,
+};
+#endif /* WIRELESS_EXT > 12 */
+
+#if WIRELESS_EXT <= 12
+/* Old style support for wireless extensions */
+static int orinoco_ioctl_we_old(struct net_device *dev, struct ifreq *rq, int cmd)
+{
 	struct iwreq *wrq = (struct iwreq *)rq;
 	int err = 0;
-	int tmp;
-	int changed = 0;
-	unsigned long flags;
 
 	TRACE_ENTER(dev->name);
 
-	/* In theory, we could allow most of the the SET stuff to be
-	 * done. In practice, the lapse of time at startup when the
-	 * card is not ready is very short, so why bother...  Note
-	 * that netif_device_present is different from up/down
-	 * (ifconfig), when the device is not yet up, it is usually
-	 * already ready...  Jean II */
-	if (! netif_device_present(dev))
-		return -ENODEV;
-
 	switch (cmd) {
 	case SIOCGIWNAME:
-		strcpy(wrq->u.name, "IEEE 802.11-DS");
+		err = orinoco_ioctl_getname(dev, NULL, wrq->u.name, NULL);
 		break;
 		
 	case SIOCGIWAP:
-		wrq->u.ap_addr.sa_family = ARPHRD_ETHER;
-		err = orinoco_hw_get_bssid(priv, wrq->u.ap_addr.sa_data);
+		err = orinoco_ioctl_getwap(dev, NULL, &wrq->u.ap_addr, NULL);
 		break;
 
 	case SIOCGIWRANGE:
-		err = orinoco_ioctl_getiwrange(dev, &wrq->u.data);
+		{
+			struct iw_range range;
+			err = orinoco_ioctl_getiwrange(dev, NULL,
+						       &(wrq->u.data),
+						       (char *) &range);
+			if (copy_to_user(wrq->u.data.pointer, &range,
+					 sizeof(struct iw_range)))
+				err = -EFAULT;
+		}
 		break;
 
 	case SIOCSIWMODE:
-		err = orinoco_lock(priv, &flags);
-		if (err)
-			return err;
-		switch (wrq->u.mode) {
-		case IW_MODE_ADHOC:
-			if (! (priv->has_ibss || priv->has_port3) )
-				err = -EINVAL;
-			else {
-				priv->iw_mode = IW_MODE_ADHOC;
-				changed = 1;
-			}
-			break;
-
-		case IW_MODE_INFRA:
-			priv->iw_mode = IW_MODE_INFRA;
-			changed = 1;
-			break;
-
-		default:
-			err = -EINVAL;
-			break;
-		}
-		set_port_type(priv);
-		orinoco_unlock(priv, &flags);
+		err = orinoco_ioctl_setmode(dev, NULL, &wrq->u.mode, NULL);
 		break;
 
 	case SIOCGIWMODE:
-		err = orinoco_lock(priv, &flags);
-		if (err)
-			return err;
-		wrq->u.mode = priv->iw_mode;
-		orinoco_unlock(priv, &flags);
+		err = orinoco_ioctl_getmode(dev, NULL, &wrq->u.mode, NULL);
 		break;
 
 	case SIOCSIWENCODE:
-		if (! priv->has_wep) {
-			err = -EOPNOTSUPP;
-			break;
+		{
+			char keybuf[ORINOCO_MAX_KEY_SIZE];
+			if (wrq->u.encoding.pointer) {
+				/* We actually have a key to set */
+				if (wrq->u.encoding.length > ORINOCO_MAX_KEY_SIZE) {
+					err = -E2BIG;
+					break;
+				}
+				if (copy_from_user(keybuf,
+						   wrq->u.encoding.pointer,
+						   wrq->u.encoding.length)) {
+					err = -EFAULT;
+					break;
+				}
+			} else if (wrq->u.encoding.length != 0) {
+				err = -EINVAL;
+				break;
+			}
+			err = orinoco_ioctl_setiwencode(dev, NULL,
+							&(wrq->u.encoding),
+							keybuf);
 		}
-
-		err = orinoco_ioctl_setiwencode(dev, &wrq->u.encoding);
-		if (! err)
-			changed = 1;
 		break;
 
 	case SIOCGIWENCODE:
-		if (! priv->has_wep) {
-			err = -EOPNOTSUPP;
-			break;
-		}
-
-		if (! capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
+		{
+			char keybuf[ORINOCO_MAX_KEY_SIZE];
+			err = orinoco_ioctl_getiwencode(dev, NULL,
+							&(wrq->u.encoding),
+							keybuf);
+			if (wrq->u.encoding.pointer) {
+				if (copy_to_user(wrq->u.encoding.pointer,
+						 keybuf,
+						 wrq->u.encoding.length))
+					err = -EFAULT;
+			}
 		}
-
-		err = orinoco_ioctl_getiwencode(dev, &wrq->u.encoding);
 		break;
 
 	case SIOCSIWESSID:
-		err = orinoco_ioctl_setessid(dev, &wrq->u.essid);
-		if (! err)
-			changed = 1;
+		{
+			char essidbuf[IW_ESSID_MAX_SIZE+1];
+			if (wrq->u.essid.length > IW_ESSID_MAX_SIZE) {
+				err = -E2BIG;
+				break;
+			}
+			if (copy_from_user(essidbuf, wrq->u.essid.pointer,
+					   wrq->u.essid.length)) {
+				err = -EFAULT;
+				break;
+			}
+			err = orinoco_ioctl_setessid(dev, NULL,
+						     &(wrq->u.essid),
+						     essidbuf);
+		}
 		break;
 
 	case SIOCGIWESSID:
-		err = orinoco_ioctl_getessid(dev, &wrq->u.essid);
+		{
+			char essidbuf[IW_ESSID_MAX_SIZE+1];
+			err = orinoco_ioctl_getessid(dev, NULL,
+						     &(wrq->u.essid),
+						     essidbuf);
+			if (wrq->u.essid.pointer)
+				if ( copy_to_user(wrq->u.essid.pointer,
+						  essidbuf,
+						  wrq->u.essid.length) )
+					err = -EFAULT;
+		}
 		break;
 
 	case SIOCSIWNICKN:
-		err = orinoco_ioctl_setnick(dev, &wrq->u.data);
-		if (! err)
-			changed = 1;
+		{
+			char nickbuf[IW_ESSID_MAX_SIZE+1];
+			if (wrq->u.essid.length > IW_ESSID_MAX_SIZE) {
+				err = -E2BIG;
+				break;
+			}
+			if (copy_from_user(nickbuf, wrq->u.essid.pointer,
+					   wrq->u.essid.length)) {
+				err = -EFAULT;
+				break;
+			}
+			err = orinoco_ioctl_setnick(dev, NULL, &(wrq->u.essid),
+						    nickbuf);
+		}
 		break;
 
 	case SIOCGIWNICKN:
-		err = orinoco_ioctl_getnick(dev, &wrq->u.data);
+		{
+			char nickbuf[IW_ESSID_MAX_SIZE+1];
+			err = orinoco_ioctl_getnick(dev, NULL, &(wrq->u.essid),
+						    nickbuf);
+			if (wrq->u.essid.pointer)
+				if ( copy_to_user(wrq->u.essid.pointer,
+						  nickbuf,
+						  wrq->u.essid.length) )
+					err = -EFAULT;
+		}
 		break;
 
 	case SIOCGIWFREQ:
-		tmp = orinoco_hw_get_freq(priv);
-		if (tmp < 0) {
-			err = tmp;
-		} else {
-			wrq->u.freq.m = tmp;
-			wrq->u.freq.e = 1;
-		}
+		err = orinoco_ioctl_getfreq(dev, NULL, &(wrq->u.freq), NULL);
 		break;
 
 	case SIOCSIWFREQ:
-		err = orinoco_ioctl_setfreq(dev, &wrq->u.freq);
-		if (! err)
-			changed = 1;
+		err = orinoco_ioctl_setfreq(dev, NULL, &(wrq->u.freq), NULL);
 		break;
 
 	case SIOCGIWSENS:
-		err = orinoco_ioctl_getsens(dev, &wrq->u.sens);
+		err = orinoco_ioctl_getsens(dev, NULL, &(wrq->u.sens), NULL);
 		break;
 
 	case SIOCSIWSENS:
-		err = orinoco_ioctl_setsens(dev, &wrq->u.sens);
-		if (! err)
-			changed = 1;
+		err = orinoco_ioctl_setsens(dev, NULL, &(wrq->u.sens), NULL);
 		break;
 
 	case SIOCGIWRTS:
-		wrq->u.rts.value = priv->rts_thresh;
-		wrq->u.rts.disabled = (wrq->u.rts.value == 2347);
-		wrq->u.rts.fixed = 1;
+		err = orinoco_ioctl_getrts(dev, NULL, &(wrq->u.rts), NULL);
 		break;
 
 	case SIOCSIWRTS:
-		err = orinoco_ioctl_setrts(dev, &wrq->u.rts);
-		if (! err)
-			changed = 1;
+		err = orinoco_ioctl_setrts(dev, NULL, &(wrq->u.rts), NULL);
 		break;
 
 	case SIOCSIWFRAG:
-		err = orinoco_ioctl_setfrag(dev, &wrq->u.frag);
-		if (! err)
-			changed = 1;
+		err = orinoco_ioctl_setfrag(dev, NULL, &(wrq->u.frag), NULL);
 		break;
 
 	case SIOCGIWFRAG:
-		err = orinoco_ioctl_getfrag(dev, &wrq->u.frag);
+		err = orinoco_ioctl_getfrag(dev, NULL, &(wrq->u.frag), NULL);
 		break;
 
 	case SIOCSIWRATE:
-		err = orinoco_ioctl_setrate(dev, &wrq->u.bitrate);
-		if (! err)
-			changed = 1;
+		err = orinoco_ioctl_setrate(dev, NULL, &(wrq->u.bitrate),
+					    NULL);
 		break;
 
 	case SIOCGIWRATE:
-		err = orinoco_ioctl_getrate(dev, &wrq->u.bitrate);
+		err = orinoco_ioctl_getrate(dev, NULL, &(wrq->u.bitrate),
+					    NULL);
 		break;
 
 	case SIOCSIWPOWER:
-		err = orinoco_ioctl_setpower(dev, &wrq->u.power);
-		if (! err)
-			changed = 1;
+		err = orinoco_ioctl_setpower(dev, NULL, &(wrq->u.power), NULL);
 		break;
 
 	case SIOCGIWPOWER:
-		err = orinoco_ioctl_getpower(dev, &wrq->u.power);
-		break;
-
-	case SIOCGIWTXPOW:
-		/* The card only supports one tx power, so this is easy */
-		wrq->u.txpower.value = 15; /* dBm */
-		wrq->u.txpower.fixed = 1;
-		wrq->u.txpower.disabled = 0;
-		wrq->u.txpower.flags = IW_TXPOW_DBM;
+		err = orinoco_ioctl_getpower(dev, NULL, &(wrq->u.power), NULL);
 		break;
 
 	case SIOCSIWRETRY:
@@ -3851,143 +4272,173 @@
 		break;
 
 	case SIOCGIWRETRY:
-		err = orinoco_ioctl_getretry(dev, &wrq->u.retry);
+		err = orinoco_ioctl_getretry(dev, NULL, &(wrq->u.retry), NULL);
 		break;
 
 	case SIOCSIWSPY:
-		err = orinoco_ioctl_setspy(dev, &wrq->u.data);
+		{
+			struct sockaddr address[IW_MAX_SPY];
+			/* Check the number of addresses */
+			if (wrq->u.data.length > IW_MAX_SPY) {
+				err = -E2BIG;
+				break;
+			}
+			/* Get the data in the driver */
+			if (wrq->u.data.pointer) {
+				if (copy_from_user((char *) address,
+						   wrq->u.data.pointer,
+						   sizeof(struct sockaddr) *
+						   wrq->u.data.length)) {
+					err = -EFAULT;
+					break;
+				}
+			} else if (wrq->u.data.length != 0) {
+				err = -EINVAL;
+				break;
+			}
+			err = orinoco_ioctl_setspy(dev, NULL, &(wrq->u.data),
+						   (char *) address);
+		}
 		break;
 
 	case SIOCGIWSPY:
-		err = orinoco_ioctl_getspy(dev, &wrq->u.data);
+		{
+			char buffer[IW_MAX_SPY * (sizeof(struct sockaddr) +
+						  sizeof(struct iw_quality))];
+			err = orinoco_ioctl_getspy(dev, NULL, &(wrq->u.data),
+						   buffer);
+			if (wrq->u.data.pointer) {
+				if (copy_to_user(wrq->u.data.pointer,
+						 buffer,
+						 (wrq->u.data.length *
+						  (sizeof(struct sockaddr) +
+						   sizeof(struct iw_quality)))
+						 ))
+					err = -EFAULT;
+			}
+		}
 		break;
 
 	case SIOCGIWPRIV:
 		if (wrq->u.data.pointer) {
-			struct iw_priv_args privtab[] = {
-				{ SIOCIWFIRSTPRIV + 0x0, 0, 0, "force_reset" },
-				{ SIOCIWFIRSTPRIV + 0x1, 0, 0, "card_reset" },
-				{ SIOCIWFIRSTPRIV + 0x2,
-				  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-				  0, "set_port3" },
-				{ SIOCIWFIRSTPRIV + 0x3, 0,
-				  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-				  "get_port3" },
-				{ SIOCIWFIRSTPRIV + 0x4,
-				  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-				  0, "set_preamble" },
-				{ SIOCIWFIRSTPRIV + 0x5, 0,
-				  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-				  "get_preamble" },
-				{ SIOCIWFIRSTPRIV + 0x6,
-				  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-				  0, "set_ibssport" },
-				{ SIOCIWFIRSTPRIV + 0x7, 0,
-				  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-				  "get_ibssport" },
-				{ SIOCIWLASTPRIV, 0, 0, "dump_recs" },
-			};
-
-			wrq->u.data.length = sizeof(privtab) / sizeof(privtab[0]);
-			if (copy_to_user(wrq->u.data.pointer, privtab, sizeof(privtab)))
+			wrq->u.data.length = ARRAY_SIZE(orinoco_privtab);
+			if (copy_to_user(wrq->u.data.pointer,
+					 orinoco_privtab,
+					 sizeof(orinoco_privtab)))
 				err = -EFAULT;
 		}
 		break;
 	       
 	case SIOCIWFIRSTPRIV + 0x0: /* force_reset */
 	case SIOCIWFIRSTPRIV + 0x1: /* card_reset */
-		if (! capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
+		{
+			struct iw_request_info info;
+			info.cmd = cmd;
+			err = orinoco_ioctl_reset(dev, &info, &(wrq->u),
+						  (char *) &(wrq->u));
 		}
-		
-		printk(KERN_DEBUG "%s: Force scheduling reset!\n", dev->name);
-
-		schedule_work(&priv->reset_work);
 		break;
 
 	case SIOCIWFIRSTPRIV + 0x2: /* set_port3 */
-		if (! capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
-		}
-
-		err = orinoco_ioctl_setport3(dev, wrq);
-		if (! err)
-			changed = 1;
+		err = orinoco_ioctl_setport3(dev, NULL, &(wrq->u),
+					     (char *) &(wrq->u));
 		break;
 
 	case SIOCIWFIRSTPRIV + 0x3: /* get_port3 */
-		err = orinoco_ioctl_getport3(dev, wrq);
+		err = orinoco_ioctl_getport3(dev, NULL, &(wrq->u),
+					     (char *) &(wrq->u));
 		break;
 
 	case SIOCIWFIRSTPRIV + 0x4: /* set_preamble */
-		if (! capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
-		}
-
-		/* 802.11b has recently defined some short preamble.
-		 * Basically, the Phy header has been reduced in size.
-		 * This increase performance, especially at high rates
-		 * (the preamble is transmitted at 1Mb/s), unfortunately
-		 * this give compatibility troubles... - Jean II */
-		if(priv->has_preamble) {
-			int val = *( (int *) wrq->u.name );
-
-			err = orinoco_lock(priv, &flags);
-			if (err)
-				return err;
-			if (val)
-				priv->preamble = 1;
-			else
-				priv->preamble = 0;
-			orinoco_unlock(priv, &flags);
-			changed = 1;
-		} else
-			err = -EOPNOTSUPP;
+		err = orinoco_ioctl_setpreamble(dev, NULL, &(wrq->u),
+						(char *) &(wrq->u));
 		break;
 
 	case SIOCIWFIRSTPRIV + 0x5: /* get_preamble */
-		if(priv->has_preamble) {
-			int *val = (int *)wrq->u.name;
-
-			err = orinoco_lock(priv, &flags);
-			if (err)
-				return err;
-			*val = priv->preamble;
-			orinoco_unlock(priv, &flags);
-		} else
-			err = -EOPNOTSUPP;
+		err = orinoco_ioctl_getpreamble(dev, NULL, &(wrq->u),
+						(char *) &(wrq->u));
 		break;
-	case SIOCIWFIRSTPRIV + 0x6: /* set_ibssport */
-		if (! capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
-		}
 
-		err = orinoco_ioctl_setibssport(dev, wrq);
-		if (! err)
-			changed = 1;
+	case SIOCIWFIRSTPRIV + 0x6: /* set_ibssport */
+		err = orinoco_ioctl_setibssport(dev, NULL, &(wrq->u),
+						(char *) &(wrq->u));
 		break;
 
 	case SIOCIWFIRSTPRIV + 0x7: /* get_ibssport */
-		err = orinoco_ioctl_getibssport(dev, wrq);
+		err = orinoco_ioctl_getibssport(dev, NULL, &(wrq->u),
+						(char *) &(wrq->u));
 		break;
 
+	case SIOCIWFIRSTPRIV + 0x9: /* get_rid */
+		{
+			u16 lenght;
+			char *buffer = kmalloc(MAX_RID_LEN, GFP_KERNEL);
+
+			if (!buffer) {
+				err = -ENOMEM;
+				break;
+			}
+			err = orinoco_ioctl_getrid(dev, NULL, &wrq->u.data,
+						   buffer);
+			if (err) {
+				kfree(buffer);
+				break;
+			}
+
+			lenght = min_t(u16, wrq->u.data.length, MAX_RID_LEN);
+			if (copy_to_user(wrq->u.data.pointer, buffer,
+					 lenght) != 0)
+				err = -EFAULT;
+
+			kfree(buffer);
+		}
+		break;
 
 	default:
 		err = -EOPNOTSUPP;
 	}
 	
-	if (! err && changed && netif_running(dev)) {
-		err = orinoco_reconfigure(dev);
-	}		
-
+	if (err == -EINPROGRESS) {
+		if (netif_running(dev))
+			err = orinoco_ioctl_commit(dev, NULL, NULL, NULL);
+		else
+			err = 0;
+	}
 	TRACE_EXIT(dev->name);
 
 	return err;
 }
+#endif /* WIRELESS_EXT > 12 */
+
+static int orinoco_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	int err = 0;
+
+	TRACE_ENTER(dev->name);
+
+	/* In theory, we could allow most of the the SET stuff to be
+	 * done. In practice, the lapse of time at startup when the
+	 * card is not ready is very short, so why bother...  Note
+	 * that netif_device_present is different from up/down
+	 * (ifconfig), when the device is not yet up, it is usually
+	 * already ready...  Jean II */
+	if (! netif_device_present(dev))
+		return -ENODEV;
+
+#if WIRELESS_EXT <= 12
+	/* Old style wireless extensions support */
+	if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
+		err = orinoco_ioctl_we_old(dev, rq, cmd);
+	else
+#endif /* WIRELESS_EXT <= 12 */
+	switch (cmd) {
+	default:
+		err = -EOPNOTSUPP;
+	}
+
+	TRACE_EXIT(dev->name);
+	return err;
+}
 
 
 /********************************************************************/
--- a/drivers/net/wireless/orinoco.h.10-wireless-handlers	2004-10-26 11:10:25.446963392 -0400
+++ b/drivers/net/wireless/orinoco.h	2004-10-26 12:42:22.112302784 -0400
@@ -23,6 +23,9 @@
 /* To enable debug messages */
 //#define ORINOCO_DEBUG		3
 
+#if (! defined (WIRELESS_EXT)) || (WIRELESS_EXT < 11)
+#error "orinoco driver requires Wireless extensions v11 or later."
+#endif /* (! defined (WIRELESS_EXT)) || (WIRELESS_EXT < 11) */
 #define WIRELESS_SPY		// enable iwspy support
 
 #define ORINOCO_MAX_KEY_SIZE	14
@@ -61,16 +64,21 @@
 #define FIRMWARE_TYPE_AGERE 1
 #define FIRMWARE_TYPE_INTERSIL 2
 #define FIRMWARE_TYPE_SYMBOL 3
-	int has_ibss, has_port3, has_ibss_any, ibss_port;
-	int has_wep, has_big_wep;
-	int has_mwo;
-	int has_pm;
-	int has_preamble;
-	int has_sensitivity;
+	int ibss_port;
+	int has_ibss_any;
 	int nicbuf_size;
 	u16 channel_mask;
-	int broken_disableport;
 
+	/* Boolean capabilities */
+	unsigned int has_ibss:1;
+	unsigned int has_port3:1;
+	unsigned int has_wep:1;
+	unsigned int has_big_wep:1;
+	unsigned int has_mwo:1;
+	unsigned int has_pm:1;
+	unsigned int has_preamble:1;
+	unsigned int has_sensitivity:1;
+	unsigned int broken_disableport:1;
 	unsigned int irq_no_disable:1;
 
 	/* Configuration paramaters */
@@ -81,6 +89,8 @@
 	int bitratemode;
  	char nick[IW_ESSID_MAX_SIZE+1];
 	char desired_essid[IW_ESSID_MAX_SIZE+1];
+	char desired_bssid[ETH_ALEN];
+	int bssid_fixed;
 	u16 frag_thresh, mwo_robust;
 	u16 channel;
 	u16 ap_density, rts_thresh;
