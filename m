From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next iproute2] iplink: display rx nohandler stats
Date: Tue, 9 Feb 2016 11:17:57 -0800
Message-ID: <20160209111757.4d7d65c1@xeon-e3>
References: <20160208183254.GB4566@redhat.com>
	<20160208113821.0ba26eb0@xeon-e3>
	<1454972260.7627.368.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160209.034023.50018877443465909.davem@davemloft.net>
	<56B9C5DC.4050505@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	jarod@redhat.com, linux-kernel@vger.kernel.org,
	edumazet@google.com, jiri@mellanox.com, daniel@iogearbox.net,
	tom@herbertland.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B9C5DC.4050505@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support for the new rx_nohandler statistic.
This code is designed to handle the case where the kernel reported statistic
structure is smaller than the larger structure in later releases (and vice versa).

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 ip/ipaddress.c | 35 ++++++++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 9 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 9d254d2..c4a8fc3 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -481,7 +481,8 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 	/* RX error stats */
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s", _SL_);
+		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s%s",
+			s->rx_nohandler ? "   nohandler" : "",  _SL_);
 
 		fprintf(fp, "               ");
 		print_num(fp, 8, s->rx_length_errors);
@@ -489,6 +490,9 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 		print_num(fp, 7, s->rx_frame_errors);
 		print_num(fp, 7, s->rx_fifo_errors);
 		print_num(fp, 7, s->rx_missed_errors);
+		if (s->rx_nohandler)
+			print_num(fp, 7, s->rx_nohandler);
+
 	}
 	fprintf(fp, "%s", _SL_);
 
@@ -496,7 +500,6 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 	fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
 		s->tx_compressed ? "compressed" : "", _SL_);
 
-
 	fprintf(fp, "    ");
 	print_num(fp, 10, s->tx_bytes);
 	print_num(fp, 8, s->tx_packets);
@@ -546,13 +549,16 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 	/* RX error stats */
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s", _SL_);
+		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s%s",
+			s->rx_nohandler ? "   nohandler" : "",  _SL_);
 		fprintf(fp, "               ");
 		print_num(fp, 8, s->rx_length_errors);
 		print_num(fp, 7, s->rx_crc_errors);
 		print_num(fp, 7, s->rx_frame_errors);
 		print_num(fp, 7, s->rx_fifo_errors);
 		print_num(fp, 7, s->rx_missed_errors);
+		if (s->rx_nohandler)
+			print_num(fp, 7, s->rx_nohandler);
 	}
 	fprintf(fp, "%s", _SL_);
 
@@ -590,12 +596,23 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 
 static void __print_link_stats(FILE *fp, struct rtattr **tb)
 {
-	if (tb[IFLA_STATS64])
-		print_link_stats64(fp, RTA_DATA(tb[IFLA_STATS64]),
-					tb[IFLA_CARRIER_CHANGES]);
-	else if (tb[IFLA_STATS])
-		print_link_stats32(fp, RTA_DATA(tb[IFLA_STATS]),
-					tb[IFLA_CARRIER_CHANGES]);
+	const struct rtattr *carrier_changes = tb[IFLA_CARRIER_CHANGES];
+
+	if (tb[IFLA_STATS64]) {
+		struct rtnl_link_stats64 stats = { 0 };
+
+		memcpy(&stats, RTA_DATA(tb[IFLA_STATS64]),
+		       MIN(RTA_PAYLOAD(tb[IFLA_STATS64]), sizeof(stats)));
+
+		print_link_stats64(fp, &stats, carrier_changes);
+	} else if (tb[IFLA_STATS]) {
+		struct rtnl_link_stats stats = { 0 };
+
+		memcpy(&stats, RTA_DATA(tb[IFLA_STATS]),
+		       MIN(RTA_PAYLOAD(tb[IFLA_STATS]), sizeof(stats)));
+
+		print_link_stats32(fp, &stats, carrier_changes);
+	}
 }
 
 static void print_link_stats(FILE *fp, struct nlmsghdr *n)
-- 
2.1.4
