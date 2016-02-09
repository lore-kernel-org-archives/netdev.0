From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next iproute2] iplink: display rx nohandler stats
Date: Tue, 9 Feb 2016 18:51:35 -0500
Message-ID: <20160209235134.GA15438@redhat.com>
References: <20160208183254.GB4566@redhat.com>
 <20160208113821.0ba26eb0@xeon-e3>
 <1454972260.7627.368.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160209.034023.50018877443465909.davem@davemloft.net>
 <56B9C5DC.4050505@mojatatu.com>
 <20160209111757.4d7d65c1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160209111757.4d7d65c1@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 09, 2016 at 11:17:57AM -0800, Stephen Hemminger wrote:
> Support for the new rx_nohandler statistic.
> This code is designed to handle the case where the kernel reported statistic
> structure is smaller than the larger structure in later releases (and vice versa).

This seems to work here, for the most part. However, if you are running a
kernel with the new counter, and the counter happens to contain 0, aren't
we going to not print anything?

I've got a tweaked version here locally that gets a touch messy, where I
get a count of members from RTA_DATA(IFLA_STATS{,64} / sizeof(__u{32,64}),
pass that into the print functions, and key off that length for whether or
not to print the extra members, so they'll show up even when 0, if they're
supported. This does rely on strict ordering of the struct members, no
reordering, no removals, etc., but I think everyone is already in favor of
that. Looks like the same sort of length checks could be used for
rx_compressed and tx_compressed as well, as I think they fall victim to
the same issue of not printing if those counters are legitimately 0. Yes,
it's a little uglier, and more brittle, but more accurate output.

Work-in-progress patch:

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 9d254d2..ae4359a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -462,7 +462,8 @@ static void print_vf_stats64(FILE *fp, struct rtattr *vfstats)
 }
 
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
-                               const struct rtattr *carrier_changes)
+                               const struct rtattr *carrier_changes,
+			       unsigned slen)
 {
 	/* RX stats */
 	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
@@ -481,14 +482,16 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 	/* RX error stats */
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s", _SL_);
-
+		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s%s",
+			slen > 23 ? "  nohandler" : "", _SL_);
 		fprintf(fp, "               ");
 		print_num(fp, 8, s->rx_length_errors);
 		print_num(fp, 7, s->rx_crc_errors);
 		print_num(fp, 7, s->rx_frame_errors);
 		print_num(fp, 7, s->rx_fifo_errors);
 		print_num(fp, 7, s->rx_missed_errors);
+		if (slen > 23)
+			print_num(fp, 7, s->rx_nohandler);
 	}
 	fprintf(fp, "%s", _SL_);
 
@@ -496,7 +499,6 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 	fprintf(fp, "    TX: bytes  packets  errors  dropped carrier collsns %s%s",
 		s->tx_compressed ? "compressed" : "", _SL_);
 
-
 	fprintf(fp, "    ");
 	print_num(fp, 10, s->tx_bytes);
 	print_num(fp, 8, s->tx_packets);
@@ -526,13 +528,13 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 }
 
 static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
-			       const struct rtattr *carrier_changes)
+			       const struct rtattr *carrier_changes,
+			       unsigned slen)
 {
 	/* RX stats */
 	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
 		s->rx_compressed ? "compressed" : "", _SL_);
 
-
 	fprintf(fp, "    ");
 	print_num(fp, 10, s->rx_bytes);
 	print_num(fp, 8, s->rx_packets);
@@ -546,13 +548,16 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 	/* RX error stats */
 	if (show_stats > 1) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s", _SL_);
+		fprintf(fp, "    RX errors: length   crc     frame   fifo    missed%s%s",
+			slen > 23 ? "  nohandler" : "", _SL_);
 		fprintf(fp, "               ");
 		print_num(fp, 8, s->rx_length_errors);
 		print_num(fp, 7, s->rx_crc_errors);
 		print_num(fp, 7, s->rx_frame_errors);
 		print_num(fp, 7, s->rx_fifo_errors);
 		print_num(fp, 7, s->rx_missed_errors);
+		if (slen > 23)
+			print_num(fp, 7, s->rx_nohandler);
 	}
 	fprintf(fp, "%s", _SL_);
 
@@ -590,12 +595,27 @@ static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
 
 static void __print_link_stats(FILE *fp, struct rtattr **tb)
 {
-	if (tb[IFLA_STATS64])
-		print_link_stats64(fp, RTA_DATA(tb[IFLA_STATS64]),
-					tb[IFLA_CARRIER_CHANGES]);
-	else if (tb[IFLA_STATS])
-		print_link_stats32(fp, RTA_DATA(tb[IFLA_STATS]),
-					tb[IFLA_CARRIER_CHANGES]);
+	const struct rtattr *carrier_changes = tb[IFLA_CARRIER_CHANGES];
+	unsigned slen;
+
+	if (tb[IFLA_STATS64]) {
+		struct rtnl_link_stats64 stats = { 0 };
+		slen = RTA_PAYLOAD(tb[IFLA_STATS64]) / sizeof(__u64);
+
+		memcpy(&stats, RTA_DATA(tb[IFLA_STATS64]),
+		       MIN(RTA_PAYLOAD(tb[IFLA_STATS64]), sizeof(stats)));
+
+		print_link_stats64(fp, &stats, carrier_changes, slen);
+	} else if (tb[IFLA_STATS]) {
+		struct rtnl_link_stats stats = { 0 };
+		slen = RTA_PAYLOAD(tb[IFLA_STATS]) / sizeof(__u32);
+
+		memcpy(&stats, RTA_DATA(tb[IFLA_STATS]),
+		       MIN(RTA_PAYLOAD(tb[IFLA_STATS]), sizeof(stats)));
+
+		print_link_stats32(fp, &stats, carrier_changes, slen);
+	}
+
 }
 
 static void print_link_stats(FILE *fp, struct nlmsghdr *n)

-- 
Jarod Wilson
jarod@redhat.com
