From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH ethtool] Add the command to show the time stamping capabilities.
Date: Sun,  1 Apr 2012 17:23:28 +0200
Message-ID: <1333293808-7729-1-git-send-email-richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:64107 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab2DAPXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 11:23:38 -0400
Received: by wgbdr13 with SMTP id dr13so1960889wgb.1
        for <netdev@vger.kernel.org>; Sun, 01 Apr 2012 08:23:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 ethtool-copy.h |   19 ++++++++++
 ethtool.c      |  104 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 123 insertions(+), 0 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d904c1a..dd93cc5 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -680,6 +680,24 @@ struct ethtool_sfeatures {
 	struct ethtool_set_features_block features[0];
 };
 
+/**
+ * struct ethtool_ts_info - holds a device's timestamping and PHC association
+ * @cmd: command number = %ETHTOOL_GET_TS_INFO
+ * @so_timestamping: bit mask of SO_TIMESTAMPING modes supported by the device
+ * @phc_index: device index of the associated PHC, or -1 if there is none
+ * @tx_types: bit mask of hwtstamp_tx_types modes supported by the device
+ * @rx_filters: bit mask of hwtstamp_rx_filters modes supported by the device
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
@@ -786,6 +804,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index e80b38b..bef8aa7 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -38,6 +38,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 
+#include <linux/net_tstamp.h>
 #include <linux/sockios.h>
 
 #ifndef MAX_ADDR_LEN
@@ -1115,6 +1116,91 @@ static int dump_rxfhash(int fhash, u64 val)
 	return 0;
 }
 
+static int dump_tsinfo(const struct ethtool_ts_info *info)
+{
+	if (info->so_timestamping & SOF_TIMESTAMPING_TX_HARDWARE)
+		fprintf(stdout, "SOF_TIMESTAMPING_TX_HARDWARE\n");
+
+	if (info->so_timestamping & SOF_TIMESTAMPING_TX_SOFTWARE)
+		fprintf(stdout, "SOF_TIMESTAMPING_TX_SOFTWARE\n");
+
+	if (info->so_timestamping & SOF_TIMESTAMPING_RX_HARDWARE)
+		fprintf(stdout, "SOF_TIMESTAMPING_RX_HARDWARE\n");
+
+	if (info->so_timestamping & SOF_TIMESTAMPING_RX_SOFTWARE)
+		fprintf(stdout, "SOF_TIMESTAMPING_RX_SOFTWARE\n");
+
+	if (info->so_timestamping & SOF_TIMESTAMPING_SOFTWARE)
+		fprintf(stdout, "SOF_TIMESTAMPING_SOFTWARE\n");
+
+	if (info->so_timestamping & SOF_TIMESTAMPING_SYS_HARDWARE)
+		fprintf(stdout, "SOF_TIMESTAMPING_SYS_HARDWARE\n");
+
+	if (info->so_timestamping & SOF_TIMESTAMPING_RAW_HARDWARE)
+		fprintf(stdout, "SOF_TIMESTAMPING_RAW_HARDWARE\n");
+
+	if (info->phc_index < 0)
+		fprintf(stdout, "No PTP Hardware Clock\n");
+	else
+		fprintf(stdout, "PTP Hardware Clock %d\n", info->phc_index);
+
+	if (info->tx_types & (1 << HWTSTAMP_TX_OFF))
+		fprintf(stdout, "HWTSTAMP_TX_OFF\n");
+
+	if (info->tx_types & (1 << HWTSTAMP_TX_ON))
+		fprintf(stdout, "HWTSTAMP_TX_ON\n");
+
+	if (info->tx_types & (1 << HWTSTAMP_TX_ONESTEP_SYNC))
+		fprintf(stdout, "HWTSTAMP_TX_ONESTEP_SYNC\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_NONE))
+		fprintf(stdout, "HWTSTAMP_FILTER_NONE\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_ALL))
+		fprintf(stdout, "HWTSTAMP_FILTER_ALL\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_SOME))
+		fprintf(stdout, "HWTSTAMP_FILTER_SOME\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V1_L4_EVENT\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V1_L4_SYNC\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L4_EVENT\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L4_SYNC\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L2_EVENT\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L2_SYNC\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_EVENT))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_EVENT\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_SYNC))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_SYNC\n");
+
+	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ))
+		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_DELAY_REQ\n");
+
+	return 0;
+}
+
 static struct ethtool_gstrings *
 get_stringset(struct cmd_context *ctx, enum ethtool_stringset set_id,
 	      ptrdiff_t drvinfo_offset)
@@ -3077,6 +3163,23 @@ static int do_sprivflags(struct cmd_context *ctx)
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
@@ -3206,6 +3309,7 @@ static const struct option {
 	  "			[ action %d ]\n"
 	  "			[ loc %d]] |\n"
 	  "		delete %d\n" },
+	{ "-T|--timestamping", 1, do_tsinfo, "Show time stamping options" },
 	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
 	  "Show Rx flow hash indirection" },
 	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
-- 
1.7.2.5
