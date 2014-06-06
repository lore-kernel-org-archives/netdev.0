From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v6 ethtool 2/2] ethtool: Support for configurable RSS hash key
Date: Fri, 6 Jun 2014 21:21:28 +0530
Message-ID: <8f08e0df-1ab6-4dc6-b331-ee1bf820593b@CMEXHTCAS2.ad.emulex.com>
References: <1402069888-13302-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:14162 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666AbaFFPxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 11:53:10 -0400
In-Reply-To: <1402069888-13302-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch will primarily implement the parser for the options provided
by the user for set and get rxfh before invoking the ioctl.
This patch also has Ethtool man page changes which describes the Usage of
set and get rxfh options.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 ethtool.8.in |   18 ++-
 ethtool.c    |  390 ++++++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 340 insertions(+), 68 deletions(-)

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
index 8e968a8..f463e10 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -878,6 +878,72 @@ static char *unparse_rxfhashopts(u64 opts)
 	return buf;
 }
 
+static int convert_string_to_hashkey(char *rss_hkey, u32 key_size,
+				     const char *rss_hkey_string)
+{
+	u32 i = 0;
+	int hex_byte, len;
+
+	do {
+		if (i > (key_size - 1)) {
+			fprintf(stderr,
+				"Invalid key: Key is too long\n");
+			goto err;
+		}
+
+		if (sscanf(rss_hkey_string, "%2x%n", &hex_byte, &len) < 1 ||
+		    len != 2) {
+			fprintf(stderr, "Invalid rss hash key format\n");
+			goto err;
+		}
+
+		rss_hkey[i++] = hex_byte;
+		rss_hkey_string += 2;
+
+		if (*rss_hkey_string == ':') {
+			rss_hkey_string++;
+		} else if (*rss_hkey_string != '\0') {
+			fprintf(stderr, "Invalid rss hash key format\n");
+			goto err;
+		}
+
+	} while (*rss_hkey_string);
+
+	if (i != key_size) {
+		fprintf(stderr, "Invalid key: Key is too short\n");
+		goto err;
+	}
+
+	return 0;
+err:
+	return -EINVAL;
+}
+
+static int parse_hkey(char **rss_hkey, u32 key_size,
+		      const char *rss_hkey_string)
+{
+	if (!key_size) {
+		fprintf(stderr,
+			"Cannot set RX flow hash configuration:\n"
+			" Hash key setting not supported\n");
+		return -EINVAL;
+	}
+
+	*rss_hkey = malloc(key_size);
+	if (!(*rss_hkey)) {
+		perror("Cannot allocate memory for rss hash key");
+		return -ENOMEM;
+	}
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
@@ -3041,92 +3107,141 @@ static int do_grxclass(struct cmd_context *ctx)
 	return err ? 1 : 0;
 }
 
-static int do_grxfhindir(struct cmd_context *ctx)
+static void print_indir_table(struct cmd_context *ctx,
+			      struct ethtool_rxnfc *ring_count,
+			      u32 indir_size, u32 *indir)
 {
-	struct ethtool_rxnfc ring_count;
-	struct ethtool_rxfh_indir indir_head;
-	struct ethtool_rxfh_indir *indir;
 	u32 i;
-	int err;
 
-	ring_count.cmd = ETHTOOL_GRXRINGS;
-	err = send_ioctl(ctx, &ring_count);
-	if (err < 0) {
-		perror("Cannot get RX ring count");
-		return 102;
+	printf("RX flow hash indirection table for %s with %llu RX ring(s):\n",
+	       ctx->devname, ring_count->data);
+
+	if (!indir_size)
+		perror("Operation not supported\n");
+
+	for (i = 0; i < indir_size; i++) {
+		if (i % 8 == 0)
+			printf("%5u: ", i);
+		printf(" %5u", indir[i]);
+		if (i % 8 == 7)
+			fputc('\n', stdout);
 	}
+}
+
+static int do_grxfhindir(struct cmd_context *ctx,
+			 struct ethtool_rxnfc *ring_count)
+{
+	struct ethtool_rxfh_indir indir_head;
+	struct ethtool_rxfh_indir *indir;
+	int err;
 
 	indir_head.cmd = ETHTOOL_GRXFHINDIR;
 	indir_head.size = 0;
 	err = send_ioctl(ctx, &indir_head);
 	if (err < 0) {
-		perror("Cannot get RX flow hash indirection table size");
+		perror("Cannot get RX flow hash indirection table size\n");
 		return 103;
 	}
 
 	indir = malloc(sizeof(*indir) +
 		       indir_head.size * sizeof(*indir->ring_index));
+	if (!indir) {
+		perror("Cannot allocate memory for indirection table\n");
+		return 104;
+	}
+
 	indir->cmd = ETHTOOL_GRXFHINDIR;
 	indir->size = indir_head.size;
 	err = send_ioctl(ctx, indir);
 	if (err < 0) {
 		perror("Cannot get RX flow hash indirection table");
-		return 103;
+		free(indir);
+		return 105;
 	}
 
-	printf("RX flow hash indirection table for %s with %llu RX ring(s):\n",
-	       ctx->devname, ring_count.data);
-	for (i = 0; i < indir->size; i++) {
-		if (i % 8 == 0)
-			printf("%5u: ", i);
-		printf(" %5u", indir->ring_index[i]);
-		if (i % 8 == 7)
-			fputc('\n', stdout);
-	}
+	print_indir_table(ctx, ring_count, indir->size, indir->ring_index);
+
+	free(indir);
 	return 0;
 }
 
-static int do_srxfhindir(struct cmd_context *ctx)
+static int do_grxfh(struct cmd_context *ctx)
 {
-	int rxfhindir_equal = 0;
-	char **rxfhindir_weight = NULL;
-	struct ethtool_rxfh_indir indir_head;
-	struct ethtool_rxfh_indir *indir;
-	u32 i;
+	struct ethtool_rxfh rss_head = {0};
+	struct ethtool_rxnfc ring_count;
+	struct ethtool_rxfh *rss;
+	u32 i, indir_bytes;
+	char *hkey;
 	int err;
 
-	if (ctx->argc < 2)
-		exit_bad_args();
-	if (!strcmp(ctx->argp[0], "equal")) {
-		if (ctx->argc != 2)
-			exit_bad_args();
-		rxfhindir_equal = get_int_range(ctx->argp[1], 0, 1, INT_MAX);
-	} else if (!strcmp(ctx->argp[0], "weight")) {
-		rxfhindir_weight = ctx->argp + 1;
-	} else {
-		exit_bad_args();
+	ring_count.cmd = ETHTOOL_GRXRINGS;
+	err = send_ioctl(ctx, &ring_count);
+	if (err < 0) {
+		perror("Cannot get RX ring count");
+		return 102;
 	}
 
-	indir_head.cmd = ETHTOOL_GRXFHINDIR;
-	indir_head.size = 0;
-	err = send_ioctl(ctx, &indir_head);
-	if (err < 0) {
-		perror("Cannot get RX flow hash indirection table size");
+	rss_head.cmd = ETHTOOL_GRSSH;
+	err = send_ioctl(ctx, &rss_head);
+	if (errno == EOPNOTSUPP) {
+		return do_grxfhindir(ctx, &ring_count);
+	} else if (err < 0) {
+		perror("Cannot get RX flow hash indir size and/or key size");
+		return 103;
+	}
+
+	rss = calloc(1, sizeof(*rss) +
+			rss_head.indir_size * sizeof(rss_head.rss_config[0]) +
+			rss_head.key_size);
+	if (!rss) {
+		perror("Cannot allocate memory for RX flow hash config\n");
 		return 104;
 	}
 
-	indir = malloc(sizeof(*indir) +
-		       indir_head.size * sizeof(*indir->ring_index));
-	indir->cmd = ETHTOOL_SRXFHINDIR;
-	indir->size = indir_head.size;
+	rss->cmd = ETHTOOL_GRSSH;
+	rss->indir_size = rss_head.indir_size;
+	rss->key_size = rss_head.key_size;
+	err = send_ioctl(ctx, rss);
+	if (err < 0) {
+		perror("Cannot get RX flow hash configuration");
+		free(rss);
+		return 105;
+	}
+
+	print_indir_table(ctx, &ring_count, rss->indir_size, rss->rss_config);
 
+	indir_bytes = rss->indir_size * sizeof(rss->rss_config[0]);
+	hkey = ((char *)rss->rss_config + indir_bytes);
+
+	printf("RSS hash key:\n");
+	if (!rss->key_size)
+		printf("Operation not supported\n");
+
+	for (i = 0; i < rss->key_size; i++) {
+		if (i == (rss->key_size - 1))
+			printf("%02x\n", (u8) hkey[i]);
+		else
+			printf("%02x:", (u8) hkey[i]);
+	}
+
+	free(rss);
+	return 0;
+}
+
+static int fill_indir_table(u32 *indir_size, u32 *indir, int rxfhindir_equal,
+			    char **rxfhindir_weight, u32 num_weights)
+{
+	u32 i;
+	/*
+	 * "*indir_size == 0" ==> reset indir to default
+	 */
 	if (rxfhindir_equal) {
-		for (i = 0; i < indir->size; i++)
-			indir->ring_index[i] = i % rxfhindir_equal;
-	} else {
+		for (i = 0; i < *indir_size; i++)
+			indir[i] = i % rxfhindir_equal;
+	} else if (rxfhindir_weight) {
 		u32 j, weight, sum = 0, partial = 0;
 
-		for (j = 0; rxfhindir_weight[j]; j++) {
+		for (j = 0; j < num_weights; j++) {
 			weight = get_u32(rxfhindir_weight[j], 0);
 			sum += weight;
 		}
@@ -3134,36 +3249,186 @@ static int do_srxfhindir(struct cmd_context *ctx)
 		if (sum == 0) {
 			fprintf(stderr,
 				"At least one weight must be non-zero\n");
-			exit(1);
+			return -EINVAL;
 		}
 
-		if (sum > indir->size) {
+		if (sum > *indir_size) {
 			fprintf(stderr,
 				"Total weight exceeds the size of the "
 				"indirection table\n");
-			exit(1);
+			return -EINVAL;
 		}
 
 		j = -1;
-		for (i = 0; i < indir->size; i++) {
-			while (i >= indir->size * partial / sum) {
+		for (i = 0; i < *indir_size; i++) {
+			while (i >= (*indir_size) * partial / sum) {
 				j += 1;
 				weight = get_u32(rxfhindir_weight[j], 0);
 				partial += weight;
 			}
-			indir->ring_index[i] = j;
+			indir[i] = j;
 		}
+	} else {
+		*indir_size = ETH_RXFH_INDIR_NO_CHANGE;
+	}
+
+	return 0;
+}
+
+static int do_srxfhindir(struct cmd_context *ctx, int rxfhindir_equal,
+			 char **rxfhindir_weight, u32 num_weights)
+{
+	struct ethtool_rxfh_indir indir_head;
+	struct ethtool_rxfh_indir *indir;
+	int err;
+
+	indir_head.cmd = ETHTOOL_GRXFHINDIR;
+	indir_head.size = 0;
+	err = send_ioctl(ctx, &indir_head);
+	if (err < 0) {
+		perror("Cannot get RX flow hash indirection table size");
+		return 104;
+	}
+
+	indir = malloc(sizeof(*indir) +
+		       indir_head.size * sizeof(*indir->ring_index));
+
+	if (!indir) {
+		perror("Cannot allocate memory for indirection table\n");
+		return 105;
+	}
+
+	indir->cmd = ETHTOOL_SRXFHINDIR;
+	indir->size = indir_head.size;
+
+	if (fill_indir_table(&indir->size, indir->ring_index, rxfhindir_equal,
+			     rxfhindir_weight, num_weights) < 0) {
+		free(indir);
+		return 106;
 	}
 
 	err = send_ioctl(ctx, indir);
 	if (err < 0) {
 		perror("Cannot set RX flow hash indirection table");
-		return 105;
+		free(indir);
+		return 107;
 	}
 
+	free(indir);
 	return 0;
 }
 
+static int do_srxfh(struct cmd_context *ctx)
+{
+	struct ethtool_rxfh rss_head = {0};
+	struct ethtool_rxfh *rss;
+	struct ethtool_rxnfc ring_count;
+	int rxfhindir_equal = 0;
+	char **rxfhindir_weight = NULL;
+	char *rxfhindir_key = NULL;
+	char *hkey = NULL;
+	int err = 0;
+	u32 arg_num = 0, indir_bytes = 0;
+	u32 entry_size = sizeof(rss_head.rss_config[0]);
+	u32 num_weights = 0;
+
+	if (ctx->argc < 2)
+		exit_bad_args();
+
+	while (arg_num < ctx->argc) {
+		if (!strcmp(ctx->argp[arg_num], "equal")) {
+			++arg_num;
+			rxfhindir_equal = get_int_range(ctx->argp[arg_num],
+							0, 1, INT_MAX);
+			++arg_num;
+		} else if (!strcmp(ctx->argp[arg_num], "weight")) {
+			++arg_num;
+			rxfhindir_weight = ctx->argp + arg_num;
+			while (arg_num < ctx->argc &&
+			       isdigit((unsigned char)ctx->argp[arg_num][0])) {
+				++arg_num;
+				++num_weights;
+			}
+			if (!num_weights)
+				exit_bad_args();
+		} else if (!strcmp(ctx->argp[arg_num], "hkey")) {
+			++arg_num;
+			rxfhindir_key = ctx->argp[arg_num];
+			if (!rxfhindir_key)
+				exit_bad_args();
+			++arg_num;
+		} else {
+			exit_bad_args();
+		}
+	}
+
+	if (rxfhindir_equal && rxfhindir_weight) {
+		printf("Equal and weight options are mutually exclusive\n");
+		return 101;
+	}
+
+	ring_count.cmd = ETHTOOL_GRXRINGS;
+	err = send_ioctl(ctx, &ring_count);
+	if (err < 0) {
+		perror("Cannot get RX ring count");
+		return 102;
+	}
+
+	rss_head.cmd = ETHTOOL_GRSSH;
+	err = send_ioctl(ctx, &rss_head);
+	if (errno == EOPNOTSUPP && !rxfhindir_key) {
+		return do_srxfhindir(ctx, rxfhindir_equal, rxfhindir_weight,
+				     num_weights);
+	} else if (err < 0) {
+		perror("Cannot get RX flow hash indir size and key size");
+		return 103;
+	}
+
+	if (rxfhindir_key) {
+		err = parse_hkey(&hkey, rss_head.key_size,
+				 rxfhindir_key);
+		if (err < 0)
+			return err;
+	}
+
+	if (rxfhindir_equal || rxfhindir_weight)
+		indir_bytes = rss_head.indir_size * entry_size;
+
+	rss = calloc(1, sizeof(*rss) + indir_bytes + rss_head.key_size);
+	if (!rss) {
+		perror("Cannot allocate memory for RX flow hash config\n");
+		return 104;
+	}
+	rss->cmd = ETHTOOL_SRSSH;
+	rss->indir_size = rss_head.indir_size;
+	rss->key_size = rss_head.key_size;
+
+	if (fill_indir_table(&rss->indir_size, rss->rss_config, rxfhindir_equal,
+			     rxfhindir_weight, num_weights) < 0) {
+		err = 105;
+		goto free;
+	}
+
+	if (hkey)
+		memcpy((char *)rss->rss_config + indir_bytes,
+		       hkey, rss->key_size);
+	else
+		rss->key_size = 0;
+
+	err = send_ioctl(ctx, rss);
+	if (err < 0) {
+		perror("Cannot set RX flow hash configuration");
+		err = 106;
+	}
+
+free:
+	if (hkey)
+		free(hkey);
+
+	free(rss);
+	return err;
+}
+
 static int do_flash(struct cmd_context *ctx)
 {
 	char *flash_file;
@@ -3841,11 +4106,12 @@ static const struct option {
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
+	  "		[ equal N | weight W0 W1 ... ]\n"
+	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n" },
 	{ "-f|--flash", 1, do_flash,
 	  "Flash firmware image from the specified file to a region on the device",
 	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-- 
1.7.1
