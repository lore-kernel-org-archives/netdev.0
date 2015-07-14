From: anuradhak@cumulusnetworks.com
Subject: [PATCH iproute2 v7 4/4] ip link: proto_down config and display.
Date: Tue, 14 Jul 2015 13:43:22 -0700
Message-ID: <1436906602-2958-5-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36787 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbGNUni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 16:43:38 -0400
Received: by pdjr16 with SMTP id r16so11595704pdj.3
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 13:43:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

This patch adds support to set and display protodown on a switch port. The
switch driver can handle this error state by doing a phys down on the port.

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

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 include/linux/if_link.h |    1 +
 ip/ipaddress.c          |    5 +++++
 ip/iplink.c             |   13 +++++++++++++
 man/man8/ip-link.8.in   |    8 ++++++++
 4 files changed, 27 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 8df6a84..a06a461 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -148,6 +148,7 @@ enum {
 	IFLA_PHYS_SWITCH_ID,
 	IFLA_LINK_NETNSID,
 	IFLA_PHYS_PORT_NAME,
+	IFLA_PROTO_DOWN,
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 85a81ba..93e2522 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -736,6 +736,11 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			fprintf(fp, " link-netnsid unknown");
 	}
 
+	if (tb[IFLA_PROTO_DOWN]) {
+		if (rta_getattr_u8(tb[IFLA_PROTO_DOWN]))
+			fprintf(fp, " protodown on ");
+	}
+
 	if (tb[IFLA_PROMISCUITY] && show_details)
 		fprintf(fp, " promiscuity %u ",
 			*(int*)RTA_DATA(tb[IFLA_PROMISCUITY]));
diff --git a/ip/iplink.c b/ip/iplink.c
index e296e6f..369d50e 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -85,6 +85,7 @@ void iplink_usage(void)
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
 	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
+	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type TYPE]\n");
 
 	if (iplink_have_newlink()) {
@@ -612,6 +613,18 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				invarg("Invalid \"link-netnsid\" value\n", *argv);
 			addattr32(&req->n, sizeof(*req), IFLA_LINK_NETNSID,
 				  link_netnsid);
+		} else if (strcmp(*argv, "protodown") == 0) {
+			unsigned int proto_down;
+
+			NEXT_ARG();
+			if (strcmp(*argv, "on") == 0)
+				proto_down = 1;
+			else if (strcmp(*argv, "off") == 0)
+				proto_down = 0;
+			else
+				return on_off("protodown", *argv);
+			addattr8(&req->n, sizeof(*req), IFLA_PROTO_DOWN,
+				 proto_down);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 372e6c6..c123fcc 100644
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
+state on the device. Indicates that a protocol error has been detected on the port. Switch drivers can react to this error by doing a phys down on the switch port.
+
+.TP
 .BR "dynamic on " or " dynamic off"
 change the
 .B DYNAMIC
-- 
1.7.10.4
