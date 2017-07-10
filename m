From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH] netns: avoid directory traversal (was: ip netns: Make sure netns name is sane)
Date: Mon, 10 Jul 2017 14:08:31 +0200
Message-ID: <20170710120831.9355-1-mcroce@redhat.com>
Cc: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43130 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753298AbdGJMIg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 08:08:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phil,

I noticed that your patch still leaves an uncovered scenario, the one where the
namespace name is "." or "..".
Calling 'ip netns del ..' will remove /var/run which is a symlink to /run on
most systems causing some daemons, eg. dbus, to fail.

ip netns doesn't validate input, allowing creation and deletion of files
relatives to /var/run/netns.
This patch denies creation or deletion of namespaces with names contaning
"/" or that matches exactly "." or "..".
---
 ip/ipnetns.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 0b0378a..4254994 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -766,6 +766,11 @@ static int netns_monitor(int argc, char **argv)
 	return 0;
 }
 
+static int invalid_name(const char *name)
+{
+	return strchr(name, '/') || !strcmp(name, ".") || !strcmp(name, "..");
+}
+
 int do_netns(int argc, char **argv)
 {
 	netns_nsid_socket_init();
@@ -775,6 +780,11 @@ int do_netns(int argc, char **argv)
 		return netns_list(0, NULL);
 	}
 
+	if (argc > 1 && invalid_name(argv[1])) {
+		fprintf(stderr, "Invalid netns name \"%s\"\n", argv[1]);
+		exit(-1);
+	}
+
 	if ((matches(*argv, "list") == 0) || (matches(*argv, "show") == 0) ||
 	    (matches(*argv, "lst") == 0)) {
 		netns_map_init();
-- 
2.9.4
