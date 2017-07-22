From: elie@bouttier.eu
Subject: [PATCH] ip route: replace exits with returns
Date: Sun, 23 Jul 2017 00:42:02 +0200
Message-ID: <20170722224202.5602-1-elie@bouttier.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?=C3=89lie=20Bouttier?= <elie@bouttier.eu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cannelle.eu.org ([91.224.149.170]:52878 "EHLO
        pigeon.cannelle.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754501AbdGVWtq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 18:49:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Élie Bouttier <elie@bouttier.eu>

This patch replaces exits with returns in ip route
commands.

Allows to continue when invoked with ip -batch.

Signed-off-by: Élie Bouttier <elie@bouttier.eu>
---
 ip/iproute.c | 47 ++++++++++++++++++++++++++---------------------
 1 file changed, 26 insertions(+), 21 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index a735d281..cb695ad4 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -137,7 +137,7 @@ static int flush_update(void)
 {
 	if (rtnl_send_check(&rth, filter.flushb, filter.flushp) < 0) {
 		perror("Failed to send flush request");
-		return -1;
+		return -2;
 	}
 	filter.flushp = 0;
 	return 0;
@@ -319,6 +319,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	struct rtattr *tb[RTA_MAX+1];
 	int host_len, family;
 	__u32 table;
+	int ret;
 
 	SPRINT_BUF(b1);
 	static int hz;
@@ -348,8 +349,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		struct nlmsghdr *fn;
 
 		if (NLMSG_ALIGN(filter.flushp) + n->nlmsg_len > filter.flushe) {
-			if (flush_update())
-				return -1;
+			if ((ret = flush_update()) < 0)
+				return ret;
 		}
 		fn = (struct nlmsghdr *)(filter.flushb + NLMSG_ALIGN(filter.flushp));
 		memcpy(fn, n, n->nlmsg_len);
@@ -764,7 +765,7 @@ static int parse_one_nh(struct nlmsghdr *n, struct rtmsg *r,
 			NEXT_ARG();
 			if ((rtnh->rtnh_ifindex = ll_name_to_index(*argv)) == 0) {
 				fprintf(stderr, "Cannot find device \"%s\"\n", *argv);
-				exit(1);
+				return -1;
 			}
 		} else if (strcmp(*argv, "weight") == 0) {
 			unsigned int w;
@@ -1396,6 +1397,7 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 	char *od = NULL;
 	unsigned int mark = 0;
 	rtnl_filter_t filter_fn;
+	int ret;
 
 	if (action == IPROUTE_SAVE) {
 		if (save_route_prep())
@@ -1604,12 +1606,12 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 		for (;;) {
 			if (rtnl_wilddump_request(&rth, do_ipv6, RTM_GETROUTE) < 0) {
 				perror("Cannot send dump request");
-				exit(1);
+				return -2;
 			}
 			filter.flushed = 0;
 			if (rtnl_dump_filter(&rth, filter_fn, stdout) < 0) {
 				fprintf(stderr, "Flush terminated\n");
-				exit(1);
+				return -2;
 			}
 			if (filter.flushed == 0) {
 				if (show_stats) {
@@ -1622,13 +1624,13 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 				return 0;
 			}
 			round++;
-			if (flush_update() < 0)
-				exit(1);
+			if ((ret = flush_update()) < 0)
+				return ret;
 
 			if (time(0) - start > 30) {
 				printf("\n*** Flush not completed after %ld seconds, %d entries remain ***\n",
 				       (long)(time(0) - start), filter.flushed);
-				exit(1);
+				return -1;
 			}
 
 			if (show_stats) {
@@ -1641,21 +1643,21 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 	if (!filter.cloned) {
 		if (rtnl_wilddump_request(&rth, do_ipv6, RTM_GETROUTE) < 0) {
 			perror("Cannot send dump request");
-			exit(1);
+			return -2;
 		}
 	} else {
 		if (rtnl_rtcache_request(&rth, do_ipv6) < 0) {
 			perror("Cannot send dump request");
-			exit(1);
+			return -2;
 		}
 	}
 
 	if (rtnl_dump_filter(&rth, filter_fn, stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
-		exit(1);
+		return -2;
 	}
 
-	exit(0);
+	return 0;
 }
 
 
@@ -1761,7 +1763,7 @@ static int iproute_get(int argc, char **argv)
 
 	if (req.r.rtm_dst_len == 0) {
 		fprintf(stderr, "need at least a destination address\n");
-		exit(1);
+		return -1;
 	}
 
 	if (idev || odev)  {
@@ -1918,12 +1920,12 @@ static int iproute_restore(void)
 	int pos, prio;
 
 	if (route_dump_check_magic())
-		exit(-1);
+		return -1;
 
 	pos = ftell(stdin);
 	if (pos == -1) {
 		perror("Failed to restore: ftell");
-		exit(-1);
+		return -1;
 	}
 
 	for (prio = 0; prio < 3; prio++) {
@@ -1931,15 +1933,15 @@ static int iproute_restore(void)
 
 		err = rtnl_from_file(stdin, &restore_handler, &prio);
 		if (err)
-			exit(err);
+			return -2;
 
 		if (fseek(stdin, pos, SEEK_SET) == -1) {
 			perror("Failed to restore: fseek");
-			exit(-1);
+			return -1;
 		}
 	}
 
-	exit(0);
+	return 0;
 }
 
 static int show_handler(const struct sockaddr_nl *nl,
@@ -1953,9 +1955,12 @@ static int show_handler(const struct sockaddr_nl *nl,
 static int iproute_showdump(void)
 {
 	if (route_dump_check_magic())
-		exit(-1);
+		return -1;
 
-	exit(rtnl_from_file(stdin, &show_handler, NULL));
+	if (rtnl_from_file(stdin, &show_handler, NULL))
+		return -2;
+
+	return 0;
 }
 
 void iproute_reset_filter(int ifindex)
-- 
2.13.0
