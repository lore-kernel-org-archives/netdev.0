From: =?UTF-8?q?Remigiusz=20Ko=C5=82=C5=82=C4=85taj?=
        <remigiusz.kollataj@mobica.com>
Subject: [PATCH iproute2] ip: add handling for new CAN netlink interface
Date: Fri, 19 May 2017 14:54:49 +0200
Message-ID: <20170519125449.7214-1-remigiusz.kollataj@mobica.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: remigiusz.kollataj@mobica.com, linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34094 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754709AbdESMzn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 08:55:43 -0400
Received: by mail-lf0-f47.google.com with SMTP id 99so551201lfu.1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 05:55:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds handling for new CAN netlink interface introduced in
4.11 kernel:
- IFLA_CAN_TERMINATION,
- IFLA_CAN_TERMINATION_CONST,
- IFLA_CAN_BITRATE_CONST,
- IFLA_CAN_DATA_BITRATE_CONST

Output example:
$ip -d link show can0
6: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN mode DEFAULT group default qlen 10
    link/can  promiscuity 0
    can state STOPPED (berr-counter tx 0 rx 0) restart-ms 0
          bitrate 80000
             [   20000,    33333,    50000,    80000,    83333,   100000,
                125000,   150000,   175000,   200000,   225000,   250000,
                275000,   300000,   500000,   625000,   800000,  1000000 ]
          termination 0 [ 0, 120 ]
          clock 0numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535

Signed-off-by: Remigiusz Kołłątaj <remigiusz.kollataj@mobica.com>
---
 ip/iplink_can.c | 98 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 94 insertions(+), 4 deletions(-)

diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index 20d4d37d..5df56b2b 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -41,6 +41,8 @@ static void print_usage(FILE *f)
 		"\t[ restart-ms TIME-MS ]\n"
 		"\t[ restart ]\n"
 		"\n"
+		"\t[ termination { 0..65535 } ]\n"
+		"\n"
 		"\tWhere: BITRATE	:= { 1..1000000 }\n"
 		"\t	  SAMPLE-POINT	:= { 0.000..0.999 }\n"
 		"\t	  TQ		:= { NUMBER }\n"
@@ -220,6 +222,14 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (get_u32(&val, *argv, 0))
 				invarg("invalid \"restart-ms\" value\n", *argv);
 			addattr32(n, 1024, IFLA_CAN_RESTART_MS, val);
+		} else if (matches(*argv, "termination") == 0) {
+			__u16 val;
+
+			NEXT_ARG();
+			if (get_u16(&val, *argv, 0))
+				invarg("invalid \"termination\" value\n",
+				       *argv);
+			addattr16(n, 1024, IFLA_CAN_TERMINATION, val);
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 			return -1;
@@ -282,7 +292,8 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fprintf(f, "restart-ms %d ", *restart_ms);
 	}
 
-	if (tb[IFLA_CAN_BITTIMING]) {
+	/* bittiming is irrelevant if fixed bitrate is defined */
+	if (tb[IFLA_CAN_BITTIMING] && !tb[IFLA_CAN_BITRATE_CONST]) {
 		struct can_bittiming *bt = RTA_DATA(tb[IFLA_CAN_BITTIMING]);
 
 		fprintf(f, "\n	  bitrate %d sample-point %.3f ",
@@ -292,7 +303,8 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			bt->sjw);
 	}
 
-	if (tb[IFLA_CAN_BITTIMING_CONST]) {
+	/* bittiming const is irrelevant if fixed bitrate is defined */
+	if (tb[IFLA_CAN_BITTIMING_CONST] && !tb[IFLA_CAN_BITRATE_CONST]) {
 		struct can_bittiming_const *btc =
 			RTA_DATA(tb[IFLA_CAN_BITTIMING_CONST]);
 
@@ -303,7 +315,37 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			btc->brp_min, btc->brp_max, btc->brp_inc);
 	}
 
-	if (tb[IFLA_CAN_DATA_BITTIMING]) {
+	if (tb[IFLA_CAN_BITRATE_CONST]) {
+		__u32 *bitrate_const = RTA_DATA(tb[IFLA_CAN_BITRATE_CONST]);
+		int bitrate_cnt = RTA_PAYLOAD(tb[IFLA_CAN_BITRATE_CONST]) /
+				  sizeof(*bitrate_const);
+		int i;
+		__u32 bitrate = 0;
+
+		if (tb[IFLA_CAN_BITTIMING]) {
+			struct can_bittiming *bt =
+			    RTA_DATA(tb[IFLA_CAN_BITTIMING]);
+			bitrate = bt->bitrate;
+		}
+
+		fprintf(f, "\n	  bitrate %u", bitrate);
+		fprintf(f, "\n	     [");
+
+		for (i = 0; i < bitrate_cnt - 1; ++i) {
+			/* This will keep lines below 80 signs */
+			if (!(i % 6) && i)
+				fprintf(f, "\n	      ");
+
+			fprintf(f, "%8u, ", bitrate_const[i]);
+		}
+
+		if (!(i % 6) && i)
+			fprintf(f, "\n	      ");
+		fprintf(f, "%8u ]", bitrate_const[i]);
+	}
+
+	/* data bittiming is irrelevant if fixed bitrate is defined */
+	if (tb[IFLA_CAN_DATA_BITTIMING] && !tb[IFLA_CAN_DATA_BITRATE_CONST]) {
 		struct can_bittiming *dbt =
 			RTA_DATA(tb[IFLA_CAN_DATA_BITTIMING]);
 
@@ -315,7 +357,9 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			dbt->phase_seg2, dbt->sjw);
 	}
 
-	if (tb[IFLA_CAN_DATA_BITTIMING_CONST]) {
+	/* data bittiming const is irrelevant if fixed bitrate is defined */
+	if (tb[IFLA_CAN_DATA_BITTIMING_CONST] &&
+	    !tb[IFLA_CAN_DATA_BITRATE_CONST]) {
 		struct can_bittiming_const *dbtc =
 			RTA_DATA(tb[IFLA_CAN_DATA_BITTIMING_CONST]);
 
@@ -326,6 +370,52 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			dbtc->brp_min, dbtc->brp_max, dbtc->brp_inc);
 	}
 
+	if (tb[IFLA_CAN_DATA_BITRATE_CONST]) {
+		__u32 *dbitrate_const =
+		    RTA_DATA(tb[IFLA_CAN_DATA_BITRATE_CONST]);
+		int dbitrate_cnt =
+		    RTA_PAYLOAD(tb[IFLA_CAN_DATA_BITRATE_CONST]) /
+		    sizeof(*dbitrate_const);
+		int i;
+		__u32 dbitrate = 0;
+
+		if (tb[IFLA_CAN_DATA_BITTIMING]) {
+			struct can_bittiming *dbt =
+			    RTA_DATA(tb[IFLA_CAN_DATA_BITTIMING]);
+			dbitrate = dbt->bitrate;
+		}
+
+		fprintf(f, "\n	  dbitrate %u", dbitrate);
+		fprintf(f, "\n	     [");
+
+		for (i = 0; i < dbitrate_cnt - 1; ++i) {
+			/* This will keep lines below 80 signs */
+			if (!(i % 6) && i)
+				fprintf(f, "\n	      ");
+
+			fprintf(f, "%8u, ", dbitrate_const[i]);
+		}
+
+		if (!(i % 6) && i)
+			fprintf(f, "\n	      ");
+		fprintf(f, "%8u ]", dbitrate_const[i]);
+	}
+
+	if (tb[IFLA_CAN_TERMINATION_CONST] && tb[IFLA_CAN_TERMINATION]) {
+		__u16 *trm = RTA_DATA(tb[IFLA_CAN_TERMINATION]);
+		__u16 *trm_const = RTA_DATA(tb[IFLA_CAN_TERMINATION_CONST]);
+		int trm_cnt = RTA_PAYLOAD(tb[IFLA_CAN_TERMINATION_CONST]) /
+			      sizeof(*trm_const);
+		int i;
+
+		fprintf(f, "\n	  termination %hu [ ", *trm);
+
+		for (i = 0; i < trm_cnt - 1; ++i)
+			fprintf(f, "%hu, ", trm_const[i]);
+
+		fprintf(f, "%hu ]", trm_const[i]);
+	}
+
 	if (tb[IFLA_CAN_CLOCK]) {
 		struct can_clock *clock = RTA_DATA(tb[IFLA_CAN_CLOCK]);
 
-- 
2.13.0
