From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 4/5] ethtool: Implement named message type flags
Date: Fri, 25 Jun 2010 15:49:45 +0100
Message-ID: <1277477385.2094.9.camel@achroite.uk.solarflarecom.com>
References: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11806 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089Ab0FYOts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 10:49:48 -0400
In-Reply-To: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow message type flags to be turned on and off by name.
Print the names of the currently set flags below the numeric value.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8 |   66 +++++++++++++++++++++++++++++++++++++--
 ethtool.c |  104 ++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 156 insertions(+), 14 deletions(-)

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
index 4adab4b..a70cd03 100644
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
@@ -313,7 +333,6 @@ static int wol_change = 0;
 static u8 sopass_wanted[SOPASS_MAX];
 static int sopass_change = 0;
 static int gwol_changed = 0; /* did anything in GWOL change? */
-static int msglvl_wanted = -1;
 static int phys_id_time = 0;
 static int gregs_changed = 0;
 static int gregs_dump_raw = 0;
@@ -337,6 +356,11 @@ static struct ethtool_rx_ntuple_flow_spec ntuple_fs;
 static char *flash_file = NULL;
 static int flash = -1;
 static int flash_region = -1;
+
+static int msglvl_changed;
+static u32 msglvl_wanted = 0;
+static u32 msglvl_unwanted =0;
+
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -455,6 +479,39 @@ static struct cmdline_info cmdline_ntuple[] = {
 	{ "action", CMDL_S32, &ntuple_fs.action, NULL },
 };
 
+static struct cmdline_info cmdline_msglvl[] = {
+	{ "drv", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_DRV, &msglvl_unwanted },
+	{ "probe", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_PROBE, &msglvl_unwanted },
+	{ "link", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_LINK, &msglvl_unwanted },
+	{ "timer", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_TIMER, &msglvl_unwanted },
+	{ "ifdown", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_IFDOWN, &msglvl_unwanted },
+	{ "ifup", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_IFUP, &msglvl_unwanted },
+	{ "rx_err", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_RX_ERR, &msglvl_unwanted },
+	{ "tx_err", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_TX_ERR, &msglvl_unwanted },
+	{ "tx_queued", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_TX_QUEUED, &msglvl_unwanted },
+	{ "intr", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_INTR, &msglvl_unwanted },
+	{ "tx_done", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_TX_DONE, &msglvl_unwanted },
+	{ "rx_status", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_RX_STATUS, &msglvl_unwanted },
+	{ "pktdata", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_PKTDATA, &msglvl_unwanted },
+	{ "hw", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_HW, &msglvl_unwanted },
+	{ "wol", CMDL_FLAG, &msglvl_wanted, NULL,
+	  NETIF_MSG_WOL, &msglvl_unwanted },
+};
+
 static long long
 get_int_range(char *str, int base, long long min, long long max)
 {
@@ -920,7 +977,20 @@ static void parse_cmdline(int argc, char **argp)
 				i++;
 				if (i >= argc)
 					show_usage(1);
-				msglvl_wanted = get_int(argp[i], 0);
+				if (isdigit((unsigned char)argp[i][0])) {
+					msglvl_changed = 1;
+					msglvl_unwanted = ~0;
+					msglvl_wanted =
+						get_uint_range(argp[i], 0,
+							       0xffffffff);
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
@@ -2247,8 +2317,12 @@ static int do_gset(int fd, struct ifreq *ifr)
 	ifr->ifr_data = (caddr_t)&edata;
 	err = send_ioctl(fd, ifr);
 	if (err == 0) {
-		fprintf(stdout, "	Current message level: 0x%08x (%d)\n",
+		fprintf(stdout, "	Current message level: 0x%08x (%d)\n"
+			"			       ",
 			edata.data, edata.data);
+		print_flags(cmdline_msglvl, ARRAY_SIZE(cmdline_msglvl),
+			    edata.data);
+		fprintf(stdout, "\n");
 		allfail = 0;
 	} else if (errno != EOPNOTSUPP) {
 		perror("Cannot get message level");
@@ -2371,15 +2445,23 @@ static int do_sset(int fd, struct ifreq *ifr)
 		}
 	}
 
-	if (msglvl_wanted != -1) {
+	if (msglvl_changed) {
 		struct ethtool_value edata;
 
-		edata.cmd = ETHTOOL_SMSGLVL;
-		edata.data = msglvl_wanted;
-		ifr->ifr_data = (caddr_t)&edata;;
+		edata.cmd = ETHTOOL_GMSGLVL;
+		ifr->ifr_data = (caddr_t)&edata;
 		err = send_ioctl(fd, ifr);
-		if (err < 0)
-			perror("Cannot set new msglvl");
+		if (err < 0) {
+			perror("Cannot get msglvl");
+		} else {
+			edata.cmd = ETHTOOL_SMSGLVL;
+			edata.data = ((edata.data & ~msglvl_unwanted) |
+				      msglvl_wanted);
+			ifr->ifr_data = (caddr_t)&edata;
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

