From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 5/7] ethtool: Add Ethernet-level RX n-tuple
 filtering and 'clear' action
Date: Thu, 23 Sep 2010 22:49:43 +0100
Message-ID: <1285278583.7794.32.camel@achroite.uk.solarflarecom.com>
References: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54667 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350Ab0IWVtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:49:46 -0400
In-Reply-To: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8 |   48 ++++++++++++++++++++++++++++++++++++++----
 ethtool.c |   68 +++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 103 insertions(+), 13 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index 295caab..2c54cb4 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -233,8 +233,9 @@ ethtool \- Display or change ethernet card settings
 .B ethtool \-u|\-\-show\-ntuple
 .I ethX
 
-.B ethtool \-U|\-\-config\-ntuple
-.I ethX
+.TP
+.BI ethtool\ \-U|\-\-config\-ntuple \ ethX
+.RB {
 .A3 flow-type tcp4 udp4 sctp4
 .RB [ src-ip
 .IR addr
@@ -252,6 +253,21 @@ ethtool \- Display or change ethernet card settings
 .IR port
 .RB [ dst-port-mask
 .IR mask ]]
+.br
+.RB | \ flow-type\ ether
+.RB [ src
+.IR mac-addr
+.RB [ src-mask
+.IR mask ]]
+.RB [ dst
+.IR mac-addr
+.RB [ dst-mask
+.IR mask ]]
+.RB [ proto
+.IR N
+.RB [ proto-mask
+.IR mask ]]\ }
+.br
 .RB [ vlan
 .IR VLAN-tag
 .RB [ vlan-mask
@@ -649,7 +665,7 @@ Get Rx ntuple filters and actions, then display them to the user.
 .B \-U \-\-config-ntuple
 Configure Rx ntuple filters and actions
 .TP
-.B flow-type tcp4|udp4|sctp4
+.B flow-type tcp4|udp4|sctp4|ether
 .RS
 .PD 0
 .TP 3
@@ -658,6 +674,8 @@ Configure Rx ntuple filters and actions
 .BR "udp4" "    UDP over IPv4"
 .TP 3
 .BR "sctp4" "   SCTP over IPv4"
+.TP 3
+.BR "ether" "   Ethernet"
 .PD
 .RE
 .TP
@@ -686,6 +704,25 @@ Includes the destination port.
 .BI dst-port-mask \ mask
 Specify a mask for the destination port.
 .TP
+.BI src \ mac-addr
+Includes the source MAC address, specified as 6 bytes in hexadecimal
+separated by colons.
+.TP
+.BI src-mask \ mask
+Specify a mask for the source MAC address.
+.TP
+.BI dst \ mac-addr
+Includes the destination MAC address.
+.TP
+.BI dst-mask \ mask
+Specify a mask for the destination MAC address.
+.TP
+.BI proto \ N
+Includes the Ethernet protocol number (ethertype).
+.TP
+.BI proto-mask \ mask
+Specify a mask for the Ethernet protocol number.
+.TP
 .BI vlan \ VLAN-tag
 Includes the VLAN tag.
 .TP
@@ -699,11 +736,12 @@ Includes 64-bits of user-specific data.
 Specify a mask for the user-specific data.
 .TP
 .BI action \ N
-Specifies either the Rx queue to send packets to, or to drop
-the matched flow.
+Specifies the Rx queue to send packets to, or some other action.
 .RS
 .PD 0
 .TP 3
+.BR "-2" "             Clear the filter"
+.TP 3
 .BR "-1" "             Drop the matched flow"
 .TP 3
 .BR "0 or higher" "    Rx queue to route the flow"
diff --git a/ethtool.c b/ethtool.c
index ea6a26f..31158f8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -240,11 +240,15 @@ static struct option {
 		"		equal N | weight W0 W1 ...\n" },
     { "-U", "--config-ntuple", MODE_SNTUPLE, "Configure Rx ntuple filters "
 		"and actions",
-		"		flow-type tcp4|udp4|sctp4\n"
-		"		[ src-ip ADDR [src-ip-mask MASK] ]\n"
-		"		[ dst-ip ADDR [dst-ip-mask MASK] ]\n"
-		"		[ src-port PORT [src-port-mask MASK] ]\n"
-		"		[ dst-port PORT [dst-port-mask MASK] ]\n"
+		"		{ flow-type tcp4|udp4|sctp4\n"
+		"		  [ src-ip ADDR [src-ip-mask MASK] ]\n"
+		"		  [ dst-ip ADDR [dst-ip-mask MASK] ]\n"
+		"		  [ src-port PORT [src-port-mask MASK] ]\n"
+		"		  [ dst-port PORT [dst-port-mask MASK] ]\n"
+		"		| flow-type ether\n"
+		"		  [ src MAC-ADDR [src-mask MASK] ]\n"
+		"		  [ dst MAC-ADDR [dst-mask MASK] ]\n"
+		"		  [ proto N [proto-mask MASK] ] }\n"
 		"		[ vlan VLAN-TAG [vlan-mask MASK] ]\n"
 		"		[ user-def DATA [user-def-mask MASK] ]\n"
 		"		action N\n" },
@@ -377,6 +381,12 @@ static int ntuple_psrc_seen = 0;
 static int ntuple_psrc_mask_seen = 0;
 static int ntuple_pdst_seen = 0;
 static int ntuple_pdst_mask_seen = 0;
+static int ntuple_ether_dst_seen = 0;
+static int ntuple_ether_dst_mask_seen = 0;
+static int ntuple_ether_src_seen = 0;
+static int ntuple_ether_src_mask_seen = 0;
+static int ntuple_ether_proto_seen = 0;
+static int ntuple_ether_proto_mask_seen = 0;
 static int ntuple_vlan_tag_seen = 0;
 static int ntuple_vlan_tag_mask_seen = 0;
 static int ntuple_user_def_seen = 0;
@@ -497,7 +507,7 @@ static struct cmdline_info cmdline_coalesce[] = {
 	{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted, &ecoal.tx_max_coalesced_frames_high },
 };
 
-static struct cmdline_info cmdline_ntuple[] = {
+static struct cmdline_info cmdline_ntuple_tcp_ip4[] = {
 	{ "src-ip", CMDL_IP4, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL,
 	  0, &ntuple_ip4src_seen },
 	{ "src-ip-mask", CMDL_IP4, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL,
@@ -525,6 +535,30 @@ static struct cmdline_info cmdline_ntuple[] = {
 	{ "action", CMDL_S32, &ntuple_fs.action, NULL },
 };
 
+static struct cmdline_info cmdline_ntuple_ether[] = {
+	{ "dst", CMDL_MAC, ntuple_fs.h_u.ether_spec.h_dest, NULL,
+	  0, &ntuple_ether_dst_seen },
+	{ "dst-mask", CMDL_MAC, ntuple_fs.m_u.ether_spec.h_dest, NULL,
+	  0, &ntuple_ether_dst_mask_seen },
+	{ "src", CMDL_MAC, ntuple_fs.h_u.ether_spec.h_source, NULL,
+	  0, &ntuple_ether_src_seen },
+	{ "src-mask", CMDL_MAC, ntuple_fs.m_u.ether_spec.h_source, NULL,
+	  0, &ntuple_ether_src_mask_seen },
+	{ "proto", CMDL_BE16, &ntuple_fs.h_u.ether_spec.h_proto, NULL,
+	  0, &ntuple_ether_proto_seen },
+	{ "proto-mask", CMDL_BE16, &ntuple_fs.m_u.ether_spec.h_proto, NULL,
+	  0, &ntuple_ether_proto_mask_seen },
+	{ "vlan", CMDL_U16, &ntuple_fs.vlan_tag, NULL,
+	  0, &ntuple_vlan_tag_seen },
+	{ "vlan-mask", CMDL_U16, &ntuple_fs.vlan_tag_mask, NULL,
+	  0, &ntuple_vlan_tag_mask_seen },
+	{ "user-def", CMDL_U64, &ntuple_fs.data, NULL,
+	  0, &ntuple_user_def_seen },
+	{ "user-def-mask", CMDL_U64, &ntuple_fs.data_mask, NULL,
+	  0, &ntuple_user_def_mask_seen },
+	{ "action", CMDL_S32, &ntuple_fs.action, NULL },
+};
+
 static struct cmdline_info cmdline_msglvl[] = {
 	{ "drv", CMDL_FLAG, &msglvl_wanted, NULL,
 	  NETIF_MSG_DRV, &msglvl_mask },
@@ -741,6 +775,8 @@ static int rxflow_str_to_type(const char *str)
 		flow_type = AH_ESP_V6_FLOW;
 	else if (!strcmp(str, "sctp6"))
 		flow_type = SCTP_V6_FLOW;
+	else if (!strcmp(str, "ether"))
+		flow_type = ETHER_FLOW;
 
 	return flow_type;
 }
@@ -1551,8 +1587,8 @@ static void parse_rxntupleopts(int argc, char **argp, int i)
 	case SCTP_V4_FLOW:
 		parse_generic_cmdline(argc, argp, i + 1,
 				      &sntuple_changed,
-				      cmdline_ntuple,
-				      ARRAY_SIZE(cmdline_ntuple));
+				      cmdline_ntuple_tcp_ip4,
+				      ARRAY_SIZE(cmdline_ntuple_tcp_ip4));
 		if (!ntuple_ip4src_seen)
 			ntuple_fs.m_u.tcp_ip4_spec.ip4src = 0xffffffff;
 		if (!ntuple_ip4dst_seen)
@@ -1563,6 +1599,19 @@ static void parse_rxntupleopts(int argc, char **argp, int i)
 			ntuple_fs.m_u.tcp_ip4_spec.pdst = 0xffff;
 		ntuple_fs.m_u.tcp_ip4_spec.tos = 0xff;
 		break;
+	case ETHER_FLOW:
+		parse_generic_cmdline(argc, argp, i + 1,
+				      &sntuple_changed,
+				      cmdline_ntuple_ether,
+				      ARRAY_SIZE(cmdline_ntuple_ether));
+		if (!ntuple_ether_dst_seen)
+			memset(ntuple_fs.m_u.ether_spec.h_dest, 0xff, ETH_ALEN);
+		if (!ntuple_ether_src_seen)
+			memset(ntuple_fs.m_u.ether_spec.h_source, 0xff,
+			       ETH_ALEN);
+		if (!ntuple_ether_proto_seen)
+			ntuple_fs.m_u.ether_spec.h_proto = 0xffff;
+		break;
 	default:
 		fprintf(stderr, "Unsupported flow type \"%s\"\n", argp[i]);
 		exit(106);
@@ -1578,6 +1627,9 @@ static void parse_rxntupleopts(int argc, char **argp, int i)
 	    (ntuple_ip4dst_mask_seen && !ntuple_ip4dst_seen) ||
 	    (ntuple_psrc_mask_seen && !ntuple_psrc_seen) ||
 	    (ntuple_pdst_mask_seen && !ntuple_pdst_seen) ||
+	    (ntuple_ether_dst_mask_seen && !ntuple_ether_dst_seen) ||
+	    (ntuple_ether_src_mask_seen && !ntuple_ether_src_seen) ||
+	    (ntuple_ether_proto_mask_seen && !ntuple_ether_proto_seen) ||
 	    (ntuple_vlan_tag_mask_seen && !ntuple_vlan_tag_seen) ||
 	    (ntuple_user_def_mask_seen && !ntuple_user_def_seen)) {
 		fprintf(stderr, "Cannot specify mask without value\n");
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

