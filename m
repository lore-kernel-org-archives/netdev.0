From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/7] ethtool: Generalise cmdline_info::unwanted_val
 to a "seen" flag or bitmask
Date: Thu, 23 Sep 2010 22:48:14 +0100
Message-ID: <1285278494.7794.29.camel@achroite.uk.solarflarecom.com>
References: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54559 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754969Ab0IWVsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:48:17 -0400
In-Reply-To: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   68 +++++++++++++++++++++++++++++++++---------------------------
 1 files changed, 37 insertions(+), 31 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 6b2b7c8..8c5d595 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -290,7 +290,7 @@ static int off_tso_wanted = -1;
 static int off_ufo_wanted = -1;
 static int off_gso_wanted = -1;
 static u32 off_flags_wanted = 0;
-static u32 off_flags_unwanted = 0;
+static u32 off_flags_mask = 0;
 static int off_gro_wanted = -1;
 
 static struct ethtool_pauseparam epause;
@@ -372,7 +372,7 @@ static int flash_region = -1;
 
 static int msglvl_changed;
 static u32 msglvl_wanted = 0;
-static u32 msglvl_unwanted =0;
+static u32 msglvl_mask = 0;
 
 static enum {
 	ONLINE=0,
@@ -402,8 +402,10 @@ struct cmdline_info {
 	void *ioctl_val;
 	/* For FLAG, the flag value to be set/cleared */
 	u32 flag_val;
-	/* For FLAG, accumulates all flags to be cleared */
-	u32 *unwanted_val;
+	/* For FLAG, points to u32 and accumulates all flags seen.
+	 * For anything else, points to int and is set if the option is
+	 * seen. */
+	void *seen_val;
 };
 
 static struct cmdline_info cmdline_gregs[] = {
@@ -433,12 +435,12 @@ static struct cmdline_info cmdline_offload[] = {
 	{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
 	{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
 	{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_LRO, &off_flags_unwanted },
+	  ETH_FLAG_LRO, &off_flags_mask },
 	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
 	{ "ntuple", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_NTUPLE, &off_flags_unwanted },
+	  ETH_FLAG_NTUPLE, &off_flags_mask },
 	{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_RXHASH, &off_flags_unwanted },
+	  ETH_FLAG_RXHASH, &off_flags_mask },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -497,35 +499,35 @@ static struct cmdline_info cmdline_ntuple[] = {
 
 static struct cmdline_info cmdline_msglvl[] = {
 	{ "drv", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_DRV, &msglvl_unwanted },
+	  NETIF_MSG_DRV, &msglvl_mask },
 	{ "probe", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_PROBE, &msglvl_unwanted },
+	  NETIF_MSG_PROBE, &msglvl_mask },
 	{ "link", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_LINK, &msglvl_unwanted },
+	  NETIF_MSG_LINK, &msglvl_mask },
 	{ "timer", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TIMER, &msglvl_unwanted },
+	  NETIF_MSG_TIMER, &msglvl_mask },
 	{ "ifdown", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_IFDOWN, &msglvl_unwanted },
+	  NETIF_MSG_IFDOWN, &msglvl_mask },
 	{ "ifup", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_IFUP, &msglvl_unwanted },
+	  NETIF_MSG_IFUP, &msglvl_mask },
 	{ "rx_err", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_RX_ERR, &msglvl_unwanted },
+	  NETIF_MSG_RX_ERR, &msglvl_mask },
 	{ "tx_err", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TX_ERR, &msglvl_unwanted },
+	  NETIF_MSG_TX_ERR, &msglvl_mask },
 	{ "tx_queued", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TX_QUEUED, &msglvl_unwanted },
+	  NETIF_MSG_TX_QUEUED, &msglvl_mask },
 	{ "intr", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_INTR, &msglvl_unwanted },
+	  NETIF_MSG_INTR, &msglvl_mask },
 	{ "tx_done", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TX_DONE, &msglvl_unwanted },
+	  NETIF_MSG_TX_DONE, &msglvl_mask },
 	{ "rx_status", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_RX_STATUS, &msglvl_unwanted },
+	  NETIF_MSG_RX_STATUS, &msglvl_mask },
 	{ "pktdata", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_PKTDATA, &msglvl_unwanted },
+	  NETIF_MSG_PKTDATA, &msglvl_mask },
 	{ "hw", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_HW, &msglvl_unwanted },
+	  NETIF_MSG_HW, &msglvl_mask },
 	{ "wol", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_WOL, &msglvl_unwanted },
+	  NETIF_MSG_WOL, &msglvl_mask },
 };
 
 static long long
@@ -582,6 +584,9 @@ static void parse_generic_cmdline(int argc, char **argp,
 			if (!strcmp(info[idx].name, argp[i])) {
 				found = 1;
 				*changed = 1;
+				if (info[idx].type != CMDL_FLAG &&
+				    info[idx].seen_val)
+					*(int *)info[idx].seen_val = 1;
 				i += 1;
 				if (i >= argc)
 					show_usage(1);
@@ -638,13 +643,14 @@ static void parse_generic_cmdline(int argc, char **argp,
 				}
 				case CMDL_FLAG: {
 					u32 *p;
-					if (!strcmp(argp[i], "on"))
+					p = info[idx].seen_val;
+					*p |= info[idx].flag_val;
+					if (!strcmp(argp[i], "on")) {
 						p = info[idx].wanted_val;
-					else if (!strcmp(argp[i], "off"))
-						p = info[idx].unwanted_val;
-					else
+						*p |= info[idx].flag_val;
+					} else if (strcmp(argp[i], "off")) {
 						show_usage(1);
-					*p |= info[idx].flag_val;
+					}
 					break;
 				}
 				case CMDL_STR: {
@@ -1027,7 +1033,7 @@ static void parse_cmdline(int argc, char **argp)
 					show_usage(1);
 				if (isdigit((unsigned char)argp[i][0])) {
 					msglvl_changed = 1;
-					msglvl_unwanted = ~0;
+					msglvl_mask = ~0;
 					msglvl_wanted =
 						get_uint_range(argp[i], 0,
 							       0xffffffff);
@@ -2243,7 +2249,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 			return 90;
 		}
 	}
-	if (off_flags_wanted || off_flags_unwanted) {
+	if (off_flags_mask) {
 		changed = 1;
 		eval.cmd = ETHTOOL_GFLAGS;
 		eval.data = 0;
@@ -2255,7 +2261,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		}
 
 		eval.cmd = ETHTOOL_SFLAGS;
-		eval.data = ((eval.data & ~off_flags_unwanted) |
+		eval.data = ((eval.data & ~off_flags_mask) |
 			     off_flags_wanted);
 
 		err = ioctl(fd, SIOCETHTOOL, ifr);
@@ -2459,7 +2465,7 @@ static int do_sset(int fd, struct ifreq *ifr)
 			perror("Cannot get msglvl");
 		} else {
 			edata.cmd = ETHTOOL_SMSGLVL;
-			edata.data = ((edata.data & ~msglvl_unwanted) |
+			edata.data = ((edata.data & ~msglvl_mask) |
 				      msglvl_wanted);
 			ifr->ifr_data = (caddr_t)&edata;
 			err = send_ioctl(fd, ifr);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

