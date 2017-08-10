From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 4/6] rtnetlink: init handler refcounts to 1
Date: Thu, 10 Aug 2017 16:53:00 +0200
Message-ID: <20170810145302.30391-5-fw@strlen.de>
References: <20170810145302.30391-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46634 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752612AbdHJOw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 10:52:58 -0400
In-Reply-To: <20170810145302.30391-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If using CONFIG_REFCOUNT_FULL=y we get following splat:
 refcount_t: increment on 0; use-after-free.
WARNING: CPU: 0 PID: 304 at lib/refcount.c:152 refcount_inc+0x47/0x50
Call Trace:
 rtnetlink_rcv_msg+0x191/0x260
 ...

This warning is harmless (0 is "no callback running", not "memory
was freed").

Use '1' as the new 'no handler is running' base instead of 0 to avoid
this.

Fixes: 019a316992ee ("rtnetlink: add reference counting to prevent module unload while dump is in progress")
Reported-by: Sabrina Dubroca <sdubroca@redhat.com>
Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 087f2434813a..59eda6952bc9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -262,7 +262,7 @@ void rtnl_unregister_all(int protocol)
 
 	synchronize_net();
 
-	while (refcount_read(&rtnl_msg_handlers_ref[protocol]) > 0)
+	while (refcount_read(&rtnl_msg_handlers_ref[protocol]) > 1)
 		schedule();
 	kfree(handlers);
 }
@@ -4324,6 +4324,11 @@ static struct pernet_operations rtnetlink_net_ops = {
 
 void __init rtnetlink_init(void)
 {
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(rtnl_msg_handlers_ref); i++)
+		refcount_set(&rtnl_msg_handlers_ref[i], 1);
+
 	if (register_pernet_subsys(&rtnetlink_net_ops))
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 
-- 
2.13.0
