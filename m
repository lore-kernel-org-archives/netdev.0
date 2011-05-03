From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Tue, 03 May 2011 09:12:26 -0700
Message-ID: <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14880 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab1ECQMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 12:12:44 -0400
In-Reply-To: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona Behera <santwona.behera@sun.com>

This patch was originally introduced as:
  [PATCH 1/3] [ethtool] Add rx pkt classification interface
  Signed-off-by: Santwona Behera <santwona.behera@sun.com>
  http://patchwork.ozlabs.org/patch/23223/

v2:
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

v3:
The latest update to this patch now inverts the masks to match the mask
types used for n-tuple.  As such a network flow classifier is defined using
the exact same syntax as n-tuple, and the tool will correct for the fact
that NFC uses the 1's compliment of the n-tuple mask.

I also updated the ordering of new rules being added.  All new rules will
take the highest numbered open rule when no location is specified.

Since NFC now uses the same syntax as n-tuple I added code such that now
when location is not specified the -U option will first try to add a new
n-tuple rule, and if that fails with a ENOTSUPP it will then try to add the
rule via the NFC interface.

Finally I split out the addition of bitops and the updates to documentation
into separate patches.  This makes the total patch size a bit more
manageable since the addition of NFC and the merging of it with n-tuple were
combined into this patch.

v4:
This change merges the ntuple and network flow classifier rules so that if
we setup a rule and the device has the NTUPLE flag set we will first try to
use set_rx_ntuple.  If that fails with EOPNOTSUPP we then will attempt to
use the network flow classifier rule insertion.  This way we can support
legacy configurations such as niu on kernels prior to 2.6.40 that support
network flow classifier but not ntuple, but for drivers such as ixgbe we
can test for ntuple first, and then network flow classifier.

This patch has also updated the output to make use of the updated network
flow classifier extensions that have been accepted into the kernel.

v5:
This change merged the documentation update into this patch.  In addition the
documentation changes were made such that there is only one listing of the
individual options and they are all listed as optional.

In addition this patch contains several fixes to address things such as the
fact that we were maintaining the table logic even though we only need it for
displaying all of the rules, or when adding a rule with no location specified.
As such all of the logic for deleting or finding rules in the table has been
removed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 Makefile.am    |    3 
 ethtool-util.h |   14 +
 ethtool.8.in   |  194 ++++++----
 ethtool.c      |  400 ++++++++++++----------
 rxclass.c      | 1039 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 1384 insertions(+), 266 deletions(-)
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
diff --git a/ethtool-util.h b/ethtool-util.h
index d8b621c..79be7f2 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -65,6 +65,8 @@ static inline u64 cpu_to_be64(u64 value)
 #define SIOCETHTOOL     0x8946
 #endif
 
+#define	RX_CLS_LOC_UNSPEC	0xffffffffUL
+
 /* National Semiconductor DP83815, DP83816 */
 int natsemi_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int natsemi_dump_eeprom(struct ethtool_drvinfo *info,
@@ -128,4 +130,14 @@ int sfc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 			struct ethtool_regs *regs);
 int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
-#endif
+
+/* Rx flow classification */
+int rxclass_parse_ruleopts(char **optstr, int opt_cnt,
+			   struct ethtool_rx_flow_spec *fsp);
+int rxclass_rule_getall(int fd, struct ifreq *ifr);
+int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc);
+int rxclass_rule_ins(int fd, struct ifreq *ifr,
+		     struct ethtool_rx_flow_spec *fsp);
+int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc);
+
+#endif /* ETHTOOL_UTIL_H__ */
diff --git a/ethtool.8.in b/ethtool.8.in
index 9f484fb..c923319 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -42,10 +42,20 @@
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
@@ -57,6 +67,12 @@
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
@@ -236,8 +252,7 @@ ethtool \- query or control network driver and hardware settings
 .HP
 .B ethtool \-N
 .I ethX
-.RB [ rx\-flow\-hash \ \*(FL
-.RB \ \*(HO]
+.RB [ rx\-flow\-hash \ \*(FL \  \*(HO]
 .HP
 .B ethtool \-x|\-\-show\-rxfh\-indir
 .I ethX
@@ -257,50 +272,28 @@ ethtool \- query or control network driver and hardware settings
 .HP
 .B ethtool \-u|\-\-show\-ntuple
 .I ethX
-.TP
+.BN rule
+.HP
+
 .BI ethtool\ \-U|\-\-config\-ntuple \ ethX
-.RB {
-.A3 flow\-type tcp4 udp4 sctp4
-.RB [ src\-ip
-.IR addr
-.RB [ src\-ip\-mask
-.IR mask ]]
-.RB [ dst\-ip
-.IR addr
-.RB [ dst\-ip\-mask
-.IR mask ]]
-.RB [ src\-port
-.IR port
-.RB [ src\-port\-mask
-.IR mask ]]
-.RB [ dst\-port
-.IR port
-.RB [ dst\-port\-mask
-.IR mask ]]
-.br
-.RB | \ flow\-type\ ether
-.RB [ src
-.IR mac\-addr
-.RB [ src\-mask
-.IR mask ]]
-.RB [ dst
-.IR mac\-addr
-.RB [ dst\-mask
-.IR mask ]]
-.RB [ proto
-.IR N
-.RB [ proto\-mask
-.IR mask ]]\ }
-.br
-.RB [ vlan
-.IR VLAN\-tag
-.RB [ vlan\-mask
-.IR mask ]]
-.RB [ user\-def
-.IR data
-.RB [ user\-def\-mask
-.IR mask ]]
-.RI action \ N
+.BN delete
+.RB [\  flow\-type \ \*(NC
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
+.BM vlan\-etype
+.BM vlan
+.BM user\-def
+.BN action
+.BN loc
+.RB ]
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -630,77 +623,90 @@ Default region is 0 which denotes all regions in the flash.
 .TP
 .B \-u \-\-show\-ntuple
 Get Rx ntuple filters and actions, then display them to the user.
+.TP
+.BI rule \ N
+Retrieves the RX classification rule with the given ID.
 .PD
 .RE
 .TP
 .B \-U \-\-config\-ntuple
 Configure Rx ntuple filters and actions
 .TP
-.B flow\-type tcp4|udp4|sctp4|ether
+.BI delete \ N
+Deletes the RX classification rule with the given ID.
+.TP
+.B flow\-type \*(NC
 .TS
 nokeep;
 lB	l.
+ether	Ethernet
+ip4	Raw IPv4
 tcp4	TCP over IPv4
 udp4	UDP over IPv4
 sctp4	SCTP over IPv4
-ether	Ethernet
+ah4	IPSEC AH over IPv4
+esp4	IPSEC ESP over IPv4
 .TE
+.PP
+All fields below that include a mask option may either use "m" to
+indicate a mask, or may use the full name of the field with a "-mask"
+appended to indicate that this is the mask for a given field.
+.PD
+.RE
 .TP
-.BI src\-ip \ addr
-Includes the source IP address, specified using dotted-quad notation
-or as a single 32-bit number.
-.TP
-.BI src\-ip\-mask \ mask
-Specify a mask for the source IP address.
-.TP
-.BI dst\-ip \ addr
-Includes the destination IP address.
-.TP
-.BI dst\-ip\-mask \ mask
-Specify a mask for the destination IP address.
-.TP
-.BI src\-port \ port
-Includes the source port.
-.TP
-.BI src\-port\-mask \ mask
-Specify a mask for the source port.
+.BR src \ \*(MA\ [ m \ \*(MA]
+Includes the source MAC address, specified as 6 bytes in hexadecimal
+separated by colons, along with an optional mask.  Valid only for
+flow-type ether.
 .TP
-.BI dst\-port \ port
-Includes the destination port.
+.BR dst \ \*(MA\ [ m \ \*(MA]
+Includes the destination MAC address, specified as 6 bytes in hexadecimal
+separated by colons, along with an optional mask.  Valid only for
+flow-type ether.
 .TP
-.BI dst\-port\-mask \ mask
-Specify a mask for the destination port.
+.BI proto \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Includes the Ethernet protocol number (ethertype) and an optional mask.
+Valid only for flow-type ether.
 .TP
-.BI src \ mac\-addr
-Includes the source MAC address, specified as 6 bytes in hexadecimal
-separated by colons.
+.BR src\-ip \ \*(PA\ [ m \ \*(PA]
+Specify the source IP address of the incoming packet to match along with
+an optional mask.  Valid for all IPv4 based flow-types.
 .TP
-.BI src\-mask \ mask
-Specify a mask for the source MAC address.
+.BR dst\-ip \ \*(PA\ [ m \ \*(PA]
+Specify the destination IP address of the incoming packet to match along
+with an optional mask.  Valid for all IPv4 based flow-types.
 .TP
-.BI dst \ mac\-addr
-Includes the destination MAC address.
+.BI tos \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the Type of Service field in the incoming packet to
+match along with an optional mask.  Applies to all IPv4 based flow-types.
 .TP
-.BI dst\-mask \ mask
-Specify a mask for the destination MAC address.
+.BI l4proto \ N \\fR\ [\\fPl4m \ N \\fR]\\fP
+Includes the layer 4 protocol number and optional mask.  Valid only for
+flow-type ip4.
 .TP
-.BI proto \ N
-Includes the Ethernet protocol number (ethertype).
+.BI src\-port \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the source port field (applicable to TCP/UDP packets)
+in the incoming packet to match along with an optional mask.  Valid for
+flow-types ip4, tcp4, udp4, and sctp4.
 .TP
-.BI proto\-mask \ mask
-Specify a mask for the Ethernet protocol number.
+.BI dst\-port \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the destination port field (applicable to TCP/UDP
+packets)in the incoming packet to match along with an optional mask.
+Valid for flow-types ip4, tcp4, udp4, and sctp4.
 .TP
-.BI vlan \ VLAN\-tag
-Includes the VLAN tag.
+.BI spi \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the security parameter index field (applicable to
+AH/ESP packets)in the incoming packet to match along with an optional
+mask.  Valid for flow-types ip4, ah4, and esp4.
 .TP
-.BI vlan\-mask \ mask
-Specify a mask for the VLAN tag.
+.BI vlan\-etype \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Includes the VLAN tag Ethertype and an optional mask.
 .TP
-.BI user\-def \ data
-Includes 64-bits of user-specific data.
+.BI vlan \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Includes the VLAN tag and an optional mask.
 .TP
-.BI user\-def\-mask \ mask
-Specify a mask for the user-specific data.
+.BI user\-def \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Includes 64-bits of user-specific data and an optional mask.
 .TP
 .BI action \ N
 Specifies the Rx queue to send packets to, or some other action.
@@ -711,6 +717,11 @@ lB	l.
 -1	Drop the matched flow
 0 or higher	Rx queue to route the flow
 .TE
+.TP
+.BI loc \ N
+Specify the location/ID to insert the rule. This will overwrite
+any rule present in that location and will not go through any
+of the rule ordering process.
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
@@ -724,7 +735,8 @@ Jakub Jelinek,
 Andre Majorel,
 Eli Kupermann,
 Scott Feldman,
-Andi Kleen.
+Andi Kleen,
+Alexander Duyck.
 .SH AVAILABILITY
 .B ethtool
 is available from
diff --git a/ethtool.c b/ethtool.c
index 24d4e4f..2e04d87 100644
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
@@ -85,14 +87,13 @@ static int do_gstats(int fd, struct ifreq *ifr);
 static int rxflow_str_to_type(const char *str);
 static int parse_rxfhashopts(char *optstr, u32 *data);
 static char *unparse_rxfhashopts(u64 opts);
-static void parse_rxntupleopts(int argc, char **argp, int first_arg);
 static int dump_rxfhash(int fhash, u64 val);
 static int do_srxclass(int fd, struct ifreq *ifr);
 static int do_grxclass(int fd, struct ifreq *ifr);
 static int do_grxfhindir(int fd, struct ifreq *ifr);
 static int do_srxfhindir(int fd, struct ifreq *ifr);
-static int do_srxntuple(int fd, struct ifreq *ifr);
-static int do_grxntuple(int fd, struct ifreq *ifr);
+static int do_srxclsrule(int fd, struct ifreq *ifr);
+static int do_grxclsrule(int fd, struct ifreq *ifr);
 static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
 
@@ -123,8 +124,8 @@ static enum {
 	MODE_SNFC,
 	MODE_GRXFHINDIR,
 	MODE_SRXFHINDIR,
-	MODE_SNTUPLE,
-	MODE_GNTUPLE,
+	MODE_SCLSRULE,
+	MODE_GCLSRULE,
 	MODE_FLASHDEV,
 	MODE_PERMADDR,
 } mode = MODE_GSET;
@@ -230,22 +231,28 @@ static struct option {
 		"indirection" },
     { "-X", "--set-rxfh-indir", MODE_SRXFHINDIR, "Set Rx flow hash indirection",
 		"		equal N | weight W0 W1 ...\n" },
-    { "-U", "--config-ntuple", MODE_SNTUPLE, "Configure Rx ntuple filters "
+    { "-U", "--config-ntuple", MODE_SCLSRULE, "Configure Rx ntuple filters "
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
-    { "-u", "--show-ntuple", MODE_GNTUPLE,
-		"Get Rx ntuple filters and actions\n" },
+		"		[ delete %d ] |\n"
+		"		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
+		"			[ src %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
+		"			[ dst %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
+		"			[ proto %d [m %x] ]\n"
+		"			[ src-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
+		"			[ dst-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
+		"			[ tos %d [m %x] ]\n"
+		"			[ l4proto %d [m %x] ]\n"
+		"			[ src-port %d [m %x] ]\n"
+		"			[ dst-port %d [m %x] ]\n"
+		"			[ spi %d [m %x] ]\n"
+		"			[ vlan-etype %x [m %x] ]\n"
+		"			[ vlan %x [m %x] ]\n"
+		"			[ user-def %x [m %x] ]\n"
+		"			[ action %d ]\n"
+		"			[ loc %d]]\n" },
+    { "-u", "--show-ntuple", MODE_GCLSRULE,
+		"Get Rx ntuple filters and actions",
+		"		[ rule %d ]\n"},
     { "-P", "--show-permaddr", MODE_PERMADDR,
 		"Show permanent hardware address" },
     { "-h", "--help", MODE_HELP, "Show this help" },
@@ -371,26 +378,6 @@ static u32 rx_fhash_val = 0;
 static int rx_fhash_changed = 0;
 static int rxfhindir_equal = 0;
 static char **rxfhindir_weight = NULL;
-static int sntuple_changed = 0;
-static struct ethtool_rx_ntuple_flow_spec ntuple_fs;
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
@@ -399,6 +386,11 @@ static int msglvl_changed;
 static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
 
+static int rx_class_rule_get = -1;
+static int rx_class_rule_del = -1;
+static int rx_class_rule_added = 0;
+static struct ethtool_rx_flow_spec rx_rule_fs;
+
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -511,58 +503,6 @@ static struct cmdline_info cmdline_coalesce[] = {
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
@@ -833,8 +773,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_SNFC) ||
 			    (mode == MODE_GRXFHINDIR) ||
 			    (mode == MODE_SRXFHINDIR) ||
-			    (mode == MODE_SNTUPLE) ||
-			    (mode == MODE_GNTUPLE) ||
+			    (mode == MODE_SCLSRULE) ||
+			    (mode == MODE_GCLSRULE) ||
 			    (mode == MODE_PHYS_ID) ||
 			    (mode == MODE_FLASHDEV) ||
 			    (mode == MODE_PERMADDR)) {
@@ -918,16 +858,45 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
-			if (mode == MODE_SNTUPLE) {
+			if (mode == MODE_SCLSRULE) {
 				if (!strcmp(argp[i], "flow-type")) {
 					i += 1;
 					if (i >= argc) {
 						exit_bad_args();
 						break;
 					}
-					parse_rxntupleopts(argc, argp, i);
-					i = argc;
-					break;
+					if (rxclass_parse_ruleopts(&argp[i],
+							argc - i,
+							&rx_rule_fs) < 0) {
+						exit_bad_args();
+					} else {
+						i = argc;
+						rx_class_rule_added = 1;
+					}
+				} else if (!strcmp(argp[i], "delete")) {
+					i += 1;
+					if (i >= argc) {
+						exit_bad_args();
+						break;
+					}
+					rx_class_rule_del =
+						get_uint_range(argp[i], 0,
+							       INT_MAX);
+				} else {
+					exit_bad_args();
+				}
+				break;
+			}
+			if (mode == MODE_GCLSRULE) {
+				if (!strcmp(argp[i], "rule")) {
+					i += 1;
+					if (i >= argc) {
+						exit_bad_args();
+						break;
+					}
+					rx_class_rule_get =
+						get_uint_range(argp[i], 0,
+							       INT_MAX);
 				} else {
 					exit_bad_args();
 				}
@@ -1598,66 +1567,6 @@ static char *unparse_rxfhashopts(u64 opts)
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
@@ -2019,10 +1928,10 @@ static int doit(void)
 		return do_grxfhindir(fd, &ifr);
 	} else if (mode == MODE_SRXFHINDIR) {
 		return do_srxfhindir(fd, &ifr);
-	} else if (mode == MODE_SNTUPLE) {
-		return do_srxntuple(fd, &ifr);
-	} else if (mode == MODE_GNTUPLE) {
-		return do_grxntuple(fd, &ifr);
+	} else if (mode == MODE_SCLSRULE) {
+		return do_srxclsrule(fd, &ifr);
+	} else if (mode == MODE_GCLSRULE) {
+		return do_grxclsrule(fd, &ifr);
 	} else if (mode == MODE_FLASHDEV) {
 		return do_flash(fd, &ifr);
 	} else if (mode == MODE_PERMADDR) {
@@ -3155,21 +3064,143 @@ static int do_permaddr(int fd, struct ifreq *ifr)
 	return err;
 }
 
+static int flow_spec_to_ntuple(struct ethtool_rx_flow_spec *fsp,
+			       struct ethtool_rx_ntuple_flow_spec *ntuple)
+{
+	size_t i;
+
+	/* verify location is not specified */
+	if (fsp->location != RX_CLS_LOC_UNSPEC)
+		return -1;
+
+	/* verify ring cookie can transfer to action */
+	if (fsp->ring_cookie > INT_MAX && fsp->ring_cookie < (u64)(-2))
+		return -1;
+
+	/* verify only one field is setting data field */
+	if ((fsp->flow_type & FLOW_EXT) &&
+	    (fsp->m_ext.data[0] || fsp->m_ext.data[1]) &&
+	    fsp->m_ext.vlan_etype)
+		return -1;
+
+	/* Set entire ntuple to ~0 to guarantee all masks are set */
+	memset(ntuple, ~0, sizeof(*ntuple));
+
+	/* set non-filter values */
+	ntuple->flow_type = fsp->flow_type;
+	ntuple->action = fsp->ring_cookie;
+
+	/*
+	 * Copy over header union, they are identical in layout however
+	 * the ntuple union contains additional padding on the end
+	 */
+	memcpy(&ntuple->h_u, &fsp->h_u, sizeof(fsp->h_u));
+
+	/*
+	 * The same rule mentioned above applies to the mask union.  However,
+	 * in addition we need to invert the mask bits to match the ntuple
+	 * mask which is 1 for masked, versus 0 for masked as seen in nfc.
+	 */
+	memcpy(&ntuple->m_u, &fsp->m_u, sizeof(fsp->m_u));
+	for (i = 0; i < sizeof(fsp->m_u); i++)
+		ntuple->m_u.hdata[i] ^= 0xFF;
+
+	/* copy extended fields */
+	if (fsp->flow_type & FLOW_EXT) {
+		ntuple->vlan_tag =
+			ntohs(fsp->h_ext.vlan_tci);
+		ntuple->vlan_tag_mask =
+			~ntohs(fsp->m_ext.vlan_tci);
+		if (fsp->m_ext.vlan_etype) {
+			/*
+			 * vlan_etype and user data are mutually exclusive
+			 * in ntuple configuration as they occupy the same
+			 * space.
+			 */
+			if (fsp->m_ext.data[0] || fsp->m_ext.data[1])
+				return -1;
+			ntuple->data =
+				ntohl(fsp->h_ext.vlan_etype);
+			ntuple->data_mask =
+				~(u64)ntohl(fsp->m_ext.vlan_etype);
+		} else {
+			ntuple->data =
+				(u64)ntohl(fsp->h_ext.data[0]) << 32;
+			ntuple->data |=
+				(u64)ntohl(fsp->h_ext.data[1]);
+			ntuple->data_mask =
+				(u64)ntohl(~fsp->m_ext.data[0]) << 32;
+			ntuple->data_mask |=
+				(u64)ntohl(~fsp->m_ext.data[1]);
+		}
+	}
+
+	return 0;
+}
+
 static int do_srxntuple(int fd, struct ifreq *ifr)
 {
+	struct ethtool_rx_ntuple ntuplecmd;
+	struct ethtool_value eval;
 	int err;
 
-	if (sntuple_changed) {
-		struct ethtool_rx_ntuple ntuplecmd;
+	/* attempt to convert the flow classifier to an ntuple classifier */
+	err = flow_spec_to_ntuple(&rx_rule_fs, &ntuplecmd.fs);
+	if (err)
+		return -1;
 
-		ntuplecmd.cmd = ETHTOOL_SRXNTUPLE;
-		memcpy(&ntuplecmd.fs, &ntuple_fs,
-		       sizeof(struct ethtool_rx_ntuple_flow_spec));
+	/*
+	 * Check to see if the flag is set for N-tuple, this allows
+	 * us to avoid the possible EINVAL response for the N-tuple
+	 * flag not being set on the device
+	 */
+	eval.cmd = ETHTOOL_GFLAGS;
+	ifr->ifr_data = (caddr_t)&eval;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err || !(eval.data & ETH_FLAG_NTUPLE))
+		return -1;
 
-		ifr->ifr_data = (caddr_t)&ntuplecmd;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err < 0)
-			perror("Cannot add new RX n-tuple filter");
+	/* send rule via N-tuple */
+	ntuplecmd.cmd = ETHTOOL_SRXNTUPLE;
+	ifr->ifr_data = (caddr_t)&ntuplecmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+
+	/*
+	 * Display error only if reponse is something other than op not
+	 * supported.  It is possible that the interface uses the network
+	 * flow classifier interface instead of N-tuple. 
+	 */ 
+	if (err && errno != EOPNOTSUPP)
+		perror("Cannot add new rule via N-tuple");
+
+	return err;
+}
+
+static int do_srxclsrule(int fd, struct ifreq *ifr)
+{
+	int err;
+
+	if (rx_class_rule_added) {
+		/* attempt to add rule via N-tuple specifier */
+		err = do_srxntuple(fd, ifr);
+		if (!err)
+			return 0;
+
+		/* attempt to add rule via network flow classifier */
+		err = rxclass_rule_ins(fd, ifr, &rx_rule_fs);
+		if (err < 0) {
+			fprintf(stderr, "Cannot insert"
+				" classification rule\n");
+			return 1;
+		}
+	} else if (rx_class_rule_del >= 0) {
+		err = rxclass_rule_del(fd, ifr, rx_class_rule_del);
+
+		if (err < 0) {
+			fprintf(stderr, "Cannot delete"
+				" classification rule\n");
+			return 1;
+		}
 	} else {
 		exit_bad_args();
 	}
@@ -3177,9 +3208,32 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_grxntuple(int fd, struct ifreq *ifr)
+static int do_grxclsrule(int fd, struct ifreq *ifr)
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
+
+	return err ? 1 : 0;
 }
 
 static int send_ioctl(int fd, struct ifreq *ifr)
diff --git a/rxclass.c b/rxclass.c
new file mode 100644
index 0000000..1e6b2a6
--- /dev/null
+++ b/rxclass.c
@@ -0,0 +1,1039 @@
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
+static void invert_flow_mask(struct ethtool_rx_flow_spec *fsp)
+{
+	size_t i;
+
+	for (i = 0; i < sizeof(fsp->m_u); i++)
+		fsp->m_u.hdata[i] ^= 0xFF;
+}
+
+static void rmgr_print_ipv4_rule(__be32 sip, __be32 sipm, __be32 dip,
+				 __be32 dipm, u8 tos, u8 tosm)
+{
+	char sip_str[INET_ADDRSTRLEN];
+	char sipm_str[INET_ADDRSTRLEN];
+	char dip_str[INET_ADDRSTRLEN];
+	char dipm_str[INET_ADDRSTRLEN];
+
+	fprintf(stdout,
+		"\tSrc IP addr: %s mask: %s\n"
+		"\tDest IP addr: %s mask: %s\n"
+		"\tTOS: 0x%x mask: 0x%x\n",
+		inet_ntop(AF_INET, &sip, sip_str, INET_ADDRSTRLEN),
+		inet_ntop(AF_INET, &sipm, sipm_str, INET_ADDRSTRLEN),
+		inet_ntop(AF_INET, &dip, dip_str, INET_ADDRSTRLEN),
+		inet_ntop(AF_INET, &dipm, dipm_str, INET_ADDRSTRLEN),
+		tos, tosm);
+}
+
+static void rmgr_print_nfc_spec_ext(struct ethtool_rx_flow_spec *fsp)
+{
+	u64 data, datam;
+	__u16 etype, etypem, tci, tcim;
+
+	if (!(fsp->flow_type & FLOW_EXT))
+		return;
+
+	etype = ntohs(fsp->h_ext.vlan_etype);
+	etypem = ntohs(~fsp->m_ext.vlan_etype);
+	tci = ntohs(fsp->h_ext.vlan_tci);
+	tcim = ntohs(~fsp->m_ext.vlan_tci);
+	data = (u64)ntohl(fsp->h_ext.data[0]) << 32;
+	data = (u64)ntohl(fsp->h_ext.data[1]);
+	datam = (u64)ntohl(~fsp->m_ext.data[0]) << 32;
+	datam |= (u64)ntohl(~fsp->m_ext.data[1]);
+
+	fprintf(stdout,
+		"\tVLAN EtherType: 0x%x mask: 0x%x\n"
+		"\tVLAN: 0x%x mask: 0x%x\n"
+		"\tUser-defined: 0x%llx mask: 0x%llx\n",
+		etype, etypem, tci, tcim, data, datam);
+}
+
+static void rmgr_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
+{
+	unsigned char	*smac, *smacm, *dmac, *dmacm;
+	__u32		flow_type;
+
+	if (fsp->location != RX_CLS_LOC_UNSPEC)
+		fprintf(stdout,	"Filter: %d\n", fsp->location);
+	else
+		fprintf(stdout,	"Filter: Unspecified\n");
+
+	flow_type = fsp->flow_type & ~FLOW_EXT;
+
+	invert_flow_mask(fsp);
+
+	switch (flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+		if (flow_type == TCP_V4_FLOW)
+			fprintf(stdout, "\tRule Type: TCP over IPv4\n");
+		else if (flow_type == UDP_V4_FLOW)
+			fprintf(stdout, "\tRule Type: UDP over IPv4\n");
+		else
+			fprintf(stdout, "\tRule Type: SCTP over IPv4\n");
+		rmgr_print_ipv4_rule(fsp->h_u.tcp_ip4_spec.ip4src,
+				     fsp->m_u.tcp_ip4_spec.ip4src,
+				     fsp->h_u.tcp_ip4_spec.ip4dst,
+				     fsp->m_u.tcp_ip4_spec.ip4dst,
+				     fsp->h_u.tcp_ip4_spec.tos,
+				     fsp->m_u.tcp_ip4_spec.tos);
+		fprintf(stdout,
+			"\tSrc port: %d mask: 0x%x\n"
+			"\tDest port: %d mask: 0x%x\n",
+			ntohs(fsp->h_u.tcp_ip4_spec.psrc),
+			ntohs(fsp->m_u.tcp_ip4_spec.psrc),
+			ntohs(fsp->h_u.tcp_ip4_spec.pdst),
+			ntohs(fsp->m_u.tcp_ip4_spec.pdst));
+		break;
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		if (flow_type == AH_V4_FLOW)
+			fprintf(stdout, "\tRule Type: IPSEC AH over IPv4\n");
+		else
+			fprintf(stdout, "\tRule Type: IPSEC ESP over IPv4\n");
+		rmgr_print_ipv4_rule(fsp->h_u.ah_ip4_spec.ip4src,
+				     fsp->m_u.ah_ip4_spec.ip4src,
+				     fsp->h_u.ah_ip4_spec.ip4dst,
+				     fsp->m_u.ah_ip4_spec.ip4dst,
+				     fsp->h_u.ah_ip4_spec.tos,
+				     fsp->m_u.ah_ip4_spec.tos);
+		fprintf(stdout,
+			"\tSPI: %d mask: 0x%x\n",
+			ntohl(fsp->h_u.esp_ip4_spec.spi),
+			ntohl(fsp->m_u.esp_ip4_spec.spi));
+		break;
+	case IP_USER_FLOW:
+		fprintf(stdout, "\tRule Type: Raw IPv4\n");
+		rmgr_print_ipv4_rule(fsp->h_u.usr_ip4_spec.ip4src,
+				     fsp->m_u.usr_ip4_spec.ip4src,
+				     fsp->h_u.usr_ip4_spec.ip4dst,
+				     fsp->m_u.usr_ip4_spec.ip4dst,
+				     fsp->h_u.usr_ip4_spec.tos,
+				     fsp->m_u.usr_ip4_spec.tos);
+		fprintf(stdout,
+			"\tProtocol: %d mask: 0x%x\n"
+			"\tL4 bytes: 0x%x mask: 0x%x\n",
+			fsp->h_u.usr_ip4_spec.proto,
+			fsp->m_u.usr_ip4_spec.proto,
+			ntohl(fsp->h_u.usr_ip4_spec.l4_4_bytes),
+			ntohl(fsp->m_u.usr_ip4_spec.l4_4_bytes));
+		break;
+	case ETHER_FLOW:
+		dmac = fsp->h_u.ether_spec.h_dest;
+		dmacm = fsp->m_u.ether_spec.h_dest;
+		smac = fsp->h_u.ether_spec.h_source;
+		smacm = fsp->m_u.ether_spec.h_source;
+
+		fprintf(stdout,
+			"\tFlow Type: Raw Ethernet\n"
+			"\tSrc MAC addr: %02X:%02X:%02X:%02X:%02X:%02X"
+			" mask: %02X:%02X:%02X:%02X:%02X:%02X\n"
+			"\tDest MAC addr: %02X:%02X:%02X:%02X:%02X:%02X"
+			" mask: %02X:%02X:%02X:%02X:%02X:%02X\n"
+			"\tEthertype: 0x%X mask: 0x%X\n",
+			smac[0], smac[1], smac[2], smac[3], smac[4], smac[5],
+			smacm[0], smacm[1], smacm[2], smacm[3], smacm[4],
+			smacm[5], dmac[0], dmac[1], dmac[2], dmac[3], dmac[4],
+			dmac[5], dmacm[0], dmacm[1], dmacm[2], dmacm[3],
+			dmacm[4], dmacm[5],
+			ntohs(fsp->h_u.ether_spec.h_proto),
+			ntohs(fsp->m_u.ether_spec.h_proto));
+		break;
+	default:
+		fprintf(stdout,
+			"\tUnknown Flow type: %d\n", flow_type);
+		break;
+	}
+
+	rmgr_print_nfc_spec_ext(fsp);
+
+	if (fsp->ring_cookie != RX_CLS_FLOW_DISC)
+		fprintf(stdout, "\tAction: Direct to queue %llu\n",
+			fsp->ring_cookie);
+	else
+		fprintf(stdout, "\tAction: Drop\n");
+
+	fprintf(stdout, "\n");
+}
+
+static void rmgr_print_rule(struct ethtool_rx_flow_spec *fsp)
+{
+	/* print the rule in this location */
+	switch (fsp->flow_type & ~FLOW_EXT) {
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
+	if (loc >= rmgr.size) {
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
+static int rmgr_add(struct ethtool_rx_flow_spec *fsp)
+{
+	__u32 loc = fsp->location;
+	__u32 slot_num;
+
+	/* start at the end of the list since it is lowest priority */
+	loc = rmgr.size - 1;
+
+	/* locate the first slot a rule can be placed in */
+	slot_num = loc / BITS_PER_LONG;
+
+	/*
+	 * Avoid testing individual bits by inverting the word and checking
+	 * to see if any bits are left set, if so there are empty spots.  By
+	 * moving 1 + loc % BITS_PER_LONG we align ourselves to the last bit
+	 * in the previous word.
+	 *
+	 * If loc rolls over it should be greater than or equal to rmgr.size
+	 * and as such we know we have reached the end of the list.
+	 */
+	if (!~(rmgr.slot[slot_num] | (~1UL << rmgr.size % BITS_PER_LONG))) {
+		loc -= 1 + (loc % BITS_PER_LONG);
+		slot_num--;
+	}
+
+	/*
+	 * Now that we are aligned with the last bit in each long we can just
+	 * go though and eliminate all the longs with no free bits
+	 */
+	while (loc < rmgr.size && !~(rmgr.slot[slot_num])) {
+		loc -= BITS_PER_LONG;
+		slot_num--;
+	}
+
+	/*
+	 * If we still are inside the range, test individual bits as one is
+	 * likely available for our use.
+	 */
+	while (loc < rmgr.size && test_bit(loc, rmgr.slot))
+		loc--;
+
+	/* location found, insert rule */
+	if (loc < rmgr.size) {
+		fsp->location = loc;
+		return rmgr_ins(loc);
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
+		perror("rmgr: Cannot allocate memory for"
+		       " RX class rule locations");
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
+	/* make certain the table size is valid */
+	rmgr.size = nfccmd->data;
+	if (rmgr.size == 0 || rmgr.size < rmgr.n_rules) {
+		perror("rmgr: Invalid RX class rules table size");
+		return -1;
+	}
+
+	/* initialize bitmap for storage of valid locations */
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
+int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc)
+{
+	struct ethtool_rxnfc nfccmd;
+
+	/* fetch rule from netdev and display */
+	nfccmd.cmd = ETHTOOL_GRXCLSRULE;
+	memset(&nfccmd.fs, 0, sizeof(struct ethtool_rx_flow_spec));
+	nfccmd.fs.location = loc;
+	ifr->ifr_data = (caddr_t)&nfccmd;
+	if (ioctl(fd, SIOCETHTOOL, ifr) < 0) {
+		perror("rmgr: Cannot get RX class rule");
+		return -1;
+	}
+
+	rmgr_print_rule(&nfccmd.fs);
+	return 0;
+}
+
+int rxclass_rule_getall(int fd, struct ifreq *ifr)
+{
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
+		if (!rmgr.slot[i / BITS_PER_LONG])
+			continue;
+		for (j = 0; j < BITS_PER_LONG; j++) {
+			if (!test_bit(i + j, rmgr.slot))
+				continue;
+			err = rxclass_rule_get(fd, ifr, i + j);
+			if (err < 0) {
+				rmgr_cleanup();
+				return err;
+			}
+		}
+	}
+
+	rmgr_cleanup();
+	return 0;
+}
+
+int rxclass_rule_ins(int fd, struct ifreq *ifr,
+		     struct ethtool_rx_flow_spec *fsp)
+{
+	struct ethtool_rxnfc nfccmd;
+	__u32 loc = fsp->location;
+	int err;
+
+	/*
+	 * if location is unspecified pull rules from device
+	 * and allocate a free rule for our use
+	 */
+	if (loc == RX_CLS_LOC_UNSPEC) {
+		/* init table of available rules */
+		err = rmgr_init(fd, ifr);
+		if (err < 0)
+			return err;
+
+		/* verify rule location */
+		err = rmgr_add(fsp);
+		if (err < 0)
+			return err;
+
+		/* cleanup table and free resources */
+		rmgr_cleanup();
+	}
+
+	/* notify netdev of new rule */
+	nfccmd.cmd = ETHTOOL_SRXCLSRLINS;
+	nfccmd.fs = *fsp;
+	ifr->ifr_data = (caddr_t)&nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0)
+		perror("rmgr: Cannot insert RX class rule");
+	else if (loc == RX_CLS_LOC_UNSPEC)
+		printf("Added rule with ID %d\n", fsp->location);
+
+	return 0;
+}
+
+int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc)
+{
+	struct ethtool_rxnfc nfccmd;
+	int err;
+
+	/* notify netdev of rule removal */
+	nfccmd.cmd = ETHTOOL_SRXCLSRLDEL;
+	nfccmd.fs.location = loc;
+	ifr->ifr_data = (caddr_t)&nfccmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0)
+		perror("rmgr: Cannot delete RX class rule");
+
+	return err;
+}
+
+typedef enum {
+	OPT_NONE = 0,
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
+#define NTUPLE_FLAG_VETH	0x400
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
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
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
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
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
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
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
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
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
+			   const struct rule_opts *opt)
+{
+	unsigned long long mask = ~0ULL;
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
+			return -1;
+		*(int *)&p[opt->moffset] = ~(int)val;
+		break;
+	}
+	case OPT_U8: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 8);
+		if (err)
+			return -1;
+		*(u8 *)&p[opt->moffset] = ~(u8)val;
+		break;
+	}
+	case OPT_U16: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 16);
+		if (err)
+			return -1;
+		*(u16 *)&p[opt->moffset] = ~(u16)val;
+		break;
+	}
+	case OPT_U32: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 32);
+		if (err)
+			return -1;
+		*(u32 *)&p[opt->moffset] = ~(u32)val;
+		break;
+	}
+	case OPT_U64: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 64);
+		if (err)
+			return -1;
+		*(u64 *)&p[opt->moffset] = ~(u64)val;
+		break;
+	}
+	case OPT_BE16: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 16);
+		if (err)
+			return -1;
+		*(__be16 *)&p[opt->moffset] = ~htons((u16)val);
+		break;
+	}
+	case OPT_BE32: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 32);
+		if (err)
+			return -1;
+		*(__be32 *)&p[opt->moffset] = ~htonl((u32)val);
+		break;
+	}
+	case OPT_BE64: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 64);
+		if (err)
+			return -1;
+		*(__be64 *)&p[opt->moffset] = ~htonll((u64)val);
+		break;
+	}
+	case OPT_IP4: {
+		__be32 val;
+		err = rxclass_get_ipv4(str, &val);
+		if (err)
+			return -1;
+		*(__be32 *)&p[opt->moffset] = ~val;
+		break;
+	}
+	case OPT_MAC: {
+		unsigned char val[ETH_ALEN];
+		int i;
+		err = rxclass_get_ether(str, val);
+		if (err)
+			return -1;
+
+		for (i = 0; i < ETH_ALEN; i++)
+			val[i] = ~val[i];
+
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
+int rxclass_parse_ruleopts(char **argp, int argc,
+			   struct ethtool_rx_flow_spec *fsp)
+{
+	const struct rule_opts *options;
+	unsigned char *p = (unsigned char *)fsp;
+	int i = 0, n_opts, err;
+	u32 flags = 0;
+	int flow_type;
+
+	if (argc < 1)
+		goto syntax_err;
+
+	if (!strcmp(argp[0], "tcp4"))
+		flow_type = TCP_V4_FLOW;
+	else if (!strcmp(argp[0], "udp4"))
+		flow_type = UDP_V4_FLOW;
+	else if (!strcmp(argp[0], "sctp4"))
+		flow_type = SCTP_V4_FLOW;
+	else if (!strcmp(argp[0], "ah4"))
+		flow_type = AH_V4_FLOW;
+	else if (!strcmp(argp[0], "esp4"))
+		flow_type = ESP_V4_FLOW;
+	else if (!strcmp(argp[0], "ip4"))
+		flow_type = IP_USER_FLOW;
+	else if (!strcmp(argp[0], "ether"))
+		flow_type = ETHER_FLOW;
+	else
+		goto syntax_err;
+
+	switch (flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+		options = rule_nfc_tcp_ip4;
+		n_opts = ARRAY_SIZE(rule_nfc_tcp_ip4);
+		break;
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		options = rule_nfc_esp_ip4;
+		n_opts = ARRAY_SIZE(rule_nfc_esp_ip4);
+		break;
+	case IP_USER_FLOW:
+		options = rule_nfc_usr_ip4;
+		n_opts = ARRAY_SIZE(rule_nfc_usr_ip4);
+		break;
+	case ETHER_FLOW:
+		options = rule_nfc_ether;
+		n_opts = ARRAY_SIZE(rule_nfc_ether);
+		break;
+	default:
+		fprintf(stderr, "Add rule, invalid rule type[%s]\n", argp[0]);
+		return -1;
+	}
+
+	memset(p, 0, sizeof(*fsp));
+	fsp->flow_type = flow_type;
+	fsp->location = RX_CLS_LOC_UNSPEC;
+
+	for (i = 1; i < argc;) {
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
+			err = rxclass_get_val(argp[i], p, &flags, opt);
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
+			if (strcmp(argp[i], "m") && strcmp(argp[i], mask_name))
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
+			fprintf(stdout, "Add rule, unrecognized option[%s]\n",
+				argp[i]);
+			return -1;
+		}
+	}
+
+	if (flags & (NTUPLE_FLAG_VLAN | NTUPLE_FLAG_UDEF | NTUPLE_FLAG_VETH))
+		fsp->flow_type |= FLOW_EXT;
+
+	return 0;
+
+syntax_err:
+	fprintf(stderr, "Add rule, invalid syntax\n");
+	return -1;
+}

