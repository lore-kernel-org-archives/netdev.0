From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH-next v2 1/4] net/core: make sock_diag.c explicitly non-modular
Date: Wed, 7 Oct 2015 17:27:43 -0400
Message-ID: <1444253266-22012-2-git-send-email-paul.gortmaker@windriver.com>
References: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Craig Gallek <kraig@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47786 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbbJGV2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 17:28:16 -0400
In-Reply-To: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Makefile currently controlling compilation of this code lists
it under "obj-y" ...meaning that it currently is not being built as
a module by anyone.

Lets remove the modular code that is essentially orphaned, so that
when reading the driver there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  We can
change to one of the other priority initcalls (subsys?) at any later
date, if desired.

We can't remove module.h since the file uses other module related
stuff even though it is not modular itself.

We move the information from the MODULE_LICENSE tag to the top of the
file, since that information is not captured anywhere else.  The
MODULE_ALIAS_NET_PF_PROTO becomes a no-op in the non modular case, so
it is removed.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Craig Gallek <kraig@google.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/core/sock_diag.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 817622f3dbb7..0c1d58d43f67 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -1,3 +1,5 @@
+/* License: GPL */
+
 #include <linux/mutex.h>
 #include <linux/socket.h>
 #include <linux/skbuff.h>
@@ -323,14 +325,4 @@ static int __init sock_diag_init(void)
 	BUG_ON(!broadcast_wq);
 	return register_pernet_subsys(&diag_net_ops);
 }
-
-static void __exit sock_diag_exit(void)
-{
-	unregister_pernet_subsys(&diag_net_ops);
-	destroy_workqueue(broadcast_wq);
-}
-
-module_init(sock_diag_init);
-module_exit(sock_diag_exit);
-MODULE_LICENSE("GPL");
-MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_SOCK_DIAG);
+device_initcall(sock_diag_init);
-- 
2.6.0.rc3
