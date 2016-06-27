From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 iproute2 2/6] ip link/addr: Add support for vrf keyword
Date: Mon, 27 Jun 2016 11:50:57 -0700
Message-ID: <1467053461-16147-3-git-send-email-dsa@cumulusnetworks.com>
References: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35015 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbcF0SvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:51:11 -0400
Received: by mail-pa0-f53.google.com with SMTP id hl6so61420275pac.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:51:10 -0700 (PDT)
In-Reply-To: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
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
 ip/ipaddress.c | 12 +++++++++++-
 ip/iplink.c    | 15 +++++++++++++--
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 8766530f7fa7..03688d422dcc 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -79,7 +79,7 @@ static void usage(void)
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
 			NEXT_ARG();
 			filter.kind = *argv;
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
 
-- 
2.1.4
