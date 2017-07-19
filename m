From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH v2] netns: avoid directory traversal (was: ip netns: Make sure netns name is sane)
Date: Thu, 20 Jul 2017 00:36:32 +0200
Message-ID: <20170719223632.4124-1-mcroce@redhat.com>
References: <20170718171230.084c804e@xeon-e3>
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33248 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751911AbdGSWgf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 18:36:35 -0400
In-Reply-To: <20170718171230.084c804e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: reword commit message

ip netns keeps track of created namespaces with bind mounts named
/var/run/netns/<namespace>. No input sanitization is done, allowing creation and
deletion of files relatives to /var/run/netns or, if the path is non existent or
invalid, allows to create "untracked" namespaces (invisible to the tool).

This commit denies creation or deletion of namespaces with names contaning
"/" or matching exactly "." or "..".

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 ip/ipnetns.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 0b0378ab..42549944 100644
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
2.13.3
