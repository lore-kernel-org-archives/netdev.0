From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] ethtool: add the EEE option
Date: Tue, 28 Feb 2012 13:46:15 +0100
Message-ID: <1330433175-21811-1-git-send-email-peppe.cavallaro@st.com>
References: <1330433084-18586-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:49771 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932299Ab2B1Mqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 07:46:40 -0500
In-Reply-To: <1330433084-18586-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new option to enable/disable the
Energy Efficient Ethernet support: below some example:

bash-3.00# ethtool -s eth0 eee on
stmmac: Energy-Efficient Ethernet initialized

bash-3.00# ./ethtool eth0
Settings for eth0:
	Supported ports: [ TP MII ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
[snip]
	Wake-on: d
	Current message level: 0x0000003f (63)
			       drv probe link timer ifdown ifup
	Link detected: yes
	Energy-Efficient Ethernet: Enabled

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 ethtool-copy.h |    3 +++
 ethtool.c      |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d904c1a..e17ae37 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -40,6 +40,7 @@ struct ethtool_cmd {
 	__u8	eth_tp_mdix;
 	__u8	reserved2;
 	__u32	lp_advertising;	/* Features the link partner advertises */
+	__u32	eee;		/* Energy-Efficient Etehrnet */
 	__u32	reserved[2];
 };
 
@@ -786,6 +787,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GEEE		0x00000041 /* Get EEE */
+#define ETHTOOL_SEEE		0x00000042 /* Set EEE */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index d0cc7d4..9e63973 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1840,6 +1840,18 @@ static int do_gset(struct cmd_context *ctx)
 	} else if (errno != EOPNOTSUPP) {
 		perror("Cannot get link status");
 	}
+	edata.cmd = ETHTOOL_GEEE;
+	err = send_ioctl(ctx, &edata);
+	if (err == 0) {
+		fprintf(stdout, "	Energy-Efficient Ethernet: %s\n",
+			edata.data ? "enabled" : "disabled");
+		allfail = 0;
+	} else if (errno != EOPNOTSUPP) {
+		perror("Cannot get EEE feature");
+	} else if (errno == EOPNOTSUPP) {
+		fprintf(stdout, "	Energy-Efficient Ethernet:"
+				" not supported\n");
+	}
 
 	if (allfail) {
 		fprintf(stdout, "No data available\n");
@@ -1857,6 +1869,8 @@ static int do_sset(struct cmd_context *ctx)
 	int phyad_wanted = -1;
 	int xcvr_wanted = -1;
 	int advertising_wanted = -1;
+	int eee_wanted = -1;
+	int eee_changed = 0;
 	int gset_changed = 0; /* did anything in GSET change? */
 	u32 wol_wanted = 0;
 	int wol_change = 0;
@@ -1983,6 +1997,17 @@ static int do_sset(struct cmd_context *ctx)
 					ARRAY_SIZE(cmdline_msglvl));
 				break;
 			}
+		} else if (!strcmp(argp[i], "eee")) {
+			eee_changed = 1;
+			i++;
+			if (i >= argc)
+				exit_bad_args();
+			if (!strcmp(argp[i], "on"))
+				eee_wanted = 1;
+			else if (!strcmp(argp[i], "off"))
+				eee_wanted = 0;
+			else
+				exit_bad_args();
 		} else {
 			exit_bad_args();
 		}
@@ -2129,6 +2154,23 @@ static int do_sset(struct cmd_context *ctx)
 		}
 	}
 
+	if (eee_changed) {
+		struct ethtool_value edata;
+
+		edata.cmd = ETHTOOL_GEEE;
+		err = send_ioctl(ctx, &edata);
+		if (err < 0)
+			perror("Cannot get current EEE settings");
+		else {
+			edata.cmd = ETHTOOL_SEEE;
+			edata.data = eee_wanted;
+			err = send_ioctl(ctx, &edata);
+			if (err < 0)
+				fprintf(stderr, "Cannot turn %s the EEE",
+					(eee_wanted ? "on" : "off"));
+		}
+	}
+
 	if (msglvl_changed) {
 		struct ethtool_value edata;
 
@@ -3129,7 +3171,8 @@ static const struct option {
 	  "		[ xcvr internal|external ]\n"
 	  "		[ wol p|u|m|b|a|g|s|d... ]\n"
 	  "		[ sopass %x:%x:%x:%x:%x:%x ]\n"
-	  "		[ msglvl %d | msglvl type on|off ... ]\n" },
+	  "		[ msglvl %d | msglvl type on|off ]\n"
+	  "		[ eee on|off ... ]\n" },
 	{ "-a|--show-pause", 1, do_gpause, "Show pause options" },
 	{ "-A|--pause", 1, do_spause, "Set pause options",
 	  "		[ autoneg on|off ]\n"
-- 
1.7.4.4
