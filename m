From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] ethtool: Add 2.5G support
Date: Thu, 03 May 2007 00:27:10 -0700
Message-ID: <1178177230.4909.63.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1305 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161187AbXECGkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:40:05 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add 2.5G Serdes support to ethtool user program and ethtool.8 man
page.  The missing pause bits are also added to keep ethtool-copy.h
in sync with the kernel's version.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 30f5e05..4615ef6 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -306,6 +306,9 @@ struct ethtool_stats {
 #define SUPPORTED_FIBRE			(1 << 10)
 #define SUPPORTED_BNC			(1 << 11)
 #define SUPPORTED_10000baseT_Full	(1 << 12)
+#define SUPPORTED_Pause			(1 << 13)
+#define SUPPORTED_Asym_Pause		(1 << 14)
+#define SUPPORTED_2500baseX_Full	(1 << 15)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -321,6 +324,9 @@ struct ethtool_stats {
 #define ADVERTISED_FIBRE		(1 << 10)
 #define ADVERTISED_BNC			(1 << 11)
 #define ADVERTISED_10000baseT_Full	(1 << 12)
+#define ADVERTISED_Pause		(1 << 13)
+#define ADVERTISED_Asym_Pause		(1 << 14)
+#define ADVERTISED_2500baseX_Full	(1 << 15)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
@@ -332,6 +338,7 @@ struct ethtool_stats {
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
+#define SPEED_2500		2500
 #define SPEED_10000		10000
 
 /* Duplex, half or full. */
diff --git a/ethtool.8 b/ethtool.8
index d6561bf..248260a 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -175,7 +175,7 @@ ethtool \- Display or change ethernet card settings
 
 .B ethtool \-s
 .I ethX
-.B4 speed 10 100 1000 10000
+.B4 speed 10 100 1000 2500 10000
 .B2 duplex half full
 .B4 port tp aui bnc mii fibre
 .B2 autoneg on off
@@ -326,7 +326,7 @@ All following options only apply if
 .B \-s
 was specified.
 .TP
-.A4 speed 10 100 1000 10000
+.A4 speed 10 100 1000 2500 10000
 Set speed in Mb/s.
 .B ethtool
 with just the device name as an argument will show you the supported device speeds.
@@ -360,6 +360,8 @@ a hexidecimal value using one or a combination of the following values:
 .TP 3
 .BR "0x020" "    1000 Full"
 .TP 3
+.BR "0x8000" "   2500 Full" "(not supported by IEEE standards)"
+.TP 3
 .BR "0x800" "    10000 Full"
 .TP 3
 .BR "0x03F" "    Auto"
diff --git a/ethtool.c b/ethtool.c
index 1fbad09..4aa8e06 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -98,7 +98,7 @@ static struct option {
     char *opthelp;
 } args[] = {
     { "-s", "--change", MODE_SSET, "Change generic options",
-		"		[ speed 10|100|1000|10000 ]\n"
+		"		[ speed 10|100|1000|2500|10000 ]\n"
 		"		[ duplex half|full ]\n"
 		"		[ port tp|aui|bnc|mii|fibre ]\n"
 		"		[ autoneg on|off ]\n"
@@ -521,6 +521,8 @@ static void parse_cmdline(int argc, char **argp)
 					speed_wanted = SPEED_100;
 				else if (!strcmp(argp[i], "1000"))
 					speed_wanted = SPEED_1000;
+				else if (!strcmp(argp[i], "2500"))
+					speed_wanted = SPEED_2500;
 				else if (!strcmp(argp[1], "10000"))
 					speed_wanted = SPEED_10000;
 				else
@@ -649,6 +651,9 @@ static void parse_cmdline(int argc, char **argp)
 		else if (speed_wanted == SPEED_1000 &&
 			 duplex_wanted == DUPLEX_FULL)
 			advertising_wanted = ADVERTISED_1000baseT_Full;
+		else if (speed_wanted == SPEED_2500 &&
+			 duplex_wanted == DUPLEX_FULL)
+			advertising_wanted = ADVERTISED_2500baseX_Full;
 		else if (speed_wanted == SPEED_10000 &&
 			 duplex_wanted == DUPLEX_FULL)
 			advertising_wanted = ADVERTISED_10000baseT_Full;
@@ -712,6 +717,13 @@ static void dump_supported(struct ethtool_cmd *ep)
 	if (mask & SUPPORTED_1000baseT_Full) {
 		did1++; fprintf(stdout, "1000baseT/Full ");
 	}
+	if (did1 && (mask & SUPPORTED_2500baseX_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	                        ");
+	}
+	if (mask & SUPPORTED_2500baseX_Full) {
+		did1++; fprintf(stdout, "2500baseX/Full ");
+	}
 	fprintf(stdout, "\n");
 
 	fprintf(stdout, "	Supports auto-negotiation: ");
@@ -754,6 +766,13 @@ static void dump_advertised(struct ethtool_cmd *ep)
 	if (mask & ADVERTISED_1000baseT_Full) {
 		did1++; fprintf(stdout, "1000baseT/Full ");
 	}
+	if (did1 && (mask & ADVERTISED_2500baseX_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	                        ");
+	}
+	if (mask & ADVERTISED_2500baseX_Full) {
+		did1++; fprintf(stdout, "2500baseX/Full ");
+	}
 	if (did1 && (mask & ADVERTISED_10000baseT_Full)) {
 		fprintf(stdout, "\n");
 		fprintf(stdout, "	                        ");
@@ -788,6 +807,9 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	case SPEED_1000:
 		fprintf(stdout, "1000Mb/s\n");
 		break;
+	case SPEED_2500:
+		fprintf(stdout, "2500Mb/s\n");
+		break;
 	case SPEED_10000:
 		fprintf(stdout, "10000Mb/s\n");
 		break;
@@ -1712,6 +1734,7 @@ static int do_sset(int fd, struct ifreq *ifr)
 						 ADVERTISED_100baseT_Full |
 						 ADVERTISED_1000baseT_Half |
 						 ADVERTISED_1000baseT_Full |
+						 ADVERTISED_2500baseX_Full |
 						 ADVERTISED_10000baseT_Full);
 				else
 					ecmd.advertising = advertising_wanted;


