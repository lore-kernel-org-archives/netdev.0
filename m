From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 12/21] Move argument parsing to sub-command
 functions
Date: Tue, 1 Nov 2011 23:18:20 +0000
Message-ID: <1320189500.2758.42.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38345 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553Ab1KAXSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:18:24 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of doing most of the argument parsing in parse_cmdline(),
find the sub-command and (if required) the device name in main()
and do the rest in the sub-command handler function.  Pass argc
and argp around in struct cmd_context.

This also tightens up argument parsing slightly: extraneous or missing
arguments will now result in an error in a few cases where they were
previously ignored.  All test cases now pass.

Replace sub-command dispatch in doit() with a function pointer
in struct option.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in |    4 +-
 ethtool.c    |  988 +++++++++++++++++++++++-----------------------------------
 internal.h   |    4 +-
 rxclass.c    |    4 +-
 4 files changed, 390 insertions(+), 610 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 3304fe5..7c39629 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -252,11 +252,11 @@ ethtool \- query or control network driver and hardware settings
 .HP
 .B ethtool \-n
 .I devname
-.RB [ rx\-flow\-hash \ \*(FL]
+.BR rx\-flow\-hash \ \*(FL
 .HP
 .B ethtool \-N
 .I devname
-.RB [ rx\-flow\-hash \ \*(FL \: \*(HO]
+.BR rx\-flow\-hash \ \*(FL \: \*(HO
 .HP
 .B ethtool \-w|\-\-get\-dump
 .I devname
diff --git a/ethtool.c b/ethtool.c
index 7a26043..4eff916 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -64,6 +64,8 @@ enum {
 };
 #endif
 
+static int show_usage(struct cmd_context *ctx);
+static int do_version(struct cmd_context *ctx);
 static int parse_wolopts(char *optstr, u32 *data);
 static char *unparse_wolopts(int wolopts);
 static void get_mac_addr(char *src, unsigned char *dest);
@@ -102,48 +104,14 @@ static int do_permaddr(struct cmd_context *ctx);
 static int do_getfwdump(struct cmd_context *ctx);
 static int do_setfwdump(struct cmd_context *ctx);
 
-static enum {
-	MODE_VERSION = -2,
-	MODE_HELP = -1,
-	MODE_GSET=0,
-	MODE_SSET,
-	MODE_GDRV,
-	MODE_GREGS,
-	MODE_NWAY_RST,
-	MODE_GEEPROM,
-	MODE_SEEPROM,
-	MODE_TEST,
-	MODE_PHYS_ID,
-	MODE_GPAUSE,
-	MODE_SPAUSE,
-	MODE_GCOALESCE,
-	MODE_SCOALESCE,
-	MODE_GRING,
-	MODE_SRING,
-	MODE_GOFFLOAD,
-	MODE_SOFFLOAD,
-	MODE_GSTATS,
-	MODE_GNFC,
-	MODE_SNFC,
-	MODE_GRXFHINDIR,
-	MODE_SRXFHINDIR,
-	MODE_SCLSRULE,
-	MODE_GCLSRULE,
-	MODE_FLASHDEV,
-	MODE_PERMADDR,
-	MODE_SET_DUMP,
-	MODE_GET_DUMP,
-	MODE_GCHANNELS,
-	MODE_SCHANNELS
-} mode = MODE_GSET;
-
 static struct option {
 	char *srt, *lng;
-	int Mode;
+	int want_device;
+	int (*func)(struct cmd_context *);
 	char *help;
 	char *opthelp;
 } args[] = {
-	{ "-s", "--change", MODE_SSET, "Change generic options",
+	{ "-s", "--change", 1, do_sset, "Change generic options",
 	  "		[ speed %d ]\n"
 	  "		[ duplex half|full ]\n"
 	  "		[ port tp|aui|bnc|mii|fibre ]\n"
@@ -154,13 +122,13 @@ static struct option {
 	  "		[ wol p|u|m|b|a|g|s|d... ]\n"
 	  "		[ sopass %x:%x:%x:%x:%x:%x ]\n"
 	  "		[ msglvl %d | msglvl type on|off ... ]\n" },
-	{ "-a", "--show-pause", MODE_GPAUSE, "Show pause options" },
-	{ "-A", "--pause", MODE_SPAUSE, "Set pause options",
+	{ "-a", "--show-pause", 1, do_gpause, "Show pause options" },
+	{ "-A", "--pause", 1, do_spause, "Set pause options",
 	  "		[ autoneg on|off ]\n"
 	  "		[ rx on|off ]\n"
 	  "		[ tx on|off ]\n" },
-	{ "-c", "--show-coalesce", MODE_GCOALESCE, "Show coalesce options" },
-	{ "-C", "--coalesce", MODE_SCOALESCE, "Set coalesce options",
+	{ "-c", "--show-coalesce", 1, do_gcoalesce, "Show coalesce options" },
+	{ "-C", "--coalesce", 1, do_scoalesce, "Set coalesce options",
 	  "		[adaptive-rx on|off]\n"
 	  "		[adaptive-tx on|off]\n"
 	  "		[rx-usecs N]\n"
@@ -183,15 +151,15 @@ static struct option {
 	  "		[tx-usecs-high N]\n"
 	  "		[tx-frames-high N]\n"
 	  "		[sample-interval N]\n" },
-	{ "-g", "--show-ring", MODE_GRING, "Query RX/TX ring parameters" },
-	{ "-G", "--set-ring", MODE_SRING, "Set RX/TX ring parameters",
+	{ "-g", "--show-ring", 1, do_gring, "Query RX/TX ring parameters" },
+	{ "-G", "--set-ring", 1, do_sring, "Set RX/TX ring parameters",
 	  "		[ rx N ]\n"
 	  "		[ rx-mini N ]\n"
 	  "		[ rx-jumbo N ]\n"
 	  "		[ tx N ]\n" },
-	{ "-k", "--show-offload", MODE_GOFFLOAD,
+	{ "-k", "--show-offload", 1, do_goffload,
 	  "Get protocol offload information" },
-	{ "-K", "--offload", MODE_SOFFLOAD, "Set protocol offload",
+	{ "-K", "--offload", 1, do_soffload, "Set protocol offload",
 	  "		[ rx on|off ]\n"
 	  "		[ tx on|off ]\n"
 	  "		[ sg on|off ]\n"
@@ -205,44 +173,44 @@ static struct option {
 	  "		[ ntuple on|off ]\n"
 	  "		[ rxhash on|off ]\n"
 	},
-	{ "-i", "--driver", MODE_GDRV, "Show driver information" },
-	{ "-d", "--register-dump", MODE_GREGS, "Do a register dump",
+	{ "-i", "--driver", 1, do_gdrv, "Show driver information" },
+	{ "-d", "--register-dump", 1, do_gregs, "Do a register dump",
 	  "		[ raw on|off ]\n"
 	  "		[ file FILENAME ]\n" },
-	{ "-e", "--eeprom-dump", MODE_GEEPROM, "Do a EEPROM dump",
+	{ "-e", "--eeprom-dump", 1, do_geeprom, "Do a EEPROM dump",
 	  "		[ raw on|off ]\n"
 	  "		[ offset N ]\n"
 	  "		[ length N ]\n" },
-	{ "-E", "--change-eeprom", MODE_SEEPROM,
+	{ "-E", "--change-eeprom", 1, do_seeprom,
 	  "Change bytes in device EEPROM",
 	  "		[ magic N ]\n"
 	  "		[ offset N ]\n"
 	  "		[ length N ]\n"
 	  "		[ value N ]\n" },
-	{ "-r", "--negotiate", MODE_NWAY_RST, "Restart N-WAY negotiation" },
-	{ "-p", "--identify", MODE_PHYS_ID,
+	{ "-r", "--negotiate", 1, do_nway_rst, "Restart N-WAY negotiation" },
+	{ "-p", "--identify", 1, do_phys_id,
 	  "Show visible port identification (e.g. blinking)",
 	  "               [ TIME-IN-SECONDS ]\n" },
-	{ "-t", "--test", MODE_TEST, "Execute adapter self test",
+	{ "-t", "--test", 1, do_test, "Execute adapter self test",
 	  "               [ online | offline | external_lb ]\n" },
-	{ "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
-	{ "-n", "--show-nfc", MODE_GNFC,
+	{ "-S", "--statistics", 1, do_gstats, "Show adapter statistics" },
+	{ "-n", "--show-nfc", 1, do_grxclass,
 	  "Show Rx network flow classification options",
 	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
 	  "tcp6|udp6|ah6|esp6|sctp6 ]\n" },
-	{ "-f", "--flash", MODE_FLASHDEV,
+	{ "-f", "--flash", 1, do_flash,
 	  "Flash firmware image from the specified file to a region on the device",
 	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-	{ "-N", "--config-nfc", MODE_SNFC,
+	{ "-N", "--config-nfc", 1, do_srxclass,
 	  "Configure Rx network flow classification options",
 	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
 	  "tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
-	{ "-x", "--show-rxfh-indir", MODE_GRXFHINDIR,
+	{ "-x", "--show-rxfh-indir", 1, do_grxfhindir,
 	  "Show Rx flow hash indirection" },
-	{ "-X", "--set-rxfh-indir", MODE_SRXFHINDIR,
+	{ "-X", "--set-rxfh-indir", 1, do_srxfhindir,
 	  "Set Rx flow hash indirection",
 	  "		equal N | weight W0 W1 ...\n" },
-	{ "-U", "--config-ntuple", MODE_SCLSRULE,
+	{ "-U", "--config-ntuple", 1, do_srxclsrule,
 	  "Configure Rx ntuple filters and actions",
 	  "		[ delete %d ] |\n"
 	  "		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
@@ -261,25 +229,25 @@ static struct option {
 	  "			[ user-def %x [m %x] ]\n"
 	  "			[ action %d ]\n"
 	  "			[ loc %d]]\n" },
-	{ "-u", "--show-ntuple", MODE_GCLSRULE,
+	{ "-u", "--show-ntuple", 1, do_grxclsrule,
 	  "Get Rx ntuple filters and actions",
 	  "		[ rule %d ]\n"},
-	{ "-P", "--show-permaddr", MODE_PERMADDR,
+	{ "-P", "--show-permaddr", 1, do_permaddr,
 	  "Show permanent hardware address" },
-	{ "-w", "--get-dump", MODE_GET_DUMP,
+	{ "-w", "--get-dump", 1, do_getfwdump,
 	  "Get dump flag, data",
 	  "		[ data FILENAME ]\n" },
-	{ "-W", "--set-dump", MODE_SET_DUMP,
+	{ "-W", "--set-dump", 1, do_setfwdump,
 	  "Set dump flag of the device",
 	  "		N\n"},
-	{ "-l", "--show-channels", MODE_GCHANNELS, "Query Channels" },
-	{ "-L", "--set-channels", MODE_SCHANNELS, "Set Channels",
+	{ "-l", "--show-channels", 1, do_gchannels, "Query Channels" },
+	{ "-L", "--set-channels", 1, do_schannels, "Set Channels",
 	  "               [ rx N ]\n"
 	  "               [ tx N ]\n"
 	  "               [ other N ]\n"
 	  "               [ combined N ]\n" },
-	{ "-h", "--help", MODE_HELP, "Show this help" },
-	{ NULL, "--version", MODE_VERSION, "Show version number" },
+	{ "-h", "--help", 0, show_usage, "Show this help" },
+	{ NULL, "--version", 0, do_version, "Show version number" },
 	{}
 };
 
@@ -294,7 +262,7 @@ static void exit_bad_args(void)
 	exit(1);
 }
 
-static void show_usage(void)
+static int show_usage(struct cmd_context *ctx)
 {
 	int i;
 
@@ -310,11 +278,13 @@ static void show_usage(void)
 			fprintf(stdout, "%s|", args[i].srt);
 		fprintf(stdout, "%s %s\t%s\n",
 			args[i].lng,
-			args[i].Mode < 0 ? "\t" : "DEVNAME",
+			args[i].want_device ? "DEVNAME" : "\t",
 			args[i].help);
 		if (args[i].opthelp)
 			fputs(args[i].opthelp, stdout);
 	}
+
+	return 0;
 }
 
 static char *devname = NULL;
@@ -406,11 +376,9 @@ static int seeprom_value_seen = 0;
 static int rx_fhash_get = 0;
 static int rx_fhash_set = 0;
 static u32 rx_fhash_val = 0;
-static int rx_fhash_changed = 0;
 static int rxfhindir_equal = 0;
 static char **rxfhindir_weight = NULL;
 static char *flash_file = NULL;
-static int flash = -1;
 static int flash_region = -1;
 
 static int msglvl_changed;
@@ -421,7 +389,6 @@ static char *dump_file = NULL;
 
 static int rx_class_rule_get = -1;
 static int rx_class_rule_del = -1;
-static int rx_class_rule_added = 0;
 static struct ethtool_rx_flow_spec rx_rule_fs;
 
 static enum {
@@ -619,15 +586,17 @@ static u32 get_u32(char *str, int base)
 	return get_uint_range(str, base, 0xffffffff);
 }
 
-static void parse_generic_cmdline(int argc, char **argp,
-				  int first_arg, int *changed,
+static void parse_generic_cmdline(struct cmd_context *ctx,
+				  int *changed,
 				  struct cmdline_info *info,
 				  unsigned int n_info)
 {
+	int argc = ctx->argc;
+	char **argp = ctx->argp;
 	int i, idx;
 	int found;
 
-	for (i = first_arg; i < argc; i++) {
+	for (i = 0; i < argc; i++) {
 		found = 0;
 		for (idx = 0; idx < n_info; idx++) {
 			if (!strcmp(info[idx].name, argp[i])) {
@@ -773,443 +742,11 @@ static int rxflow_str_to_type(const char *str)
 	return flow_type;
 }
 
-static void parse_cmdline(int argc, char **argp)
+static int do_version(struct cmd_context *ctx)
 {
-	int i, k;
-
-	for (i = 1; i < argc; i++) {
-		switch (i) {
-		case 1:
-			for (k = 0; args[k].lng; k++)
-				if ((args[k].srt &&
-				     !strcmp(argp[i], args[k].srt)) ||
-				    !strcmp(argp[i], args[k].lng)) {
-					mode = args[k].Mode;
-					break;
-				}
-			if (mode == MODE_HELP) {
-				show_usage();
-				exit(0);
-			} else if (mode == MODE_VERSION) {
-				fprintf(stdout,
-					PACKAGE " version " VERSION "\n");
-				exit(0);
-			} else if (!args[k].lng && argp[i][0] == '-') {
-				exit_bad_args();
-			} else {
-				devname = argp[i];
-			}
-			break;
-		case 2:
-			if ((mode == MODE_SSET) ||
-			    (mode == MODE_GDRV) ||
-			    (mode == MODE_GREGS)||
-			    (mode == MODE_NWAY_RST) ||
-			    (mode == MODE_TEST) ||
-			    (mode == MODE_GEEPROM) ||
-			    (mode == MODE_SEEPROM) ||
-			    (mode == MODE_GPAUSE) ||
-			    (mode == MODE_SPAUSE) ||
-			    (mode == MODE_GCOALESCE) ||
-			    (mode == MODE_SCOALESCE) ||
-			    (mode == MODE_GRING) ||
-			    (mode == MODE_GCHANNELS) ||
-			    (mode == MODE_SCHANNELS) ||
-			    (mode == MODE_SRING) ||
-			    (mode == MODE_GOFFLOAD) ||
-			    (mode == MODE_SOFFLOAD) ||
-			    (mode == MODE_GSTATS) ||
-			    (mode == MODE_GNFC) ||
-			    (mode == MODE_SNFC) ||
-			    (mode == MODE_GRXFHINDIR) ||
-			    (mode == MODE_SRXFHINDIR) ||
-			    (mode == MODE_SCLSRULE) ||
-			    (mode == MODE_GCLSRULE) ||
-			    (mode == MODE_PHYS_ID) ||
-			    (mode == MODE_FLASHDEV) ||
-			    (mode == MODE_PERMADDR) ||
-			    (mode == MODE_SET_DUMP) ||
-			    (mode == MODE_GET_DUMP)) {
-				devname = argp[i];
-				break;
-			}
-			/* fallthrough */
-		case 3:
-			if (mode == MODE_TEST) {
-				if (!strcmp(argp[i], "online")) {
-					test_type = ONLINE;
-				} else if (!strcmp(argp[i], "offline")) {
-					test_type = OFFLINE;
-				} else if (!strcmp(argp[i], "external_lb")) {
-					test_type = EXTERNAL_LB;
-				} else {
-					exit_bad_args();
-				}
-				break;
-			} else if (mode == MODE_PHYS_ID) {
-				phys_id_time = get_int(argp[i],0);
-				break;
-			} else if (mode == MODE_FLASHDEV) {
-				flash_file = argp[i];
-				flash = 1;
-				break;
-			} else if (mode == MODE_SET_DUMP) {
-				dump_flag = get_u32(argp[i], 0);
-				break;
-			}
-			/* fallthrough */
-		default:
-			if (mode == MODE_GREGS) {
-				parse_generic_cmdline(argc, argp, i,
-					&gregs_changed,
-					cmdline_gregs,
-					ARRAY_SIZE(cmdline_gregs));
-				i = argc;
-				break;
-			}
-			if (mode == MODE_GEEPROM) {
-				parse_generic_cmdline(argc, argp, i,
-					&geeprom_changed,
-					cmdline_geeprom,
-					ARRAY_SIZE(cmdline_geeprom));
-				i = argc;
-				break;
-			}
-			if (mode == MODE_SEEPROM) {
-				parse_generic_cmdline(argc, argp, i,
-					&seeprom_changed,
-					cmdline_seeprom,
-					ARRAY_SIZE(cmdline_seeprom));
-				i = argc;
-				break;
-			}
-			if (mode == MODE_SPAUSE) {
-				parse_generic_cmdline(argc, argp, i,
-					&gpause_changed,
-			      		cmdline_pause,
-			      		ARRAY_SIZE(cmdline_pause));
-				i = argc;
-				break;
-			}
-			if (mode == MODE_SRING) {
-				parse_generic_cmdline(argc, argp, i,
-					&gring_changed,
-			      		cmdline_ring,
-			      		ARRAY_SIZE(cmdline_ring));
-				i = argc;
-				break;
-			}
-			if (mode == MODE_SCHANNELS) {
-				parse_generic_cmdline(argc, argp, i,
-					&gchannels_changed,
-					cmdline_channels,
-					ARRAY_SIZE(cmdline_ring));
-				i = argc;
-				break;
-			}
-			if (mode == MODE_SCOALESCE) {
-				parse_generic_cmdline(argc, argp, i,
-					&gcoalesce_changed,
-			      		cmdline_coalesce,
-			      		ARRAY_SIZE(cmdline_coalesce));
-				i = argc;
-				break;
-			}
-			if (mode == MODE_SOFFLOAD) {
-				parse_generic_cmdline(argc, argp, i,
-					&goffload_changed,
-			      		cmdline_offload,
-			      		ARRAY_SIZE(cmdline_offload));
-				i = argc;
-				break;
-			}
-			if (mode == MODE_SCLSRULE) {
-				if (!strcmp(argp[i], "flow-type")) {
-					i += 1;
-					if (i >= argc) {
-						exit_bad_args();
-						break;
-					}
-					if (rxclass_parse_ruleopts(&argp[i],
-							argc - i,
-							&rx_rule_fs) < 0) {
-						exit_bad_args();
-					} else {
-						i = argc;
-						rx_class_rule_added = 1;
-					}
-				} else if (!strcmp(argp[i], "delete")) {
-					i += 1;
-					if (i >= argc) {
-						exit_bad_args();
-						break;
-					}
-					rx_class_rule_del =
-						get_uint_range(argp[i], 0,
-							       INT_MAX);
-				} else {
-					exit_bad_args();
-				}
-				break;
-			}
-			if (mode == MODE_GCLSRULE) {
-				if (!strcmp(argp[i], "rule")) {
-					i += 1;
-					if (i >= argc) {
-						exit_bad_args();
-						break;
-					}
-					rx_class_rule_get =
-						get_uint_range(argp[i], 0,
-							       INT_MAX);
-				} else {
-					exit_bad_args();
-				}
-				break;
-			}
-			if (mode == MODE_GNFC) {
-				if (!strcmp(argp[i], "rx-flow-hash")) {
-					i += 1;
-					if (i >= argc) {
-						exit_bad_args();
-						break;
-					}
-					rx_fhash_get =
-						rxflow_str_to_type(argp[i]);
-					if (!rx_fhash_get)
-						exit_bad_args();
-				} else
-					exit_bad_args();
-				break;
-			}
-			if (mode == MODE_FLASHDEV) {
-				flash_region = strtol(argp[i], NULL, 0);
-				if ((flash_region < 0))
-					exit_bad_args();
-				break;
-			}
-			if (mode == MODE_SNFC) {
-				if (!strcmp(argp[i], "rx-flow-hash")) {
-					i += 1;
-					if (i >= argc) {
-						exit_bad_args();
-						break;
-					}
-					rx_fhash_set =
-						rxflow_str_to_type(argp[i]);
-					if (!rx_fhash_set) {
-						exit_bad_args();
-						break;
-					}
-					i += 1;
-					if (i >= argc) {
-						exit_bad_args();
-						break;
-					}
-					if (parse_rxfhashopts(argp[i],
-						&rx_fhash_val) < 0)
-						exit_bad_args();
-					else
-						rx_fhash_changed = 1;
-				} else
-					exit_bad_args();
-				break;
-			}
-			if (mode == MODE_SRXFHINDIR) {
-				if (!strcmp(argp[i], "equal")) {
-					if (argc != i + 2) {
-						exit_bad_args();
-						break;
-					}
-					i += 1;
-					rxfhindir_equal =
-						get_int_range(argp[i], 0, 1,
-							      INT_MAX);
-					i += 1;
-				} else if (!strcmp(argp[i], "weight")) {
-					i += 1;
-					if (i >= argc) {
-						exit_bad_args();
-						break;
-					}
-					rxfhindir_weight = argp + i;
-					i = argc;
-				} else {
-					exit_bad_args();
-				}
-				break;
-			}
-			if (mode == MODE_GET_DUMP) {
-				if (argc != i + 2) {
-					exit_bad_args();
-					break;
-				}
-				if (!strcmp(argp[i++], "data"))
-					dump_flag = ETHTOOL_GET_DUMP_DATA;
-				else {
-					exit_bad_args();
-					break;
-				}
-				dump_file = argp[i];
-				i = argc;
-				break;
-			}
-			if (mode != MODE_SSET)
-				exit_bad_args();
-			if (!strcmp(argp[i], "speed")) {
-				gset_changed = 1;
-				i += 1;
-				if (i >= argc)
-					exit_bad_args();
-				speed_wanted = get_int(argp[i],10);
-				break;
-			} else if (!strcmp(argp[i], "duplex")) {
-				gset_changed = 1;
-				i += 1;
-				if (i >= argc)
-					exit_bad_args();
-				if (!strcmp(argp[i], "half"))
-					duplex_wanted = DUPLEX_HALF;
-				else if (!strcmp(argp[i], "full"))
-					duplex_wanted = DUPLEX_FULL;
-				else
-					exit_bad_args();
-				break;
-			} else if (!strcmp(argp[i], "port")) {
-				gset_changed = 1;
-				i += 1;
-				if (i >= argc)
-					exit_bad_args();
-				if (!strcmp(argp[i], "tp"))
-					port_wanted = PORT_TP;
-				else if (!strcmp(argp[i], "aui"))
-					port_wanted = PORT_AUI;
-				else if (!strcmp(argp[i], "bnc"))
-					port_wanted = PORT_BNC;
-				else if (!strcmp(argp[i], "mii"))
-					port_wanted = PORT_MII;
-				else if (!strcmp(argp[i], "fibre"))
-					port_wanted = PORT_FIBRE;
-				else
-					exit_bad_args();
-				break;
-			} else if (!strcmp(argp[i], "autoneg")) {
-				i += 1;
-				if (i >= argc)
-					exit_bad_args();
-				if (!strcmp(argp[i], "on")) {
-					gset_changed = 1;
-					autoneg_wanted = AUTONEG_ENABLE;
-				} else if (!strcmp(argp[i], "off")) {
-					gset_changed = 1;
-					autoneg_wanted = AUTONEG_DISABLE;
-				} else {
-					exit_bad_args();
-				}
-				break;
-			} else if (!strcmp(argp[i], "advertise")) {
-				gset_changed = 1;
-				i += 1;
-				if (i >= argc)
-					exit_bad_args();
-				advertising_wanted = get_int(argp[i], 16);
-				break;
-			} else if (!strcmp(argp[i], "phyad")) {
-				gset_changed = 1;
-				i += 1;
-				if (i >= argc)
-					exit_bad_args();
-				phyad_wanted = get_int(argp[i], 0);
-				break;
-			} else if (!strcmp(argp[i], "xcvr")) {
-				gset_changed = 1;
-				i += 1;
-				if (i >= argc)
-					exit_bad_args();
-				if (!strcmp(argp[i], "internal"))
-					xcvr_wanted = XCVR_INTERNAL;
-				else if (!strcmp(argp[i], "external"))
-					xcvr_wanted = XCVR_EXTERNAL;
-				else
-					exit_bad_args();
-				break;
-			} else if (!strcmp(argp[i], "wol")) {
-				gwol_changed = 1;
-				i++;
-				if (i >= argc)
-					exit_bad_args();
-				if (parse_wolopts(argp[i], &wol_wanted) < 0)
-					exit_bad_args();
-				wol_change = 1;
-				break;
-			} else if (!strcmp(argp[i], "sopass")) {
-				gwol_changed = 1;
-				i++;
-				if (i >= argc)
-					exit_bad_args();
-				get_mac_addr(argp[i], sopass_wanted);
-				sopass_change = 1;
-				break;
-			} else if (!strcmp(argp[i], "msglvl")) {
-				i++;
-				if (i >= argc)
-					exit_bad_args();
-				if (isdigit((unsigned char)argp[i][0])) {
-					msglvl_changed = 1;
-					msglvl_mask = ~0;
-					msglvl_wanted =
-						get_uint_range(argp[i], 0,
-							       0xffffffff);
-				} else {
-					parse_generic_cmdline(
-						argc, argp, i,
-						&msglvl_changed,
-						cmdline_msglvl,
-						ARRAY_SIZE(cmdline_msglvl));
-					i = argc;
-				}
-				break;
-			}
-			exit_bad_args();
-		}
-	}
-
-	if (advertising_wanted < 0) {
-		if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
-			advertising_wanted = ADVERTISED_10baseT_Half;
-		else if (speed_wanted == SPEED_10 &&
-			 duplex_wanted == DUPLEX_FULL)
-			advertising_wanted = ADVERTISED_10baseT_Full;
-		else if (speed_wanted == SPEED_100 &&
-			 duplex_wanted == DUPLEX_HALF)
-			advertising_wanted = ADVERTISED_100baseT_Half;
-		else if (speed_wanted == SPEED_100 &&
-			 duplex_wanted == DUPLEX_FULL)
-			advertising_wanted = ADVERTISED_100baseT_Full;
-		else if (speed_wanted == SPEED_1000 &&
-			 duplex_wanted == DUPLEX_HALF)
-			advertising_wanted = ADVERTISED_1000baseT_Half;
-		else if (speed_wanted == SPEED_1000 &&
-			 duplex_wanted == DUPLEX_FULL)
-			advertising_wanted = ADVERTISED_1000baseT_Full;
-		else if (speed_wanted == SPEED_2500 &&
-			 duplex_wanted == DUPLEX_FULL)
-			advertising_wanted = ADVERTISED_2500baseX_Full;
-		else if (speed_wanted == SPEED_10000 &&
-			 duplex_wanted == DUPLEX_FULL)
-			advertising_wanted = ADVERTISED_10000baseT_Full;
-		else
-			/* auto negotiate without forcing,
-			 * all supported speed will be assigned in do_sset()
-			 */
-			advertising_wanted = 0;
-
-	}
-
-	if (devname == NULL)
-		exit_bad_args();
-	if (strlen(devname) >= IFNAMSIZ)
-		exit_bad_args();
+	fprintf(stdout,
+		PACKAGE " version " VERSION "\n");
+	return 0;
 }
 
 static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask);
@@ -1978,92 +1515,14 @@ static int dump_rxfhash(int fhash, u64 val)
 	return 0;
 }
 
-static int doit(void)
-{
-	struct cmd_context ctx;
-
-	/* Setup our control structures. */
-	memset(&ctx.ifr, 0, sizeof(ctx.ifr));
-	strcpy(ctx.ifr.ifr_name, devname);
-
-	/* Open control socket. */
-	ctx.fd = socket(AF_INET, SOCK_DGRAM, 0);
-	if (ctx.fd < 0) {
-		perror("Cannot get control socket");
-		return 70;
-	}
-
-	/* all of these are expected to populate ifr->ifr_data as needed */
-	if (mode == MODE_GDRV) {
-		return do_gdrv(&ctx);
-	} else if (mode == MODE_GSET) {
-		return do_gset(&ctx);
-	} else if (mode == MODE_SSET) {
-		return do_sset(&ctx);
-	} else if (mode == MODE_GREGS) {
-		return do_gregs(&ctx);
-	} else if (mode == MODE_NWAY_RST) {
-		return do_nway_rst(&ctx);
-	} else if (mode == MODE_GEEPROM) {
-		return do_geeprom(&ctx);
-	} else if (mode == MODE_SEEPROM) {
-		return do_seeprom(&ctx);
-	} else if (mode == MODE_TEST) {
-		return do_test(&ctx);
-	} else if (mode == MODE_PHYS_ID) {
-		return do_phys_id(&ctx);
-	} else if (mode == MODE_GPAUSE) {
-		return do_gpause(&ctx);
-	} else if (mode == MODE_SPAUSE) {
-		return do_spause(&ctx);
-	} else if (mode == MODE_GCOALESCE) {
-		return do_gcoalesce(&ctx);
-	} else if (mode == MODE_SCOALESCE) {
-		return do_scoalesce(&ctx);
-	} else if (mode == MODE_GRING) {
-		return do_gring(&ctx);
-	} else if (mode == MODE_SRING) {
-		return do_sring(&ctx);
-	} else if (mode == MODE_GCHANNELS) {
-		return do_gchannels(&ctx);
-	} else if (mode == MODE_SCHANNELS) {
-		return do_schannels(&ctx);
-	} else if (mode == MODE_GOFFLOAD) {
-		return do_goffload(&ctx);
-	} else if (mode == MODE_SOFFLOAD) {
-		return do_soffload(&ctx);
-	} else if (mode == MODE_GSTATS) {
-		return do_gstats(&ctx);
-	} else if (mode == MODE_GNFC) {
-		return do_grxclass(&ctx);
-	} else if (mode == MODE_SNFC) {
-		return do_srxclass(&ctx);
-	} else if (mode == MODE_GRXFHINDIR) {
-		return do_grxfhindir(&ctx);
-	} else if (mode == MODE_SRXFHINDIR) {
-		return do_srxfhindir(&ctx);
-	} else if (mode == MODE_SCLSRULE) {
-		return do_srxclsrule(&ctx);
-	} else if (mode == MODE_GCLSRULE) {
-		return do_grxclsrule(&ctx);
-	} else if (mode == MODE_FLASHDEV) {
-		return do_flash(&ctx);
-	} else if (mode == MODE_PERMADDR) {
-		return do_permaddr(&ctx);
-	} else if (mode == MODE_GET_DUMP) {
-		return do_getfwdump(&ctx);
-	} else if (mode == MODE_SET_DUMP) {
-		return do_setfwdump(&ctx);
-	}
-
-	return 69;
-}
-
 static int do_gdrv(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_drvinfo drvinfo;
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
 	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
@@ -2078,6 +1537,9 @@ static int do_gpause(struct cmd_context *ctx)
 	struct ethtool_cmd ecmd;
 	int err;
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	fprintf(stdout, "Pause parameters for %s:\n", devname);
 
 	epause.cmd = ETHTOOL_GPAUSEPARAM;
@@ -2135,6 +1597,9 @@ static int do_spause(struct cmd_context *ctx)
 {
 	int err, changed = 0;
 
+	parse_generic_cmdline(ctx, &gpause_changed,
+			      cmdline_pause, ARRAY_SIZE(cmdline_pause));
+
 	epause.cmd = ETHTOOL_GPAUSEPARAM;
 	err = send_ioctl(ctx, &epause);
 	if (err) {
@@ -2163,6 +1628,9 @@ static int do_sring(struct cmd_context *ctx)
 {
 	int err, changed = 0;
 
+	parse_generic_cmdline(ctx, &gring_changed,
+			      cmdline_ring, ARRAY_SIZE(cmdline_ring));
+
 	ering.cmd = ETHTOOL_GRINGPARAM;
 	err = send_ioctl(ctx, &ering);
 	if (err) {
@@ -2191,6 +1659,9 @@ static int do_gring(struct cmd_context *ctx)
 {
 	int err;
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	fprintf(stdout, "Ring parameters for %s:\n", devname);
 
 	ering.cmd = ETHTOOL_GRINGPARAM;
@@ -2211,6 +1682,9 @@ static int do_schannels(struct cmd_context *ctx)
 {
 	int err, changed = 0;
 
+	parse_generic_cmdline(ctx, &gchannels_changed,
+			      cmdline_channels, ARRAY_SIZE(cmdline_ring));
+
 	echannels.cmd = ETHTOOL_GCHANNELS;
 	err = send_ioctl(ctx, &echannels);
 	if (err) {
@@ -2244,6 +1718,9 @@ static int do_gchannels(struct cmd_context *ctx)
 {
 	int err;
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	fprintf(stdout, "Channel parameters for %s:\n", devname);
 
 	echannels.cmd = ETHTOOL_GCHANNELS;
@@ -2264,6 +1741,9 @@ static int do_gcoalesce(struct cmd_context *ctx)
 {
 	int err;
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	fprintf(stdout, "Coalesce parameters for %s:\n", devname);
 
 	ecoal.cmd = ETHTOOL_GCOALESCE;
@@ -2284,6 +1764,9 @@ static int do_scoalesce(struct cmd_context *ctx)
 {
 	int err, changed = 0;
 
+	parse_generic_cmdline(ctx, &gcoalesce_changed,
+			      cmdline_coalesce, ARRAY_SIZE(cmdline_coalesce));
+
 	ecoal.cmd = ETHTOOL_GCOALESCE;
 	err = send_ioctl(ctx, &ecoal);
 	if (err) {
@@ -2316,6 +1799,9 @@ static int do_goffload(struct cmd_context *ctx)
 	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, rxvlan = 0, txvlan = 0,
 	    ntuple = 0, rxhash = 0;
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
 	eval.cmd = ETHTOOL_GRXCSUM;
@@ -2408,6 +1894,9 @@ static int do_soffload(struct cmd_context *ctx)
 	struct ethtool_value eval;
 	int err, changed = 0;
 
+	parse_generic_cmdline(ctx, &goffload_changed,
+			      cmdline_offload, ARRAY_SIZE(cmdline_offload));
+
 	if (off_csum_rx_wanted >= 0) {
 		changed = 1;
 		eval.cmd = ETHTOOL_SRXCSUM;
@@ -2517,6 +2006,9 @@ static int do_gset(struct cmd_context *ctx)
 	struct ethtool_value edata;
 	int allfail = 1;
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	fprintf(stdout, "Settings for %s:\n", devname);
 
 	ecmd.cmd = ETHTOOL_GSET;
@@ -2574,8 +2066,152 @@ static int do_gset(struct cmd_context *ctx)
 
 static int do_sset(struct cmd_context *ctx)
 {
+	int argc = ctx->argc;
+	char **argp = ctx->argp;
+	int i;
 	int err;
 
+	for (i = 0; i < argc; i++) {
+		if (!strcmp(argp[i], "speed")) {
+			gset_changed = 1;
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			speed_wanted = get_int(argp[i],10);
+		} else if (!strcmp(argp[i], "duplex")) {
+			gset_changed = 1;
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			if (!strcmp(argp[i], "half"))
+				duplex_wanted = DUPLEX_HALF;
+			else if (!strcmp(argp[i], "full"))
+				duplex_wanted = DUPLEX_FULL;
+			else
+				exit_bad_args();
+		} else if (!strcmp(argp[i], "port")) {
+			gset_changed = 1;
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			if (!strcmp(argp[i], "tp"))
+				port_wanted = PORT_TP;
+			else if (!strcmp(argp[i], "aui"))
+				port_wanted = PORT_AUI;
+			else if (!strcmp(argp[i], "bnc"))
+				port_wanted = PORT_BNC;
+			else if (!strcmp(argp[i], "mii"))
+				port_wanted = PORT_MII;
+			else if (!strcmp(argp[i], "fibre"))
+				port_wanted = PORT_FIBRE;
+			else
+				exit_bad_args();
+		} else if (!strcmp(argp[i], "autoneg")) {
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			if (!strcmp(argp[i], "on")) {
+				gset_changed = 1;
+				autoneg_wanted = AUTONEG_ENABLE;
+			} else if (!strcmp(argp[i], "off")) {
+				gset_changed = 1;
+				autoneg_wanted = AUTONEG_DISABLE;
+			} else {
+				exit_bad_args();
+			}
+		} else if (!strcmp(argp[i], "advertise")) {
+			gset_changed = 1;
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			advertising_wanted = get_int(argp[i], 16);
+		} else if (!strcmp(argp[i], "phyad")) {
+			gset_changed = 1;
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			phyad_wanted = get_int(argp[i], 0);
+		} else if (!strcmp(argp[i], "xcvr")) {
+			gset_changed = 1;
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			if (!strcmp(argp[i], "internal"))
+				xcvr_wanted = XCVR_INTERNAL;
+			else if (!strcmp(argp[i], "external"))
+				xcvr_wanted = XCVR_EXTERNAL;
+			else
+				exit_bad_args();
+		} else if (!strcmp(argp[i], "wol")) {
+			gwol_changed = 1;
+			i++;
+			if (i >= argc)
+				exit_bad_args();
+			if (parse_wolopts(argp[i], &wol_wanted) < 0)
+				exit_bad_args();
+			wol_change = 1;
+		} else if (!strcmp(argp[i], "sopass")) {
+			gwol_changed = 1;
+			i++;
+			if (i >= argc)
+				exit_bad_args();
+			get_mac_addr(argp[i], sopass_wanted);
+			sopass_change = 1;
+		} else if (!strcmp(argp[i], "msglvl")) {
+			i++;
+			if (i >= argc)
+				exit_bad_args();
+			if (isdigit((unsigned char)argp[i][0])) {
+				msglvl_changed = 1;
+				msglvl_mask = ~0;
+				msglvl_wanted =
+					get_uint_range(argp[i], 0,
+						       0xffffffff);
+			} else {
+				ctx->argc -= i;
+				ctx->argp += i;
+				parse_generic_cmdline(
+					ctx, &msglvl_changed,
+					cmdline_msglvl,
+					ARRAY_SIZE(cmdline_msglvl));
+				break;
+			}
+		} else {
+			exit_bad_args();
+		}
+	}
+
+	if (advertising_wanted < 0) {
+		if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
+			advertising_wanted = ADVERTISED_10baseT_Half;
+		else if (speed_wanted == SPEED_10 &&
+			 duplex_wanted == DUPLEX_FULL)
+			advertising_wanted = ADVERTISED_10baseT_Full;
+		else if (speed_wanted == SPEED_100 &&
+			 duplex_wanted == DUPLEX_HALF)
+			advertising_wanted = ADVERTISED_100baseT_Half;
+		else if (speed_wanted == SPEED_100 &&
+			 duplex_wanted == DUPLEX_FULL)
+			advertising_wanted = ADVERTISED_100baseT_Full;
+		else if (speed_wanted == SPEED_1000 &&
+			 duplex_wanted == DUPLEX_HALF)
+			advertising_wanted = ADVERTISED_1000baseT_Half;
+		else if (speed_wanted == SPEED_1000 &&
+			 duplex_wanted == DUPLEX_FULL)
+			advertising_wanted = ADVERTISED_1000baseT_Full;
+		else if (speed_wanted == SPEED_2500 &&
+			 duplex_wanted == DUPLEX_FULL)
+			advertising_wanted = ADVERTISED_2500baseX_Full;
+		else if (speed_wanted == SPEED_10000 &&
+			 duplex_wanted == DUPLEX_FULL)
+			advertising_wanted = ADVERTISED_10000baseT_Full;
+		else
+			/* auto negotiate without forcing,
+			 * all supported speed will be assigned below
+			 */
+			advertising_wanted = 0;
+	}
+
 	if (gset_changed) {
 		struct ethtool_cmd ecmd;
 
@@ -2712,6 +2348,9 @@ static int do_gregs(struct cmd_context *ctx)
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_regs *regs;
 
+	parse_generic_cmdline(ctx, &gregs_changed,
+			      cmdline_gregs, ARRAY_SIZE(cmdline_gregs));
+
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
 	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
@@ -2747,6 +2386,9 @@ static int do_nway_rst(struct cmd_context *ctx)
 	struct ethtool_value edata;
 	int err;
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	edata.cmd = ETHTOOL_NWAY_RST;
 	err = send_ioctl(ctx, &edata);
 	if (err < 0)
@@ -2761,6 +2403,9 @@ static int do_geeprom(struct cmd_context *ctx)
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_eeprom *eeprom;
 
+	parse_generic_cmdline(ctx, &geeprom_changed,
+			      cmdline_geeprom, ARRAY_SIZE(cmdline_geeprom));
+
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
 	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
@@ -2800,6 +2445,9 @@ static int do_seeprom(struct cmd_context *ctx)
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_eeprom *eeprom;
 
+	parse_generic_cmdline(ctx, &seeprom_changed,
+			      cmdline_seeprom, ARRAY_SIZE(cmdline_seeprom));
+
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
 	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
@@ -2849,6 +2497,20 @@ static int do_test(struct cmd_context *ctx)
 	struct ethtool_test *test;
 	struct ethtool_gstrings *strings;
 
+	if (ctx->argc > 1)
+		exit_bad_args();
+	if (ctx->argc == 1) {
+		if (!strcmp(ctx->argp[0], "online")) {
+			test_type = ONLINE;
+	 	} else if (!strcmp(*ctx->argp, "offline")) {
+			test_type = OFFLINE;
+		} else if (!strcmp(*ctx->argp, "external_lb")) {
+			test_type = EXTERNAL_LB;
+		} else {
+			exit_bad_args();
+		}
+	}
+
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
 	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
@@ -2907,6 +2569,11 @@ static int do_phys_id(struct cmd_context *ctx)
 	int err;
 	struct ethtool_value edata;
 
+	if (ctx->argc > 1)
+		exit_bad_args();
+	if (ctx->argc == 1)
+		phys_id_time = get_int(*ctx->argp, 0);
+
 	edata.cmd = ETHTOOL_PHYS_ID;
 	edata.data = phys_id_time;
 	err = send_ioctl(ctx, &edata);
@@ -2924,6 +2591,9 @@ static int do_gstats(struct cmd_context *ctx)
 	unsigned int n_stats, sz_str, sz_stats, i;
 	int err;
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
 	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
@@ -2985,10 +2655,15 @@ static int do_gstats(struct cmd_context *ctx)
 
 static int do_srxclass(struct cmd_context *ctx)
 {
+	struct ethtool_rxnfc nfccmd;
 	int err;
 
-	if (rx_fhash_changed) {
-		struct ethtool_rxnfc nfccmd;
+	if (ctx->argc == 3 && !strcmp(ctx->argp[0], "rx-flow-hash")) {
+		rx_fhash_set = rxflow_str_to_type(ctx->argp[1]);
+		if (!rx_fhash_set)
+			exit_bad_args();
+		if (parse_rxfhashopts(ctx->argp[2], &rx_fhash_val) < 0)
+			exit_bad_args();
 
 		nfccmd.cmd = ETHTOOL_SRXFH;
 		nfccmd.flow_type = rx_fhash_set;
@@ -2997,7 +2672,8 @@ static int do_srxclass(struct cmd_context *ctx)
 		err = send_ioctl(ctx, &nfccmd);
 		if (err < 0)
 			perror("Cannot change RX network flow hashing options");
-
+	} else {
+		exit_bad_args();
 	}
 
 	return 0;
@@ -3005,10 +2681,13 @@ static int do_srxclass(struct cmd_context *ctx)
 
 static int do_grxclass(struct cmd_context *ctx)
 {
+	struct ethtool_rxnfc nfccmd;
 	int err;
 
-	if (rx_fhash_get) {
-		struct ethtool_rxnfc nfccmd;
+	if (ctx->argc == 2 && !strcmp(ctx->argp[0], "rx-flow-hash")) {
+		rx_fhash_get = rxflow_str_to_type(ctx->argp[1]);
+		if (!rx_fhash_get)
+			exit_bad_args();
 
 		nfccmd.cmd = ETHTOOL_GRXFH;
 		nfccmd.flow_type = rx_fhash_get;
@@ -3017,6 +2696,8 @@ static int do_grxclass(struct cmd_context *ctx)
 			perror("Cannot get RX network flow hashing options");
 		else
 			dump_rxfhash(rx_fhash_get, nfccmd.data);
+	} else {
+		exit_bad_args();
 	}
 
 	return 0;
@@ -3074,8 +2755,17 @@ static int do_srxfhindir(struct cmd_context *ctx)
 	u32 i;
 	int err;
 
-	if (!rxfhindir_equal && !rxfhindir_weight)
+	if (ctx->argc < 2)
+		exit_bad_args();
+	if (!strcmp(ctx->argp[0], "equal")) {
+		if (ctx->argc != 2)
+			exit_bad_args();
+		rxfhindir_equal = get_int_range(ctx->argp[1], 0, 1, INT_MAX);
+	} else if (!strcmp(ctx->argp[0], "weight")) {
+		rxfhindir_weight = ctx->argp + 1;
+	} else {
 		exit_bad_args();
+	}
 
 	indir_head.cmd = ETHTOOL_GRXFHINDIR;
 	indir_head.size = 0;
@@ -3139,10 +2829,13 @@ static int do_flash(struct cmd_context *ctx)
 	struct ethtool_flash efl;
 	int err;
 
-	if (flash < 0) {
-		fprintf(stdout, "Missing filename argument\n");
+	if (ctx->argc < 1 || ctx->argc > 2)
 		exit_bad_args();
-		return 98;
+	flash_file = ctx->argp[0];
+	if (ctx->argc == 2) {
+		flash_region = strtol(ctx->argp[1], NULL, 0);
+		if (flash_region < 0)
+			exit_bad_args();
 	}
 
 	if (strlen(flash_file) > ETHTOOL_FLASH_MAX_FILENAME - 1) {
@@ -3309,7 +3002,15 @@ static int do_srxclsrule(struct cmd_context *ctx)
 {
 	int err;
 
-	if (rx_class_rule_added) {
+	if (ctx->argc < 2)
+		exit_bad_args();
+
+	if (!strcmp(ctx->argp[0], "flow-type")) {
+		ctx->argc--;
+		ctx->argp++;
+		if (rxclass_parse_ruleopts(ctx, &rx_rule_fs) < 0)
+			exit_bad_args();
+
 		/* attempt to add rule via N-tuple specifier */
 		err = do_srxntuple(ctx);
 		if (!err)
@@ -3322,7 +3023,9 @@ static int do_srxclsrule(struct cmd_context *ctx)
 				" classification rule\n");
 			return 1;
 		}
-	} else if (rx_class_rule_del >= 0) {
+	} else if (!strcmp(ctx->argp[0], "delete")) {
+		rx_class_rule_del = get_uint_range(ctx->argp[1], 0, INT_MAX);
+
 		err = rxclass_rule_del(ctx, rx_class_rule_del);
 
 		if (err < 0) {
@@ -3342,13 +3045,18 @@ static int do_grxclsrule(struct cmd_context *ctx)
 	struct ethtool_rxnfc nfccmd;
 	int err;
 
-	if (rx_class_rule_get >= 0) {
+	if (ctx->argc == 2 && !strcmp(ctx->argp[0], "rule")) {
+		rx_class_rule_get = get_uint_range(ctx->argp[1], 0, INT_MAX);
+
 		err = rxclass_rule_get(ctx, rx_class_rule_get);
 		if (err < 0)
 			fprintf(stderr, "Cannot get RX classification rule\n");
 		return err ? 1 : 0;
 	}
 
+	if (ctx->argc != 0)
+		exit_bad_args();
+
 	nfccmd.cmd = ETHTOOL_GRXRINGS;
 	err = send_ioctl(ctx, &nfccmd);
 	if (err < 0)
@@ -3396,6 +3104,13 @@ static int do_getfwdump(struct cmd_context *ctx)
 	struct ethtool_dump edata;
 	struct ethtool_dump *data;
 
+	if (ctx->argc == 2 && !strcmp(ctx->argp[0], "data")) {
+		dump_flag = ETHTOOL_GET_DUMP_DATA;
+		dump_file = ctx->argp[1];
+	} else if (ctx->argc != 0) {
+		exit_bad_args();
+	}
+
 	edata.cmd = ETHTOOL_GET_DUMP_FLAG;
 
 	err = send_ioctl(ctx, &edata);
@@ -3432,6 +3147,10 @@ static int do_setfwdump(struct cmd_context *ctx)
 	int err;
 	struct ethtool_dump dump;
 
+	if (ctx->argc != 1)
+		exit_bad_args();
+	dump_flag = get_u32(ctx->argp[0], 0);
+
 	dump.cmd = ETHTOOL_SET_DUMP;
 	dump.flag = dump_flag;
 	err = send_ioctl(ctx, &dump);
@@ -3455,6 +3174,63 @@ int send_ioctl(struct cmd_context *ctx, void *cmd)
 
 int main(int argc, char **argp, char **envp)
 {
-	parse_cmdline(argc, argp);
-	return doit();
+	int (*func)(struct cmd_context *) = NULL;
+	int want_device = 0;
+	struct cmd_context ctx;
+	int k;
+
+	/* Skip command name */
+	argp++;
+	argc--;
+
+	/* First argument must be either a valid option or a device
+	 * name to get settings for (which we don't expect to begin
+	 * with '-').
+	 */
+	if (argc == 0)
+		exit_bad_args();
+	for (k = 0; args[k].lng; k++) {
+		if ((args[k].srt && !strcmp(*argp, args[k].srt)) ||
+		    !strcmp(*argp, args[k].lng)) {
+			argp++;
+			argc--;
+			func = args[k].func;
+			want_device = args[k].want_device;
+			break;
+		}
+	}
+	if (!func) {
+		if ((*argp)[0] == '-')
+			exit_bad_args();
+		func = do_gset;
+		want_device = 1;
+	}
+
+	if (want_device) {
+		devname = *argp++;
+		argc--;
+
+		if (devname == NULL)
+			exit_bad_args();
+		if (strlen(devname) >= IFNAMSIZ)
+			exit_bad_args();
+
+		/* Setup our control structures. */
+		memset(&ctx.ifr, 0, sizeof(ctx.ifr));
+		strcpy(ctx.ifr.ifr_name, devname);
+
+		/* Open control socket. */
+		ctx.fd = socket(AF_INET, SOCK_DGRAM, 0);
+		if (ctx.fd < 0) {
+			perror("Cannot get control socket");
+			return 70;
+		}
+	} else {
+		ctx.fd = -1;
+	}
+
+	ctx.argc = argc;
+	ctx.argp = argp;
+
+	return func(&ctx);
 }
diff --git a/internal.h b/internal.h
index ba7d719..eb13db8 100644
--- a/internal.h
+++ b/internal.h
@@ -92,6 +92,8 @@ static inline int test_bit(unsigned int nr, const unsigned long *addr)
 struct cmd_context {
 	int fd;			/* socket suitable for ethtool ioctl */
 	struct ifreq ifr;	/* ifreq suitable for ethtool ioctl */
+	int argc;		/* number of arguments to the sub-command */
+	char **argp;		/* arguments to the sub-command */
 };
 
 #ifdef TEST_ETHTOOL
@@ -165,7 +167,7 @@ int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
 /* Rx flow classification */
-int rxclass_parse_ruleopts(char **optstr, int opt_cnt,
+int rxclass_parse_ruleopts(struct cmd_context *ctx,
 			   struct ethtool_rx_flow_spec *fsp);
 int rxclass_rule_getall(struct cmd_context *ctx);
 int rxclass_rule_get(struct cmd_context *ctx, __u32 loc);
diff --git a/rxclass.c b/rxclass.c
index dec9dd5..0c7b916 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -950,7 +950,7 @@ static int rxclass_get_mask(char *str, unsigned char *p,
 	return 0;
 }
 
-int rxclass_parse_ruleopts(char **argp, int argc,
+int rxclass_parse_ruleopts(struct cmd_context *ctx,
 			   struct ethtool_rx_flow_spec *fsp)
 {
 	const struct rule_opts *options;
@@ -958,6 +958,8 @@ int rxclass_parse_ruleopts(char **argp, int argc,
 	int i = 0, n_opts, err;
 	u32 flags = 0;
 	int flow_type;
+	int argc = ctx->argc;
+	char **argp = ctx->argp;
 
 	if (argc < 1)
 		goto syntax_err;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
