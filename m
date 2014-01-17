From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: [PATCH 2/4 ethtool] ethtool: Support for configurable RSS hash key.
Date: Fri, 17 Jan 2014 13:02:38 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8D4@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:7143 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbaAQNCk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 08:02:40 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch will primarily implement the parser for the options provided by the user for set and get hashkey before invoking the ioctl.
This patch also has Ethtool man page changes which describes the Usage of set and get hashkey options.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 ethtool.8.in |   17 ++++++++
 ethtool.c    |  130 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 147 insertions(+), 0 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in index f587ec8..a228bf7 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -275,6 +275,13 @@ ethtool \- query or control network driver and hardware settings  .br  .BI delete \ N  .HP
+.B ethtool \-\-show\-hashkey
+.I devname
+.HP
+.B ethtool \-\-hashkey
+.I devname
+.RB [ hkey \ \*(MA:\...]
+.HP
 .B ethtool \-w|\-\-get\-dump
 .I devname
 .RB [ data
@@ -762,6 +769,16 @@ of the rule ordering process.
 .BI delete \ N
 Deletes the RX classification rule with the given ID.
 .TP
+.B \-\-show\-hashkey
+Gets  the configured rss hashkey of the specified network device.
+.TP
+.B \-\-hashkey hkey
+Changes rss hash key of the specified network device. RSS hash key should be of device supported length.
+40 bytes for IPv6.
+16 bytes for IPv4.
+Hash key format must be in xx:yy:zz:aa:bb:cc format meaning both the 
+nibbles of a byte should be mentioned even if a nibble is zero.
+.TP
 .B \-w \-\-get\-dump
 Retrieves and prints firmware dump for the specified network device.
 By default, it prints out the dump flag, version and length of the dump data.
diff --git a/ethtool.c b/ethtool.c
index b06dfa3..4b05b0c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -471,6 +471,59 @@ static int rxflow_str_to_type(const char *str)
 	return flow_type;
 }
 
+static inline int is_hkey_char_valid(const char rss_hkey_string) {
+	/* Are there any invalid characters in the string */
+	return ((rss_hkey_string >= '0' && rss_hkey_string <= '9') ||
+	       (rss_hkey_string >= 'a' && rss_hkey_string <= 'f') ||
+	       (rss_hkey_string >= 'A' && rss_hkey_string <= 'F')); }
+
+static int convert_string_to_hashkey(struct ethtool_rss_hkey *rss_hkey,
+				      const char *rss_hkey_string)
+{
+	int i = 0;
+	int hex_byte;
+
+	do {
+		if (i > (RSS_HASH_KEY_LEN - 1)) {
+			fprintf(stderr,
+				"Invalid key: Device supports %d bytes key\n",
+				rss_hkey->data_len);
+			goto err;
+		}
+
+		if (!(is_hkey_char_valid(*rss_hkey_string) &&
+		      is_hkey_char_valid(*(rss_hkey_string + 1)))) {
+			fprintf(stderr, "Invalid RSS Hash Key Format\n");
+			goto err;
+		}
+
+		sscanf(rss_hkey_string, "%2x", &hex_byte);
+		rss_hkey->data[i++] = hex_byte;
+
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
+	if (i != rss_hkey->data_len) {
+		fprintf(stderr, "Invalid key: Device supports %d bytes key\n",
+			rss_hkey->data_len);
+		goto err;
+	}
+
+	return 0;
+err:
+	exit_bad_args();
+}
+
 static int do_version(struct cmd_context *ctx)  {
 	fprintf(stdout,
@@ -2863,6 +2916,80 @@ static int do_phys_id(struct cmd_context *ctx)
 	return err;
 }
 
+static int get_hashkey(struct cmd_context *ctx) {
+	struct ethtool_rss_hkey *rss_hkey;
+	int rc;
+	int i;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	rss_hkey = calloc(1, sizeof(struct ethtool_rss_hkey));
+	if (!rss_hkey) {
+		perror("Cannot allocate enough memory for get hashkey data");
+		return -ENOMEM;
+	}
+
+	rss_hkey->cmd = ETHTOOL_GET_RSS_HKEY;
+
+	rc = send_ioctl(ctx, rss_hkey);
+	if (rc < 0) {
+		perror("Cannot get hash key");
+		goto done;
+	}
+
+	for (i = 0; i < RSS_HASH_KEY_LEN; i++) {
+		if (i == (RSS_HASH_KEY_LEN - 1))
+			printf("%02x\n", rss_hkey->data[i]);
+		else
+			printf("%02x:", rss_hkey->data[i]);
+	}
+
+done:
+	free(rss_hkey);
+	return rc;
+}
+
+static int set_hashkey(struct cmd_context *ctx) {
+	struct ethtool_rss_hkey *rss_hkey;
+	int err;
+
+	if (ctx->argc != 2)
+		exit_bad_args();
+
+	if (strcmp(ctx->argp[0], "hkey"))
+		exit_bad_args();
+
+	rss_hkey = calloc(1, sizeof(struct ethtool_rss_hkey));
+	if (!rss_hkey) {
+		perror("Cannot allocate enough memory for rss hkey data");
+		return -ENOMEM;
+	}
+	rss_hkey->cmd = ETHTOOL_GET_RSS_HKEY;
+
+	err = send_ioctl(ctx, rss_hkey);
+	if (err < 0) {
+		perror("Cannot get rss hash key");
+		goto done;
+	}
+
+	if (convert_string_to_hashkey(rss_hkey, ctx->argp[1]) < 0) {
+		err = -EINVAL;
+		goto done;
+	}
+
+	rss_hkey->cmd = ETHTOOL_SET_RSS_HKEY;
+
+	err = send_ioctl(ctx, rss_hkey);
+	if (err < 0)
+		perror("Cannot set rss hash key");
+done:
+	free(rss_hkey);
+	return err;
+}
+
 static int do_gstats(struct cmd_context *ctx)  {
 	struct ethtool_gstrings *strings;
@@ -3829,6 +3956,9 @@ static const struct option {
 	  "			[ action %d ]\n"
 	  "			[ loc %d]] |\n"
 	  "		delete %d\n" },
+	{ "--show-hashkey", 1, get_hashkey, "Show RSS hash key " },
+	{ "--hashkey", 1, set_hashkey, "Set RSS hash key",
+	  "		[ hkey %x:%x:%x:%x:%x:....:%x]\n" },
 	{ "-T|--show-time-stamping", 1, do_tsinfo,
 	  "Show time stamping capabilities" },
 	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
--
1.7.1
