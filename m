From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 3/7] ethtool: Fix RX n-tuple masks and documentation
Date: Thu, 23 Sep 2010 22:48:52 +0100
Message-ID: <1285278532.7794.30.camel@achroite.uk.solarflarecom.com>
References: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54589 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039Ab0IWVsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:48:55 -0400
In-Reply-To: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For fields with unspecified values, explicitly mask all bits.  Do not
allow specifying a mask without a value.

Change usage information to clarify which parameters are optional or
required.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8 |   31 ++++++++--------
 ethtool.c |  115 +++++++++++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 105 insertions(+), 41 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index 3ca403c..295caab 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -235,34 +235,33 @@ ethtool \- Display or change ethernet card settings
 
 .B ethtool \-U|\-\-config\-ntuple
 .I ethX
-.RB [ flow-type
-.RB tcp4|udp4|sctp4 ]
+.A3 flow-type tcp4 udp4 sctp4
 .RB [ src-ip
-.IR addr ]
+.IR addr
 .RB [ src-ip-mask
-.IR mask ]
+.IR mask ]]
 .RB [ dst-ip
-.IR addr ]
+.IR addr
 .RB [ dst-ip-mask
-.IR mask ]
+.IR mask ]]
 .RB [ src-port
-.IR port ]
+.IR port
 .RB [ src-port-mask
-.IR mask ]
+.IR mask ]]
 .RB [ dst-port
-.IR port ]
+.IR port
 .RB [ dst-port-mask
-.IR mask ]
+.IR mask ]]
 .RB [ vlan
-.IR VLAN-tag ]
+.IR VLAN-tag
 .RB [ vlan-mask
-.IR mask ]
+.IR mask ]]
 .RB [ user-def
-.IR data ]
+.IR data
 .RB [ user-def-mask
-.IR mask ]
-.RB [ action
-.IR queue\ or\ drop ]
+.IR mask ]]
+.RI action \ N
+
 .SH DESCRIPTION
 .BI ethtool
 is used for querying settings of an ethernet device and changing them.
diff --git a/ethtool.c b/ethtool.c
index 8c5d595..6ec1cac 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -99,6 +99,7 @@ static int do_gstats(int fd, struct ifreq *ifr);
 static int rxflow_str_to_type(const char *str);
 static int parse_rxfhashopts(char *optstr, u32 *data);
 static char *unparse_rxfhashopts(u64 opts);
+static void parse_rxntupleopts(int argc, char **argp, int first_arg);
 static int dump_rxfhash(int fhash, u64 val);
 static int do_srxclass(int fd, struct ifreq *ifr);
 static int do_grxclass(int fd, struct ifreq *ifr);
@@ -239,12 +240,14 @@ static struct option {
 		"		equal N | weight W0 W1 ...\n" },
     { "-U", "--config-ntuple", MODE_SNTUPLE, "Configure Rx ntuple filters "
 		"and actions",
-		"               [ flow-type tcp4|udp4|sctp4 src-ip <addr> "
-		"src-ip-mask <mask> dst-ip <addr> dst-ip-mask <mask> "
-		"src-port <port> src-port-mask <mask> dst-port <port> "
-		"dst-port-mask <mask> vlan <VLAN tag> vlan-mask <mask> "
-		"user-def <data> user-def-mask <mask> "
-		"action <queue or drop>\n" },
+		"		flow-type tcp4|udp4|sctp4\n"
+		"		[ src-ip ADDR [src-ip-mask MASK] ]\n"
+		"		[ dst-ip ADDR [dst-ip-mask MASK] ]\n"
+		"		[ src-port PORT [src-port-mask MASK] ]\n"
+		"		[ dst-port PORT [dst-port-mask MASK] ]\n"
+		"		[ vlan VLAN-TAG [vlan-mask MASK] ]\n"
+		"		[ user-def DATA [user-def-mask MASK] ]\n"
+		"		action N\n" },
     { "-u", "--show-ntuple", MODE_GNTUPLE,
 		"Get Rx ntuple filters and actions\n" },
     { "-h", "--help", MODE_HELP, "Show this help" },
@@ -366,6 +369,18 @@ static int rxfhindir_equal = 0;
 static char **rxfhindir_weight = NULL;
 static int sntuple_changed = 0;
 static struct ethtool_rx_ntuple_flow_spec ntuple_fs;
+static int ntuple_ip4src_seen = 0;
+static int ntuple_ip4src_mask_seen = 0;
+static int ntuple_ip4dst_seen = 0;
+static int ntuple_ip4dst_mask_seen = 0;
+static int ntuple_psrc_seen = 0;
+static int ntuple_psrc_mask_seen = 0;
+static int ntuple_pdst_seen = 0;
+static int ntuple_pdst_mask_seen = 0;
+static int ntuple_vlan_tag_seen = 0;
+static int ntuple_vlan_tag_mask_seen = 0;
+static int ntuple_user_def_seen = 0;
+static int ntuple_user_def_mask_seen = 0;
 static char *flash_file = NULL;
 static int flash = -1;
 static int flash_region = -1;
@@ -482,18 +497,30 @@ static struct cmdline_info cmdline_coalesce[] = {
 };
 
 static struct cmdline_info cmdline_ntuple[] = {
-	{ "src-ip", CMDL_IP4, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL },
-	{ "src-ip-mask", CMDL_IP4, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL },
-	{ "dst-ip", CMDL_IP4, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL },
-	{ "dst-ip-mask", CMDL_IP4, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL },
-	{ "src-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.psrc, NULL },
-	{ "src-port-mask", CMDL_BE16, &ntuple_fs.m_u.tcp_ip4_spec.psrc, NULL },
-	{ "dst-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.pdst, NULL },
-	{ "dst-port-mask", CMDL_BE16, &ntuple_fs.m_u.tcp_ip4_spec.pdst, NULL },
-	{ "vlan", CMDL_U16, &ntuple_fs.vlan_tag, NULL },
-	{ "vlan-mask", CMDL_U16, &ntuple_fs.vlan_tag_mask, NULL },
-	{ "user-def", CMDL_U64, &ntuple_fs.data, NULL },
-	{ "user-def-mask", CMDL_U64, &ntuple_fs.data_mask, NULL },
+	{ "src-ip", CMDL_IP4, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL,
+	  0, &ntuple_ip4src_seen },
+	{ "src-ip-mask", CMDL_IP4, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL,
+	  0, &ntuple_ip4src_mask_seen },
+	{ "dst-ip", CMDL_IP4, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL,
+	  0, &ntuple_ip4dst_seen },
+	{ "dst-ip-mask", CMDL_IP4, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL,
+	  0, &ntuple_ip4dst_mask_seen },
+	{ "src-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.psrc, NULL,
+	  0, &ntuple_psrc_seen },
+	{ "src-port-mask", CMDL_BE16, &ntuple_fs.m_u.tcp_ip4_spec.psrc, NULL,
+	  0, &ntuple_psrc_mask_seen },
+	{ "dst-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.pdst, NULL,
+	  0, &ntuple_pdst_seen },
+	{ "dst-port-mask", CMDL_BE16, &ntuple_fs.m_u.tcp_ip4_spec.pdst, NULL,
+	  0, &ntuple_pdst_mask_seen },
+	{ "vlan", CMDL_U16, &ntuple_fs.vlan_tag, NULL,
+	  0, &ntuple_vlan_tag_seen },
+	{ "vlan-mask", CMDL_U16, &ntuple_fs.vlan_tag_mask, NULL,
+	  0, &ntuple_vlan_tag_mask_seen },
+	{ "user-def", CMDL_U64, &ntuple_fs.data, NULL,
+	  0, &ntuple_user_def_seen },
+	{ "user-def-mask", CMDL_U64, &ntuple_fs.data_mask, NULL,
+	  0, &ntuple_user_def_mask_seen },
 	{ "action", CMDL_S32, &ntuple_fs.action, NULL },
 };
 
@@ -844,13 +871,7 @@ static void parse_cmdline(int argc, char **argp)
 						show_usage(1);
 						break;
 					}
-					ntuple_fs.flow_type =
-					            rxflow_str_to_type(argp[i]);
-					i += 1;
-					parse_generic_cmdline(argc, argp, i,
-						&sntuple_changed,
-						cmdline_ntuple,
-						ARRAY_SIZE(cmdline_ntuple));
+					parse_rxntupleopts(argc, argp, i);
 					i = argc;
 					break;
 				} else {
@@ -1518,6 +1539,50 @@ static char *unparse_rxfhashopts(u64 opts)
 	return buf;
 }
 
+static void parse_rxntupleopts(int argc, char **argp, int i)
+{
+	ntuple_fs.flow_type = rxflow_str_to_type(argp[i]);
+
+	switch (ntuple_fs.flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+		parse_generic_cmdline(argc, argp, i + 1,
+				      &sntuple_changed,
+				      cmdline_ntuple,
+				      ARRAY_SIZE(cmdline_ntuple));
+		if (!ntuple_ip4src_seen)
+			ntuple_fs.m_u.tcp_ip4_spec.ip4src = 0xffffffff;
+		if (!ntuple_ip4dst_seen)
+			ntuple_fs.m_u.tcp_ip4_spec.ip4dst = 0xffffffff;
+		if (!ntuple_psrc_seen)
+			ntuple_fs.m_u.tcp_ip4_spec.psrc = 0xffff;
+		if (!ntuple_pdst_seen)
+			ntuple_fs.m_u.tcp_ip4_spec.pdst = 0xffff;
+		ntuple_fs.m_u.tcp_ip4_spec.tos = 0xff;
+		break;
+	default:
+		fprintf(stderr, "Unsupported flow type \"%s\"\n", argp[i]);
+		exit(106);
+		break;
+	}
+
+	if (!ntuple_vlan_tag_seen)
+		ntuple_fs.vlan_tag_mask = 0xffff;
+	if (!ntuple_user_def_seen)
+		ntuple_fs.data_mask = 0xffffffffffffffffULL;
+
+	if ((ntuple_ip4src_mask_seen && !ntuple_ip4src_seen) ||
+	    (ntuple_ip4dst_mask_seen && !ntuple_ip4dst_seen) ||
+	    (ntuple_psrc_mask_seen && !ntuple_psrc_seen) ||
+	    (ntuple_pdst_mask_seen && !ntuple_pdst_seen) ||
+	    (ntuple_vlan_tag_mask_seen && !ntuple_vlan_tag_seen) ||
+	    (ntuple_user_def_mask_seen && !ntuple_user_def_seen)) {
+		fprintf(stderr, "Cannot specify mask without value\n");
+		exit(107);
+	}
+}
+
 static struct {
 	const char *name;
 	int (*func)(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

