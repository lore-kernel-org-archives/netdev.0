From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 3/4] v2 Add RX packet classification interface
Date: Fri, 25 Feb 2011 15:48:56 -0800
Message-ID: <20110225234856.8409.9562.stgit@gitlad.jf.intel.com>
References: <20110225233902.8409.74474.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54044 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756479Ab1BYXtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:49:09 -0500
In-Reply-To: <20110225233902.8409.74474.stgit@gitlad.jf.intel.com>
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

This patch now also merges the functionality of the packet classification
into the ntuple interface.  This is done by using the key word flow-type to
indicate the addition of an ntuple, class-rule-add to indicate the addition
of a network flow classifier, and class-rule-del to indicate the deletion
of a network flow classifier. Since ntuple display functionality was
already removed I have made the defalt for the -u option to display the
number of rings and all network flow classification filters.  If a single
rule is requested via class-rule %d then only that rule will be displayed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 Makefile.am      |    3 
 ethtool-bitops.h |   25 +
 ethtool-util.h   |   42 ++
 ethtool.8.in     |  198 +++++----
 ethtool.c        |  284 ++++++-------
 rxclass.c        | 1169 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 1459 insertions(+), 262 deletions(-)
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
index 0000000..93d32a4
--- /dev/null
+++ b/ethtool-bitops.h
@@ -0,0 +1,25 @@
+#ifndef ETHTOOL_BITOPS_H__
+#define ETHTOOL_BITOPS_H__
+
+#define BITS_PER_BYTE		8
+#define BITS_PER_LONG		BITS_PER_BYTE * sizeof(long)
+#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
+#define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_LONG)
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
index f053028..182658b 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -5,15 +5,18 @@
 
 #include <sys/types.h>
 #include <endian.h>
+#include <sys/ioctl.h>
+#include <net/if.h>
+#include "ethtool-config.h"
+#include "ethtool-copy.h"
 
 /* ethtool.h expects these to be defined by <linux/types.h> */
 #ifndef HAVE_BE_TYPES
 typedef __uint16_t __be16;
 typedef __uint32_t __be32;
+typedef unsigned long long __be64;
 #endif
 
-#include "ethtool-copy.h"
-
 typedef unsigned long long u64;
 typedef __uint32_t u32;
 typedef __uint16_t u16;
@@ -23,11 +26,15 @@ typedef __int32_t s32;
 #if __BYTE_ORDER == __BIG_ENDIAN
 static inline u16 cpu_to_be16(u16 value)
 {
-    return value;
+	return value;
 }
 static inline u32 cpu_to_be32(u32 value)
 {
-    return value;
+	return value;
+}
+static inline u64 cpu_to_be64(u64 value)
+{
+	return value;
 }
 #else
 static inline u16 cpu_to_be16(u16 value)
@@ -38,6 +45,21 @@ static inline u32 cpu_to_be32(u32 value)
 {
 	return cpu_to_be16(value >> 16) | (cpu_to_be16(value) << 16);
 }
+static inline u64 cpu_to_be64(u64 value)
+{
+	return cpu_to_be32(value >> 32) | ((u64)cpu_to_be32(value) << 32);
+}
+#endif
+
+#define ntohll cpu_to_be64
+#define htonll cpu_to_be64
+
+#ifndef ARRAY_SIZE
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
+#endif
+
+#ifndef SIOCETHTOOL
+#define SIOCETHTOOL     0x8946
 #endif
 
 /* National Semiconductor DP83815, DP83816 */
@@ -103,4 +125,14 @@ int sfc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 			struct ethtool_regs *regs);
 int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
-#endif
+
+/* Rx flow classification */
+int rxclass_parse_ruleopts(char **optstr, int opt_cnt,
+			   void *fsp, __u8 *loc_valid);
+int rxclass_rule_getall(int fd, struct ifreq *ifr);
+int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc);
+int rxclass_rule_ins(int fd, struct ifreq *ifr,
+		     struct ethtool_rx_flow_spec *fsp, __u8 loc_valid);
+int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc);
+
+#endif /* ETHTOOL_UTIL_H__ */
diff --git a/ethtool.8.in b/ethtool.8.in
index 7dec259..b68b010 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -40,10 +40,20 @@
 [\\fB\\$1\\fP\ \\fIN\\fP]
 ..
 .\"
+.\"	.BM - same as above but has a mask field for format "[value N [value-mask N]]"
+.\"
+.de BM
+[\\fB\\$1\\fP\ \\fIN\\fP\ [\\fB\\$1\-mask\\fP\ \\fIN\\fP]]
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
@@ -55,6 +65,12 @@
 .\"	\(*HO - hash options
 .\"
 .ds HO \fBm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
+.\"
+.\"	\(*NC - Network Classifier type values
+.\"
+.ds NC \fBether\fP|\fBip4\fP|\fBtcp4\fP|\fBudp4\fP|\fBsctp4\fP|\fBah4\fP|\fBesp4\fP
+
+.\"
 .\" Start URL.
 .de UR
 .  ds m1 \\$1\"
@@ -227,8 +243,7 @@ ethtool \- query or control network driver and hardware settings
 
 .B ethtool \-N
 .I ethX
-.RB [ rx-flow-hash \ \*(FL
-.RB \ \*(HO]
+.RB [ rx-flow-hash \ \*(FL \  \*(HO]
 
 .B ethtool \-x|\-\-show\-rxfh\-indir
 .I ethX
@@ -248,51 +263,38 @@ ethtool \- query or control network driver and hardware settings
 
 .B ethtool \-u|\-\-show\-ntuple
 .I ethX
+.BN class-rule
 
-.TP
 .BI ethtool\ \-U|\-\-config\-ntuple \ ethX
-.RB {
-.A3 flow-type tcp4 udp4 sctp4
-.RB [ src-ip
-.IR addr
-.RB [ src-ip-mask
-.IR mask ]]
-.RB [ dst-ip
-.IR addr
-.RB [ dst-ip-mask
-.IR mask ]]
-.RB [ src-port
-.IR port
-.RB [ src-port-mask
-.IR mask ]]
-.RB [ dst-port
-.IR port
-.RB [ dst-port-mask
-.IR mask ]]
-.br
-.RB | \ flow-type\ ether
-.RB [ src
-.IR mac-addr
-.RB [ src-mask
-.IR mask ]]
-.RB [ dst
-.IR mac-addr
-.RB [ dst-mask
-.IR mask ]]
-.RB [ proto
-.IR N
-.RB [ proto-mask
-.IR mask ]]\ }
-.br
-.RB [ vlan
-.IR VLAN-tag
-.RB [ vlan-mask
-.IR mask ]]
-.RB [ user-def
-.IR data
-.RB [ user-def-mask
-.IR mask ]]
-.RI action \ N
+.BN class-rule-del
+.RB [\  class-rule-add \ \*(NC
+.RB [ src \ \*(MA\ [ src-mask \ \*(MA]]
+.RB [ dst \ \*(MA\ [ dst-mask \ \*(MA]]
+.BM proto
+.RB [ src-ip \ \*(PA\ [ src-ip-mask \ \*(PA]]
+.RB [ dst-ip \ \*(PA\ [ dst-ip-mask \ \*(PA]]
+.BM tos
+.BM l4proto
+.BM src-port
+.BM dst-port
+.BM spi
+.BN action
+.BN loc
+.RB \ |\  flow-type \ \*(NC
+.RB [ src \ \*(MA\ [ src-mask \ \*(MA]]
+.RB [ dst \ \*(MA\ [ dst-mask \ \*(MA]]
+.BM proto
+.RB [ src-ip \ \*(PA\ [ src-ip-mask \ \*(PA]]
+.RB [ dst-ip \ \*(PA\ [ dst-ip-mask \ \*(PA]]
+.BM tos
+.BM l4proto
+.BM src-port
+.BM dst-port
+.BM spi
+.BM vlan
+.BM user-def
+.BN action
+.RB ]
 
 .SH DESCRIPTION
 .BI ethtool
@@ -654,7 +656,8 @@ Hash on bytes 0 and 1 of the Layer 4 header of the rx packet.
 Hash on bytes 2 and 3 of the Layer 4 header of the rx packet.
 .TP 3
 .B r
-Discard all packets of this flow type. When this option is set, all other options are ignored.
+Discard all packets of this flow type. When this option is set, all
+other options are ignored.
 .PD
 .RE
 .TP
@@ -685,14 +688,23 @@ Default region is 0 which denotes all regions in the flash.
 .TP
 .B \-u \-\-show-ntuple
 Get Rx ntuple filters and actions, then display them to the user.
+.TP
+.BI class-rule \ N
+Retrieves the RX classification rule with the given ID.
 .PD
 .RE
 .TP
 .B \-U \-\-config-ntuple
 Configure Rx ntuple filters and actions
 .TP
-.B flow-type tcp4|udp4|sctp4|ether
+.BI class-rule-del \ N
+Deletes the RX classification rule with the given ID.
+.PP
+.BR class-rule-add \ \*(NC
+.br
+.BR flow-type \ \*(NC
 .RS
+Adds an RX packet classification rule.
 .PD 0
 .TP 3
 .BR "tcp4" "    TCP over IPv4"
@@ -701,78 +713,80 @@ Configure Rx ntuple filters and actions
 .TP 3
 .BR "sctp4" "   SCTP over IPv4"
 .TP 3
+.BR "ah4" "     IPSEC AH over IPv4"
+.TP 3
+.BR "esp4" "    IPSEC ESP over IPv4"
+.TP 3
+.BR "ip4" "     Raw IPv4"
+.TP 3
 .BR "ether" "   Ethernet"
 .PD
 .RE
 .TP
-.BI src-ip \ addr
-Includes the source IP address, specified using dotted-quad notation
-or as a single 32-bit number.
-.TP
-.BI src-ip-mask \ mask
-Specify a mask for the source IP address.
-.TP
-.BI dst-ip \ addr
-Includes the destination IP address.
-.TP
-.BI dst-ip-mask \ mask
-Specify a mask for the destination IP address.
-.TP
-.BI src-port \ port
-Includes the source port.
-.TP
-.BI src-port-mask \ mask
-Specify a mask for the source port.
-.TP
-.BI dst-port \ port
-Includes the destination port.
+.BR src \ \*(MA\ [ src-mask \ \*(MA]
+Includes the source MAC address, specified as 6 bytes in hexadecimal
+separated by colons, along with an optional mask.
 .TP
-.BI dst-port-mask \ mask
-Specify a mask for the destination port.
+.BR dst \ \*(MA\ [ src-mask \ \*(MA]
+Includes the destination MAC address, specified as 6 bytes in hexadecimal
+separated by colons, along with an optional mask.
 .TP
-.BI src \ mac-addr
-Includes the source MAC address, specified as 6 bytes in hexadecimal
-separated by colons.
+.BI proto \ N \\fR\ [\\fPproto-mask \ N \\fR]\\fP
+Includes the Ethernet protocol number (ethertype) and an optional mask.
 .TP
-.BI src-mask \ mask
-Specify a mask for the source MAC address.
+.BR src-ip \ \*(PA\ [ src-ip-mask \ \*(PA]
+Specify the source IP address of the incoming packet to
+match along with an optional mask.
 .TP
-.BI dst \ mac-addr
-Includes the destination MAC address.
+.BR dst-ip \ \*(PA\ [ dst-ip-mask \ \*(PA]
+Specify the destination IP address of the incoming packet to
+match along with an optional mask.
 .TP
-.BI dst-mask \ mask
-Specify a mask for the destination MAC address.
+.BI tos \ N \\fR\ [\\fPtos-mask \ N \\fR]\\fP
+Specify the value of the Type of Service field in the incoming packet to
+match along with an optional mask.
 .TP
-.BI proto \ N
-Includes the Ethernet protocol number (ethertype).
+.BI l4proto \ N \\fR\ [\\fPl4proto-mask \ N \\fR]\\fP
+Includes the layer 4 protocol number and optional mask.
 .TP
-.BI proto-mask \ mask
-Specify a mask for the Ethernet protocol number.
+.BI src-port \ N \\fR\ [\\fPsrc-port-mask \ N \\fR]\\fP
+Specify the value of the source port field (applicable to
+TCP/UDP packets)in the incoming packet to match along with an
+optional mask.
 .TP
-.BI vlan \ VLAN-tag
-Includes the VLAN tag.
+.BI dst-port \ N \\fR\ [\\fPdst-port-mask \ N \\fR]\\fP
+Specify the value of the destination port field (applicable to
+TCP/UDP packets)in the incoming packet to match along with an
+optional mask.
 .TP
-.BI vlan-mask \ mask
-Specify a mask for the VLAN tag.
+.BI spi \ N \\fR\ [\\fPspi-mask \ N \\fR]\\fP
+Specify the value of the security parameter index field (applicable to
+AH/ESP packets)in the incoming packet to match along with an
+optional mask.
 .TP
-.BI user-def \ data
-Includes 64-bits of user-specific data.
+.BI vlan \ N \\fR\ [\\fPvlan-mask \ N \\fR]\\fP
+Includes the VLAN tag and an optional mask.
 .TP
-.BI user-def-mask \ mask
-Specify a mask for the user-specific data.
+.BI user-def \ N \\fR\ [\\fPuser-def-mask \ N \\fR]\\fP
+Includes 64-bits of user-specific data and an optional mask.
 .TP
 .BI action \ N
 Specifies the Rx queue to send packets to, or some other action.
 .RS
 .PD 0
 .TP 3
-.BR "-2" "             Clear the filter"
+.BR "-2" "             Clear the filter (ntuple only)"
 .TP 3
 .BR "-1" "             Drop the matched flow"
 .TP 3
 .BR "0 or higher" "    Rx queue to route the flow"
 .PD
 .RE
+.TP
+.BI loc \ N
+Specify the location/ID to insert the rule. This will overwrite
+any rule present in that location and will not go through any
+of the rule ordering process.
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index 2a084db..f4dfc39 100644
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
@@ -43,18 +45,13 @@
 #include <arpa/inet.h>
 
 #include <linux/sockios.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
 #include "ethtool-util.h"
 
-
-#ifndef SIOCETHTOOL
-#define SIOCETHTOOL     0x8946
-#endif
 #ifndef MAX_ADDR_LEN
 #define MAX_ADDR_LEN	32
 #endif
-#ifndef ARRAY_SIZE
-#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
-#endif
 
 #ifndef HAVE_NETIF_MSG
 enum {
@@ -100,7 +97,6 @@ static int do_gstats(int fd, struct ifreq *ifr);
 static int rxflow_str_to_type(const char *str);
 static int parse_rxfhashopts(char *optstr, u32 *data);
 static char *unparse_rxfhashopts(u64 opts);
-static void parse_rxntupleopts(int argc, char **argp, int first_arg);
 static int dump_rxfhash(int fhash, u64 val);
 static int do_srxclass(int fd, struct ifreq *ifr);
 static int do_grxclass(int fd, struct ifreq *ifr);
@@ -246,20 +242,37 @@ static struct option {
 		"		equal N | weight W0 W1 ...\n" },
     { "-U", "--config-ntuple", MODE_SNTUPLE, "Configure Rx ntuple filters "
 		"and actions",
-		"		{ flow-type tcp4|udp4|sctp4\n"
-		"		  [ src-ip ADDR [src-ip-mask MASK] ]\n"
-		"		  [ dst-ip ADDR [dst-ip-mask MASK] ]\n"
-		"		  [ src-port PORT [src-port-mask MASK] ]\n"
-		"		  [ dst-port PORT [dst-port-mask MASK] ]\n"
-		"		| flow-type ether\n"
-		"		  [ src MAC-ADDR [src-mask MASK] ]\n"
-		"		  [ dst MAC-ADDR [dst-mask MASK] ]\n"
-		"		  [ proto N [proto-mask MASK] ] }\n"
-		"		[ vlan VLAN-TAG [vlan-mask MASK] ]\n"
-		"		[ user-def DATA [user-def-mask MASK] ]\n"
-		"		action N\n" },
+		"		[ class-rule-del %d ]\n"
+		"		[ class-rule-add ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
+		"			[ src %x:%x:%x:%x:%x:%x [src-mask %x:%x:%x:%x:%x:%x] ]\n"
+		"			[ dst %x:%x:%x:%x:%x:%x [dst-mask %x:%x:%x:%x:%x:%x] ]\n"
+		"			[ proto %d [proto-mask MASK] ]\n"
+		"			[ src-ip %d.%d.%d.%d [src-ip-mask %d.%d.%d.%d] ]\n"
+		"			[ dst-ip %d.%d.%d.%d [dst-ip-mask %d.%d.%d.%d] ]\n"
+		"			[ tos %d [tos-mask %x] ]\n"
+		"			[ l4proto %d [l4proto-mask MASK] ]\n"
+		"			[ src-port %d [src-port-mask %x] ]\n"
+		"			[ dst-port %d [dst-port-mask %x] ]\n"
+		"			[ spi %d [spi-mask %x] ]\n"
+		"			[ action %d ]\n"
+		"			[ loc %d] |\n"
+		"		  flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
+		"			[ src %x:%x:%x:%x:%x:%x [src-mask %x:%x:%x:%x:%x:%x] ]\n"
+		"			[ dst %x:%x:%x:%x:%x:%x [dst-mask %x:%x:%x:%x:%x:%x] ]\n"
+		"			[ proto %d [proto-mask MASK] ]\n"
+		"			[ src-ip %d.%d.%d.%d [src-ip-mask %d.%d.%d.%d] ]\n"
+		"			[ dst-ip %d.%d.%d.%d [dst-ip-mask %d.%d.%d.%d] ]\n"
+		"			[ tos %d [tos-mask %x] ]\n"
+		"			[ l4proto %d [l4proto-mask MASK] ]\n"
+		"			[ src-port %d [src-port-mask %x] ]\n"
+		"			[ dst-port %d [dst-port-mask %x] ]\n"
+		"			[ spi %d [spi-mask %x] ]\n"
+		"			[ vlan %x [vlan-mask %x] ]\n"
+		"			[ user-def %x [user-def-mask %x] ]\n"
+		"			[ action %d ] ]\n" },
     { "-u", "--show-ntuple", MODE_GNTUPLE,
-		"Get Rx ntuple filters and actions\n" },
+		"Get Rx ntuple filters and actions",
+		"		[ class-rule %d ]\n"},
     { "-P", "--show-permaddr", MODE_PERMADDR,
 		"Show permanent hardware address" },
     { "-h", "--help", MODE_HELP, "Show this help" },
@@ -381,24 +394,6 @@ static int rxfhindir_equal = 0;
 static char **rxfhindir_weight = NULL;
 static int sntuple_changed = 0;
 static struct ethtool_rx_ntuple_flow_spec ntuple_fs;
-static int ntuple_ip4src_seen = 0;
-static int ntuple_ip4src_mask_seen = 0;
-static int ntuple_ip4dst_seen = 0;
-static int ntuple_ip4dst_mask_seen = 0;
-static int ntuple_psrc_seen = 0;
-static int ntuple_psrc_mask_seen = 0;
-static int ntuple_pdst_seen = 0;
-static int ntuple_pdst_mask_seen = 0;
-static int ntuple_ether_dst_seen = 0;
-static int ntuple_ether_dst_mask_seen = 0;
-static int ntuple_ether_src_seen = 0;
-static int ntuple_ether_src_mask_seen = 0;
-static int ntuple_ether_proto_seen = 0;
-static int ntuple_ether_proto_mask_seen = 0;
-static int ntuple_vlan_tag_seen = 0;
-static int ntuple_vlan_tag_mask_seen = 0;
-static int ntuple_user_def_seen = 0;
-static int ntuple_user_def_mask_seen = 0;
 static char *flash_file = NULL;
 static int flash = -1;
 static int flash_region = -1;
@@ -407,6 +402,12 @@ static int msglvl_changed;
 static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
 
+static int rx_class_rule_get = -1;
+static int rx_class_rule_del = -1;
+static int rx_class_rule_added = 0;
+static struct ethtool_rx_flow_spec rx_rule_fs;
+static u8 rxclass_loc_valid = 0;
+
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -519,58 +520,6 @@ static struct cmdline_info cmdline_coalesce[] = {
 	{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted, &ecoal.tx_max_coalesced_frames_high },
 };
 
-static struct cmdline_info cmdline_ntuple_tcp_ip4[] = {
-	{ "src-ip", CMDL_IP4, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL,
-	  0, &ntuple_ip4src_seen },
-	{ "src-ip-mask", CMDL_IP4, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL,
-	  0, &ntuple_ip4src_mask_seen },
-	{ "dst-ip", CMDL_IP4, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL,
-	  0, &ntuple_ip4dst_seen },
-	{ "dst-ip-mask", CMDL_IP4, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL,
-	  0, &ntuple_ip4dst_mask_seen },
-	{ "src-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.psrc, NULL,
-	  0, &ntuple_psrc_seen },
-	{ "src-port-mask", CMDL_BE16, &ntuple_fs.m_u.tcp_ip4_spec.psrc, NULL,
-	  0, &ntuple_psrc_mask_seen },
-	{ "dst-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.pdst, NULL,
-	  0, &ntuple_pdst_seen },
-	{ "dst-port-mask", CMDL_BE16, &ntuple_fs.m_u.tcp_ip4_spec.pdst, NULL,
-	  0, &ntuple_pdst_mask_seen },
-	{ "vlan", CMDL_U16, &ntuple_fs.vlan_tag, NULL,
-	  0, &ntuple_vlan_tag_seen },
-	{ "vlan-mask", CMDL_U16, &ntuple_fs.vlan_tag_mask, NULL,
-	  0, &ntuple_vlan_tag_mask_seen },
-	{ "user-def", CMDL_U64, &ntuple_fs.data, NULL,
-	  0, &ntuple_user_def_seen },
-	{ "user-def-mask", CMDL_U64, &ntuple_fs.data_mask, NULL,
-	  0, &ntuple_user_def_mask_seen },
-	{ "action", CMDL_S32, &ntuple_fs.action, NULL },
-};
-
-static struct cmdline_info cmdline_ntuple_ether[] = {
-	{ "dst", CMDL_MAC, ntuple_fs.h_u.ether_spec.h_dest, NULL,
-	  0, &ntuple_ether_dst_seen },
-	{ "dst-mask", CMDL_MAC, ntuple_fs.m_u.ether_spec.h_dest, NULL,
-	  0, &ntuple_ether_dst_mask_seen },
-	{ "src", CMDL_MAC, ntuple_fs.h_u.ether_spec.h_source, NULL,
-	  0, &ntuple_ether_src_seen },
-	{ "src-mask", CMDL_MAC, ntuple_fs.m_u.ether_spec.h_source, NULL,
-	  0, &ntuple_ether_src_mask_seen },
-	{ "proto", CMDL_BE16, &ntuple_fs.h_u.ether_spec.h_proto, NULL,
-	  0, &ntuple_ether_proto_seen },
-	{ "proto-mask", CMDL_BE16, &ntuple_fs.m_u.ether_spec.h_proto, NULL,
-	  0, &ntuple_ether_proto_mask_seen },
-	{ "vlan", CMDL_U16, &ntuple_fs.vlan_tag, NULL,
-	  0, &ntuple_vlan_tag_seen },
-	{ "vlan-mask", CMDL_U16, &ntuple_fs.vlan_tag_mask, NULL,
-	  0, &ntuple_vlan_tag_mask_seen },
-	{ "user-def", CMDL_U64, &ntuple_fs.data, NULL,
-	  0, &ntuple_user_def_seen },
-	{ "user-def-mask", CMDL_U64, &ntuple_fs.data_mask, NULL,
-	  0, &ntuple_user_def_mask_seen },
-	{ "action", CMDL_S32, &ntuple_fs.action, NULL },
-};
-
 static struct cmdline_info cmdline_msglvl[] = {
 	{ "drv", CMDL_FLAG, &msglvl_wanted, NULL,
 	  NETIF_MSG_DRV, &msglvl_mask },
@@ -924,14 +873,49 @@ static void parse_cmdline(int argc, char **argp)
 			}
 			if (mode == MODE_SNTUPLE) {
 				if (!strcmp(argp[i], "flow-type")) {
+					if (rxclass_parse_ruleopts(&argp[i],
+								   argc - i,
+								   &ntuple_fs,
+								   NULL) < 0) {
+						show_usage(1);
+					} else {
+						i = argc;
+						sntuple_changed = 1;
+					}
+				} else if (!strcmp(argp[i], "class-rule-del")) {
 					i += 1;
 					if (i >= argc) {
 						show_usage(1);
 						break;
 					}
-					parse_rxntupleopts(argc, argp, i);
-					i = argc;
-					break;
+					rx_class_rule_del =
+						get_uint_range(argp[i], 0,
+							       INT_MAX);
+				} else if (!strcmp(argp[i], "class-rule-add")) {
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
+					show_usage(1);
+				}
+				break;
+			}
+			if (mode == MODE_GNTUPLE) {
+				if (!strcmp(argp[i], "class-rule")) {
+					i += 1;
+					if (i >= argc) {
+						show_usage(1);
+						break;
+					}
+					rx_class_rule_get =
+						get_uint_range(argp[i], 0,
+							       INT_MAX);
 				} else {
 					show_usage(1);
 				}
@@ -981,8 +965,10 @@ static void parse_cmdline(int argc, char **argp)
 						show_usage(1);
 					else
 						rx_fhash_changed = 1;
-				} else
+				} else {
 					show_usage(1);
+				}
+
 				break;
 			}
 			if (mode == MODE_SRXFHINDIR) {
@@ -1594,66 +1580,6 @@ static char *unparse_rxfhashopts(u64 opts)
 	return buf;
 }
 
-static void parse_rxntupleopts(int argc, char **argp, int i)
-{
-	ntuple_fs.flow_type = rxflow_str_to_type(argp[i]);
-
-	switch (ntuple_fs.flow_type) {
-	case TCP_V4_FLOW:
-	case UDP_V4_FLOW:
-	case SCTP_V4_FLOW:
-		parse_generic_cmdline(argc, argp, i + 1,
-				      &sntuple_changed,
-				      cmdline_ntuple_tcp_ip4,
-				      ARRAY_SIZE(cmdline_ntuple_tcp_ip4));
-		if (!ntuple_ip4src_seen)
-			ntuple_fs.m_u.tcp_ip4_spec.ip4src = 0xffffffff;
-		if (!ntuple_ip4dst_seen)
-			ntuple_fs.m_u.tcp_ip4_spec.ip4dst = 0xffffffff;
-		if (!ntuple_psrc_seen)
-			ntuple_fs.m_u.tcp_ip4_spec.psrc = 0xffff;
-		if (!ntuple_pdst_seen)
-			ntuple_fs.m_u.tcp_ip4_spec.pdst = 0xffff;
-		ntuple_fs.m_u.tcp_ip4_spec.tos = 0xff;
-		break;
-	case ETHER_FLOW:
-		parse_generic_cmdline(argc, argp, i + 1,
-				      &sntuple_changed,
-				      cmdline_ntuple_ether,
-				      ARRAY_SIZE(cmdline_ntuple_ether));
-		if (!ntuple_ether_dst_seen)
-			memset(ntuple_fs.m_u.ether_spec.h_dest, 0xff, ETH_ALEN);
-		if (!ntuple_ether_src_seen)
-			memset(ntuple_fs.m_u.ether_spec.h_source, 0xff,
-			       ETH_ALEN);
-		if (!ntuple_ether_proto_seen)
-			ntuple_fs.m_u.ether_spec.h_proto = 0xffff;
-		break;
-	default:
-		fprintf(stderr, "Unsupported flow type \"%s\"\n", argp[i]);
-		exit(106);
-		break;
-	}
-
-	if (!ntuple_vlan_tag_seen)
-		ntuple_fs.vlan_tag_mask = 0xffff;
-	if (!ntuple_user_def_seen)
-		ntuple_fs.data_mask = 0xffffffffffffffffULL;
-
-	if ((ntuple_ip4src_mask_seen && !ntuple_ip4src_seen) ||
-	    (ntuple_ip4dst_mask_seen && !ntuple_ip4dst_seen) ||
-	    (ntuple_psrc_mask_seen && !ntuple_psrc_seen) ||
-	    (ntuple_pdst_mask_seen && !ntuple_pdst_seen) ||
-	    (ntuple_ether_dst_mask_seen && !ntuple_ether_dst_seen) ||
-	    (ntuple_ether_src_mask_seen && !ntuple_ether_src_seen) ||
-	    (ntuple_ether_proto_mask_seen && !ntuple_ether_proto_seen) ||
-	    (ntuple_vlan_tag_mask_seen && !ntuple_vlan_tag_seen) ||
-	    (ntuple_user_def_mask_seen && !ntuple_user_def_seen)) {
-		fprintf(stderr, "Cannot specify mask without value\n");
-		exit(107);
-	}
-}
-
 static struct {
 	const char *name;
 	int (*func)(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
@@ -2922,14 +2848,12 @@ static int do_gstats(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-
 static int do_srxclass(int fd, struct ifreq *ifr)
 {
-	int err;
+	int err = 0;
+	struct ethtool_rxnfc nfccmd;
 
 	if (rx_fhash_changed) {
-		struct ethtool_rxnfc nfccmd;
-
 		nfccmd.cmd = ETHTOOL_SRXFH;
 		nfccmd.flow_type = rx_fhash_set;
 		nfccmd.data = rx_fhash_val;
@@ -2941,12 +2865,12 @@ static int do_srxclass(int fd, struct ifreq *ifr)
 
 	}
 
-	return 0;
+	return err ? 1 : 0;
 }
 
 static int do_grxclass(int fd, struct ifreq *ifr)
 {
-	int err;
+	int err = 0;
 
 	if (rx_fhash_get) {
 		struct ethtool_rxnfc nfccmd;
@@ -2961,7 +2885,7 @@ static int do_grxclass(int fd, struct ifreq *ifr)
 			dump_rxfhash(rx_fhash_get, nfccmd.data);
 	}
 
-	return 0;
+	return err ? 1 : 0;
 }
 
 static int do_grxfhindir(int fd, struct ifreq *ifr)
@@ -3142,7 +3066,17 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 {
 	int err;
 
-	if (sntuple_changed) {
+	if (rx_class_rule_added) {
+		err = rxclass_rule_ins(fd, ifr, &rx_rule_fs,
+				       rxclass_loc_valid);
+		if (err < 0)
+			fprintf(stderr, "Cannot insert RX classification rule\n");
+	} else if (rx_class_rule_del >= 0) {
+		err = rxclass_rule_del(fd, ifr, rx_class_rule_del);
+
+		if (err < 0)
+			fprintf(stderr, "Cannot delete RX classification rule\n");
+	} else if (sntuple_changed) {
 		struct ethtool_rx_ntuple ntuplecmd;
 
 		ntuplecmd.cmd = ETHTOOL_SRXNTUPLE;
@@ -3162,7 +3096,29 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 
 static int do_grxntuple(int fd, struct ifreq *ifr)
 {
-	return 0;
+	struct ethtool_rxnfc nfccmd;
+	int err;
+
+	if (rx_class_rule_get >= 0) {
+		err = rxclass_rule_get(fd, ifr, rx_class_rule_get);
+		if (err < 0)
+			fprintf(stderr, "Cannot get RX classification rule\n");
+		return err ? 1 : 0;
+	}
+
+	nfccmd.cmd = ETHTOOL_GRXRINGS;
+	ifr->ifr_data = (caddr_t)&nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0)
+		perror("Cannot get RX rings");
+	else
+		fprintf(stdout, "%d RX rings available\n",
+			(int)nfccmd.data);
+
+	err = rxclass_rule_getall(fd, ifr);
+	if (err < 0)
+		fprintf(stderr, "RX classification rule retrieval failed\n");
+	return err ? 1 : 0;
 }
 
 static int send_ioctl(int fd, struct ifreq *ifr)
diff --git a/rxclass.c b/rxclass.c
new file mode 100644
index 0000000..f2a8c96
--- /dev/null
+++ b/rxclass.c
@@ -0,0 +1,1169 @@
+/*
+ * Copyright (C) 2008 Sun Microsystems, Inc. All rights reserved.
+ */
+#include <stdio.h>
+#include <stdint.h>
+#include <stddef.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
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
+static void rmgr_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
+{
+	unsigned char	*smac, *smacm, *dmac, *dmacm;
+	__u32		sip, dip, sipm, dipm;
+	__u16		proto, protom;
+
+	fprintf(stdout,	"Filter: %d\n", fsp->location);
+
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case IP_USER_FLOW:
+		sip = ntohl(fsp->h_u.tcp_ip4_spec.ip4src);
+		dip = ntohl(fsp->h_u.tcp_ip4_spec.ip4dst);
+		sipm = ntohl(fsp->m_u.tcp_ip4_spec.ip4src);
+		dipm = ntohl(fsp->m_u.tcp_ip4_spec.ip4dst);
+
+		switch (fsp->flow_type) {
+		case TCP_V4_FLOW:
+			fprintf(stdout, "\tRule Type: TCP over IPv4\n");
+			break;
+		case UDP_V4_FLOW:
+			fprintf(stdout, "\tRule Type: UDP over IPv4\n");
+			break;
+		case SCTP_V4_FLOW:
+			fprintf(stdout, "\tRule Type: SCTP over IPv4\n");
+			break;
+		case AH_V4_FLOW:
+			fprintf(stdout, "\tRule Type: IPSEC AH over IPv4\n");
+			break;
+		case ESP_V4_FLOW:
+			fprintf(stdout, "\tRule Type: IPSEC ESP over IPv4\n");
+			break;
+		case IP_USER_FLOW:
+			fprintf(stdout, "\tRule Type: Raw IPv4\n");
+			break;
+		default:
+			break;
+		}
+
+		fprintf(stdout,
+			"\tSrc IP addr: %d.%d.%d.%d mask: %d.%d.%d.%d\n"
+			"\tDest IP addr: %d.%d.%d.%d mask: %d.%d.%d.%d\n"
+			"\tTOS: 0x%x mask: 0x%x\n",
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
+		case UDP_V4_FLOW:
+		case SCTP_V4_FLOW:
+			fprintf(stdout,
+				"\tSrc port: %d mask: 0x%x\n"
+				"\tDest port: %d mask: 0x%x\n",
+				ntohs(fsp->h_u.tcp_ip4_spec.psrc),
+				ntohs(fsp->m_u.tcp_ip4_spec.psrc),
+				ntohs(fsp->h_u.tcp_ip4_spec.pdst),
+				ntohs(fsp->m_u.tcp_ip4_spec.pdst));
+			break;
+		case AH_V4_FLOW:
+		case ESP_V4_FLOW:
+			fprintf(stdout,
+				"\tSPI: %d mask: 0x%x\n",
+				ntohl(fsp->h_u.esp_ip4_spec.spi),
+				ntohl(fsp->m_u.esp_ip4_spec.spi));
+			break;
+		case IP_USER_FLOW:
+			fprintf(stdout,
+				"\tProtocol: %d mask: 0x%x\n"
+				"\tL4 bytes: 0x%x mask: 0x%x\n",
+				fsp->h_u.usr_ip4_spec.proto,
+				fsp->m_u.usr_ip4_spec.proto,
+				ntohl(fsp->h_u.usr_ip4_spec.l4_4_bytes),
+				ntohl(fsp->m_u.usr_ip4_spec.l4_4_bytes));
+			break;
+		default:
+			break;
+		}
+		break;
+	case ETHER_FLOW:
+		dmac = fsp->h_u.ether_spec.h_dest;
+		dmacm = fsp->m_u.ether_spec.h_dest;
+		smac = fsp->h_u.ether_spec.h_source;
+		smacm = fsp->m_u.ether_spec.h_source;
+		proto = ntohs(fsp->h_u.ether_spec.h_proto);
+		protom = ntohs(fsp->m_u.ether_spec.h_proto);
+
+		fprintf(stdout,
+			"\tFlow Type: Raw Ethernet\n"
+			"\tSrc MAC addr: %02X:%02X:%02X:%02X:%02X:%02X"
+			" mask: %02X:%02X:%02X:%02X:%02X:%02X\n"
+			"\tDest MAC addr: %02X:%02X:%02X:%02X:%02X:%02X"
+			" mask: %02X:%02X:%02X:%02X:%02X:%02X\n"
+			"\tEthertype: 0x%X mask: 0x%X\n",
+			smac[0], smac[1], smac[2], smac[3], smac[4], smac[5],
+			smacm[0], smacm[1], smacm[2], smacm[3], smacm[4], smacm[5],
+			dmac[0], dmac[1], dmac[2], dmac[3], dmac[4], dmac[5],
+			dmacm[0], dmacm[1], dmacm[2], dmacm[3], dmacm[4], dmacm[5],
+			proto, protom);
+		break;
+	default:
+		fprintf(stdout,
+			"\tUnknown Flow type: %d\n", fsp->flow_type);
+		break;
+	}
+
+	if (fsp->ring_cookie != RX_CLS_FLOW_DISC)
+		fprintf(stdout, "\tAction: Direct to queue %llu\n",
+			fsp->ring_cookie);
+	else
+		fprintf(stdout, "\tAction: Drop\n");
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
+	case ETHER_FLOW:
+		rmgr_print_nfc_rule(fsp);
+		break;
+	case IP_USER_FLOW:
+		if (fsp->h_u.usr_ip4_spec.ip_ver == ETH_RX_NFC_IP4) {
+			rmgr_print_nfc_rule(fsp);
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
+	memset(&rmgr, 0, sizeof(struct rmgr_ctrl));
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
+			memset(&nfccmd.fs, 0,
+			       sizeof(struct ethtool_rx_flow_spec));
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
+	memset(&nfccmd.fs, 0, sizeof(struct ethtool_rx_flow_spec));
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
+typedef enum {
+	OPT_NONE,
+	OPT_S32,
+	OPT_U8,
+	OPT_U16,
+	OPT_U32,
+	OPT_U64,
+	OPT_BE16,
+	OPT_BE32,
+	OPT_BE64,
+	OPT_IP4,
+	OPT_MAC,
+} rule_opt_type_t;
+
+typedef enum {
+	ETH_SPEC_NONE,
+	ETH_SPEC_NFC,
+	ETH_SPEC_NTUPLE,
+} rule_spec_type_t;
+
+#define NFC_FLAG_RING		0x001
+#define NFC_FLAG_LOC		0x002
+#define NFC_FLAG_SADDR		0x004
+#define NFC_FLAG_DADDR		0x008
+#define NFC_FLAG_SPORT		0x010
+#define NFC_FLAG_DPORT		0x020
+#define NFC_FLAG_SPI		0x030
+#define NFC_FLAG_TOS		0x040
+#define NFC_FLAG_PROTO		0x080
+#define NTUPLE_FLAG_VLAN	0x100
+#define NTUPLE_FLAG_UDEF	0x200
+
+struct rule_opts {
+	const char	*name;
+	rule_opt_type_t	type;
+	u32		flag;
+	int		offset;
+	int		moffset;
+};
+
+static struct rule_opts rule_nfc_tcp_ip4[] = {
+	{ "src-ip", OPT_IP4, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip4_spec.ip4src),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip4_spec.ip4src) },
+	{ "dst-ip", OPT_IP4, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip4_spec.ip4dst),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip4_spec.ip4dst) },
+	{ "tos", OPT_U8, NFC_FLAG_TOS,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip4_spec.tos),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip4_spec.tos) },
+	{ "src-port", OPT_BE16, NFC_FLAG_SPORT,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip4_spec.psrc),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip4_spec.psrc) },
+	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip4_spec.pdst),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip4_spec.pdst) },
+	{ "action", OPT_U64, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "loc", OPT_U32, NFC_FLAG_LOC,
+	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+};
+
+static struct rule_opts rule_nfc_esp_ip4[] = {
+	{ "src-ip", OPT_IP4, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip4_spec.ip4src),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip4_spec.ip4src) },
+	{ "dst-ip", OPT_IP4, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip4_spec.ip4dst),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip4_spec.ip4dst) },
+	{ "tos", OPT_U8, NFC_FLAG_TOS,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip4_spec.tos),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip4_spec.tos) },
+	{ "spi", OPT_BE32, NFC_FLAG_SPI,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip4_spec.spi),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip4_spec.spi) },
+	{ "action", OPT_U64, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "loc", OPT_U32, NFC_FLAG_LOC,
+	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+};
+
+static struct rule_opts rule_nfc_usr_ip4[] = {
+	{ "src-ip", OPT_IP4, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.ip4src),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.ip4src) },
+	{ "dst-ip", OPT_IP4, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.ip4dst),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.ip4dst) },
+	{ "tos", OPT_U8, NFC_FLAG_TOS,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.tos),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.tos) },
+	{ "l4proto", OPT_U8, NFC_FLAG_PROTO,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.proto),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.proto) },
+	{ "spi", OPT_BE32, NFC_FLAG_SPI,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.l4_4_bytes),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) },
+	{ "src-port", OPT_BE16, NFC_FLAG_SPORT,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.l4_4_bytes),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) },
+	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.l4_4_bytes) + 2,
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) + 2 },
+	{ "action", OPT_U64, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "loc", OPT_U32, NFC_FLAG_LOC,
+	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+};
+
+static struct rule_opts rule_nfc_ether[] = {
+	{ "src", OPT_MAC, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_dest),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_dest) },
+	{ "dst", OPT_MAC, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_source),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_source) },
+	{ "proto", OPT_BE16, NFC_FLAG_PROTO,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_proto),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_proto) },
+	{ "action", OPT_U64, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "loc", OPT_U32, NFC_FLAG_LOC,
+	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+};
+
+static struct rule_opts rule_ntuple_tcp_ip4[] = {
+	{ "src-ip", OPT_IP4, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.tcp_ip4_spec.ip4src),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.tcp_ip4_spec.ip4src) },
+	{ "dst-ip", OPT_IP4, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.tcp_ip4_spec.ip4dst),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.tcp_ip4_spec.ip4dst) },
+	{ "tos", OPT_U8, NFC_FLAG_TOS,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.tcp_ip4_spec.tos),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.tcp_ip4_spec.tos) },
+	{ "src-port", OPT_BE16, NFC_FLAG_SPORT,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.tcp_ip4_spec.psrc),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.tcp_ip4_spec.psrc) },
+	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.tcp_ip4_spec.pdst),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.tcp_ip4_spec.pdst) },
+	{ "vlan", OPT_U16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, vlan_tag),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, vlan_tag_mask) },
+	{ "user-def", OPT_U64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, data),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, data_mask) },
+	{ "action", OPT_S32, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, action), -1 },
+};
+
+static struct rule_opts rule_ntuple_esp_ip4[] = {
+	{ "src-ip", OPT_IP4, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.esp_ip4_spec.ip4src),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.esp_ip4_spec.ip4src) },
+	{ "dst-ip", OPT_IP4, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.esp_ip4_spec.ip4dst),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.esp_ip4_spec.ip4dst) },
+	{ "tos", OPT_U8, NFC_FLAG_TOS,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.esp_ip4_spec.tos),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.esp_ip4_spec.tos) },
+	{ "spi", OPT_BE32, NFC_FLAG_SPI,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.esp_ip4_spec.spi),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.esp_ip4_spec.spi) },
+	{ "vlan", OPT_U16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, vlan_tag),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, vlan_tag_mask) },
+	{ "user-def", OPT_U64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, data),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, data_mask) },
+	{ "action", OPT_S32, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, action), -1 },
+};
+
+static struct rule_opts rule_ntuple_usr_ip4[] = {
+	{ "src-ip", OPT_IP4, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.usr_ip4_spec.ip4src),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.usr_ip4_spec.ip4src) },
+	{ "dst-ip", OPT_IP4, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.usr_ip4_spec.ip4dst),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.usr_ip4_spec.ip4dst) },
+	{ "tos", OPT_U8, NFC_FLAG_TOS,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.usr_ip4_spec.tos),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.usr_ip4_spec.tos) },
+	{ "l4proto", OPT_U8, NFC_FLAG_PROTO,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.usr_ip4_spec.proto),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.usr_ip4_spec.proto) },
+	{ "spi", OPT_BE32, NFC_FLAG_SPI,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.usr_ip4_spec.l4_4_bytes),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) },
+	{ "src-port", OPT_BE16, NFC_FLAG_SPORT,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.usr_ip4_spec.l4_4_bytes),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) },
+	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.usr_ip4_spec.l4_4_bytes) + 2,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) + 2 },
+	{ "vlan", OPT_U16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, vlan_tag),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, vlan_tag_mask) },
+	{ "user-def", OPT_U64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, data),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, data_mask) },
+	{ "action", OPT_S32, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, action), -1 },
+};
+
+static struct rule_opts rule_ntuple_ether[] = {
+	{ "src", OPT_MAC, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.ether_spec.h_dest),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.ether_spec.h_dest) },
+	{ "dst", OPT_MAC, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.ether_spec.h_source),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.ether_spec.h_source) },
+	{ "proto", OPT_BE16, NFC_FLAG_PROTO,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, h_u.ether_spec.h_proto),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, m_u.ether_spec.h_proto) },
+	{ "vlan", OPT_U16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, vlan_tag),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, vlan_tag_mask) },
+	{ "user-def", OPT_U64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, data),
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, data_mask) },
+	{ "action", OPT_S32, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_ntuple_flow_spec, action), -1 },
+};
+
+static int rxclass_get_long(char *str, long long *val, int size)
+{
+	long long max = ~0ULL >> (65 - size);
+	char *endp;
+
+	errno = 0;
+
+	*val = strtoll(str, &endp, 0);
+
+	if (*endp || errno || (*val > max) || (*val < ~max))
+		return -1;
+
+	return 0;
+}
+
+static int rxclass_get_ulong(char *str, unsigned long long *val, int size)
+{
+	long long max = ~0ULL >> (64 - size);
+	char *endp;
+
+	errno = 0;
+
+	*val = strtoull(str, &endp, 0);
+
+	if (*endp || errno || (*val > max))
+		return -1;
+
+	return 0;
+}
+
+static int rxclass_get_ipv4(char *str, __be32 *val)
+{
+	if (!strchr(str, '.')) {
+		unsigned long long v;
+		int err;
+
+		err = rxclass_get_ulong(str, &v, 32);
+		if (err)
+			return -1;
+
+		*val = htonl((u32)v);
+
+		return 0;
+	}
+
+	if (!inet_pton(AF_INET, str, val))
+		return -1;
+
+	return 0;
+}
+
+static int rxclass_get_ether(char *str, unsigned char *val)
+{
+	unsigned int buf[ETH_ALEN];
+	int count;
+
+	if (!strchr(str, ':'))
+		return -1;
+
+	count = sscanf(str, "%2x:%2x:%2x:%2x:%2x:%2x",
+		       &buf[0], &buf[1], &buf[2],
+		       &buf[3], &buf[4], &buf[5]);
+
+	if (count != ETH_ALEN)
+		return -1;
+
+	do {
+		count--;
+		val[count] = buf[count];
+	} while (count);
+
+	return 0;
+}
+
+static int rxclass_get_val(char *str, unsigned char *p, u32 *flags,
+			   const struct rule_opts *opt, rule_spec_type_t spec)
+{
+	unsigned long long mask = (spec == ETH_SPEC_NFC) ? ~0ULL : 0ULL; 
+	int err = 0;
+
+	if (*flags & opt->flag)
+		return -1;
+
+	*flags |= opt->flag;
+
+	switch (opt->type) {
+	case OPT_S32: {
+		long long val;
+		err = rxclass_get_long(str, &val, 32);
+		if (err)
+			return -1;
+		*(int *)&p[opt->offset] = (int)val;
+		if (opt->moffset >= 0)
+			*(int *)&p[opt->moffset] = (int)mask;
+		break;
+	}
+	case OPT_U8: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 8);
+		if (err)
+			return -1;
+		*(u8 *)&p[opt->offset] = (u8)val;
+		if (opt->moffset >= 0)
+			*(u8 *)&p[opt->moffset] = (u8)mask;
+		break;
+	}
+	case OPT_U16: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 16);
+		if (err)
+			return -1;
+		*(u16 *)&p[opt->offset] = (u16)val;
+		if (opt->moffset >= 0)
+			*(u16 *)&p[opt->moffset] = (u16)mask;
+		break;
+	}
+	case OPT_U32: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 32);
+		if (err)
+			return -1;
+		*(u32 *)&p[opt->offset] = (u32)val;
+		if (opt->moffset >= 0)
+			*(u32 *)&p[opt->moffset] = (u32)mask;
+		break;
+	}
+	case OPT_U64: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 64);
+		if (err)
+			return -1;
+		*(u64 *)&p[opt->offset] = (u64)val;
+		if (opt->moffset >= 0)
+			*(u64 *)&p[opt->moffset] = (u64)mask;
+		break;
+	}
+	case OPT_BE16: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 16);
+		if (err)
+			return -1;
+		*(__be16 *)&p[opt->offset] = htons((u16)val);
+		if (opt->moffset >= 0)
+			*(__be16 *)&p[opt->moffset] = (__be16)mask;
+		break;
+	}
+	case OPT_BE32: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 32);
+		if (err)
+			return -1;
+		*(__be32 *)&p[opt->offset] = htonl((u32)val);
+		if (opt->moffset >= 0)
+			*(__be32 *)&p[opt->moffset] = (__be32)mask;
+		break;
+	}
+	case OPT_BE64: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 64);
+		if (err)
+			return -1;
+		*(__be64 *)&p[opt->offset] = htonll((u64)val);
+		if (opt->moffset >= 0)
+			*(__be64 *)&p[opt->moffset] = (__be64)mask;
+		break;
+	}
+	case OPT_IP4: {
+		__be32 val;
+		err = rxclass_get_ipv4(str, &val);
+		if (err)
+			return -1;
+		*(__be32 *)&p[opt->offset] = val;
+		if (opt->moffset >= 0)
+			*(__be32 *)&p[opt->moffset] = (__be32)mask;
+		break;
+	}
+	case OPT_MAC: {
+		unsigned char val[ETH_ALEN];
+		err = rxclass_get_ether(str, val);
+		if (err)
+			return -1;
+		memcpy(&p[opt->offset], val, ETH_ALEN);
+		if (opt->moffset >= 0)
+			memcpy(&p[opt->moffset], &mask, ETH_ALEN);
+		break;
+	}
+	case OPT_NONE:
+	default:
+		return -1;
+	}
+
+	return 0;
+}
+
+static int rxclass_get_mask(char *str, unsigned char *p,
+			    const struct rule_opts *opt)
+{
+	int err = 0;
+
+	if (opt->moffset < 0)
+		return -1;
+
+	switch (opt->type) {
+	case OPT_S32: {
+		long long val;
+		err = rxclass_get_long(str, &val, 32);
+		if (err)
+		*(int *)&p[opt->moffset] = (int)val;
+		break;
+	}
+	case OPT_U8: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 8);
+		if (err)
+			return -1;
+		*(u8 *)&p[opt->moffset] = (u8)val;
+		break;
+	}
+	case OPT_U16: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 16);
+		if (err)
+			return -1;
+		*(u16 *)&p[opt->moffset] = (u16)val;
+		break;
+	}
+	case OPT_U32: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 32);
+		if (err)
+			return -1;
+		*(u32 *)&p[opt->moffset] = (u32)val;
+		break;
+	}
+	case OPT_U64: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 64);
+		if (err)
+			return -1;
+		*(u64 *)&p[opt->moffset] = (u64)val;
+		break;
+	}
+	case OPT_BE16: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 16);
+		if (err)
+			return -1;
+		*(__be16 *)&p[opt->moffset] = htons((u16)val);
+		break;
+	}
+	case OPT_BE32: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 32);
+		if (err)
+			return -1;
+		*(__be32 *)&p[opt->moffset] = htonl((u32)val);
+		break;
+	}
+	case OPT_BE64: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 64);
+		if (err)
+			return -1;
+		*(__be64 *)&p[opt->moffset] = htonll((u64)val);
+		break;
+	}
+	case OPT_IP4: {
+		__be32 val;
+		err = rxclass_get_ipv4(str, &val);
+		if (err)
+			return -1;
+		*(__be32 *)&p[opt->moffset] = val;
+		break;
+	}
+	case OPT_MAC: {
+		unsigned char val[ETH_ALEN];
+		err = rxclass_get_ether(str, val);
+		if (err)
+			return -1;
+		memcpy(&p[opt->moffset], val, ETH_ALEN);
+		break;
+	}
+	case OPT_NONE:
+	default:
+		return -1;
+	}
+
+	return 0;
+}
+
+int rxclass_parse_ruleopts(char **argp, int argc, void *fsp, u8 *loc_valid)
+{
+	const struct rule_opts *options;
+	unsigned char *p = (unsigned char *)fsp;
+	int i = 0, n_opts, err;
+	u32 flags = 0;
+	rule_spec_type_t spec_type;
+	int flow_type;
+
+	if (*argp == NULL || **argp == '\0' || argc < 2)
+		goto syntax_err;
+
+	if (!strcmp(argp[0], "class-rule-add"))
+		spec_type = ETH_SPEC_NFC;
+	else if (!strcmp(argp[0], "flow-type"))
+		spec_type = ETH_SPEC_NTUPLE;
+	else
+		goto syntax_err;
+
+	if (!strcmp(argp[1], "tcp4"))
+		flow_type = TCP_V4_FLOW;
+	else if (!strcmp(argp[1], "udp4"))
+		flow_type = UDP_V4_FLOW;
+	else if (!strcmp(argp[1], "sctp4"))
+		flow_type = SCTP_V4_FLOW;
+	else if (!strcmp(argp[1], "ah4"))
+		flow_type = AH_V4_FLOW;
+	else if (!strcmp(argp[1], "esp4"))
+		flow_type = ESP_V4_FLOW;
+	else if (!strcmp(argp[1], "ip4"))
+		flow_type = IP_USER_FLOW;
+	else if (!strcmp(argp[1], "ether"))
+		flow_type = ETHER_FLOW;
+	else
+		goto syntax_err;
+
+	switch (spec_type) {
+	case ETH_SPEC_NFC:
+		memset(p, 0, sizeof(struct ethtool_rx_flow_spec));
+		*(u32 *)p = flow_type;
+
+		switch (flow_type) {
+		case TCP_V4_FLOW:
+		case UDP_V4_FLOW:
+		case SCTP_V4_FLOW:
+			options = rule_nfc_tcp_ip4;
+			n_opts = ARRAY_SIZE(rule_nfc_tcp_ip4);
+			break;
+		case AH_V4_FLOW:
+		case ESP_V4_FLOW:
+			options = rule_nfc_esp_ip4;
+			n_opts = ARRAY_SIZE(rule_nfc_esp_ip4);
+			break;
+		case IP_USER_FLOW:
+			options = rule_nfc_usr_ip4;
+			n_opts = ARRAY_SIZE(rule_nfc_usr_ip4);
+			break;
+		case ETHER_FLOW:
+			options = rule_nfc_ether;
+			n_opts = ARRAY_SIZE(rule_nfc_ether);
+			break;
+		default:
+			fprintf(stdout, "Add rule, invalid rule type[%s]\n",
+				argp[1]);
+			return -1;
+		}
+		break;
+	case ETH_SPEC_NTUPLE:
+		memset(p, 0xff,
+		       offsetof(struct ethtool_rx_ntuple_flow_spec, action));
+		memset(p + offsetof(struct ethtool_rx_ntuple_flow_spec, action),
+		       0, 4);
+		*(u32 *)fsp = flow_type;
+
+		switch (flow_type) {
+		case TCP_V4_FLOW:
+		case UDP_V4_FLOW:
+		case SCTP_V4_FLOW:
+			options = rule_ntuple_tcp_ip4;
+			n_opts = ARRAY_SIZE(rule_ntuple_tcp_ip4);
+			break;
+		case AH_V4_FLOW:
+		case ESP_V4_FLOW:
+			options = rule_ntuple_esp_ip4;
+			n_opts = ARRAY_SIZE(rule_nfc_esp_ip4);
+			break;
+		case IP_USER_FLOW:
+			options = rule_ntuple_usr_ip4;
+			n_opts = ARRAY_SIZE(rule_nfc_usr_ip4);
+			break;
+		case ETHER_FLOW:
+			options = rule_ntuple_ether;
+			n_opts = ARRAY_SIZE(rule_nfc_ether);
+			break;
+		default:
+			fprintf(stdout, "Add rule, invalid flow type[%s]\n",
+				argp[1]);
+			return -1;
+		}
+		break;
+	default:
+		fprintf(stdout, "Add rule, invalid command[%s]\n",
+			argp[0]);
+		return -1;
+	}
+
+	for (i = 2; i < argc;) {
+		const struct rule_opts *opt;
+		int idx;
+		for (opt = options, idx = 0; idx < n_opts; idx++, opt++) {
+			char mask_name[16];
+
+			if (strcmp(argp[i], opt->name))
+				continue;
+
+			i++;
+			if (i >= argc)
+				break;
+
+			err = rxclass_get_val(argp[i], p, &flags, opt, spec_type);
+			if (err) {
+				fprintf(stderr, "Invalid %s value[%s]\n",
+					opt->name, argp[i]);
+				return -1;
+			}
+
+			i++;
+			if (i >= argc)
+				break;
+
+			sprintf(mask_name, "%s-mask", opt->name);
+			if (strcmp(argp[i], mask_name))
+				break;
+
+			i++;
+			if (i >= argc)
+				goto syntax_err;
+
+			err = rxclass_get_mask(argp[i], p, opt);
+			if (err) {
+				fprintf(stderr, "Invalid %s mask[%s]\n",
+					opt->name, argp[i]);
+				return -1;
+			}
+
+			i++;
+
+			break;
+		}
+		if (idx == n_opts) {
+			fprintf(stdout, "Add rule, unreconized option[%s]\n", argp[i]);
+			return -1;
+		}
+	}
+
+	if (spec_type == ETH_SPEC_NFC) {
+		if (loc_valid && (flags & NFC_FLAG_LOC))
+			*loc_valid = 1;
+	}
+
+	return 0;
+
+syntax_err:
+	fprintf(stdout, "Add rule, invalid syntax\n");
+	return -1;
+}

