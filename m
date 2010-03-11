From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH] Add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 21:00:34 +0100
Message-ID: <1268337635-7031-2-git-send-email-jengelh@medozas.de>
References: <1268337635-7031-1-git-send-email-jengelh@medozas.de>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:33747 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754233Ab0CKUAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 15:00:40 -0500
In-Reply-To: <1268337635-7031-1-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

`ip -s link` shows interface counters truncated to 32 bit. This is
because interface statistics are transported only in 32-bit quantity
to userspace. This commit adds recognition for the new IFLA_STATS64
attribute that exports them in full 64 bit.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/if_link.h |   33 ++++++++++++++++++++++++++++
 ip/ipaddress.c          |   55 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 87 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 5110b96..8772719 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -37,6 +37,38 @@ struct rtnl_link_stats {
 	__u32	tx_compressed;
 };
 
+struct rtnl_link_stats64 {
+	__u64	rx_packets;		/* total packets received	*/
+	__u64	tx_packets;		/* total packets transmitted	*/
+	__u64	rx_bytes;		/* total bytes received 	*/
+	__u64	tx_bytes;		/* total bytes transmitted	*/
+	__u64	rx_errors;		/* bad packets received		*/
+	__u64	tx_errors;		/* packet transmit problems	*/
+	__u64	rx_dropped;		/* no space in linux buffers	*/
+	__u64	tx_dropped;		/* no space available in linux	*/
+	__u64	multicast;		/* multicast packets received	*/
+	__u64	collisions;
+
+	/* detailed rx_errors: */
+	__u64	rx_length_errors;
+	__u64	rx_over_errors;		/* receiver ring buff overflow	*/
+	__u64	rx_crc_errors;		/* recved pkt with crc error	*/
+	__u64	rx_frame_errors;	/* recv'd frame alignment error */
+	__u64	rx_fifo_errors;		/* recv'r fifo overrun		*/
+	__u64	rx_missed_errors;	/* receiver missed packet	*/
+
+	/* detailed tx_errors */
+	__u64	tx_aborted_errors;
+	__u64	tx_carrier_errors;
+	__u64	tx_fifo_errors;
+	__u64	tx_heartbeat_errors;
+	__u64	tx_window_errors;
+
+	/* for cslip etc */
+	__u64	rx_compressed;
+	__u64	tx_compressed;
+};
+
 /* The struct should be in sync with struct ifmap */
 struct rtnl_link_ifmap {
 	__u64	mem_start;
@@ -83,6 +115,7 @@ enum {
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VFINFO,
+	IFLA_STATS64,
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 48f7b1e..33fc606 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -284,7 +284,60 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		fprintf(fp,"\n    alias %s", 
 			(const char *) RTA_DATA(tb[IFLA_IFALIAS]));
 
-	if (do_link && tb[IFLA_STATS] && show_stats) {
+	if (do_link && tb[IFLA_STATS64] && show_stats) {
+		struct rtnl_link_stats64 slocal;
+		struct rtnl_link_stats64 *s = RTA_DATA(tb[IFLA_STATS64]);
+		if (((unsigned long)s) & (sizeof(unsigned long)-1)) {
+			memcpy(&slocal, s, sizeof(slocal));
+			s = &slocal;
+		}
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
+			s->rx_compressed ? "compressed" : "", _SL_);
+		fprintf(fp, "    %-10llu %-8llu %-7llu %-7llu %-7llu %-7llu",
+			(unsigned long long)s->rx_bytes,
+			(unsigned long long)s->rx_packets,
+			(unsigned long long)s->rx_errors,
+			(unsigned long long)s->rx_dropped,
+			(unsigned long long)s->rx_over_errors,
+			(unsigned long long)s->multicast);
+		if (s->rx_compressed)
+			fprintf(fp, " %-7llu",
+				(unsigned long long)s->rx_compressed);
+		if (show_stats > 1) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "    RX errors: length  crc     frame   fifo    missed%s", _SL_);
+			fprintf(fp, "               %-7llu  %-7llu %-7llu %-7llu %-7llu",
+				(unsigned long long)s->rx_length_errors,
+				(unsigned long long)s->rx_crc_errors,
+				(unsigned long long)s->rx_frame_errors,
+				(unsigned long long)s->rx_fifo_errors,
+				(unsigned long long)s->rx_missed_errors);
+		}
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
+			s->tx_compressed ? "compressed" : "", _SL_);
+		fprintf(fp, "    %-10llu %-8llu %-7llu %-7llu %-7llu %-7llu",
+			(unsigned long long)s->tx_bytes,
+			(unsigned long long)s->tx_packets,
+			(unsigned long long)s->tx_errors,
+			(unsigned long long)s->tx_dropped,
+			(unsigned long long)s->tx_carrier_errors,
+			(unsigned long long)s->collisions);
+		if (s->tx_compressed)
+			fprintf(fp, " %-7llu",
+				(unsigned long long)s->tx_compressed);
+		if (show_stats > 1) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "    TX errors: aborted fifo    window  heartbeat%s", _SL_);
+			fprintf(fp, "               %-7llu  %-7llu %-7llu %-7llu",
+				(unsigned long long)s->tx_aborted_errors,
+				(unsigned long long)s->tx_fifo_errors,
+				(unsigned long long)s->tx_window_errors,
+				(unsigned long long)s->tx_heartbeat_errors);
+		}
+	}
+	if (do_link && !tb[IFLA_STATS64] && tb[IFLA_STATS] && show_stats) {
 		struct rtnl_link_stats slocal;
 		struct rtnl_link_stats *s = RTA_DATA(tb[IFLA_STATS]);
 		if (((unsigned long)s) & (sizeof(unsigned long)-1)) {
-- 
1.7.0

