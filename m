From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/2] ethtool: Implement named message type flags
Date: Tue, 18 May 2010 17:33:11 +0100
Message-ID: <1274200391.2113.1.camel@achroite.uk.solarflarecom.com>
References: <1274200336.2113.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14524 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab0ERQdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 12:33:15 -0400
In-Reply-To: <1274200336.2113.0.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow message type flags to be turned on and off by name.
Print the names of the currently set flags below the numeric value.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8 |   66 ++++++++++++++++++++++++++++++-
 ethtool.c |  127 +++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 178 insertions(+), 15 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index a7b43d5..5983d0e 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -200,7 +200,10 @@ ethtool \- Display or change ethernet card settings
 .RB [ wol \ \*(WO]
 .RB [ sopass \ \*(MA]
 .RB [ msglvl
-.IR N ]
+.IR N \ |
+.BI msglvl \ type
+.A1 on off
+.RB ...]
 
 .B ethtool \-n
 .I ethX
@@ -482,9 +485,66 @@ Disable (wake on nothing).  This option clears all previous options.
 .B sopass \*(MA\c
 Sets the SecureOn(tm) password.  The argument to this option must be 6
 bytes in ethernet MAC hex format (\*(MA).
-.TP
+.PP
 .BI msglvl \ N
-Sets the driver message level. Meanings differ per driver.
+.br
+.BI msglvl \ type
+.A1 on off
+.RB ...
+.RS
+Sets the driver message type flags by name or number. \fItype\fR
+names the type of message to enable or disable; \fIN\fR specifies the
+new flags numerically. The defined type names and numbers are:
+.PD 0
+.TP 12
+.B drv
+0x0001  General driver status
+.TP 12
+.B probe
+0x0002  Hardware probing
+.TP 12
+.B link
+0x0004  Link state
+.TP 12
+.B timer
+0x0008  Periodic status check
+.TP 12
+.B ifdown
+0x0010  Interface being brought down
+.TP 12
+.B ifup
+0x0020  Interface being brought up
+.TP 12
+.B rx_err
+0x0040  Receive error
+.TP 12
+.B tx_err
+0x0080  Transmit error
+.TP 12
+.B tx_queued
+0x0100  Transmit queueing
+.TP 12
+.B intr
+0x0200  Interrupt handling
+.TP 12
+.B tx_done
+0x0400  Transmit completion
+.TP 12
+.B rx_status
+0x0800  Receive completion
+.TP 12
+.B pktdata
+0x1000  Packet contents
+.TP 12
+.B hw
+0x2000  Hardware status
+.TP 12
+.B wol
+0x4000  Wake-on-LAN status
+.PP
+The precise meanings of these type flags differ between drivers.
+.PD
+.RE
 .TP
 .B \-n \-\-show-nfc
 Retrieves the receive network flow classification configurations.
diff --git a/ethtool.c b/ethtool.c
index 7004b7f..380a054 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -20,7 +20,6 @@
  *   * better man page (steal from mii-tool?)
  *   * fall back on SIOCMII* ioctl()s and possibly SIOCDEVPRIVATE*
  *   * abstract ioctls to allow for fallback modes of data gathering
- *   * symbolic names for msglvl bitmask
  */
 
 #ifdef HAVE_CONFIG_H
@@ -39,6 +38,7 @@
 #include <net/if.h>
 #include <sys/utsname.h>
 #include <limits.h>
+#include <ctype.h>
 
 #include <linux/sockios.h>
 #include "ethtool-util.h"
@@ -51,6 +51,26 @@
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 #endif
 
+#ifndef HAVE_NETIF_MSG
+enum {
+	NETIF_MSG_DRV		= 0x0001,
+	NETIF_MSG_PROBE		= 0x0002,
+	NETIF_MSG_LINK		= 0x0004,
+	NETIF_MSG_TIMER		= 0x0008,
+	NETIF_MSG_IFDOWN	= 0x0010,
+	NETIF_MSG_IFUP		= 0x0020,
+	NETIF_MSG_RX_ERR	= 0x0040,
+	NETIF_MSG_TX_ERR	= 0x0080,
+	NETIF_MSG_TX_QUEUED	= 0x0100,
+	NETIF_MSG_INTR		= 0x0200,
+	NETIF_MSG_TX_DONE	= 0x0400,
+	NETIF_MSG_RX_STATUS	= 0x0800,
+	NETIF_MSG_PKTDATA	= 0x1000,
+	NETIF_MSG_HW		= 0x2000,
+	NETIF_MSG_WOL		= 0x4000,
+};
+#endif
+
 static int parse_wolopts(char *optstr, u32 *data);
 static char *unparse_wolopts(int wolopts);
 static int parse_sopass(char *src, unsigned char *dest);
@@ -126,7 +146,7 @@ static struct option {
 		"		[ xcvr internal|external ]\n"
 		"		[ wol p|u|m|b|a|g|s|d... ]\n"
 		"		[ sopass %x:%x:%x:%x:%x:%x ]\n"
-		"		[ msglvl %d ] \n" },
+		"		[ msglvl %d | msglvl type on|off ... ]\n" },
     { "-a", "--show-pause", MODE_GPAUSE, "Show pause options" },
     { "-A", "--pause", MODE_SPAUSE, "Set pause options",
       "		[ autoneg on|off ]\n"
@@ -311,7 +331,6 @@ static int wol_change = 0;
 static u8 sopass_wanted[SOPASS_MAX];
 static int sopass_change = 0;
 static int gwol_changed = 0; /* did anything in GWOL change? */
-static int msglvl_wanted = -1;
 static int phys_id_time = 0;
 static int gregs_changed = 0;
 static int gregs_dump_raw = 0;
@@ -335,6 +354,25 @@ static struct ethtool_rx_ntuple_flow_spec ntuple_fs;
 static char *flash_file = NULL;
 static int flash = -1;
 static int flash_region = -1;
+
+static int msglvl_changed = 0;
+static int msglvl_wanted = -1;
+static int msg_drv_wanted = -1;
+static int msg_probe_wanted = -1;
+static int msg_link_wanted = -1;
+static int msg_timer_wanted = -1;
+static int msg_ifdown_wanted = -1;
+static int msg_ifup_wanted = -1;
+static int msg_rx_err_wanted = -1;
+static int msg_tx_err_wanted = -1;
+static int msg_tx_queued_wanted = -1;
+static int msg_intr_wanted = -1;
+static int msg_tx_done_wanted = -1;
+static int msg_rx_status_wanted = -1;
+static int msg_pktdata_wanted = -1;
+static int msg_hw_wanted = -1;
+static int msg_wol_wanted = -1;
+
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -447,6 +485,42 @@ static struct cmdline_info cmdline_ntuple[] = {
 	{ "action", CMDL_INT, &ntuple_fs.action, NULL },
 };
 
+static struct cmdline_info cmdline_msglvl[] = {
+	{ "drv", CMDL_BOOL, &msg_drv_wanted, NULL },
+	{ "probe", CMDL_BOOL, &msg_probe_wanted, NULL },
+	{ "link", CMDL_BOOL, &msg_link_wanted, NULL },
+	{ "timer", CMDL_BOOL, &msg_timer_wanted, NULL },
+	{ "ifdown", CMDL_BOOL, &msg_ifdown_wanted, NULL },
+	{ "ifup", CMDL_BOOL, &msg_ifup_wanted, NULL },
+	{ "rx_err", CMDL_BOOL, &msg_rx_err_wanted, NULL },
+	{ "tx_err", CMDL_BOOL, &msg_tx_err_wanted, NULL },
+	{ "tx_queued", CMDL_BOOL, &msg_tx_queued_wanted, NULL },
+	{ "intr", CMDL_BOOL, &msg_intr_wanted, NULL },
+	{ "tx_done", CMDL_BOOL, &msg_tx_done_wanted, NULL },
+	{ "rx_status", CMDL_BOOL, &msg_rx_status_wanted, NULL },
+	{ "pktdata", CMDL_BOOL, &msg_pktdata_wanted, NULL },
+	{ "hw", CMDL_BOOL, &msg_hw_wanted, NULL },
+	{ "wol", CMDL_BOOL, &msg_wol_wanted, NULL },
+};
+
+static struct named_flag flag_msglvl[] = {
+	{ "drv", NETIF_MSG_DRV, &msg_drv_wanted },
+	{ "probe", NETIF_MSG_PROBE, &msg_probe_wanted },
+	{ "link", NETIF_MSG_LINK, &msg_link_wanted },
+	{ "timer", NETIF_MSG_TIMER, &msg_timer_wanted },
+	{ "ifdown", NETIF_MSG_IFDOWN, &msg_ifdown_wanted },
+	{ "ifup", NETIF_MSG_IFUP, &msg_ifup_wanted },
+	{ "rx_err", NETIF_MSG_RX_ERR, &msg_rx_err_wanted },
+	{ "tx_err", NETIF_MSG_TX_ERR, &msg_tx_err_wanted },
+	{ "tx_queued", NETIF_MSG_TX_QUEUED, &msg_tx_queued_wanted },
+	{ "intr", NETIF_MSG_INTR, &msg_intr_wanted },
+	{ "tx_done", NETIF_MSG_TX_DONE, &msg_tx_done_wanted },
+	{ "rx_status", NETIF_MSG_RX_STATUS, &msg_rx_status_wanted },
+	{ "pktdata", NETIF_MSG_PKTDATA, &msg_pktdata_wanted },
+	{ "hw", NETIF_MSG_HW, &msg_hw_wanted },
+	{ "wol", NETIF_MSG_WOL, &msg_wol_wanted },
+};
+
 static int get_int(char *str, int base)
 {
 	long v;
@@ -877,7 +951,17 @@ static void parse_cmdline(int argc, char **argp)
 				i++;
 				if (i >= argc)
 					show_usage(1);
-				msglvl_wanted = get_int(argp[i], 0);
+				if (isdigit((unsigned char)argp[i][0])) {
+					msglvl_wanted = get_int(argp[i], 0);
+					msglvl_changed = 1;
+				} else {
+					parse_generic_cmdline(
+						argc, argp, i,
+						&msglvl_changed,
+						cmdline_msglvl,
+						ARRAY_SIZE(cmdline_msglvl));
+					i = argc;
+				}
 				break;
 			}
 			show_usage(1);
@@ -2203,8 +2287,11 @@ static int do_gset(int fd, struct ifreq *ifr)
 	ifr->ifr_data = (caddr_t)&edata;
 	err = send_ioctl(fd, ifr);
 	if (err == 0) {
-		fprintf(stdout, "	Current message level: 0x%08x (%d)\n",
+		fprintf(stdout, "	Current message level: 0x%08x (%d)\n"
+			"			       ",
 			edata.data, edata.data);
+		print_flags(flag_msglvl, ARRAY_SIZE(flag_msglvl), edata.data);
+		fprintf(stdout, "\n");
 		allfail = 0;
 	} else if (errno != EOPNOTSUPP) {
 		perror("Cannot get message level");
@@ -2327,15 +2414,31 @@ static int do_sset(int fd, struct ifreq *ifr)
 		}
 	}
 
-	if (msglvl_wanted != -1) {
+	if (msglvl_changed) {
 		struct ethtool_value edata;
 
-		edata.cmd = ETHTOOL_SMSGLVL;
-		edata.data = msglvl_wanted;
-		ifr->ifr_data = (caddr_t)&edata;;
-		err = send_ioctl(fd, ifr);
-		if (err < 0)
-			perror("Cannot set new msglvl");
+		if (msglvl_wanted == -1) {
+			edata.cmd = ETHTOOL_GMSGLVL;
+			ifr->ifr_data = (caddr_t)&edata;;
+			err = send_ioctl(fd, ifr);
+			if (err < 0)
+				perror("Cannot get msglvl");
+			else
+				msglvl_wanted = update_flags(
+					flag_msglvl, ARRAY_SIZE(flag_msglvl),
+					edata.data);
+		} else {
+			err = 0;
+		}
+
+		if (err == 0) {
+			edata.cmd = ETHTOOL_SMSGLVL;
+			edata.data = msglvl_wanted;
+			ifr->ifr_data = (caddr_t)&edata;;
+			err = send_ioctl(fd, ifr);
+			if (err < 0)
+				perror("Cannot set new msglvl");
+		}
 	}
 
 	return 0;
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

