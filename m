From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH -net] netpoll: fix NULL pointer dereference in netpoll_cleanup
Date: Tue, 17 Sep 2013 16:12:35 +0200
Message-ID: <1379427155-8561-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49143 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607Ab3IQOQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 10:16:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been hitting a NULL ptr deref while using netconsole because the
np->dev check and the pointer manipulation in netpoll_cleanup are done
without rtnl and the following sequence happens when having a netconsole
over a vlan and we remove the vlan while disabling the netconsole:
	CPU 1					CPU2
					removes vlan and calls the notifier
enters store_enabled(), calls
netdev_cleanup which checks np->dev
and then waits for rtnl
					executes the netconsole netdev
					release notifier making np->dev
					== NULL and releases rtnl
continues to dereference a member of
np->dev which at this point is == NULL

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 net/core/netpoll.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 2c637e9..569a185 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -1284,15 +1284,15 @@ EXPORT_SYMBOL_GPL(__netpoll_free_async);
 
 void netpoll_cleanup(struct netpoll *np)
 {
-	if (!np->dev)
-		return;
-
 	rtnl_lock();
+	if (!np->dev) {
+		rtnl_unlock();
+		return;
+	}
 	__netpoll_cleanup(np);
-	rtnl_unlock();
-
 	dev_put(np->dev);
 	np->dev = NULL;
+	rtnl_unlock();
 }
 EXPORT_SYMBOL(netpoll_cleanup);
 
-- 
1.8.1.4
