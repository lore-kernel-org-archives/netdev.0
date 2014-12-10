From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip: Simplify executing ip cmd within namespace
Date: Thu, 11 Dec 2014 00:56:35 +0200
Message-ID: <1418252195-2612-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:50649 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756081AbaLJXG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 18:06:26 -0500
Received: by mail-la0-f54.google.com with SMTP id pv20so3230082lab.41
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 15:06:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added new '-ns' option to simplify executing following cmd:

    ip netns exec NETNS ip OPTIONS COMMAND OBJECT

    to

    ip -ns NETNS OPTIONS COMMAND OBJECT

e.g.:

    ip -ns vnet0 link add br0 type bridge

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
May be new option should have better name than '-ns' ?

 ip/ip.c        |  6 ++++++
 ip/ip_common.h |  1 +
 ip/ipnetns.c   |  2 +-
 man/man8/ip.8  | 21 +++++++++++++++++++++
 4 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/ip/ip.c b/ip/ip.c
index 5f759d5..35cf463 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -262,6 +262,12 @@ int main(int argc, char **argv)
 			rcvbuf = size;
 		} else if (matches(opt, "-help") == 0) {
 			usage();
+		} else if (matches(opt, "-ns") == 0) {
+			argc--;
+			argv++;
+			argv[0] = argv[1];
+			argv[1] = basename;
+			return netns_exec(argc, argv);
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"ip -help\".\n", opt);
 			exit(-1);
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 75bfb82..d4f7e1f 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -88,6 +88,7 @@ struct link_util
 struct link_util *get_link_kind(const char *kind);
 struct link_util *get_link_slave_kind(const char *slave_kind);
 int get_netns_fd(const char *name);
+int netns_exec(int argc, char **argv);
 
 #ifndef	INFINITY_LIFE_TIME
 #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 1c8aa02..367841c 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -129,7 +129,7 @@ static void bind_etc(const char *name)
 	closedir(dir);
 }
 
-static int netns_exec(int argc, char **argv)
+int netns_exec(int argc, char **argv)
 {
 	/* Setup the proper environment for apps that are not netns
 	 * aware, and execute a program in that environment.
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 2d42e98..bfb0c53 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -134,6 +134,27 @@ the output.
 use the system's name resolver to print DNS names instead of
 host addresses.
 
+.TP
+.BR "\-ns " <NETNS>
+executes the following
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+in the specified network namespace
+.IR NETNS .
+Actually it just simplifies executing of:
+
+.B ip netns exec
+.IR NETNS
+.B ip
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
+to
+
+.B ip
+.RI "-ns " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
 .SH IP - COMMAND SYNTAX
 
 .SS
-- 
2.1.3
