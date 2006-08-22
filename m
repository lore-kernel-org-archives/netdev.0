From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [ETHTOOL] GSO Support for ethtool
Date: Tue, 22 Aug 2006 11:40:04 +0900 (JST)
Message-ID: <20060822.114004.123582878.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	junji@is.s.u-tokyo.ac.jp, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:6931 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932079AbWHVCiS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 22:38:18 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Upcoming 2.6.18 provides Generic Segmentation Offload (GSO).
This provides its control with -K option.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d696de3..30f5e05 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -285,6 +285,8 @@ #define ETHTOOL_GTSO		0x0000001e /* Get 
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
 #define ETHTOOL_GUFO		0x00000021 /* Get UFO enable (ethtool_value) */
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
+#define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
+#define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8 b/ethtool.8
index 6cb1477..b735be0 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -154,6 +154,7 @@ ethtool \- Display or change ethernet ca
 .B2 sg on off
 .B2 tso on off
 .B2 ufo on off
+.B2 gso on off
 
 .B ethtool \-p|\-\-blink
 .I ethX
@@ -276,6 +277,9 @@ Specify if tcp segmentation offload is e
 .A2 ufo on off
 Specify if UDP fragmentation offload is enabled 
 .TP
+.A2 gso on off
+Specify if generic segmentation offload is enabled 
+.TP
 .B \-p \-\-identify
 initiates adapter-specific action intended to enable an operator to
 easily identify the adapter by sight.  Typically this involves
diff --git a/ethtool.c b/ethtool.c
index 7d408be..fdaae0e 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -145,7 +145,8 @@ static struct option { 
 		"		[ tx on|off ]\n"
 		"		[ sg on|off ]\n"
 	        "		[ tso on|off ]\n"
-	        "		[ ufo on|off ]\n" },
+	        "		[ ufo on|off ]\n"
+	        "		[ gso on|off ]\n" },
     { "-i", "--driver", MODE_GDRV, "Show driver information" }, 
     { "-d", "--register-dump", MODE_GREGS, "Do a register dump" },
     { "-e", "--eeprom-dump", MODE_GEEPROM, "Do a EEPROM dump",
@@ -191,6 +192,7 @@ static int off_csum_tx_wanted = -1;
 static int off_sg_wanted = -1;
 static int off_tso_wanted = -1;
 static int off_ufo_wanted = -1;
+static int off_gso_wanted = -1;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -295,6 +297,7 @@ static struct cmdline_info cmdline_offlo
 	{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },
 	{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
 	{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
+	{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -1115,19 +1118,21 @@ static int dump_coalesce(void)
 	return 0;
 }
 
-static int dump_offload (int rx, int tx, int sg, int tso, int ufo)
+static int dump_offload (int rx, int tx, int sg, int tso, int ufo, int gso)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
 		"tx-checksumming: %s\n"
 		"scatter-gather: %s\n"
 		"tcp segmentation offload: %s\n"
-		"udp fragmentation offload: %s\n",
+		"udp fragmentation offload: %s\n"
+		"generic segmentation offload: %s\n",
 		rx ? "on" : "off",
 		tx ? "on" : "off",
 		sg ? "on" : "off",
 		tso ? "on" : "off",
-		ufo ? "on" : "off");
+		ufo ? "on" : "off",
+		gso ? "on" : "off");
 
 	return 0;
 }
@@ -1391,7 +1396,7 @@ static int do_scoalesce(int fd, struct i
 static int do_goffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
-	int err, allfail = 1, rx = 0, tx = 0, sg = 0, tso = 0, ufo = 0;
+	int err, allfail = 1, rx = 0, tx = 0, sg = 0, tso = 0, ufo = 0, gso = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -1445,12 +1450,22 @@ static int do_goffload(int fd, struct if
 		allfail = 0;
 	}
 
+	eval.cmd = ETHTOOL_GGSO;
+	ifr->ifr_data = (caddr_t)&eval;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err)
+		perror("Cannot get device generic segmentation offload settings");
+	else {
+		gso = eval.data;
+		allfail = 0;
+	}
+
 	if (allfail) {
 		fprintf(stdout, "no offload info available\n");
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo);
+	return dump_offload(rx, tx, sg, tso, ufo, gso);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
@@ -1516,6 +1531,17 @@ static int do_soffload(int fd, struct if
 			return 89;
 		}
 	}
+	if (off_gso_wanted >= 0) {
+		changed = 1;
+		eval.cmd = ETHTOOL_SGSO;
+		eval.data = (off_gso_wanted == 1);
+		ifr->ifr_data = (caddr_t)&eval;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot set device generic segmentation offload settings");
+			return 90;
+		}
+	}
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
 	}

--yoshfuji
