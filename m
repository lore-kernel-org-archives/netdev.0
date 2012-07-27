From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/2] iproute: Add magic cookie to route dump file
Date: Fri, 27 Jul 2012 08:55:41 +0400
Message-ID: <50121F4D.8090606@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5032 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753373Ab2G0Ezs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 00:55:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to somehow verify that a blob contains route dump a
4-bytes magic is put at the head of the data and is checked
on restore.

Magic digits are taken from Portland (OR) coordinates :) Is
there any more reliable way of generating such?

Signed-of-by: Pavel Emelyanov <xemul@parallels.com>

---

 ip/iproute.c |   54 +++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 47 insertions(+), 7 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 5cd313e..bbb3923 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1064,6 +1064,8 @@ static int iproute_flush_cache(void)
 	return 0;
 }
 
+static __u32 route_dump_magic = 0x45311224;
+
 int save_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	int ret;
@@ -1072,11 +1074,6 @@ int save_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	struct rtattr *tb[RTA_MAX+1];
 	int host_len = -1;
 
-	if (isatty(STDOUT_FILENO)) {
-		fprintf(stderr, "Not sending binary stream to stdout\n");
-		return -1;
-	}
-
 	host_len = calc_host_len(r);
 	len -= NLMSG_LENGTH(sizeof(*r));
 	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
@@ -1093,6 +1090,24 @@ int save_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	return ret == n->nlmsg_len ? 0 : ret;
 }
 
+static int save_route_prep(void)
+{
+	int ret;
+
+	if (isatty(STDOUT_FILENO)) {
+		fprintf(stderr, "Not sending binary stream to stdout\n");
+		return -1;
+	}
+
+	ret = write(STDOUT_FILENO, &route_dump_magic, sizeof(route_dump_magic));
+	if (ret != sizeof(route_dump_magic)) {
+		fprintf(stderr, "Can't write magic to dump file\n");
+		return -1;
+	}
+
+	return 0;
+}
+
 static int iproute_list_flush_or_save(int argc, char **argv, int action)
 {
 	int do_ipv6 = preferred_family;
@@ -1101,9 +1116,12 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 	unsigned int mark = 0;
 	rtnl_filter_t filter_fn;
 
-	if (action == IPROUTE_SAVE)
+	if (action == IPROUTE_SAVE) {
+		if (save_route_prep())
+			return -1;
+
 		filter_fn = save_route;
-	else
+	} else
 		filter_fn = print_route;
 
 	iproute_reset_filter();
@@ -1521,8 +1539,30 @@ int restore_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
 	return ret;
 }
 
+static int route_dump_check_magic(void)
+{
+	int ret;
+	__u32 magic = 0;
+
+	if (isatty(STDIN_FILENO)) {
+		fprintf(stderr, "Can't restore route dump from a terminal\n");
+		return -1;
+	}
+
+	ret = fread(&magic, sizeof(magic), 1, stdin);
+	if (magic != route_dump_magic) {
+		fprintf(stderr, "Magic mismatch (%d elems, %x magic)\n", ret, magic);
+		return -1;
+	}
+
+	return 0;
+}
+
 int iproute_restore(void)
 {
+	if (route_dump_check_magic())
+		exit(-1);
+
 	exit(rtnl_from_file(stdin, &restore_handler, NULL));
 }
 
-- 
1.5.5.6
