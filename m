From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Add route showdump command
Date: Thu, 26 Jul 2012 12:53:39 +0400
Message-ID: <50110593.1070502@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dan Smith <danms@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46959 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741Ab2GZIxs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2012 04:53:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some time ago the save+restore commands were added to ip route (git
id f4ff11e3, Add ip route save/restore). These two save the raw rtnl
stream into a file and restore one (reading it from stdin).

The problem is that there's no way to get the contents of the dump
file in a human readable form. How about adding a command that reads
the rtnl stream from stdin and prints the data in a way the usual
"ip route list" does?

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/ip/iproute.c b/ip/iproute.c
index 5cd313e..585a7d8 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -60,6 +60,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip route { list | flush } SELECTOR\n");
 	fprintf(stderr, "       ip route save SELECTOR\n");
 	fprintf(stderr, "       ip route restore\n");
+	fprintf(stderr, "       ip route showdump\n");
 	fprintf(stderr, "       ip route get ADDRESS [ from ADDRESS iif STRING ]\n");
 	fprintf(stderr, "                            [ oif STRING ]  [ tos TOS ]\n");
 	fprintf(stderr, "                            [ mark NUMBER ]\n");
@@ -1526,6 +1527,17 @@ int iproute_restore(void)
 	exit(rtnl_from_file(stdin, &restore_handler, NULL));
 }
 
+static int show_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+{
+	print_route(nl, n, stdout);
+	return 0;
+}
+
+static int iproute_showdump(void)
+{
+	exit(rtnl_from_file(stdin, &show_handler, NULL));
+}
+
 void iproute_reset_filter()
 {
 	memset(&filter, 0, sizeof(filter));
@@ -1570,6 +1582,8 @@ int do_iproute(int argc, char **argv)
 		return iproute_list_flush_or_save(argc-1, argv+1, IPROUTE_SAVE);
 	if (matches(*argv, "restore") == 0)
 		return iproute_restore();
+	if (matches(*argv, "showdump") == 0)
+		return iproute_showdump();
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip route help\".\n", *argv);
