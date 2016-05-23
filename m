From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master] ip, token: add del command
Date: Tue, 24 May 2016 00:47:38 +0200
Message-ID: <15ca6151698ae0cb9bda5e0e5bfe665487a08865.1464043263.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38757 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbcEWWr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 18:47:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For convenience also add a del command for deleting a token and
update the man page accordingly.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ip/iptoken.c        | 26 ++++++++++++++------------
 man/man8/ip-token.8 | 13 +++++++++++--
 2 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/ip/iptoken.c b/ip/iptoken.c
index 6e1a1ab..722b526 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -38,7 +38,7 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip token [ list | set | get ] [ TOKEN ] [ dev DEV ]\n");
+	fprintf(stderr, "Usage: ip token [ list | set | del | get ] [ TOKEN ] [ dev DEV ]\n");
 	exit(-1);
 }
 
@@ -117,7 +117,7 @@ static int iptoken_list(int argc, char **argv)
 	return 0;
 }
 
-static int iptoken_set(int argc, char **argv)
+static int iptoken_set(int argc, char **argv, bool delete)
 {
 	struct {
 		struct nlmsghdr n;
@@ -125,10 +125,9 @@ static int iptoken_set(int argc, char **argv)
 		char buf[512];
 	} req;
 	struct rtattr *afs, *afs6;
-	bool have_token = false, have_dev = false;
-	inet_prefix addr;
+	bool have_token = delete, have_dev = false;
+	inet_prefix addr = { .bytelen = 16, };
 
-	memset(&addr, 0, sizeof(addr));
 	memset(&req, 0, sizeof(req));
 
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
@@ -149,13 +148,7 @@ static int iptoken_set(int argc, char **argv)
 			if (matches(*argv, "help") == 0)
 				usage();
 			if (!have_token) {
-				afs = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
-				afs6 = addattr_nest(&req.n, sizeof(req), AF_INET6);
 				get_prefix(&addr, *argv, req.ifi.ifi_family);
-				addattr_l(&req.n, sizeof(req), IFLA_INET6_TOKEN,
-					  &addr.data, addr.bytelen);
-				addattr_nest_end(&req.n, afs6);
-				addattr_nest_end(&req.n, afs);
 				have_token = true;
 			}
 		}
@@ -171,6 +164,13 @@ static int iptoken_set(int argc, char **argv)
 		return -1;
 	}
 
+	afs = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
+	afs6 = addattr_nest(&req.n, sizeof(req), AF_INET6);
+	addattr_l(&req.n, sizeof(req), IFLA_INET6_TOKEN,
+		  &addr.data, addr.bytelen);
+	addattr_nest_end(&req.n, afs6);
+	addattr_nest_end(&req.n, afs);
+
 	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -2;
 
@@ -189,7 +189,9 @@ int do_iptoken(int argc, char **argv)
 		return iptoken_list(argc - 1, argv + 1);
 	} else if (matches(argv[0], "set") == 0 ||
 		   matches(argv[0], "add") == 0) {
-		return iptoken_set(argc - 1, argv + 1);
+		return iptoken_set(argc - 1, argv + 1, false);
+	} else if (matches(argv[0], "delete") == 0) {
+		return iptoken_set(argc - 1, argv + 1, true);
 	} else if (matches(argv[0], "get") == 0) {
 		return iptoken_list(argc - 1, argv + 1);
 	} else if (matches(argv[0], "help") == 0)
diff --git a/man/man8/ip-token.8 b/man/man8/ip-token.8
index 260f366..6505b8c 100644
--- a/man/man8/ip-token.8
+++ b/man/man8/ip-token.8
@@ -18,6 +18,10 @@ ip-token \- tokenized interface identifier support
 .IR DEV
 
 .ti -8
+.B ip token del dev
+.IR DEV
+
+.ti -8
 .B ip token get
 .RB "[ " dev
 .IR DEV " ]"
@@ -37,8 +41,7 @@ IPv6 Identifiers are described in the draft
 [1]: <draft-chown-6man-tokenised-ipv6-identifiers-02>.
 
 .SS ip token set - set an interface token
-set the interface token to the kernel. Once a token is set, it cannot be
-removed from the interface, only overwritten.
+set the interface token to the kernel.
 .TP
 .I TOKEN
 the interface identifier token address.
@@ -46,6 +49,12 @@ the interface identifier token address.
 .BI dev " DEV"
 the networking interface.
 
+.SS ip token del - delete an interface token
+delete the interface token from the kernel.
+.TP
+.BI dev " DEV"
+the networking interface.
+
 .SS ip token get - get the interface token from the kernel
 show a tokenized interface identifier of a particular networking device.
 .B Arguments:
-- 
1.9.3
