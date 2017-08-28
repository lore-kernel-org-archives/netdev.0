From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ss: Fix for added diag support check
Date: Mon, 28 Aug 2017 19:31:22 +0200
Message-ID: <20170828173122.11458-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47593 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751269AbdH1Rbe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 13:31:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9f66764e308e9 ("libnetlink: Add test for error code returned from
netlink reply") changed rtnl_dump_filter_l() to return an error in case
NLMSG_DONE would contain one, even if it was ENOENT.

This in turn breaks ss when it tries to dump DCCP sockets on a system
without support for it: The function tcp_show(), which is shared between
TCP and DCCP, will start parsing /proc since inet_show_netlink() returns
an error - yet it parses /proc/net/tcp which doesn't make sense for DCCP
sockets at all.

On my system, a call to 'ss' without further arguments prints the list
of connected TCP sockets twice.

Fix this by introducing a dedicated function dccp_show() which does not
have a fallback to /proc, just like sctp_show(). And since tcp_show()
is no longer "multi-purpose", drop it's socktype parameter.

Fixes: 9f66764e308e9 ("libnetlink: Add test for error code returned from netlink reply")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index fcc3cf9282c49..2c9e80e696595 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2753,7 +2753,7 @@ static int tcp_show_netlink_file(struct filter *f)
 	return err;
 }
 
-static int tcp_show(struct filter *f, int socktype)
+static int tcp_show(struct filter *f)
 {
 	FILE *fp = NULL;
 	char *buf = NULL;
@@ -2768,7 +2768,7 @@ static int tcp_show(struct filter *f, int socktype)
 		return tcp_show_netlink_file(f);
 
 	if (!getenv("PROC_NET_TCP") && !getenv("PROC_ROOT")
-	    && inet_show_netlink(f, NULL, socktype) == 0)
+	    && inet_show_netlink(f, NULL, IPPROTO_TCP) == 0)
 		return 0;
 
 	/* Sigh... We have to parse /proc/net/tcp... */
@@ -2836,6 +2836,18 @@ outerr:
 	} while (0);
 }
 
+static int dccp_show(struct filter *f)
+{
+	if (!filter_af_get(f, AF_INET) && !filter_af_get(f, AF_INET6))
+		return 0;
+
+	if (!getenv("PROC_NET_DCCP") && !getenv("PROC_ROOT")
+	    && inet_show_netlink(f, NULL, IPPROTO_DCCP) == 0)
+		return 0;
+
+	return 0;
+}
+
 static int sctp_show(struct filter *f)
 {
 	if (!filter_af_get(f, AF_INET) && !filter_af_get(f, AF_INET6))
@@ -4390,9 +4402,9 @@ int main(int argc, char *argv[])
 	if (current_filter.dbs & (1<<UDP_DB))
 		udp_show(&current_filter);
 	if (current_filter.dbs & (1<<TCP_DB))
-		tcp_show(&current_filter, IPPROTO_TCP);
+		tcp_show(&current_filter);
 	if (current_filter.dbs & (1<<DCCP_DB))
-		tcp_show(&current_filter, IPPROTO_DCCP);
+		dccp_show(&current_filter);
 	if (current_filter.dbs & (1<<SCTP_DB))
 		sctp_show(&current_filter);
 
-- 
2.13.1
