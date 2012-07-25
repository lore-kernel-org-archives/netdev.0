From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC ETHTOOL PATCH 2/2] ethtool: allow setting MDI-X state
Date: Wed, 25 Jul 2012 10:53:08 -0700
Message-ID: <20120725175308.9839.50343.stgit@jbrandeb-snb.jf.intel.com>
References: <20120725174351.9839.132.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com
To: netdev@vger.kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45999 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428Ab2GYUwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 16:52:04 -0400
In-Reply-To: <20120725174351.9839.132.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bit ago ethtool added support for reading MDI-X state, this
patch finishes the implementation, adding the complementary write
command.

Add support to ethtool for controlling the MDI-X (crossover)
state of a network port.  Most adapters correctly negotiate
MDI-X, but some ill-behaved switches have trouble and end up
picking the wrong MDI setting, which results in complete loss of
link.  Usually this error condition can be observed when multiple
ethtool -r ethX are required before link is achieved.

This patch allows the user to override the normal "auto" setting
and force the crossover state to on or off.

The set will fail if the driver doesn't support the get, as
suggested by Ben Hutchings.

# ./ethtool -s p1p1 mdix off
setting MDI not supported

In addition the do_gset output was changed slightly to report the
value set by the user (when the driver supports the set)

old:
MDI-X: on

new:
MDI-X: on (auto)
or
MDI-X: on (forced)

usage is ethtool -s eth0 mdix [auto|on|off]

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---

 ethtool.8.in |    8 ++++++++
 ethtool.c    |   48 +++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 53 insertions(+), 3 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 523b737..fbfb252 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -239,6 +239,7 @@ ethtool \- query or control network driver and hardware settings
 .BI speed \ N
 .B2 duplex half full
 .B4 port tp aui bnc mii fibre
+.B3 mdix auto on off
 .B2 autoneg on off
 .BN advertise
 .BN phyad
@@ -518,6 +519,13 @@ Sets full or half duplex mode.
 .A4 port tp aui bnc mii fibre
 Selects device port.
 .TP
+.A3 mdix auto on off
+Selects MDI-X mode for port. May be used to override the automatic detection
+feature of most adapters.  Auto means automatic detection of MDI status, on
+forces MDI-X (crossover) mode, while off means MDI (straight through) mode.
+The driver should guarantee that this command takes effect immediately, and
+if necessary may reset the link to cause the change to take effect.
+.TP
 .A2 autoneg on off
 Specifies whether autonegotiation should be enabled. Autonegotiation 
 is enabled by default, but in some network devices may have trouble
diff --git a/ethtool.c b/ethtool.c
index f18f611..7b60895 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -18,6 +18,8 @@
  * Rx Network Flow Control configuration support <santwona.behera@sun.com>
  * Various features by Ben Hutchings <bhutchings@solarflare.com>;
  *	Copyright 2009, 2010 Solarflare Communications
+ * MDI-X set support by Jesse Brandeburg <jesse.brandeburg@intel.com>
+ * 	Copyright 2012 Intel Corporation
  *
  * TODO:
  *   * show settings for all devices
@@ -559,13 +561,29 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 		fprintf(stdout, "	MDI-X: ");
 		switch (ep->eth_tp_mdix) {
 		case ETH_TP_MDI:
-			fprintf(stdout, "off\n");
+			fprintf(stdout, "off");
 			break;
 		case ETH_TP_MDI_X:
-			fprintf(stdout, "on\n");
+			fprintf(stdout, "on");
 			break;
 		default:
-			fprintf(stdout, "Unknown\n");
+			fprintf(stdout, "Unknown");
+			break;
+		}
+		switch (ep->eth_tp_mdix_ctrl) {
+		case ETH_TP_MDI:
+		case ETH_TP_MDI_X:
+			/* forced via sset */
+			fprintf(stdout, " (forced)\n");
+			break;
+		case ETH_TP_MDI_AUTO:
+			/* not forced */
+			fprintf(stdout, " (auto)\n");
+			break;
+		case ETH_TP_MDI_INVALID:
+		default:
+			/* this interface doesn't support gset MDI-X */
+			fprintf(stdout, "\n");
 			break;
 		}
 	}
@@ -1939,6 +1957,7 @@ static int do_sset(struct cmd_context *ctx)
 	int speed_wanted = -1;
 	int duplex_wanted = -1;
 	int port_wanted = -1;
+	int mdix_wanted = -1;
 	int autoneg_wanted = -1;
 	int phyad_wanted = -1;
 	int xcvr_wanted = -1;
@@ -1999,6 +2018,19 @@ static int do_sset(struct cmd_context *ctx)
 				port_wanted = PORT_FIBRE;
 			else
 				exit_bad_args();
+		} else if (!strcmp(argp[i], "mdix")) {
+			gset_changed = 1;
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			if (!strcmp(argp[i], "auto"))
+				mdix_wanted = ETH_TP_MDI_AUTO;
+			else if (!strcmp(argp[i], "on"))
+				mdix_wanted = ETH_TP_MDI_X;
+			else if (!strcmp(argp[i], "off"))
+				mdix_wanted = ETH_TP_MDI;
+			else
+				exit_bad_args();
 		} else if (!strcmp(argp[i], "autoneg")) {
 			i += 1;
 			if (i >= argc)
@@ -2120,6 +2152,13 @@ static int do_sset(struct cmd_context *ctx)
 				ecmd.duplex = duplex_wanted;
 			if (port_wanted != -1)
 				ecmd.port = port_wanted;
+			if (mdix_wanted != -1) {
+				/* check driver supports MDI-X */
+				if (ecmd.eth_tp_mdix_ctrl != ETH_TP_MDI_INVALID)
+					ecmd.eth_tp_mdix_ctrl = mdix_wanted;
+				else
+					fprintf(stderr, "setting MDI not supported\n");
+			}
 			if (autoneg_wanted != -1)
 				ecmd.autoneg = autoneg_wanted;
 			if (phyad_wanted != -1)
@@ -2179,6 +2218,8 @@ static int do_sset(struct cmd_context *ctx)
 				fprintf(stderr, "  not setting phy_address\n");
 			if (xcvr_wanted != -1)
 				fprintf(stderr, "  not setting transceiver\n");
+			if (mdix_wanted != -1)
+				fprintf(stderr, "  not setting mdix\n");
 		}
 	}
 
@@ -3285,6 +3326,7 @@ static const struct option {
 	  "		[ speed %d ]\n"
 	  "		[ duplex half|full ]\n"
 	  "		[ port tp|aui|bnc|mii|fibre ]\n"
+	  "		[ mdix auto|on|off ]\n"
 	  "		[ autoneg on|off ]\n"
 	  "		[ advertise %x ]\n"
 	  "		[ phyad %d ]\n"
