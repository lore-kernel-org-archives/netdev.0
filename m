From: Santwona.Behera@Sun.COM
Subject: [PATCH 1/3] [ethtool] Add support for RX packet classification in a
 network device
Date: Mon, 09 Feb 2009 15:12:21 -0800
Message-ID: <4990B855.30905@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_RDUp7G4zByQIvyevXvBhNA)"
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>,
	Santwona Behera <Santwona.Behera@Sun.COM>
To: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:40017 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337AbZBIXMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 18:12:34 -0500
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n19NCYvh010619
	for <netdev@vger.kernel.org>; Mon, 9 Feb 2009 15:12:34 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KET00400LJ7SK00@fe-sfbay-09.sun.com> for netdev@vger.kernel.org; Mon,
 09 Feb 2009 15:12:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_RDUp7G4zByQIvyevXvBhNA)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: 7BIT


--Boundary_(ID_RDUp7G4zByQIvyevXvBhNA)
Content-type: text/x-patch;
 name=ethtool-add-rx-pkt-classification-interface.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline;
 filename=ethtool-add-rx-pkt-classification-interface.patch

From: Santwona Behera <santwona.behera@sun.com>
[PATCH 1/3] [ethtool] Add RX pkt classification interface

Signed-off-by: Santwona Behera <santwona.behera@sun.com>
---
 ethtool-copy.h |   82 ++++-
 ethtool.8      |  138 +++++++-
 ethtool.c      | 1070 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 1260 insertions(+), 30 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index eadba25..8c61f3e 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -12,6 +12,8 @@
 #ifndef _LINUX_ETHTOOL_H
 #define _LINUX_ETHTOOL_H
 
+#include <linux/types.h>
+
 /* This should work for both 32 and 64 bit userland. */
 struct ethtool_cmd {
 	__u32	cmd;
@@ -285,10 +287,71 @@ enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 };
 
-struct ethtool_rxnfc {
-	__u32		cmd;
+struct ethtool_tcpip4_spec {
+	__u32	ip4src;
+	__u32	ip4dst;
+	__u16	psrc;
+	__u16	pdst;
+	__u8    tos;
+};
+
+struct ethtool_ah_espip4_spec {
+	__u32	ip4src;
+	__u32	ip4dst;
+	__u32	spi;
+	__u8    tos;
+};
+
+struct ethtool_rawip4_spec {
+	__u32	ip4src;
+	__u32	ip4dst;
+	__u8	hdata[64];
+};
+
+struct ethtool_ether_spec {
+	__u16	ether_type;
+	__u8	frame_size;
+	__u8	eframe[16];
+};
+
+#define	ETH_RX_NFC_IP4	1
+#define	ETH_RX_NFC_IP6	2
+
+struct ethtool_usrip4_spec {
+	__u32	ip4src;
+	__u32	ip4dst;
+	__u32	l4_4_bytes;
+	__u8    tos;
+	__u8    ip_ver;
+	__u8    proto;
+};
+
+struct ethtool_rx_flow_spec {
 	__u32		flow_type;
-	__u64		data;
+	union
+	{
+		struct ethtool_tcpip4_spec		tcp_ip4_spec;
+		struct ethtool_tcpip4_spec		udp_ip4_spec;
+		struct ethtool_tcpip4_spec		sctp_ip4_spec;
+		struct ethtool_ah_espip4_spec		ah_ip4_spec;
+		struct ethtool_ah_espip4_spec		esp_ip4_spec;
+		struct ethtool_rawip4_spec		raw_ip4_spec;
+		struct ethtool_ether_spec		ether_spec;
+		struct ethtool_usrip4_spec		usr_ip4_spec;
+		__u8					hdata[64];
+	} h_u, m_u; /* entry, mask */
+	__u64		ring_cookie;
+	__u32		location;
+};
+
+struct ethtool_rxnfc {
+	__u32				cmd;
+	__u32				flow_type;
+	/* The rx flow hash value or the rule DB size or the # rx rings */
+	__u64				data;
+	struct ethtool_rx_flow_spec	fs;
+	__u32				rule_cnt;
+	__u32				rule_locs[0];
 };
 
 /* CMDs currently supported */
@@ -336,6 +399,12 @@ struct ethtool_rxnfc {
 
 #define	ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
 #define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
+#define	ETHTOOL_GRXRINGS	0x0000002d /* Get RX rings available for LB */
+#define	ETHTOOL_GRXCLSRLCNT	0x0000002e /* Get RX class rule count */
+#define	ETHTOOL_GRXCLSRULE	0x0000002f /* Get RX classification rule */
+#define	ETHTOOL_GRXCLSRLALL	0x00000030 /* Get all RX classification rule */
+#define	ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
+#define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -432,9 +501,13 @@ struct ethtool_rxnfc {
 #define	UDP_V6_FLOW	0x06
 #define	SCTP_V6_FLOW	0x07
 #define	AH_ESP_V6_FLOW	0x08
+#define	AH_V4_FLOW	0x09
+#define	ESP_V4_FLOW	0x0a
+#define	AH_V6_FLOW	0x0b
+#define	ESP_V6_FLOW	0x0c
+#define	IP_USER_FLOW	0x0d
 
 /* L3-L4 network traffic flow hash options */
-#define	RXH_DEV_PORT	(1 << 0)
 #define	RXH_L2DA	(1 << 1)
 #define	RXH_VLAN	(1 << 2)
 #define	RXH_L3_PROTO	(1 << 3)
@@ -444,5 +517,6 @@ struct ethtool_rxnfc {
 #define	RXH_L4_B_2_3	(1 << 7) /* dst port in case of TCP/UDP/SCTP */
 #define	RXH_DISCARD	(1 << 31)
 
+#define	RX_CLS_FLOW_DISC	0xffffffffffffffffULL
 
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/ethtool.8 b/ethtool.8
index 1beb387..e8a843d 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -37,17 +37,30 @@
 .\"
 .ds MA \fIxx\fP\fB:\fP\fIyy\fP\fB:\fP\fIzz\fP\fB:\fP\fIaa\fP\fB:\fP\fIbb\fP\fB:\fP\fIcc\fP
 .\"
+.\"	\(*PA - IP address
+.\"
+.ds PA \fIN\fP\fB.\fP\fIN\fP\fB.\fP\fIN\fP\fB.\fP\fIN\fP
+.\"
 .\"	\(*WO - wol flags
 .\"
 .ds WO \fBp\fP|\fBu\fP|\fBm\fP|\fBb\fP|\fBa\fP|\fBg\fP|\fBs\fP|\fBd\fP...
 .\"
 .\"	\(*FL - flow type values
 .\"
-.ds FL \fBtcp4\fP|\fBudp4\fP|\fBah4\fP|\fBsctp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBsctp6\fP
+.ds FL \fBtcp4\fP|\fBudp4\fP|\fBah4\fP||\fBesp4\fP|\fBsctp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBesp6\fP|\fBsctp6\fP
 .\"
 .\"	\(*HO - hash options
 .\"
-.ds HO \fBp\fP|\fm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
+.ds HO \fBm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
+.\"
+.\"	\(*PV - ipversion options
+.\"
+.ds PV \fBip4\fP|\fBip6\fP
+.\"
+.\"	\(*L4 - L4 proto options
+.\"
+.ds L4 \fBtcp\fP|\fBudp\fP|\fBsctp\fP|\fBah\fP|\fBesp\fP|\fIN\fP
+
 .TH ETHTOOL 8 "July 2007" "Ethtool version 6"
 .SH NAME
 ethtool \- Display or change ethernet card settings
@@ -200,11 +213,53 @@ ethtool \- Display or change ethernet card settings
 .B ethtool \-n
 .I ethX
 .RB [ rx-flow-hash \ \*(FL]
+.RB [ rx-rings ]
+.RB [ rx-class-rule-all ]
+.RB [ rx-class-rule
+.IR N ]
 
 .B ethtool \-N
 .I ethX
 .RB [ rx-flow-hash \ \*(FL
 .RB \ \*(HO]
+.RB [ rx-class-rule-del
+.IR N ]
+.RB [ rx-class-rule-add \ \*(PV
+.RB \ \*(L4
+.RB [ tos
+.IR N
+.RB [ m
+.IR N ]
+.RB ]
+.RB [ sip \ \*(PA
+.RB [ m \ \*(PA ]
+.RB ]
+.RB [ dip \ \*(PA
+.RB [ m \ \*(PA ]
+.RB ]
+.RB [ sport
+.IR N
+.RB [ m
+.IR N ]
+.RB ]
+.RB [ dport
+.IR N
+.RB [ m
+.IR N ]
+.RB ]
+.RB [ spi
+.IR N
+.RB [ m
+.IR N ]
+.RB ]
+.RB [ ring
+.IR N |
+.B drop
+.RB ]
+.RB [ loc
+.IR N ]
+.RB ]
+
 .SH DESCRIPTION
 .BI ethtool
 is used for querying settings of an ethernet device and changing them.
@@ -457,6 +512,15 @@ Retrieves the hash options for the specified network traffic type.
 .PD
 .RE
 .TP
+.B rx-rings
+Retrieves the number of RX rings available for this interface.
+.TP
+.B rx-class-rule-all
+Retrieves all the RX classification rules programmed for this interface.
+.TP
+.BI rx-class-rule \ N
+Retrieves the RX classification rule with the given ID.
+.TP
 .B \-N \-\-config-nfc
 Configures the receive network flow classification.
 .TP
@@ -465,9 +529,6 @@ Configures the hash options for the specified network traffic type.
 .RS
 .PD 0
 .TP 3
-.B p
-Hash on the device port number on which the packet was received.
-.TP 3
 .B m
 Hash on the Layer 2 destination address of the rx packet.
 .TP 3
@@ -490,9 +551,74 @@ Hash on bytes 0 and 1 of the Layer 4 header of the rx packet.
 Hash on bytes 2 and 3 of the Layer 4 header of the rx packet.
 .TP 3
 .B r
-Discard all packets of this flow type. When this option is set, all other options are ignored.
+Discard all packets of this flow type. When this option is set, all
+other options are ignored.
 .PD
 .RE
+.TP
+.BI rx-class-rule-del \ N
+Deletes the RX classification rule with the given ID.
+.TP
+.BR rx-class-rule-add
+Adds an RX packet classification rule.
+.TP
+.B \*(PV
+Select IP version for the rule - IPv4 or IPv6
+.TP
+.B \*(L4
+Select the L4 protocol for the rule. An integer value for a user defined
+protocol can be specified.
+.TP
+.BI tos \ N
+.B [
+.BI m \ N
+.BR ]
+Specify the value of the Type of Service field in the incoming packet to
+match along with an optional mask.
+.TP
+.BR sip \ \*(PA \ [ \  m \ \*(PA \ ]
+Specify the source IP address of the incoming packet to
+match along with an optional mask.
+.TP
+.BR dip \ \*(PA \ [ \  m \ \*(PA \ ]
+Specify the destination IP address of the incoming packet to
+match along with an optional mask.
+.TP
+.BI sport \ N
+.B [
+.BI m \ N
+.BR ]
+Specify the value of the source port field (applicable to
+TCP/UDP packets)in the incoming packet to match along with an
+optional mask.
+.TP
+.BI dport \ N
+.B [
+.BI m \ N
+.BR ]
+Specify the value of the destination port field (applicable to
+TCP/UDP packets)in the incoming packet to match along with an
+optional mask.
+.TP
+.BI spi \ N
+.B [
+.BI m \ N
+.BR ]
+Specify the value of the SPI field (applicable to
+SCTP packets)in the incoming packet to match along with an
+optional mask.
+.TP
+.BI ring \ N
+.B |
+.BR drop
+Specify the RX ring index to which a packet matching this
+rule should be steered, or specify if the matching packet
+should be dropped.
+.TP
+.BI loc \ \ \ N
+Specify the location/ID to insert the rule. This will overwrite
+any rule present in that location and will not go through any
+of the rule ordering process.
 .SH BUGS
 Not supported (in part or whole) on all ethernet drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index a7c02d0..d4050e9 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -6,6 +6,7 @@
  * Kernel 2.4 update Copyright 2001 Jeff Garzik <jgarzik@mandrakesoft.com>
  * Wake-on-LAN,natsemi,misc support by Tim Hockin <thockin@sun.com>
  * Portions Copyright 2002 Intel
+ * Portions Copyright (c) Sun Microsystems 2009
  * do_test support by Eli Kupermann <eli.kupermann@intel.com>
  * ETHTOOL_PHYS_ID support by Chris Leech <christopher.leech@intel.com>
  * e1000 support by Scott Feldman <scott.feldman@intel.com>
@@ -14,6 +15,7 @@
  * amd8111e support by Reeja John <reeja.john@amd.com>
  * long arguments by Andi Kleen.
  * SMSC LAN911x support by Steve Glendinning <steve.glendinning@smsc.com>
+ * Rx Network Flow Control configuration support <santwona.behera@sun.com>
  *
  * TODO:
  *   * no-args => summary of each device (mii-tool style)
@@ -34,11 +36,15 @@
 #include <sys/ioctl.h>
 #include <sys/stat.h>
 #include <stdio.h>
-#include <string.h>
+#include <stdint.h>
+#include <stddef.h>
+#include <strings.h>
 #include <errno.h>
 #include <net/if.h>
 
 #include <linux/sockios.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
 #include "ethtool-util.h"
 
 #ifndef SIOCETHTOOL
@@ -72,9 +78,21 @@ static int do_gstats(int fd, struct ifreq *ifr);
 static int rxflow_str_to_type(const char *str);
 static int parse_rxfhashopts(char *optstr, u32 *data);
 static char *unparse_rxfhashopts(u64 opts);
+static int parse_rxclassruleopts(char **optstr, int opt_cnt,
+				 struct ethtool_rx_flow_spec *fsp);
 static int dump_rxfhash(int fhash, u64 val);
 static int do_srxclass(int fd, struct ifreq *ifr);
 static int do_grxclass(int fd, struct ifreq *ifr);
+static void rmgr_print_ipv4_rule(struct ethtool_rx_flow_spec *fsp);
+static void rmgr_print_rule(struct ethtool_rx_flow_spec *fsp);
+static int rmgr_add(struct ethtool_rx_flow_spec *fsp, __u8 loc_valid);
+static int rmgr_del(__u32 loc);
+static int rmgr_init(int fd, struct ifreq *ifr);
+static int rmgr_rx_rule_getall(int fd, struct ifreq *ifr);
+static int rmgr_rx_rule_get(int fd, struct ifreq *ifr, __u32 loc);
+static int rmgr_rx_rule_ins(int fd, struct ifreq *ifr,
+			    struct ethtool_rx_flow_spec *fsp, __u8 loc_valid);
+static int rmgr_rx_rule_del(int fd, struct ifreq *ifr, __u32 loc);
 
 static enum {
 	MODE_HELP = -1,
@@ -180,14 +198,28 @@ static struct option {
     { "-t", "--test", MODE_TEST, "Execute adapter self test",
                 "               [ online | offline ]\n" },
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
-    { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification"
+    { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification "
 		"options",
-		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
-		"tcp6|udp6|ah6|sctp6 ]\n" },
+		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+		"tcp6|udp6|ah6|esp6|sctp6 ]\n"
+		"		[ rx-rings ]\n"
+		"		[ rx-class-rule-all ]\n"
+		"		[ rx-class-rule %%d ]\n"},
     { "-N", "--config-nfc", MODE_SNFC, "Configure Rx network flow "
 		"classification options",
-		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
-		"tcp6|udp6|ah6|sctp6 p|m|v|t|s|d|f|n|r... ]\n" },
+		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+		"tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n"
+		"		[ rx-class-rule-del %%d ]\n"
+		"		[ rx-class-rule-add ip4|ip6 tcp|udp|sctp|ah|esp|%%d\n"
+		"			[tos %%d [m %%x]]\n"
+		"			[sip %%d.%%d.%%d.%%d "
+		"[m %%d.%%d.%%d.%%d]]\n"
+		"			[dip %%d.%%d.%%d.%%d "
+		"[m %%d.%%d.%%d.%%d]]\n"
+		"			[sport %%d [m %%x]] "
+		"[dport %%d [m %%x]]\n"
+		"			[spi %%d [m %%x]]\n"
+		"			[ring %%d | drop] [loc %%d]]\n"},
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -289,6 +321,95 @@ static int rx_fhash_get = 0;
 static int rx_fhash_set = 0;
 static u32 rx_fhash_val = 0;
 static int rx_fhash_changed = 0;
+static int rx_rings_get = 0;
+static int rx_class_rule_get = -1;
+static int rx_class_rule_getall = 0;
+static int rx_class_rule_del = -1;
+static int rx_class_rule_added = 0;
+static struct ethtool_rx_flow_spec rx_rule_fs;
+static u8 rx_class_rule_loc_given = 0;
+
+/*
+ * This is a rule manager implementation for ordering rx flow
+ * classification rules in a longest prefix first match order.
+ * The assumption is that this rule manager is the only one adding rules to
+ * the device's hardware classifier.
+ */
+
+/*
+ * There are 9 regions defined for ordering the rules, listed in decreasing
+ * priority order, i.e., the rules in a particular region are matched after
+ * the rules in the region before it. Withing a given region, lower numbered
+ * rules are matched first.
+ *
+ * Region 1: Rules with all 5 tuples specified, no masks.
+ *		- L4 proto
+ *		- src IP
+ *		- dst IP
+ *		- IP TOS byte
+ *		- src port and/or dst port OR spi
+ *
+ * Region 2: Rules with all 5 tuples specified, and one or more of them
+ * have masks specified.
+ *
+ * Region 3: Rules with 4 tuples specified, no masks.
+ *		- L4 proto and any 3 of the following
+ *			- src IP
+ *			- dst IP
+ *			- IP TOS byte
+ *			- src port and/or dst port OR spi
+ *
+ * Region 4: Rules with 4 tuples specified, and one or more of them
+ * have masks specified.
+ *
+ * Region 5: Rules with 3 tuples specified, no masks.
+ *		- L4 proto and any 2 of the following
+ *			- src IP
+ *			- dst IP
+ *			- IP TOS byte
+ *			- src port and/or dst port OR spi
+ *
+ * Region 6: Rules with 3 tuples specified, and one or more of them
+ * have masks specified.
+ *
+ *
+ * Region 7: Rules with 2 tuples specified, no masks.
+ *		- L4 proto and any 1 of the following
+ *			- src IP
+ *			- dst IP
+ *			- IP TOS byte
+ *			- src port and/or dst port OR spi
+ *
+ * Region 8: Rules with 2 tuples specified, and one or more of them
+ * have masks specified.
+ *
+ * Region 9: Rules with only the L4 proto specified.
+ *
+ */
+#define RMGR_MAX_REGIONS	9
+
+struct rmgr_range {
+	__u32	top;
+	__u32	len;
+	int	region;
+};
+
+struct rmgr_ctrl {
+	__u32				size;
+
+	/* <slot> is the classifier slot map.  It is populated */
+	/* with flow_spec pointers (or NULL). */
+	struct ethtool_rx_flow_spec	**slot;
+	/* <limit> is the maximum number of regions. */
+	__u16				limit;
+	/* <legend> is the set of ranges */
+	struct rmgr_range		legend[RMGR_MAX_REGIONS];
+	__u32				n_rules;
+};
+
+static struct rmgr_ctrl rmgr;
+static int rmgr_init_done = 0;
+
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -427,7 +548,9 @@ static int rxflow_str_to_type(const char *str)
 	else if (!strcmp(str, "udp4"))
 		flow_type = UDP_V4_FLOW;
 	else if (!strcmp(str, "ah4"))
-		flow_type = AH_ESP_V4_FLOW;
+		flow_type = AH_V4_FLOW;
+	else if (!strcmp(str, "esp4"))
+		flow_type = ESP_V4_FLOW;
 	else if (!strcmp(str, "sctp4"))
 		flow_type = SCTP_V4_FLOW;
 	else if (!strcmp(str, "tcp6"))
@@ -435,7 +558,9 @@ static int rxflow_str_to_type(const char *str)
 	else if (!strcmp(str, "udp6"))
 		flow_type = UDP_V6_FLOW;
 	else if (!strcmp(str, "ah6"))
-		flow_type = AH_ESP_V6_FLOW;
+		flow_type = AH_V6_FLOW;
+	else if (!strcmp(str, "esp6"))
+		flow_type = ESP_V6_FLOW;
 	else if (!strcmp(str, "sctp6"))
 		flow_type = SCTP_V6_FLOW;
 
@@ -570,6 +695,23 @@ static void parse_cmdline(int argc, char **argp)
 						rxflow_str_to_type(argp[i]);
 					if (!rx_fhash_get)
 						show_usage(1);
+				} else if (!strcmp(argp[i], "rx-rings")) {
+					i += 1;
+					rx_rings_get = 1;
+				} else if (!strcmp(argp[i],
+						   "rx-class-rule-all")) {
+					i += 1;
+					rx_class_rule_getall = 1;
+				} else if (!strcmp(argp[i], "rx-class-rule")) {
+					i += 1;
+					if (i >= argc) {
+						show_usage(1);
+						break;
+					}
+					rx_class_rule_get =
+						strtol(argp[i], NULL, 0);
+					if (rx_class_rule_get < 0)
+						show_usage(1);
 				} else
 					show_usage(1);
 				break;
@@ -597,8 +739,37 @@ static void parse_cmdline(int argc, char **argp)
 						show_usage(1);
 					else
 						rx_fhash_changed = 1;
-				} else
+				} else if (!strcmp(argp[i],
+						   "rx-class-rule-del")) {
+					i += 1;
+					if (i >= argc) {
+						show_usage(1);
+						break;
+					}
+					rx_class_rule_del =
+						strtol(argp[i], NULL, 0);
+					if (rx_class_rule_del < 0)
+						show_usage(1);
+				} else if (!strcmp(argp[i],
+						   "rx-class-rule-add")) {
+					i += 1;
+					if (i >= argc) {
+						show_usage(1);
+						break;
+					}
+					if (parse_rxclassruleopts(&argp[i],
+								  argc - i,
+								  &rx_rule_fs)
+					    < 0) {
+						show_usage(1);
+					} else {
+						i = argc;
+						rx_class_rule_added = 1;
+					}
+				} else {
 					show_usage(1);
+				}
+
 				break;
 			}
 			if (mode != MODE_SSET)
@@ -1097,9 +1268,6 @@ static int parse_rxfhashopts(char *optstr, u32 *data)
 	*data = 0;
 	while (*optstr) {
 		switch (*optstr) {
-			case 'p':
-				*data |= RXH_DEV_PORT;
-				break;
 			case 'm':
 				*data |= RXH_L2DA;
 				break;
@@ -1132,6 +1300,334 @@ static int parse_rxfhashopts(char *optstr, u32 *data)
 	return 0;
 }
 
+static int parse_rxclassruleopts(char **optstr, int opt_cnt,
+				 struct ethtool_rx_flow_spec *fsp)
+{
+	int i = 0;
+
+	u_int8_t discard, ring_set;
+	u_int32_t ipsa, ipsm, ipda, ipdm, spi, spim;
+	u_int16_t sp, spm, dp, dpm;
+	u_int8_t ip_ver, proto, tos, tm;
+	struct in_addr in_addr;
+
+	if (*optstr == NULL || **optstr == '\0' || opt_cnt < 2) {
+		fprintf(stdout, "Add rule, invalid syntax \n");
+		return -1;
+	}
+
+	bzero (fsp, sizeof (struct ethtool_rx_flow_spec));
+	ipsa = ipda = ipsm = ipdm = spi = spim = 0x0;
+	sp = dp = spm = dpm = 0x0;
+	ip_ver = proto = tos = tm = 0x0;
+	discard = ring_set = 0;
+
+	if (!strcmp(optstr[i], "ip4")) {
+		ip_ver = ETH_RX_NFC_IP4;
+	} else if (!strcmp(optstr[i], "ip6")) {
+		ip_ver = ETH_RX_NFC_IP6;
+	} else {
+		fprintf(stdout, "Add rule, invalid syntax for IP version\n");
+		return -1;
+	}
+
+	i++;
+
+	switch (ip_ver) {
+	case ETH_RX_NFC_IP4:
+		if (!strcmp(optstr[i], "tcp")) {
+			fsp->flow_type = TCP_V4_FLOW;
+		} else if (!strcmp(optstr[i], "udp")) {
+			fsp->flow_type = UDP_V4_FLOW;
+		} else if (!strcmp(optstr[i], "sctp")) {
+			fsp->flow_type = SCTP_V4_FLOW;
+		} else if (!strcmp(optstr[i], "ah")) {
+			fsp->flow_type = AH_V4_FLOW;
+		} else if (!strcmp(optstr[i], "esp")) {
+			fsp->flow_type = ESP_V4_FLOW;
+		}
+		break;
+
+	case ETH_RX_NFC_IP6:
+		if (!strcmp(optstr[i], "tcp")) {
+			fsp->flow_type = TCP_V6_FLOW;
+		} else if (!strcmp(optstr[i], "udp")) {
+			fsp->flow_type = UDP_V6_FLOW;
+		} else if (!strcmp(optstr[i], "sctp")) {
+			fsp->flow_type = SCTP_V6_FLOW;
+		} else if (!strcmp(optstr[i], "ah")) {
+			fsp->flow_type = AH_V6_FLOW;
+		} else if (!strcmp(optstr[i], "esp")) {
+			fsp->flow_type = ESP_V6_FLOW;
+		}
+		break;
+	default:
+		fprintf(stdout, "Add rule, Invalid IP version %d\n", ip_ver);
+			return -1;
+	}
+
+	if (fsp->flow_type == 0) {
+		if ((proto = (u_int8_t) strtoul(optstr[i], (char **)NULL, 0))
+		    != 0) {
+			fprintf(stdout, "Add rule, user defined proto %d\n",
+				proto);
+			fsp->flow_type = IP_USER_FLOW;
+			fsp->h_u.usr_ip4_spec.proto = proto;
+			fsp->h_u.usr_ip4_spec.ip_ver = ip_ver;
+		} else {
+			fprintf(stdout, "Add rule, invalid IP proto %s\n",
+				optstr[i]);
+			return -1;
+		}
+	}
+
+	if (ip_ver == ETH_RX_NFC_IP6) {
+		fprintf(stdout, "IPv6 not yet implemented\n");
+		return -1;
+	}
+
+	for (i = 2; i < opt_cnt;) {
+
+		if (!strcmp(optstr[i], "tos")) {
+			tos = (u_int8_t) strtoul(optstr[i+1], (char **)NULL,
+						 0);
+			tm = 0xff;
+			fsp->h_u.tcp_ip4_spec.tos = tos;
+
+			i += 2;
+			if (opt_cnt > (i+1)) {
+				if (!strcmp(optstr[i], "m")) {
+					tm = (u_int8_t)strtoul(optstr[i+1],
+								 (char **)NULL, 16);
+					i += 2;
+				}
+			}
+			fsp->m_u.tcp_ip4_spec.tos = tm;
+
+		} else if (!strcmp(optstr[i], "sip")) {
+			if (strchr(optstr[i+1], '.') == NULL) {
+				ipsa = strtoul(optstr[i+1], (char **)NULL, 16);
+			} else {
+				if (!inet_pton(AF_INET, optstr[i+1], &in_addr)) {
+					fprintf(stdout,
+						"Invalid src address [%s]\n" ,
+						optstr[i+1]);
+					return -1;
+				}
+				ipsa = htonl(in_addr.s_addr);
+			}
+			ipsm = 0xffffffff;
+			fsp->h_u.tcp_ip4_spec.ip4src = ipsa;
+
+			i += 2;
+			if (opt_cnt > (i+1)) {
+				if (!strcmp(optstr[i], "m")) {
+					if (strchr(optstr[i+1], '.') == NULL) {
+						ipsm = strtoul(optstr[i+1],
+							       (char **)NULL,
+							       16);
+					} else {
+						
+						if (!inet_pton(AF_INET,
+							       optstr[i+1],
+							       &in_addr)) {
+							fprintf(stdout,
+								"Invalid smask"
+								"[%s]\n",
+								optstr[i+1]);
+								return -1;
+						}
+						ipsm = htonl(in_addr.s_addr);
+					}
+					i += 2;
+				}
+			}
+			fsp->m_u.tcp_ip4_spec.ip4src = ipsm;
+		} else if (!strcmp(optstr[i], "dip")) {
+			if (strchr(optstr[i+1], '.') == NULL) {
+				ipda = strtoul(optstr[i+1], (char **)NULL, 16);
+			} else {
+				if (!inet_pton(AF_INET, optstr[i+1], &in_addr)) {
+					fprintf(stdout,
+						"Invalid dst address [%s]\n",
+						optstr[i+1]);
+					return -1;
+				}
+				ipda = htonl(in_addr.s_addr);
+			}
+			ipdm = 0xffffffff;
+			fsp->h_u.tcp_ip4_spec.ip4dst = ipda;
+
+			i += 2;
+			if (opt_cnt > (i+1)) {
+				if (!strcmp(optstr[i], "m")) {
+					if (strchr(optstr[i+1], '.') == NULL) {
+						ipdm = strtoul(optstr[i+1],
+							       (char **)NULL,
+							       16);
+					} else {
+						
+						if (!inet_pton(AF_INET,
+							       optstr[i+1],
+							       &in_addr)) {
+							fprintf(stdout,
+								"Invalid dmask"
+								"[%s]\n",
+								optstr[i+1]);
+								return -1;
+						}
+						ipdm = htonl(in_addr.s_addr);
+					}
+					i += 2;
+				}
+			}
+			fsp->m_u.tcp_ip4_spec.ip4dst = ipdm;
+		} else if (!strcmp(optstr[i], "sport")) {
+			switch (fsp->flow_type) {
+			case TCP_V4_FLOW:
+			case UDP_V4_FLOW:
+			case SCTP_V4_FLOW:
+			case TCP_V6_FLOW:
+			case UDP_V6_FLOW:
+			case SCTP_V6_FLOW:
+			case IP_USER_FLOW:
+				break;
+			default:
+				fprintf(stdout, "Invalid option <sport> "
+					"for this flow\n");
+				return -1;
+			}
+			sp = (u_int16_t) strtoul(optstr[i+1], (char **)NULL,
+						 0);
+			spm = 0xffff;
+			if (fsp->flow_type == IP_USER_FLOW) {
+				fsp->h_u.usr_ip4_spec.l4_4_bytes |=
+					((u32)sp << 16);
+			} else {
+				fsp->h_u.tcp_ip4_spec.psrc = sp;
+			}
+			i += 2;
+			if (opt_cnt > (i+1)) {
+				if (!strcmp(optstr[i], "m")) {
+					spm = (u_int16_t)strtoul(optstr[i+1],
+								 (char **)NULL, 16);
+					i += 2;
+				}
+			}
+			if (fsp->flow_type == IP_USER_FLOW) {
+				fsp->m_u.usr_ip4_spec.l4_4_bytes |=
+					((u32)spm << 16);
+			} else {
+				fsp->m_u.tcp_ip4_spec.psrc = spm;
+			}
+		} else if (!strcmp(optstr[i], "dport")) {
+			switch (fsp->flow_type) {
+			case TCP_V4_FLOW:
+			case UDP_V4_FLOW:
+			case SCTP_V4_FLOW:
+			case TCP_V6_FLOW:
+			case UDP_V6_FLOW:
+			case SCTP_V6_FLOW:
+			case IP_USER_FLOW:
+				break;
+			default:
+				fprintf(stdout, "Invalid option <dport> "
+					"for this flow\n");
+				return -1;
+			}
+			dp = (u_int16_t) strtoul(optstr[i+1], (char **)NULL,
+						 0);
+			dpm = 0xffff;
+			if (fsp->flow_type == IP_USER_FLOW)
+				fsp->h_u.usr_ip4_spec.l4_4_bytes |= dp;
+			else
+				fsp->h_u.tcp_ip4_spec.pdst = dp;
+
+			i += 2;
+			if (opt_cnt > (i+1)) {
+				if (!strcmp(optstr[i], "m")) {
+					dpm = (u_int16_t)strtoul(optstr[i+1],
+								 (char **)NULL, 16);
+					i += 2;
+				}
+			}
+			if (fsp->flow_type == IP_USER_FLOW)
+				fsp->m_u.usr_ip4_spec.l4_4_bytes |= dpm;
+			else
+				fsp->m_u.tcp_ip4_spec.pdst = dpm;
+		} else if (!strcmp(optstr[i], "spi")) {
+			switch (fsp->flow_type) {
+			case AH_V4_FLOW:
+			case ESP_V4_FLOW:
+			case AH_V6_FLOW:
+			case ESP_V6_FLOW:
+			case IP_USER_FLOW:
+				break;
+			case TCP_V4_FLOW:
+			case UDP_V4_FLOW:
+			case SCTP_V4_FLOW:
+			case TCP_V6_FLOW:
+			case UDP_V6_FLOW:
+			case SCTP_V6_FLOW:
+			default:
+				fprintf(stdout, "Invalid option <spi> "
+					"for this flow\n");
+				return -1;
+			}
+			spi = (u_int32_t) strtoul(optstr[i+1], (char **)NULL,
+						 0);
+			spim = 0xffffffff;
+			if (fsp->flow_type == IP_USER_FLOW)
+				fsp->h_u.usr_ip4_spec.l4_4_bytes = spi;
+			else
+				fsp->h_u.esp_ip4_spec.spi = spi;
+
+			i += 2;
+			if (opt_cnt > (i+1)) {
+				if (!strcmp(optstr[i], "m")) {
+					spim = (u_int32_t)strtoul(optstr[i+1],
+								 (char **)NULL, 16);
+					i += 2;
+				}
+			}
+			if (fsp->flow_type == IP_USER_FLOW)
+				fsp->m_u.usr_ip4_spec.l4_4_bytes = spim;
+			else
+				fsp->m_u.esp_ip4_spec.spi = spim;
+		} else if (!strcmp(optstr[i], "ring")) {
+			if (discard == 1) {
+				fprintf(stdout, "Invalid syntax - <drop> "
+					"option already specified\n");
+				return -1;
+			}
+			fsp->ring_cookie = strtol(optstr[i+1], (char **)NULL,
+                                                  0);
+			i += 2;
+			ring_set = 1;
+		} else if (!strcmp(optstr[i], "drop")) {
+			if (ring_set == 1) {
+				fprintf(stdout, "Invalid syntax - <ring> "
+					"option already specified\n");
+				return -1;
+			}
+			fsp->ring_cookie = RX_CLS_FLOW_DISC;
+			i++;
+			discard = 1;
+		} else if (!strcmp(optstr[i], "loc")) {
+			fsp->location = strtol(optstr[i+1], (char **)NULL,
+						  0);
+			i += 2;
+			rx_class_rule_loc_given = 1;
+		} else {
+			
+			fprintf(stdout, "Add rule, invalid syntax\n");
+			return -1;
+		}
+	}
+
+	return 0;
+}
+
 static char *unparse_rxfhashopts(u64 opts)
 {
 	static char buf[300];
@@ -1139,9 +1635,6 @@ static char *unparse_rxfhashopts(u64 opts)
 	memset(buf, 0, sizeof(buf));
 
 	if (opts) {
-		if (opts & RXH_DEV_PORT) {
-			strcat(buf, "Dev port\n");
-		}
 		if (opts & RXH_L2DA) {
 			strcat(buf, "L2DA\n");
 		}
@@ -1420,9 +1913,12 @@ static int dump_rxfhash(int fhash, u64 val)
 	case SCTP_V4_FLOW:
 		fprintf(stdout, "SCTP over IPV4 flows");
 		break;
-	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
 		fprintf(stdout, "IPSEC AH over IPV4 flows");
 		break;
+	case ESP_V4_FLOW:
+		fprintf(stdout, "IPSEC ESP over IPV4 flows");
+		break;
 	case TCP_V6_FLOW:
 		fprintf(stdout, "TCP over IPV6 flows");
 		break;
@@ -1432,9 +1928,12 @@ static int dump_rxfhash(int fhash, u64 val)
 	case SCTP_V6_FLOW:
 		fprintf(stdout, "SCTP over IPV6 flows");
 		break;
-	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
 		fprintf(stdout, "IPSEC AH over IPV6 flows");
 		break;
+	case ESP_V6_FLOW:
+		fprintf(stdout, "IPSEC ESP over IPV6 flows");
+		break;
 	default:
 		break;
 	}
@@ -1450,6 +1949,143 @@ static int dump_rxfhash(int fhash, u64 val)
 	return 0;
 }
 
+static void rmgr_print_ipv4_rule(struct ethtool_rx_flow_spec *fsp)
+{
+	char		chan[16];
+	char		l4_proto[16];
+
+	if (fsp->ring_cookie != RX_CLS_FLOW_DISC)
+		sprintf(chan, "Rx Ring [%d]", (int)fsp->ring_cookie);
+	else
+		sprintf(chan, "Discard");
+
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case IP_USER_FLOW:
+		fprintf(stdout,
+			"      IPv4 Rule:   ID[%d] Target[%s]\n"
+			"      IP src addr[%d.%d.%d.%d] mask[%d.%d.%d.%d]\n"
+			"      IP dst addr[%d.%d.%d.%d] mask[%d.%d.%d.%d]\n",
+			fsp->location, chan,
+			(fsp->h_u.tcp_ip4_spec.ip4src & 0xff000000) >> 24,
+			(fsp->h_u.tcp_ip4_spec.ip4src & 0xff0000) >> 16,
+			(fsp->h_u.tcp_ip4_spec.ip4src & 0xff00) >> 8,
+			fsp->h_u.tcp_ip4_spec.ip4src & 0xff,
+			(fsp->m_u.tcp_ip4_spec.ip4src & 0xff000000) >> 24,
+			(fsp->m_u.tcp_ip4_spec.ip4src & 0xff0000) >> 16,
+			(fsp->m_u.tcp_ip4_spec.ip4src & 0xff00) >> 8,
+			fsp->m_u.tcp_ip4_spec.ip4src & 0xff,
+			(fsp->h_u.tcp_ip4_spec.ip4dst & 0xff000000) >> 24,
+			(fsp->h_u.tcp_ip4_spec.ip4dst & 0xff0000) >> 16,
+			(fsp->h_u.tcp_ip4_spec.ip4dst & 0xff00) >> 8,
+			fsp->h_u.tcp_ip4_spec.ip4dst & 0xff,
+			(fsp->m_u.tcp_ip4_spec.ip4dst & 0xff000000) >> 24,
+			(fsp->m_u.tcp_ip4_spec.ip4dst & 0xff0000) >> 16,
+			(fsp->m_u.tcp_ip4_spec.ip4dst & 0xff00) >> 8,
+			fsp->m_u.tcp_ip4_spec.ip4dst & 0xff);
+
+		switch (fsp->flow_type) {
+		case TCP_V4_FLOW:
+			sprintf(l4_proto, "TCP");
+			break;
+		case UDP_V4_FLOW:
+			sprintf(l4_proto, "UDP");
+			break;
+		case SCTP_V4_FLOW:
+			sprintf(l4_proto, "SCTP");
+			break;
+		case AH_V4_FLOW:
+			sprintf(l4_proto, "AH");
+			break;
+		case ESP_V4_FLOW:
+			sprintf(l4_proto, "ESP");
+			break;
+		default:
+			break;
+		}
+		switch (fsp->flow_type) {
+		case TCP_V4_FLOW:
+		case UDP_V4_FLOW:
+		case SCTP_V4_FLOW:
+			fprintf(stdout,
+				"      L4 proto[%s]\n"
+				"      L4 src port[%d] mask[0x%x]\n"
+				"      L4 dst port[%d] mask[0x%x]\n",
+				l4_proto,
+				fsp->h_u.tcp_ip4_spec.psrc,
+				fsp->m_u.tcp_ip4_spec.psrc,
+				fsp->h_u.tcp_ip4_spec.pdst,
+				fsp->m_u.tcp_ip4_spec.pdst);
+			break;
+		case AH_V4_FLOW:
+		case ESP_V4_FLOW:
+			fprintf(stdout,
+				"      L4 proto[%s]\n"
+				"      L4 SPI[%d] mask[0x%x]\n",
+				l4_proto,
+				fsp->h_u.esp_ip4_spec.spi,
+				fsp->m_u.esp_ip4_spec.spi);
+			break;
+		case IP_USER_FLOW:
+			fprintf(stdout,
+				"      L4 user proto[%d]\n"
+				"      L4 first 4 bytes[0x%x] mask[0x%x]\n",
+				fsp->h_u.usr_ip4_spec.proto,
+				fsp->h_u.usr_ip4_spec.l4_4_bytes,
+				fsp->m_u.usr_ip4_spec.l4_4_bytes);
+			break;
+		default:
+			break;
+		}
+		break;
+	default:
+		fprintf(stdout,
+			"      Unknown L4 proto, type[%d]\n", fsp->flow_type);
+		break;
+	}
+
+	fprintf(stdout,
+		"      IP TOS[0x%x] mask[0x%x]\n",
+		fsp->h_u.tcp_ip4_spec.tos,
+		fsp->m_u.tcp_ip4_spec.tos);
+
+	fprintf(stdout,"\n\n");
+}
+
+static void rmgr_print_rule(struct ethtool_rx_flow_spec *fsp)
+{
+	/* print the rule in this location */
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		rmgr_print_ipv4_rule(fsp);
+		break;
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+		perror("IPv6 flows not implemented");
+		break;
+	case IP_USER_FLOW:
+		if (fsp->h_u.usr_ip4_spec.ip_ver == ETH_RX_NFC_IP4)
+			rmgr_print_ipv4_rule(fsp);
+		else
+			perror("IPv6 flows not implemented");
+		break;
+	default:
+		perror("rmgr: Unknown flow type");
+		break;
+	}
+}
+
 static int doit(void)
 {
 	struct ifreq ifr;
@@ -2338,14 +2974,12 @@ static int do_gstats(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-
 static int do_srxclass(int fd, struct ifreq *ifr)
 {
 	int err;
+	struct ethtool_rxnfc nfccmd;
 
 	if (rx_fhash_changed) {
-		struct ethtool_rxnfc nfccmd;
-
 		nfccmd.cmd = ETHTOOL_SRXFH;
 		nfccmd.flow_type = rx_fhash_set;
 		nfccmd.data = rx_fhash_val;
@@ -2357,6 +2991,20 @@ static int do_srxclass(int fd, struct ifreq *ifr)
 
 	}
 
+	if (rx_class_rule_added) {
+		err = rmgr_rx_rule_ins(fd, ifr, &rx_rule_fs,
+				       rx_class_rule_loc_given);
+		if (err < 0)
+			perror("Cannot insert RX classification rule");
+	}
+
+	if (rx_class_rule_del >= 0) {
+		err = rmgr_rx_rule_del(fd, ifr, rx_class_rule_del);
+
+		if (err < 0)
+			perror("Cannot delete RX classification rule");
+	}
+
 	return 0;
 }
 
@@ -2377,6 +3025,388 @@ static int do_grxclass(int fd, struct ifreq *ifr)
 			dump_rxfhash(rx_fhash_get, nfccmd.data);
 	}
 
+	if (rx_rings_get) {
+		struct ethtool_rxnfc nfccmd;
+
+		nfccmd.cmd = ETHTOOL_GRXRINGS;
+		ifr->ifr_data = (caddr_t)&nfccmd;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err < 0)
+			perror("Cannot get RX rings");
+		else
+			fprintf(stdout, "%d RX rings available\n",
+				(int)nfccmd.data);
+	}
+
+	if (rx_class_rule_get >= 0) {
+		err = rmgr_rx_rule_get(fd, ifr, rx_class_rule_get);
+		if (err < 0)
+			perror("Cannot get RX classification rule");
+	}
+
+	if (rx_class_rule_getall) {
+		err = rmgr_rx_rule_getall(fd, ifr);
+		if (err < 0)
+			perror("RX classification rule retrieval failed");
+	}
+
+	return 0;
+}
+
+static int rmgr_add(struct ethtool_rx_flow_spec *fsp, __u8 loc_valid)
+{
+	struct ethtool_rx_flow_spec *new_rule = NULL;
+	struct rmgr_range region;
+	int i, j;
+
+	if (loc_valid) {
+		/* Do a direct insertion by location index, no sorting */
+		rmgr.slot[fsp->location] =
+			calloc(1, sizeof (struct ethtool_rx_flow_spec));
+		*rmgr.slot[fsp->location] = *fsp;
+			
+		return 0;
+	}
+
+	/* evaluate rule and add in appropriate region */
+	i = rmgr.limit;
+
+	/* Proto is always present (specified or implicit) */
+	i--;
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		if (fsp->m_u.tcp_ip4_spec.tos == 0xff)
+			i--;
+		if (fsp->h_u.tcp_ip4_spec.tos)
+			i--;
+		if (fsp->m_u.tcp_ip4_spec.ip4src == 0xffffffff)
+			i--;
+		if (fsp->h_u.tcp_ip4_spec.ip4src)
+			i--;
+		if (fsp->m_u.tcp_ip4_spec.ip4dst == 0xffffffff)
+			i--;
+		if (fsp->h_u.tcp_ip4_spec.ip4dst)
+			i--;
+		if (fsp->flow_type == AH_V4_FLOW ||
+		    fsp->flow_type == ESP_V4_FLOW) {
+			if (fsp->m_u.esp_ip4_spec.spi == 0xffffffff)
+				i--;
+			if (fsp->h_u.esp_ip4_spec.spi)
+				i--;
+		} else {
+			if ((fsp->m_u.tcp_ip4_spec.psrc == 0xffff) ||
+			    (fsp->m_u.tcp_ip4_spec.pdst == 0xffff))
+				i--;
+			if (fsp->h_u.tcp_ip4_spec.psrc ||
+			    fsp->h_u.tcp_ip4_spec.pdst)
+				i--;
+		}
+		break;
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+		perror("IPv6 flows not implemented");
+		return -1;
+	case IP_USER_FLOW:
+		if (fsp->h_u.usr_ip4_spec.ip_ver == ETH_RX_NFC_IP4) {
+			if (fsp->m_u.usr_ip4_spec.tos == 0xff)
+				i--;
+			if (fsp->h_u.usr_ip4_spec.tos)
+				i--;
+			if (fsp->m_u.usr_ip4_spec.ip4src == 0xffffffff)
+				i--;
+			if (fsp->h_u.usr_ip4_spec.ip4src)
+				i--;
+			if (fsp->m_u.usr_ip4_spec.ip4dst == 0xffffffff)
+				i--;
+			if (fsp->h_u.usr_ip4_spec.ip4dst)
+				i--;
+			if (fsp->m_u.usr_ip4_spec.l4_4_bytes == 0xffffffff)
+				i--;
+			if (fsp->h_u.usr_ip4_spec.l4_4_bytes)
+				i--;
+			break;
+		} else {
+			perror("IPv6 flows not implemented");
+			return -1;
+		}
+	default:
+		return -1;
+	}
+
+	/* find an empty slot in this region */
+	region = rmgr.legend[i];
+	for (j = region.top; j < (region.top + region.len); j++) {
+		if (rmgr.slot[j] == (struct ethtool_rx_flow_spec *)NULL) {
+			new_rule =
+				calloc(1,
+				       sizeof (struct ethtool_rx_flow_spec));
+			if (new_rule == (struct ethtool_rx_flow_spec *)NULL)
+				return -1;
+			*new_rule = *fsp;
+			rmgr.slot[j] = new_rule;
+			break;
+		}
+	}
+	if (new_rule == (struct ethtool_rx_flow_spec *)NULL) {
+		/* no space in this region */
+		/* Try to append */
+		j = region.top + region.len;
+		if (j < rmgr.size) {
+			if (rmgr.slot[j] ==
+			    (struct ethtool_rx_flow_spec *)NULL) {
+				new_rule =
+					calloc(1,
+					       sizeof (struct ethtool_rx_flow_spec ));
+				if (new_rule ==
+				    (struct ethtool_rx_flow_spec *)NULL)
+					return -1;
+				*new_rule = *fsp;
+				rmgr.slot[j] = new_rule;
+				rmgr.legend[i+1].top++;
+				rmgr.legend[i+1].len--;
+				rmgr.legend[i].len++;
+			}
+		}
+		if (new_rule == (struct ethtool_rx_flow_spec *)NULL) {
+			/* Try to prepend */
+			j = region.top - 1;
+			if (j >= 0) {
+				if (rmgr.slot[j] ==
+				    (struct ethtool_rx_flow_spec *)NULL) {
+					new_rule =
+						calloc(1,
+						       sizeof (struct ethtool_rx_flow_spec ));
+					if (new_rule == NULL)
+						return -1;
+					*new_rule = *fsp;
+					rmgr.slot[j] = new_rule;
+					rmgr.legend[i].top--;
+					rmgr.legend[i].len++;
+					rmgr.legend[i-1].len--;
+				}
+			}
+		}
+	}
+	if (new_rule == (struct ethtool_rx_flow_spec *)NULL) {
+		/* No space to add this rule */
+		perror("rmgr: Cannot find appropriate slot to insert rule");
+		return -1;
+	}
+
+	fsp->location = j;
+	     
+	return 0;
+}
+
+static int rmgr_del(__u32 loc)
+{
+	int i;
+	__u32 bottom;
+
+	if (rmgr.slot[loc] == NULL) {
+		perror("rmgr: No such rule");
+		return -1;
+	}
+
+	/* find the region */
+	for (i = 0; i < rmgr.limit; i++) {
+		bottom = rmgr.legend[i].top + rmgr.legend[i].len;
+		if (loc >= rmgr.legend[i].top &&
+		    loc < bottom) {
+			if (rmgr.slot[loc] !=
+			    (struct ethtool_rx_flow_spec *)NULL)
+				free(rmgr.slot[loc]);
+			rmgr.slot[loc] = NULL;
+		}
+	}
+
+	if (rmgr.slot[loc] != NULL) {
+		/* Did not find the region -- something is wrong */
+		perror("rmgr: Could not find rule");
+		return -1;
+	}
+
+	return 0;
+}
+
+static int rmgr_init(int fd, struct ifreq *ifr)
+{
+	struct ethtool_rxnfc *nfccmd;
+	struct rmgr_range *range;
+	int err, i, j;
+	__u32 reg_len;
+	__u32 *rule_locs;
+
+	if (rmgr_init_done)
+		return 0;
+
+	bzero((void *)&rmgr, sizeof (struct rmgr_ctrl));
+
+	nfccmd = calloc(1, sizeof(*nfccmd));
+	nfccmd->cmd = ETHTOOL_GRXCLSRLCNT;
+	ifr->ifr_data = (caddr_t)nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	rmgr.n_rules = nfccmd->rule_cnt;
+	free(nfccmd);
+	if (err < 0) {
+		perror("rmgr: Cannot get RX class rule count");
+		return -1;
+	}
+
+	nfccmd = calloc(1, sizeof(*nfccmd) + (rmgr.n_rules * sizeof(__u32)));
+
+	nfccmd->cmd = ETHTOOL_GRXCLSRLALL;
+	nfccmd->rule_cnt = rmgr.n_rules;
+	ifr->ifr_data = (caddr_t)nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("rmgr: Cannot get RX class rules");
+		free(nfccmd);
+		return -1;
+	}
+
+	rmgr.size = nfccmd->data;
+	rmgr.slot = calloc(1, rmgr.size *
+			   sizeof (struct ethtool_rx_flow_spec *));
+
+	rmgr.limit = RMGR_MAX_REGIONS;
+
+	reg_len = rmgr.size / rmgr.limit;
+	range = rmgr.legend;
+
+	for (i = 0, j = 0; i < rmgr.limit; i++) {
+		range->top = (__u32)j;
+		range->len = reg_len;
+		range->region = i;
+		j += reg_len;
+		range++;
+	}
+
+	rule_locs = nfccmd->rule_locs;
+
+	for (i = 0; i < rmgr.n_rules; i++) {
+		/* get rule from device and add to rule manager */
+		nfccmd->cmd = ETHTOOL_GRXCLSRULE;
+		nfccmd->fs.location = rule_locs[i];
+		ifr->ifr_data = (caddr_t)nfccmd;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err < 0) {
+			perror("rmgr: Cannot get RX class rule");
+			free(rmgr.slot);
+			free(nfccmd);
+			return -1;
+		}
+		err = rmgr_add(&nfccmd->fs, 1);
+	}
+
+	rmgr_init_done = 1;
+	free(nfccmd);
+	return 0;
+}
+
+static int rmgr_rx_rule_getall(int fd, struct ifreq *ifr)
+{
+	struct ethtool_rx_flow_spec *fsp;
+	int err, i;
+
+	if (!rmgr_init_done) {
+		err = rmgr_init(fd, ifr);
+		if (err < 0)
+			return err;
+	}
+
+	fprintf(stdout, "Total %d rules\n\n", rmgr.n_rules);
+
+	for (i = 0; i < rmgr.size; i++) {
+		fsp = rmgr.slot[i];
+		if (fsp == (struct ethtool_rx_flow_spec *)NULL)
+			continue;
+		rmgr_print_rule(fsp);
+	}
+	return 0;
+}
+
+static int rmgr_rx_rule_get(int fd, struct ifreq *ifr, __u32 loc)
+{
+	struct ethtool_rx_flow_spec *fsp;
+	int err;
+
+	if (!rmgr_init_done) {
+		err = rmgr_init(fd, ifr);
+		if (err < 0)
+			return err;
+	}
+
+	fsp = rmgr.slot[loc];
+	if (fsp == NULL || fsp->location != loc) {
+		perror("rmgr: No such rule");
+		return -1;
+	}
+
+	rmgr_print_rule(fsp);
+
+	return 0;
+}
+
+static int rmgr_rx_rule_ins(int fd, struct ifreq *ifr,
+			    struct ethtool_rx_flow_spec *fsp, __u8 loc_valid)
+{
+	struct ethtool_rxnfc nfccmd;
+	int err;
+
+	if (!rmgr_init_done) {
+		err = rmgr_init(fd, ifr);
+		if (err < 0)
+			return err;
+	}
+
+	err = rmgr_add(fsp, loc_valid);
+	if (err < 0)
+		return err;
+
+	nfccmd.cmd = ETHTOOL_SRXCLSRLINS;
+	nfccmd.fs = *fsp;
+	ifr->ifr_data = (caddr_t)&nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("rmgr: Cannot insert RX class rule");
+		return -1;
+	}
+	rmgr.n_rules++;
+	return 0;
+}
+
+static int rmgr_rx_rule_del(int fd, struct ifreq *ifr, __u32 loc)
+{
+	struct ethtool_rxnfc nfccmd;
+	int err;
+
+	if (!rmgr_init_done) {
+		err = rmgr_init(fd, ifr);
+		if (err < 0)
+			return err;
+	}
+
+	err = rmgr_del(loc);
+	if (err < 0)
+		return err;
+
+	nfccmd.cmd = ETHTOOL_SRXCLSRLDEL;
+	nfccmd.fs.location = loc;
+	ifr->ifr_data = (caddr_t)&nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("rmgr: Cannot delete RX class rule");
+		return -1;
+	}
+	rmgr.n_rules--;
 	return 0;
 }
 
-- 
1.6.0.4


--Boundary_(ID_RDUp7G4zByQIvyevXvBhNA)--
