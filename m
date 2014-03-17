From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v4 ethtool 2/2] ethtool: Support for configurable RSS hash key
Date: Mon, 17 Mar 2014 18:02:52 +0530
Message-ID: <175bafae-e837-4e2e-8c6c-af5d7ef21552@CMEXHTCAS2.ad.emulex.com>
References: <1395059572-16136-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22199 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932901AbaCQMdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 08:33:14 -0400
In-Reply-To: <1395059572-16136-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch will primarily implement the parser for the options provided
by the user for set and get rxfh before invoking the ioctl.
This patch also has Ethtool man page changes which describes the Usage of
set and get rxfh options.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 ethtool.8.in |   18 +++--
 ethtool.c    |  253 ++++++++++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 212 insertions(+), 59 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index bb394cc..df5a6ce 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -286,11 +286,12 @@ ethtool \- query or control network driver and hardware settings
 .B ethtool \-T|\-\-show\-time\-stamping
 .I devname
 .HP
-.B ethtool \-x|\-\-show\-rxfh\-indir
+.B ethtool \-x|\-\-show\-rxfh\-indir|\-\-show\-rxfh
 .I devname
 .HP
-.B ethtool \-X|\-\-set\-rxfh\-indir
+.B ethtool \-X|\-\-set\-rxfh\-indir|\-\-rxfh
 .I devname
+.RB [ hkey \ \*(MA:\...]
 .RB [\  equal
 .IR N \ |
 .BI weight\  W0
@@ -784,11 +785,16 @@ Sets the dump flag for the device.
 Show the device's time stamping capabilities and associated PTP
 hardware clock.
 .TP
-.B \-x \-\-show\-rxfh\-indir
-Retrieves the receive flow hash indirection table.
+.B \-x \-\-show\-rxfh\-indir \-\-show\-rxfh
+Retrieves the receive flow hash indirection table and/or RSS hash key.
 .TP
-.B \-X \-\-set\-rxfh\-indir
-Configures the receive flow hash indirection table.
+.B \-X \-\-set\-rxfh\-indir \-\-rxfh
+Configures the receive flow hash indirection table and/or RSS hash key.
+.TP
+.BI hkey
+Sets rss hash key of the specified network device. RSS hash key should be of device supported length.
+Hash key format must be in xx:yy:zz:aa:bb:cc format meaning both the nibbles of a byte should be mentioned
+even if a nibble is zero.
 .TP
 .BI equal\  N
 Sets the receive flow hash indirection table to spread flows evenly
diff --git a/ethtool.c b/ethtool.c
index acb4397..0791451 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -874,6 +874,73 @@ static char *unparse_rxfhashopts(u64 opts)
 	return buf;
 }
 
+static int convert_string_to_hashkey(char *rss_hkey, u32 key_size,
+				     const char *rss_hkey_string)
+{
+	int i = 0;
+	int hex_byte;
+
+	do {
+		if (i > (key_size - 1)) {
+			fprintf(stderr,
+				"Invalid key: Device supports %d bytes key\n",
+				key_size);
+			goto err;
+		}
+
+		if (!(isxdigit(*rss_hkey_string) &&
+		      isxdigit(*(rss_hkey_string + 1)))) {
+			fprintf(stderr, "Invalid RSS Hash Key Format\n");
+			goto err;
+		}
+
+		sscanf(rss_hkey_string, "%2x", &hex_byte);
+		rss_hkey[i++] = hex_byte;
+		rss_hkey_string += 2;
+
+		if (*rss_hkey_string == ':') {
+			rss_hkey_string++;
+		} else if (*rss_hkey_string != '\0') {
+			fprintf(stderr, "Invalid RSS Hash Key Format\n");
+			goto err;
+		}
+
+	} while (*rss_hkey_string);
+
+	if (i != key_size) {
+		fprintf(stderr, "Invalid key: Device supports %d bytes key\n",
+			key_size);
+		goto err;
+	}
+
+	return 0;
+err:
+	exit_bad_args();
+}
+
+static int parse_hkey(char **rss_hkey, u32 key_size,
+		      const char *rss_hkey_string)
+{
+	if (!key_size) {
+		fprintf(stderr,
+			"Cannot set RX flow hash configuration:\n"
+			" Hash key setting not supported\n");
+		exit(1);
+	}
+
+	*rss_hkey = malloc(key_size);
+	if (!(*rss_hkey))
+		return -ENOMEM;
+
+	if (convert_string_to_hashkey(*rss_hkey, key_size,
+				      rss_hkey_string) < 0) {
+		free(*rss_hkey);
+		*rss_hkey = NULL;
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static const struct {
 	const char *name;
 	int (*func)(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
@@ -3035,13 +3102,14 @@ static int do_grxclass(struct cmd_context *ctx)
 	return err ? 1 : 0;
 }
 
-static int do_grxfhindir(struct cmd_context *ctx)
+static int do_grxfh(struct cmd_context *ctx)
 {
 	struct ethtool_rxnfc ring_count;
-	struct ethtool_rxfh_indir indir_head;
-	struct ethtool_rxfh_indir *indir;
-	u32 i;
+	struct ethtool_rxfh rss_head;
+	struct ethtool_rxfh *rss;
+	u32 i, indir_bytes;
 	int err;
+	char *hkey;
 
 	ring_count.cmd = ETHTOOL_GRXRINGS;
 	err = send_ioctl(ctx, &ring_count);
@@ -3050,77 +3118,146 @@ static int do_grxfhindir(struct cmd_context *ctx)
 		return 102;
 	}
 
-	indir_head.cmd = ETHTOOL_GRXFHINDIR;
-	indir_head.size = 0;
-	err = send_ioctl(ctx, &indir_head);
-	if (err < 0) {
-		perror("Cannot get RX flow hash indirection table size");
+	rss_head.cmd = ETHTOOL_GRSSH;
+	rss_head.indir_size = 0;
+	rss_head.key_size = 0;
+	err = send_ioctl(ctx, &rss_head);
+	if ((err < 0) || (!rss_head.indir_size && !rss_head.key_size)) {
+		perror("Cannot get RX flow hash indirection and key size");
 		return 103;
 	}
 
-	indir = malloc(sizeof(*indir) +
-		       indir_head.size * sizeof(*indir->ring_index));
-	indir->cmd = ETHTOOL_GRXFHINDIR;
-	indir->size = indir_head.size;
-	err = send_ioctl(ctx, indir);
+	rss = malloc(sizeof(*rss) +
+		     rss_head.indir_size * sizeof(rss_head.rss_config[0]) +
+		     rss_head.key_size);
+	rss->cmd = ETHTOOL_GRSSH;
+	rss->indir_size = rss_head.indir_size;
+	rss->key_size = rss_head.key_size;
+	err = send_ioctl(ctx, rss);
 	if (err < 0) {
-		perror("Cannot get RX flow hash indirection table");
+		perror("Cannot get RX flow hash configuration");
 		return 103;
 	}
 
 	printf("RX flow hash indirection table for %s with %llu RX ring(s):\n",
 	       ctx->devname, ring_count.data);
-	for (i = 0; i < indir->size; i++) {
+	if (!rss->indir_size)
+		printf("*** Operation Not Supported ***\n");
+
+	for (i = 0; i < rss->indir_size; i++) {
 		if (i % 8 == 0)
 			printf("%5u: ", i);
-		printf(" %5u", indir->ring_index[i]);
+		printf(" %5u", rss->rss_config[i]);
 		if (i % 8 == 7)
 			fputc('\n', stdout);
 	}
+
+	indir_bytes = rss->indir_size * sizeof(rss->rss_config[0]);
+	hkey = ((char *)rss->rss_config + indir_bytes);
+
+	printf("RSS hash key:\n");
+	if (!rss->key_size)
+		printf("*** Operation Not Supported ***\n");
+
+	for (i = 0; i < rss->key_size; i++) {
+		if (i == (rss->key_size - 1))
+			printf("%02x\n", (u8) hkey[i]);
+		else
+			printf("%02x:", (u8) hkey[i]);
+	}
 	return 0;
 }
 
-static int do_srxfhindir(struct cmd_context *ctx)
+
+
+
+static int do_srxfh(struct cmd_context *ctx)
 {
+	struct ethtool_rxfh rss_head;
+	struct ethtool_rxfh *rss;
+	struct ethtool_rxnfc ring_count;
 	int rxfhindir_equal = 0;
 	char **rxfhindir_weight = NULL;
-	struct ethtool_rxfh_indir indir_head;
-	struct ethtool_rxfh_indir *indir;
-	u32 i;
+	char *rss_hkey = NULL;
 	int err;
+	u32 i, arg_num = 0, indir_bytes = 0;
+	u32 entry_size = sizeof(rss_head.rss_config[0]);
+	u8 parse_indir = 1;
 
 	if (ctx->argc < 2)
 		exit_bad_args();
-	if (!strcmp(ctx->argp[0], "equal")) {
-		if (ctx->argc != 2)
-			exit_bad_args();
-		rxfhindir_equal = get_int_range(ctx->argp[1], 0, 1, INT_MAX);
-	} else if (!strcmp(ctx->argp[0], "weight")) {
-		rxfhindir_weight = ctx->argp + 1;
-	} else {
-		exit_bad_args();
+
+	ring_count.cmd = ETHTOOL_GRXRINGS;
+	err = send_ioctl(ctx, &ring_count);
+	if (err < 0) {
+		perror("Cannot get RX ring count");
+		return 102;
 	}
 
-	indir_head.cmd = ETHTOOL_GRXFHINDIR;
-	indir_head.size = 0;
-	err = send_ioctl(ctx, &indir_head);
+	rss_head.cmd = ETHTOOL_GRSSH;
+	rss_head.indir_size = 0;
+	rss_head.key_size = 0;
+	err = send_ioctl(ctx, &rss_head);
 	if (err < 0) {
-		perror("Cannot get RX flow hash indirection table size");
-		return 104;
+		perror("Cannot get RX flow hash indirection and key size");
+		return 103;
 	}
 
-	indir = malloc(sizeof(*indir) +
-		       indir_head.size * sizeof(*indir->ring_index));
-	indir->cmd = ETHTOOL_SRXFHINDIR;
-	indir->size = indir_head.size;
+	if (!strcmp(ctx->argp[0], "hkey")) {
+		err = parse_hkey(&rss_hkey, rss_head.key_size,
+				 ctx->argp[1]);
+		if (err < 0)
+			return err;
+
+		arg_num = 2;
+		if (!ctx->argp[arg_num])
+			parse_indir = 0;
+	}
 
+	if (parse_indir) {
+		if (!strcmp(ctx->argp[arg_num], "equal"))
+			rxfhindir_equal = get_int_range(ctx->argp[arg_num + 1],
+							0, 1, INT_MAX);
+		else if (!strcmp(ctx->argp[arg_num], "weight"))
+			rxfhindir_weight = ctx->argp + arg_num + 1;
+		else
+			exit_bad_args();
+
+		indir_bytes = rss_head.indir_size * entry_size;
+	}
+
+	rss = malloc(sizeof(*rss) + indir_bytes + rss_head.key_size);
+	rss->cmd = ETHTOOL_SRSSH;
+	rss->indir_size = rss_head.indir_size;
+	rss->key_size = rss_head.key_size;
+
+	/*
+	 * indir_size = 0 ==> reset indir to default
+	 * indir_size = 0xDEADBEEF ==> ignore indir
+	 */
 	if (rxfhindir_equal) {
-		for (i = 0; i < indir->size; i++)
-			indir->ring_index[i] = i % rxfhindir_equal;
-	} else {
+		for (i = 0; i < rss->indir_size; i++)
+			rss->rss_config[i] = i % rxfhindir_equal;
+		arg_num += 2;
+		if (ctx->argp[arg_num] &&
+		    !strcmp(ctx->argp[arg_num], "hkey")) {
+			err = parse_hkey(&rss_hkey, rss_head.key_size,
+					 ctx->argp[arg_num + 1]);
+			if (err < 0)
+				return err;
+		}
+	} else if (rxfhindir_weight) {
 		u32 j, weight, sum = 0, partial = 0;
 
 		for (j = 0; rxfhindir_weight[j]; j++) {
+			if (!strcmp(rxfhindir_weight[j], "hkey")) {
+				err = parse_hkey(&rss_hkey,
+						 rss_head.key_size,
+						 rxfhindir_weight[++j]);
+				if (err < 0)
+					return err;
+				break;
+			}
 			weight = get_u32(rxfhindir_weight[j], 0);
 			sum += weight;
 		}
@@ -3131,7 +3268,7 @@ static int do_srxfhindir(struct cmd_context *ctx)
 			exit(1);
 		}
 
-		if (sum > indir->size) {
+		if (sum > rss->indir_size) {
 			fprintf(stderr,
 				"Total weight exceeds the size of the "
 				"indirection table\n");
@@ -3139,22 +3276,31 @@ static int do_srxfhindir(struct cmd_context *ctx)
 		}
 
 		j = -1;
-		for (i = 0; i < indir->size; i++) {
-			while (i >= indir->size * partial / sum) {
+		for (i = 0; i < rss->indir_size; i++) {
+			while (i >= rss->indir_size * partial / sum) {
 				j += 1;
 				weight = get_u32(rxfhindir_weight[j], 0);
 				partial += weight;
 			}
-			indir->ring_index[i] = j;
+			rss->rss_config[i] = j;
 		}
+	} else {
+		rss->indir_size = 0xDEADBEEF;
 	}
 
-	err = send_ioctl(ctx, indir);
+	if (rss_hkey) {
+		memcpy((char *)rss->rss_config + indir_bytes,
+		       rss_hkey, rss->key_size);
+		free(rss_hkey);
+	} else {
+		rss->key_size = 0;
+	}
+
+	err = send_ioctl(ctx, rss);
 	if (err < 0) {
-		perror("Cannot set RX flow hash indirection table");
+		perror("Cannot set RX flow hash configuration");
 		return 105;
 	}
-
 	return 0;
 }
 
@@ -3833,11 +3979,12 @@ static const struct option {
 	  "		delete %d\n" },
 	{ "-T|--show-time-stamping", 1, do_tsinfo,
 	  "Show time stamping capabilities" },
-	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
-	  "Show Rx flow hash indirection" },
-	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
-	  "Set Rx flow hash indirection",
-	  "		equal N | weight W0 W1 ...\n" },
+	{ "-x|--show-rxfh-indir|--show-rxfh", 1, do_grxfh,
+	  "Show Rx flow hash indirection and/or hashkey" },
+	{ "-X|--set-rxfh-indir|--rxfh", 1, do_srxfh,
+	  "Set Rx flow hash indirection and/or hashkey",
+	  "		equal N | weight W0 W1 ...\n"
+	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n" },
 	{ "-f|--flash", 1, do_flash,
 	  "Flash firmware image from the specified file to a region on the device",
 	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-- 
1.7.1
