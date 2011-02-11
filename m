From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 2/2] Add RX packet classification interface
Date: Thu, 10 Feb 2011 17:18:38 -0800
Message-ID: <20110211011838.23554.3735.stgit@gitlad.jf.intel.com>
References: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64199 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757517Ab1BKBSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 20:18:39 -0500
In-Reply-To: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona Behera <santwona.behera@sun.com>

This patch was originally introduced as:
  [PATCH 1/3] [ethtool] Add rx pkt classification interface
  Signed-off-by: Santwona Behera <santwona.behera@sun.com>
  http://patchwork.ozlabs.org/patch/23223/

I have updated it to address a number of issues.  As a result I removed the
local caching of rules due to the fact that there were memory leaks in this
code and the rule manager would consume over 1Mb of space for an 8K table
when all that was needed was 1K in order to store which rules were active
and which were not.

In addition I dropped the use of regions as there were multiple issue found
including the fact that the regions were not properly expanding beyond 2
and the fact that the regions required reading all of the rules in order to
correctly expand beyond 2.  By dropping the regions from the rule manager
it is possible to write a much cleaner interface leaving region management
to be done by either the driver or by external management scripts.

I also added an ethtool bitops interface to allow for simple bit set and
test activities since the rule manager can most efficiently store the list
of active rules via a bitmap.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 Makefile.am      |    3 
 ethtool-bitops.h |   25 ++
 ethtool-util.h   |   13 +
 ethtool.8.in     |  101 ++++++-
 ethtool.c        |  144 +++++++++-
 rxclass.c        |  809 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 1077 insertions(+), 18 deletions(-)
 create mode 100644 ethtool-bitops.h
 create mode 100644 rxclass.c

diff --git a/Makefile.am b/Makefile.am
index a0d2116..0262c31 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -8,7 +8,8 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h ethtool-util.h	\
 		  amd8111e.c de2104x.c e100.c e1000.c igb.c	\
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
-		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c
+		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
+		  rxclass.c
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff --git a/ethtool-bitops.h b/ethtool-bitops.h
new file mode 100644
index 0000000..7101056
--- /dev/null
+++ b/ethtool-bitops.h
@@ -0,0 +1,25 @@
+#ifndef ETHTOOL_BITOPS_H__
+#define ETHTOOL_BITOPS_H__
+
+#define BITS_PER_LONG		__WORDSIZE
+#define BITS_PER_BYTE		8
+#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
+#define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_BYTE * sizeof(long))
+
+static inline void set_bit(int nr, unsigned long *addr)
+{
+	addr[nr / BITS_PER_LONG] |= 1UL << (nr % BITS_PER_LONG);
+}
+
+static inline void clear_bit(int nr, unsigned long *addr)
+{
+	addr[nr / BITS_PER_LONG] &= ~(1UL << (nr % BITS_PER_LONG));
+}
+
+static __always_inline int test_bit(unsigned int nr, const unsigned long *addr)
+{
+	return ((1UL << (nr % BITS_PER_LONG)) &
+		(((unsigned long *)addr)[nr / BITS_PER_LONG])) != 0UL;
+}
+
+#endif
diff --git a/ethtool-util.h b/ethtool-util.h
index f053028..e9300e2 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -103,4 +103,17 @@ int sfc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 			struct ethtool_regs *regs);
 int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
+/* Rx flow classification */
+#include <sys/ioctl.h>
+#include <net/if.h>
+
+int rxclass_parse_ruleopts(char **optstr, int opt_cnt,
+			   struct ethtool_rx_flow_spec *fsp, __u8 *loc_valid);
+int rxclass_rule_getall(int fd, struct ifreq *ifr);
+int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc);
+int rxclass_rule_ins(int fd, struct ifreq *ifr,
+		     struct ethtool_rx_flow_spec *fsp, __u8 loc_valid);
+int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc);
+
 #endif
diff --git a/ethtool.8.in b/ethtool.8.in
index 133825b..c183a3d 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -40,21 +40,36 @@
 [\\fB\\$1\\fP\ \\fIN\\fP]
 ..
 .\"
+.\"	.BM - same as above but has a mask field for format "[value N [m N]]"
+.\"
+.de BM
+[\\fB\\$1\\fP\ \\fIN\\fP\ [\\fBm\\fP\ \\fIN\\fP]]
+..
+.\"
 .\"	\(*MA - mac address
 .\"
 .ds MA \fIxx\fP\fB:\fP\fIyy\fP\fB:\fP\fIzz\fP\fB:\fP\fIaa\fP\fB:\fP\fIbb\fP\fB:\fP\fIcc\fP
 .\"
+.\"	\(*PA - IP address
+.\"
+.ds PA \fIx\fP\fB.\fP\fIx\fP\fB.\fP\fIx\fP\fB.\fP\fIx\fP
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
 .ds HO \fBm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
+.\"
+.\"	\(*L4 - L4 proto options
+.\"
+.ds L4 \fBtcp\fP|\fBudp\fP|\fBsctp\fP|\fBah\fP|\fBesp\fP|\fIN\fP
+.\"
 .\" Start URL.
 .de UR
 .  ds m1 \\$1\"
@@ -224,11 +239,27 @@ ethtool \- query or control network driver and hardware settings
 .B ethtool \-n
 .I ethX
 .RB [ rx-flow-hash \ \*(FL]
+.RB [ rx-rings ]
+.RB [ rx-class-rule-all ]
+.RB [ rx-class-rule
+.IR N ]
 
 .B ethtool \-N
 .I ethX
-.RB [ rx-flow-hash \ \*(FL
-.RB \ \*(HO]
+.RB [ rx-flow-hash \ \*(FL \  \*(HO]
+.BN rx-class-rule-del
+.RB [ rx-class-rule-add \  ip4 | ip6 \ \*(L4
+.RB [ sip \ \*(PA\ [ m \ \*(PA]]
+.RB [ dip \ \*(PA\ [ m \ \*(PA]]
+.BM tos
+.BM sport
+.BM dport
+.BM spi
+.RB [ ring
+.IR N |
+.BR drop ]
+.RB [ loc
+.IR N ]]
 
 .B ethtool \-x|\-\-show\-rxfh\-indir
 .I ethX
@@ -624,6 +655,15 @@ Retrieves the hash options for the specified network traffic type.
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
@@ -654,10 +694,63 @@ Hash on bytes 0 and 1 of the Layer 4 header of the rx packet.
 Hash on bytes 2 and 3 of the Layer 4 header of the rx packet.
 .TP 3
 .B r
-Discard all packets of this flow type. When this option is set, all other options are ignored.
+Discard all packets of this flow type. When this option is set, all
+other options are ignored.
 .PD
 .RE
 .TP
+.BI rx-class-rule-del \ N
+Deletes the RX classification rule with the given ID.
+.TP
+.BR rx-class-rule-add
+Adds an RX packet classification rule.
+.TP
+.A1 ip4 ip6
+Select IP version for the rule - IPv4 or IPv6
+.TP
+.RB \*(L4
+Select the L4 protocol for the rule. An integer value for a user defined
+protocol can be specified.
+.TP
+.BR sip \ \*(PA\ [ m \ \*(PA]
+Specify the source IP address of the incoming packet to
+match along with an optional mask.
+.TP
+.BR dip \ \*(PA\ [ m \ \*(PA]
+Specify the destination IP address of the incoming packet to
+match along with an optional mask.
+.TP
+.BI tos \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the Type of Service field in the incoming packet to
+match along with an optional mask.
+.TP
+.BI sport \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the source port field (applicable to
+TCP/UDP packets)in the incoming packet to match along with an
+optional mask.
+.TP
+.BI dport \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the destination port field (applicable to
+TCP/UDP packets)in the incoming packet to match along with an
+optional mask.
+.TP
+.BI spi \ N \\fR\ [\\fPm \ N \\fR]\\fP
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
+.TP
 .B \-x \-\-show\-rxfh\-indir
 Retrieves the receive flow hash indirection table.
 .TP
diff --git a/ethtool.c b/ethtool.c
index 1afdfe4..b624980 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -6,6 +6,7 @@
  * Kernel 2.4 update Copyright 2001 Jeff Garzik <jgarzik@mandrakesoft.com>
  * Wake-on-LAN,natsemi,misc support by Tim Hockin <thockin@sun.com>
  * Portions Copyright 2002 Intel
+ * Portions Copyright (C) Sun Microsystems 2008
  * do_test support by Eli Kupermann <eli.kupermann@intel.com>
  * ETHTOOL_PHYS_ID support by Chris Leech <christopher.leech@intel.com>
  * e1000 support by Scott Feldman <scott.feldman@intel.com>
@@ -14,6 +15,7 @@
  * amd8111e support by Reeja John <reeja.john@amd.com>
  * long arguments by Andi Kleen.
  * SMSC LAN911x support by Steve Glendinning <steve.glendinning@smsc.com>
+ * Rx Network Flow Control configuration support <santwona.behera@sun.com>
  * Various features by Ben Hutchings <bhutchings@solarflare.com>;
  *	Copyright 2009, 2010 Solarflare Communications
  *
@@ -32,7 +34,7 @@
 #include <sys/ioctl.h>
 #include <sys/stat.h>
 #include <stdio.h>
-#include <string.h>
+#include <strings.h>
 #include <errno.h>
 #include <net/if.h>
 #include <sys/utsname.h>
@@ -44,6 +46,8 @@
 #include <arpa/inet.h>
 
 #include <linux/sockios.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
 #include "ethtool-util.h"
 
 
@@ -232,15 +236,28 @@ static struct option {
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
     { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification "
 		"options",
-		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
-		"tcp6|udp6|ah6|sctp6 ]\n" },
+		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+		"tcp6|udp6|ah6|esp6|sctp6 ]\n"
+		"		[ rx-rings ]\n"
+		"		[ rx-class-rule-all ]\n"
+		"		[ rx-class-rule %d ]\n"},
     { "-f", "--flash", MODE_FLASHDEV, "FILENAME " "Flash firmware image "
     		"from the specified file to a region on the device",
 		"               [ REGION-NUMBER-TO-FLASH ]\n" },
     { "-N", "--config-nfc", MODE_SNFC, "Configure Rx network flow "
 		"classification options",
-		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
-		"tcp6|udp6|ah6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
+		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+		"tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n"
+		"		[ rx-class-rule-del %d ]\n"
+		"		[ rx-class-rule-add ip4|ip6 tcp|udp|sctp|ah|esp|%d\n"
+		"			[sip %d.%d.%d.%d [m %d.%d.%d.%d]]\n"
+		"			[dip %d.%d.%d.%d [m %d.%d.%d.%d]]\n"
+		"			[tos %d [m %x]]\n"
+		"			[sport %d [m %x]]\n"
+		"			[dport %d [m %x]]\n"
+		"			[spi %d [m %x]]\n"
+		"			[ring %d | drop]\n"
+		"			[loc %d]]\n"},
     { "-x", "--show-rxfh-indir", MODE_GRXFHINDIR, "Show Rx flow hash "
 		"indirection" },
     { "-X", "--set-rxfh-indir", MODE_SRXFHINDIR, "Set Rx flow hash indirection",
@@ -408,6 +425,14 @@ static int msglvl_changed;
 static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
 
+static int rx_rings_get = 0;
+static int rx_class_rule_get = -1;
+static int rx_class_rule_getall = 0;
+static int rx_class_rule_del = -1;
+static int rx_class_rule_added = 0;
+static struct ethtool_rx_flow_spec rx_rule_fs;
+static u8 rxclass_loc_valid = 0;
+
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -777,7 +802,9 @@ static int rxflow_str_to_type(const char *str)
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
@@ -785,7 +812,9 @@ static int rxflow_str_to_type(const char *str)
 	else if (!strcmp(str, "udp6"))
 		flow_type = UDP_V6_FLOW;
 	else if (!strcmp(str, "ah6"))
-		flow_type = AH_ESP_V6_FLOW;
+		flow_type = AH_V6_FLOW;
+	else if (!strcmp(str, "esp6"))
+		flow_type = ESP_V6_FLOW;
 	else if (!strcmp(str, "sctp6"))
 		flow_type = SCTP_V6_FLOW;
 	else if (!strcmp(str, "ether"))
@@ -945,6 +974,23 @@ static void parse_cmdline(int argc, char **argp)
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
@@ -978,8 +1024,37 @@ static void parse_cmdline(int argc, char **argp)
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
+					if (rxclass_parse_ruleopts(&argp[i],
+								   argc - i,
+								   &rx_rule_fs,
+								   &rxclass_loc_valid) < 0) {
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
 			if (mode == MODE_SRXFHINDIR) {
@@ -1917,9 +1992,12 @@ static int dump_rxfhash(int fhash, u64 val)
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
@@ -1929,9 +2007,12 @@ static int dump_rxfhash(int fhash, u64 val)
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
@@ -2911,14 +2992,12 @@ static int do_gstats(int fd, struct ifreq *ifr)
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
@@ -2930,6 +3009,20 @@ static int do_srxclass(int fd, struct ifreq *ifr)
 
 	}
 
+	if (rx_class_rule_added) {
+		err = rxclass_rule_ins(fd, ifr, &rx_rule_fs,
+				       rxclass_loc_valid);
+		if (err < 0)
+			fprintf(stderr, "Cannot insert RX classification rule\n");
+	}
+
+	if (rx_class_rule_del >= 0) {
+		err = rxclass_rule_del(fd, ifr, rx_class_rule_del);
+
+		if (err < 0)
+			fprintf(stderr, "Cannot delete RX classification rule\n");
+	}
+
 	return 0;
 }
 
@@ -2950,6 +3043,31 @@ static int do_grxclass(int fd, struct ifreq *ifr)
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
+		err = rxclass_rule_get(fd, ifr, rx_class_rule_get);
+		if (err < 0)
+			fprintf(stderr, "Cannot get RX classification rule\n");
+	}
+
+	if (rx_class_rule_getall) {
+		err = rxclass_rule_getall(fd, ifr);
+		if (err < 0)
+			fprintf(stderr, "RX classification rule retrieval failed\n");
+	}
+
 	return 0;
 }
 
diff --git a/rxclass.c b/rxclass.c
new file mode 100644
index 0000000..fd01a32
--- /dev/null
+++ b/rxclass.c
@@ -0,0 +1,809 @@
+/*
+ * Copyright (C) 2008 Sun Microsystems, Inc. All rights reserved.
+ */
+#include <stdio.h>
+#include <stdint.h>
+#include <stddef.h>
+#include <stdlib.h>
+#include <string.h>
+#include <strings.h>
+
+#include <linux/sockios.h>
+#include <arpa/inet.h>
+#include "ethtool-util.h"
+#include "ethtool-bitops.h"
+
+/*
+ * This is a rule manager implementation for ordering rx flow
+ * classification rules in a longest prefix first match order.
+ * The assumption is that this rule manager is the only one adding rules to
+ * the device's hardware classifier.
+ */
+
+struct rmgr_ctrl {
+	/* slot contains a bitmap indicating which filters are valid */
+	unsigned long		*slot;
+	__u32			n_rules;
+	__u32			size;
+};
+
+static struct rmgr_ctrl rmgr;
+static int rmgr_init_done = 0;
+
+#ifndef SIOCETHTOOL
+#define SIOCETHTOOL     0x8946
+#endif
+
+static void rmgr_print_ipv4_rule(struct ethtool_rx_flow_spec *fsp)
+{
+	char		chan[16];
+	char		l4_proto[16];
+	__u32		sip, dip, sipm, dipm;
+
+	sip = ntohl(fsp->h_u.tcp_ip4_spec.ip4src);
+	dip = ntohl(fsp->h_u.tcp_ip4_spec.ip4dst);
+	sipm = ntohl(fsp->m_u.tcp_ip4_spec.ip4src);
+	dipm = ntohl(fsp->m_u.tcp_ip4_spec.ip4dst);
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
+			"      IPv4 Rule:  ID[%d] Target[%s]\n"
+			"      IP src addr[%d.%d.%d.%d] mask[%d.%d.%d.%d]\n"
+			"      IP dst addr[%d.%d.%d.%d] mask[%d.%d.%d.%d]\n"
+			"      IP TOS[0x%x] mask[0x%x]\n",
+			fsp->location, chan,
+			(sip & 0xff000000) >> 24,
+			(sip & 0xff0000) >> 16,
+			(sip & 0xff00) >> 8,
+			sip & 0xff,
+			(sipm & 0xff000000) >> 24,
+			(sipm & 0xff0000) >> 16,
+			(sipm & 0xff00) >> 8,
+			sipm & 0xff,
+			(dip & 0xff000000) >> 24,
+			(dip & 0xff0000) >> 16,
+			(dip & 0xff00) >> 8,
+			dip & 0xff,
+			(dipm & 0xff000000) >> 24,
+			(dipm & 0xff0000) >> 16,
+			(dipm & 0xff00) >> 8,
+			dipm & 0xff,
+			fsp->h_u.tcp_ip4_spec.tos,
+			fsp->m_u.tcp_ip4_spec.tos);
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
+				ntohs(fsp->h_u.tcp_ip4_spec.psrc),
+				ntohs(fsp->m_u.tcp_ip4_spec.psrc),
+				ntohs(fsp->h_u.tcp_ip4_spec.pdst),
+				ntohs(fsp->m_u.tcp_ip4_spec.pdst));
+			break;
+		case AH_V4_FLOW:
+		case ESP_V4_FLOW:
+			fprintf(stdout,
+				"      L4 proto[%s]\n"
+				"      L4 SPI[%d] mask[0x%x]\n",
+				l4_proto,
+				ntohl(fsp->h_u.esp_ip4_spec.spi),
+				ntohl(fsp->m_u.esp_ip4_spec.spi));
+			break;
+		case IP_USER_FLOW:
+			fprintf(stdout,
+				"      L4 user proto[%d]\n"
+				"      L4 first 4 bytes[0x%x] mask[0x%x]\n",
+				fsp->h_u.usr_ip4_spec.proto,
+				ntohl(fsp->h_u.usr_ip4_spec.l4_4_bytes),
+				ntohl(fsp->m_u.usr_ip4_spec.l4_4_bytes));
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
+	fprintf(stdout, "\n\n");
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
+	case IP_USER_FLOW:
+		if (fsp->h_u.usr_ip4_spec.ip_ver == ETH_RX_NFC_IP4) {
+			rmgr_print_ipv4_rule(fsp);
+			break;
+		}
+		/* IPv6 User Flow falls through to the case below */
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+		fprintf(stderr, "IPv6 flows not implemented\n");
+		break;
+	default:
+		fprintf(stderr, "rmgr: Unknown flow type\n");
+		break;
+	}
+}
+
+static int rmgr_ins(__u32 loc)
+{
+	/* verify location is in rule manager range */
+	if ((loc < 0) || (loc >= rmgr.size)) {
+		fprintf(stderr, "rmgr: Location out of range\n");
+		return -1;
+	}
+
+	/* set bit for the rule */
+	set_bit(loc, rmgr.slot);
+
+	return 0;
+}
+
+static int rmgr_find(__u32 loc)
+{
+	/* verify location is in rule manager range */
+	if ((loc < 0) || (loc >= rmgr.size)) {
+		fprintf(stderr, "rmgr: Location out of range\n");
+		return -1;
+	}
+
+	/* if slot is found return 0 indicating success */
+	if (test_bit(loc, rmgr.slot))
+		return 0;
+
+	/* rule not found */
+	fprintf(stderr, "rmgr: No such rule\n");
+	return -1;
+}
+
+static int rmgr_del(__u32 loc)
+{
+	/* verify rule exists before attempting to delete */
+	int err = rmgr_find(loc);
+	if (err)
+		return err;
+
+	/* clear bit for the rule */
+	clear_bit(loc, rmgr.slot);
+
+	return 0;
+}
+
+static int rmgr_add(struct ethtool_rx_flow_spec *fsp, __u8 loc_valid)
+{
+	__u32 loc = fsp->location;
+
+	/* location provided, insert rule and update regions to match rule */
+	if (loc_valid)
+		return rmgr_ins(loc);
+
+	/* find an open slot */
+	for (loc = 0; loc < rmgr.size; loc += BITS_PER_LONG) {
+		if ((rmgr.slot[loc / BITS_PER_LONG]) != ~0UL)
+			break;
+	}
+
+	/* find and use available location in slot */
+	for (; loc < rmgr.size; loc++) {
+		if (!test_bit(loc, rmgr.slot)) {
+			fsp->location = loc;
+			return rmgr_ins(loc);
+		}
+	}
+
+	/* No space to add this rule */
+	fprintf(stderr, "rmgr: Cannot find appropriate slot to insert rule\n");
+
+	return -1;
+}
+
+static int rmgr_init(int fd, struct ifreq *ifr)
+{
+	struct ethtool_rxnfc *nfccmd;
+	int err, i;
+	__u32 *rule_locs;
+
+	if (rmgr_init_done)
+		return 0;
+
+	/* clear rule manager settings */
+	bzero((void *)&rmgr, sizeof(struct rmgr_ctrl));
+
+	/* allocate memory for count request */
+	nfccmd = calloc(1, sizeof(*nfccmd));
+	if (!nfccmd) {
+		perror("rmgr: Cannot allocate memory for RX class rule data");
+		return -1;
+	}
+
+	/* request count and store in rmgr.n_rules */
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
+	/* alloc memory for request of location list */
+	nfccmd = calloc(1, sizeof(*nfccmd) + (rmgr.n_rules * sizeof(__u32)));
+	if (!nfccmd) {
+		perror("rmgr: Cannot allocate memory for RX class rule locations");
+		return -1;
+	}
+
+	/* request location list */
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
+	/* intitialize bitmap for storage of valid locations */
+	rmgr.size = nfccmd->data;
+	rmgr.slot = calloc(1, BITS_TO_LONGS(rmgr.size) * sizeof(long));
+	if (!rmgr.slot) {
+		perror("rmgr: Cannot allocate memory for RX class rules");
+		return -1;
+	}
+
+	/* write locations to bitmap */
+	rule_locs = nfccmd->rule_locs;
+	for (i = 0; i < rmgr.n_rules; i++) {
+		err = rmgr_ins(rule_locs[i]);
+		if (err < 0)
+			break;
+	}
+
+	/* free memory and set flag to avoid reinit */
+	free(nfccmd);
+	rmgr_init_done = 1;
+
+	return err;
+}
+
+static void rmgr_cleanup(void)
+{
+	if (!rmgr_init_done)
+		return;
+
+	rmgr_init_done = 0;
+
+	free(rmgr.slot);
+	rmgr.slot = NULL;
+	rmgr.size = 0;
+}
+
+int rxclass_rule_getall(int fd, struct ifreq *ifr)
+{
+	struct ethtool_rxnfc nfccmd;
+	int err, i, j;
+
+	/* init table of available rules */
+	err = rmgr_init(fd, ifr);
+	if (err < 0)
+		return err;
+
+	fprintf(stdout, "Total %d rules\n\n", rmgr.n_rules);
+
+	/* fetch and display all available rules */
+	for (i = 0; i < rmgr.size; i += BITS_PER_LONG) {
+		if (rmgr.slot[i / BITS_PER_LONG] == 0UL)
+			continue;
+		for (j = 0; j < BITS_PER_LONG; j++) {
+			if (!test_bit(i + j, rmgr.slot))
+				continue;
+			nfccmd.cmd = ETHTOOL_GRXCLSRULE;
+			bzero(&nfccmd.fs, sizeof(struct ethtool_rx_flow_spec));
+			nfccmd.fs.location = i + j;
+			ifr->ifr_data = (caddr_t)&nfccmd;
+			err = ioctl(fd, SIOCETHTOOL, ifr);
+			if (err < 0) {
+				perror("rmgr: Cannot get RX class rule");
+				return -1;
+			}
+			rmgr_print_rule(&nfccmd.fs);
+		}
+	}
+
+	rmgr_cleanup();
+
+	return 0;
+}
+
+int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc)
+{
+	struct ethtool_rxnfc nfccmd;
+	int err;
+
+	/* init table of available rules */
+	err = rmgr_init(fd, ifr);
+	if (err < 0)
+		return err;
+
+	/* verify rule exists before attempting to display */
+	err = rmgr_find(loc);
+	if (err < 0)
+		return err;
+
+	/* fetch rule from netdev and display */
+	nfccmd.cmd = ETHTOOL_GRXCLSRULE;
+	bzero(&nfccmd.fs, sizeof(struct ethtool_rx_flow_spec));
+	nfccmd.fs.location = loc;
+	ifr->ifr_data = (caddr_t)&nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("rmgr: Cannot get RX class rule");
+		return -1;
+	}
+	rmgr_print_rule(&nfccmd.fs);
+
+	rmgr_cleanup();
+
+	return 0;
+}
+
+int rxclass_rule_ins(int fd, struct ifreq *ifr,
+		     struct ethtool_rx_flow_spec *fsp, __u8 loc_valid)
+{
+	struct ethtool_rxnfc nfccmd;
+	int err;
+
+	/* init table of available rules */
+	err = rmgr_init(fd, ifr);
+	if (err < 0)
+		return err;
+
+	/* verify rule location */
+	err = rmgr_add(fsp, loc_valid);
+	if (err < 0)
+		return err;
+
+	/* notify netdev of new rule */
+	nfccmd.cmd = ETHTOOL_SRXCLSRLINS;
+	nfccmd.fs = *fsp;
+	ifr->ifr_data = (caddr_t)&nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("rmgr: Cannot insert RX class rule");
+		return -1;
+	}
+	rmgr.n_rules++;
+
+	printf("Added rule with ID %d\n", fsp->location);
+
+	rmgr_cleanup();
+
+	return 0;
+}
+
+int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc)
+{
+	struct ethtool_rxnfc nfccmd;
+	int err;
+
+	/* init table of available rules */
+	err = rmgr_init(fd, ifr);
+	if (err < 0)
+		return err;
+
+	/* verify rule exists */
+	err = rmgr_del(loc);
+	if (err < 0)
+		return err;
+
+	/* notify netdev of rule removal */
+	nfccmd.cmd = ETHTOOL_SRXCLSRLDEL;
+	nfccmd.fs.location = loc;
+	ifr->ifr_data = (caddr_t)&nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("rmgr: Cannot delete RX class rule");
+		return -1;
+	}
+	rmgr.n_rules--;
+
+	rmgr_cleanup();
+
+	return 0;
+}
+
+int rxclass_parse_ruleopts(char **optstr, int opt_cnt,
+			   struct ethtool_rx_flow_spec *fsp,
+			   u_int8_t *loc_valid)
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
+		fprintf(stdout, "Add rule, invalid syntax\n");
+		return -1;
+	}
+
+	bzero(fsp, sizeof(struct ethtool_rx_flow_spec));
+	ipsa = ipda = ipsm = ipdm = spi = spim = 0x0;
+	sp = dp = spm = dpm = 0x0;
+	ip_ver = proto = tos = tm = 0x0;
+	discard = ring_set = 0;
+
+	if (!strcmp(optstr[i], "ip4")) {
+		ip_ver = ETH_RX_NFC_IP4;
+	} else if (!strcmp(optstr[i], "ip6")) {
+		fprintf(stdout, "IPv6 not yet implemented\n");
+		return -1;
+	} else {
+		fprintf(stdout, "Add rule, invalid syntax for IP version\n");
+		return -1;
+	}
+
+	i++;
+
+	switch (ip_ver) {
+	case ETH_RX_NFC_IP4:
+		if (!strcmp(optstr[i], "tcp"))
+			fsp->flow_type = TCP_V4_FLOW;
+		else if (!strcmp(optstr[i], "udp"))
+			fsp->flow_type = UDP_V4_FLOW;
+		else if (!strcmp(optstr[i], "sctp"))
+			fsp->flow_type = SCTP_V4_FLOW;
+		else if (!strcmp(optstr[i], "ah"))
+			fsp->flow_type = AH_V4_FLOW;
+		else if (!strcmp(optstr[i], "esp"))
+			fsp->flow_type = ESP_V4_FLOW;
+		break;
+	default:
+		fprintf(stdout, "Add rule, Invalid IP version %d\n", ip_ver);
+			return -1;
+	}
+
+	if (fsp->flow_type == 0) {
+		proto = (u_int8_t)strtoul(optstr[i], (char **)NULL, 0);
+		if (proto != 0) {
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
+	for (i = 2; i < opt_cnt;) {
+		if (!strcmp(optstr[i], "tos")) {
+			tos = (u_int8_t)strtoul(optstr[i+1], (char **)NULL,
+						 0);
+			tm = 0xff;
+			fsp->h_u.tcp_ip4_spec.tos = tos;
+
+			i += 2;
+			if (opt_cnt > (i+1)) {
+				if (!strcmp(optstr[i], "m")) {
+					tm = (u_int8_t)strtoul(optstr[i+1],
+							       (char **)NULL,
+							       16);
+					i += 2;
+				}
+			}
+			fsp->m_u.tcp_ip4_spec.tos = tm;
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
+				ipsa = ntohl(in_addr.s_addr);
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
+						if (!inet_pton(AF_INET,
+							       optstr[i+1],
+							       &in_addr)) {
+							fprintf(stdout,
+								"Invalid smask"
+								"[%s]\n",
+								optstr[i+1]);
+								return -1;
+						}
+						ipsm = ntohl(in_addr.s_addr);
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
+				ipda = ntohl(in_addr.s_addr);
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
+						if (!inet_pton(AF_INET,
+							       optstr[i+1],
+							       &in_addr)) {
+							fprintf(stdout,
+								"Invalid dmask"
+								"[%s]\n",
+								optstr[i+1]);
+								return -1;
+						}
+						ipdm = ntohl(in_addr.s_addr);
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
+			sp = (u_int16_t)strtoul(optstr[i+1], (char **)NULL,
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
+								 (char **)NULL,
+								 16);
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
+			dp = (u_int16_t)strtoul(optstr[i+1], (char **)NULL,
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
+								 (char **)NULL,
+								 16);
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
+			spi = (u_int32_t)strtoul(optstr[i+1], (char **)NULL,
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
+								 (char **)NULL,
+								 16);
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
+						  0);
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
+			*loc_valid = 1;
+		} else {
+			fprintf(stdout, "Add rule, invalid syntax\n");
+			return -1;
+		}
+	}
+
+	/* Convert all multibyte network fields to network byte order */
+	fsp->h_u.tcp_ip4_spec.ip4src = htonl(fsp->h_u.tcp_ip4_spec.ip4src);
+	fsp->h_u.tcp_ip4_spec.ip4dst = htonl(fsp->h_u.tcp_ip4_spec.ip4dst);
+	fsp->m_u.tcp_ip4_spec.ip4src = htonl(fsp->m_u.tcp_ip4_spec.ip4src);
+	fsp->m_u.tcp_ip4_spec.ip4dst = htonl(fsp->m_u.tcp_ip4_spec.ip4dst);
+
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+		fsp->h_u.tcp_ip4_spec.psrc = htons(fsp->h_u.tcp_ip4_spec.psrc);
+		fsp->h_u.tcp_ip4_spec.pdst = htons(fsp->h_u.tcp_ip4_spec.pdst);
+		fsp->m_u.tcp_ip4_spec.psrc = htons(fsp->m_u.tcp_ip4_spec.psrc);
+		fsp->m_u.tcp_ip4_spec.pdst = htons(fsp->m_u.tcp_ip4_spec.pdst);
+		break;
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+		fsp->h_u.esp_ip4_spec.spi = htonl(fsp->h_u.esp_ip4_spec.spi);
+		fsp->m_u.esp_ip4_spec.spi = htonl(fsp->m_u.esp_ip4_spec.spi);
+		break;
+	case IP_USER_FLOW:
+		fsp->h_u.usr_ip4_spec.l4_4_bytes =
+			htonl(fsp->h_u.usr_ip4_spec.l4_4_bytes);
+		fsp->m_u.usr_ip4_spec.l4_4_bytes =
+			htonl(fsp->m_u.usr_ip4_spec.l4_4_bytes);
+		break;
+	default:
+		break;
+	}
+
+	return 0;
+}

