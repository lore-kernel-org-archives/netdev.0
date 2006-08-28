From: mabbas <mabbas@linux.intel.com>
Subject: [PATCH 2/7] d80211: add support for SIOCSIWRATE and SIOCGIWRATE
Date: Mon, 28 Aug 2006 13:45:34 -0700
Message-ID: <44F355EE.3090607@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070508030606020006090502"
Cc: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:21069 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S1751508AbWH1UpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:45:17 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070508030606020006090502
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------070508030606020006090502
Content-Type: text/x-patch;
 name="d80211-wrate.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-wrate.patch"


This patch modify d80211 to add SIOCSIWRATE and SIOCGIWRATE
commands. this patch almost does the same thing as in 
PRISM2_HOSTAPD_SET_RATE_SETS. 

Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index e72721f..26ed68c 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -395,6 +395,21 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 		tx->u.tx.control->tx_rate = tx->u.tx.rate->val2;
 	}
 
+	/* only data unicast frame */
+	if ((tx->u.tx.rate) && tx->skb && tx->sdata && tx->u.tx.unicast &&
+	    (tx->sdata->type == IEEE80211_IF_TYPE_STA ||
+	     tx->sdata->type == IEEE80211_IF_TYPE_IBSS )&& !extra.mgmt_data) {
+		struct ieee80211_hdr *hdr;
+		u16 fc;
+
+		hdr = (struct ieee80211_hdr *) tx->skb->data;
+		fc = le16_to_cpu(hdr->frame_control);
+
+		if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA)
+			tx->sdata->u.sta.last_rate = tx->u.tx.rate->rate * 
+								     100000;
+	}
+
 	return TXRX_CONTINUE;
 }
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 0d2d79d..c3ec075 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -280,6 +280,9 @@ #define IEEE80211_AUTH_ALG_LEAP BIT(2)
 	struct sk_buff *probe_resp; /* ProbeResp template for IBSS */
 	u32 supp_rates_bits;
 
+	u32 last_rate; /* last tx data rate value. management and multi cast frame
+			* wont be used. */
+
 	int wmm_last_param_set;
 };
 
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..99a5dfd 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -2138,6 +2138,103 @@ static int ieee80211_ioctl_giwretry(stru
 	return 0;
 }
 
+static int ieee80211_ioctl_siwrate(struct net_device *dev,
+                                struct iw_request_info *info,
+                                union iwreq_data *wrqu, char *extra)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	int i, j;
+	u32 target_rate = wrqu->bitrate.value /100000;
+	u32 fixed;
+	int *old_supp = local->supp_rates[local->conf.phymode];
+	int *supp = NULL;
+
+	/* value = -1, fixed = 0 means auto only, so we should use
+	 * all rates offered by AP
+	 * value = X, fixed = 1 means only rate X
+	* value = X, fixed = 0 means all rates lower equal X */
+
+	if (target_rate == -1) {
+		fixed = 0;
+		goto apply;
+	}
+
+	fixed = wrqu->bitrate.fixed;
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
+	/* number of supported rate equal to all current supported rate
+	 * this equal like supp_rates = NULL so save process time and set
+	* supp to NULL
+	*/
+	if ((j >= local->num_curr_rates) || (j == 0)) {
+		kfree(supp);
+		supp = NULL;
+	}
+
+	apply:
+	if (!old_supp && !supp)
+		return 0;
+
+	local->supp_rates[local->conf.phymode] = supp;
+	if (old_supp)
+		kfree(old_supp);
+
+
+	ieee80211_prepare_rates(dev);
+	if (ieee80211_hw_config(dev))
+		return  -EINVAL;
+
+	return 0;
+}
+
+static int ieee80211_ioctl_giwrate(struct net_device *dev,
+				struct iw_request_info *info,
+				union iwreq_data *wrqu,
+				char *extra)
+{
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_if_sta *ifsta;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	u32 max_rate = 0;
+	int i;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ifsta = &sdata->u.sta;
+	
+	/* get the highest rate available */
+	for (i = local->num_curr_rates - 1; i >= 0 ; i--) {
+		struct ieee80211_rate *rate = &local->curr_rates[i];
+
+		if (rate->flags & IEEE80211_RATE_SUPPORTED) {
+			max_rate = rate->rate * 100000;
+			break;
+		}
+	}
+
+	/* if we have not transfered any data set to highest rate available */
+	if ((max_rate >= ifsta->last_rate) && ifsta->last_rate)
+		wrqu->bitrate.value = ifsta->last_rate;
+	else
+		wrqu->bitrate.value = max_rate;
+	return 0;
+}
+
 
 static void ieee80211_ioctl_unmask_channels(struct ieee80211_local *local)
 {
@@ -3142,8 +3239,8 @@ static const iw_handler ieee80211_handle
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

--------------070508030606020006090502--
