From: Christian Hesse <mail@eworm.de>
Subject: [PATCH v4 1/1] ip-link: add switch to show human readable output
Date: Fri, 31 Oct 2014 22:33:13 +0100
Message-ID: <1414791193-25192-1-git-send-email-mail@eworm.de>
References: <20141031123115.4cd13371@urahara>
Cc: netdev@vger.kernel.org, Christian Hesse <mail@eworm.de>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:33303 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759641AbaJaVh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 17:37:28 -0400
In-Reply-To: <20141031123115.4cd13371@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Byte and packet count can increase to really big numbers. This adds a
switch to show human readable output.

4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
    link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1523846973 3969051  0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    8710088361 6077735  0       0       0       0
4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
    link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1.5G       3.9M     0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    8.7G       6.0M     0       0       0       0
---
 include/utils.h       |   1 +
 ip/ip.c               |   5 +
 ip/ipaddress.c        | 286 ++++++++++++++++++++++++++++++++++++++------------
 man/man8/ip-link.8.in |   7 ++
 4 files changed, 233 insertions(+), 66 deletions(-)

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
index 45729d8..4b8ddca 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -319,107 +319,261 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	}
 }
 
+
+static void print_human64(FILE *fp, int length, uint64_t count)
+{
+	char * prefix = "kMGTPE";
+	int written = 0, i;
+	uint64_t powi = 1;
+
+	if (count < 1000) {
+		/* we are below 1000, so no precision and no prefix */
+		written = fprintf(fp, "%"PRIu64, count);
+	} else {
+		/* increase value by a factor of 1000 and print
+		 * if result is something a human can read */
+		for (i = 0; i < 6; i++) {
+			powi *= 1000;
+			if (count / 1000 < powi) {
+				 written = fprintf(fp, "%"PRIu64".%"PRIu64"%c",
+					 count / powi, count * 10 / powi % 10, *prefix);
+				 break;
+			}
+			prefix++;
+		}
+	}
+
+	do {
+		fputc(' ', fp);
+	} while (written++ < length);
+}
+
+static void print_human32(FILE *fp, int length, uint32_t count)
+{
+	char * prefix = "KMG";
+	int written = 0, i;
+	uint32_t powi = 1;
+
+	if (count < 1000) {
+		/* we are below 1000, so no precision and no prefix */
+		written = fprintf(fp, "%u", count);
+	} else {
+		/* increase value by a factor of 1000 and print
+		 * if result is something a human can read */
+		for (i = 0; i < 3; i++) {
+			powi *= 1000;
+			if (count / 1000 < powi) {
+				 written = fprintf(fp, "%u.%u%c",
+					 count / powi, count * 10 / powi % 10, *prefix);
+				 break;
+			}
+			prefix++;
+		}
+	}
+
+	do {
+		fputc(' ', fp);
+	} while (written++ < length);
+}
+
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
                                const struct rtattr *carrier_changes)
 {
+	/* RX stats */
 	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
 		s->rx_compressed ? "compressed" : "", _SL_);
-	fprintf(fp, "    %-10"PRIu64" %-8"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
-		(uint64_t)s->rx_bytes,
-		(uint64_t)s->rx_packets,
-		(uint64_t)s->rx_errors,
-		(uint64_t)s->rx_dropped,
-		(uint64_t)s->rx_over_errors,
-		(uint64_t)s->multicast);
-	if (s->rx_compressed)
-		fprintf(fp, " %-7"PRIu64"",
-			(uint64_t)s->rx_compressed);
+	if (human_readable) {
+		fprintf(fp, "    ");
+		print_human64(fp, 10, (uint64_t)s->rx_bytes);
+		print_human64(fp, 8, (uint64_t)s->rx_packets);
+		print_human64(fp, 7, (uint64_t)s->rx_errors);
+		print_human64(fp, 7, (uint64_t)s->rx_dropped);
+		print_human64(fp, 7, (uint64_t)s->rx_over_errors);
+		print_human64(fp, 7, (uint64_t)s->multicast);
+		if (s->rx_compressed)
+			print_human64(fp, 7, (uint64_t)s->rx_compressed);
+	} else {
+		fprintf(fp, "    %-10"PRIu64" %-8"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
+			(uint64_t)s->rx_bytes,
+			(uint64_t)s->rx_packets,
+			(uint64_t)s->rx_errors,
+			(uint64_t)s->rx_dropped,
+			(uint64_t)s->rx_over_errors,
+			(uint64_t)s->multicast);
+		if (s->rx_compressed)
+			fprintf(fp, " %-7"PRIu64"",
+				(uint64_t)s->rx_compressed);
+	}
+
+	/* RX error stats */
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    RX errors: length  crc     frame   fifo    missed%s", _SL_);
-		fprintf(fp, "               %-7"PRIu64"  %-7"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
-			(uint64_t)s->rx_length_errors,
-			(uint64_t)s->rx_crc_errors,
-			(uint64_t)s->rx_frame_errors,
-			(uint64_t)s->rx_fifo_errors,
-			(uint64_t)s->rx_missed_errors);
+		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s", _SL_);
+		if (human_readable) {
+			fprintf(fp, "               ");
+			print_human64(fp, 8, (uint64_t)s->rx_length_errors);
+			print_human64(fp, 7, (uint64_t)s->rx_crc_errors);
+			print_human64(fp, 7, (uint64_t)s->rx_frame_errors);
+			print_human64(fp, 7, (uint64_t)s->rx_fifo_errors);
+			print_human64(fp, 7, (uint64_t)s->rx_missed_errors);
+		} else {
+			fprintf(fp, "               %-8"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
+				(uint64_t)s->rx_length_errors,
+				(uint64_t)s->rx_crc_errors,
+				(uint64_t)s->rx_frame_errors,
+				(uint64_t)s->rx_fifo_errors,
+				(uint64_t)s->rx_missed_errors);
+		}
 	}
 	fprintf(fp, "%s", _SL_);
+
+	/* TX stats */
 	fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
 		(uint64_t)s->tx_compressed ? "compressed" : "", _SL_);
-	fprintf(fp, "    %-10"PRIu64" %-8"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
-		(uint64_t)s->tx_bytes,
-		(uint64_t)s->tx_packets,
-		(uint64_t)s->tx_errors,
-		(uint64_t)s->tx_dropped,
-		(uint64_t)s->tx_carrier_errors,
-		(uint64_t)s->collisions);
-	if (s->tx_compressed)
-		fprintf(fp, " %-7"PRIu64"",
-			(uint64_t)s->tx_compressed);
+	if (human_readable) {
+		fprintf(fp, "    ");
+		print_human64(fp, 10, (uint64_t)s->tx_bytes);
+		print_human64(fp, 8, (uint64_t)s->tx_packets);
+		print_human64(fp, 7, (uint64_t)s->tx_errors);
+		print_human64(fp, 7, (uint64_t)s->tx_dropped);
+		print_human64(fp, 7, (uint64_t)s->tx_carrier_errors);
+		print_human64(fp, 7, (uint64_t)s->collisions);
+		if (s->tx_compressed)
+			print_human64(fp, 7, (uint64_t)s->tx_compressed);
+	} else {
+		fprintf(fp, "    %-10"PRIu64" %-8"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
+			(uint64_t)s->tx_bytes,
+			(uint64_t)s->tx_packets,
+			(uint64_t)s->tx_errors,
+			(uint64_t)s->tx_dropped,
+			(uint64_t)s->tx_carrier_errors,
+			(uint64_t)s->collisions);
+		if (s->tx_compressed)
+			fprintf(fp, " %-7"PRIu64"",
+				(uint64_t)s->tx_compressed);
+	}
+
+	/* TX error stats */
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    TX errors: aborted fifo    window  heartbeat");
+		fprintf(fp, "    TX errors: aborted  fifo   window heartbeat");
                 if (carrier_changes)
 			fprintf(fp, " transns");
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "               %-7"PRIu64"  %-7"PRIu64" %-7"PRIu64" %-8"PRIu64"",
-			(uint64_t)s->tx_aborted_errors,
-			(uint64_t)s->tx_fifo_errors,
-			(uint64_t)s->tx_window_errors,
-			(uint64_t)s->tx_heartbeat_errors);
-		if (carrier_changes)
-			fprintf(fp, " %-7u",
-				*(uint32_t*)RTA_DATA(carrier_changes));
+		if (human_readable) {
+			fprintf(fp, "               ");
+			print_human64(fp, 8, (uint64_t)s->tx_aborted_errors);
+			print_human64(fp, 7, (uint64_t)s->tx_fifo_errors);
+			print_human64(fp, 7, (uint64_t)s->tx_window_errors);
+			print_human64(fp, 7, (uint64_t)s->tx_heartbeat_errors);
+			if (carrier_changes)
+				print_human64(fp, 7, (uint64_t)*(uint32_t*)RTA_DATA(carrier_changes));
+		} else {
+			fprintf(fp, "               %-8"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
+				(uint64_t)s->tx_aborted_errors,
+				(uint64_t)s->tx_fifo_errors,
+				(uint64_t)s->tx_window_errors,
+				(uint64_t)s->tx_heartbeat_errors);
+			if (carrier_changes)
+				fprintf(fp, " %-7u",
+					*(uint32_t*)RTA_DATA(carrier_changes));
+		}
 	}
 }
 
 static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 			       const struct rtattr *carrier_changes)
 {
+	/* RX stats */
 	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
 		s->rx_compressed ? "compressed" : "", _SL_);
-	fprintf(fp, "    %-10u %-8u %-7u %-7u %-7u %-7u",
-		s->rx_bytes, s->rx_packets, s->rx_errors,
-		s->rx_dropped, s->rx_over_errors,
-		s->multicast
-		);
-	if (s->rx_compressed)
-		fprintf(fp, " %-7u", s->rx_compressed);
+	if (human_readable) {
+		fprintf(fp, "    ");
+		print_human32(fp, 10, s->rx_bytes);
+		print_human32(fp, 8, s->rx_packets);
+		print_human32(fp, 7, s->rx_errors);
+		print_human32(fp, 7, s->rx_dropped);
+		print_human32(fp, 7, s->rx_over_errors);
+		print_human32(fp, 7, s->multicast);
+		if (s->rx_compressed)
+			print_human32(fp, 7, s->rx_compressed);
+	} else {
+		fprintf(fp, "    %-10u %-8u %-7u %-7u %-7u %-7u",
+			s->rx_bytes, s->rx_packets, s->rx_errors,
+			s->rx_dropped, s->rx_over_errors,
+			s->multicast);
+		if (s->rx_compressed)
+			fprintf(fp, " %-7u", s->rx_compressed);
+	}
+
+	/* RX error stats */
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    RX errors: length  crc     frame   fifo    missed%s", _SL_);
-		fprintf(fp, "               %-7u  %-7u %-7u %-7u %-7u",
-			s->rx_length_errors,
-			s->rx_crc_errors,
-			s->rx_frame_errors,
-			s->rx_fifo_errors,
-			s->rx_missed_errors
-			);
+		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s", _SL_);
+		if (human_readable) {
+			fprintf(fp, "               ");
+			print_human32(fp, 8, s->rx_length_errors);
+			print_human32(fp, 7, s->rx_crc_errors);
+			print_human32(fp, 7, s->rx_frame_errors);
+			print_human32(fp, 7, s->rx_fifo_errors);
+			print_human32(fp, 7, s->rx_missed_errors);
+		} else {
+			fprintf(fp, "               %-8u %-7u %-7u %-7u %-7u",
+				s->rx_length_errors,
+				s->rx_crc_errors,
+				s->rx_frame_errors,
+				s->rx_fifo_errors,
+				s->rx_missed_errors);
+		}
 	}
 	fprintf(fp, "%s", _SL_);
+
+	/* TX stats */
 	fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
 		s->tx_compressed ? "compressed" : "", _SL_);
-	fprintf(fp, "    %-10u %-8u %-7u %-7u %-7u %-7u",
-		s->tx_bytes, s->tx_packets, s->tx_errors,
-		s->tx_dropped, s->tx_carrier_errors, s->collisions);
-	if (s->tx_compressed)
-		fprintf(fp, " %-7u", s->tx_compressed);
+	if (human_readable) {
+		fprintf(fp, "    ");
+		print_human32(fp, 10, s->tx_bytes);
+		print_human32(fp, 8, s->tx_packets);
+		print_human32(fp, 7, s->tx_errors);
+		print_human32(fp, 7, s->tx_dropped);
+		print_human32(fp, 7, s->tx_carrier_errors);
+		print_human32(fp, 7, s->collisions);
+		if (s->tx_compressed)
+			print_human32(fp, 7, s->tx_compressed);
+	} else {
+		fprintf(fp, "    %-10u %-8u %-7u %-7u %-7u %-7u",
+			s->tx_bytes, s->tx_packets, s->tx_errors,
+			s->tx_dropped, s->tx_carrier_errors, s->collisions);
+		if (s->tx_compressed)
+			fprintf(fp, " %-7u", s->tx_compressed);
+	}
+
+	/* TX error stats */
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    TX errors: aborted fifo    window  heartbeat");
+		fprintf(fp, "    TX errors: aborted  fifo   window heartbeat");
                 if (carrier_changes)
 			fprintf(fp, " transns");
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "               %-7u  %-7u %-7u %-8u",
-			s->tx_aborted_errors,
-			s->tx_fifo_errors,
-			s->tx_window_errors,
-			s->tx_heartbeat_errors
-			);
-		if (carrier_changes)
-			fprintf(fp, " %-7u",
-				*(uint32_t*)RTA_DATA(carrier_changes));
+		if (human_readable) {
+			fprintf(fp, "               ");
+			print_human32(fp, 8, s->tx_aborted_errors);
+			print_human32(fp, 7, s->tx_fifo_errors);
+			print_human32(fp, 7, s->tx_window_errors);
+			print_human32(fp, 7, s->tx_heartbeat_errors);
+			if (carrier_changes)
+				print_human32(fp, 7, *(uint32_t*)RTA_DATA(carrier_changes));
+		} else {
+			fprintf(fp, "               %-8u %-7u %-7u %-7u",
+				s->tx_aborted_errors,
+				s->tx_fifo_errors,
+				s->tx_window_errors,
+				s->tx_heartbeat_errors);
+			if (carrier_changes)
+				fprintf(fp, " %-7u",
+					*(uint32_t*)RTA_DATA(carrier_changes));
+		}
 	}
 }
 
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 464009d..9747c4c 100644
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
@@ -660,6 +661,12 @@ specifies what group of devices to show.
 .B up
 only display running interfaces.
 
+.SH "NOTES"
+Human readable values are calculated with SI prefixes, so with a decimal
+base, not binary. (This is unlike
+.BR ifconfig (8)
+, with uses binary prefix.) 1,000 bytes are 1 kB, 1,000 kB are 1 MB, ...
+
 .SH "EXAMPLES"
 .PP
 ip link show
-- 
2.1.3
