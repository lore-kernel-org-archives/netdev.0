From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH iproute2] Add more supoprt for bonding netlink attributes
Date: Thu, 07 Nov 2013 02:36:09 -0800
Message-ID: <20131107103609.27546.20194.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38585 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631Ab3KGKgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 05:36:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add get/set support for the following bonding attributes:

miimon
updelay
downdelay
use_carrier
arp_interval
arp_ip_target
arp_validate
arp_all_targets

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 include/linux/if_link.h |    8 +++
 ip/iplink_bond.c        |  134 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 140 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index a485920..69e0353 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -329,6 +329,14 @@ enum {
 	IFLA_BOND_UNSPEC,
 	IFLA_BOND_MODE,
 	IFLA_BOND_ACTIVE_SLAVE,
+        IFLA_BOND_MIIMON,
+        IFLA_BOND_UPDELAY,
+        IFLA_BOND_DOWNDELAY,
+        IFLA_BOND_USE_CARRIER,
+        IFLA_BOND_ARP_INTERVAL,
+        IFLA_BOND_ARP_IP_TARGET,
+        IFLA_BOND_ARP_VALIDATE,
+        IFLA_BOND_ARP_ALL_TARGETS,
 	__IFLA_BOND_MAX,
 };
 
diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index 3fb7f4f..9ca6bdb 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -7,6 +7,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Authors:     Jiri Pirko <jiri@resnulli.us>
+ *              Scott Feldman <sfeldma@cumulusnetworks.com>
  */
 
 #include <stdio.h>
@@ -19,11 +20,19 @@
 #include "utils.h"
 #include "ip_common.h"
 
+#define BOND_MAX_ARP_TARGETS    16
+
 static void explain(void)
 {
 	fprintf(stderr,
 		"Usage: ... bond [ mode BONDMODE ] [ active_slave SLAVE_DEV ]\n"
-		"                [ clear_active_slave ]\n"
+		"                [ clear_active_slave ] [ miimon MIIMON ]\n"
+		"                [ updelay UPDELAY ] [ downdelay DOWNDELAY ]\n"
+		"                [ use_carrier USE_CARRIER ]\n"
+		"                [ arp_interval ARP_INTERVAL ]\n"
+		"                [ arp_validate ARP_VALIDATE ]\n"
+		"                [ arp_all_targets ARP_ALL_TARGETS ]\n"
+		"                [ arp_ip_target [ ARP_IP_TARGET, ... ] ]\n"
 		"\n"
 		"BONDMODE := 0-6\n"
 	);
@@ -32,7 +41,9 @@ static void explain(void)
 static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
-	__u8 mode;
+	__u8 mode, use_carrier;
+	__u32 miimon, updelay, downdelay, arp_interval, arp_validate;
+	__u32 arp_all_targets;
 	unsigned ifindex;
 
 	while (argc > 0) {
@@ -51,6 +62,72 @@ static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
 			addattr32(n, 1024, IFLA_BOND_ACTIVE_SLAVE, ifindex);
 		} else if (matches(*argv, "clear_active_slave") == 0) {
 			addattr32(n, 1024, IFLA_BOND_ACTIVE_SLAVE, 0);
+		} else if (matches(*argv, "miimon") == 0) {
+			NEXT_ARG();
+			if (get_u32(&miimon, *argv, 0)) {
+				invarg("miimon %s is invalid", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BOND_MIIMON, miimon);
+		} else if (matches(*argv, "updelay") == 0) {
+			NEXT_ARG();
+			if (get_u32(&updelay, *argv, 0)) {
+				invarg("updelay %s is invalid", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BOND_UPDELAY, updelay);
+		} else if (matches(*argv, "downdelay") == 0) {
+			NEXT_ARG();
+			if (get_u32(&downdelay, *argv, 0)) {
+				invarg("downdelay %s is invalid", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BOND_DOWNDELAY, downdelay);
+		} else if (matches(*argv, "use_carrier") == 0) {
+			NEXT_ARG();
+			if (get_u8(&use_carrier, *argv, 0)) {
+				invarg("use_carrier %s is invalid", *argv);
+				return -1;
+			}
+			addattr8(n, 1024, IFLA_BOND_USE_CARRIER, use_carrier);
+		} else if (matches(*argv, "arp_interval") == 0) {
+			NEXT_ARG();
+			if (get_u32(&arp_interval, *argv, 0)) {
+				invarg("arp_interval %s is invalid", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BOND_ARP_INTERVAL, arp_interval);
+		} else if (matches(*argv, "arp_ip_target") == 0) {
+			struct rtattr * nest = addattr_nest(n, 1024,
+				IFLA_BOND_ARP_IP_TARGET);
+			if (NEXT_ARG_OK()) {
+				NEXT_ARG();
+				char *targets = strdupa(*argv);
+				char *target = strtok(targets, ",");
+				int i;
+
+				for(i = 0; target && i < BOND_MAX_ARP_TARGETS; i++) {
+					__u32 addr = get_addr32(target);
+					addattr32(n, 1024, i, addr);
+					target = strtok(NULL, ",");
+				}
+				addattr_nest_end(n, nest);
+			}
+			addattr_nest_end(n, nest);
+		} else if (matches(*argv, "arp_validate") == 0) {
+			NEXT_ARG();
+			if (get_u32(&arp_validate, *argv, 0)) {
+				invarg("arp_validate %s is invalid", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BOND_ARP_VALIDATE, arp_validate);
+		} else if (matches(*argv, "arp_all_targets") == 0) {
+			NEXT_ARG();
+			if (get_u32(&arp_all_targets, *argv, 0)) {
+				invarg("arp_all_targets %s is invalid", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BOND_ARP_ALL_TARGETS, arp_all_targets);
 		} else {
 			fprintf(stderr, "bond: unknown command \"%s\"?\n", *argv);
 			explain();
@@ -82,6 +159,59 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		else
 			fprintf(f, "active_slave %u ", ifindex);
 	}
+
+	if (tb[IFLA_BOND_MIIMON])
+		fprintf(f, "miimon %u ", rta_getattr_u32(tb[IFLA_BOND_MIIMON]));
+
+	if (tb[IFLA_BOND_UPDELAY])
+		fprintf(f, "updelay %u ", rta_getattr_u32(tb[IFLA_BOND_UPDELAY]));
+
+	if (tb[IFLA_BOND_DOWNDELAY])
+		fprintf(f, "downdelay %u ",
+			rta_getattr_u32(tb[IFLA_BOND_DOWNDELAY]));
+
+	if (tb[IFLA_BOND_USE_CARRIER])
+		fprintf(f, "use_carrier %u ",
+			rta_getattr_u8(tb[IFLA_BOND_USE_CARRIER]));
+
+	if (tb[IFLA_BOND_ARP_INTERVAL])
+		fprintf(f, "arp_interval %u ",
+			rta_getattr_u32(tb[IFLA_BOND_ARP_INTERVAL]));
+
+	if (tb[IFLA_BOND_ARP_IP_TARGET]) {
+		struct rtattr *iptb[BOND_MAX_ARP_TARGETS];
+		char buf[INET_ADDRSTRLEN];
+		int i;
+
+		parse_rtattr_nested(iptb, BOND_MAX_ARP_TARGETS,
+			tb[IFLA_BOND_ARP_IP_TARGET]);
+
+		if (iptb[0])
+			fprintf(f, "arp_ip_target ");
+
+		for (i = 0; i < BOND_MAX_ARP_TARGETS; i++) {
+			if (iptb[i])
+				fprintf(f, "%s",
+					rt_addr_n2a(AF_INET,
+						    RTA_PAYLOAD(iptb[i]),
+						    RTA_DATA(iptb[i]),
+						    buf,
+						    INET_ADDRSTRLEN));
+			if (i < BOND_MAX_ARP_TARGETS- 1 && iptb[i+1])
+				fprintf(f, ",");
+		}
+
+		if (iptb[0])
+			fprintf(f, " ");
+	}
+
+	if (tb[IFLA_BOND_ARP_VALIDATE])
+		fprintf(f, "arp_validate %u ",
+			rta_getattr_u32(tb[IFLA_BOND_ARP_VALIDATE]));
+
+	if (tb[IFLA_BOND_ARP_ALL_TARGETS])
+		fprintf(f, "arp_all_target %u ",
+			rta_getattr_u32(tb[IFLA_BOND_ARP_ALL_TARGETS]));
 }
 
 struct link_util bond_link_util = {
