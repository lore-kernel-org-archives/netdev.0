From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: [PATCH 01/3] d80211:  add support for SIOCSIWRATE, SIOCSIWTXPOW and
 SIOCSIWPOWER
Date: Mon, 21 Aug 2006 17:30:22 -0700
Message-ID: <44EA501E.4010605@linux.intel.com>
References: <20060821074107.648561364@sipsolutions.net> <20060821075158.728615077@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000202000402050908080101"
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:9033 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750939AbWHVAad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 20:30:33 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060821075158.728615077@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000202000402050908080101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

the attached patch will add support to handle these iw_handle 
SIOC[S/G]IWRATE, SIOC[S/G]IWTXPOW and SIOC[S/G]IWPOWER.  It also  added 
some changes in ieee80211_ioctl_giwrange function to report supported 
channels and rates.  a call to ieee80211_hw_config is needed to infor 
the low level driver about these changes, I guess we might need to add 
flag to indicate which parameters was changed so the low level driver 
does not need to make extra calls.


--------------000202000402050908080101
Content-Type: text/plain;
 name="d80211-add-more-wireless-tool-cmd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-add-more-wireless-tool-cmd.patch"

diff --git a/include/net/d80211.h b/include/net/d80211.h
index ba5cb4c..0cde91f 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -256,6 +256,7 @@ struct ieee80211_conf {
         u8 antenna_max;			/* maximum antenna gain */
 	short tx_power_reduction; /* in 0.1 dBm */
 
+	u8 power_management_enable;     /* flag to enable/disable power management*/
 	int antenna_sel;		/* default antenna conf:
 					 *	0 = default/diversity,
 			  		 *	1 = Ant0,
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 11804d5..86a5373 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1250,6 +1250,10 @@ static int ieee80211_tx(struct net_devic
 			break;
 	}
 
+	/* only data unicast frame */
+	if ((tx.u.tx.rate) && !mgmt && !control->no_ack)
+		local->last_rate = tx.u.tx.rate->rate * 100000;
+
 	skb = tx.skb; /* handlers are allowed to change skb */
 
 	if (sta)
@@ -4358,6 +4362,8 @@ struct net_device *ieee80211_alloc_hw(si
 	local->long_retry_limit = 4;
 	local->conf.calib_int = 60;
 	local->conf.radio_enabled = 1;
+	local->last_rate = -1;
+	local->conf.power_management_enable = 0;
 	local->rate_ctrl_num_up = RATE_CONTROL_NUM_UP;
 	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index bdaaf5e..29c40c5 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -396,6 +396,9 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	int *supp_rates[NUM_IEEE80211_MODES];
 	int *basic_rates[NUM_IEEE80211_MODES];
 
+	u32 last_rate; /* last tx data rate value. management and multi cast frame
+			* wont be used. */
+
 	int rts_threshold;
 	int cts_protect_erp_frames;
 	int fragmentation_threshold;
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index b983716..5e01659 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1537,6 +1537,19 @@ static int ieee80211_ioctl_giwname(struc
 				   char *name, char *extra)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_sub_if_data *sdata;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+        if (!local->conf.radio_enabled) {
+        	strcpy(name, "radio off");
+                return 0;
+	} else if (sdata->type == IEEE80211_IF_TYPE_STA) {
+        	if (!(sdata->u.sta.associated) ||
+                     (sdata->u.sta.probereq_poll)) {
+			strcpy(name, "unassociated");
+			return 0;
+		}
+        }
 
 	switch (local->conf.phymode) {
 	case MODE_IEEE80211A:
@@ -1565,6 +1578,9 @@ static int ieee80211_ioctl_giwrange(stru
 				 struct iw_point *data, char *extra)
 {
 	struct iw_range *range = (struct iw_range *) extra;
+	int i,j,c;
+	int skip_bg = 0;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	data->length = sizeof(struct iw_range);
 	memset(range, 0, sizeof(struct iw_range));
@@ -1580,6 +1596,42 @@ static int ieee80211_ioctl_giwrange(stru
 	range->min_frag = 256;
 	range->max_frag = 2346;
 
+	j = 0;
+        for (i = 0; i < local->num_curr_rates ; i++) {
+                struct ieee80211_rate *rate = &local->curr_rates[i];
+
+                if (rate->flags & IEEE80211_RATE_SUPPORTED) {
+			range->bitrate[j] = rate->rate * 100000;
+			j++;
+		}
+	}
+	range->num_bitrates = j;
+
+	c = 0;
+        for (i = 0; i < local->hw->num_modes; i++) {
+                struct ieee80211_hw_modes *mode = &local->hw->modes[i];
+		if (skip_bg &&
+                    ((mode->mode == MODE_IEEE80211G) ||
+                    (mode->mode == MODE_IEEE80211B)))
+			continue;
+
+		for (j = 0; 
+		     j < mode->num_channels && c < IW_MAX_FREQUENCIES; j++) {
+			struct ieee80211_channel *chan = &mode->channels[j];
+
+                        range->freq[c].i = chan->chan;
+                        range->freq[c].m = chan->freq * 100000;
+                        range->freq[c].e = 1;
+			c++;
+		}
+		if ((mode->mode == MODE_IEEE80211G) || 
+		    (mode->mode == MODE_IEEE80211B))
+			skip_bg = 1;
+
+	}
+        range->num_channels = c;
+        range->num_frequency = c;
+
 	return 0;
 }
 
@@ -2138,6 +2190,169 @@ static int ieee80211_ioctl_giwretry(stru
 }
 
 
+static int ieee80211_ioctl_siwrate(struct net_device *dev,
+                           struct iw_request_info *info,
+                           union iwreq_data *wrqu, char *extra)
+{
+        struct ieee80211_local *local = dev->ieee80211_ptr;
+        int i, j;
+        u32 target_rate = wrqu->bitrate.value /100000;
+        u32 fixed;
+	int *old_supp = local->supp_rates[local->conf.phymode];
+	int *supp = NULL;
+
+        /* value = -1, fixed = 0 means auto only, so we should use
+         * all rates offered by AP
+         * value = X, fixed = 1 means only rate X
+         * value = X, fixed = 0 means all rates lower equal X */
+        if (target_rate == -1) {
+                fixed = 0;
+                goto apply;
+        }
+
+        fixed = wrqu->bitrate.fixed;
+	supp = (int *) kmalloc((local->num_curr_rates + 1) * 
+					sizeof(int), GFP_KERNEL);
+	if (!supp)
+		return 0;
+
+	j = 0;
+	for (i=0; i< local->num_curr_rates; i++) {
+		struct ieee80211_rate *rate = &local->curr_rates[i];
+
+		if (target_rate == rate->rate) {
+			supp[j++] = rate->rate;
+			break;
+		} else if (!fixed)
+			supp[j++] = rate->rate;
+	}
+
+	supp[j] = -1;
+
+        if ((j >= local->num_curr_rates) || (j == 0)) {
+                kfree(supp);
+                supp = NULL;
+        }
+
+     apply:
+	if (!old_supp && !supp)
+		return 0;
+
+        local->supp_rates[local->conf.phymode] = supp;
+	if (old_supp)
+        	kfree(old_supp);
+
+	
+	ieee80211_prepare_rates(dev);
+	ieee80211_hw_config(dev);
+        return 0;
+}
+
+static int ieee80211_ioctl_giwrate(struct net_device *dev,
+                           struct iw_request_info *info,
+                           union iwreq_data *wrqu, char *extra)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+        u32 max_rate = 0;
+	int i;
+
+        for (i = local->num_curr_rates - 1; i >= 0 ; i--) {
+                struct ieee80211_rate *rate = &local->curr_rates[i];
+
+		if (rate->flags & IEEE80211_RATE_SUPPORTED) {	
+			max_rate = rate->rate * 100000;
+			break;
+		}
+	}
+
+        if (max_rate >= local->last_rate)
+                wrqu->bitrate.value = local->last_rate;
+        else
+                wrqu->bitrate.value = max_rate;
+        return 0;
+}
+
+static int ieee80211_ioctl_giwtxpow(struct net_device *dev,
+                            struct iw_request_info *info,
+                            union iwreq_data *wrqu, char *extra)
+{
+	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
+
+	wrqu->txpower.flags = IW_TXPOW_DBM;
+        wrqu->txpower.fixed = 1;
+        wrqu->txpower.disabled = (conf->radio_enabled) ? 0 : 1;
+	wrqu->txpower.value = conf->power_level;
+        return 0;
+}
+
+
+static int ieee80211_ioctl_siwtxpow(struct net_device *dev,
+                            struct iw_request_info *info,
+                            union iwreq_data *wrqu, char *extra)
+{
+	int rc = 0;
+	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
+
+	/* we need to add flag in ieee80211_conf to mark the changed fields.
+	*/
+        if (wrqu->txpower.flags != IW_TXPOW_DBM) 
+                rc = -EINVAL;
+	else
+		conf->power_level = wrqu->txpower.value;
+        
+
+	ieee80211_ioctl_set_radio_enabled(dev, !wrqu->txpower.disabled);
+        return rc;
+}
+
+static int ieee80211_ioctl_siwpower(struct net_device *dev,
+                            struct iw_request_info *info,
+                            union iwreq_data *wrqu, char *extra)
+{
+	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
+
+        /* We might need to add new callback function instead of
+           calling ieee80211_hw_config
+	*/
+	if (wrqu->power.disabled) {
+		conf->power_management_enable = 0;
+		ieee80211_hw_config(dev);
+		return 0;
+        }
+
+        if (wrqu->power.flags & IW_POWER_TYPE) 
+                return -EOPNOTSUPP;
+
+        switch (wrqu->power.flags & IW_POWER_MODE) {
+        case IW_POWER_ON:       /* If not specified */
+        case IW_POWER_MODE:     /* If set all mask */
+        case IW_POWER_ALL_R:    /* If explicitely state all */
+                break;
+        default:                /* Otherwise we don't support it */
+                return -EOPNOTSUPP;
+        }
+
+	conf->power_management_enable = 1;
+	ieee80211_hw_config(dev);
+
+        return 0;
+}
+
+static int ieee80211_ioctl_giwpower(struct net_device *dev,
+                            struct iw_request_info *info,
+                            union iwreq_data *wrqu, char *extra)
+{
+	struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
+
+        if (!conf->power_management_enable)
+                wrqu->power.disabled = 1;
+        else {
+                wrqu->power.disabled = 0;
+        }
+        return 0;
+}
+
+
 static void ieee80211_ioctl_unmask_channels(struct ieee80211_local *local)
 {
 	int m, c;
@@ -3141,20 +3356,20 @@ static const iw_handler ieee80211_handle
 	(iw_handler) NULL,				/* SIOCGIWNICKN */
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) NULL,				/* -- hole -- */
-	(iw_handler) NULL,				/* SIOCSIWRATE */
-	(iw_handler) NULL,				/* SIOCGIWRATE */
+	(iw_handler) ieee80211_ioctl_siwrate,		/* SIOCSIWRATE */
+	(iw_handler) ieee80211_ioctl_giwrate,		/* SIOCGIWRATE */
 	(iw_handler) ieee80211_ioctl_siwrts,		/* SIOCSIWRTS */
 	(iw_handler) ieee80211_ioctl_giwrts,		/* SIOCGIWRTS */
 	(iw_handler) ieee80211_ioctl_siwfrag,		/* SIOCSIWFRAG */
 	(iw_handler) ieee80211_ioctl_giwfrag,		/* SIOCGIWFRAG */
-	(iw_handler) NULL,				/* SIOCSIWTXPOW */
-	(iw_handler) NULL,				/* SIOCGIWTXPOW */
+	(iw_handler) ieee80211_ioctl_siwtxpow,		/* SIOCSIWTXPOW */
+	(iw_handler) ieee80211_ioctl_giwtxpow,		/* SIOCGIWTXPOW */
 	(iw_handler) ieee80211_ioctl_siwretry,		/* SIOCSIWRETRY */
 	(iw_handler) ieee80211_ioctl_giwretry,		/* SIOCGIWRETRY */
 	(iw_handler) ieee80211_ioctl_siwencode,		/* SIOCSIWENCODE */
 	(iw_handler) ieee80211_ioctl_giwencode,		/* SIOCGIWENCODE */
-	(iw_handler) NULL,				/* SIOCSIWPOWER */
-	(iw_handler) NULL,				/* SIOCGIWPOWER */
+	(iw_handler) ieee80211_ioctl_siwpower,		/* SIOCSIWPOWER */
+	(iw_handler) ieee80211_ioctl_giwpower,		/* SIOCGIWPOWER */
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) ieee80211_ioctl_siwgenie,		/* SIOCSIWGENIE */

--------------000202000402050908080101--
