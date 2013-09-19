From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH -net v2 1/2] netpoll: fix NULL pointer dereference in netpoll_cleanup
Date: Thu, 19 Sep 2013 15:02:35 +0200
Message-ID: <1379595756-3527-2-git-send-email-nikolay@redhat.com>
References: <1379595756-3527-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25516 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754001Ab3ISNGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 09:06:10 -0400
In-Reply-To: <1379595756-3527-1-git-send-email-nikolay@redhat.com>
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
v2: fix the style as requested

 net/core/netpoll.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 2c637e9..2ba363d 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -1284,15 +1284,14 @@ EXPORT_SYMBOL_GPL(__netpoll_free_async);
 
 void netpoll_cleanup(struct netpoll *np)
 {
-	if (!np->dev)
-		return;
-
 	rtnl_lock();
+	if (!np->dev)
+		goto out;
 	__netpoll_cleanup(np);
-	rtnl_unlock();
-
 	dev_put(np->dev);
 	np->dev = NULL;
+out:
+	rtnl_unlock();
 }
 EXPORT_SYMBOL(netpoll_cleanup);
 
-- 
1.8.1.4
