From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool 2/2] ethtool: allow setting MDI-X state
Date: Tue, 21 Aug 2012 01:37:16 -0700
Message-ID: <1345538236-1636-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1345538236-1636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34228 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628Ab2HUIhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 04:37:22 -0400
In-Reply-To: <1345538236-1636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

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
Tested-by: Aaron Brown aaron.f.brown@intel.com
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ethtool.8.in |  8 ++++++++
 ethtool.c    | 55 +++++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 53 insertions(+), 10 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7253832..3208d38 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -229,6 +229,7 @@ ethtool \- query or control network driver and hardware settings
 .BI speed \ N
 .B2 duplex half full
 .B4 port tp aui bnc mii fibre
+.B3 mdix auto on off
 .B2 autoneg on off
 .BN advertise
 .BN phyad
@@ -521,6 +522,13 @@ Sets full or half duplex mode.
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
index e573357..e21b7cb 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -18,6 +18,8 @@
  * Rx Network Flow Control configuration support <santwona.behera@sun.com>
  * Various features by Ben Hutchings <bhutchings@solarflare.com>;
  *	Copyright 2009, 2010 Solarflare Communications
+ * MDI-X set support by Jesse Brandeburg <jesse.brandeburg@intel.com>
+ *	Copyright 2012 Intel Corporation
  *
  * TODO:
  *   * show settings for all devices
@@ -602,16 +604,25 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 
 	if (ep->port == PORT_TP) {
 		fprintf(stdout, "	MDI-X: ");
-		switch (ep->eth_tp_mdix) {
-		case ETH_TP_MDI:
-			fprintf(stdout, "off\n");
-			break;
-		case ETH_TP_MDI_X:
-			fprintf(stdout, "on\n");
-			break;
-		default:
-			fprintf(stdout, "Unknown\n");
-			break;
+		if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI) {
+			fprintf(stdout, "off (forced)\n");
+		} else if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI_X) {
+			fprintf(stdout, "on (forced)\n");
+		} else {
+			switch (ep->eth_tp_mdix) {
+			case ETH_TP_MDI:
+				fprintf(stdout, "off");
+				break;
+			case ETH_TP_MDI_X:
+				fprintf(stdout, "on");
+				break;
+			default:
+				fprintf(stdout, "Unknown");
+				break;
+			}
+			if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
+				fprintf(stdout, " (auto)");
+			fprintf(stdout, "\n");
 		}
 	}
 
@@ -2199,6 +2210,7 @@ static int do_sset(struct cmd_context *ctx)
 	int speed_wanted = -1;
 	int duplex_wanted = -1;
 	int port_wanted = -1;
+	int mdix_wanted = -1;
 	int autoneg_wanted = -1;
 	int phyad_wanted = -1;
 	int xcvr_wanted = -1;
@@ -2259,6 +2271,19 @@ static int do_sset(struct cmd_context *ctx)
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
@@ -2380,6 +2405,13 @@ static int do_sset(struct cmd_context *ctx)
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
@@ -2439,6 +2471,8 @@ static int do_sset(struct cmd_context *ctx)
 				fprintf(stderr, "  not setting phy_address\n");
 			if (xcvr_wanted != -1)
 				fprintf(stderr, "  not setting transceiver\n");
+			if (mdix_wanted != -1)
+				fprintf(stderr, "  not setting mdix\n");
 		}
 	}
 
@@ -3604,6 +3638,7 @@ static const struct option {
 	  "		[ speed %d ]\n"
 	  "		[ duplex half|full ]\n"
 	  "		[ port tp|aui|bnc|mii|fibre ]\n"
+	  "		[ mdix auto|on|off ]\n"
 	  "		[ autoneg on|off ]\n"
 	  "		[ advertise %x ]\n"
 	  "		[ phyad %d ]\n"
-- 
1.7.11.4
