From: anuradhak@cumulusnetworks.com
Subject: [RFC PATCH iproute v3 4/4] ip link: Config and display IFF_PROTO_DOWN flag.
Date: Mon, 27 Apr 2015 10:38:24 -0700
Message-ID: <1430156304-13187-5-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35111 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933064AbbD0Rij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:38:39 -0400
Received: by pabtp1 with SMTP id tp1so136354448pab.2
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 10:38:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

This patch adds support to set and display the IFF_PROTO_DOWN flag. One
example user space application setting this flag is a multi-chassis LAG
application to handle split-brain situation on peer-link failure.

Example:
root@net-next:~# ip link set eth0 protodown on
root@net-next:~# ip link show eth0
3: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP,PROTO_DOWN> mtu 1500 qdisc pfifo_fas
t state DOWN mode DEFAULT group default qlen 1000
    link/ether 00:01:00:00:06:ee brd ff:ff:ff:ff:ff:ff
root@net-next:~# ip link set eth0 protodown off
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
 include/linux/if.h    |    4 ++++
 ip/ipaddress.c        |    1 +
 ip/iplink.c           |   19 +++++++++++++++++++
 man/man8/ip-link.8.in |    8 ++++++++
 4 files changed, 32 insertions(+)

diff --git a/include/linux/if.h b/include/linux/if.h
index a55a9e0..8018883 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -66,6 +66,8 @@
  * @IFF_LOWER_UP: driver signals L1 up. Volatile.
  * @IFF_DORMANT: driver signals dormant. Volatile.
  * @IFF_ECHO: echo sent packets. Volatile.
+ * @IFF_PROTO_DOWN: protocol is down on the interface. Can be toggeled
+ *	through sysfs.
  */
 enum net_device_flags {
 	IFF_UP				= 1<<0,  /* sysfs */
@@ -87,6 +89,7 @@ enum net_device_flags {
 	IFF_LOWER_UP			= 1<<16, /* __volatile__ */
 	IFF_DORMANT			= 1<<17, /* __volatile__ */
 	IFF_ECHO			= 1<<18, /* __volatile__ */
+	IFF_PROTO_DOWN			= 1<<19, /* sysfs */
 };
 
 #define IFF_UP				IFF_UP
@@ -108,6 +111,7 @@ enum net_device_flags {
 #define IFF_LOWER_UP			IFF_LOWER_UP
 #define IFF_DORMANT			IFF_DORMANT
 #define IFF_ECHO			IFF_ECHO
+#define IFF_PROTO_DOWN			IFF_PROTO_DOWN
 
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_ECHO|\
 		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index e582da0..572f1c8 100644
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
diff --git a/ip/iplink.c b/ip/iplink.c
index e6f30e9..4b7d8dc 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -64,6 +64,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ multicast { on | off } ]\n");
 	fprintf(stderr, "	                  [ allmulticast { on | off } ]\n");
 	fprintf(stderr, "	                  [ promisc { on | off } ]\n");
+	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
 	fprintf(stderr, "	                  [ trailers { on | off } ]\n");
 	fprintf(stderr, "	                  [ txqueuelen PACKETS ]\n");
 	fprintf(stderr, "	                  [ name NEWNAME ]\n");
@@ -494,6 +495,15 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				req->i.ifi_flags |= IFF_NOARP;
 			} else
 				return on_off("noarp", *argv);
+		} else if (strcmp(*argv, "protodown") == 0) {
+			NEXT_ARG();
+			req->i.ifi_change |= IFF_PROTO_DOWN;
+			if (strcmp(*argv, "on") == 0) {
+				req->i.ifi_flags |= IFF_PROTO_DOWN;
+			} else if (strcmp(*argv, "off") == 0) {
+				req->i.ifi_flags &= ~IFF_PROTO_DOWN;
+			} else
+				return on_off("protodown", *argv);
 		} else if (strcmp(*argv, "vf") == 0) {
 			struct rtattr *vflist;
 			NEXT_ARG();
@@ -1076,6 +1086,15 @@ static int do_set(int argc, char **argv)
 				flags |= IFF_NOARP;
 			} else
 				return on_off("noarp", *argv);
+		} else if (strcmp(*argv, "protodown") == 0) {
+			NEXT_ARG();
+			mask |= IFF_PROTO_DOWN;
+			if (strcmp(*argv, "on") == 0) {
+				flags |= IFF_PROTO_DOWN;
+			} else if (strcmp(*argv, "off") == 0) {
+				flags &= ~IFF_PROTO_DOWN;
+			} else
+				return on_off("protodown", *argv);
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();
 			mask |= IFF_DYNAMIC;
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 5ad372c..25c8f66 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -96,6 +96,8 @@ ip-link \- network device configuration
 .br
 .BR multicast " { " on " | " off " } |"
 .br
+.BR protodown " { " on " | " off " } |"
+.br
 .B  txqueuelen
 .IR PACKETS " |"
 .br
@@ -634,6 +636,12 @@ change the
 flag on the device.
 
 .TP
+.BR "protodown on " or " protodown off"
+change the
+.B PROTODOWN
+flag on the device.
+
+.TP
 .BR "dynamic on " or " dynamic off"
 change the
 .B DYNAMIC
-- 
1.7.10.4
