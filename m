From: anuradhak@cumulusnetworks.com
Subject: [PATCH iproute2 3/3] ip link: Config and display device proto_down bits.
Date: Fri, 20 Mar 2015 08:11:58 -0700
Message-ID: <1426864318-25132-4-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33207 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbbCTPMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 11:12:10 -0400
Received: by pdnc3 with SMTP id c3so111458848pdn.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 08:12:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

This patch adds support to set the proto_down bits on netdevices. One
example user space application setting this flag is a STP userspace
daemon to implement BPDU guard functionality.

Example:
root@net-next:~# ip link set eth0 protodown stp on  
root@net-next:~# ip link show eth0
3: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP,PROTO_DOWN> mtu 1500 qdisc pfifo_fas
t state DOWN mode DEFAULT group default protodown <STP> qlen 1000
    link/ether 00:01:00:00:06:ee brd ff:ff:ff:ff:ff:ff
root@net-next:~# ip link set eth0 protodown stp off
root@net-next:~# ip link show eth0
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mo
de DEFAULT group default qlen 1000
    link/ether 00:01:00:00:06:ee brd ff:ff:ff:ff:ff:ff
root@net-next:~#

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 include/linux/if.h      |   29 +++++++++++++++++++++++++++-
 include/linux/if_link.h |    9 +++++++++
 ip/ipaddress.c          |   24 ++++++++++++++++++++++++
 ip/iplink.c             |   48 +++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-link.8.in   |   11 +++++++++++
 5 files changed, 120 insertions(+), 1 deletion(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index a55a9e0..4aabba6 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -66,6 +66,8 @@
  * @IFF_LOWER_UP: driver signals L1 up. Volatile.
  * @IFF_DORMANT: driver signals dormant. Volatile.
  * @IFF_ECHO: echo sent packets. Volatile.
+ * @IFF_PROTO_DOWN: protocol is down on the interface. Userspace can toggle
+ *	this by toggling the net_device proto_down bits. Volatile.
  */
 enum net_device_flags {
 	IFF_UP				= 1<<0,  /* sysfs */
@@ -87,6 +89,7 @@ enum net_device_flags {
 	IFF_LOWER_UP			= 1<<16, /* __volatile__ */
 	IFF_DORMANT			= 1<<17, /* __volatile__ */
 	IFF_ECHO			= 1<<18, /* __volatile__ */
+	IFF_PROTO_DOWN			= 1<<19, /* __volatile__ */
 };
 
 #define IFF_UP				IFF_UP
@@ -108,9 +111,11 @@ enum net_device_flags {
 #define IFF_LOWER_UP			IFF_LOWER_UP
 #define IFF_DORMANT			IFF_DORMANT
 #define IFF_ECHO			IFF_ECHO
+#define IFF_PROTO_DOWN			IFF_PROTO_DOWN
 
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_ECHO|\
-		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
+		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT|\
+		IFF_PROTO_DOWN)
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
@@ -156,6 +161,28 @@ enum {
 	IF_LINK_MODE_DORMANT,	/* limit upward transition to dormant */
 };
 
+/**
+ * enum net_device_proto_down - &struct net_device proto_down
+ *
+ * These are the &struct net_device proto_down bits and define a list of
+ * protocols that could hold the device in a IFF_PROTO_DOWN state. Setting of
+ * these bits is triggered by userspace. Userspace can query and set these
+ * flags using userspace utilities. There is also a sysfs entry available
+ * which can only be queried. The sysfs entries are available via
+ * /sys/class/net/<dev>/proto_down
+ *
+ *
+ * @IF_LINK_PROTO_DOWN_MLAG: proto_down by a multi-chassis LAG application.
+ * @IF_LINK_PROTO_DOWN_STP: proto_down by an STP application.
+ */
+enum net_device_proto_down {
+	IF_LINK_PROTO_DOWN_MLAG		= 1<<0,
+	IF_LINK_PROTO_DOWN_STP		= 1<<1,
+};
+
+#define IF_LINK_PROTO_DOWN_MLAG		IF_LINK_PROTO_DOWN_MLAG
+#define IF_LINK_PROTO_DOWN_STP		IF_LINK_PROTO_DOWN_STP
+
 /*
  *	Device mapping structure. I'd just gone off and designed a 
  *	beautiful scheme using only loadable modules with arguments
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 3450c3f..e9bfb73 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -80,6 +80,13 @@ struct rtnl_link_ifmap {
 	__u8	port;
 };
 
+/* link protodown */
+struct rtnl_link_protodown {
+	__u32	proto_down;		/* Bitmap of protocols that want
+					 * to hold the device down */
+	__u32	proto_down_change;	/* Change mask for proto_down */
+};
+
 /*
  * IFLA_AF_SPEC
  *   Contains nested attributes for address family specific attributes.
@@ -147,6 +154,8 @@ enum {
 	IFLA_CARRIER_CHANGES,
 	IFLA_PHYS_SWITCH_ID,
 	IFLA_LINK_NETNSID,
+	IFLA_LINKPROTODOWN,	/* Bitmap of protocols that want to
+				 * hold the device down */
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 99a6ab5..f750d0e 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -119,6 +119,7 @@ static void print_link_flags(FILE *fp, unsigned flags, unsigned mdown)
 	_PF(LOWER_UP);
 	_PF(DORMANT);
 	_PF(ECHO);
+	_PF(PROTO_DOWN);
 #undef _PF
 	if (flags)
 		fprintf(fp, "%x", flags);
@@ -203,6 +204,26 @@ static char *parse_link_kind(struct rtattr *tb)
 	return "";
 }
 
+static void print_linkprotodown(FILE *fp,
+		struct rtnl_link_protodown *link_proto_down)
+{
+	unsigned int proto_down = link_proto_down->proto_down;
+
+	if (!proto_down)
+		return;
+
+	fprintf(fp, "protodown <");
+#define _PDNF(f) if (proto_down&IF_LINK_PROTO_DOWN_##f) { \
+		     proto_down &= ~IF_LINK_PROTO_DOWN_##f ; \
+		     fprintf(fp, #f "%s", proto_down ? "," : ""); }
+	_PDNF(MLAG);
+	_PDNF(STP);
+#undef _PDNF
+	if (proto_down)
+		fprintf(fp, "%x", proto_down);
+	fprintf(fp, "> ");
+}
+
 static void print_linktype(FILE *fp, struct rtattr *tb)
 {
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
@@ -657,6 +678,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		fprintf(fp, "group %s ", rtnl_group_n2a(group, b1, sizeof(b1)));
 	}
 
+	if (do_link && tb[IFLA_LINKPROTODOWN])
+		print_linkprotodown(fp, RTA_DATA(tb[IFLA_LINKPROTODOWN]));
+
 	if (filter.showqueue)
 		print_queuelen(fp, tb);
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 5893ee4..f4a52c2 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -72,6 +72,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "	                  [ netns NAME ]\n");
+	fprintf(stderr, "	                  [ protodown PROTODOWNTYPE { on | off } ]\n");
 	fprintf(stderr, "                         [ link-netnsid ID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
@@ -94,6 +95,7 @@ void iplink_usage(void)
 		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n");
 		fprintf(stderr, "          bond_slave | ipvlan }\n");
 	}
+	fprintf(stderr, "PROTODOWNTYPE := { mlag | stp }\n");
 	exit(-1);
 }
 
@@ -175,6 +177,30 @@ static int get_addr_gen_mode(const char *mode)
 	return -1;
 }
 
+static int get_link_proto_down_type(const char *type)
+{
+	if (matches(type, "mlag") == 0)
+		return IF_LINK_PROTO_DOWN_MLAG;
+	if (matches(type, "stp") == 0)
+		return IF_LINK_PROTO_DOWN_STP;
+	return 0;
+}
+
+static int fill_link_proto_down_value(
+		struct rtnl_link_protodown *link_proto_down, char *set_type)
+{
+	if (matches(set_type, "on") == 0) {
+		link_proto_down->proto_down =
+			link_proto_down->proto_down_change;
+		return 0;
+	}
+	if (matches(set_type, "off") == 0) {
+		link_proto_down->proto_down = 0;
+		return 0;
+	}
+	return -1;
+}
+
 #if IPLINK_IOCTL_COMPAT
 static int have_rtnl_newlink = -1;
 
@@ -554,6 +580,28 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			if (mode < 0)
 				invarg("Invalid link mode\n", *argv);
 			addattr8(&req->n, sizeof(*req), IFLA_LINKMODE, mode);
+		} else if (strcmp(*argv, "protodown") == 0) {
+			struct rtnl_link_protodown link_proto_down;
+			char proto_down_str[64];
+
+			NEXT_ARG();
+			link_proto_down.proto_down_change =
+					get_link_proto_down_type(*argv);
+			if (!link_proto_down.proto_down_change)
+				invarg("Invalid \"protodown\" value\n", *argv);
+			sprintf(proto_down_str, "protodown %s", *argv);
+			if (NEXT_ARG_OK()) {
+				NEXT_ARG();
+				if (fill_link_proto_down_value(
+					&link_proto_down, *argv) < 0){
+					return on_off(proto_down_str, *argv);
+				}
+				addattr_l(&req->n, sizeof(*req),
+					  IFLA_LINKPROTODOWN, &link_proto_down,
+					  sizeof(link_proto_down));
+			} else {
+				return on_off(proto_down_str, *argv);
+			}
 		} else if (strcmp(*argv, "state") == 0) {
 			int state;
 			NEXT_ARG();
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 9bbf2d3..3745e3a 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -113,6 +113,9 @@ ip-link \- network device configuration
 .B  netns
 .IR NETNSNAME " |"
 .br
+.BI "protodown " PROTODOWNTYPE
+.RB  "{ " on " | " off " } |"
+.br
 .B alias
 .IR NAME  " |"
 .br
@@ -687,6 +690,14 @@ tool can be used. But it allows to change network namespace only for physical de
 .IR PID .
 
 .TP
+.BI "protodown " PROTODOWNTYPE " on|off"
+protodown the device for a specific protocol type
+
+.IR PROTODOWNTYPE " := [ "
+.BR mlag " | "
+.BR stp " ]"
+
+.TP
 .BI alias " NAME"
 give the device a symbolic name for easy reference.
 
-- 
1.7.10.4
