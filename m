From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH] iproute2: netlink support for bus-error reporting and counters
Date: Tue, 23 Feb 2010 09:24:55 +0100
Message-ID: <4B8390D7.5010409@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:36357 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380Ab0BWI0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 03:26:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses the new features of the kernel's netlink CAN interface
making the bus-error reporting configurable and allowing to retrieve
the CAN TX and RX bus error counters via netlink interface. Here is the
output of my test session showing how to use them:

# ip link set can0 up type can bitrate 500000 berr-reporting on
# ip -d -s link show can0
2: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
    link/can
    can <BERR-REPORTING> state ERROR-PASSIVE (berr-counter tx 128 rx 0) restart-ms 0
                              CAN bus error counter values ^^^^^^^^^^^
    bitrate 500000 sample-point 0.875
    tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
    sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
    clock 8000000
    re-started bus-errors arbit-lost error-warn error-pass bus-off
    0          54101      0          1          1          0
    RX: bytes  packets  errors  dropped overrun mcast
    432808     54101    54101   0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    0          0        0       0       0       0

# ifconfig can0 down
# ip link set can0 up type can berr-reporting off
# candump -t d any,0:0,#FFFFFFFF
 (0.000000)  can0  20000004  [8] 00 08 00 00 00 00 60 00   ERRORFRAME
 (0.000474)  can0  20000004  [8] 00 20 00 00 00 00 80 00   ERRORFRAME
                                                   ^^ ^^
						    \  \___ rxerr
						     \_____ txerr

Furthermore, the missing support for one-shot mode has been added.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

---
diff --git a/include/linux/can/netlink.h b/include/linux/can/netlink.h
index 9ecbb78..3250de9 100644
--- a/include/linux/can/netlink.h
+++ b/include/linux/can/netlink.h
@@ -70,6 +70,14 @@ enum can_state {
 };
 
 /*
+ * CAN bus error counters
+ */
+struct can_berr_counter {
+	__u16 txerr;
+	__u16 rxerr;
+};
+
+/*
  * CAN controller mode
  */
 struct can_ctrlmode {
@@ -77,9 +85,11 @@ struct can_ctrlmode {
 	__u32 flags;
 };
 
-#define CAN_CTRLMODE_LOOPBACK	0x1	/* Loopback mode */
-#define CAN_CTRLMODE_LISTENONLY	0x2 	/* Listen-only mode */
-#define CAN_CTRLMODE_3_SAMPLES	0x4	/* Triple sampling mode */
+#define CAN_CTRLMODE_LOOPBACK		0x01	/* Loopback mode */
+#define CAN_CTRLMODE_LISTENONLY		0x02 	/* Listen-only mode */
+#define CAN_CTRLMODE_3_SAMPLES		0x04	/* Triple sampling mode */
+#define CAN_CTRLMODE_ONE_SHOT		0x08	/* One-Shot mode */
+#define CAN_CTRLMODE_BERR_REPORTING	0x10	/* Bus-error reporting */
 
 /*
  * CAN device statistics
@@ -105,6 +115,7 @@ enum {
 	IFLA_CAN_CTRLMODE,
 	IFLA_CAN_RESTART_MS,
 	IFLA_CAN_RESTART,
+	IFLA_CAN_BERR_COUNTER,
 	__IFLA_CAN_MAX
 };
 
diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index 50221e1..c8af4bc 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -30,6 +30,8 @@ static void usage(void)
 	        "\t[ loopback { on | off } ]\n"
 	        "\t[ listen-only { on | off } ]\n"
 	        "\t[ triple-sampling { on | off } ]\n"
+	        "\t[ one-shot { on | off } ]\n"
+	        "\t[ berr-reporting { on | off } ]\n"
 		"\n"
 	        "\t[ restart-ms TIME-MS ]\n"
 	        "\t[ restart ]\n"
@@ -84,6 +86,8 @@ static void print_ctrlmode(FILE *f, __u32 cm)
 	_PF(CAN_CTRLMODE_LOOPBACK, "LOOPBACK");
 	_PF(CAN_CTRLMODE_LISTENONLY, "LISTEN-ONLY");
 	_PF(CAN_CTRLMODE_3_SAMPLES, "TRIPLE-SAMPLING");
+	_PF(CAN_CTRLMODE_ONE_SHOT, "ONE-SHOT");
+	_PF(CAN_CTRLMODE_BERR_REPORTING, "BERR-REPORTING");
 #undef _PF
 	if (cm)
 		fprintf(f, "%x", cm);
@@ -142,6 +146,14 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			set_ctrlmode("triple-sampling", *argv, &cm,
 				     CAN_CTRLMODE_3_SAMPLES);
+		} else if (matches(*argv, "one-shot") == 0) {
+			NEXT_ARG();
+			set_ctrlmode("one-shot", *argv, &cm,
+				     CAN_CTRLMODE_ONE_SHOT);
+		} else if (matches(*argv, "berr-reporting") == 0) {
+			NEXT_ARG();
+			set_ctrlmode("berr-reporting", *argv, &cm,
+				     CAN_CTRLMODE_BERR_REPORTING);
 		} else if (matches(*argv, "restart") == 0) {
 			__u32 val = 1;
 
@@ -200,6 +212,13 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			can_state_names[*state] : "UNKNOWN");
 	}
 
+	if (tb[IFLA_CAN_BERR_COUNTER]) {
+		struct can_berr_counter *bc =
+			RTA_DATA(tb[IFLA_CAN_BERR_COUNTER]);
+
+		fprintf(f, "(berr-counter tx %d rx %d) ", bc->txerr, bc->rxerr);
+	}
+
 	if (tb[IFLA_CAN_RESTART_MS]) {
 		__u32 *restart_ms = RTA_DATA(tb[IFLA_CAN_RESTART_MS]);
 
