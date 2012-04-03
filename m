From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH] Add the command to show the time stamping
	capabilities.
Date: Tue,  3 Apr 2012 19:58:23 +0200
Message-ID: <1333475903-8185-1-git-send-email-richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 ethtool-copy.h    |   24 +++++++++++
 ethtool.8.in      |    7 +++
 ethtool.c         |  103 ++++++++++++++++++++++++++++++++++++++++++++++++
 internal.h        |    1 +
 net_tstamp-copy.h |  113 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 test-cmdline.c    |    3 +
 6 files changed, 251 insertions(+), 0 deletions(-)
 create mode 100644 net_tstamp-copy.h

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d904c1a..2e32222 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -680,6 +680,29 @@ struct ethtool_sfeatures {
 	struct ethtool_set_features_block features[0];
 };
 
+/**
+ * struct ethtool_ts_info - holds a device's timestamping and PHC association
+ * @cmd: command number = %ETHTOOL_GET_TS_INFO
+ * @so_timestamping: bit mask of the sum of the supported SO_TIMESTAMPING flags
+ * @phc_index: device index of the associated PHC, or -1 if there is none
+ * @tx_types: bit mask of the supported hwtstamp_tx_types enumeration values
+ * @rx_filters: bit mask of the supported hwtstamp_rx_filters enumeration values
+ *
+ * The bits in the 'tx_types' and 'rx_filters' fields correspond to
+ * the 'hwtstamp_tx_types' and 'hwtstamp_rx_filters' enumeration values,
+ * respectively.  For example, if the device supports HWTSTAMP_TX_ON,
+ * then (1 << HWTSTAMP_TX_ON) in 'tx_types' will be set.
+ */
+struct ethtool_ts_info {
+	__u32	cmd;
+	__u32	so_timestamping;
+	__s32	phc_index;
+	__u32	tx_types;
+	__u32	tx_reserved[3];
+	__u32	rx_filters;
+	__u32	rx_reserved[3];
+};
+
 /*
  * %ETHTOOL_SFEATURES changes features present in features[].valid to the
  * values of corresponding bits in features[].requested. Bits in .requested
@@ -786,6 +809,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8.in b/ethtool.8.in
index 63d5d48..20fb8e9 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -292,6 +292,9 @@ ethtool \- query or control network driver and hardware settings
 .I devname
 .BI \ N
 .HP
+.B ethtool \-T|\-\-timestamping
+.I devname
+.HP
 .B ethtool \-x|\-\-show\-rxfh\-indir
 .I devname
 .HP
@@ -745,6 +748,10 @@ is indicated, then ethtool fetches the dump data and directs it to a
 .B \-W \-\-set\-dump
 Sets the dump flag for the device.
 .TP
+.B \-T \-\-timestamping
+Show the device's time stamping capabilities and associated PTP
+hardware clock.
+.TP
 .B \-x \-\-show\-rxfh\-indir
 Retrieves the receive flow hash indirection table.
 .TP
diff --git a/ethtool.c b/ethtool.c
index e80b38b..c6292a6 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1115,6 +1115,91 @@ static int dump_rxfhash(int fhash, u64 val)
 	return 0;
 }
 
+#define N_SOTS 7
+
+static char *so_timestamping_labels[N_SOTS] = {
+	"hardware-transmit     (SOF_TIMESTAMPING_TX_HARDWARE)",
+	"software-transmit     (SOF_TIMESTAMPING_TX_SOFTWARE)",
+	"hardware-receive      (SOF_TIMESTAMPING_RX_HARDWARE)",
+	"software-receive      (SOF_TIMESTAMPING_RX_SOFTWARE)",
+	"software-system-clock (SOF_TIMESTAMPING_SOFTWARE)",
+	"hardware-legacy-clock (SOF_TIMESTAMPING_SYS_HARDWARE)",
+	"hardware-raw-clock    (SOF_TIMESTAMPING_RAW_HARDWARE)",
+};
+
+#define N_TX_TYPES (HWTSTAMP_TX_ONESTEP_SYNC + 1)
+
+static char *tx_type_labels[N_TX_TYPES] = {
+	"off                   (HWTSTAMP_TX_OFF)",
+	"on                    (HWTSTAMP_TX_ON)",
+	"one-step-sync         (HWTSTAMP_TX_ONESTEP_SYNC)",
+};
+
+#define N_RX_FILTERS (HWTSTAMP_FILTER_PTP_V2_DELAY_REQ + 1)
+
+static char *rx_filter_labels[N_RX_FILTERS] = {
+	"none                  (HWTSTAMP_FILTER_NONE)",
+	"all                   (HWTSTAMP_FILTER_ALL)",
+	"some                  (HWTSTAMP_FILTER_SOME)",
+	"ptpv1-l4-event        (HWTSTAMP_FILTER_PTP_V1_L4_EVENT)",
+	"ptpv1-l4-sync         (HWTSTAMP_FILTER_PTP_V1_L4_SYNC)",
+	"ptpv1-l4-delay-req    (HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ)",
+	"ptpv2-l4-event        (HWTSTAMP_FILTER_PTP_V2_L4_EVENT)",
+	"ptpv2-l4-sync         (HWTSTAMP_FILTER_PTP_V2_L4_SYNC)",
+	"ptpv2-l4-delay-req    (HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ)",
+	"ptpv2-l2-event        (HWTSTAMP_FILTER_PTP_V2_L2_EVENT)",
+	"ptpv2-l2-sync         (HWTSTAMP_FILTER_PTP_V2_L2_SYNC)",
+	"ptpv2-l2-delay-req    (HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ)",
+	"ptpv2-event           (HWTSTAMP_FILTER_PTP_V2_EVENT)",
+	"ptpv2-sync            (HWTSTAMP_FILTER_PTP_V2_SYNC)",
+	"ptpv2-delay-req       (HWTSTAMP_FILTER_PTP_V2_DELAY_REQ)",
+};
+
+static int dump_tsinfo(const struct ethtool_ts_info *info)
+{
+	int i;
+
+	fprintf(stdout, "Capabilities:\n");
+
+	for (i = 0; i < N_SOTS; i++) {
+		if (info->so_timestamping & (1 << i))
+			fprintf(stdout, "\t%s\n", so_timestamping_labels[i]);
+	}
+
+	fprintf(stdout, "PTP Hardware Clock: ");
+
+	if (info->phc_index < 0)
+		fprintf(stdout, "none\n");
+	else
+		fprintf(stdout, "%d\n", info->phc_index);
+
+	fprintf(stdout, "Hardware Transmit Timestamp Modes:");
+
+	if (!info->tx_types)
+		fprintf(stdout, " none\n");
+	else
+		fprintf(stdout, "\n");
+
+	for (i = 0; i < N_TX_TYPES; i++) {
+		if (info->tx_types & (1 << i))
+			fprintf(stdout,	"\t%s\n", tx_type_labels[i]);
+	}
+
+	fprintf(stdout, "Hardware Receive Filter Modes:");
+
+	if (!info->rx_filters)
+		fprintf(stdout, " none\n");
+	else
+		fprintf(stdout, "\n");
+
+	for (i = 0; i < N_RX_FILTERS; i++) {
+		if (info->rx_filters & (1 << i))
+			fprintf(stdout, "\t%s\n", rx_filter_labels[i]);
+	}
+
+	return 0;
+}
+
 static struct ethtool_gstrings *
 get_stringset(struct cmd_context *ctx, enum ethtool_stringset set_id,
 	      ptrdiff_t drvinfo_offset)
@@ -3077,6 +3162,23 @@ static int do_sprivflags(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_tsinfo(struct cmd_context *ctx)
+{
+	struct ethtool_ts_info info;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	fprintf(stdout, "Time stamping parameters for %s:\n", ctx->devname);
+	info.cmd = ETHTOOL_GET_TS_INFO;
+	if (send_ioctl(ctx, &info)) {
+		perror("Cannot get device time stamping settings");
+		return -1;
+	}
+	dump_tsinfo(&info);
+	return 0;
+}
+
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
 #ifndef TEST_ETHTOOL
@@ -3206,6 +3308,7 @@ static const struct option {
 	  "			[ action %d ]\n"
 	  "			[ loc %d]] |\n"
 	  "		delete %d\n" },
+	{ "-T|--timestamping", 1, do_tsinfo, "Show time stamping capabilities" },
 	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
 	  "Show Rx flow hash indirection" },
 	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
diff --git a/internal.h b/internal.h
index 867c0ea..d72cdf5 100644
--- a/internal.h
+++ b/internal.h
@@ -25,6 +25,7 @@ typedef __uint8_t u8;
 typedef __int32_t s32;
 
 #include "ethtool-copy.h"
+#include "net_tstamp-copy.h"
 
 #if __BYTE_ORDER == __BIG_ENDIAN
 static inline u16 cpu_to_be16(u16 value)
diff --git a/net_tstamp-copy.h b/net_tstamp-copy.h
new file mode 100644
index 0000000..ae5df12
--- /dev/null
+++ b/net_tstamp-copy.h
@@ -0,0 +1,113 @@
+/*
+ * Userspace API for hardware time stamping of network packets
+ *
+ * Copyright (C) 2008,2009 Intel Corporation
+ * Author: Patrick Ohly <patrick.ohly@intel.com>
+ *
+ */
+
+#ifndef _NET_TIMESTAMPING_H
+#define _NET_TIMESTAMPING_H
+
+#include <linux/socket.h>   /* for SO_TIMESTAMPING */
+
+/* SO_TIMESTAMPING gets an integer bit field comprised of these values */
+enum {
+	SOF_TIMESTAMPING_TX_HARDWARE = (1<<0),
+	SOF_TIMESTAMPING_TX_SOFTWARE = (1<<1),
+	SOF_TIMESTAMPING_RX_HARDWARE = (1<<2),
+	SOF_TIMESTAMPING_RX_SOFTWARE = (1<<3),
+	SOF_TIMESTAMPING_SOFTWARE = (1<<4),
+	SOF_TIMESTAMPING_SYS_HARDWARE = (1<<5),
+	SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6),
+	SOF_TIMESTAMPING_MASK =
+	(SOF_TIMESTAMPING_RAW_HARDWARE - 1) |
+	SOF_TIMESTAMPING_RAW_HARDWARE
+};
+
+/**
+ * struct hwtstamp_config - %SIOCSHWTSTAMP parameter
+ *
+ * @flags:	no flags defined right now, must be zero
+ * @tx_type:	one of HWTSTAMP_TX_*
+ * @rx_type:	one of one of HWTSTAMP_FILTER_*
+ *
+ * %SIOCSHWTSTAMP expects a &struct ifreq with a ifr_data pointer to
+ * this structure. dev_ifsioc() in the kernel takes care of the
+ * translation between 32 bit userspace and 64 bit kernel. The
+ * structure is intentionally chosen so that it has the same layout on
+ * 32 and 64 bit systems, don't break this!
+ */
+struct hwtstamp_config {
+	int flags;
+	int tx_type;
+	int rx_filter;
+};
+
+/* possible values for hwtstamp_config->tx_type */
+enum hwtstamp_tx_types {
+	/*
+	 * No outgoing packet will need hardware time stamping;
+	 * should a packet arrive which asks for it, no hardware
+	 * time stamping will be done.
+	 */
+	HWTSTAMP_TX_OFF,
+
+	/*
+	 * Enables hardware time stamping for outgoing packets;
+	 * the sender of the packet decides which are to be
+	 * time stamped by setting %SOF_TIMESTAMPING_TX_SOFTWARE
+	 * before sending the packet.
+	 */
+	HWTSTAMP_TX_ON,
+
+	/*
+	 * Enables time stamping for outgoing packets just as
+	 * HWTSTAMP_TX_ON does, but also enables time stamp insertion
+	 * directly into Sync packets. In this case, transmitted Sync
+	 * packets will not received a time stamp via the socket error
+	 * queue.
+	 */
+	HWTSTAMP_TX_ONESTEP_SYNC,
+};
+
+/* possible values for hwtstamp_config->rx_filter */
+enum hwtstamp_rx_filters {
+	/* time stamp no incoming packet at all */
+	HWTSTAMP_FILTER_NONE,
+
+	/* time stamp any incoming packet */
+	HWTSTAMP_FILTER_ALL,
+
+	/* return value: time stamp all packets requested plus some others */
+	HWTSTAMP_FILTER_SOME,
+
+	/* PTP v1, UDP, any kind of event packet */
+	HWTSTAMP_FILTER_PTP_V1_L4_EVENT,
+	/* PTP v1, UDP, Sync packet */
+	HWTSTAMP_FILTER_PTP_V1_L4_SYNC,
+	/* PTP v1, UDP, Delay_req packet */
+	HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ,
+	/* PTP v2, UDP, any kind of event packet */
+	HWTSTAMP_FILTER_PTP_V2_L4_EVENT,
+	/* PTP v2, UDP, Sync packet */
+	HWTSTAMP_FILTER_PTP_V2_L4_SYNC,
+	/* PTP v2, UDP, Delay_req packet */
+	HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ,
+
+	/* 802.AS1, Ethernet, any kind of event packet */
+	HWTSTAMP_FILTER_PTP_V2_L2_EVENT,
+	/* 802.AS1, Ethernet, Sync packet */
+	HWTSTAMP_FILTER_PTP_V2_L2_SYNC,
+	/* 802.AS1, Ethernet, Delay_req packet */
+	HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ,
+
+	/* PTP v2/802.AS1, any layer, any kind of event packet */
+	HWTSTAMP_FILTER_PTP_V2_EVENT,
+	/* PTP v2/802.AS1, any layer, Sync packet */
+	HWTSTAMP_FILTER_PTP_V2_SYNC,
+	/* PTP v2/802.AS1, any layer, Delay_req packet */
+	HWTSTAMP_FILTER_PTP_V2_DELAY_REQ,
+};
+
+#endif /* _NET_TIMESTAMPING_H */
diff --git a/test-cmdline.c b/test-cmdline.c
index 4718842..b89ab4e 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -172,6 +172,9 @@ static struct test_case {
 	{ 1, "-U devname foo" },
 	{ 1, "-N" },
 	{ 1, "-U" },
+	{ 0, "-T devname" },
+	{ 0, "--timestamping devname" },
+	{ 1, "-T" },
 	{ 0, "-x devname" },
 	{ 0, "--show-rxfh-indir devname" },
 	{ 1, "-x" },
-- 
1.7.2.5


------------------------------------------------------------------------------
Better than sec? Nothing is better than sec when it comes to
monitoring Big Data applications. Try Boundary one-second 
resolution app monitoring today. Free.
http://p.sf.net/sfu/Boundary-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
