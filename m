From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC PATCH] ethtool: allow setting MDI-X state
Date: Wed, 17 Nov 2010 15:16:55 -0800
Message-ID: <20101117231655.30673.37157.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39616 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698Ab0KQXQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Nov 2010 18:16:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool recently added support for reading MDI-X state, this
patch finishes the implementation, adding the complementary write
command.

Add support to ethtool for controlling the MDI-X (crossover)
state of a network port.  Most adapters correctly negotiate
MDI-X, but some ill-behaved switches have trouble and end up
picking the wrong MDI setting, which results in complete loss of
link.  Usually this error condition can be observed with multiple
ethtool -r ethX required before link is achieved.

usage is ethtool -s eth0 mdix [auto|on|off]

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 ethtool.8 |    8 ++++++++
 ethtool.c |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index 1760924..c96e35d 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -196,6 +196,7 @@ ethtool \- Display or change ethernet card settings
 .BI speed \ N
 .B2 duplex half full
 .B4 port tp aui bnc mii fibre
+.B3 mdix auto on off
 .B2 autoneg on off
 .RB [ advertise
 .IR N ]
@@ -452,6 +453,13 @@ Sets full or half duplex mode.
 .A4 port tp aui bnc mii fibre
 Selects device port.
 .TP
+.A3 mdix auto on off
+Selects MDI-X mode for port. May be used to override the automatic detection
+feature of most adapters.  Auto means automatic detection of MDI status, on
+forces MDI-X (crossover) mode, while off means MDI (straight through) mode.
+Depending on implementation an ethtool -r ethX command may be necessary to
+cause the change to take effect.
+.TP
 .A2 autoneg on off
 Specifies whether autonegotiation should be enabled. Autonegotiation 
 is enabled by deafult, but in some network devices may have trouble
diff --git a/ethtool.c b/ethtool.c
index 239912b..fcc7998 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -157,6 +157,7 @@ static struct option {
 		"		[ speed %d ]\n"
 		"		[ duplex half|full ]\n"
 		"		[ port tp|aui|bnc|mii|fibre ]\n"
+		"		[ mdix auto|on|off ]\n"
 		"		[ autoneg on|off ]\n"
 		"		[ advertise %x ]\n"
 		"		[ phyad %d ]\n"
@@ -353,6 +354,7 @@ static s32 coal_tx_frames_high_wanted = -1;
 static int speed_wanted = -1;
 static int duplex_wanted = -1;
 static int port_wanted = -1;
+static int mdix_wanted = -1;
 static int autoneg_wanted = -1;
 static int phyad_wanted = -1;
 static int xcvr_wanted = -1;
@@ -1048,6 +1050,20 @@ static void parse_cmdline(int argc, char **argp)
 				else
 					show_usage(1);
 				break;
+			} else if (!strcmp(argp[i], "mdix")) {
+				gset_changed = 1;
+				i += 1;
+				if (i >= argc)
+					show_usage(1);
+				if (!strcmp(argp[i], "auto"))
+					mdix_wanted = ETH_TP_MDI_INVALID;
+				else if (!strcmp(argp[i], "on"))
+					mdix_wanted = ETH_TP_MDI_X;
+				else if (!strcmp(argp[i], "off"))
+					mdix_wanted = ETH_TP_MDI;
+				else
+					show_usage(1);
+				break;
 			} else if (!strcmp(argp[i], "autoneg")) {
 				i += 1;
 				if (i >= argc)
@@ -1124,6 +1140,20 @@ static void parse_cmdline(int argc, char **argp)
 					i = argc;
 				}
 				break;
+			} else if (!strcmp(argp[i], "mdix")) {
+				gset_changed = 1;
+				i += 1;
+				if (i >= argc)
+					show_usage(1);
+				if (!strcmp(argp[i], "auto"))
+					mdix_wanted = ETH_TP_MDI_INVALID;
+				else if (!strcmp(argp[i], "on"))
+					mdix_wanted = ETH_TP_MDI_X;
+				else if (!strcmp(argp[i], "off"))
+					mdix_wanted = ETH_TP_MDI;
+				else
+					show_usage(1);
+				break;
 			}
 			show_usage(1);
 		}
@@ -2525,6 +2555,8 @@ static int do_sset(int fd, struct ifreq *ifr)
 				ecmd.duplex = duplex_wanted;
 			if (port_wanted != -1)
 				ecmd.port = port_wanted;
+			if (mdix_wanted != -1)
+				ecmd.eth_tp_mdix = mdix_wanted;
 			if (autoneg_wanted != -1)
 				ecmd.autoneg = autoneg_wanted;
 			if (phyad_wanted != -1)
@@ -2566,6 +2598,8 @@ static int do_sset(int fd, struct ifreq *ifr)
 				fprintf(stderr, "  not setting phy_address\n");
 			if (xcvr_wanted != -1)
 				fprintf(stderr, "  not setting transceiver\n");
+			if (mdix_wanted != -1)
+				fprintf(stderr, "  not setting mdix\n");
 		}
 	}
 

