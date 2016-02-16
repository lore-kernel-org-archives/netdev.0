From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 1/5] iplink: bridge_slave: export read-only values
Date: Tue, 16 Feb 2016 16:08:51 +0100
Message-ID: <1455635335-9973-2-git-send-email-razor@blackwall.org>
References: <1455635335-9973-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34450 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932234AbcBPPJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 10:09:31 -0500
Received: by mail-wm0-f42.google.com with SMTP id b205so114323650wmb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 07:09:31 -0800 (PST)
In-Reply-To: <1455635335-9973-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Export all the read-only values that get returned about a bridge port
such as the timers, the ids, designated_port and cost,
topology_change_ack and config_pending. For the bridge ids the
br_dump_bridge_id function is exported from iplink_bridge.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/ip_common.h           |  2 ++
 ip/iplink_bridge.c       |  3 +--
 ip/iplink_bridge_slave.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 73 insertions(+), 2 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 9a846df348fe..815487a07b8a 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -87,6 +87,8 @@ struct link_util
 struct link_util *get_link_kind(const char *kind);
 struct link_util *get_link_slave_kind(const char *slave_kind);
 
+void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf, size_t len);
+
 #ifndef	INFINITY_LIFE_TIME
 #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
 #endif
diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 1b666f0adef4..79f15eff7c39 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -60,8 +60,7 @@ static void explain(void)
 	print_explain(stderr);
 }
 
-static void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf,
-			      size_t len)
+void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf, size_t len)
 {
 	char eaddr[32];
 
diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index 4593872ecd84..c58f55294261 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -98,6 +98,76 @@ static void bridge_slave_print_opt(struct link_util *lu, FILE *f,
 	if (tb[IFLA_BRPORT_UNICAST_FLOOD])
 		print_onoff(f, "flood",
 			rta_getattr_u8(tb[IFLA_BRPORT_UNICAST_FLOOD]));
+
+	if (tb[IFLA_BRPORT_ID])
+		fprintf(f, "port_id 0x%x ",
+			rta_getattr_u16(tb[IFLA_BRPORT_ID]));
+
+	if (tb[IFLA_BRPORT_NO])
+		fprintf(f, "port_no 0x%x ",
+			rta_getattr_u16(tb[IFLA_BRPORT_NO]));
+
+	if (tb[IFLA_BRPORT_DESIGNATED_PORT])
+		fprintf(f, "designated_port %u ",
+			rta_getattr_u16(tb[IFLA_BRPORT_DESIGNATED_PORT]));
+
+	if (tb[IFLA_BRPORT_DESIGNATED_COST])
+		fprintf(f, "designated_cost %u ",
+			rta_getattr_u16(tb[IFLA_BRPORT_DESIGNATED_COST]));
+
+	if (tb[IFLA_BRPORT_BRIDGE_ID]) {
+		char bridge_id[32];
+
+		br_dump_bridge_id(RTA_DATA(tb[IFLA_BRPORT_BRIDGE_ID]),
+				  bridge_id, sizeof(bridge_id));
+		fprintf(f, "designated_bridge %s ", bridge_id);
+	}
+
+	if (tb[IFLA_BRPORT_ROOT_ID]) {
+		char root_id[32];
+
+		br_dump_bridge_id(RTA_DATA(tb[IFLA_BRPORT_ROOT_ID]),
+				  root_id, sizeof(root_id));
+		fprintf(f, "designated_root %s ", root_id);
+	}
+
+	if (tb[IFLA_BRPORT_HOLD_TIMER]) {
+		struct timeval tv;
+		__u64 htimer;
+
+		htimer = rta_getattr_u64(tb[IFLA_BRPORT_HOLD_TIMER]);
+		__jiffies_to_tv(&tv, htimer);
+		fprintf(f, "hold_timer %4i.%.2i ", (int)tv.tv_sec,
+			(int)tv.tv_usec/10000);
+	}
+
+	if (tb[IFLA_BRPORT_MESSAGE_AGE_TIMER]) {
+		struct timeval tv;
+		__u64 agetimer;
+
+		agetimer = rta_getattr_u64(tb[IFLA_BRPORT_MESSAGE_AGE_TIMER]);
+		__jiffies_to_tv(&tv, agetimer);
+		fprintf(f, "message_age_timer %4i.%.2i ", (int)tv.tv_sec,
+			(int)tv.tv_usec/10000);
+	}
+
+	if (tb[IFLA_BRPORT_FORWARD_DELAY_TIMER]) {
+		struct timeval tv;
+		__u64 fwdtimer;
+
+		fwdtimer = rta_getattr_u64(tb[IFLA_BRPORT_FORWARD_DELAY_TIMER]);
+		__jiffies_to_tv(&tv, fwdtimer);
+		fprintf(f, "forward_delay_timer %4i.%.2i ", (int)tv.tv_sec,
+			(int)tv.tv_usec/10000);
+	}
+
+	if (tb[IFLA_BRPORT_TOPOLOGY_CHANGE_ACK])
+		fprintf(f, "topology_change_ack %u ",
+			rta_getattr_u8(tb[IFLA_BRPORT_TOPOLOGY_CHANGE_ACK]));
+
+	if (tb[IFLA_BRPORT_CONFIG_PENDING])
+		fprintf(f, "config_pending %u ",
+			rta_getattr_u8(tb[IFLA_BRPORT_CONFIG_PENDING]));
 }
 
 static void bridge_slave_parse_on_off(char *arg_name, char *arg_val,
-- 
2.4.3
