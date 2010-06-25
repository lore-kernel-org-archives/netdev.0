From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/5] ethtool: Parse integers into variables of
 different sizes and byte orders
Date: Fri, 25 Jun 2010 15:46:58 +0100
Message-ID: <1277477218.2094.5.camel@achroite.uk.solarflarecom.com>
References: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11644 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227Ab0FYOrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 10:47:02 -0400
In-Reply-To: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The arguments for RX n-tuple traffic direction are filled into
structure fields of varying size, some of which are in big-endian
rather than native byte order.  Currently parse_generic_cmdline()
only supports 32-bit integers in native byte order, so this does
not work correctly.

Replace CMDL_INT and CMDL_UINT with the more explicit CMDL_S32 and
CMDL_U32.  Add CMDL_U16 and CMDL_U64 for narrower and wider integers,
and CMDL_BE16 and CMDL_BE32 for big-endian unsigned integers.  Use
them for RX n-tuple argument parsing.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I've removed the 'historical' comment from the kernel-style named types
because I see no sign of a transition away from them.

Ben.

 ethtool-util.h |   29 ++++++-
 ethtool.c      |  226 +++++++++++++++++++++++++++++++++-----------------------
 2 files changed, 160 insertions(+), 95 deletions(-)

diff --git a/ethtool-util.h b/ethtool-util.h
index e9a998a..01b1d03 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -4,14 +4,35 @@
 #define ETHTOOL_UTIL_H__
 
 #include <sys/types.h>
+#include <endian.h>
 
 #include "ethtool-copy.h"
 
-/* historical: we used to use kernel-like types; remove these once cleaned */
 typedef unsigned long long u64;
-typedef __uint32_t u32;         /* ditto */
-typedef __uint16_t u16;         /* ditto */
-typedef __uint8_t u8;           /* ditto */
+typedef __uint32_t u32;
+typedef __uint16_t u16;
+typedef __uint8_t u8;
+typedef __int32_t s32;
+
+#if __BYTE_ORDER == __BIG_ENDIAN
+static inline u16 cpu_to_be16(u16 value)
+{
+    return value;
+}
+static inline u32 cpu_to_be32(u32 value)
+{
+    return value;
+}
+#else
+static inline u16 cpu_to_be16(u16 value)
+{
+	return (value >> 8) | (value << 8);
+}
+static inline u32 cpu_to_be32(u32 value)
+{
+	return cpu_to_be16(value >> 16) | (cpu_to_be16(value) << 16);
+}
+#endif
 
 /* National Semiconductor DP83815, DP83816 */
 int natsemi_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
diff --git a/ethtool.c b/ethtool.c
index 5d61439..8969390 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -268,35 +268,35 @@ static int pause_tx_wanted = -1;
 
 static struct ethtool_ringparam ering;
 static int gring_changed = 0;
-static int ring_rx_wanted = -1;
-static int ring_rx_mini_wanted = -1;
-static int ring_rx_jumbo_wanted = -1;
-static int ring_tx_wanted = -1;
+static s32 ring_rx_wanted = -1;
+static s32 ring_rx_mini_wanted = -1;
+static s32 ring_rx_jumbo_wanted = -1;
+static s32 ring_tx_wanted = -1;
 
 static struct ethtool_coalesce ecoal;
 static int gcoalesce_changed = 0;
-static int coal_stats_wanted = -1;
+static s32 coal_stats_wanted = -1;
 static int coal_adaptive_rx_wanted = -1;
 static int coal_adaptive_tx_wanted = -1;
-static int coal_sample_rate_wanted = -1;
-static int coal_pkt_rate_low_wanted = -1;
-static int coal_pkt_rate_high_wanted = -1;
-static int coal_rx_usec_wanted = -1;
-static int coal_rx_frames_wanted = -1;
-static int coal_rx_usec_irq_wanted = -1;
-static int coal_rx_frames_irq_wanted = -1;
-static int coal_tx_usec_wanted = -1;
-static int coal_tx_frames_wanted = -1;
-static int coal_tx_usec_irq_wanted = -1;
-static int coal_tx_frames_irq_wanted = -1;
-static int coal_rx_usec_low_wanted = -1;
-static int coal_rx_frames_low_wanted = -1;
-static int coal_tx_usec_low_wanted = -1;
-static int coal_tx_frames_low_wanted = -1;
-static int coal_rx_usec_high_wanted = -1;
-static int coal_rx_frames_high_wanted = -1;
-static int coal_tx_usec_high_wanted = -1;
-static int coal_tx_frames_high_wanted = -1;
+static s32 coal_sample_rate_wanted = -1;
+static s32 coal_pkt_rate_low_wanted = -1;
+static s32 coal_pkt_rate_high_wanted = -1;
+static s32 coal_rx_usec_wanted = -1;
+static s32 coal_rx_frames_wanted = -1;
+static s32 coal_rx_usec_irq_wanted = -1;
+static s32 coal_rx_frames_irq_wanted = -1;
+static s32 coal_tx_usec_wanted = -1;
+static s32 coal_tx_frames_wanted = -1;
+static s32 coal_tx_usec_irq_wanted = -1;
+static s32 coal_tx_frames_irq_wanted = -1;
+static s32 coal_rx_usec_low_wanted = -1;
+static s32 coal_rx_frames_low_wanted = -1;
+static s32 coal_tx_usec_low_wanted = -1;
+static s32 coal_tx_frames_low_wanted = -1;
+static s32 coal_rx_usec_high_wanted = -1;
+static s32 coal_rx_frames_high_wanted = -1;
+static s32 coal_tx_usec_high_wanted = -1;
+static s32 coal_tx_frames_high_wanted = -1;
 
 static int speed_wanted = -1;
 static int duplex_wanted = -1;
@@ -319,13 +319,13 @@ static int gregs_dump_hex = 0;
 static char *gregs_dump_file = NULL;
 static int geeprom_changed = 0;
 static int geeprom_dump_raw = 0;
-static int geeprom_offset = 0;
-static int geeprom_length = -1;
+static s32 geeprom_offset = 0;
+static s32 geeprom_length = -1;
 static int seeprom_changed = 0;
-static int seeprom_magic = 0;
-static int seeprom_length = -1;
-static int seeprom_offset = 0;
-static int seeprom_value = EOF;
+static s32 seeprom_magic = 0;
+static s32 seeprom_length = -1;
+static s32 seeprom_offset = 0;
+static s32 seeprom_value = EOF;
 static int rx_fhash_get = 0;
 static int rx_fhash_set = 0;
 static u32 rx_fhash_val = 0;
@@ -343,14 +343,19 @@ static enum {
 typedef enum {
 	CMDL_NONE,
 	CMDL_BOOL,
-	CMDL_INT,
-	CMDL_UINT,
+	CMDL_S32,
+	CMDL_U16,
+	CMDL_U32,
+	CMDL_U64,
+	CMDL_BE16,
+	CMDL_BE32,
 	CMDL_STR,
 } cmdline_type_t;
 
 struct cmdline_info {
 	const char *name;
 	cmdline_type_t type;
+	/* Points to int (BOOL), s32, u16, u32, u64 or char * (STR) */
 	void *wanted_val;
 	void *ioctl_val;
 };
@@ -362,16 +367,16 @@ static struct cmdline_info cmdline_gregs[] = {
 };
 
 static struct cmdline_info cmdline_geeprom[] = {
-	{ "offset", CMDL_INT, &geeprom_offset, NULL },
-	{ "length", CMDL_INT, &geeprom_length, NULL },
+	{ "offset", CMDL_S32, &geeprom_offset, NULL },
+	{ "length", CMDL_S32, &geeprom_length, NULL },
 	{ "raw", CMDL_BOOL, &geeprom_dump_raw, NULL },
 };
 
 static struct cmdline_info cmdline_seeprom[] = {
-	{ "magic", CMDL_INT, &seeprom_magic, NULL },
-	{ "offset", CMDL_INT, &seeprom_offset, NULL },
-	{ "length", CMDL_INT, &seeprom_length, NULL },
-	{ "value", CMDL_INT, &seeprom_value, NULL },
+	{ "magic", CMDL_S32, &seeprom_magic, NULL },
+	{ "offset", CMDL_S32, &seeprom_offset, NULL },
+	{ "length", CMDL_S32, &seeprom_length, NULL },
+	{ "value", CMDL_S32, &seeprom_value, NULL },
 };
 
 static struct cmdline_info cmdline_offload[] = {
@@ -394,87 +399,94 @@ static struct cmdline_info cmdline_pause[] = {
 };
 
 static struct cmdline_info cmdline_ring[] = {
-	{ "rx", CMDL_INT, &ring_rx_wanted, &ering.rx_pending },
-	{ "rx-mini", CMDL_INT, &ring_rx_mini_wanted, &ering.rx_mini_pending },
-	{ "rx-jumbo", CMDL_INT, &ring_rx_jumbo_wanted, &ering.rx_jumbo_pending },
-	{ "tx", CMDL_INT, &ring_tx_wanted, &ering.tx_pending },
+	{ "rx", CMDL_S32, &ring_rx_wanted, &ering.rx_pending },
+	{ "rx-mini", CMDL_S32, &ring_rx_mini_wanted, &ering.rx_mini_pending },
+	{ "rx-jumbo", CMDL_S32, &ring_rx_jumbo_wanted, &ering.rx_jumbo_pending },
+	{ "tx", CMDL_S32, &ring_tx_wanted, &ering.tx_pending },
 };
 
 static struct cmdline_info cmdline_coalesce[] = {
 	{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted, &ecoal.use_adaptive_rx_coalesce },
 	{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted, &ecoal.use_adaptive_tx_coalesce },
-	{ "sample-interval", CMDL_INT, &coal_sample_rate_wanted, &ecoal.rate_sample_interval },
-	{ "stats-block-usecs", CMDL_INT, &coal_stats_wanted, &ecoal.stats_block_coalesce_usecs },
-	{ "pkt-rate-low", CMDL_INT, &coal_pkt_rate_low_wanted, &ecoal.pkt_rate_low },
-	{ "pkt-rate-high", CMDL_INT, &coal_pkt_rate_high_wanted, &ecoal.pkt_rate_high },
-	{ "rx-usecs", CMDL_INT, &coal_rx_usec_wanted, &ecoal.rx_coalesce_usecs },
-	{ "rx-frames", CMDL_INT, &coal_rx_frames_wanted, &ecoal.rx_max_coalesced_frames },
-	{ "rx-usecs-irq", CMDL_INT, &coal_rx_usec_irq_wanted, &ecoal.rx_coalesce_usecs_irq },
-	{ "rx-frames-irq", CMDL_INT, &coal_rx_frames_irq_wanted, &ecoal.rx_max_coalesced_frames_irq },
-	{ "tx-usecs", CMDL_INT, &coal_tx_usec_wanted, &ecoal.tx_coalesce_usecs },
-	{ "tx-frames", CMDL_INT, &coal_tx_frames_wanted, &ecoal.tx_max_coalesced_frames },
-	{ "tx-usecs-irq", CMDL_INT, &coal_tx_usec_irq_wanted, &ecoal.tx_coalesce_usecs_irq },
-	{ "tx-frames-irq", CMDL_INT, &coal_tx_frames_irq_wanted, &ecoal.tx_max_coalesced_frames_irq },
-	{ "rx-usecs-low", CMDL_INT, &coal_rx_usec_low_wanted, &ecoal.rx_coalesce_usecs_low },
-	{ "rx-frames-low", CMDL_INT, &coal_rx_frames_low_wanted, &ecoal.rx_max_coalesced_frames_low },
-	{ "tx-usecs-low", CMDL_INT, &coal_tx_usec_low_wanted, &ecoal.tx_coalesce_usecs_low },
-	{ "tx-frames-low", CMDL_INT, &coal_tx_frames_low_wanted, &ecoal.tx_max_coalesced_frames_low },
-	{ "rx-usecs-high", CMDL_INT, &coal_rx_usec_high_wanted, &ecoal.rx_coalesce_usecs_high },
-	{ "rx-frames-high", CMDL_INT, &coal_rx_frames_high_wanted, &ecoal.rx_max_coalesced_frames_high },
-	{ "tx-usecs-high", CMDL_INT, &coal_tx_usec_high_wanted, &ecoal.tx_coalesce_usecs_high },
-	{ "tx-frames-high", CMDL_INT, &coal_tx_frames_high_wanted, &ecoal.tx_max_coalesced_frames_high },
+	{ "sample-interval", CMDL_S32, &coal_sample_rate_wanted, &ecoal.rate_sample_interval },
+	{ "stats-block-usecs", CMDL_S32, &coal_stats_wanted, &ecoal.stats_block_coalesce_usecs },
+	{ "pkt-rate-low", CMDL_S32, &coal_pkt_rate_low_wanted, &ecoal.pkt_rate_low },
+	{ "pkt-rate-high", CMDL_S32, &coal_pkt_rate_high_wanted, &ecoal.pkt_rate_high },
+	{ "rx-usecs", CMDL_S32, &coal_rx_usec_wanted, &ecoal.rx_coalesce_usecs },
+	{ "rx-frames", CMDL_S32, &coal_rx_frames_wanted, &ecoal.rx_max_coalesced_frames },
+	{ "rx-usecs-irq", CMDL_S32, &coal_rx_usec_irq_wanted, &ecoal.rx_coalesce_usecs_irq },
+	{ "rx-frames-irq", CMDL_S32, &coal_rx_frames_irq_wanted, &ecoal.rx_max_coalesced_frames_irq },
+	{ "tx-usecs", CMDL_S32, &coal_tx_usec_wanted, &ecoal.tx_coalesce_usecs },
+	{ "tx-frames", CMDL_S32, &coal_tx_frames_wanted, &ecoal.tx_max_coalesced_frames },
+	{ "tx-usecs-irq", CMDL_S32, &coal_tx_usec_irq_wanted, &ecoal.tx_coalesce_usecs_irq },
+	{ "tx-frames-irq", CMDL_S32, &coal_tx_frames_irq_wanted, &ecoal.tx_max_coalesced_frames_irq },
+	{ "rx-usecs-low", CMDL_S32, &coal_rx_usec_low_wanted, &ecoal.rx_coalesce_usecs_low },
+	{ "rx-frames-low", CMDL_S32, &coal_rx_frames_low_wanted, &ecoal.rx_max_coalesced_frames_low },
+	{ "tx-usecs-low", CMDL_S32, &coal_tx_usec_low_wanted, &ecoal.tx_coalesce_usecs_low },
+	{ "tx-frames-low", CMDL_S32, &coal_tx_frames_low_wanted, &ecoal.tx_max_coalesced_frames_low },
+	{ "rx-usecs-high", CMDL_S32, &coal_rx_usec_high_wanted, &ecoal.rx_coalesce_usecs_high },
+	{ "rx-frames-high", CMDL_S32, &coal_rx_frames_high_wanted, &ecoal.rx_max_coalesced_frames_high },
+	{ "tx-usecs-high", CMDL_S32, &coal_tx_usec_high_wanted, &ecoal.tx_coalesce_usecs_high },
+	{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted, &ecoal.tx_max_coalesced_frames_high },
 };
 
 static struct cmdline_info cmdline_ntuple[] = {
-	{ "src-ip", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL },
-	{ "src-ip-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL },
-	{ "dst-ip", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL },
-	{ "dst-ip-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL },
-	{ "src-port", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.psrc, NULL },
-	{ "src-port-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.psrc, NULL },
-	{ "dst-port", CMDL_INT, &ntuple_fs.h_u.tcp_ip4_spec.pdst, NULL },
-	{ "dst-port-mask", CMDL_UINT, &ntuple_fs.m_u.tcp_ip4_spec.pdst, NULL },
-	{ "vlan", CMDL_INT, &ntuple_fs.vlan_tag, NULL },
-	{ "vlan-mask", CMDL_UINT, &ntuple_fs.vlan_tag_mask, NULL },
-	{ "user-def", CMDL_INT, &ntuple_fs.data, NULL },
-	{ "user-def-mask", CMDL_UINT, &ntuple_fs.data_mask, NULL },
-	{ "action", CMDL_INT, &ntuple_fs.action, NULL },
+	{ "src-ip", CMDL_BE32, &ntuple_fs.h_u.tcp_ip4_spec.ip4src, NULL },
+	{ "src-ip-mask", CMDL_BE32, &ntuple_fs.m_u.tcp_ip4_spec.ip4src, NULL },
+	{ "dst-ip", CMDL_BE32, &ntuple_fs.h_u.tcp_ip4_spec.ip4dst, NULL },
+	{ "dst-ip-mask", CMDL_BE32, &ntuple_fs.m_u.tcp_ip4_spec.ip4dst, NULL },
+	{ "src-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.psrc, NULL },
+	{ "src-port-mask", CMDL_BE16, &ntuple_fs.m_u.tcp_ip4_spec.psrc, NULL },
+	{ "dst-port", CMDL_BE16, &ntuple_fs.h_u.tcp_ip4_spec.pdst, NULL },
+	{ "dst-port-mask", CMDL_BE16, &ntuple_fs.m_u.tcp_ip4_spec.pdst, NULL },
+	{ "vlan", CMDL_U16, &ntuple_fs.vlan_tag, NULL },
+	{ "vlan-mask", CMDL_U16, &ntuple_fs.vlan_tag_mask, NULL },
+	{ "user-def", CMDL_U64, &ntuple_fs.data, NULL },
+	{ "user-def-mask", CMDL_U64, &ntuple_fs.data_mask, NULL },
+	{ "action", CMDL_S32, &ntuple_fs.action, NULL },
 };
 
-static int get_int(char *str, int base)
+static long long
+get_int_range(char *str, int base, long long min, long long max)
 {
-	long v;
+	long long v;
 	char *endp;
 
 	if (!str)
 		show_usage(1);
 	errno = 0;
-	v = strtol(str, &endp, base);
-	if ( errno || *endp || v > INT_MAX)
+	v = strtoll(str, &endp, base);
+	if (errno || *endp || v < min || v > max)
 		show_usage(1);
-	return (int)v;
+	return v;
 }
 
-static int get_uint(char *str, int base)
+static unsigned long long
+get_uint_range(char *str, int base, unsigned long long max)
 {
-	unsigned long v;
+	unsigned long long v;
 	char *endp;
 
 	if (!str)
 		show_usage(1);
 	errno = 0;
-	v = strtoul(str, &endp, base);
-	if ( errno || *endp || v > UINT_MAX)
+	v = strtoull(str, &endp, base);
+	if ( errno || *endp || v > max)
 		show_usage(1);
 	return v;
 }
 
+static int get_int(char *str, int base)
+{
+	return get_int_range(str, base, INT_MIN, INT_MAX);
+}
+
 static void parse_generic_cmdline(int argc, char **argp,
 				  int first_arg, int *changed,
 				  struct cmdline_info *info,
 				  unsigned int n_info)
 {
-	int i, idx, *p;
+	int i, idx;
 	int found;
 
 	for (i = first_arg; i < argc; i++) {
@@ -486,9 +498,9 @@ static void parse_generic_cmdline(int argc, char **argp,
 				i += 1;
 				if (i >= argc)
 					show_usage(1);
-				p = info[idx].wanted_val;
 				switch (info[idx].type) {
-				case CMDL_BOOL:
+				case CMDL_BOOL: {
+					int *p = info[idx].wanted_val;
 					if (!strcmp(argp[i], "on"))
 						*p = 1;
 					else if (!strcmp(argp[i], "off"))
@@ -496,12 +508,44 @@ static void parse_generic_cmdline(int argc, char **argp,
 					else
 						show_usage(1);
 					break;
-				case CMDL_INT: {
-					*p = get_int(argp[i],0);
+				}
+				case CMDL_S32: {
+					s32 *p = info[idx].wanted_val;
+					*p = get_int_range(argp[i], 0,
+							   -0x80000000LL,
+							   0x7fffffff);
+					break;
+				}
+				case CMDL_U16: {
+					u16 *p = info[idx].wanted_val;
+					*p = get_uint_range(argp[i], 0, 0xffff);
+					break;
+				}
+				case CMDL_U32: {
+					u32 *p = info[idx].wanted_val;
+					*p = get_uint_range(argp[i], 0,
+							    0xffffffff);
+					break;
+				}
+				case CMDL_U64: {
+					u64 *p = info[idx].wanted_val;
+					*p = get_uint_range(
+						argp[i], 0,
+						0xffffffffffffffffLL);
+					break;
+				}
+				case CMDL_BE16: {
+					u16 *p = info[idx].wanted_val;
+					*p = cpu_to_be16(
+						get_uint_range(argp[i], 0,
+							       0xffff));
 					break;
 				}
-				case CMDL_UINT: {
-					*p = get_uint(argp[i],0);
+				case CMDL_BE32: {
+					u32 *p = info[idx].wanted_val;
+					*p = cpu_to_be32(
+						get_uint_range(argp[i], 0,
+							       0xffffffff));
 					break;
 				}
 				case CMDL_STR: {
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

