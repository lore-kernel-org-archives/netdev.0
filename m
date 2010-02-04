From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Wed, 03 Feb 2010 23:51:01 -0800
Message-ID: <20100204075101.16661.95658.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:59776
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756728Ab0BDHv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 02:51:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Program underlying ethernet devices with n-tuple flow classification
filters.

This also adds a new flag to ethtool_flags, allowing n-tuple
programming to be toggled using the set_flags call.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 ethtool-copy.h |   35 +++++++++++++
 ethtool.c      |  156 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 186 insertions(+), 5 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d366c3a..2681cd8 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -241,6 +241,7 @@ enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
+	ETH_SS_NTUPLE_FILTERS,
 };
 
 /* for passing string sets for data tagging */
@@ -289,6 +290,7 @@ struct ethtool_perm_addr {
  */
 enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
+	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
 };
 
 /* The following structures are for supporting RX network flow
@@ -374,6 +376,36 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
 
+struct ethtool_rx_ntuple_flow_spec {
+	int		flow_type;
+	union {
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
+
+	__u16	        vlan_tag;
+	__u16	        vlan_tag_mask;
+	__u64		data;      /* user-defined flow spec data */
+	__u64		data_mask; /* user-defined flow spec mask */
+
+	/* signed to distinguish between queue and actions (DROP) */
+	int		action;
+#define ETHTOOL_RXNTUPLE_ACTION_DROP -1
+};
+
+#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
+#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
+struct ethtool_rx_ntuple {
+	__u32					cmd;
+	struct ethtool_rx_ntuple_flow_spec	fs;
+};
 
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
@@ -431,6 +463,9 @@ struct ethtool_flash {
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
 
+#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
+#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/ethtool.c b/ethtool.c
index 10ff1f1..fc9e419 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -78,6 +78,8 @@ static char *unparse_rxfhashopts(u64 opts);
 static int dump_rxfhash(int fhash, u64 val);
 static int do_srxclass(int fd, struct ifreq *ifr);
 static int do_grxclass(int fd, struct ifreq *ifr);
+static int do_srxntuple(int fd, struct ifreq *ifr);
+static int do_grxntuple(int fd, struct ifreq *ifr);
 static int do_flash(int fd, struct ifreq *ifr);
 static int send_ioctl(int fd, struct ifreq *ifr);
 
@@ -103,6 +105,8 @@ static enum {
 	MODE_GSTATS,
 	MODE_GNFC,
 	MODE_SNFC,
+	MODE_SNTUPLE,
+	MODE_GNTUPLE,
 	MODE_FLASHDEV,
 } mode = MODE_GSET;
 
@@ -168,6 +172,7 @@ static struct option {
 		"		[ gso on|off ]\n"
 		"		[ gro on|off ]\n"
 		"		[ lro on|off ]\n"
+		"		[ ntuple on|off ]\n"
     },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
     { "-d", "--register-dump", MODE_GREGS, "Do a register dump",
@@ -199,6 +204,16 @@ static struct option {
 		"classification options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
 		"tcp6|udp6|ah6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
+    { "-U", "--config-ntuple", MODE_SNTUPLE, "Configure Rx ntuple filters "
+		"and actions",
+		"               [ flow-type tcp4|udp4|sctp4 src-ip <addr> "
+		"src-ip-mask <mask> dst-ip <addr> dst-ip-mask <mask> "
+		"src-port <port> src-port-mask <mask> dst-port <port> "
+		"dst-port-mask <mask> vlan <VLAN tag> vlan-mask <mask> "
+		"user-def <data> user-def-mask <mask> "
+		"action <queue or drop>\n" },
+    { "-u", "--show-ntuple", MODE_GNTUPLE,
+		"Get Rx ntuple filters and actions\n" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -241,6 +256,7 @@ static int off_ufo_wanted = -1;
 static int off_gso_wanted = -1;
 static int off_lro_wanted = -1;
 static int off_gro_wanted = -1;
+static int off_ntuple_wanted = -1;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -312,6 +328,8 @@ static int rx_fhash_get = 0;
 static int rx_fhash_set = 0;
 static u32 rx_fhash_val = 0;
 static int rx_fhash_changed = 0;
+static int sntuple_changed = 0;
+static struct ethtool_rx_ntuple_flow_spec ntuple_fs;
 static char *flash_file = NULL;
 static int flash = -1;
 static int flash_region = -1;
@@ -363,6 +381,7 @@ static struct cmdline_info cmdline_offload[] = {
 	{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
 	{ "lro", CMDL_BOOL, &off_lro_wanted, NULL },
 	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
+	{ "ntuple", CMDL_BOOL, &off_ntuple_wanted, NULL },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -403,6 +422,22 @@ static struct cmdline_info cmdline_coalesce[] = {
 	{ "tx-frames-high", CMDL_INT, &coal_tx_frames_high_wanted, &ecoal.tx_max_coalesced_frames_high },
 };
 
+static struct cmdline_info cmdline_ntuple[] = {
+	{ "src-ip", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL },
+	{ "src-ip-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL },
+	{ "dst-ip", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL },
+	{ "dst-ip-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL },
+	{ "src-port", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.psrc, NULL },
+	{ "src-port-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.psrc, NULL },
+	{ "dst-port", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.pdst, NULL },
+	{ "dst-port-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.pdst, NULL },
+	{ "vlan", CMDL_INT, &ntuple_fs.vlan_tag, NULL },
+	{ "vlan-mask", CMDL_UINT, &ntuple_fs.vlan_tag_mask, NULL },
+	{ "user-def", CMDL_INT, &ntuple_fs.data, NULL },
+	{ "user-def-mask", CMDL_UINT, &ntuple_fs.data_mask, NULL },
+	{ "action", CMDL_INT, &ntuple_fs.action, NULL },
+};
+
 static int get_int(char *str, int base)
 {
 	long v;
@@ -544,6 +579,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GSTATS) ||
 			    (mode == MODE_GNFC) ||
 			    (mode == MODE_SNFC) ||
+			    (mode == MODE_SNTUPLE) ||
+			    (mode == MODE_GNTUPLE) ||
 			    (mode == MODE_PHYS_ID) ||
 			    (mode == MODE_FLASHDEV)) {
 				devname = argp[i];
@@ -626,6 +663,27 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_SNTUPLE) {
+				if (!strcmp(argp[i], "flow-type")) {
+					i += 1;
+					if (i >= argc) {
+						show_usage(1);
+						break;
+					}
+					ntuple_fs.flow_type =
+					            rxflow_str_to_type(argp[i]);
+					i += 1;
+					parse_generic_cmdline(argc, argp, i,
+						&sntuple_changed,
+						cmdline_ntuple,
+						ARRAY_SIZE(cmdline_ntuple));
+					i = argc;
+					break;
+				} else {
+					show_usage(1);
+				}
+				break;
+			}
 			if (mode == MODE_GNFC) {
 				if (!strcmp(argp[i], "rx-flow-hash")) {
 					i += 1;
@@ -1468,7 +1526,7 @@ static int dump_coalesce(void)
 }
 
 static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
-			int gro, int lro)
+			int gro, int lro, int ntuple)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1478,7 +1536,8 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		"udp-fragmentation-offload: %s\n"
 		"generic-segmentation-offload: %s\n"
 		"generic-receive-offload: %s\n"
-		"large-receive-offload: %s\n",
+		"large-receive-offload: %s\n"
+		"ntuple-filters: %s\n",
 		rx ? "on" : "off",
 		tx ? "on" : "off",
 		sg ? "on" : "off",
@@ -1486,7 +1545,8 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
 		ufo ? "on" : "off",
 		gso ? "on" : "off",
 		gro ? "on" : "off",
-		lro ? "on" : "off");
+		lro ? "on" : "off",
+		ntuple ? "on" : "off");
 
 	return 0;
 }
@@ -1590,6 +1650,10 @@ static int doit(void)
 		return do_grxclass(fd, &ifr);
 	} else if (mode == MODE_SNFC) {
 		return do_srxclass(fd, &ifr);
+	} else if (mode == MODE_SNTUPLE) {
+		return do_srxntuple(fd, &ifr);
+	} else if (mode == MODE_GNTUPLE) {
+		return do_grxntuple(fd, &ifr);
 	} else if (mode == MODE_FLASHDEV) {
 		return do_flash(fd, &ifr);
 	}
@@ -1799,7 +1863,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
 	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
-	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0;
+	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0, ntuple = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -1870,6 +1934,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		perror("Cannot get device flags");
 	} else {
 		lro = (eval.data & ETH_FLAG_LRO) != 0;
+		ntuple = (eval.data & ETH_FLAG_NTUPLE) != 0;
 		allfail = 0;
 	}
 
@@ -1888,7 +1953,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro);
+	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, ntuple);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
@@ -1999,6 +2064,29 @@ static int do_soffload(int fd, struct ifreq *ifr)
 			return 93;
 		}
 	}
+	if (off_ntuple_wanted >= 0) {
+		changed = 1;
+		eval.cmd = ETHTOOL_GFLAGS;
+		eval.data = 0;
+		ifr->ifr_data = (caddr_t)&eval;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot get device flag settings");
+			return 91;
+		}
+
+		eval.cmd = ETHTOOL_SFLAGS;
+		if (off_ntuple_wanted == 1)
+			eval.data |= ETH_FLAG_NTUPLE;
+		else
+			eval.data &= ~ETH_FLAG_NTUPLE;
+
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot set n-tuple filter settings");
+			return 93;
+		}
+	}
 
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
@@ -2545,6 +2633,64 @@ static int do_flash(int fd, struct ifreq *ifr)
 	return err;
 }
 
+static int do_srxntuple(int fd, struct ifreq *ifr)
+{
+	int err;
+
+	if (sntuple_changed) {
+		struct ethtool_rx_ntuple ntuplecmd;
+
+		ntuplecmd.cmd = ETHTOOL_SRXNTUPLE;
+		memcpy(&ntuplecmd.fs, &ntuple_fs,
+		       sizeof(struct ethtool_rx_ntuple_flow_spec));
+
+		ifr->ifr_data = (caddr_t)&ntuplecmd;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err < 0)
+			perror("Cannot add new RX n-tuple filter");
+	} else {
+		show_usage(1);
+	}
+
+	return 0;
+}
+
+static int do_grxntuple(int fd, struct ifreq *ifr)
+{
+	struct ethtool_gstrings *strings;
+	int sz_str, n_strings, err, i;
+
+	n_strings = ETHTOOL_MAX_NTUPLE_LIST_ENTRY *
+	            ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY;
+	sz_str = n_strings * ETH_GSTRING_LEN;
+
+	strings = calloc(1, sz_str + sizeof(struct ethtool_gstrings));
+	if (!strings) {
+		fprintf(stderr, "no memory available\n");
+		return 95;
+	}
+
+	strings->cmd = ETHTOOL_GRXNTUPLE;
+	strings->string_set = ETH_SS_NTUPLE_FILTERS;
+	strings->len = n_strings;
+	ifr->ifr_data = (caddr_t) strings;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot get Rx n-tuple information");
+		free(strings);
+		return 100;
+	}
+
+	n_strings = strings->len;
+	fprintf(stdout, "Rx n-tuple filters:\n");
+	for (i = 0; i < n_strings; i++)
+		fprintf(stdout, "%s", &strings->data[i * ETH_GSTRING_LEN]);
+
+	free(strings);
+
+	return 0;
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	return ioctl(fd, SIOCETHTOOL, ifr);

