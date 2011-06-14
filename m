From: Carolyn Wyborny <carolyn.wyborny@intel.com>
Subject: [RFC 1/2] ethtool:  Add DMA Coalescing adapter feature to ethtool.
Date: Tue, 14 Jun 2011 10:12:36 -0700
Message-ID: <1308071556-6271-1-git-send-email-carolyn.wyborny@intel.com>
To: netdev@vger.kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64469 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589Ab1FNRK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 13:10:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This RFC patch adds support for DMA Coalescing device feature
configuration via ethtool.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
---
 ethtool.8.in |   13 +
 ethtool.c    |  709 ++++++++++++++++++++++++++++++++--------------------------
 2 files changed, 407 insertions(+), 315 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7b1cdf5..006cd0d 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -283,6 +283,13 @@ ethtool \- query or control network driver and hardware settings
 .I ethX
 .BN rule
 .HP
+.B ethtool \-z|\-\-show\-dmac
+.I ethX
+.HP
+.B ethtool \-Z|\-\-dmac
+.I ethX
+.BN tune
+.HP
 .BI ethtool\ \-U|\-\-config\-ntuple \ ethX
 .BN delete
 .RB [\  flow\-type \ \*(NC
@@ -729,6 +736,12 @@ Includes 64-bits of user-specific data and an optional mask.
 .TP
 .BI action \ N
 Specifies the Rx queue to send packets to, or some other action.
+.TP
+.B \-z \-\-show\-dmac
+Specifies current setting for DMA Coalescing.
+.TP
+.B \-Z \-\-change\-dmac
+Changes the setting for DMA Coalescing.
 .TS
 nokeep;
 lB	l.
diff --git a/ethtool.c b/ethtool.c
index c189c78..5692e0a 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -99,7 +99,8 @@ static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
 static int do_getfwdump(int fd, struct ifreq *ifr);
 static int do_setfwdump(int fd, struct ifreq *ifr);
-
+static int do_gdmac(int fd, struct ifreq *ifr);
+static int do_sdmac(int fd, struct ifreq *ifr);
 static int send_ioctl(int fd, struct ifreq *ifr);
 
 static enum {
@@ -133,6 +134,8 @@ static enum {
 	MODE_PERMADDR,
 	MODE_SET_DUMP,
 	MODE_GET_DUMP,
+	MODE_GDMAC,
+	MODE_SDMAC,
 } mode = MODE_GSET;
 
 static struct option {
@@ -257,18 +260,21 @@ static struct option {
 		"			[ loc %d]]\n" },
     { "-u", "--show-ntuple", MODE_GCLSRULE,
 		"Get Rx ntuple filters and actions",
-		"		[ rule %d ]\n"},
+	"		[ rule %d ]\n"},
     { "-P", "--show-permaddr", MODE_PERMADDR,
-		"Show permanent hardware address" },
+	"Show permanent hardware address" },
     { "-w", "--get-dump", MODE_GET_DUMP,
-		"Get dump flag, data",
-		"		[ data FILENAME ]\n" },
+	"Get dump flag, data",
+	"		[ data FILENAME ]\n" },
     { "-W", "--set-dump", MODE_SET_DUMP,
-		"Set dump flag of the device",
-		"		N\n"},
+	"Set dump flag of the device",
+	"		N\n"},
+    { "-z", "--show-dmac", MODE_GDMAC, "Show DMA coalesce options" },
+    { "-Z", "--dmac", MODE_SDMAC, "Set DMA coalesce options",
+	"		[dmac N]\n"},
     { "-h", "--help", MODE_HELP, "Show this help" },
     { NULL, "--version", MODE_VERSION, "Show version number" },
-    {}
+{}
 };
 
 
@@ -404,338 +410,346 @@ static int rx_class_rule_del = -1;
 static int rx_class_rule_added = 0;
 static struct ethtool_rx_flow_spec rx_rule_fs;
 
+static struct ethtool_dmac edmac;
+static int sdmac_changed;
+static s32 dmac_tune_wanted = -1;
+
 static enum {
-	ONLINE=0,
-	OFFLINE,
+ONLINE=0,
+OFFLINE,
 } test_type = OFFLINE;
 
 typedef enum {
-	CMDL_NONE,
-	CMDL_BOOL,
-	CMDL_S32,
-	CMDL_U16,
-	CMDL_U32,
-	CMDL_U64,
-	CMDL_BE16,
-	CMDL_IP4,
-	CMDL_STR,
-	CMDL_FLAG,
-	CMDL_MAC,
+CMDL_NONE,
+CMDL_BOOL,
+CMDL_S32,
+CMDL_U16,
+CMDL_U32,
+CMDL_U64,
+CMDL_BE16,
+CMDL_IP4,
+CMDL_STR,
+CMDL_FLAG,
+CMDL_MAC,
 } cmdline_type_t;
 
 struct cmdline_info {
-	const char *name;
-	cmdline_type_t type;
-	/* Points to int (BOOL), s32, u16, u32 (U32/FLAG/IP4), u64,
-	 * char * (STR) or u8[6] (MAC).  For FLAG, the value accumulates
-	 * all flags to be set. */
-	void *wanted_val;
-	void *ioctl_val;
-	/* For FLAG, the flag value to be set/cleared */
-	u32 flag_val;
-	/* For FLAG, points to u32 and accumulates all flags seen.
-	 * For anything else, points to int and is set if the option is
-	 * seen. */
-	void *seen_val;
+const char *name;
+cmdline_type_t type;
+/* Points to int (BOOL), s32, u16, u32 (U32/FLAG/IP4), u64,
+	* char * (STR) or u8[6] (MAC).  For FLAG, the value accumulates
+	* all flags to be set. */
+void *wanted_val;
+void *ioctl_val;
+/* For FLAG, the flag value to be set/cleared */
+u32 flag_val;
+/* For FLAG, points to u32 and accumulates all flags seen.
+	* For anything else, points to int and is set if the option is
+	* seen. */
+void *seen_val;
 };
 
 static struct cmdline_info cmdline_gregs[] = {
-	{ "raw", CMDL_BOOL, &gregs_dump_raw, NULL },
-	{ "hex", CMDL_BOOL, &gregs_dump_hex, NULL },
-	{ "file", CMDL_STR, &gregs_dump_file, NULL },
+{ "raw", CMDL_BOOL, &gregs_dump_raw, NULL },
+{ "hex", CMDL_BOOL, &gregs_dump_hex, NULL },
+{ "file", CMDL_STR, &gregs_dump_file, NULL },
 };
 
 static struct cmdline_info cmdline_geeprom[] = {
-	{ "offset", CMDL_S32, &geeprom_offset, NULL },
-	{ "length", CMDL_S32, &geeprom_length, NULL },
-	{ "raw", CMDL_BOOL, &geeprom_dump_raw, NULL },
+{ "offset", CMDL_S32, &geeprom_offset, NULL },
+{ "length", CMDL_S32, &geeprom_length, NULL },
+{ "raw", CMDL_BOOL, &geeprom_dump_raw, NULL },
 };
 
 static struct cmdline_info cmdline_seeprom[] = {
-	{ "magic", CMDL_S32, &seeprom_magic, NULL },
-	{ "offset", CMDL_S32, &seeprom_offset, NULL },
-	{ "length", CMDL_S32, &seeprom_length, NULL },
-	{ "value", CMDL_S32, &seeprom_value, NULL },
+{ "magic", CMDL_S32, &seeprom_magic, NULL },
+{ "offset", CMDL_S32, &seeprom_offset, NULL },
+{ "length", CMDL_S32, &seeprom_length, NULL },
+{ "value", CMDL_S32, &seeprom_value, NULL },
 };
 
 static struct cmdline_info cmdline_offload[] = {
-	{ "rx", CMDL_BOOL, &off_csum_rx_wanted, NULL },
-	{ "tx", CMDL_BOOL, &off_csum_tx_wanted, NULL },
-	{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },
-	{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
-	{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
-	{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
-	{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_LRO, &off_flags_mask },
-	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
-	{ "rxvlan", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_RXVLAN, &off_flags_mask },
-	{ "txvlan", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_TXVLAN, &off_flags_mask },
-	{ "ntuple", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_NTUPLE, &off_flags_mask },
-	{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_RXHASH, &off_flags_mask },
+{ "rx", CMDL_BOOL, &off_csum_rx_wanted, NULL },
+{ "tx", CMDL_BOOL, &off_csum_tx_wanted, NULL },
+{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },
+{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
+{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
+{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
+{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
+	ETH_FLAG_LRO, &off_flags_mask },
+{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
+{ "rxvlan", CMDL_FLAG, &off_flags_wanted, NULL,
+	ETH_FLAG_RXVLAN, &off_flags_mask },
+{ "txvlan", CMDL_FLAG, &off_flags_wanted, NULL,
+	ETH_FLAG_TXVLAN, &off_flags_mask },
+{ "ntuple", CMDL_FLAG, &off_flags_wanted, NULL,
+	ETH_FLAG_NTUPLE, &off_flags_mask },
+{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
+	ETH_FLAG_RXHASH, &off_flags_mask },
 };
 
 static struct cmdline_info cmdline_pause[] = {
-	{ "autoneg", CMDL_BOOL, &pause_autoneg_wanted, &epause.autoneg },
-	{ "rx", CMDL_BOOL, &pause_rx_wanted, &epause.rx_pause },
-	{ "tx", CMDL_BOOL, &pause_tx_wanted, &epause.tx_pause },
+{ "autoneg", CMDL_BOOL, &pause_autoneg_wanted, &epause.autoneg },
+{ "rx", CMDL_BOOL, &pause_rx_wanted, &epause.rx_pause },
+{ "tx", CMDL_BOOL, &pause_tx_wanted, &epause.tx_pause },
 };
 
 static struct cmdline_info cmdline_ring[] = {
-	{ "rx", CMDL_S32, &ring_rx_wanted, &ering.rx_pending },
-	{ "rx-mini", CMDL_S32, &ring_rx_mini_wanted, &ering.rx_mini_pending },
-	{ "rx-jumbo", CMDL_S32, &ring_rx_jumbo_wanted, &ering.rx_jumbo_pending },
-	{ "tx", CMDL_S32, &ring_tx_wanted, &ering.tx_pending },
+{ "rx", CMDL_S32, &ring_rx_wanted, &ering.rx_pending },
+{ "rx-mini", CMDL_S32, &ring_rx_mini_wanted, &ering.rx_mini_pending },
+{ "rx-jumbo", CMDL_S32, &ring_rx_jumbo_wanted, &ering.rx_jumbo_pending },
+{ "tx", CMDL_S32, &ring_tx_wanted, &ering.tx_pending },
 };
 
 static struct cmdline_info cmdline_coalesce[] = {
-	{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted, &ecoal.use_adaptive_rx_coalesce },
-	{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted, &ecoal.use_adaptive_tx_coalesce },
-	{ "sample-interval", CMDL_S32, &coal_sample_rate_wanted, &ecoal.rate_sample_interval },
-	{ "stats-block-usecs", CMDL_S32, &coal_stats_wanted, &ecoal.stats_block_coalesce_usecs },
-	{ "pkt-rate-low", CMDL_S32, &coal_pkt_rate_low_wanted, &ecoal.pkt_rate_low },
-	{ "pkt-rate-high", CMDL_S32, &coal_pkt_rate_high_wanted, &ecoal.pkt_rate_high },
-	{ "rx-usecs", CMDL_S32, &coal_rx_usec_wanted, &ecoal.rx_coalesce_usecs },
-	{ "rx-frames", CMDL_S32, &coal_rx_frames_wanted, &ecoal.rx_max_coalesced_frames },
-	{ "rx-usecs-irq", CMDL_S32, &coal_rx_usec_irq_wanted, &ecoal.rx_coalesce_usecs_irq },
-	{ "rx-frames-irq", CMDL_S32, &coal_rx_frames_irq_wanted, &ecoal.rx_max_coalesced_frames_irq },
-	{ "tx-usecs", CMDL_S32, &coal_tx_usec_wanted, &ecoal.tx_coalesce_usecs },
-	{ "tx-frames", CMDL_S32, &coal_tx_frames_wanted, &ecoal.tx_max_coalesced_frames },
-	{ "tx-usecs-irq", CMDL_S32, &coal_tx_usec_irq_wanted, &ecoal.tx_coalesce_usecs_irq },
-	{ "tx-frames-irq", CMDL_S32, &coal_tx_frames_irq_wanted, &ecoal.tx_max_coalesced_frames_irq },
-	{ "rx-usecs-low", CMDL_S32, &coal_rx_usec_low_wanted, &ecoal.rx_coalesce_usecs_low },
-	{ "rx-frames-low", CMDL_S32, &coal_rx_frames_low_wanted, &ecoal.rx_max_coalesced_frames_low },
-	{ "tx-usecs-low", CMDL_S32, &coal_tx_usec_low_wanted, &ecoal.tx_coalesce_usecs_low },
-	{ "tx-frames-low", CMDL_S32, &coal_tx_frames_low_wanted, &ecoal.tx_max_coalesced_frames_low },
-	{ "rx-usecs-high", CMDL_S32, &coal_rx_usec_high_wanted, &ecoal.rx_coalesce_usecs_high },
-	{ "rx-frames-high", CMDL_S32, &coal_rx_frames_high_wanted, &ecoal.rx_max_coalesced_frames_high },
-	{ "tx-usecs-high", CMDL_S32, &coal_tx_usec_high_wanted, &ecoal.tx_coalesce_usecs_high },
-	{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted, &ecoal.tx_max_coalesced_frames_high },
+{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted, &ecoal.use_adaptive_rx_coalesce },
+{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted, &ecoal.use_adaptive_tx_coalesce },
+{ "sample-interval", CMDL_S32, &coal_sample_rate_wanted, &ecoal.rate_sample_interval },
+{ "stats-block-usecs", CMDL_S32, &coal_stats_wanted, &ecoal.stats_block_coalesce_usecs },
+{ "pkt-rate-low", CMDL_S32, &coal_pkt_rate_low_wanted, &ecoal.pkt_rate_low },
+{ "pkt-rate-high", CMDL_S32, &coal_pkt_rate_high_wanted, &ecoal.pkt_rate_high },
+{ "rx-usecs", CMDL_S32, &coal_rx_usec_wanted, &ecoal.rx_coalesce_usecs },
+{ "rx-frames", CMDL_S32, &coal_rx_frames_wanted, &ecoal.rx_max_coalesced_frames },
+{ "rx-usecs-irq", CMDL_S32, &coal_rx_usec_irq_wanted, &ecoal.rx_coalesce_usecs_irq },
+{ "rx-frames-irq", CMDL_S32, &coal_rx_frames_irq_wanted, &ecoal.rx_max_coalesced_frames_irq },
+{ "tx-usecs", CMDL_S32, &coal_tx_usec_wanted, &ecoal.tx_coalesce_usecs },
+{ "tx-frames", CMDL_S32, &coal_tx_frames_wanted, &ecoal.tx_max_coalesced_frames },
+{ "tx-usecs-irq", CMDL_S32, &coal_tx_usec_irq_wanted, &ecoal.tx_coalesce_usecs_irq },
+{ "tx-frames-irq", CMDL_S32, &coal_tx_frames_irq_wanted, &ecoal.tx_max_coalesced_frames_irq },
+{ "rx-usecs-low", CMDL_S32, &coal_rx_usec_low_wanted, &ecoal.rx_coalesce_usecs_low },
+{ "rx-frames-low", CMDL_S32, &coal_rx_frames_low_wanted, &ecoal.rx_max_coalesced_frames_low },
+{ "tx-usecs-low", CMDL_S32, &coal_tx_usec_low_wanted, &ecoal.tx_coalesce_usecs_low },
+{ "tx-frames-low", CMDL_S32, &coal_tx_frames_low_wanted, &ecoal.tx_max_coalesced_frames_low },
+{ "rx-usecs-high", CMDL_S32, &coal_rx_usec_high_wanted, &ecoal.rx_coalesce_usecs_high },
+{ "rx-frames-high", CMDL_S32, &coal_rx_frames_high_wanted, &ecoal.rx_max_coalesced_frames_high },
+{ "tx-usecs-high", CMDL_S32, &coal_tx_usec_high_wanted, &ecoal.tx_coalesce_usecs_high },
+{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted, &ecoal.tx_max_coalesced_frames_high },
 };
 
 static struct cmdline_info cmdline_msglvl[] = {
-	{ "drv", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_DRV, &msglvl_mask },
-	{ "probe", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_PROBE, &msglvl_mask },
-	{ "link", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_LINK, &msglvl_mask },
-	{ "timer", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TIMER, &msglvl_mask },
-	{ "ifdown", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_IFDOWN, &msglvl_mask },
-	{ "ifup", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_IFUP, &msglvl_mask },
-	{ "rx_err", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_RX_ERR, &msglvl_mask },
-	{ "tx_err", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TX_ERR, &msglvl_mask },
-	{ "tx_queued", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TX_QUEUED, &msglvl_mask },
-	{ "intr", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_INTR, &msglvl_mask },
-	{ "tx_done", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_TX_DONE, &msglvl_mask },
-	{ "rx_status", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_RX_STATUS, &msglvl_mask },
-	{ "pktdata", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_PKTDATA, &msglvl_mask },
-	{ "hw", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_HW, &msglvl_mask },
-	{ "wol", CMDL_FLAG, &msglvl_wanted, NULL,
-	  NETIF_MSG_WOL, &msglvl_mask },
+{ "drv", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_DRV, &msglvl_mask },
+{ "probe", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_PROBE, &msglvl_mask },
+{ "link", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_LINK, &msglvl_mask },
+{ "timer", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_TIMER, &msglvl_mask },
+{ "ifdown", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_IFDOWN, &msglvl_mask },
+{ "ifup", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_IFUP, &msglvl_mask },
+{ "rx_err", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_RX_ERR, &msglvl_mask },
+{ "tx_err", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_TX_ERR, &msglvl_mask },
+{ "tx_queued", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_TX_QUEUED, &msglvl_mask },
+{ "intr", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_INTR, &msglvl_mask },
+{ "tx_done", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_TX_DONE, &msglvl_mask },
+{ "rx_status", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_RX_STATUS, &msglvl_mask },
+{ "pktdata", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_PKTDATA, &msglvl_mask },
+{ "hw", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_HW, &msglvl_mask },
+{ "wol", CMDL_FLAG, &msglvl_wanted, NULL,
+	NETIF_MSG_WOL, &msglvl_mask },
+};
+
+static struct cmdline_info cmdline_dmac[] = {
+{ "tune", CMDL_S32, &dmac_tune_wanted, &edmac.tune },
 };
 
 static long long
 get_int_range(char *str, int base, long long min, long long max)
 {
-	long long v;
-	char *endp;
+long long v;
+char *endp;
 
-	if (!str)
-		exit_bad_args();
-	errno = 0;
-	v = strtoll(str, &endp, base);
-	if (errno || *endp || v < min || v > max)
-		exit_bad_args();
-	return v;
+if (!str)
+	exit_bad_args();
+errno = 0;
+v = strtoll(str, &endp, base);
+if (errno || *endp || v < min || v > max)
+	exit_bad_args();
+return v;
 }
 
 static unsigned long long
 get_uint_range(char *str, int base, unsigned long long max)
 {
-	unsigned long long v;
-	char *endp;
+unsigned long long v;
+char *endp;
 
-	if (!str)
-		exit_bad_args();
-	errno = 0;
-	v = strtoull(str, &endp, base);
-	if ( errno || *endp || v > max)
-		exit_bad_args();
-	return v;
+if (!str)
+	exit_bad_args();
+errno = 0;
+v = strtoull(str, &endp, base);
+if ( errno || *endp || v > max)
+	exit_bad_args();
+return v;
 }
 
 static int get_int(char *str, int base)
 {
-	return get_int_range(str, base, INT_MIN, INT_MAX);
+return get_int_range(str, base, INT_MIN, INT_MAX);
 }
 
 static u32 get_u32(char *str, int base)
 {
-	return get_uint_range(str, base, 0xffffffff);
+return get_uint_range(str, base, 0xffffffff);
 }
 
 static void parse_generic_cmdline(int argc, char **argp,
-				  int first_arg, int *changed,
-				  struct cmdline_info *info,
-				  unsigned int n_info)
-{
-	int i, idx;
-	int found;
-
-	for (i = first_arg; i < argc; i++) {
-		found = 0;
-		for (idx = 0; idx < n_info; idx++) {
-			if (!strcmp(info[idx].name, argp[i])) {
-				found = 1;
-				*changed = 1;
-				if (info[idx].type != CMDL_FLAG &&
-				    info[idx].seen_val)
-					*(int *)info[idx].seen_val = 1;
-				i += 1;
-				if (i >= argc)
+				int first_arg, int *changed,
+				struct cmdline_info *info,
+				unsigned int n_info)
+{
+int i, idx;
+int found;
+
+for (i = first_arg; i < argc; i++) {
+	found = 0;
+	for (idx = 0; idx < n_info; idx++) {
+		if (!strcmp(info[idx].name, argp[i])) {
+			found = 1;
+			*changed = 1;
+			if (info[idx].type != CMDL_FLAG &&
+				info[idx].seen_val)
+				*(int *)info[idx].seen_val = 1;
+			i += 1;
+			if (i >= argc)
+				exit_bad_args();
+			switch (info[idx].type) {
+			case CMDL_BOOL: {
+				int *p = info[idx].wanted_val;
+				if (!strcmp(argp[i], "on"))
+					*p = 1;
+				else if (!strcmp(argp[i], "off"))
+					*p = 0;
+				else
 					exit_bad_args();
-				switch (info[idx].type) {
-				case CMDL_BOOL: {
-					int *p = info[idx].wanted_val;
-					if (!strcmp(argp[i], "on"))
-						*p = 1;
-					else if (!strcmp(argp[i], "off"))
-						*p = 0;
-					else
-						exit_bad_args();
-					break;
-				}
-				case CMDL_S32: {
-					s32 *p = info[idx].wanted_val;
-					*p = get_int_range(argp[i], 0,
-							   -0x80000000LL,
-							   0x7fffffff);
-					break;
-				}
-				case CMDL_U16: {
-					u16 *p = info[idx].wanted_val;
-					*p = get_uint_range(argp[i], 0, 0xffff);
-					break;
-				}
-				case CMDL_U32: {
-					u32 *p = info[idx].wanted_val;
-					*p = get_uint_range(argp[i], 0,
-							    0xffffffff);
-					break;
-				}
-				case CMDL_U64: {
-					u64 *p = info[idx].wanted_val;
-					*p = get_uint_range(
-						argp[i], 0,
-						0xffffffffffffffffLL);
-					break;
-				}
-				case CMDL_BE16: {
-					u16 *p = info[idx].wanted_val;
-					*p = cpu_to_be16(
-						get_uint_range(argp[i], 0,
-							       0xffff));
-					break;
-				}
-				case CMDL_IP4: {
-					u32 *p = info[idx].wanted_val;
-					struct in_addr in;
-					if (!inet_aton(argp[i], &in))
-						exit_bad_args();
-					*p = in.s_addr;
-					break;
-				}
-				case CMDL_MAC:
-					get_mac_addr(argp[i],
-						     info[idx].wanted_val);
-					break;
-				case CMDL_FLAG: {
-					u32 *p;
-					p = info[idx].seen_val;
+				break;
+			}
+			case CMDL_S32: {
+				s32 *p = info[idx].wanted_val;
+				*p = get_int_range(argp[i], 0,
+							-0x80000000LL,
+							0x7fffffff);
+				break;
+			}
+			case CMDL_U16: {
+				u16 *p = info[idx].wanted_val;
+				*p = get_uint_range(argp[i], 0, 0xffff);
+				break;
+			}
+			case CMDL_U32: {
+				u32 *p = info[idx].wanted_val;
+				*p = get_uint_range(argp[i], 0,
+							0xffffffff);
+				break;
+			}
+			case CMDL_U64: {
+				u64 *p = info[idx].wanted_val;
+				*p = get_uint_range(
+					argp[i], 0,
+					0xffffffffffffffffLL);
+				break;
+			}
+			case CMDL_BE16: {
+				u16 *p = info[idx].wanted_val;
+				*p = cpu_to_be16(
+					get_uint_range(argp[i], 0,
+							0xffff));
+				break;
+			}
+			case CMDL_IP4: {
+				u32 *p = info[idx].wanted_val;
+				struct in_addr in;
+				if (!inet_aton(argp[i], &in))
+					exit_bad_args();
+				*p = in.s_addr;
+				break;
+			}
+			case CMDL_MAC:
+				get_mac_addr(argp[i],
+						info[idx].wanted_val);
+				break;
+			case CMDL_FLAG: {
+				u32 *p;
+				p = info[idx].seen_val;
+				*p |= info[idx].flag_val;
+				if (!strcmp(argp[i], "on")) {
+					p = info[idx].wanted_val;
 					*p |= info[idx].flag_val;
-					if (!strcmp(argp[i], "on")) {
-						p = info[idx].wanted_val;
-						*p |= info[idx].flag_val;
-					} else if (strcmp(argp[i], "off")) {
-						exit_bad_args();
-					}
-					break;
-				}
-				case CMDL_STR: {
-					char **s = info[idx].wanted_val;
-					*s = strdup(argp[i]);
-					break;
-				}
-				default:
+				} else if (strcmp(argp[i], "off")) {
 					exit_bad_args();
 				}
 				break;
 			}
+			case CMDL_STR: {
+				char **s = info[idx].wanted_val;
+				*s = strdup(argp[i]);
+				break;
+			}
+			default:
+				exit_bad_args();
+			}
+			break;
 		}
-		if( !found)
-			exit_bad_args();
 	}
+	if( !found)
+		exit_bad_args();
+}
 }
 
 static void
 print_flags(const struct cmdline_info *info, unsigned int n_info, u32 value)
 {
-	const char *sep = "";
+const char *sep = "";
 
-	while (n_info) {
-		if (info->type == CMDL_FLAG && value & info->flag_val) {
-			printf("%s%s", sep, info->name);
-			sep = " ";
-			value &= ~info->flag_val;
-		}
-		++info;
-		--n_info;
+while (n_info) {
+	if (info->type == CMDL_FLAG && value & info->flag_val) {
+		printf("%s%s", sep, info->name);
+		sep = " ";
+		value &= ~info->flag_val;
 	}
+	++info;
+	--n_info;
+}
 
-	/* Print any unrecognised flags in hex */
-	if (value)
-		printf("%s%#x", sep, value);
+/* Print any unrecognised flags in hex */
+if (value)
+	printf("%s%#x", sep, value);
 }
 
 static int rxflow_str_to_type(const char *str)
 {
-	int flow_type = 0;
-
-	if (!strcmp(str, "tcp4"))
-		flow_type = TCP_V4_FLOW;
-	else if (!strcmp(str, "udp4"))
-		flow_type = UDP_V4_FLOW;
-	else if (!strcmp(str, "ah4") || !strcmp(str, "esp4"))
-		flow_type = AH_ESP_V4_FLOW;
-	else if (!strcmp(str, "sctp4"))
-		flow_type = SCTP_V4_FLOW;
-	else if (!strcmp(str, "tcp6"))
-		flow_type = TCP_V6_FLOW;
-	else if (!strcmp(str, "udp6"))
-		flow_type = UDP_V6_FLOW;
-	else if (!strcmp(str, "ah6") || !strcmp(str, "esp6"))
-		flow_type = AH_ESP_V6_FLOW;
-	else if (!strcmp(str, "sctp6"))
-		flow_type = SCTP_V6_FLOW;
-	else if (!strcmp(str, "ether"))
-		flow_type = ETHER_FLOW;
-
-	return flow_type;
+int flow_type = 0;
+
+if (!strcmp(str, "tcp4"))
+	flow_type = TCP_V4_FLOW;
+else if (!strcmp(str, "udp4"))
+	flow_type = UDP_V4_FLOW;
+else if (!strcmp(str, "ah4") || !strcmp(str, "esp4"))
+	flow_type = AH_ESP_V4_FLOW;
+else if (!strcmp(str, "sctp4"))
+	flow_type = SCTP_V4_FLOW;
+else if (!strcmp(str, "tcp6"))
+	flow_type = TCP_V6_FLOW;
+else if (!strcmp(str, "udp6"))
+	flow_type = UDP_V6_FLOW;
+else if (!strcmp(str, "ah6") || !strcmp(str, "esp6"))
+	flow_type = AH_ESP_V6_FLOW;
+else if (!strcmp(str, "sctp6"))
+	flow_type = SCTP_V6_FLOW;
+else if (!strcmp(str, "ether"))
+	flow_type = ETHER_FLOW;
+
+return flow_type;
 }
 
 static void parse_cmdline(int argc, char **argp)
@@ -743,56 +757,58 @@ static void parse_cmdline(int argc, char **argp)
 	int i, k;
 
 	for (i = 1; i < argc; i++) {
-		switch (i) {
-		case 1:
-			for (k = 0; args[k].lng; k++)
-				if ((args[k].srt &&
-				     !strcmp(argp[i], args[k].srt)) ||
-				    !strcmp(argp[i], args[k].lng)) {
-					mode = args[k].Mode;
-					break;
-				}
-			if (mode == MODE_HELP) {
-				show_usage();
-				exit(0);
-			} else if (mode == MODE_VERSION) {
-				fprintf(stdout,
-					PACKAGE " version " VERSION "\n");
-				exit(0);
-			} else if (!args[k].lng && argp[i][0] == '-') {
-				exit_bad_args();
-			} else {
-				devname = argp[i];
+	switch (i) {
+	case 1:
+		for (k = 0; args[k].lng; k++)
+			if ((args[k].srt &&
+				!strcmp(argp[i], args[k].srt)) ||
+				!strcmp(argp[i], args[k].lng)) {
+				mode = args[k].Mode;
+				break;
 			}
+		if (mode == MODE_HELP) {
+			show_usage();
+			exit(0);
+		} else if (mode == MODE_VERSION) {
+			fprintf(stdout,
+				PACKAGE " version " VERSION "\n");
+			exit(0);
+		} else if (!args[k].lng && argp[i][0] == '-') {
+			exit_bad_args();
+		} else {
+			devname = argp[i];
 			break;
-		case 2:
-			if ((mode == MODE_SSET) ||
-			    (mode == MODE_GDRV) ||
-			    (mode == MODE_GREGS)||
-			    (mode == MODE_NWAY_RST) ||
-			    (mode == MODE_TEST) ||
-			    (mode == MODE_GEEPROM) ||
-			    (mode == MODE_SEEPROM) ||
-			    (mode == MODE_GPAUSE) ||
-			    (mode == MODE_SPAUSE) ||
-			    (mode == MODE_GCOALESCE) ||
-			    (mode == MODE_SCOALESCE) ||
-			    (mode == MODE_GRING) ||
-			    (mode == MODE_SRING) ||
-			    (mode == MODE_GOFFLOAD) ||
-			    (mode == MODE_SOFFLOAD) ||
-			    (mode == MODE_GSTATS) ||
-			    (mode == MODE_GNFC) ||
-			    (mode == MODE_SNFC) ||
-			    (mode == MODE_GRXFHINDIR) ||
-			    (mode == MODE_SRXFHINDIR) ||
-			    (mode == MODE_SCLSRULE) ||
-			    (mode == MODE_GCLSRULE) ||
-			    (mode == MODE_PHYS_ID) ||
-			    (mode == MODE_FLASHDEV) ||
-			    (mode == MODE_PERMADDR) ||
-			    (mode == MODE_SET_DUMP) ||
-			    (mode == MODE_GET_DUMP)) {
+		}
+	case 2:
+		if ((mode == MODE_SSET) ||
+			(mode == MODE_GDRV) ||
+			(mode == MODE_GREGS)||
+			(mode == MODE_NWAY_RST) ||
+			(mode == MODE_TEST) ||
+			(mode == MODE_GEEPROM) ||
+			(mode == MODE_SEEPROM) ||
+			(mode == MODE_GPAUSE) ||
+			(mode == MODE_SPAUSE) ||
+			(mode == MODE_GCOALESCE) ||
+			(mode == MODE_SCOALESCE) ||
+			(mode == MODE_GRING) ||
+			(mode == MODE_SRING) ||
+			(mode == MODE_GOFFLOAD) ||
+			(mode == MODE_SOFFLOAD) ||
+			(mode == MODE_GSTATS) ||
+			(mode == MODE_GNFC) ||
+			(mode == MODE_SNFC) ||
+			(mode == MODE_GRXFHINDIR) ||
+			(mode == MODE_SRXFHINDIR) ||
+			(mode == MODE_SCLSRULE) ||
+			(mode == MODE_GCLSRULE) ||
+			(mode == MODE_PHYS_ID) ||
+			(mode == MODE_FLASHDEV) ||
+			(mode == MODE_GDMAC) ||
+			(mode == MODE_SDMAC) ||
+			(mode == MODE_PERMADDR) ||
+			(mode == MODE_SET_DUMP) ||
+			(mode == MODE_GET_DUMP)) {
 				devname = argp[i];
 				break;
 			}
@@ -1007,6 +1023,16 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_SDMAC) {
+				if (!strcmp(argp[i], "dmac")) {
+					sdmac_changed = 1;
+					i++;
+					if (i >= argc)
+						exit_bad_args();
+					dmac_tune_wanted = get_int(argp[i],10);
+				}
+				break;
+			}
 			if (mode != MODE_SSET)
 				exit_bad_args();
 			if (!strcmp(argp[i], "speed")) {
@@ -1123,7 +1149,6 @@ static void parse_cmdline(int argc, char **argp)
 				}
 				break;
 			}
-			exit_bad_args();
 		}
 	}
 
@@ -1935,6 +1960,10 @@ static int doit(void)
 		return do_getfwdump(fd, &ifr);
 	} else if (mode == MODE_SET_DUMP) {
 		return do_setfwdump(fd, &ifr);
+	} else if (mode == MODE_GDMAC) {
+		return do_gdmac(fd, &ifr);
+	} else if (mode == MODE_SDMAC) {
+		return do_sdmac(fd, &ifr);
 	}
 
 	return 69;
@@ -3327,6 +3356,56 @@ static int send_ioctl(int fd, struct ifreq *ifr)
 	return ioctl(fd, SIOCETHTOOL, ifr);
 }
 
+static int do_gdmac(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_dmac edmac;
+	printf("ethtool:do_gdmac..\n");
+
+	fprintf(stdout, "DMA Coalesce parameters for %s:\n", devname);
+
+	edmac.cmd = ETHTOOL_GDMAC;
+	ifr->ifr_data = (caddr_t)&edmac;
+	err = send_ioctl(fd, ifr);
+	if (err == 0) {
+		fprintf(stdout, "DMAC:%d\n", edmac.tune);
+	} else {
+		perror("Cannot get device DMA Coalesce settings");
+		return err;
+	}
+
+	return 0;
+}
+
+static int do_sdmac(int fd, struct ifreq *ifr)
+{
+	int err, changed = 0;
+	struct ethtool_dmac edmac;
+
+	edmac.cmd = ETHTOOL_GDMAC;
+	ifr->ifr_data = (caddr_t)&edmac;
+	err = send_ioctl(fd, ifr);
+	if (err)
+		return err;
+	else
+		if (edmac.tune != dmac_tune_wanted)
+			changed = 1;
+
+	if (!changed) {
+		fprintf(stderr, "no DMAC parameters changed, aborting\n");
+		return 80;
+	} else
+		edmac.tune = dmac_tune_wanted;
+
+	edmac.cmd = ETHTOOL_SDMAC;
+	ifr->ifr_data = (caddr_t)&edmac;
+	err = send_ioctl(fd, ifr);
+	if (err) {
+		perror("Cannot set device DMA coalesce parameters");
+		return err;
+	}
+	return 0;
+}
 int main(int argc, char **argp, char **envp)
 {
 	parse_cmdline(argc, argp);
-- 
1.7.4.4

