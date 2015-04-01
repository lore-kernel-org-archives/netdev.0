From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: fix a slab object leak
Date: Wed, 1 Apr 2015 09:42:50 +0800
Message-ID: <1427852570-25210-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:58178 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927AbbDABnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 21:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When remove TIPC module, there is a warning to remind us that a slab
object is leaked like:

root@localhost:~# rmmod tipc
[   19.056226] =============================================================================
[   19.057549] BUG TIPC (Not tainted): Objects remaining in TIPC on kmem_cache_close()
[   19.058736] -----------------------------------------------------------------------------
[   19.058736]
[   19.060287] INFO: Slab 0xffffea0000519a00 objects=23 used=1 fp=0xffff880014668b00 flags=0x100000000004080
[   19.061915] INFO: Object 0xffff880014668000 @offset=0
[   19.062717] kmem_cache_destroy TIPC: Slab cache still has objects

This is because the listening socket of TIPC topology server is not
closed before TIPC proto handler is unregistered with proto_unregister().
However, as the socket is closed in tipc_exit_net() which is called by
unregister_pernet_subsys() during unregistering TIPC namespace operation,
the warning can be eliminated if calling unregister_pernet_subsys() is
moved before calling proto_unregister().

Fixes: e05b31f4bf89 ("tipc: make tipc socket support net namespace")
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 935205e..be1c9fa 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -152,11 +152,11 @@ out_netlink:
 static void __exit tipc_exit(void)
 {
 	tipc_bearer_cleanup();
+	unregister_pernet_subsys(&tipc_net_ops);
 	tipc_netlink_stop();
 	tipc_netlink_compat_stop();
 	tipc_socket_stop();
 	tipc_unregister_sysctl();
-	unregister_pernet_subsys(&tipc_net_ops);
 
 	pr_info("Deactivated\n");
 }
-- 
1.7.9.5
