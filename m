From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.11-rc2 ] wireless: Hook up Atmel scan quality
	information
Date: Wed, 02 Feb 2005 15:17:04 -0500
Message-ID: <1107375424.18721.1.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, simon@thekelleys.org.uk
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Actually return quality information for scanned access points.

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- atmel.c.scan-qual	2005-02-02 14:53:40.000000000 -0500
+++ atmel.c	2005-02-02 15:10:46.000000000 -0500
@@ -639,6 +639,7 @@
 static int reset_atmel_card(struct net_device *dev );
 static void atmel_enter_state(struct atmel_private *priv, int new_state);
 int atmel_open (struct net_device *dev);
+static u8 get_rssi_percentage (struct atmel_private *priv, u8 rssi);
 
 static inline u16 atmel_hi(struct atmel_private *priv, u16 offset)
 {
@@ -2187,6 +2188,15 @@
 		iwe.u.mode = priv->BSSinfo[i].BSStype;
 		current_ev = iwe_stream_add_event(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, IW_EV_UINT_LEN);
 	
+		iwe.cmd = IWEVQUAL;
+		iwe.u.qual.level = get_rssi_percentage (priv, priv->BSSinfo[i].RSSI);
+		iwe.u.qual.noise = 0;
+		iwe.u.qual.qual = iwe.u.qual.level;
+		iwe.u.qual.updated = IW_QUAL_LEVEL_UPDATED
+						| IW_QUAL_QUAL_UPDATED
+						| IW_QUAL_NOISE_INVALID; /* Don't know noise or quality */
+		current_ev = iwe_stream_add_event(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, IW_EV_QUAL_LEN);
+
 		iwe.cmd = SIOCGIWFREQ;
 		iwe.u.freq.m = priv->BSSinfo[i].channel;
 		iwe.u.freq.e = 0;
@@ -3048,9 +3058,8 @@
 	} 
 }	
 
-static void smooth_rssi(struct atmel_private *priv, u8 rssi)
+static u8 get_rssi_percentage (struct atmel_private *priv, u8 rssi)
 {
-	u8 old = priv->wstats.qual.level;
 	u8 max_rssi = 42; /* 502-rmfd-revd max by experiment, default for now */
 
 	switch (priv->firmware_type) {
@@ -3061,7 +3070,14 @@
 			break;
 	}
 
-	rssi = rssi * 100 / max_rssi;
+	return (rssi * 100 / max_rssi);
+}
+
+static void smooth_rssi(struct atmel_private *priv, u8 rssi)
+{
+	u8 old = priv->wstats.qual.level;
+
+	rssi = get_rssi_percentage (priv, rssi);
 	if((rssi + old) % 2)
 		priv->wstats.qual.level =  ((rssi + old)/2) + 1;
 	else
