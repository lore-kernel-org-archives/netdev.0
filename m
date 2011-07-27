From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC ethtool PATCH] ethtool: Add new commands to set VFs,
	VM queues and spoof checking
Date: Wed, 27 Jul 2011 15:23:17 -0700
Message-ID: <20110727222317.8595.55126.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8843 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755326Ab1G0WXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 18:23:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 ethtool-copy.h |   11 ++++++++++-
 ethtool.c      |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index c7a18f7..0360070 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -33,12 +33,14 @@ struct ethtool_cmd {
 	__u8	mdio_support;
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
+	__u32	num_vfs;	/* Enable SR-IOV VFs */
+	__u32	num_vmqs;	/* Set number of queues for VMDq */
 	__u16	speed_hi;       /* The forced speed (upper
 				 * bits) in Mbps. Please use
 				 * ethtool_cmd_speed()/_set() to
 				 * access it */
 	__u8	eth_tp_mdix;
-	__u8	reserved2;
+	__u8	spoof_check;	/* Enable/Disable anti-spoofing */
 	__u32	lp_advertising;	/* Features the link partner advertises */
 	__u32	reserved[2];
 };
@@ -846,6 +848,13 @@ enum ethtool_sfeatures_retval_bits {
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
+/* Enable or disable MAC and/or VLAN spoofchecking.If this is
+ * set to enable, then depending on the controller capabilities
+ * MAC and/or VLAN spoofing will be turned on.
+ */
+#define SPOOFCHECK_DISABLE	0x00
+#define SPOOFCHECK_ENABLE	0x01
+
 /* Mode MDI or MDI-X */
 #define ETH_TP_MDI_INVALID	0x00
 #define ETH_TP_MDI		0x01
diff --git a/ethtool.c b/ethtool.c
index c189c78..0154f41 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -148,6 +148,9 @@ static struct option {
 		"		[ autoneg on|off ]\n"
 		"		[ advertise %x ]\n"
 		"		[ phyad %d ]\n"
+		"		[ vfs %d ]\n"
+		"		[ vmqueues %d]\n"
+		"		[ spoofcheck on|off ]\n"
 		"		[ xcvr internal|external ]\n"
 		"		[ wol p|u|m|b|a|g|s|d... ]\n"
 		"		[ sopass %x:%x:%x:%x:%x:%x ]\n"
@@ -362,6 +365,9 @@ static int port_wanted = -1;
 static int autoneg_wanted = -1;
 static int phyad_wanted = -1;
 static int xcvr_wanted = -1;
+static int num_vfs_wanted = -1;
+static int num_vmqs_wanted = -1;
+static u8 spoofchk_wanted = -1;
 static int advertising_wanted = -1;
 static int gset_changed = 0; /* did anything in GSET change? */
 static u32  wol_wanted = 0;
@@ -1074,6 +1080,34 @@ static void parse_cmdline(int argc, char **argp)
 					exit_bad_args();
 				phyad_wanted = get_int(argp[i], 0);
 				break;
+			} else if (!strcmp(argp[i], "vfs")) {
+				gset_changed = 1;
+				i += 1;
+				if (i >= argc)
+					exit_bad_args();
+				num_vfs_wanted = get_int(argp[i], 0);
+				break;
+			} else if (!strcmp(argp[i], "vmqueues")) {
+				gset_changed = 1;
+				i += 1;
+				if (i >= argc)
+					exit_bad_args();
+				num_vmqs_wanted = get_int(argp[i], 0);
+				break;
+			} else if (!strcmp(argp[i], "spoofcheck")) {
+				i += 1;
+				if (i >= argc)
+					exit_bad_args();
+				if (!strcmp(argp[i], "on")) {
+					gset_changed = 1;
+					spoofchk_wanted = SPOOFCHECK_ENABLE;
+				} else if (!strcmp(argp[i], "off")) {
+					gset_changed = 1;
+					spoofchk_wanted = SPOOFCHECK_DISABLE;
+				} else {
+					exit_bad_args();
+				}
+				break;
 			} else if (!strcmp(argp[i], "xcvr")) {
 				gset_changed = 1;
 				i += 1;
@@ -2447,6 +2481,12 @@ static int do_sset(int fd, struct ifreq *ifr)
 				ecmd.phy_address = phyad_wanted;
 			if (xcvr_wanted != -1)
 				ecmd.transceiver = xcvr_wanted;
+			if (num_vfs_wanted != -1)
+				ecmd.num_vfs = num_vfs_wanted;
+			if (num_vmqs_wanted != -1)
+				ecmd.num_vmqs = num_vmqs_wanted;
+			if (spoofchk_wanted != -1)
+				ecmd.spoof_check = spoofchk_wanted;
 			/* XXX If the user specified speed or duplex
 			 * then we should mask the advertised modes
 			 * accordingly.  For now, warn that we aren't

