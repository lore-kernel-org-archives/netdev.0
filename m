From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v4 4/4] ip link: proto_down config and display.
Date: Wed,  8 Jul 2015 14:04:25 -0700
Message-ID: <1436389465-3077-5-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33040 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623AbbGHVEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:04:44 -0400
Received: by pacws9 with SMTP id ws9so139186964pac.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 14:04:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

This patch adds support to set and display the IF_PROTOF_DOWN proto_flag.
One example user space application setting this flag is a multi-chassis
LAG application to handle split-brain situation on peer-link failure.

Example:
root@net-next:~# ip link set eth1 protodown on
root@net-next:~# ip link show eth1
4: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 1000 proto_flags <DOWN>
    link/ether 52:54:00:12:35:01 brd ff:ff:ff:ff:ff:ff
root@net-next:~# ip link set eth1 protodown off
root@net-next:~# ip link show eth1
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:12:35:01 brd ff:ff:ff:ff:ff:ff
root@net-next:~#

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 include/linux/if.h      |    6 ++++++
 include/linux/if_link.h |   12 ++++++++++++
 ip/ipaddress.c          |   27 +++++++++++++++++++++++++++
 ip/iplink.c             |   18 ++++++++++++++++++
 man/man8/ip-link.8.in   |    8 ++++++++
 5 files changed, 71 insertions(+)

diff --git a/include/linux/if.h b/include/linux/if.h
index a55a9e0..97f53d8 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -156,6 +156,12 @@ enum {
 	IF_LINK_MODE_DORMANT,	/* limit upward transition to dormant */
 };
 
+/* proto_flags - port state information can be passed to the switch driver and
+ * used to determine the phys state of the switch port */
+enum {
+	IF_PROTOF_DOWN		= 1<<0	/* set switch port phys state down */
+};
+
 /*
  *	Device mapping structure. I'd just gone off and designed a 
  *	beautiful scheme using only loadable modules with arguments
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 3d0d613..1d07f3f 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -148,6 +148,7 @@ enum {
 	IFLA_PHYS_SWITCH_ID,
 	IFLA_LINK_NETNSID,
 	IFLA_PHYS_PORT_NAME,
+	IFLA_PROTO_FLAGS_INFO,
 	__IFLA_MAX
 };
 
@@ -620,4 +621,15 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+
+/* proto_flags section */
+enum {
+	IFLA_PROTO_FLAGS_UNSPEC,
+	IFLA_PROTO_FLAGS_VAL,
+	IFLA_PROTO_FLAGS_CHANGE,
+	__IFLA_PROTO_FLAGS_MAX,
+};
+
+#define IFLA_PROTO_FLAGS_MAX (__IFLA_PROTO_FLAGS_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 340e1c9..4078023 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -556,6 +556,30 @@ static void print_link_stats(FILE *fp, struct nlmsghdr *n)
 	fprintf(fp, "%s", _SL_);
 }
 
+static void print_proto_flags(FILE *fp, struct rtattr *tb)
+{
+	struct rtattr *proto_info[IFLA_INFO_MAX+1];
+	uint32_t proto_flags;
+
+	parse_rtattr_nested(proto_info, IFLA_PROTO_FLAGS_MAX, tb);
+
+	if (proto_info[IFLA_PROTO_FLAGS_VAL]) {
+		proto_flags = *(uint32_t *)RTA_DATA(
+				proto_info[IFLA_PROTO_FLAGS_VAL]);
+		if (proto_flags) {
+			fprintf(fp, " proto_flags <");
+#define _PROTOF(f) if (proto_flags & IF_PROTOF_##f) { \
+		      proto_flags &= ~IF_PROTOF_##f ; \
+		      fprintf(fp, #f "%s", proto_flags ? "," : ""); }
+			_PROTOF(DOWN);
+#undef _PROTOF
+			if (proto_flags)
+				fprintf(fp, "%x", proto_flags);
+			fprintf(fp, "> ");
+		}
+	}
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -669,6 +693,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (filter.showqueue)
 		print_queuelen(fp, tb);
 
+	if (tb[IFLA_PROTO_FLAGS_INFO])
+		print_proto_flags(fp, tb[IFLA_PROTO_FLAGS_INFO]);
+
 	if (!filter.family || filter.family == AF_PACKET || show_details) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "%s", _SL_);
diff --git a/ip/iplink.c b/ip/iplink.c
index a4a4980..29cb8ce 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -611,6 +611,24 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				invarg("Invalid \"link-netnsid\" value\n", *argv);
 			addattr32(&req->n, sizeof(*req), IFLA_LINK_NETNSID,
 				  link_netnsid);
+		} else if (strcmp(*argv, "protodown") == 0) {
+			struct rtattr *proto_info;
+			unsigned int proto_flags = 0;
+
+			NEXT_ARG();
+			if (strcmp(*argv, "on") == 0)
+				proto_flags |= IF_PROTOF_DOWN;
+			else if (strcmp(*argv, "off") != 0)
+				return on_off("protodown", *argv);
+			proto_info = addattr_nest(&req->n,
+						  sizeof(*req),
+						  IFLA_PROTO_FLAGS_INFO);
+			addattr32(&req->n, sizeof(*req),
+				  IFLA_PROTO_FLAGS_VAL, proto_flags);
+			addattr32(&req->n, sizeof(*req),
+				  IFLA_PROTO_FLAGS_CHANGE, IF_PROTOF_DOWN);
+
+			addattr_nest_end(&req->n, proto_info);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 714aab4..479f652 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -100,6 +100,8 @@ ip-link \- network device configuration
 .br
 .BR multicast " { " on " | " off " } |"
 .br
+.BR protodown " { " on " | " off " } |"
+.br
 .B  txqueuelen
 .IR PACKETS " |"
 .br
@@ -645,6 +647,12 @@ change the
 flag on the device.
 
 .TP
+.BR "protodown on " or " protodown off"
+change the
+.B PROTODOWN
+proto_flag on the device.
+
+.TP
 .BR "dynamic on " or " dynamic off"
 change the
 .B DYNAMIC
-- 
1.7.10.4
