From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/4] Merge RX NFC options
Date: Fri, 17 Feb 2012 20:55:00 +0000
Message-ID: <1329512100.2822.6.camel@bwh-desktop>
References: <1329512042.2822.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15473 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754368Ab2BQUzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 15:55:03 -0500
In-Reply-To: <1329512042.2822.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Santwona Behera originally intended to extend the -n and -N options to
cover querying and setting rules as well as flow hash options.
However, his patch fell between the cracks and the ethtool utility got
n-tuple support first, using the -u and -U options.  When RX NFC rule
support was finally added I insisted that it should not require
different command syntax, so rules must be accessed through these
options.

The sets of valid argument lists following the -n and -u options are
still non-overlapping, and similarly for the -N and -U options.  Since
the top level argument parser now supports arbitrary numbers of option
aliases, we can merge these pairs together and achieve the original
intent.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in   |  155 +++++++++++++++++++++++-------------------------
 ethtool.c      |  178 ++++++++++++++++++++++++--------------------------------
 test-cmdline.c |   52 +++++++++--------
 3 files changed, 177 insertions(+), 208 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index e6e46cc..6f0b246 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -250,13 +250,37 @@ ethtool \- query or control network driver and hardware settings
 .A1 on off
 .RB ...]
 .HP
-.B ethtool \-n
+.B ethtool \-n|\-u|\-\-show\-nfc|\-\-show\-ntuple
 .I devname
-.BR rx\-flow\-hash \ \*(FL
+.RB [\  rx\-flow\-hash \ \*(FL \ |
+.br
+.BI rule \ N
+.RB ]
 .HP
-.B ethtool \-N
+.B ethtool \-N|\-U|\-\-config\-nfc|\-\-config\-ntuple
 .I devname
-.BR rx\-flow\-hash \ \*(FL \: \*(HO
+.BR rx\-flow\-hash \ \*(FL \: \*(HO \ |
+.br
+.B flow\-type \*(NC
+.RB [ src \ \*(MA\ [ m \ \*(MA]]
+.RB [ dst \ \*(MA\ [ m \ \*(MA]]
+.BM proto
+.RB [ src\-ip \ \*(PA\ [ m \ \*(PA]]
+.RB [ dst\-ip \ \*(PA\ [ m \ \*(PA]]
+.BM tos
+.BM l4proto
+.BM src\-port
+.BM dst\-port
+.BM spi
+.BM l4data
+.BM vlan\-etype
+.BM vlan
+.BM user\-def
+.BN action
+.BN loc
+.RB |
+.br
+.BI delete \ N
 .HP
 .B ethtool \-w|\-\-get\-dump
 .I devname
@@ -283,31 +307,6 @@ ethtool \- query or control network driver and hardware settings
 .RI FILE
 .RI [ N ]
 .HP
-.B ethtool \-u|\-\-show\-ntuple
-.I devname
-.BN rule
-.HP
-.BI ethtool\ \-U|\-\-config\-ntuple \ devname
-.BN delete
-.RB [\  flow\-type \ \*(NC
-.RB [ src \ \*(MA\ [ m \ \*(MA]]
-.RB [ dst \ \*(MA\ [ m \ \*(MA]]
-.BM proto
-.RB [ src\-ip \ \*(PA\ [ m \ \*(PA]]
-.RB [ dst\-ip \ \*(PA\ [ m \ \*(PA]]
-.BM tos
-.BM l4proto
-.BM src\-port
-.BM dst\-port
-.BM spi
-.BM l4data
-.BM vlan\-etype
-.BM vlan
-.BM user\-def
-.BN action
-.BN loc
-.RB ]
-.HP
 .B ethtool \-l|\-\-show\-channels
 .I devname
 .HP
@@ -590,7 +589,7 @@ The precise meanings of these type flags differ between drivers.
 .PD
 .RE
 .TP
-.B \-n \-\-show\-nfc
+.B \-n \-u \-\-show\-nfc \-\-show\-ntuple
 Retrieves the receive network flow classification configurations.
 .TP
 .BR rx\-flow\-hash \ \*(FL
@@ -610,7 +609,12 @@ esp6	IPSEC ESP over IPv6
 sctp6	SCTP over IPv6
 .TE
 .TP
-.B \-N \-\-config\-nfc
+.BI rule \ N
+Retrieves the RX classification rule with the given ID.
+.PD
+.RE
+.TP
+.B \-N \-U \-\-config\-nfc \-\-config\-ntuple
 Configures the receive network flow classification.
 .TP
 .BR rx\-flow\-hash \ \*(FL \: \*(HO
@@ -631,56 +635,6 @@ other options are ignored.
 T}
 .TE
 .TP
-.B \-w \-\-get\-dump
-Retrieves and prints firmware dump for the specified network device.
-By default, it prints out the dump flag, version and length of the dump data.
-When
-.I data
-is indicated, then ethtool fetches the dump data and directs it to a
-.I file.
-.TP
-.B \-W \-\-set\-dump
-Sets the dump flag for the device.
-.TP
-.B \-x \-\-show\-rxfh\-indir
-Retrieves the receive flow hash indirection table.
-.TP
-.B \-X \-\-set\-rxfh\-indir
-Configures the receive flow hash indirection table.
-.TP
-.BI equal\  N
-Sets the receive flow hash indirection table to spread flows evenly
-between the first \fIN\fR receive queues.
-.TP
-\fBweight\fR \fIW0 W1\fR ...
-Sets the receive flow hash indirection table to spread flows between
-receive queues according to the given weights.  The sum of the weights
-must be non-zero and must not exceed the size of the indirection table.
-.TP
-.B \-f \-\-flash \ FILE
-Flash firmware image from the specified file to a region on the adapter.
-By default this will flash all the regions on the adapter.
-.TP
-.B N
-A number to identify flash region where the image should be flashed.
-Default region is 0 which denotes all regions in the flash.
-.PD
-.RE
-.TP
-.B \-u \-\-show\-ntuple
-Get Rx ntuple filters and actions, then display them to the user.
-.TP
-.BI rule \ N
-Retrieves the RX classification rule with the given ID.
-.PD
-.RE
-.TP
-.B \-U \-\-config\-ntuple
-Configure Rx ntuple filters and actions
-.TP
-.BI delete \ N
-Deletes the RX classification rule with the given ID.
-.TP
 .B flow\-type \*(NC
 .TS
 nokeep;
@@ -773,6 +727,45 @@ Specify the location/ID to insert the rule. This will overwrite
 any rule present in that location and will not go through any
 of the rule ordering process.
 .TP
+.BI delete \ N
+Deletes the RX classification rule with the given ID.
+.TP
+.B \-w \-\-get\-dump
+Retrieves and prints firmware dump for the specified network device.
+By default, it prints out the dump flag, version and length of the dump data.
+When
+.I data
+is indicated, then ethtool fetches the dump data and directs it to a
+.I file.
+.TP
+.B \-W \-\-set\-dump
+Sets the dump flag for the device.
+.TP
+.B \-x \-\-show\-rxfh\-indir
+Retrieves the receive flow hash indirection table.
+.TP
+.B \-X \-\-set\-rxfh\-indir
+Configures the receive flow hash indirection table.
+.TP
+.BI equal\  N
+Sets the receive flow hash indirection table to spread flows evenly
+between the first \fIN\fR receive queues.
+.TP
+\fBweight\fR \fIW0 W1\fR ...
+Sets the receive flow hash indirection table to spread flows between
+receive queues according to the given weights.  The sum of the weights
+must be non-zero and must not exceed the size of the indirection table.
+.TP
+.B \-f \-\-flash \ FILE
+Flash firmware image from the specified file to a region on the adapter.
+By default this will flash all the regions on the adapter.
+.TP
+.B N
+A number to identify flash region where the image should be flashed.
+Default region is 0 which denotes all regions in the flash.
+.PD
+.RE
+.TP
 .B \-l \-\-show\-channels
 Queries the specified network device for the numbers of channels it has.
 A channel is an IRQ and the set of queues that can trigger that IRQ.
diff --git a/ethtool.c b/ethtool.c
index 1f496dd..e80b38b 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2472,11 +2472,16 @@ static int do_gstats(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_srxntuple(struct cmd_context *ctx,
+			struct ethtool_rx_flow_spec *rx_rule_fs);
 
 static int do_srxclass(struct cmd_context *ctx)
 {
 	int err;
 
+	if (ctx->argc < 2)
+		exit_bad_args();
+
 	if (ctx->argc == 3 && !strcmp(ctx->argp[0], "rx-flow-hash")) {
 		int rx_fhash_set;
 		u32 rx_fhash_val;
@@ -2495,6 +2500,37 @@ static int do_srxclass(struct cmd_context *ctx)
 		err = send_ioctl(ctx, &nfccmd);
 		if (err < 0)
 			perror("Cannot change RX network flow hashing options");
+	} else if (!strcmp(ctx->argp[0], "flow-type")) {	
+		struct ethtool_rx_flow_spec rx_rule_fs;
+
+		ctx->argc--;
+		ctx->argp++;
+		if (rxclass_parse_ruleopts(ctx, &rx_rule_fs) < 0)
+			exit_bad_args();
+
+		/* attempt to add rule via N-tuple specifier */
+		err = do_srxntuple(ctx, &rx_rule_fs);
+		if (!err)
+			return 0;
+
+		/* attempt to add rule via network flow classifier */
+		err = rxclass_rule_ins(ctx, &rx_rule_fs);
+		if (err < 0) {
+			fprintf(stderr, "Cannot insert"
+				" classification rule\n");
+			return 1;
+		}
+	} else if (!strcmp(ctx->argp[0], "delete")) {
+		int rx_class_rule_del =
+			get_uint_range(ctx->argp[1], 0, INT_MAX);
+
+		err = rxclass_rule_del(ctx, rx_class_rule_del);
+
+		if (err < 0) {
+			fprintf(stderr, "Cannot delete"
+				" classification rule\n");
+			return 1;
+		}
 	} else {
 		exit_bad_args();
 	}
@@ -2521,11 +2557,31 @@ static int do_grxclass(struct cmd_context *ctx)
 			perror("Cannot get RX network flow hashing options");
 		else
 			dump_rxfhash(rx_fhash_get, nfccmd.data);
+	} else if (ctx->argc == 2 && !strcmp(ctx->argp[0], "rule")) {
+		int rx_class_rule_get =
+			get_uint_range(ctx->argp[1], 0, INT_MAX);
+
+		err = rxclass_rule_get(ctx, rx_class_rule_get);
+		if (err < 0)
+			fprintf(stderr, "Cannot get RX classification rule\n");
+	} else if (ctx->argc == 0) {
+		nfccmd.cmd = ETHTOOL_GRXRINGS;
+		err = send_ioctl(ctx, &nfccmd);
+		if (err < 0)
+			perror("Cannot get RX rings");
+		else
+			fprintf(stdout, "%d RX rings available\n",
+				(int)nfccmd.data);
+
+		err = rxclass_rule_getall(ctx);
+		if (err < 0)
+			fprintf(stderr, "RX classification rule retrieval failed\n");
+
 	} else {
 		exit_bad_args();
 	}
 
-	return 0;
+	return err ? 1 : 0;
 }
 
 static int do_grxfhindir(struct cmd_context *ctx)
@@ -2830,84 +2886,6 @@ static int do_srxntuple(struct cmd_context *ctx,
 	return 0;
 }
 
-static int do_srxclsrule(struct cmd_context *ctx)
-{
-	int err;
-
-	if (ctx->argc < 2)
-		exit_bad_args();
-
-	if (!strcmp(ctx->argp[0], "flow-type")) {	
-		struct ethtool_rx_flow_spec rx_rule_fs;
-
-		ctx->argc--;
-		ctx->argp++;
-		if (rxclass_parse_ruleopts(ctx, &rx_rule_fs) < 0)
-			exit_bad_args();
-
-		/* attempt to add rule via N-tuple specifier */
-		err = do_srxntuple(ctx, &rx_rule_fs);
-		if (!err)
-			return 0;
-
-		/* attempt to add rule via network flow classifier */
-		err = rxclass_rule_ins(ctx, &rx_rule_fs);
-		if (err < 0) {
-			fprintf(stderr, "Cannot insert"
-				" classification rule\n");
-			return 1;
-		}
-	} else if (!strcmp(ctx->argp[0], "delete")) {
-		int rx_class_rule_del =
-			get_uint_range(ctx->argp[1], 0, INT_MAX);
-
-		err = rxclass_rule_del(ctx, rx_class_rule_del);
-
-		if (err < 0) {
-			fprintf(stderr, "Cannot delete"
-				" classification rule\n");
-			return 1;
-		}
-	} else {
-		exit_bad_args();
-	}
-
-	return 0;
-}
-
-static int do_grxclsrule(struct cmd_context *ctx)
-{
-	struct ethtool_rxnfc nfccmd;
-	int err;
-
-	if (ctx->argc == 2 && !strcmp(ctx->argp[0], "rule")) {
-		int rx_class_rule_get =
-			get_uint_range(ctx->argp[1], 0, INT_MAX);
-
-		err = rxclass_rule_get(ctx, rx_class_rule_get);
-		if (err < 0)
-			fprintf(stderr, "Cannot get RX classification rule\n");
-		return err ? 1 : 0;
-	}
-
-	if (ctx->argc != 0)
-		exit_bad_args();
-
-	nfccmd.cmd = ETHTOOL_GRXRINGS;
-	err = send_ioctl(ctx, &nfccmd);
-	if (err < 0)
-		perror("Cannot get RX rings");
-	else
-		fprintf(stdout, "%d RX rings available\n",
-			(int)nfccmd.data);
-
-	err = rxclass_rule_getall(ctx);
-	if (err < 0)
-		fprintf(stderr, "RX classification rule retrieval failed\n");
-
-	return err ? 1 : 0;
-}
-
 static int do_writefwdump(struct ethtool_dump *dump, const char *dump_file)
 {
 	int err = 0;
@@ -3202,26 +3180,16 @@ static const struct option {
 	{ "-t|--test", 1, do_test, "Execute adapter self test",
 	  "               [ online | offline | external_lb ]\n" },
 	{ "-S|--statistics", 1, do_gstats, "Show adapter statistics" },
-	{ "-n|--show-nfc", 1, do_grxclass,
-	  "Show Rx network flow classification options",
-	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
-	  "tcp6|udp6|ah6|esp6|sctp6 ]\n" },
-	{ "-N|--config-nfc", 1, do_srxclass,
-	  "Configure Rx network flow classification options",
+	{ "-n|-u|--show-nfc|--show-ntuple", 1, do_grxclass,
+	  "Show Rx network flow classification options or rules",
 	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
-	  "tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
-	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
-	  "Show Rx flow hash indirection" },
-	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
-	  "Set Rx flow hash indirection",
-	  "		equal N | weight W0 W1 ...\n" },
-	{ "-f|--flash", 1, do_flash,
-	  "Flash firmware image from the specified file to a region on the device",
-	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-	{ "-U|--config-ntuple", 1, do_srxclsrule,
-	  "Configure Rx ntuple filters and actions",
-	  "		[ delete %d ] |\n"
-	  "		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
+	  "tcp6|udp6|ah6|esp6|sctp6 |\n"
+	  "		  rule %d ]\n" },
+	{ "-N|-U|--config-nfc|--config-ntuple", 1, do_srxclass,
+	  "Configure Rx network flow classification options or rules",
+	  "		rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+	  "tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... |\n"
+	  "		flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
 	  "			[ src %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
 	  "			[ dst %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
 	  "			[ proto %d [m %x] ]\n"
@@ -3236,10 +3204,16 @@ static const struct option {
 	  "			[ vlan %x [m %x] ]\n"
 	  "			[ user-def %x [m %x] ]\n"
 	  "			[ action %d ]\n"
-	  "			[ loc %d]]\n" },
-	{ "-u|--show-ntuple", 1, do_grxclsrule,
-	  "Get Rx ntuple filters and actions",
-	  "		[ rule %d ]\n"},
+	  "			[ loc %d]] |\n"
+	  "		delete %d\n" },
+	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
+	  "Show Rx flow hash indirection" },
+	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
+	  "Set Rx flow hash indirection",
+	  "		equal N | weight W0 W1 ...\n" },
+	{ "-f|--flash", 1, do_flash,
+	  "Flash firmware image from the specified file to a region on the device",
+	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
 	{ "-P|--show-permaddr", 1, do_permaddr,
 	  "Show permanent hardware address" },
 	{ "-w|--get-dump", 1, do_getfwdump,
diff --git a/test-cmdline.c b/test-cmdline.c
index 56a26d8..4718842 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -130,12 +130,15 @@ static struct test_case {
 	{ 0, "-S devname" },
 	{ 0, "--statistics devname" },
 	{ 1, "-S" },
-	/* Argument parsing for -n is specialised */
+	/* Argument parsing for -n/-u is specialised */
 	{ 0, "-n devname rx-flow-hash tcp4" },
+	{ 0, "-u devname rx-flow-hash sctp4" },
 	{ 0, "--show-nfc devname rx-flow-hash udp6" },
+	{ 0, "--show-ntuple devname rx-flow-hash esp6" },
 	{ 1, "-n devname rx-flow-hash foo" },
+	{ 1, "-u devname rx-flow-hash foo" },
 	{ 1, "--show-nfc devname rx-flow-hash" },
-	{ 1, "-n devname foo" },
+	{ 1, "--show-ntuple devname rx-flow-hash" },
 	{ 1, "-n" },
 	/* Argument parsing for -f is specialised */
 	{ 1, "-f devname" },
@@ -143,14 +146,32 @@ static struct test_case {
 	{ 0, "-f devname filename 1" },
 	{ 1, "-f devname filename 1 foo" },
 	{ 1, "-f" },
-	/* Argument parsing for -N is specialised */
+	/* Argument parsing for -N/-U is specialised */
 	{ 0, "-N devname rx-flow-hash tcp4 mvtsdfn" },
-	{ 0, "--config-nfc devname rx-flow-hash tcp4 r" },
-	{ 1, "-N devname rx-flow-hash tcp4" },
+	{ 0, "--config-ntuple devname rx-flow-hash tcp4 r" },
+	{ 1, "-U devname rx-flow-hash tcp4" },
 	{ 1, "--config-nfc devname rx-flow-hash foo" },
 	{ 1, "-N devname rx-flow-hash" },
-	{ 1, "--config-nfc devname foo" },
+	{ 1, "--config-ntuple devname foo" },
+	{ 0, "-U devname delete 1" },
+	{ 1, "--config-nfc devname delete foo" },
+	{ 1, "-N devname delete" },
+	{ 0, "--config-ntuple devname flow-type ether src 01:23:45:67:89:ab m cd:ef:01:23:45:67 dst 89:ab:cd:ef:01:23 m 45:67:89:ab:cd:ef proto 0x0123 m 0x4567 vlan 0x89ab m 0xcdef action 0" },
+	{ 0, "-U devname flow-type ether src 01:23:45:67:89:ab src-mask cd:ef:01:23:45:67 dst 89:ab:cd:ef:01:23 dst-mask 45:67:89:ab:cd:ef proto 0x0123 proto-mask 0x4567 vlan 0x89ab vlan-mask 0xcdef action 1" },
+	{ 1, "--config-nfc devname flow-type ether src 01:23:45:67:89: action 3" },
+	{ 1, "-N devname flow-type ether src 01:23:45:67:89 action 4" },
+	{ 0, "--config-ntuple devname flow-type ip4 src-ip 0.123.45.67 m 89.0.123.45 dst-ip 67.89.0.123 m 45.67.89.0 tos 1 m 1 l4proto 0x23 m 0x45 l4data 0xfedcba98 m 76543210 vlan 0x89ab m 0xcdef action 6" },
+	{ 0, "-U devname flow-type ip4 src-ip 0.123.45.67 src-ip-mask 89.0.123.45 dst-ip 67.89.0.123 dst-ip-mask 45.67.89.0 tos 1 tos-mask 1 l4proto 0x23 l4proto-mask 0x45 l4data 0xfedcba98 l4data-mask 76543210 vlan 0x89ab vlan-mask 0xcdef action 7" },
+	{ 0, "--config-nfc devname flow-type tcp4 src-ip 0.123.45.67 m 89.0.123.45 dst-ip 67.89.0.123 m 45.67.89.0 tos 1 m 1 src-port 23456 m 7890 dst-port 12345 m 6789 vlan 0x89ab m 0xcdef action 8" },
+	{ 0, "-N devname flow-type tcp4 src-ip 0.123.45.67 src-ip-mask 89.0.123.45 dst-ip 67.89.0.123 dst-ip-mask 45.67.89.0 tos 1 tos-mask 1 src-port 23456 src-port-mask 7890 dst-port 12345 dst-port-mask 6789 vlan 0x89ab vlan-mask 0xcdef action 9" },
+	{ 0, "--config-ntuple devname flow-type ah4 src-ip 0.123.45.67 m 89.0.123.45 dst-ip 67.89.0.123 m 45.67.89.0 tos 1 m 1 spi 2 m 3 vlan 0x89ab m 0xcdef action 10" },
+	{ 0, "-U devname flow-type ah4 src-ip 0.123.45.67 src-ip-mask 89.0.123.45 dst-ip 67.89.0.123 dst-ip-mask 45.67.89.0 tos 1 tos-mask 1 spi 2 spi-mask 3 vlan 0x89ab vlan-mask 0xcdef action 11" },
+	{ 1, "--config-nfc devname flow-type tcp4 action foo" },
+	{ 1, "-N devname flow-type foo" },
+	{ 1, "--config-ntuple devname flow-type" },
+	{ 1, "-U devname foo" },
 	{ 1, "-N" },
+	{ 1, "-U" },
 	{ 0, "-x devname" },
 	{ 0, "--show-rxfh-indir devname" },
 	{ 1, "-x" },
@@ -163,25 +184,6 @@ static struct test_case {
 	{ 0, "--set-rxfh-indir devname weight 1 2 3 4" },
 	{ 1, "-X devname foo" },
 	{ 1, "-X" },
-	/* Argument parsing for -U is specialised */
-	{ 0, "-U devname delete 1" },
-	{ 1, "--config-ntuple devname delete foo" },
-	{ 1, "-U devname delete" },
-	{ 0, "--config-ntuple devname flow-type ether src 01:23:45:67:89:ab m cd:ef:01:23:45:67 dst 89:ab:cd:ef:01:23 m 45:67:89:ab:cd:ef proto 0x0123 m 0x4567 vlan 0x89ab m 0xcdef action 0" },
-	{ 0, "-U devname flow-type ether src 01:23:45:67:89:ab src-mask cd:ef:01:23:45:67 dst 89:ab:cd:ef:01:23 dst-mask 45:67:89:ab:cd:ef proto 0x0123 proto-mask 0x4567 vlan 0x89ab vlan-mask 0xcdef action 1" },
-	{ 1, "--config-ntuple devname flow-type ether src 01:23:45:67:89: action 3" },
-	{ 1, "-U devname flow-type ether src 01:23:45:67:89 action 4" },
-	{ 0, "--config-ntuple devname flow-type ip4 src-ip 0.123.45.67 m 89.0.123.45 dst-ip 67.89.0.123 m 45.67.89.0 tos 1 m 1 l4proto 0x23 m 0x45 l4data 0xfedcba98 m 76543210 vlan 0x89ab m 0xcdef action 6" },
-	{ 0, "-U devname flow-type ip4 src-ip 0.123.45.67 src-ip-mask 89.0.123.45 dst-ip 67.89.0.123 dst-ip-mask 45.67.89.0 tos 1 tos-mask 1 l4proto 0x23 l4proto-mask 0x45 l4data 0xfedcba98 l4data-mask 76543210 vlan 0x89ab vlan-mask 0xcdef action 7" },
-	{ 0, "--config-ntuple devname flow-type tcp4 src-ip 0.123.45.67 m 89.0.123.45 dst-ip 67.89.0.123 m 45.67.89.0 tos 1 m 1 src-port 23456 m 7890 dst-port 12345 m 6789 vlan 0x89ab m 0xcdef action 8" },
-	{ 0, "-U devname flow-type tcp4 src-ip 0.123.45.67 src-ip-mask 89.0.123.45 dst-ip 67.89.0.123 dst-ip-mask 45.67.89.0 tos 1 tos-mask 1 src-port 23456 src-port-mask 7890 dst-port 12345 dst-port-mask 6789 vlan 0x89ab vlan-mask 0xcdef action 9" },
-	{ 0, "--config-ntuple devname flow-type ah4 src-ip 0.123.45.67 m 89.0.123.45 dst-ip 67.89.0.123 m 45.67.89.0 tos 1 m 1 spi 2 m 3 vlan 0x89ab m 0xcdef action 10" },
-	{ 0, "-U devname flow-type ah4 src-ip 0.123.45.67 src-ip-mask 89.0.123.45 dst-ip 67.89.0.123 dst-ip-mask 45.67.89.0 tos 1 tos-mask 1 spi 2 spi-mask 3 vlan 0x89ab vlan-mask 0xcdef action 11" },
-	{ 1, "--config-ntuple devname flow-type tcp4 action foo" },
-	{ 1, "-U devname flow-type foo" },
-	{ 1, "--config-ntuple devname flow-type" },
-	{ 1, "-U devname foo" },
-	{ 1, "-U" },
 	{ 0, "-P devname" },
 	{ 0, "--show-permaddr devname" },
 	{ 1, "-P" },
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
