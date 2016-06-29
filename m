From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v3 iproute2 2/6] ip link/addr: Add support for vrf keyword
Date: Wed, 29 Jun 2016 11:06:16 -0700
Message-ID: <1467223580-14548-3-git-send-email-dsa@cumulusnetworks.com>
References: <1467223580-14548-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36468 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbcF2SG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 14:06:28 -0400
Received: by mail-pf0-f182.google.com with SMTP id t190so20456179pfb.3
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 11:06:28 -0700 (PDT)
In-Reply-To: <1467223580-14548-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vrf keyword to 'ip link' and 'ip addr' commands (common list code).

Allows:
1. Adding a link to a VRF
       $ ip link set NAME vrf NAME

   Removing a link from a VRF still uses 'ip link set NAME nomaster'

2. Showing links associated with a VRF:
       $ ip link show vrf NAME

3. List addresses associated with links in a VRF
       $ ip -br addr show vrf red

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipaddress.c           | 12 +++++++++++-
 ip/iplink.c              | 15 +++++++++++++--
 man/man8/ip-address.8.in |  6 ++++++
 man/man8/ip-link.8.in    | 10 ++++++++++
 4 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d4d649505e15..54896c726e07 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -80,7 +80,7 @@ static void usage(void)
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label LABEL ] [up]\n");
 	fprintf(stderr, "       ip address [ show [ dev IFNAME ] [ scope SCOPE-ID ] [ master DEVICE ]\n");
 	fprintf(stderr, "                         [ type TYPE ] [ to PREFIX ] [ FLAG-LIST ]\n");
-	fprintf(stderr, "                         [ label LABEL ] [up] ]\n");
+	fprintf(stderr, "                         [ label LABEL ] [up] [ vrf NAME ] ]\n");
 	fprintf(stderr, "       ip address {showdump|restore}\n");
 	fprintf(stderr, "IFADDR := PREFIX | ADDR peer PREFIX\n");
 	fprintf(stderr, "          [ broadcast ADDR ] [ anycast ADDR ]\n");
@@ -1620,6 +1620,16 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 			if (!ifindex)
 				invarg("Device does not exist\n", *argv);
 			filter.master = ifindex;
+		} else if (strcmp(*argv, "vrf") == 0) {
+			int ifindex;
+
+			NEXT_ARG();
+			ifindex = ll_name_to_index(*argv);
+			if (!ifindex)
+				invarg("Not a valid VRF name\n", *argv);
+			if (!name_is_vrf(*argv))
+				invarg("Not a valid VRF name\n", *argv);
+			filter.master = ifindex;
 		} else if (strcmp(*argv, "type") == 0) {
 			int soff;
 
diff --git a/ip/iplink.c b/ip/iplink.c
index b1f8a37922f5..f2a2e13cf0c5 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -82,11 +82,11 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ query_rss { on | off} ]\n");
 	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
 	fprintf(stderr, "				   [ trust { on | off} ] ]\n");
-	fprintf(stderr, "			  [ master DEVICE ]\n");
+	fprintf(stderr, "			  [ master DEVICE ][ vrf NAME ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
 	fprintf(stderr, "			  [ addrgenmode { eui64 | none | stable_secret | random } ]\n");
 	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
-	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type TYPE]\n");
+	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [vrf NAME] [type TYPE]\n");
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "       ip link help [ TYPE ]\n");
@@ -603,6 +603,17 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				invarg("Device does not exist\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_MASTER,
 				  &ifindex, 4);
+		} else if (strcmp(*argv, "vrf") == 0) {
+			int ifindex;
+
+			NEXT_ARG();
+			ifindex = ll_name_to_index(*argv);
+			if (!ifindex)
+				invarg("Not a valid VRF name\n", *argv);
+			if (!name_is_vrf(*argv))
+				invarg("Not a valid VRF name\n", *argv);
+			addattr_l(&req->n, sizeof(*req), IFLA_MASTER,
+				  &ifindex, sizeof(ifindex));
 		} else if (matches(*argv, "nomaster") == 0) {
 			int ifindex = 0;
 
diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 3cbe4181f7e3..7cb927173133 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -45,6 +45,8 @@ ip-address \- protocol address management
 .IR DEVICE " ] [ "
 .B  type
 .IR TYPE " ] [ "
+.B vrf
+.IR NAME " ] [ "
 .BR up " ] ]"
 
 .ti -8
@@ -280,6 +282,10 @@ is a usual shell style pattern.
 only list interfaces enslaved to this master device.
 
 .TP
+.BI vrf " NAME "
+only list interfaces enslaved to this vrf.
+
+.TP
 .BI type " TYPE"
 only list interfaces of the given type.
 
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 375b4d081408..ad18f7555d0a 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -154,6 +154,9 @@ ip-link \- network device configuration
 .br
 .RB "[ " nomaster " ]"
 .br
+.RB "[ " vrf
+.IR NAME " ]"
+.br
 .RB "[ " addrgenmode " { " eui64 " | " none " | " stable_secret " | " random " } ]"
 
 
@@ -167,6 +170,8 @@ ip-link \- network device configuration
 .IR DEVICE " ] ["
 .B type
 .IR TYPE " ]"
+.B vrf
+.IR NAME " ]"
 
 .ti -8
 .B ip link help
@@ -1256,6 +1261,11 @@ only display running interfaces.
 specifies the master device which enslaves devices to show.
 
 .TP
+.BI vrf " NAME "
+.I NAME
+speficies the VRF which enslaves devices to show.
+
+.TP
 .BI type " TYPE "
 .I TYPE
 specifies the type of devices to show.
-- 
2.1.4
