From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ip: add RTA_MARK support
Date: Wed, 21 Jul 2010 11:42:50 +0200
Message-ID: <1279705370.2452.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63867 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707Ab0GUJmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 05:42:54 -0400
Received: by wwj40 with SMTP id 40so2065939wwj.1
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 02:42:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for RTA_MARK rt attribute added in linux-2.6.36

$ ip route get ADDR mark 4
192.168.20.110 dev eth1  src 192.168.20.108  mark 4
    cache  mtu 1500 advmss 1460 hoplimit 64

$ ip route get 192.168.20.108 from ADDR iif STRING mark 256
local 192.168.20.108 from 192.168.20.110 dev lo  src 192.168.20.108  mark 0x100
    cache <local,src-direct>  iif eth1

$ ip route list cache [ADDR] mark NUMBER

Hexadecimal output if mark >= 16
null marks are not displayed.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/rtnetlink.h |    1 +
 ip/iproute.c              |   30 ++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 0d8ef9e..a3ccbe4 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -282,6 +282,7 @@ enum rtattr_type_t {
 	RTA_SESSION, /* no longer used */
 	RTA_MP_ALGO, /* no longer used */
 	RTA_TABLE,
+	RTA_MARK,
 	__RTA_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index 8252e18..cbb89c5 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -55,6 +55,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip route { list | flush } SELECTOR\n");
 	fprintf(stderr, "       ip route get ADDRESS [ from ADDRESS iif STRING ]\n");
 	fprintf(stderr, "                            [ oif STRING ]  [ tos TOS ]\n");
+	fprintf(stderr, "                            [ mark NUMBER ]\n");
 	fprintf(stderr, "       ip route { add | del | change | append | replace | monitor } ROUTE\n");
 	fprintf(stderr, "SELECTOR := [ root PREFIX ] [ match PREFIX ] [ exact PREFIX ]\n");
 	fprintf(stderr, "            [ table TABLE_ID ] [ proto RTPROTO ]\n");
@@ -96,6 +97,7 @@ static struct
 	int tos, tosmask;
 	int iif, iifmask;
 	int oif, oifmask;
+	int mark, markmask;
 	int realm, realmmask;
 	inet_prefix rprefsrc;
 	inet_prefix rvia;
@@ -273,6 +275,13 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		if ((oif^filter.oif)&filter.oifmask)
 			return 0;
 	}
+	if (filter.markmask) {
+		int mark = 0;
+		if (tb[RTA_MARK])
+			mark = *(int *)RTA_DATA(tb[RTA_MARK]);
+		if ((mark ^ filter.mark) & filter.markmask)
+			return 0;
+	}
 	if (filter.flushb &&
 	    r->rtm_family == AF_INET6 &&
 	    r->rtm_dst_len == 0 &&
@@ -384,6 +393,15 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "pervasive ");
 	if (r->rtm_flags & RTM_F_NOTIFY)
 		fprintf(fp, "notify ");
+	if (tb[RTA_MARK]) {
+		unsigned int mark = *(unsigned int*)RTA_DATA(tb[RTA_MARK]);
+		if (mark) {
+			if (mark >= 16)
+				fprintf(fp, " mark 0x%x", mark);
+			else
+				fprintf(fp, " mark %u", mark);
+		}
+	}
 
 	if (tb[RTA_FLOW] && filter.realmmask != ~0U) {
 		__u32 to = *(__u32*)RTA_DATA(tb[RTA_FLOW]);
@@ -1047,6 +1065,7 @@ static int iproute_list_or_flush(int argc, char **argv, int flush)
 	int do_ipv6 = preferred_family;
 	char *id = NULL;
 	char *od = NULL;
+	unsigned int mark = 0;
 
 	iproute_reset_filter();
 	filter.tb = RT_TABLE_MAIN;
@@ -1119,6 +1138,10 @@ static int iproute_list_or_flush(int argc, char **argv, int flush)
 		} else if (strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
 			id = *argv;
+		} else if (strcmp(*argv, "mark") == 0) {
+			NEXT_ARG();
+			get_unsigned(&mark, *argv, 0);
+			filter.markmask = -1;
 		} else if (strcmp(*argv, "via") == 0) {
 			NEXT_ARG();
 			get_prefix(&filter.rvia, *argv, do_ipv6);
@@ -1200,6 +1223,7 @@ static int iproute_list_or_flush(int argc, char **argv, int flush)
 			filter.oifmask = -1;
 		}
 	}
+	filter.mark = mark;
 
 	if (flush) {
 		int round = 0;
@@ -1289,6 +1313,7 @@ int iproute_get(int argc, char **argv)
 	char  *odev = NULL;
 	int connected = 0;
 	int from_ok = 0;
+	unsigned int mark = 0;
 
 	memset(&req, 0, sizeof(req));
 
@@ -1329,6 +1354,9 @@ int iproute_get(int argc, char **argv)
 		} else if (matches(*argv, "iif") == 0) {
 			NEXT_ARG();
 			idev = *argv;
+		} else if (matches(*argv, "mark") == 0) {
+			NEXT_ARG();
+			get_unsigned(&mark, *argv, 0);
 		} else if (matches(*argv, "oif") == 0 ||
 			   strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
@@ -1379,6 +1407,8 @@ int iproute_get(int argc, char **argv)
 			addattr32(&req.n, sizeof(req), RTA_OIF, idx);
 		}
 	}
+	if (mark)
+		addattr32(&req.n, sizeof(req), RTA_MARK, mark);
 
 	if (req.r.rtm_family == AF_UNSPEC)
 		req.r.rtm_family = AF_INET;


