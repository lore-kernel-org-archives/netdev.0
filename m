From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.11-rc2 2/2] wireless: WEXT quality cleanups + max rssi
	level fix for at76c502e
Date: Tue, 01 Feb 2005 16:56:48 -0500
Message-ID: <1107295008.17332.32.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-8QNotCicUS/LDXwth6Ty"
Cc: jgarzik@redhat.com, simon@thekelleys.org.uk
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-8QNotCicUS/LDXwth6Ty
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Use correct maximum rssi level for at76c502e-type cards, and correct
values in the qual.updated field to more closely match the current
Wireless Extensions API.

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/atmel.c	2005-02-01 16:25:38.000000000 -0500
+++ b/drivers/net/wireless/atmel.c	2005-02-01 16:25:53.000000000 -0500
@@ -1311,17 +1311,21 @@
 	if (priv->operating_mode == IW_MODE_INFRA) {
 		if (priv->station_state != STATION_STATE_READY) {
 			priv->wstats.qual.qual = 0;
-			priv->wstats.qual.level	= 0;
+			priv->wstats.qual.level = 0;
+			priv->wstats.qual.updated = (IW_QUAL_QUAL_INVALID
+					| IW_QUAL_LEVEL_INVALID);
 		}
 		priv->wstats.qual.noise = 0;
-		priv->wstats.qual.updated = 7;
+		priv->wstats.qual.updated |= IW_QUAL_NOISE_INVALID;
 	} else {
 		/* Quality levels cannot be determined in ad-hoc mode,
 		   because we can 'hear' more that one remote station. */
 		priv->wstats.qual.qual = 0;
 		priv->wstats.qual.level	= 0;
 		priv->wstats.qual.noise	= 0;
-		priv->wstats.qual.updated = 0;
+		priv->wstats.qual.updated = IW_QUAL_QUAL_INVALID
+					| IW_QUAL_LEVEL_INVALID
+					| IW_QUAL_NOISE_INVALID;
 		priv->wstats.miss.beacon = 0;
 	}
 	
@@ -2236,6 +2240,13 @@
 	range->max_qual.qual = 100;
 	range->max_qual.level = 100;
 	range->max_qual.noise = 0;
+	range->max_qual.updated = IW_QUAL_NOISE_INVALID;
+
+	range->avg_qual.qual = 50;
+	range->avg_qual.level = 50;
+	range->avg_qual.noise = 0;
+	range->avg_qual.updated = IW_QUAL_NOISE_INVALID;
+
 	range->sensitivity = 0;
 
 	range->bitrate[0] =  1000000;
@@ -2265,9 +2276,6 @@
 	range->r_time_flags = 0;
 	range->min_retry = 1;
 	range->max_retry = 65535;
-	range->avg_qual.qual = 50;
-	range->avg_qual.level = 50;
-	range->avg_qual.noise = 0;
 
 	return 0;
 }
@@ -3043,16 +3051,23 @@
 static void smooth_rssi(struct atmel_private *priv, u8 rssi)
 {
 	u8 old = priv->wstats.qual.level;
+	u8 max_rssi = 42; /* 502-rmfd-revd max by experiment, default for now
*/
 
-	/* 502-rmfd-revd gives max signal level as 42, by experiment.
-	   This is going to break for other hardware variants. */
+	switch (priv->firmware_type) {
+		case ATMEL_FW_TYPE_502E:
+			max_rssi = 63; /* 502-rmfd-reve max by experiment */
+			break;
+		default:
+			break;
+	}
 
-	rssi = rssi * 100 / 42;
+	rssi = rssi * 100 / max_rssi;
 	if((rssi + old) % 2)
 		priv->wstats.qual.level =  ((rssi + old)/2) + 1;
 	else
 		priv->wstats.qual.level =  ((rssi + old)/2);		
-	
+	priv->wstats.qual.updated |= IW_QUAL_LEVEL_UPDATED;
+	priv->wstats.qual.updated &= ~IW_QUAL_LEVEL_INVALID;
 }
 
 static void atmel_smooth_qual(struct atmel_private *priv)
@@ -3065,8 +3080,10 @@
 			priv->beacons_this_sec * priv->beacon_period * (priv-
>wstats.qual.level + 100) / 4000;
 		priv->beacons_this_sec = 0;
 	}
+	priv->wstats.qual.updated |= IW_QUAL_QUAL_UPDATED;
+	priv->wstats.qual.updated &= ~IW_QUAL_QUAL_INVALID;
 }
-	
+
 /* deals with incoming managment frames. */
 static void atmel_management_frame(struct atmel_private *priv, struct
ieee802_11_hdr *header, 
 		      u16 frame_len, u8 rssi)


--=-8QNotCicUS/LDXwth6Ty
Content-Disposition: attachment; filename=2.atmel-502e-quality-fix.patch
Content-Type: text/x-patch; name=2.atmel-502e-quality-fix.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- a/drivers/net/wireless/atmel.c	2005-02-01 16:25:38.000000000 -0500
+++ b/drivers/net/wireless/atmel.c	2005-02-01 16:25:53.000000000 -0500
@@ -1311,17 +1311,21 @@
 	if (priv->operating_mode == IW_MODE_INFRA) {
 		if (priv->station_state != STATION_STATE_READY) {
 			priv->wstats.qual.qual = 0;
-			priv->wstats.qual.level	= 0;
+			priv->wstats.qual.level = 0;
+			priv->wstats.qual.updated = (IW_QUAL_QUAL_INVALID
+					| IW_QUAL_LEVEL_INVALID);
 		}
 		priv->wstats.qual.noise = 0;
-		priv->wstats.qual.updated = 7;
+		priv->wstats.qual.updated |= IW_QUAL_NOISE_INVALID;
 	} else {
 		/* Quality levels cannot be determined in ad-hoc mode,
 		   because we can 'hear' more that one remote station. */
 		priv->wstats.qual.qual = 0;
 		priv->wstats.qual.level	= 0;
 		priv->wstats.qual.noise	= 0;
-		priv->wstats.qual.updated = 0;
+		priv->wstats.qual.updated = IW_QUAL_QUAL_INVALID
+					| IW_QUAL_LEVEL_INVALID
+					| IW_QUAL_NOISE_INVALID;
 		priv->wstats.miss.beacon = 0;
 	}
 	
@@ -2236,6 +2240,13 @@
 	range->max_qual.qual = 100;
 	range->max_qual.level = 100;
 	range->max_qual.noise = 0;
+	range->max_qual.updated = IW_QUAL_NOISE_INVALID;
+
+	range->avg_qual.qual = 50;
+	range->avg_qual.level = 50;
+	range->avg_qual.noise = 0;
+	range->avg_qual.updated = IW_QUAL_NOISE_INVALID;
+
 	range->sensitivity = 0;
 
 	range->bitrate[0] =  1000000;
@@ -2265,9 +2276,6 @@
 	range->r_time_flags = 0;
 	range->min_retry = 1;
 	range->max_retry = 65535;
-	range->avg_qual.qual = 50;
-	range->avg_qual.level = 50;
-	range->avg_qual.noise = 0;
 
 	return 0;
 }
@@ -3043,16 +3051,23 @@
 static void smooth_rssi(struct atmel_private *priv, u8 rssi)
 {
 	u8 old = priv->wstats.qual.level;
+	u8 max_rssi = 42; /* 502-rmfd-revd max by experiment, default for now */
 
-	/* 502-rmfd-revd gives max signal level as 42, by experiment.
-	   This is going to break for other hardware variants. */
+	switch (priv->firmware_type) {
+		case ATMEL_FW_TYPE_502E:
+			max_rssi = 63; /* 502-rmfd-reve max by experiment */
+			break;
+		default:
+			break;
+	}
 
-	rssi = rssi * 100 / 42;
+	rssi = rssi * 100 / max_rssi;
 	if((rssi + old) % 2)
 		priv->wstats.qual.level =  ((rssi + old)/2) + 1;
 	else
 		priv->wstats.qual.level =  ((rssi + old)/2);		
-	
+	priv->wstats.qual.updated |= IW_QUAL_LEVEL_UPDATED;
+	priv->wstats.qual.updated &= ~IW_QUAL_LEVEL_INVALID;
 }
 
 static void atmel_smooth_qual(struct atmel_private *priv)
@@ -3065,8 +3080,10 @@
 			priv->beacons_this_sec * priv->beacon_period * (priv->wstats.qual.level + 100) / 4000;
 		priv->beacons_this_sec = 0;
 	}
+	priv->wstats.qual.updated |= IW_QUAL_QUAL_UPDATED;
+	priv->wstats.qual.updated &= ~IW_QUAL_QUAL_INVALID;
 }
-	
+
 /* deals with incoming managment frames. */
 static void atmel_management_frame(struct atmel_private *priv, struct ieee802_11_hdr *header, 
 		      u16 frame_len, u8 rssi)

--=-8QNotCicUS/LDXwth6Ty--
