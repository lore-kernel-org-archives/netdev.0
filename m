From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 13/21] Support arbitrary numbers of option names
 for each mode
Date: Tue, 1 Nov 2011 23:18:40 +0000
Message-ID: <1320189520.2758.43.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38369 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086Ab1KAXSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:18:44 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of supporting a single short and long option for each
mode, take a string of options separated by "|" (matching the
way they are displayed in online help).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |  110 ++++++++++++++++++++++++++++++++-----------------------------
 1 files changed, 58 insertions(+), 52 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 4eff916..9d416e1 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -105,13 +105,13 @@ static int do_getfwdump(struct cmd_context *ctx);
 static int do_setfwdump(struct cmd_context *ctx);
 
 static struct option {
-	char *srt, *lng;
+	const char *opts;
 	int want_device;
 	int (*func)(struct cmd_context *);
 	char *help;
 	char *opthelp;
 } args[] = {
-	{ "-s", "--change", 1, do_sset, "Change generic options",
+	{ "-s|--change", 1, do_sset, "Change generic options",
 	  "		[ speed %d ]\n"
 	  "		[ duplex half|full ]\n"
 	  "		[ port tp|aui|bnc|mii|fibre ]\n"
@@ -122,13 +122,13 @@ static struct option {
 	  "		[ wol p|u|m|b|a|g|s|d... ]\n"
 	  "		[ sopass %x:%x:%x:%x:%x:%x ]\n"
 	  "		[ msglvl %d | msglvl type on|off ... ]\n" },
-	{ "-a", "--show-pause", 1, do_gpause, "Show pause options" },
-	{ "-A", "--pause", 1, do_spause, "Set pause options",
+	{ "-a|--show-pause", 1, do_gpause, "Show pause options" },
+	{ "-A|--pause", 1, do_spause, "Set pause options",
 	  "		[ autoneg on|off ]\n"
 	  "		[ rx on|off ]\n"
 	  "		[ tx on|off ]\n" },
-	{ "-c", "--show-coalesce", 1, do_gcoalesce, "Show coalesce options" },
-	{ "-C", "--coalesce", 1, do_scoalesce, "Set coalesce options",
+	{ "-c|--show-coalesce", 1, do_gcoalesce, "Show coalesce options" },
+	{ "-C|--coalesce", 1, do_scoalesce, "Set coalesce options",
 	  "		[adaptive-rx on|off]\n"
 	  "		[adaptive-tx on|off]\n"
 	  "		[rx-usecs N]\n"
@@ -151,15 +151,15 @@ static struct option {
 	  "		[tx-usecs-high N]\n"
 	  "		[tx-frames-high N]\n"
 	  "		[sample-interval N]\n" },
-	{ "-g", "--show-ring", 1, do_gring, "Query RX/TX ring parameters" },
-	{ "-G", "--set-ring", 1, do_sring, "Set RX/TX ring parameters",
+	{ "-g|--show-ring", 1, do_gring, "Query RX/TX ring parameters" },
+	{ "-G|--set-ring", 1, do_sring, "Set RX/TX ring parameters",
 	  "		[ rx N ]\n"
 	  "		[ rx-mini N ]\n"
 	  "		[ rx-jumbo N ]\n"
 	  "		[ tx N ]\n" },
-	{ "-k", "--show-offload", 1, do_goffload,
+	{ "-k|--show-offload", 1, do_goffload,
 	  "Get protocol offload information" },
-	{ "-K", "--offload", 1, do_soffload, "Set protocol offload",
+	{ "-K|--offload", 1, do_soffload, "Set protocol offload",
 	  "		[ rx on|off ]\n"
 	  "		[ tx on|off ]\n"
 	  "		[ sg on|off ]\n"
@@ -173,44 +173,44 @@ static struct option {
 	  "		[ ntuple on|off ]\n"
 	  "		[ rxhash on|off ]\n"
 	},
-	{ "-i", "--driver", 1, do_gdrv, "Show driver information" },
-	{ "-d", "--register-dump", 1, do_gregs, "Do a register dump",
+	{ "-i|--driver", 1, do_gdrv, "Show driver information" },
+	{ "-d|--register-dump", 1, do_gregs, "Do a register dump",
 	  "		[ raw on|off ]\n"
 	  "		[ file FILENAME ]\n" },
-	{ "-e", "--eeprom-dump", 1, do_geeprom, "Do a EEPROM dump",
+	{ "-e|--eeprom-dump", 1, do_geeprom, "Do a EEPROM dump",
 	  "		[ raw on|off ]\n"
 	  "		[ offset N ]\n"
 	  "		[ length N ]\n" },
-	{ "-E", "--change-eeprom", 1, do_seeprom,
+	{ "-E|--change-eeprom", 1, do_seeprom,
 	  "Change bytes in device EEPROM",
 	  "		[ magic N ]\n"
 	  "		[ offset N ]\n"
 	  "		[ length N ]\n"
 	  "		[ value N ]\n" },
-	{ "-r", "--negotiate", 1, do_nway_rst, "Restart N-WAY negotiation" },
-	{ "-p", "--identify", 1, do_phys_id,
+	{ "-r|--negotiate", 1, do_nway_rst, "Restart N-WAY negotiation" },
+	{ "-p|--identify", 1, do_phys_id,
 	  "Show visible port identification (e.g. blinking)",
 	  "               [ TIME-IN-SECONDS ]\n" },
-	{ "-t", "--test", 1, do_test, "Execute adapter self test",
+	{ "-t|--test", 1, do_test, "Execute adapter self test",
 	  "               [ online | offline | external_lb ]\n" },
-	{ "-S", "--statistics", 1, do_gstats, "Show adapter statistics" },
-	{ "-n", "--show-nfc", 1, do_grxclass,
+	{ "-S|--statistics", 1, do_gstats, "Show adapter statistics" },
+	{ "-n|--show-nfc", 1, do_grxclass,
 	  "Show Rx network flow classification options",
 	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
 	  "tcp6|udp6|ah6|esp6|sctp6 ]\n" },
-	{ "-f", "--flash", 1, do_flash,
+	{ "-f|--flash", 1, do_flash,
 	  "Flash firmware image from the specified file to a region on the device",
 	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-	{ "-N", "--config-nfc", 1, do_srxclass,
+	{ "-N|--config-nfc", 1, do_srxclass,
 	  "Configure Rx network flow classification options",
 	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
 	  "tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
-	{ "-x", "--show-rxfh-indir", 1, do_grxfhindir,
+	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
 	  "Show Rx flow hash indirection" },
-	{ "-X", "--set-rxfh-indir", 1, do_srxfhindir,
+	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
 	  "Set Rx flow hash indirection",
 	  "		equal N | weight W0 W1 ...\n" },
-	{ "-U", "--config-ntuple", 1, do_srxclsrule,
+	{ "-U|--config-ntuple", 1, do_srxclsrule,
 	  "Configure Rx ntuple filters and actions",
 	  "		[ delete %d ] |\n"
 	  "		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
@@ -229,25 +229,25 @@ static struct option {
 	  "			[ user-def %x [m %x] ]\n"
 	  "			[ action %d ]\n"
 	  "			[ loc %d]]\n" },
-	{ "-u", "--show-ntuple", 1, do_grxclsrule,
+	{ "-u|--show-ntuple", 1, do_grxclsrule,
 	  "Get Rx ntuple filters and actions",
 	  "		[ rule %d ]\n"},
-	{ "-P", "--show-permaddr", 1, do_permaddr,
+	{ "-P|--show-permaddr", 1, do_permaddr,
 	  "Show permanent hardware address" },
-	{ "-w", "--get-dump", 1, do_getfwdump,
+	{ "-w|--get-dump", 1, do_getfwdump,
 	  "Get dump flag, data",
 	  "		[ data FILENAME ]\n" },
-	{ "-W", "--set-dump", 1, do_setfwdump,
+	{ "-W|--set-dump", 1, do_setfwdump,
 	  "Set dump flag of the device",
 	  "		N\n"},
-	{ "-l", "--show-channels", 1, do_gchannels, "Query Channels" },
-	{ "-L", "--set-channels", 1, do_schannels, "Set Channels",
+	{ "-l|--show-channels", 1, do_gchannels, "Query Channels" },
+	{ "-L|--set-channels", 1, do_schannels, "Set Channels",
 	  "               [ rx N ]\n"
 	  "               [ tx N ]\n"
 	  "               [ other N ]\n"
 	  "               [ combined N ]\n" },
-	{ "-h", "--help", 0, show_usage, "Show this help" },
-	{ NULL, "--version", 0, do_version, "Show version number" },
+	{ "-h|--help", 0, show_usage, "Show this help" },
+	{ "--version", 0, do_version, "Show version number" },
 	{}
 };
 
@@ -272,12 +272,10 @@ static int show_usage(struct cmd_context *ctx)
 		"Usage:\n"
 		"        ethtool DEVNAME\t"
 		"Display standard information about device\n");
-	for (i = 0; args[i].lng; i++) {
+	for (i = 0; args[i].opts; i++) {
 		fputs("        ethtool ", stdout);
-		if (args[i].srt)
-			fprintf(stdout, "%s|", args[i].srt);
 		fprintf(stdout, "%s %s\t%s\n",
-			args[i].lng,
+			args[i].opts,
 			args[i].want_device ? "DEVNAME" : "\t",
 			args[i].help);
 		if (args[i].opthelp)
@@ -3174,8 +3172,8 @@ int send_ioctl(struct cmd_context *ctx, void *cmd)
 
 int main(int argc, char **argp, char **envp)
 {
-	int (*func)(struct cmd_context *) = NULL;
-	int want_device = 0;
+	int (*func)(struct cmd_context *);
+	int want_device;
 	struct cmd_context ctx;
 	int k;
 
@@ -3189,23 +3187,31 @@ int main(int argc, char **argp, char **envp)
 	 */
 	if (argc == 0)
 		exit_bad_args();
-	for (k = 0; args[k].lng; k++) {
-		if ((args[k].srt && !strcmp(*argp, args[k].srt)) ||
-		    !strcmp(*argp, args[k].lng)) {
-			argp++;
-			argc--;
-			func = args[k].func;
-			want_device = args[k].want_device;
-			break;
+	for (k = 0; args[k].opts; k++) {
+		const char *opt;
+		size_t len;
+		opt = args[k].opts;
+		for (;;) {
+			len = strcspn(opt, "|");
+			if (strncmp(*argp, opt, len) == 0 &&
+			    (*argp)[len] == 0) {
+				argp++;
+				argc--;
+				func = args[k].func;
+				want_device = args[k].want_device;
+				goto opt_found;
+			}
+			if (opt[len] == 0)
+				break;
+			opt += len + 1;
 		}
 	}
-	if (!func) {
-		if ((*argp)[0] == '-')
-			exit_bad_args();
-		func = do_gset;
-		want_device = 1;
-	}
+	if ((*argp)[0] == '-')
+		exit_bad_args();
+	func = do_gset;
+	want_device = 1;
 
+opt_found:
 	if (want_device) {
 		devname = *argp++;
 		argc--;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
