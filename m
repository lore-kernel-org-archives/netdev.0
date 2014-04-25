From: David Decotigny <decot@googlers.com>
Subject: [PATCH iproute2 v2] iproute2: show counter of carrier on<->off transitions
Date: Fri, 25 Apr 2014 16:43:16 -0700
Message-ID: <37c039131127d3511cd594157f727f9ce5f91c24.1398469237.git.decot@googlers.com>
References: <cover.1398469237.git.decot@googlers.com>
Cc: stephen@networkplumber.org, David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:63846 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbaDYXsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 19:48:40 -0400
Received: by mail-qa0-f73.google.com with SMTP id hw13so711336qab.4
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 16:48:39 -0700 (PDT)
In-Reply-To: <cover.1398469237.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to display the current counter of carrier on<->off
transitions (IFLA_CARRIER_CHANGES, see kernel commit "expose number of
carrier on/off changes"):

  ip -s -s link show dev eth0
  32: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    link/ether ................. brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    125552461  258881   0       0       0       10150
    RX errors: length  crc     frame   fifo    missed
               0        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    40426119   224444   0       0       0       0
    TX errors: aborted fifo    window  heartbeat transns
               0        0       0       0        3

Tested:
  - kernel with patch "net-sysfs: expose number of carrier on/off
    changes": see "transns" column above
  - kernel wthout the patch: "transns" not displayed (as expected)

Signed-off-by: David Decotigny <decot@googlers.com>
---
 ip/ipaddress.c | 32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 8169150..061c3b0 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -313,7 +313,8 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	}
 }
 
-static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s) {
+static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
+                               const struct rtattr *carrier_changes) {
 	fprintf(fp, "%s", _SL_);
 	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
 		s->rx_compressed ? "compressed" : "", _SL_);
@@ -352,16 +353,23 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s) {
 			(uint64_t)s->tx_compressed);
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    TX errors: aborted fifo    window  heartbeat%s", _SL_);
-		fprintf(fp, "               %-7"PRIu64"  %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
+		fprintf(fp, "    TX errors: aborted fifo    window  heartbeat");
+                if (carrier_changes)
+			fprintf(fp, " transns");
+		fprintf(fp, _SL_);
+		fprintf(fp, "               %-7"PRIu64"  %-7"PRIu64" %-7"PRIu64" %-8"PRIu64"",
 			(uint64_t)s->tx_aborted_errors,
 			(uint64_t)s->tx_fifo_errors,
 			(uint64_t)s->tx_window_errors,
 			(uint64_t)s->tx_heartbeat_errors);
+		if (carrier_changes)
+			fprintf(fp, " %-7u",
+				*(uint32_t*)RTA_DATA(carrier_changes));
 	}
 }
 
-static void print_link_stats(FILE *fp, const struct rtnl_link_stats *s)
+static void print_link_stats(FILE *fp, const struct rtnl_link_stats *s,
+			     const struct rtattr *carrier_changes)
 {
 	fprintf(fp, "%s", _SL_);
 	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
@@ -394,13 +402,19 @@ static void print_link_stats(FILE *fp, const struct rtnl_link_stats *s)
 		fprintf(fp, " %-7u", s->tx_compressed);
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    TX errors: aborted fifo    window  heartbeat%s", _SL_);
-		fprintf(fp, "               %-7u  %-7u %-7u %-7u",
+		fprintf(fp, "    TX errors: aborted fifo    window  heartbeat");
+                if (carrier_changes)
+			fprintf(fp, " transns");
+		fprintf(fp, _SL_);
+		fprintf(fp, "               %-7u  %-7u %-7u %-8u",
 			s->tx_aborted_errors,
 			s->tx_fifo_errors,
 			s->tx_window_errors,
 			s->tx_heartbeat_errors
 			);
+		if (carrier_changes)
+			fprintf(fp, " %-7u",
+				*(uint32_t*)RTA_DATA(carrier_changes));
 	}
 }
 
@@ -522,9 +536,11 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	if (do_link && show_stats) {
 		if (tb[IFLA_STATS64])
-			print_link_stats64(fp, RTA_DATA(tb[IFLA_STATS64]));
+			print_link_stats64(fp, RTA_DATA(tb[IFLA_STATS64]),
+					   tb[IFLA_CARRIER_CHANGES]);
 		else if (tb[IFLA_STATS])
-			print_link_stats(fp, RTA_DATA(tb[IFLA_STATS]));
+			print_link_stats(fp, RTA_DATA(tb[IFLA_STATS]),
+					 tb[IFLA_CARRIER_CHANGES]);
 	}
 
 	if (do_link && tb[IFLA_VFINFO_LIST] && tb[IFLA_NUM_VF]) {
-- 
1.9.1.423.g4596e3a
