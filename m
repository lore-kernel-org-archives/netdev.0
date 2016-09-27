From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH RFC iproute2] iplink: Support envhdrlen
Date: Tue, 27 Sep 2016 17:55:40 +0900
Message-ID: <1474966541-4420-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:60842 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752586AbcI0I64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 04:58:56 -0400
In-Reply-To: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for envhdrlen.

Example:
 # ip link set eno1 envhdrlen 8
 # ip link show eno1
 2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 envhdrlen 8 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
     link/ether 44:37:e6:6c:69:a4 brd ff:ff:ff:ff:ff:ff

Note:
As an RFC, this includes update for kernel headers.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/linux/if_link.h |  1 +
 ip/ipaddress.c          |  2 ++
 ip/iplink.c             | 10 ++++++++++
 3 files changed, 13 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index b9299e3..46ef8cc 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -157,6 +157,7 @@ enum {
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
 	IFLA_XDP,
+	IFLA_ENV_HDR_LEN,
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 76bd7b3..92a472d 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -820,6 +820,8 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	if (tb[IFLA_MTU])
 		fprintf(fp, "mtu %u ", *(int *)RTA_DATA(tb[IFLA_MTU]));
+	if (tb[IFLA_ENV_HDR_LEN])
+		fprintf(fp, "envhdrlen %u ", *(int *)RTA_DATA(tb[IFLA_ENV_HDR_LEN]));
 	if (tb[IFLA_QDISC])
 		fprintf(fp, "qdisc %s ", rta_getattr_str(tb[IFLA_QDISC]));
 	if (tb[IFLA_MASTER]) {
diff --git a/ip/iplink.c b/ip/iplink.c
index 6b1db18..4dcb9ac 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -50,6 +50,7 @@ void iplink_usage(void)
 		fprintf(stderr, "                   [ address LLADDR ]\n");
 		fprintf(stderr, "                   [ broadcast LLADDR ]\n");
 		fprintf(stderr, "                   [ mtu MTU ] [index IDX ]\n");
+		fprintf(stderr, "                   [ envhdrlen ENVHDRLEN ]\n");
 		fprintf(stderr, "                   [ numtxqueues QUEUE_COUNT ]\n");
 		fprintf(stderr, "                   [ numrxqueues QUEUE_COUNT ]\n");
 		fprintf(stderr, "                   type TYPE [ ARGS ]\n");
@@ -489,6 +490,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	char abuf[32];
 	int qlen = -1;
 	int mtu = -1;
+	int envhdrlen = -1;
 	int netns = -1;
 	int vf = -1;
 	int numtxqueues = -1;
@@ -547,6 +549,14 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
+		} else if (strcmp(*argv, "envhdrlen") == 0) {
+			NEXT_ARG();
+			if (envhdrlen != -1)
+				duparg("envhdrlen", *argv);
+			if (get_integer(&envhdrlen, *argv, 0))
+				invarg("Invalid \"envhdrlen\" value\n", *argv);
+			addattr_l(&req->n, sizeof(*req), IFLA_ENV_HDR_LEN,
+				  &envhdrlen, 4);
 		} else if (strcmp(*argv, "netns") == 0) {
 			NEXT_ARG();
 			if (netns != -1)
-- 
2.5.5
