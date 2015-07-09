From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v5 4/4] ip link: proto_down config and display.
Date: Thu,  9 Jul 2015 15:35:30 -0700
Message-ID: <1436481330-4599-5-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35299 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbbGIWfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 18:35:44 -0400
Received: by pactm7 with SMTP id tm7so157314162pac.2
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 15:35:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

This patch adds support to set and display the IF_PROTOF_DOWN proto_flag.
One example user space application setting this flag is a multi-chassis
LAG application to handle split-brain situation on peer-link failure.

Example:
root@net-next:~# ip link set eth1 protodown on
root@net-next:~/iproute2# ip link show eth1
4: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:12:35:01 brd ff:ff:ff:ff:ff:ff protodown on
root@net-next:~/iproute2# ip link set eth1 protodown off
root@net-next:~/iproute2# ip link show eth1
4: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:12:35:01 brd ff:ff:ff:ff:ff:ff
root@net-next:~/iproute2#
---
 include/linux/if.h      |    6 ++++++
 include/linux/if_link.h |   12 ++++++++++++
 ip/ipaddress.c          |   19 +++++++++++++++++++
 ip/iplink.c             |   19 +++++++++++++++++++
 man/man8/ip-link.8.in   |    8 ++++++++
 5 files changed, 64 insertions(+)

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
index 8df6a84..f6e26ae 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -148,6 +148,7 @@ enum {
 	IFLA_PHYS_SWITCH_ID,
 	IFLA_LINK_NETNSID,
 	IFLA_PHYS_PORT_NAME,
+	IFLA_PROTO_FLAGS_INFO,
 	__IFLA_MAX
 };
 
@@ -649,4 +650,15 @@ enum {
 
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
index 85a81ba..78c473a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -590,6 +590,22 @@ static void print_link_stats(FILE *fp, struct nlmsghdr *n)
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
+		if (proto_flags & IF_PROTOF_DOWN) {
+			fprintf(fp, " protodown on");
+		}
+	}
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -736,6 +752,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			fprintf(fp, " link-netnsid unknown");
 	}
 
+	if (tb[IFLA_PROTO_FLAGS_INFO])
+		print_proto_flags(fp, tb[IFLA_PROTO_FLAGS_INFO]);
+
 	if (tb[IFLA_PROMISCUITY] && show_details)
 		fprintf(fp, " promiscuity %u ",
 			*(int*)RTA_DATA(tb[IFLA_PROMISCUITY]));
diff --git a/ip/iplink.c b/ip/iplink.c
index e296e6f..3471ca9 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -85,6 +85,7 @@ void iplink_usage(void)
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
 	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
+	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type TYPE]\n");
 
 	if (iplink_have_newlink()) {
@@ -612,6 +613,24 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
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
index 372e6c6..f35f6df 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -101,6 +101,8 @@ ip-link \- network device configuration
 .br
 .BR multicast " { " on " | " off " } |"
 .br
+.BR protodown " { " on " | " off " } |"
+.br
 .B  txqueuelen
 .IR PACKETS " |"
 .br
@@ -682,6 +684,12 @@ change the
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
