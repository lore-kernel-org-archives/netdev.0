From: Stefan Gula <steweg@ynet.sk>
Subject: [patch v3, iproute2 version 3.2.0] Source mode for macvlan
 interface
Date: Mon, 30 Jan 2012 14:14:00 +0100 (CET)
Message-ID: <10839102.1251327929240954.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-meo-dmt.ynet.sk ([147.175.167.220]:56150 "EHLO
	5-meo-dmt.ynet.sk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab2A3NR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 08:17:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Gula <steweg@gmail.com>

Adjusting iproute2 utility to support new macvlan link type mode
called "source". Example of commands that can be applied:
 ip link add link eth0 name macvlan0 type macvlan mode source
 ip link set link macvlan0 type macvlan macaddr add 00:11:11:11:11:11
 ip link set link macvlan0 type macvlan macaddr del 00:11:11:11:11:11
 ip link set link macvlan0 type macvlan macaddr flush

Signed-off-by: Stefan Gula <steweg@gmail.com>

---

V2 changes: - removed more bogus lines from if_link.h not related to this patch

diff -uprN iproute2-3.2.0/Config iproute2-3.2.0-my/Config
--- iproute2-3.2.0/Config	1970-01-01 00:00:00.000000000 +0000
+++ iproute2-3.2.0-my/Config	2012-01-27 14:31:53.000000000 +0000
@@ -0,0 +1,3 @@
+# Generated config based on /usr/src/iproute2-3.2.0/include
+TC_CONFIG_XT_OLD_H:=y
+IPT_LIB_DIR:=/lib/xtables
diff -uprN iproute2-3.2.0/include/linux/if_link.h iproute2-3.2.0-my/include/linux/if_link.h
--- iproute2-3.2.0/include/linux/if_link.h	2012-01-05 16:34:31.000000000 +0000
+++ iproute2-3.2.0-my/include/linux/if_link.h	2012-01-30 13:15:40.000000000 +0000
@@ -250,6 +250,9 @@ struct ifla_vlan_qos_mapping {
 enum {
 	IFLA_MACVLAN_UNSPEC,
 	IFLA_MACVLAN_MODE,
+	IFLA_MACVLAN_MACADDR_MODE,
+	IFLA_MACVLAN_MACADDR,
+	IFLA_MACVLAN_MACADDR_DATA,
 	__IFLA_MACVLAN_MAX,
 };
 
@@ -260,6 +263,13 @@ enum macvlan_mode {
 	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
 	MACVLAN_MODE_PASSTHRU = 8,/* take over the underlying device */
+	MACVLAN_MODE_SOURCE  = 16,/* use source MAC address list to assign */
+};
+
+enum macvlan_macaddr_mode {
+	MACVLAN_MACADDR_ADD,
+	MACVLAN_MACADDR_DEL,
+	MACVLAN_MACADDR_FLUSH,
 };
 
 /* SR-IOV virtual function management section */
diff -uprN iproute2-3.2.0/ip/iplink_macvlan.c iproute2-3.2.0-my/ip/iplink_macvlan.c
--- iproute2-3.2.0/ip/iplink_macvlan.c	2012-01-05 16:34:31.000000000 +0000
+++ iproute2-3.2.0-my/ip/iplink_macvlan.c	2012-01-30 12:57:19.000000000 +0000
@@ -22,15 +22,16 @@
 
 static void explain(void)
 {
-	fprintf(stderr,
-		"Usage: ... macvlan mode { private | vepa | bridge | passthru }\n"
-	);
+	fprintf(stderr, "Usage: ... macvlan mode MODE MODE_OPTS\n"
+		"MODE: private | vepa | bridge | passthru | source\n"
+		"MODE_OPTS: for mode \"source\":\n"
+		"\tmacaddr { add <macaddr> | del <macaddr> | flush }\n");
 }
 
 static int mode_arg(void)
 {
         fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
-		"\"vepa\", \"bridge\" or \"passthru\" \n");
+		"\"vepa\", \"bridge\", \"passthru\" or \"source\"\n");
         return -1;
 }
 
@@ -50,10 +51,40 @@ static int macvlan_parse_opt(struct link
 				mode = MACVLAN_MODE_BRIDGE;
 			else if (strcmp(*argv, "passthru") == 0)
 				mode = MACVLAN_MODE_PASSTHRU;
+			else if (strcmp(*argv, "source") == 0)
+				mode = MACVLAN_MODE_SOURCE;
 			else
 				return mode_arg();
 
 			addattr32(n, 1024, IFLA_MACVLAN_MODE, mode);
+		} else if (matches(*argv, "macaddr") == 0) {
+			int len;
+			__u32 mac_mode = 0;
+			char abuf[32];
+
+			NEXT_ARG();
+
+			if (strcmp(*argv, "add") == 0) {
+				mac_mode = MACVLAN_MACADDR_ADD;
+			} else if (strcmp(*argv, "del") == 0) {
+				mac_mode = MACVLAN_MACADDR_DEL;
+			} else if (strcmp(*argv, "flush") == 0) {
+				mac_mode = MACVLAN_MACADDR_FLUSH;
+			} else {
+				explain();
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_MACVLAN_MACADDR_MODE, mac_mode);
+
+			if (mac_mode != MACVLAN_MACADDR_FLUSH) {
+				NEXT_ARG();
+
+				len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+				if (len < 0)
+					return -1;
+				addattr_l(n, 1024, IFLA_MACVLAN_MACADDR, abuf,
+					  len);
+			}
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -85,6 +116,7 @@ static void macvlan_print_opt(struct lin
 		: mode == MACVLAN_MODE_VEPA    ? "vepa"
 		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
 		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
+		: mode == MACVLAN_MODE_SOURCE  ? "source"
 		:				 "unknown");
 }
 
