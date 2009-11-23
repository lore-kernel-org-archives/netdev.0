From: Robert Olsson <robert@herjulf.net>
Subject: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 5/5 for net-next-2.6
Date: Mon, 23 Nov 2009 23:58:28 +0100
Message-ID: <19211.5012.564027.398427@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av12-2-sn2.hy.skanova.net ([81.228.8.186]:52704 "EHLO
	av12-2-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497AbZKWW6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:58:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Ethtool support. 

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Cheers
						--ro


diff --git a/Makefile.am b/Makefile.am
index eac65fe..0988a6c 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -1,4 +1,5 @@
 AM_CFLAGS = -Wall
+AM_LDLAGS = -lm
 
 man_MANS = ethtool.8
 EXTRA_DIST = LICENSE ethtool.8 ethtool.spec.in aclocal.m4 ChangeLog autogen.sh
diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3ca4e2c..90ea1cb 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -266,6 +266,54 @@ struct ethtool_stats {
 	__u64	data[0];
 };
 
+/* Diagmostic Monitoring Interface Data -- DOM */
+struct ethtool_phy_diag {
+	__u32 cmd;
+	/* A0 page */
+	__u16 type;
+	__u16 wavelength;
+	/* A2 page */
+	__u16 alarm; 
+	__u16 warning; 
+	__s16 temp;
+	__u16 temp_slope;
+	__s16 temp_offset;
+	__u16 vcc;
+	__u16 vcc_slope;
+	__s16 vcc_offset;
+	__u16 tx_bias;
+	__u16 tx_bias_slope;
+	__s16 tx_bias_offset;
+	__u16 tx_pwr;
+	__u16 tx_pwr_slope;
+	__s16 tx_pwr_offset;
+	__u16 rx_pwr;
+	__u32 rx_pwr_cal[5];
+
+	/* Thresholds */
+  	__s16 temp_alt;
+  	__s16 temp_aht;
+  	__s16 temp_wlt;
+  	__s16 temp_wht;
+  	__u16 vcc_alt;
+  	__u16 vcc_aht;
+  	__u16 vcc_wlt;
+  	__u16 vcc_wht;
+  	__u16 tx_bias_alt;
+  	__u16 tx_bias_aht;
+  	__u16 tx_bias_wlt;
+  	__u16 tx_bias_wht;
+  	__u16 tx_pwr_alt;
+  	__u16 tx_pwr_aht;
+  	__u16 tx_pwr_wlt;
+  	__u16 tx_pwr_wht;
+  	__u16 rx_pwr_alt;
+  	__u16 rx_pwr_aht;
+  	__u16 rx_pwr_wlt;
+  	__u16 rx_pwr_wht;
+};
+
+
 struct ethtool_perm_addr {
 	__u32	cmd;		/* ETHTOOL_GPERMADDR */
 	__u32	size;
diff --git a/ethtool-util.h b/ethtool-util.h
index 5572771..1a69426 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -9,7 +9,9 @@
 typedef unsigned long long __u64;
 typedef __uint32_t __u32;         /* ditto */
 typedef __uint16_t __u16;         /* ditto */
+typedef __int16_t __s16;         /* ditto */
 typedef __uint8_t __u8;           /* ditto */
+typedef __int8_t __s8;           /* ditto */
 
 /* historical: we used to use kernel-like types; remove these once cleaned */
 typedef unsigned long long u64;
diff --git a/ethtool.c b/ethtool.c
index 0110682..caa9f6c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -14,6 +14,7 @@
  * amd8111e support by Reeja John <reeja.john@amd.com>
  * long arguments by Andi Kleen.
  * SMSC LAN911x support by Steve Glendinning <steve.glendinning@smsc.com>
+ * Diagnostic Monitoring Interface Support by Robert Olsson <robert@herjulf.net>
  *
  * TODO:
  *   * no-args => summary of each device (mii-tool style)
@@ -38,8 +39,9 @@
 #include <errno.h>
 #include <net/if.h>
 #include <sys/utsname.h>
-
 #include <linux/sockios.h>
+#include "dom.h"
+
 #include "ethtool-util.h"
 
 
@@ -78,6 +80,7 @@ static int dump_rxfhash(int fhash, u64 val);
 static int do_srxclass(int fd, struct ifreq *ifr);
 static int do_grxclass(int fd, struct ifreq *ifr);
 static int send_ioctl(int fd, struct ifreq *ifr);
+static int do_phy_diag(int fd, struct ifreq *ifr);
 
 static enum {
 	MODE_HELP = -1,
@@ -101,6 +104,7 @@ static enum {
 	MODE_GSTATS,
 	MODE_GNFC,
 	MODE_SNFC,
+	MODE_PHY_DIAG
 } mode = MODE_GSET;
 
 static struct option {
@@ -184,6 +188,7 @@ static struct option {
     { "-t", "--test", MODE_TEST, "Execute adapter self test",
                 "               [ online | offline ]\n" },
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
+    { "-D", "--phy_diag", MODE_PHY_DIAG, "Show PHY diagnostics" },
     { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification"
 		"options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
@@ -496,7 +501,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GSTATS) ||
 			    (mode == MODE_GNFC) ||
 			    (mode == MODE_SNFC) ||
-			    (mode == MODE_PHYS_ID)) {
+			    (mode == MODE_PHYS_ID) || 
+			    (mode == MODE_PHY_DIAG)) {
 				devname = argp[i];
 				break;
 			}
@@ -1504,6 +1510,8 @@ static int doit(void)
 		return do_grxclass(fd, &ifr);
 	} else if (mode == MODE_SNFC) {
 		return do_srxclass(fd, &ifr);
+	} else if (mode == MODE_PHY_DIAG) {
+		return do_phy_diag(fd, &ifr);
 	}
 
 	return 69;
@@ -2403,6 +2411,287 @@ static int send_ioctl(int fd, struct ifreq *ifr)
 	return ioctl(fd, SIOCETHTOOL, ifr);
 }
 
+static int do_phy_diag(int fd, struct ifreq *ifr)
+{
+	int err, ecal = 0, aw = 0;
+	double tmp, alt=0, aht=0, wlt=0, wht=0;
+	__u8 type, option, alarm[2], warn[2];
+	
+
+	struct ethtool_phy_diag pd;
+
+	pd.cmd = ETHTOOL_GPHYDIAG;
+	ifr->ifr_data = (caddr_t)&pd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("Cannot get PHY diagnostics");
+		return 0;
+	}
+	
+	type = pd.type >> 8;
+
+	if( ~(type) & DOM_TYPE_DOM || type & DOM_TYPE_LEGAGY_DOM) {
+	  	fprintf(stdout, "PHY Diagnostics not supported:\n");
+		return 0;
+	}
+
+	if(type & DOM_TYPE_INT_CAL)
+		fprintf(stdout, "Int-Calbr: ");
+	
+	if(type & DOM_TYPE_EXT_CAL) {
+		fprintf(stdout, "Ext-Calbr: ");
+		ecal = 1;
+	}
+
+	if(type & DOM_TYPE_RX_PWR)
+		fprintf(stdout, "Avr RX-Power: ");
+	else
+		fprintf(stdout, "OMA RX-Power: ");
+	
+	if(type & DOM_TYPE_ADDR_CHNGE)
+		fprintf(stdout,"Addr Change: ");
+
+	/* Check options */
+	option = pd.type & 0x00FF;	
+
+	if(option & DOM_EO_AW) {
+		fprintf(stdout, "Alarm & Warn: ");
+		aw = 1;
+	}
+
+	if(option & DOM_EO_TX_DISABLE)
+		fprintf(stdout, "TX_DISABLE: ");
+	
+	if(option & DOM_EO_TX_FAULT)
+		fprintf(stdout, "TX_FAULT: ");
+	
+	if(option & DOM_EO_RX_LOS)
+		fprintf(stdout, "RX_LOS: ");
+	
+	if(option & DOM_EO_RATE_SELECT_MON)
+		fprintf(stdout, "RATE_SELECT MON: ");
+	
+	if(option & DOM_EO_APP_SELECT)
+		fprintf(stdout, "RATE_SELECT: ");
+	
+	if(option & DOM_EO_RATE_SELECT)
+		fprintf(stdout, "RATE_SELECT: ");
+	
+	if(aw) {
+		alarm[0] = pd.alarm >> 8;
+		alarm[1] = pd.alarm & 0x00FF;;
+
+		warn[0] = pd.warning >> 8;
+		warn[1] = pd.warning & 0x00FF;
+	}
+	
+	
+	fprintf(stdout, "\tWavelength: %d nm\n", pd.wavelength); 
+
+	if(aw)
+	  fprintf(stdout, "Alarms, warnings in beginning of line, Ie. AH = Alarm High, WL == Warn Low etc\n");
+
+
+#define ECAL(v, s, o) (( ((double) (s>>8)) + (s & 0xFF)) * (double) v + o)	
+
+	/* Temp */
+
+	if (ecal) {
+		tmp = ECAL(pd.temp, pd.temp_slope, pd.temp_offset);
+		if(aw) {
+			alt = ECAL(pd.temp_alt, pd.temp_slope, pd.temp_offset);
+			aht = ECAL(pd.temp_aht, pd.temp_slope, pd.temp_offset);
+			wlt = ECAL(pd.temp_wlt, pd.temp_slope, pd.temp_offset);
+			wht = ECAL(pd.temp_wht, pd.temp_slope, pd.temp_offset);
+		}
+
+	}
+	else 
+		tmp =  (double) (pd.temp);
+
+	if(aw) {
+		if(alarm[0] & DOM_TYPE_TEMP_AH)
+			fprintf(stdout, "AH");
+		
+		if(alarm[0] & DOM_TYPE_TEMP_AL)
+			fprintf(stdout, "AL");
+		
+		if(warn[0] & DOM_TYPE_TEMP_WH)
+			fprintf(stdout, "WH");
+		
+		if(warn[0] & DOM_TYPE_TEMP_WL)
+			fprintf(stdout, "WL");
+	}
+	fprintf(stdout, "\tTemp: %5.1f C", tmp/256);
+	if(aw)
+		fprintf(stdout, "\t\t\tThresh: Lo: %5.1f/%-5.1f  Hi: %5.1f/%-5.1f C\n",
+			alt/256, wlt/256, wht/256, aht/256);
+	else
+		fprintf(stdout, "\n");
+
+
+
+	/* VCC */
+
+	if (ecal) {
+		tmp = ECAL(pd.vcc, pd.vcc_slope, pd.vcc_offset);
+		if(aw) {
+			alt = ECAL(pd.vcc_alt, pd.vcc_slope, pd.temp_offset);
+			aht = ECAL(pd.vcc_aht, pd.vcc_slope, pd.temp_offset);
+			wlt = ECAL(pd.vcc_wlt, pd.vcc_slope, pd.temp_offset);
+			wht = ECAL(pd.vcc_wht, pd.vcc_slope, pd.temp_offset);
+		}
+	}
+	else
+		tmp =  (double) (pd.vcc); 
+	
+	fprintf(stdout, "\tVcc: %5.2f V\t", tmp/10000);
+	if(1)
+		fprintf(stdout, "\t\tThresh: Lo: %5.1f/%-5.1f  Hi: %5.1f/%-5.1f V\n",
+			alt/10000, wlt/10000, wht/10000, aht/10000);
+
+	else
+		fprintf(stdout, "\n");
+
+
+	/* TX BIAS */
+
+	if (ecal) {
+		tmp = ECAL(pd.tx_bias, pd.tx_bias_slope, pd.tx_bias_offset);
+		if(aw) {
+			alt = ECAL(pd.tx_bias_alt, pd.tx_bias_slope, pd.temp_offset);
+			aht = ECAL(pd.tx_bias_aht, pd.tx_bias_slope, pd.temp_offset);
+			wlt = ECAL(pd.tx_bias_wlt, pd.tx_bias_slope, pd.temp_offset);
+			wht = ECAL(pd.tx_bias_wht, pd.tx_bias_slope, pd.temp_offset);
+		}
+	}
+	else
+		tmp =  (double) (pd.tx_bias); 
+	
+	if(aw) {
+	  
+		if(alarm[0] & DOM_TYPE_TX_BIAS_AH)
+			fprintf(stdout, "AH");
+		
+		if(alarm[0] & DOM_TYPE_TX_BIAS_AL)
+			fprintf(stdout, "AL");
+		
+		if(warn[0] & DOM_TYPE_TX_BIAS_WH)
+			fprintf(stdout, "WH");
+		
+		if(warn[0] & DOM_TYPE_TX_BIAS_WL)
+			fprintf(stdout, "WL");
+		
+	}
+	fprintf(stdout, "\tTx-Bias: %5.1f mA\t", tmp/500);
+	if(aw)
+		fprintf(stdout, "\tThresh: Lo: %5.1f/%-5.1f  Hi: %5.1f/%-5.1f mA\n",
+			alt/500, wlt/500, wht/500, aht/500);
+
+	else
+		fprintf(stdout, "\n");
+
+
+	/* TX PWR */
+
+	if (ecal) {
+		tmp = ECAL(pd.tx_pwr, pd.tx_pwr_slope, pd.tx_pwr_offset);
+		if(aw) {
+			alt = ECAL(pd.tx_pwr_alt, pd.tx_pwr_slope, pd.temp_offset);
+			aht = ECAL(pd.tx_pwr_aht, pd.tx_pwr_slope, pd.temp_offset);
+			wlt = ECAL(pd.tx_pwr_wlt, pd.tx_pwr_slope, pd.temp_offset);
+			wht = ECAL(pd.tx_pwr_wht, pd.tx_pwr_slope, pd.temp_offset);
+		}
+	}
+	else
+		tmp =  (double) (pd.tx_pwr); 
+	if(aw) {
+	  
+		if(alarm[0] & DOM_TYPE_TX_PWR_AH)
+			fprintf(stdout, "AH");
+		
+		if(alarm[0] & DOM_TYPE_TX_PWR_AL)
+			fprintf(stdout, "AL");
+		
+		if(warn[0] & DOM_TYPE_TX_PWR_WH)
+			fprintf(stdout, "WH");
+		
+		if(warn[0] & DOM_TYPE_TX_PWR_WL)
+			fprintf(stdout, "WL");
+		
+	}
+	tmp = tmp/10000; 
+	fprintf(stdout, "\tTX-pwr: %5.1f dBm (%5.2f mW)", 10*log10(tmp), tmp);	
+	if(aw) {
+		alt = alt/10000;
+		aht = aht/10000;
+		wlt = wlt/10000;
+		wht = wht/10000;
+		fprintf(stdout, "\tThresh: Lo: %5.1f/%-5.1f  Hi: %5.1f/%-5.1f dBm\n",
+			10*log10(alt), 10*log10(wlt), 10*log10(wht), 10*log10(aht));
+	}
+	else
+		fprintf(stdout, "\n");
+
+	/* RX PWR */
+	if (ecal) {
+		/* Note factors is in floast cast to avoid conversion */
+                float *f[5]; 
+		double s, o;
+
+                f[0] = (float *) &pd.rx_pwr_cal[0];
+                f[1] = (float *) &pd.rx_pwr_cal[1];
+                f[2] = (float *) &pd.rx_pwr_cal[2];
+                f[3] = (float *) &pd.rx_pwr_cal[3];
+                f[4] = (float *) &pd.rx_pwr_cal[4];
+		s = *f[4] + *f[3] + *f[2] + *f[1];
+		o = *f[0];
+		
+		if(aw) {
+			tmp = pd.rx_pwr * s + o;
+			alt = pd.rx_pwr_alt * s + o;
+			aht = pd.rx_pwr_aht * s + o;
+			wlt = pd.rx_pwr_wlt * s + o;
+			wht = pd.rx_pwr_wht * s + o;
+		}
+	}
+	else 
+		tmp =  (double) (pd.rx_pwr); 
+
+	if(aw) {
+	  
+		if(alarm[1] & DOM_TYPE_RX_PWR_AH)
+			fprintf(stdout, "AH");
+		
+		if(alarm[1] & DOM_TYPE_RX_PWR_AL)
+			fprintf(stdout, "AL");
+		
+		if(warn[1] & DOM_TYPE_RX_PWR_WH)
+			fprintf(stdout, "WH");
+		
+		if(warn[1] & DOM_TYPE_RX_PWR_WL)
+			fprintf(stdout, "WL");
+		
+	}
+	tmp =  (double) (tmp)/10000; 
+	fprintf(stdout, "\tRX-pwr: %5.1f dBm (%5.2f mW) ", 10*log10(tmp), tmp);
+
+	if(aw) {
+		alt = alt/10000;
+		aht = aht/10000;
+		wlt = wlt/10000;
+		wht = wht/10000;
+		
+		fprintf(stdout, "\tThresh: Lo: %5.1f/%-5.1f  Hi: %5.1f/%-5.1f dBm\n",
+			10*log10(alt), 10*log10(wlt), 10*log10(wht), 10*log10(aht));
+	}
+	else 
+		fprintf(stdout, "\n");
+
+	return 0;
+}
+
+
 int main(int argc, char **argp, char **envp)
 {
 	parse_cmdline(argc, argp);
