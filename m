From: Christian Hesse <mail@eworm.de>
Subject: [PATCHv2 1/1] ip-link: add switch to show human readable output
Date: Sat, 11 Oct 2014 00:27:36 +0200
Message-ID: <1412980056-7643-1-git-send-email-mail@eworm.de>
Cc: Christian Hesse <mail@eworm.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:34131 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755242AbaJJWgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 18:36:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Byte and packet count can increase to really big numbers. This adds a
switch to show human readable output.

% ip -s link ls wl
4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
    link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    113570876  156975   0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    27290790   94313    0       0       0       0
% ip -s -h link ls wl
4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
    link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    122368888  169840   0       0       0       0
    116.7Mi    165.8Ki  0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    29087507   102309   0       0       0       0
    27.7Mi     99.9Ki   0       0       0       0
---
 include/utils.h       |   1 +
 ip/ip.c               |   5 ++
 ip/ipaddress.c        | 143 ++++++++++++++++++++++++++++++++++++++++++++++++--
 man/man8/ip-link.8.in |   1 +
 4 files changed, 146 insertions(+), 4 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 704dc51..7bb19e9 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -11,6 +11,7 @@
 #include "rtm_map.h"
 
 extern int preferred_family;
+extern int human_readable;
 extern int show_stats;
 extern int show_details;
 extern int show_raw;
diff --git a/ip/ip.c b/ip/ip.c
index 739b88d..6b352c8 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -24,6 +24,7 @@
 #include "ip_common.h"
 
 int preferred_family = AF_UNSPEC;
+int human_readable = 0;
 int show_stats = 0;
 int show_details = 0;
 int resolve_hosts = 0;
@@ -47,6 +48,7 @@ static void usage(void)
 "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm |\n"
 "                   netns | l2tp | tcp_metrics | token | netconf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
+"                    -h[uman-readable] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
@@ -212,6 +214,9 @@ int main(int argc, char **argv)
 			preferred_family = AF_DECnet;
 		} else if (strcmp(opt, "-B") == 0) {
 			preferred_family = AF_BRIDGE;
+		} else if (matches(opt, "-human") == 0 ||
+			   matches(opt, "-human-readable") == 0) {
+			++human_readable;
 		} else if (matches(opt, "-stats") == 0 ||
 			   matches(opt, "-statistics") == 0) {
 			++show_stats;
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 45729d8..d625434 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -319,6 +319,54 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	}
 }
 
+static void print_human64(FILE *fp, int length, uint64_t count)
+{
+	int written;
+
+	if (count > 1125899906842624) /* 2**50 */
+		written = fprintf(fp, "%"PRIu64".%"PRIu64"Pi",
+				count / 1125899906842624,
+				count * 10 / 1125899906842624 % 10);
+	else if (count > 1099511627776) /* 2**40 */
+		written = fprintf(fp, "%"PRIu64".%"PRIu64"Ti",
+				count / 1099511627776,
+				count * 10 / 1099511627776 % 10);
+	else if (count > 1073741824) /* 2**30 */
+		written = fprintf(fp, "%"PRIu64".%"PRIu64"Gi",
+				count / 1073741824, count * 10 / 1073741824 % 10);
+	else if (count > 1048576) /* 2**20 */
+		written = fprintf(fp, "%"PRIu64".%"PRIu64"Mi",
+				count / 1048576, count * 10 / 1048576 % 10);
+	else if (count > 1024) /* 2**10 */
+		written = fprintf(fp, "%"PRIu64".%"PRIu64"Ki",
+				count / 1024, count * 10 / 1024 % 10);
+	else
+		written = fprintf(fp, "%"PRIu64, count);
+
+	while(written++ <= length)
+		fputc(' ', fp);
+}
+
+static void print_human32(FILE *fp, int length, uint32_t count)
+{
+	int written;
+
+	if (count > 1073741824) /* 2**30 */
+		written = fprintf(fp, "%u.%uGi",
+				count / 1073741824, count * 10 / 1073741824 % 10);
+	else if (count > 1048576) /* 2**20 */
+		written = fprintf(fp, "%u.%uMi",
+				count / 1048576, count * 10 / 1048576 % 10);
+	else if (count > 1024) /* 2**10 */
+		written = fprintf(fp, "%u.%uKi",
+				count / 1024, count * 10 / 1024 % 10);
+	else
+		written = fprintf(fp, "%u", count);
+
+	while(written++ <= length)
+		fputc(' ', fp);
+}
+
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
                                const struct rtattr *carrier_changes)
 {
@@ -334,15 +382,36 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 	if (s->rx_compressed)
 		fprintf(fp, " %-7"PRIu64"",
 			(uint64_t)s->rx_compressed);
+	if (human_readable) {
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    ");
+		print_human64(fp, 10, (uint64_t)s->rx_bytes);
+		print_human64(fp, 8, (uint64_t)s->rx_packets);
+		print_human64(fp, 7, (uint64_t)s->rx_errors);
+		print_human64(fp, 7, (uint64_t)s->rx_dropped);
+		print_human64(fp, 7, (uint64_t)s->rx_over_errors);
+		print_human64(fp, 7, (uint64_t)s->multicast);
+		if (s->rx_compressed)
+			print_human64(fp, 7, (uint64_t)s->rx_compressed);
+	}
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
 		fprintf(fp, "    RX errors: length  crc     frame   fifo    missed%s", _SL_);
-		fprintf(fp, "               %-7"PRIu64"  %-7"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
+		fprintf(fp, "               %-8"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
 			(uint64_t)s->rx_length_errors,
 			(uint64_t)s->rx_crc_errors,
 			(uint64_t)s->rx_frame_errors,
 			(uint64_t)s->rx_fifo_errors,
 			(uint64_t)s->rx_missed_errors);
+		if (human_readable) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "               ");
+			print_human64(fp, 8, (uint64_t)s->rx_length_errors);
+			print_human64(fp, 7, (uint64_t)s->rx_crc_errors);
+			print_human64(fp, 7, (uint64_t)s->rx_frame_errors);
+			print_human64(fp, 7, (uint64_t)s->rx_fifo_errors);
+			print_human64(fp, 7, (uint64_t)s->rx_missed_errors);
+		}
 	}
 	fprintf(fp, "%s", _SL_);
 	fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
@@ -357,13 +426,25 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 	if (s->tx_compressed)
 		fprintf(fp, " %-7"PRIu64"",
 			(uint64_t)s->tx_compressed);
+	if (human_readable) {
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    ");
+		print_human64(fp, 10, (uint64_t)s->tx_bytes);
+		print_human64(fp, 8, (uint64_t)s->tx_packets);
+		print_human64(fp, 7, (uint64_t)s->tx_errors);
+		print_human64(fp, 7, (uint64_t)s->tx_dropped);
+		print_human64(fp, 7, (uint64_t)s->tx_carrier_errors);
+		print_human64(fp, 7, (uint64_t)s->collisions);
+		if (s->tx_compressed)
+			print_human64(fp, 7, (uint64_t)s->tx_compressed);
+	}
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
 		fprintf(fp, "    TX errors: aborted fifo    window  heartbeat");
                 if (carrier_changes)
 			fprintf(fp, " transns");
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "               %-7"PRIu64"  %-7"PRIu64" %-7"PRIu64" %-8"PRIu64"",
+		fprintf(fp, "               %-8"PRIu64" %-7"PRIu64" %-7"PRIu64" %-8"PRIu64"",
 			(uint64_t)s->tx_aborted_errors,
 			(uint64_t)s->tx_fifo_errors,
 			(uint64_t)s->tx_window_errors,
@@ -371,6 +452,17 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 		if (carrier_changes)
 			fprintf(fp, " %-7u",
 				*(uint32_t*)RTA_DATA(carrier_changes));
+		if (human_readable) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "               ");
+			print_human64(fp, 8, (uint64_t)s->tx_aborted_errors);
+			print_human64(fp, 7, (uint64_t)s->tx_fifo_errors);
+			print_human64(fp, 7, (uint64_t)s->tx_window_errors);
+			print_human64(fp, 7, (uint64_t)s->tx_heartbeat_errors);
+			if (carrier_changes)
+				print_human64(fp, 7, (uint64_t)*(uint32_t*)RTA_DATA(carrier_changes));
+		}
+
 	}
 }
 
@@ -386,16 +478,37 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 		);
 	if (s->rx_compressed)
 		fprintf(fp, " %-7u", s->rx_compressed);
+	if (human_readable) {
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    ");
+		print_human32(fp, 10, s->rx_bytes);
+		print_human32(fp, 8, s->rx_packets);
+		print_human32(fp, 7, s->rx_errors);
+		print_human32(fp, 7, s->rx_dropped);
+		print_human32(fp, 7, s->rx_over_errors);
+		print_human32(fp, 7, s->multicast);
+		if (s->rx_compressed)
+			print_human32(fp, 7, s->rx_compressed);
+	}
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
 		fprintf(fp, "    RX errors: length  crc     frame   fifo    missed%s", _SL_);
-		fprintf(fp, "               %-7u  %-7u %-7u %-7u %-7u",
+		fprintf(fp, "               %-8u %-7u %-7u %-7u %-7u",
 			s->rx_length_errors,
 			s->rx_crc_errors,
 			s->rx_frame_errors,
 			s->rx_fifo_errors,
 			s->rx_missed_errors
 			);
+		if (human_readable) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "               ");
+			print_human32(fp, 8, s->rx_length_errors);
+			print_human32(fp, 7, s->rx_crc_errors);
+			print_human32(fp, 7, s->rx_frame_errors);
+			print_human32(fp, 7, s->rx_fifo_errors);
+			print_human32(fp, 7, s->rx_missed_errors);
+		}
 	}
 	fprintf(fp, "%s", _SL_);
 	fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
@@ -405,13 +518,25 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 		s->tx_dropped, s->tx_carrier_errors, s->collisions);
 	if (s->tx_compressed)
 		fprintf(fp, " %-7u", s->tx_compressed);
+	if (human_readable) {
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    ");
+		print_human32(fp, 10, s->tx_bytes);
+		print_human32(fp, 8, s->tx_packets);
+		print_human32(fp, 7, s->tx_errors);
+		print_human32(fp, 7, s->tx_dropped);
+		print_human32(fp, 7, s->tx_carrier_errors);
+		print_human32(fp, 7, s->collisions);
+		if (s->tx_compressed)
+			print_human32(fp, 7, s->tx_compressed);
+	}
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
 		fprintf(fp, "    TX errors: aborted fifo    window  heartbeat");
                 if (carrier_changes)
 			fprintf(fp, " transns");
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "               %-7u  %-7u %-7u %-8u",
+		fprintf(fp, "               %-8u %-7u %-7u %-8u",
 			s->tx_aborted_errors,
 			s->tx_fifo_errors,
 			s->tx_window_errors,
@@ -420,6 +545,16 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 		if (carrier_changes)
 			fprintf(fp, " %-7u",
 				*(uint32_t*)RTA_DATA(carrier_changes));
+		if (human_readable) {
+			fprintf(fp, "%s", _SL_);
+			fprintf(fp, "               ");
+			print_human32(fp, 8, s->tx_aborted_errors);
+			print_human32(fp, 7, s->tx_fifo_errors);
+			print_human32(fp, 7, s->tx_window_errors);
+			print_human32(fp, 7, s->tx_heartbeat_errors);
+			if (carrier_changes)
+				print_human32(fp, 7, *(uint32_t*)RTA_DATA(carrier_changes));
+		}
 	}
 }
 
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 383917a..9c20dd0 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -16,6 +16,7 @@ ip-link \- network device configuration
 .ti -8
 .IR OPTIONS " := { "
 \fB\-V\fR[\fIersion\fR] |
+\fB\-h\fR[\fIuman-readable\fR] |
 \fB\-s\fR[\fItatistics\fR] |
 \fB\-r\fR[\fIesolve\fR] |
 \fB\-f\fR[\fIamily\fR] {
-- 
2.1.2
