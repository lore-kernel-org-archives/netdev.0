From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 4/4] ila: show usage even if the module is not available
Date: Tue, 16 Aug 2016 16:26:58 +0200
Message-ID: <c9d33e1e1779cb9808346e8f3073b49cff7c2707.1471356460.git.sd@queasysnail.net>
References: <cover.1471356460.git.sd@queasysnail.net>
Cc: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbcHPO1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 10:27:19 -0400
In-Reply-To: <cover.1471356460.git.sd@queasysnail.net>
In-Reply-To: <cover.1471356460.git.sd@queasysnail.net>
References: <cover.1471356460.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the `ip ila` command tries to initialize a genl context
even when we just want to see the help for the command, which doesn't
require to talk to the kernel at all.

Delay genl initialization, which can fail if the module isn't loaded,
until the point where we will actually need it.

Fixes: ec71cae0bb7b ("ila: Support for configuring ila to use netfilter hook")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 ip/ipila.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/ip/ipila.c b/ip/ipila.c
index 244245ca3c40..27f55e961a43 100644
--- a/ip/ipila.c
+++ b/ip/ipila.c
@@ -237,20 +237,21 @@ static int do_del(int argc, char **argv)
 
 int do_ipila(int argc, char **argv)
 {
-	if (genl_init_handle(&genl_rth, ILA_GENL_NAME, &genl_family))
-		exit(1);
-
 	if (argc < 1)
 		usage();
 
+	if (matches(*argv, "help") == 0)
+		usage();
+
+	if (genl_init_handle(&genl_rth, ILA_GENL_NAME, &genl_family))
+		exit(1);
+
 	if (matches(*argv, "add") == 0)
 		return do_add(argc-1, argv+1);
 	if (matches(*argv, "delete") == 0)
 		return do_del(argc-1, argv+1);
 	if (matches(*argv, "list") == 0)
 		return do_list(argc-1, argv+1);
-	if (matches(*argv, "help") == 0)
-		usage();
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip ila help\".\n",
 		*argv);
-- 
2.9.3
