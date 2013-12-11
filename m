From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: [PATCH] ethtool: Add option '-q' to display adjacent switch port's attributes
Date: Wed, 11 Dec 2013 14:32:28 +0100
Message-ID: <1386768748-57530-2-git-send-email-raspl@linux.vnet.ibm.com>
References: <1386768748-57530-1-git-send-email-raspl@linux.vnet.ibm.com>
Cc: davem@davemloft.net, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:41737 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874Ab3LKNek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 08:34:40 -0500
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 13:34:37 -0000
In-Reply-To: <1386768748-57530-1-git-send-email-raspl@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new option '-q|--query-switch-port' to display information on the
adjacent switch port's settings as perceived by the respective NIC.
In the output,
  - unsupported attributes are indicated as such ('unsupported'),
  - supported but disabled attributes display 'no', and
  - enabled attributes display 'yes'.
Attributes supported by this patch are
  - forwarding modes:
    standard (802.1) and reflective relay (RR) aka hairpin
  - edge virtual bridging (EVB) related capabilities:
    edge control protocol (ECP), VSI discovery and configuration protocol (VDP),
    and retransmission timer exponent (RTE).

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
---
 ethtool-copy.h | 35 ++++++++++++++++++++++++++++++
 ethtool.8.in   |  6 ++++++
 ethtool.c      | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 109 insertions(+)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index b5515c2..7028bf6 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -348,6 +348,22 @@ struct ethtool_pauseparam {
 	__u32	tx_pause;
 };
 
+/**
+ * struct ethtool_swport_attrs - query adjacent switch port attributes
+ * @cmd: ETHTOOL_GPORT
+ * @port_rc: Use GPORT_RC_* as appropriate.
+ * @supported: Forwarding modes and capabilities supported by the switch port,
+ *	see SUPPORTED_SP_* flags.
+ * @enabled: Forwarding modes and capabilities currently activated at the
+ *           adjacent switch port, see ENABLED_SP_* flags.
+ */
+struct ethtool_swport_attrs {
+	__u32	cmd;
+	__u32   port_rc;
+	__u32	supported;
+	__u32	enabled;
+};
+
 #define ETH_GSTRING_LEN		32
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -900,6 +916,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GMODULEEEPROM	0x00000043 /* Get plug-in module eeprom */
 #define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
 #define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
+#define ETHTOOL_GPORT		0x00000046 /* Get switch port attributes */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1067,6 +1084,24 @@ enum ethtool_sfeatures_retval_bits {
 #define ETH_MODULE_SFF_8472		0x2
 #define ETH_MODULE_SFF_8472_LEN		512
 
+/* Bad return codes for switch ports */
+#define GPORT_RC_LLDP_UNSUP    1	/* switch port doesn't support */
+					/* required LLDP EVB TLV       */
+
+/* Indicates what features the adjacent switch port supports. */
+#define SUPPORTED_SP_FWD_802_1	(1 << 0)
+#define SUPPORTED_SP_FWD_RR	(1 << 1)
+#define SUPPORTED_SP_CAP_RTE	(1 << 9)
+#define SUPPORTED_SP_CAP_ECP	(1 << 10)
+#define SUPPORTED_SP_CAP_VDP	(1 << 11)
+
+/* Indicates what features the adjacent switch port has enabled. */
+#define ENABLED_SP_FWD_802_1	(1 << 0)
+#define ENABLED_SP_FWD_RR	(1 << 1)
+#define ENABLED_SP_CAP_RTE	(1 << 9)
+#define ENABLED_SP_CAP_ECP	(1 << 10)
+#define ENABLED_SP_CAP_VDP	(1 << 11)
+
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
  * were actually reset.  On successful return, the flags indicate the
diff --git a/ethtool.8.in b/ethtool.8.in
index f587ec8..ffc0225 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -214,6 +214,9 @@ ethtool \- query or control network driver and hardware settings
 .B ethtool \-P|\-\-show\-permaddr
 .I devname
 .HP
+.B ethtool \-q|\-\-query-switch-port
+.I devname
+.HP
 .B ethtool \-r|\-\-negotiate
 .I devname
 .HP
@@ -483,6 +486,9 @@ Length of time to perform phys-id, in seconds.
 .B \-P \-\-show\-permaddr
 Queries the specified network device for permanent hardware address.
 .TP
+.B \-q \-\-query-switch-port
+Queries the specified Ethernet device for adjacent switch port's attributes.
+.TP
 .B \-r \-\-negotiate
 Restarts auto-negotiation on the specified Ethernet device, if
 auto-negotiation is enabled.
diff --git a/ethtool.c b/ethtool.c
index b06dfa3..3906f20 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -714,6 +714,54 @@ static int dump_drvinfo(struct ethtool_drvinfo *info)
 	return 0;
 }
 
+static const char *port_setting(struct ethtool_swport_attrs *attrs,
+				 u32 supported, u32 enabled)
+{
+	char *rc = "unsupported";
+
+	if (supported & attrs->supported) {
+		if (enabled & attrs->enabled)
+			rc = "yes";
+		else
+			rc = "no";
+	}
+
+	return rc;
+}
+
+static int dump_switch_port_attrs(const char *devname,
+					struct ethtool_swport_attrs *attrs)
+{
+	static const struct {
+		const char *name;
+		int type; /* 0=forwarding, 1=capability */
+		u32 supported;
+		u32 enabled;
+	} port_defs[] = {
+		{ "802.1", 0, SUPPORTED_SP_FWD_802_1, ENABLED_SP_FWD_802_1 },
+		{ "RR", 0, SUPPORTED_SP_FWD_RR, ENABLED_SP_FWD_RR },
+		{ "RTE", 1, SUPPORTED_SP_CAP_RTE, ENABLED_SP_CAP_RTE },
+		{ "ECP", 1, SUPPORTED_SP_CAP_ECP, ENABLED_SP_CAP_ECP },
+		{ "VDP", 1, SUPPORTED_SP_CAP_VDP, ENABLED_SP_CAP_VDP },
+	};
+	int i;
+
+	if (attrs->port_rc == GPORT_RC_LLDP_UNSUP) {
+		fprintf(stderr, "Required LLDP EVB TLV not supported by "
+			"adjacent switch\n");
+		return 1;
+	}
+	fprintf(stdout, "Adjacent switch port attributes of %s:\n",
+		devname);
+	for (i = 0; i < ARRAY_SIZE(port_defs); i++)
+		fprintf(stdout, "%s %s: %s\n", port_defs[i].name,
+			(port_defs[i].type ? "capability" : "forwarding"),
+			port_setting(attrs, port_defs[i].supported,
+			port_defs[i].enabled));
+
+	return 0;
+}
+
 static int parse_wolopts(char *optstr, u32 *data)
 {
 	*data = 0;
@@ -2863,6 +2911,24 @@ static int do_phys_id(struct cmd_context *ctx)
 	return err;
 }
 
+static int do_switch_port(struct cmd_context *ctx)
+{
+	struct ethtool_swport_attrs attrs;
+	int err;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	attrs.cmd = ETHTOOL_GPORT;
+	err = send_ioctl(ctx, &attrs);
+	if (err < 0) {
+		perror("Cannot get driver information");
+		return 1;
+	}
+
+	return dump_switch_port_attrs(ctx->devname, &attrs);
+}
+
 static int do_gstats(struct cmd_context *ctx)
 {
 	struct ethtool_gstrings *strings;
@@ -3799,6 +3865,8 @@ static const struct option {
 	{ "-p|--identify", 1, do_phys_id,
 	  "Show visible port identification (e.g. blinking)",
 	  "               [ TIME-IN-SECONDS ]\n" },
+	{ "-q|--query-switch-port", 1, do_switch_port, "Query adjacent "
+	  "switch port attributes" },
 	{ "-t|--test", 1, do_test, "Execute adapter self test",
 	  "               [ online | offline | external_lb ]\n" },
 	{ "-S|--statistics", 1, do_gstats, "Show adapter statistics" },
-- 
1.8.3.4
