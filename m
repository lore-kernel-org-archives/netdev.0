From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 5/9] orinoco: manual roaming for Symbol and Intersilfirmware
Date: Sun, 19 Jun 2005 01:27:51 +0200
Message-ID: <20050618232751.GF9918@lst.de>
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

Index: linux-2.6/drivers/net/wireless/orinoco.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/orinoco.h	2005-06-19 01:03:36.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.h	2005-06-19 01:03:47.000000000 +0200
@@ -22,6 +22,8 @@
 
 #define WIRELESS_SPY		// enable iwspy support
 
+#define MAX_SCAN_LEN		4096
+
 #define ORINOCO_MAX_KEY_SIZE	14
 #define ORINOCO_MAX_KEYS	4
 
@@ -48,6 +50,7 @@
 	/* driver state */
 	int open;
 	u16 last_linkstatus;
+	struct work_struct join_work;
 
 	/* Net device stuff */
 	struct net_device *ndev;
@@ -84,6 +87,8 @@
 	int bitratemode;
  	char nick[IW_ESSID_MAX_SIZE+1];
 	char desired_essid[IW_ESSID_MAX_SIZE+1];
+	char desired_bssid[ETH_ALEN];
+	int bssid_fixed;
 	u16 frag_thresh, mwo_robust;
 	u16 channel;
 	u16 ap_density, rts_thresh;
Index: linux-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/orinoco.c	2005-06-19 01:03:43.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.c	2005-06-19 01:03:47.000000000 +0200
@@ -1247,6 +1247,75 @@
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
+	u8 *buf;
+	u16 len;
+
+	/* Allocate buffer for scan results */
+	buf = kmalloc(MAX_SCAN_LEN, GFP_KERNEL);
+	if (! buf)
+		return;
+
+	if (orinoco_lock(priv, &flags) != 0)
+		goto out;
+
+	/* Sanity checks in case user changed something in the meantime */
+	if (! priv->bssid_fixed)
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
+		if (memcmp(&atom->bssid, priv->desired_bssid, ETH_ALEN) == 0)
+			goto found;
+	}
+
+	DEBUG(1, "%s: Requested AP not found in scan results\n",
+	      dev->name);
+	goto out;
+
+ found:
+	memcpy(req.bssid, priv->desired_bssid, ETH_ALEN);
+	req.channel = atom->channel;	/* both are little-endian */
+	err = HERMES_WRITE_RECORD(hw, USER_BAP, HERMES_RID_CNFJOINREQUEST,
+				  &req);
+	if (err)
+		printk(KERN_ERR "%s: Error issuing join request\n", dev->name);
+
+ out:
+	kfree(buf);
+	orinoco_unlock(priv, &flags);
+}
+
 static void __orinoco_ev_info(struct net_device *dev, hermes_t *hw)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
@@ -1477,6 +1546,36 @@
 	return err;
 }
 
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
 /* Change the WEP keys and/or the current keys.  Can be called
  * either from __orinoco_hw_setup_wep() or directly from
  * orinoco_ioctl_setiwencode().  In the later case the association
@@ -1662,6 +1761,13 @@
 		}
 	}
 
+	/* Set the desired BSSID */
+	err = __orinoco_hw_set_wap(priv);
+	if (err) {
+		printk(KERN_ERR "%s: Error %d setting AP address\n",
+		       dev->name, err);
+		return err;
+	}
 	/* Set the desired ESSID */
 	idbuf.len = cpu_to_le16(strlen(priv->desired_essid));
 	memcpy(&idbuf.val, priv->desired_essid, sizeof(idbuf.val));
@@ -2432,6 +2538,7 @@
 				   * before anything else touches the
 				   * hardware */
 	INIT_WORK(&priv->reset_work, (void (*)(void *))orinoco_reset, dev);
+	INIT_WORK(&priv->join_work, (void (*)(void *))orinoco_join_ap, dev);
 
 	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
@@ -2593,6 +2700,67 @@
 	return 0;
 }
 
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
+
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
+
+	/* Enable automatic roaming - no sanity checks are needed */
+	if (memcmp(&ap_addr->sa_data, off_addr, ETH_ALEN) == 0 ||
+	    memcmp(&ap_addr->sa_data, any_addr, ETH_ALEN) == 0) {
+		priv->bssid_fixed = 0;
+		memset(priv->desired_bssid, 0, ETH_ALEN);
+
+		/* "off" means keep existing connection */
+		if (ap_addr->sa_data[0] == 0) {
+			__orinoco_hw_set_wap(priv);
+			err = 0;
+		}
+		goto out;
+	}
+
+	if (priv->firmware_type == FIRMWARE_TYPE_AGERE) {
+		printk(KERN_WARNING "%s: Lucent/Agere firmware doesn't "
+		       "support manual roaming\n",
+		       dev->name);
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (priv->iw_mode != IW_MODE_INFRA) {
+		printk(KERN_WARNING "%s: Manual roaming supported only in "
+		       "managed mode\n", dev->name);
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	/* Intersil firmware hangs without Desired ESSID */
+	if (priv->firmware_type == FIRMWARE_TYPE_INTERSIL &&
+	    strlen(priv->desired_essid) == 0) {
+		printk(KERN_WARNING "%s: Desired ESSID must be set for "
+		       "manual roaming\n", dev->name);
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	/* Finally, enable manual roaming */
+	priv->bssid_fixed = 1;
+	memcpy(priv->desired_bssid, &ap_addr->sa_data, ETH_ALEN);
+
+ out:
+	orinoco_unlock(priv, &flags);
+	return err;
+}
+
 static int orinoco_ioctl_getwap(struct net_device *dev,
 				struct iw_request_info *info,
 				struct sockaddr *ap_addr,
@@ -3890,6 +4058,7 @@
 	[SIOCGIWRANGE -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getiwrange,
 	[SIOCSIWSPY   -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setspy,
 	[SIOCGIWSPY   -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getspy,
+	[SIOCSIWAP    -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setwap,
 	[SIOCGIWAP    -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getwap,
 	[SIOCSIWESSID -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setessid,
 	[SIOCGIWESSID -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getessid,
