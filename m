From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/9] orinoco: wireless API 15 support
Date: Sun, 19 Jun 2005 01:27:33 +0200
Message-ID: <20050618232733.GD9918@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, proski@gnu.org, hermes@gibson.dropbear.id.au
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


(patch from Moustafa Youssef, updated by Jim Carter and Pavel Roskin).


Index: linux-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/orinoco.c	2005-06-19 01:02:24.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.c	2005-06-19 01:03:24.000000000 +0200
@@ -463,6 +463,7 @@
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <net/iw_handler.h>
 #include <net/ieee80211.h>
 
 #include <asm/uaccess.h>
@@ -538,6 +539,10 @@
 				 | HERMES_EV_WTERR | HERMES_EV_INFO \
 				 | HERMES_EV_INFDROP )
 
+#define MAX_RID_LEN 1024
+
+static const struct iw_handler_def orinoco_handler_def;
+
 /********************************************************************/
 /* Data tables                                                      */
 /********************************************************************/
@@ -605,7 +610,6 @@
 /* Function prototypes                                              */
 /********************************************************************/
 
-static int orinoco_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int __orinoco_program_rids(struct net_device *dev);
 static void __orinoco_set_multicast_list(struct net_device *dev);
 
@@ -1870,55 +1874,6 @@
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
-	if (orinoco_lock(priv, &flags) != 0)
-		return -EBUSY;
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
@@ -2458,7 +2413,7 @@
 	dev->watchdog_timeo = HZ; /* 1 second timeout */
 	dev->get_stats = orinoco_get_stats;
 	dev->get_wireless_stats = orinoco_get_wireless_stats;
-	dev->do_ioctl = orinoco_ioctl;
+	dev->wireless_handlers = (struct iw_handler_def *)&orinoco_handler_def;
 	dev->change_mtu = orinoco_change_mtu;
 	dev->set_multicast_list = orinoco_set_multicast_list;
 	/* we use the default eth_mac_addr for setting the MAC addr */
@@ -2491,24 +2446,6 @@
 /* Wireless extensions                                              */
 /********************************************************************/
 
-static int orinoco_hw_get_bssid(struct orinoco_private *priv,
-				char buf[ETH_ALEN])
-{
-	hermes_t *hw = &priv->hw;
-	int err = 0;
-	unsigned long flags;
-
-	if (orinoco_lock(priv, &flags) != 0)
-		return -EBUSY;
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
@@ -2634,140 +2571,201 @@
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
+	int err;
+
+	err = orinoco_hw_get_bitratelist(priv, &numrates, NULL, 0);
+
+	if (!err && (numrates > 2))
+		strcpy(name, "IEEE 802.11b");
+	else
+		strcpy(name, "IEEE 802.11-DS");
+
+	return 0;
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
 	unsigned long flags;
 
-	TRACE_ENTER(dev->name);
+	if (orinoco_lock(priv, &flags) != 0)
+		return -EBUSY;
 
-	if (!access_ok(VERIFY_WRITE, rrq->pointer, sizeof(range)))
-		return -EFAULT;
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
 
-	rrq->length = sizeof(range);
+	if (priv->iw_mode == *mode)
+		return 0;
 
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
-	mode = priv->iw_mode;
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
 	orinoco_unlock(priv, &flags);
 
-	memset(&range, 0, sizeof(range));
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
 
-	/* Much of this shamelessly taken from wvlan_cs.c. No idea
-	 * what it all means -dgibson */
-	range.we_version_compiled = WIRELESS_EXT;
-	range.we_version_source = 11;
+	rrq->length = sizeof(struct iw_range);
+	memset(range, 0, sizeof(struct iw_range));
 
-	range.min_nwid = range.max_nwid = 0; /* We don't use nwids */
+	range->we_version_compiled = WIRELESS_EXT;
+	range->we_version_source = 14;
 
 	/* Set available channels/frequencies */
-	range.num_channels = NUM_CHANNELS;
+	range->num_channels = NUM_CHANNELS;
 	k = 0;
 	for (i = 0; i < NUM_CHANNELS; i++) {
 		if (priv->channel_mask & (1 << i)) {
-			range.freq[k].i = i + 1;
-			range.freq[k].m = channel_frequency[i] * 100000;
-			range.freq[k].e = 1;
+			range->freq[k].i = i + 1;
+			range->freq[k].m = channel_frequency[i] * 100000;
+			range->freq[k].e = 1;
 			k++;
 		}
 		
 		if (k >= IW_MAX_FREQUENCIES)
 			break;
 	}
-	range.num_frequency = k;
+	range->num_frequency = k;
+	range->sensitivity = 3;
 
-	range.sensitivity = 3;
+	if (priv->has_wep) {
+		range->max_encoding_tokens = ORINOCO_MAX_KEYS;
+		range->encoding_size[0] = SMALL_KEY_SIZE;
+		range->num_encoding_sizes = 1;
+
+		if (priv->has_big_wep) {
+			range->encoding_size[1] = LARGE_KEY_SIZE;
+			range->num_encoding_sizes = 2;
+		}
+	}
 
-	if ((mode == IW_MODE_ADHOC) && (priv->spy_number == 0)){
+	if ((priv->iw_mode == IW_MODE_ADHOC) && (priv->spy_number == 0)){
 		/* Quality stats meaningless in ad-hoc mode */
-		range.max_qual.qual = 0;
-		range.max_qual.level = 0;
-		range.max_qual.noise = 0;
-		range.avg_qual.qual = 0;
-		range.avg_qual.level = 0;
-		range.avg_qual.noise = 0;
 	} else {
-		range.max_qual.qual = 0x8b - 0x2f;
-		range.max_qual.level = 0x2f - 0x95 - 1;
-		range.max_qual.noise = 0x2f - 0x95 - 1;
+		range->max_qual.qual = 0x8b - 0x2f;
+		range->max_qual.level = 0x2f - 0x95 - 1;
+		range->max_qual.noise = 0x2f - 0x95 - 1;
 		/* Need to get better values */
-		range.avg_qual.qual = 0x24;
-		range.avg_qual.level = 0xC2;
-		range.avg_qual.noise = 0x9E;
+		range->avg_qual.qual = 0x24;
+		range->avg_qual.level = 0xC2;
+		range->avg_qual.noise = 0x9E;
 	}
 
 	err = orinoco_hw_get_bitratelist(priv, &numrates,
-					 range.bitrate, IW_MAX_BITRATES);
+					 range->bitrate, IW_MAX_BITRATES);
 	if (err)
 		return err;
-	range.num_bitrates = numrates;
-	
+	range->num_bitrates = numrates;
+
 	/* Set an indication of the max TCP throughput in bit/s that we can
 	 * expect using this interface. May be use for QoS stuff...
 	 * Jean II */
-	if(numrates > 2)
-		range.throughput = 5 * 1000 * 1000;	/* ~5 Mb/s */
+	if (numrates > 2)
+		range->throughput = 5 * 1000 * 1000;	/* ~5 Mb/s */
 	else
-		range.throughput = 1.5 * 1000 * 1000;	/* ~1.5 Mb/s */
-
-	range.min_rts = 0;
-	range.max_rts = 2347;
-	range.min_frag = 256;
-	range.max_frag = 2346;
-
-	if (orinoco_lock(priv, &flags) != 0)
-		return -EBUSY;
-	if (priv->has_wep) {
-		range.max_encoding_tokens = ORINOCO_MAX_KEYS;
-
-		range.encoding_size[0] = SMALL_KEY_SIZE;
-		range.num_encoding_sizes = 1;
-
-		if (priv->has_big_wep) {
-			range.encoding_size[1] = LARGE_KEY_SIZE;
-			range.num_encoding_sizes = 2;
-		}
-	} else {
-		range.num_encoding_sizes = 0;
-		range.max_encoding_tokens = 0;
-	}
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
+		range->throughput = 1.5 * 1000 * 1000;	/* ~1.5 Mb/s */
 
-	if (copy_to_user(rrq->pointer, &range, sizeof(range)))
-		return -EFAULT;
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
@@ -2775,8 +2773,7 @@
 	int enable = priv->wep_on;
 	int restricted = priv->wep_restrict;
 	u16 xlen = 0;
-	int err = 0;
-	char keybuf[ORINOCO_MAX_KEY_SIZE];
+	int err = -EINPROGRESS;		/* Call commit handler */
 	unsigned long flags;
 
 	if (! priv->has_wep)
@@ -2789,9 +2786,6 @@
 
 		if ( (erq->length > SMALL_KEY_SIZE) && !priv->has_big_wep )
 			return -E2BIG;
-		
-		if (copy_from_user(keybuf, erq->pointer, erq->length))
-			return -EFAULT;
 	}
 
 	if (orinoco_lock(priv, &flags) != 0)
@@ -2865,12 +2859,14 @@
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
 	unsigned long flags;
 
 	if (! priv->has_wep)
@@ -2899,51 +2895,47 @@
 	memcpy(keybuf, priv->keys[index].data, ORINOCO_MAX_KEY_SIZE);
 
 	orinoco_unlock(priv, &flags);
-
-	if (erq->pointer) {
-		if (copy_to_user(erq->pointer, keybuf, xlen))
-			return -EFAULT;
-	}
-
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
 	unsigned long flags;
 
 	/* Note : ESSID is ignored in Ad-Hoc demo mode, but we can set it
 	 * anyway... - Jean II */
 
-	memset(&essidbuf, 0, sizeof(essidbuf));
-
-	if (erq->flags) {
-		/* iwconfig includes the NUL in the specified length */
-		if (erq->length > IW_ESSID_MAX_SIZE+1)
-			return -E2BIG;
-		
-		if (copy_from_user(&essidbuf, erq->pointer, erq->length))
-			return -EFAULT;
-
-		essidbuf[IW_ESSID_MAX_SIZE] = '\0';
-	}
+	/* Hum... Should not use Wireless Extension constant (may change),
+	 * should use our own... - Jean II */
+	if (erq->length > IW_ESSID_MAX_SIZE)
+		return -E2BIG;
 
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
-	memcpy(priv->desired_essid, essidbuf, sizeof(priv->desired_essid));
+	/* NULL the string (for NULL termination & ESSID = ANY) - Jean II */
+	memset(priv->desired_essid, 0, sizeof(priv->desired_essid));
+
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
@@ -2957,51 +2949,46 @@
 	} else {
 		if (orinoco_lock(priv, &flags) != 0)
 			return -EBUSY;
-		memcpy(essidbuf, priv->desired_essid, sizeof(essidbuf));
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
 	unsigned long flags;
 
 	if (nrq->length > IW_ESSID_MAX_SIZE)
 		return -E2BIG;
 
-	memset(nickbuf, 0, sizeof(nickbuf));
-
-	if (copy_from_user(nickbuf, nrq->pointer, nrq->length))
-		return -EFAULT;
-
-	nickbuf[nrq->length] = '\0';
-	
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
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
 	unsigned long flags;
 
 	if (orinoco_lock(priv, &flags) != 0)
@@ -3012,17 +2999,18 @@
 
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
 	unsigned long flags;
+	int err = -EINPROGRESS;		/* Call commit handler */
 
 	/* We can only use this in Ad-Hoc demo mode to set the operating
 	 * frequency, or in IBSS mode to set the frequency where the IBSS
@@ -3055,10 +3043,33 @@
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
@@ -3084,7 +3095,10 @@
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
@@ -3101,10 +3115,13 @@
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
@@ -3122,13 +3139,30 @@
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
+
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
 
 	if (orinoco_lock(priv, &flags) != 0)
@@ -3160,11 +3194,14 @@
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
 
@@ -3197,10 +3234,12 @@
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
@@ -3236,10 +3275,13 @@
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
@@ -3304,10 +3346,13 @@
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
 
 	if (orinoco_lock(priv, &flags) != 0)
@@ -3356,7 +3401,10 @@
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
@@ -3404,7 +3452,10 @@
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
@@ -3455,10 +3506,38 @@
 	return err;
 }
 
-static int orinoco_ioctl_setibssport(struct net_device *dev, struct iwreq *wrq)
+static int orinoco_ioctl_reset(struct net_device *dev,
+			       struct iw_request_info *info,
+			       void *wrqu,
+			       char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
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
+
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int val = *( (int *) wrq->u.name );
+	int val = *( (int *) extra );
 	unsigned long flags;
 
 	if (orinoco_lock(priv, &flags) != 0)
@@ -3470,28 +3549,28 @@
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
-	unsigned long flags;
-
-	if (orinoco_lock(priv, &flags) != 0)
-		return -EBUSY;
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
 
@@ -3520,51 +3599,131 @@
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
 {
 	struct orinoco_private *priv = netdev_priv(dev);
-	int *val = (int *)wrq->u.name;
 	unsigned long flags;
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
 
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
-	*val = priv->prefer_port3;
+	if (val)
+		priv->preamble = 1;
+	else
+		priv->preamble = 0;
+
 	orinoco_unlock(priv, &flags);
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
 	return 0;
 }
 
+/* ioctl interface to hermes_read_ltv()
+ * To use with iwpriv, pass the RID as the token argument, e.g.
+ * iwpriv get_rid [0xfc00]
+ * At least Wireless Tools 25 is required to use iwpriv.
+ * For Wireless Tools 25 and 26 append "dummy" are the end. */
+static int orinoco_ioctl_getrid(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_point *data,
+				char *extra)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	hermes_t *hw = &priv->hw;
+	int rid = data->flags;
+	u16 length;
+	int err;
+	unsigned long flags;
+
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
+	if (err)
+		goto out;
+
+	data->length = min_t(u16, HERMES_RECLEN_TO_BYTES(length),
+			     MAX_RID_LEN);
+
+ out:
+	orinoco_unlock(priv, &flags);
+	return err;
+}
+
 /* Spy is used for link quality/strength measurements in Ad-Hoc mode
  * Jean II */
-static int orinoco_ioctl_setspy(struct net_device *dev, struct iw_point *srq)
+static int orinoco_ioctl_setspy(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_point *srq,
+				char *extra)
+
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
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
@@ -3588,14 +3747,17 @@
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
 	unsigned long flags;
@@ -3604,7 +3766,12 @@
 		return -EBUSY;
 
 	number = priv->spy_number;
-	if ((number > 0) && (srq->pointer)) {
+	/* Create address struct */
+	for (i = 0; i < number; i++) {
+		memcpy(address[i].sa_data, priv->spy_address[i], ETH_ALEN);
+		address[i].sa_family = AF_UNIX;
+	}
+	if (number > 0) {
 		/* Create address struct */
 		for (i = 0; i < number; i++) {
 			memcpy(address[i].sa_data, priv->spy_address[i],
@@ -3615,344 +3782,153 @@
 		/* In theory, we should disable irqs while copying the stats
 		 * because the rx path might update it in the middle...
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
-	struct iwreq *wrq = (struct iwreq *)rq;
-	int err = 0;
-	int tmp;
-	int changed = 0;
+	struct hermes *hw = &priv->hw;
 	unsigned long flags;
+	int err = 0;
 
-	TRACE_ENTER(dev->name);
-
-	/* In theory, we could allow most of the the SET stuff to be
-	 * done. In practice, the lapse of time at startup when the
-	 * card is not ready is very short, so why bother...  Note
-	 * that netif_device_present is different from up/down
-	 * (ifconfig), when the device is not yet up, it is usually
-	 * already ready...  Jean II */
-	if (! netif_device_present(dev))
-		return -ENODEV;
-
-	switch (cmd) {
-	case SIOCGIWNAME:
-		strcpy(wrq->u.name, "IEEE 802.11-DS");
-		break;
-		
-	case SIOCGIWAP:
-		wrq->u.ap_addr.sa_family = ARPHRD_ETHER;
-		err = orinoco_hw_get_bssid(priv, wrq->u.ap_addr.sa_data);
-		break;
-
-	case SIOCGIWRANGE:
-		err = orinoco_ioctl_getiwrange(dev, &wrq->u.data);
-		break;
-
-	case SIOCSIWMODE:
-		if (orinoco_lock(priv, &flags) != 0)
-			return -EBUSY;
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
-		break;
-
-	case SIOCGIWMODE:
-		if (orinoco_lock(priv, &flags) != 0)
-			return -EBUSY;
-		wrq->u.mode = priv->iw_mode;
-		orinoco_unlock(priv, &flags);
-		break;
-
-	case SIOCSIWENCODE:
-		err = orinoco_ioctl_setiwencode(dev, &wrq->u.encoding);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCGIWENCODE:
-		if (! capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
-		}
-
-		err = orinoco_ioctl_getiwencode(dev, &wrq->u.encoding);
-		break;
-
-	case SIOCSIWESSID:
-		err = orinoco_ioctl_setessid(dev, &wrq->u.essid);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCGIWESSID:
-		err = orinoco_ioctl_getessid(dev, &wrq->u.essid);
-		break;
-
-	case SIOCSIWNICKN:
-		err = orinoco_ioctl_setnick(dev, &wrq->u.data);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCGIWNICKN:
-		err = orinoco_ioctl_getnick(dev, &wrq->u.data);
-		break;
-
-	case SIOCGIWFREQ:
-		tmp = orinoco_hw_get_freq(priv);
-		if (tmp < 0) {
-			err = tmp;
-		} else {
-			wrq->u.freq.m = tmp;
-			wrq->u.freq.e = 1;
-		}
-		break;
-
-	case SIOCSIWFREQ:
-		err = orinoco_ioctl_setfreq(dev, &wrq->u.freq);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCGIWSENS:
-		err = orinoco_ioctl_getsens(dev, &wrq->u.sens);
-		break;
-
-	case SIOCSIWSENS:
-		err = orinoco_ioctl_setsens(dev, &wrq->u.sens);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCGIWRTS:
-		wrq->u.rts.value = priv->rts_thresh;
-		wrq->u.rts.disabled = (wrq->u.rts.value == 2347);
-		wrq->u.rts.fixed = 1;
-		break;
-
-	case SIOCSIWRTS:
-		err = orinoco_ioctl_setrts(dev, &wrq->u.rts);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCSIWFRAG:
-		err = orinoco_ioctl_setfrag(dev, &wrq->u.frag);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCGIWFRAG:
-		err = orinoco_ioctl_getfrag(dev, &wrq->u.frag);
-		break;
-
-	case SIOCSIWRATE:
-		err = orinoco_ioctl_setrate(dev, &wrq->u.bitrate);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCGIWRATE:
-		err = orinoco_ioctl_getrate(dev, &wrq->u.bitrate);
-		break;
-
-	case SIOCSIWPOWER:
-		err = orinoco_ioctl_setpower(dev, &wrq->u.power);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCGIWPOWER:
-		err = orinoco_ioctl_getpower(dev, &wrq->u.power);
-		break;
+	if (!priv->open)
+		return 0;
 
-	case SIOCGIWTXPOW:
-		/* The card only supports one tx power, so this is easy */
-		wrq->u.txpower.value = 15; /* dBm */
-		wrq->u.txpower.fixed = 1;
-		wrq->u.txpower.disabled = 0;
-		wrq->u.txpower.flags = IW_TXPOW_DBM;
-		break;
+	if (priv->broken_disableport) {
+		orinoco_reset(dev);
+		return 0;
+	}
 
-	case SIOCSIWRETRY:
-		err = -EOPNOTSUPP;
-		break;
+	if (orinoco_lock(priv, &flags) != 0)
+		return err;
 
-	case SIOCGIWRETRY:
-		err = orinoco_ioctl_getretry(dev, &wrq->u.retry);
-		break;
+	err = hermes_disable_port(hw, 0);
+	if (err) {
+		printk(KERN_WARNING "%s: Unable to disable port "
+		       "while reconfiguring card\n", dev->name);
+		priv->broken_disableport = 1;
+		goto out;
+	}
 
-	case SIOCSIWSPY:
-		err = orinoco_ioctl_setspy(dev, &wrq->u.data);
-		break;
+	err = __orinoco_program_rids(dev);
+	if (err) {
+		printk(KERN_WARNING "%s: Unable to reconfigure card\n",
+		       dev->name);
+		goto out;
+	}
 
-	case SIOCGIWSPY:
-		err = orinoco_ioctl_getspy(dev, &wrq->u.data);
-		break;
-
-	case SIOCGIWPRIV:
-		if (wrq->u.data.pointer) {
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
-			};
-
-			wrq->u.data.length = sizeof(privtab) / sizeof(privtab[0]);
-			if (copy_to_user(wrq->u.data.pointer, privtab, sizeof(privtab)))
-				err = -EFAULT;
-		}
-		break;
-	       
-	case SIOCIWFIRSTPRIV + 0x0: /* force_reset */
-	case SIOCIWFIRSTPRIV + 0x1: /* card_reset */
-		if (! capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
-		}
-		
-		printk(KERN_DEBUG "%s: Force scheduling reset!\n", dev->name);
+	err = hermes_enable_port(hw, 0);
+	if (err) {
+		printk(KERN_WARNING "%s: Unable to enable port while reconfiguring card\n",
+		       dev->name);
+		goto out;
+	}
 
+ out:
+	if (err) {
+		printk(KERN_WARNING "%s: Resetting instead...\n", dev->name);
 		schedule_work(&priv->reset_work);
-		break;
-
-	case SIOCIWFIRSTPRIV + 0x2: /* set_port3 */
-		if (! capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
-		}
-
-		err = orinoco_ioctl_setport3(dev, wrq);
-		if (! err)
-			changed = 1;
-		break;
-
-	case SIOCIWFIRSTPRIV + 0x3: /* get_port3 */
-		err = orinoco_ioctl_getport3(dev, wrq);
-		break;
-
-	case SIOCIWFIRSTPRIV + 0x4: /* set_preamble */
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
-			if (orinoco_lock(priv, &flags) != 0)
-				return -EBUSY;
-			if (val)
-				priv->preamble = 1;
-			else
-				priv->preamble = 0;
-			orinoco_unlock(priv, &flags);
-			changed = 1;
-		} else
-			err = -EOPNOTSUPP;
-		break;
+		err = 0;
+	}
 
-	case SIOCIWFIRSTPRIV + 0x5: /* get_preamble */
-		if(priv->has_preamble) {
-			int *val = (int *)wrq->u.name;
-
-			if (orinoco_lock(priv, &flags) != 0)
-				return -EBUSY;
-			*val = priv->preamble;
-			orinoco_unlock(priv, &flags);
-		} else
-			err = -EOPNOTSUPP;
-		break;
-	case SIOCIWFIRSTPRIV + 0x6: /* set_ibssport */
-		if (! capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
-		}
+	orinoco_unlock(priv, &flags);
+	return err;
+}
 
-		err = orinoco_ioctl_setibssport(dev, wrq);
-		if (! err)
-			changed = 1;
-		break;
+static const struct iw_priv_args orinoco_privtab[] = {
+	{ SIOCIWFIRSTPRIV + 0x0, 0, 0, "force_reset" },
+	{ SIOCIWFIRSTPRIV + 0x1, 0, 0, "card_reset" },
+	{ SIOCIWFIRSTPRIV + 0x2, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  0, "set_port3" },
+	{ SIOCIWFIRSTPRIV + 0x3, 0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  "get_port3" },
+	{ SIOCIWFIRSTPRIV + 0x4, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  0, "set_preamble" },
+	{ SIOCIWFIRSTPRIV + 0x5, 0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  "get_preamble" },
+	{ SIOCIWFIRSTPRIV + 0x6, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  0, "set_ibssport" },
+	{ SIOCIWFIRSTPRIV + 0x7, 0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  "get_ibssport" },
+	{ SIOCIWFIRSTPRIV + 0x9, 0, IW_PRIV_TYPE_BYTE | MAX_RID_LEN,
+	  "get_rid" },
+};
 
-	case SIOCIWFIRSTPRIV + 0x7: /* get_ibssport */
-		err = orinoco_ioctl_getibssport(dev, wrq);
-		break;
 
-	default:
-		err = -EOPNOTSUPP;
-	}
-	
-	if (! err && changed && netif_running(dev)) {
-		err = orinoco_reconfigure(dev);
-	}		
+/*
+ * Structures to export the Wireless Handlers
+ */
+
+static const iw_handler	orinoco_handler[] = {
+	[SIOCSIWCOMMIT-SIOCIWFIRST] (iw_handler) orinoco_ioctl_commit,
+	[SIOCGIWNAME  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getname,
+	[SIOCSIWFREQ  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setfreq,
+	[SIOCGIWFREQ  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getfreq,
+	[SIOCSIWMODE  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setmode,
+	[SIOCGIWMODE  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getmode,
+	[SIOCSIWSENS  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setsens,
+	[SIOCGIWSENS  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getsens,
+	[SIOCGIWRANGE -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getiwrange,
+	[SIOCSIWSPY   -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setspy,
+	[SIOCGIWSPY   -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getspy,
+	[SIOCGIWAP    -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getwap,
+	[SIOCSIWESSID -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setessid,
+	[SIOCGIWESSID -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getessid,
+	[SIOCSIWNICKN -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setnick,
+	[SIOCGIWNICKN -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getnick,
+	[SIOCSIWRATE  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setrate,
+	[SIOCGIWRATE  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getrate,
+	[SIOCSIWRTS   -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setrts,
+	[SIOCGIWRTS   -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getrts,
+	[SIOCSIWFRAG  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setfrag,
+	[SIOCGIWFRAG  -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getfrag,
+	[SIOCGIWRETRY -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getretry,
+	[SIOCSIWENCODE-SIOCIWFIRST] (iw_handler) orinoco_ioctl_setiwencode,
+	[SIOCGIWENCODE-SIOCIWFIRST] (iw_handler) orinoco_ioctl_getiwencode,
+	[SIOCSIWPOWER -SIOCIWFIRST] (iw_handler) orinoco_ioctl_setpower,
+	[SIOCGIWPOWER -SIOCIWFIRST] (iw_handler) orinoco_ioctl_getpower,
+};
 
-	TRACE_EXIT(dev->name);
 
-	return err;
-}
+/*
+  Added typecasting since we no longer use iwreq_data -- Moustafa
+ */
+static const iw_handler	orinoco_private_handler[] = {
+	[0] (iw_handler) orinoco_ioctl_reset,
+	[1] (iw_handler) orinoco_ioctl_reset,
+	[2] (iw_handler) orinoco_ioctl_setport3,
+	[3] (iw_handler) orinoco_ioctl_getport3,
+	[4] (iw_handler) orinoco_ioctl_setpreamble,
+	[5] (iw_handler) orinoco_ioctl_getpreamble,
+	[6] (iw_handler) orinoco_ioctl_setibssport,
+	[7] (iw_handler) orinoco_ioctl_getibssport,
+	[9] (iw_handler) orinoco_ioctl_getrid,
+};
 
+static const struct iw_handler_def orinoco_handler_def = {
+	.num_standard = ARRAY_SIZE(orinoco_handler),
+	.num_private = ARRAY_SIZE(orinoco_private_handler),
+	.num_private_args = ARRAY_SIZE(orinoco_privtab),
+	.standard = orinoco_handler,
+	.private = orinoco_private_handler,
+	.private_args = orinoco_privtab,
+};
 
 /********************************************************************/
 /* Debugging                                                        */
