From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 2/6] ip link/addr: Add support for vrf keyword
Date: Tue, 14 Jun 2016 13:59:28 -0700
Message-ID: <1465937972-25011-3-git-send-email-dsa@cumulusnetworks.com>
References: <1465937972-25011-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33535 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbcFNU7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 16:59:41 -0400
Received: by mail-pf0-f174.google.com with SMTP id y124so680458pfy.0
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 13:59:41 -0700 (PDT)
In-Reply-To: <1465937972-25011-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vrf keyword to 'ip link' and 'ip addr' commands (common list code).

Allows:
1. Adding a link to a VRF using the vrf name:
     $ ip link set NAME vrf NAME

   Versus the current syntax:
     $ ip link set NAME master DEV
   Removing a link from a VRF still uses 'ip link set NAME nomaster'

2. Showing links associated with a VRF:
       $ ip link show vrf NAME

   Versus the current syntax:
     $ ip link show master DEV

3. List addresses associated with links in a VRF
     $ ip addr show vrf NAME

   Versus the current syntax:
     $ ip addr show master DEV

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipaddress.c | 11 +++++++++++
 ip/iplink.c    | 15 +++++++++++++--
 2 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index df363b070d5d..170c4f5d1eb5 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -77,6 +77,7 @@ static void usage(void)
 	fprintf(stderr, "       ip address del IFADDR dev IFNAME [mngtmpaddr]\n");
 	fprintf(stderr, "       ip address {show|save|flush} [ dev IFNAME ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label LABEL ] [up]\n");
+	fprintf(stderr, "                            [ vrf NAME ]\n");
 	fprintf(stderr, "       ip address {showdump|restore}\n");
 	fprintf(stderr, "IFADDR := PREFIX | ADDR peer PREFIX\n");
 	fprintf(stderr, "          [ broadcast ADDR ] [ anycast ADDR ]\n");
@@ -1613,6 +1614,16 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
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
 		} else if (do_link && strcmp(*argv, "type") == 0) {
 			NEXT_ARG();
 			filter.kind = *argv;
diff --git a/ip/iplink.c b/ip/iplink.c
index d2e586b6d133..d564aca6406e 100644
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
@@ -565,6 +565,17 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
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
 
-- 
2.1.4
