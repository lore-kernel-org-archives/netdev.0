From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.11-rc3] wireless: airo WEXT and quality corrections
Date: Fri, 11 Feb 2005 16:09:55 -0500
Message-ID: <1108156195.21113.20.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, breed@users.sourceforge.net, davem@davemloft.net
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch brings the airo driver into line with the current
WEXT specification of signal quality.  It also fixes the values
used to determine signal quality and level for MPI & PCMCIA 350
cards.  It turns out that BSSListRid.rssi was actually in dBm
for 350 series cards, and that we can use the normalized
signal strength reported by the card as our "quality" value, on
a scale of 0 - 100.  Since signal level values are in dBm for
this driver, max_qual->level MUST be 0, as specified in the WEXT
spec.  This patch also uses the IW_QUAL constants new in WEXT
version 17.

Signed-off-by: Dan Williams <dcbw@redhat.com>'


--- a/drivers/net/wireless/airo.c	2005-02-10 18:36:58.000000000 -0500
+++ a/drivers/net/wireless/airo.c	2005-02-11 15:45:19.000000000 -0500
@@ -754,7 +754,7 @@
   u8 zero;
   u8 ssidLen;
   u8 ssid[32];
-  u16 rssi;
+  u16 dBm;
 #define CAP_ESS (1<<0)
 #define CAP_IBSS (1<<1)
 #define CAP_PRIVACY (1<<4)
@@ -1125,6 +1125,9 @@
 static int encapsulate(struct airo_info *ai, etherHead *pPacket, MICBuffer *buffer, int len);
 static int decapsulate(struct airo_info *ai, MICBuffer *mic, etherHead *pPacket, u16 payLen);
 
+static u8 airo_rssi_to_dbm (tdsRssiEntry *rssi_rid, u8 rssi);
+static u8 airo_dbm_to_pct (tdsRssiEntry *rssi_rid, u8 dbm);
+
 #include <linux/crypto.h>
 #endif
 
@@ -1714,6 +1717,7 @@
 	list->fh.dwell = le16_to_cpu(list->fh.dwell);
 	list->dsChannel = le16_to_cpu(list->dsChannel);
 	list->atimWindow = le16_to_cpu(list->atimWindow);
+	list->dBm = le16_to_cpu(list->dBm);
 	return rc;
 }
 
@@ -3248,7 +3252,10 @@
 					wstats.level = 0x100 - apriv->rssi[hdr.rssi[1]].rssidBm;
 				else
 					wstats.level = (hdr.rssi[1] + 321) / 2;
-				wstats.updated = 3;	
+				wstats.noise = apriv->wstats.qual.noise;
+				wstats.updated = IW_QUAL_LEVEL_UPDATED
+					| IW_QUAL_QUAL_UPDATED
+					| IW_QUAL_NOISE_UPDATED;
 				/* Update spy records */
 				wireless_spy_update(dev, sa, &wstats);
 			}
@@ -3591,7 +3598,10 @@
 			wstats.level = 0x100 - ai->rssi[hdr.rssi[1]].rssidBm;
 		else
 			wstats.level = (hdr.rssi[1] + 321) / 2;
-		wstats.updated = 3;
+		wstats.noise = ai->wstats.qual.noise;
+		wstats.updated = IW_QUAL_QUAL_UPDATED
+			| IW_QUAL_LEVEL_UPDATED
+			| IW_QUAL_NOISE_UPDATED;
 		/* Update spy records */
 		wireless_spy_update(ai->dev, sa, &wstats);
 	}
@@ -3682,7 +3692,7 @@
 		status = PC4500_readrid(ai,RID_RSSI,&rssi_rid,sizeof(rssi_rid),lock);
 		if ( status == SUCCESS ) {
 			if (ai->rssi || (ai->rssi = kmalloc(512, GFP_KERNEL)) != NULL)
-				memcpy(ai->rssi, (u8*)&rssi_rid + 2, 512);
+				memcpy(ai->rssi, (u8*)&rssi_rid + 2, 512); /* Skip RID length member */
 		}
 		else {
 			if (ai->rssi) {
@@ -5351,7 +5361,7 @@
 				(int)BSSList_rid.bssid[5],
 				(int)BSSList_rid.ssidLen,
 				BSSList_rid.ssid,
-				(int)BSSList_rid.rssi);
+				(int)BSSList_rid.dBm);
 		ptr += sprintf(ptr, " channel = %d %s %s %s %s\n",
 				(int)BSSList_rid.dsChannel,
 				BSSList_rid.cap & CAP_ESS ? "ESS" : "",
@@ -5596,6 +5606,29 @@
  * would not work at all... - Jean II
  */
 
+static u8 airo_rssi_to_dbm (tdsRssiEntry *rssi_rid, u8 rssi)
+{
+	if( !rssi_rid )
+		return 0;
+
+	return (0x100 - rssi_rid[rssi].rssidBm);
+}
+
+static u8 airo_dbm_to_pct (tdsRssiEntry *rssi_rid, u8 dbm)
+{
+	int i;
+
+	if( !rssi_rid )
+		return 0;
+
+	for( i = 0; i < 256; i++ )
+		if (rssi_rid[i].rssidBm == dbm)
+			return rssi_rid[i].rssipct;
+
+	return 0;
+}
+
+
 static int airo_get_quality (StatusRid *status_rid, CapabilityRid *cap_rid)
 {
 	int quality = 0;
@@ -6446,11 +6479,29 @@
 	}
 	range->num_frequency = k;
 
+	range->sensitivity = 65535;
+
 	/* Hum... Should put the right values there */
-	range->max_qual.qual = airo_get_max_quality(&cap_rid);
-	range->max_qual.level = 0x100 - 120;	/* -120 dBm */
+	if (local->rssi)
+		range->max_qual.qual = 100;	/* % */
+	else
+		range->max_qual.qual = airo_get_max_quality(&cap_rid);
+	range->max_qual.level = 0;	/* 0 means we use dBm  */
 	range->max_qual.noise = 0;
-	range->sensitivity = 65535;
+	range->max_qual.updated = 0;
+
+	/* Experimental measurements - boundary 11/5.5 Mb/s */
+	/* Note : with or without the (local->rssi), results
+	 * are somewhat different. - Jean II */
+	if (local->rssi) {
+		range->avg_qual.qual = 50;	/* % */
+		range->avg_qual.level = 186;	/* -70 dBm */
+	} else {
+		range->avg_qual.qual = airo_get_avg_quality(&cap_rid);
+		range->avg_qual.level = 176;	/* -80 dBm */
+	}
+	range->avg_qual.noise = 0;
+	range->avg_qual.updated = 0;
 
 	for(i = 0 ; i < 8 ; i++) {
 		range->bitrate[i] = cap_rid.supportedRates[i] * 500000;
@@ -6511,15 +6562,6 @@
 	range->max_retry = 65535;
 	range->min_r_time = 1024;
 	range->max_r_time = 65535 * 1024;
-	/* Experimental measurements - boundary 11/5.5 Mb/s */
-	/* Note : with or without the (local->rssi), results
-	 * are somewhat different. - Jean II */
-	range->avg_qual.qual = airo_get_avg_quality(&cap_rid);
-	if (local->rssi)
-		range->avg_qual.level = 186;	/* -70 dBm */
-	else
-		range->avg_qual.level = 176;	/* -80 dBm */
-	range->avg_qual.noise = 0;
 
 	/* Event capability (kernel + driver) */
 	range->event_capa[0] = (IW_EVENT_CAPA_K_0 |
@@ -6679,12 +6721,18 @@
 		loseSync = 0;
 		memcpy(address[i].sa_data, BSSList.bssid, ETH_ALEN);
 		address[i].sa_family = ARPHRD_ETHER;
-		if (local->rssi)
-			qual[i].level = 0x100 - local->rssi[BSSList.rssi].rssidBm;
-		else
-			qual[i].level = (BSSList.rssi + 321) / 2;
-		qual[i].qual = qual[i].noise = 0;
-		qual[i].updated = 2;
+		if (local->rssi) {
+			qual[i].level = 0x100 - BSSList.dBm;
+			qual[i].qual = airo_dbm_to_pct( local->rssi, BSSList.dBm );
+			qual[i].updated = IW_QUAL_QUAL_UPDATED;
+		} else {
+			qual[i].level = (BSSList.dBm + 321) / 2;
+			qual[i].qual = 0;
+			qual[i].updated = IW_QUAL_QUAL_INVALID;
+		}
+		qual[i].noise = local->wstats.qual.noise;
+		qual[i].updated |= IW_QUAL_LEVEL_UPDATED
+				| IW_QUAL_NOISE_UPDATED;
 		if (BSSList.index == 0xffff)
 			break;
 	}
@@ -6763,7 +6811,7 @@
 static inline char *airo_translate_scan(struct net_device *dev,
 					char *current_ev,
 					char *end_buf,
-					BSSListRid *list)
+					BSSListRid *bss)
 {
 	struct airo_info *ai = dev->priv;
 	struct iw_event		iwe;		/* Temporary buffer */
@@ -6774,22 +6822,22 @@
 	/* First entry *MUST* be the AP MAC address */
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
-	memcpy(iwe.u.ap_addr.sa_data, list->bssid, ETH_ALEN);
+	memcpy(iwe.u.ap_addr.sa_data, bss->bssid, ETH_ALEN);
 	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
 
 	/* Other entries will be displayed in the order we give them */
 
 	/* Add the ESSID */
-	iwe.u.data.length = list->ssidLen;
+	iwe.u.data.length = bss->ssidLen;
 	if(iwe.u.data.length > 32)
 		iwe.u.data.length = 32;
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, list->ssid);
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid);
 
 	/* Add mode */
 	iwe.cmd = SIOCGIWMODE;
-	capabilities = le16_to_cpu(list->cap);
+	capabilities = le16_to_cpu(bss->cap);
 	if(capabilities & (CAP_ESS | CAP_IBSS)) {
 		if(capabilities & CAP_ESS)
 			iwe.u.mode = IW_MODE_MASTER;
@@ -6800,19 +6848,25 @@
 
 	/* Add frequency */
 	iwe.cmd = SIOCGIWFREQ;
-	iwe.u.freq.m = le16_to_cpu(list->dsChannel);
+	iwe.u.freq.m = le16_to_cpu(bss->dsChannel);
 	iwe.u.freq.m = frequency_list[iwe.u.freq.m] * 100000;
 	iwe.u.freq.e = 1;
 	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_FREQ_LEN);
 
 	/* Add quality statistics */
 	iwe.cmd = IWEVQUAL;
-	if (ai->rssi)
-		iwe.u.qual.level = 0x100 - ai->rssi[list->rssi].rssidBm;
-	else
-		iwe.u.qual.level = (list->rssi + 321) / 2;
-	iwe.u.qual.noise = 0;
-	iwe.u.qual.qual = 0;
+	if (ai->rssi) {
+		iwe.u.qual.level = 0x100 - bss->dBm;
+		iwe.u.qual.qual = airo_dbm_to_pct( ai->rssi, bss->dBm );
+		iwe.u.qual.updated = IW_QUAL_QUAL_UPDATED;
+	} else {
+		iwe.u.qual.level = (bss->dBm + 321) / 2;
+		iwe.u.qual.qual = 0;
+		iwe.u.qual.updated = IW_QUAL_QUAL_INVALID;
+	}
+	iwe.u.qual.noise = ai->wstats.qual.noise;
+	iwe.u.qual.updated |= IW_QUAL_LEVEL_UPDATED
+			| IW_QUAL_NOISE_UPDATED;
 	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
 
 	/* Add encryption capability */
@@ -6822,7 +6876,7 @@
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, list->ssid);
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, bss->ssid);
 
 	/* Rate : stuffing multiple values in a single event require a bit
 	 * more of magic - Jean II */
@@ -6834,10 +6888,10 @@
 	/* Max 8 values */
 	for(i = 0 ; i < 8 ; i++) {
 		/* NULL terminated */
-		if(list->rates[i] == 0)
+		if(bss->rates[i] == 0)
 			break;
 		/* Bit rate given in 500 kb/s units (+ 0x80) */
-		iwe.u.bitrate.value = ((list->rates[i] & 0x7f) * 500000);
+		iwe.u.bitrate.value = ((bss->rates[i] & 0x7f) * 500000);
 		/* Add new value to event */
 		current_val = iwe_stream_add_value(current_ev, current_val, end_buf, &iwe, IW_EV_PARAM_LEN);
 	}
@@ -7156,18 +7210,22 @@
 	/* The status */
 	local->wstats.status = status_rid.mode;
 
-	/* Signal quality and co. But where is the noise level ??? */
-	local->wstats.qual.qual = airo_get_quality(&status_rid, &cap_rid);
-	if (local->rssi)
-		local->wstats.qual.level = 0x100 - local->rssi[status_rid.sigQuality].rssidBm;
-	else
+	/* Signal quality and co */
+	if (local->rssi) {
+		local->wstats.qual.level = airo_rssi_to_dbm( local->rssi, status_rid.sigQuality );
+		/* normalizedSignalStrength appears to be a percentage */
+		local->wstats.qual.qual = status_rid.normalizedSignalStrength;
+	} else {
 		local->wstats.qual.level = (status_rid.normalizedSignalStrength + 321) / 2;
+		local->wstats.qual.qual = airo_get_quality(&status_rid, &cap_rid);
+	}
+	local->wstats.qual.updated = IW_QUAL_QUAL_UPDATED | IW_QUAL_LEVEL_UPDATED;
 	if (status_rid.len >= 124) {
-		local->wstats.qual.noise = 256 - status_rid.noisedBm;
-		local->wstats.qual.updated = 7;
+		local->wstats.qual.noise = 0x100 - status_rid.noisedBm;
+		local->wstats.qual.updated |= IW_QUAL_NOISE_UPDATED;
 	} else {
 		local->wstats.qual.noise = 0;
-		local->wstats.qual.updated = 3;
+		local->wstats.qual.updated |= IW_QUAL_NOISE_INVALID;
 	}
 
 	/* Packets discarded in the wireless adapter due to wireless
