From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 2.6.24-rc2] net: net_free implicit declaration
Date: Tue, 6 Nov 2007 19:06:29 -0800
Message-ID: <20071106190629.f77560fb.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm <akpm@linux-foundation.org>,
	torvalds <torvalds@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:46816 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753359AbXKGDHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 22:07:06 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Just move the function so that is it known before it is used.

net/core/net_namespace.c: In function 'copy_net_ns':
net/core/net_namespace.c:97: error: implicit declaration of function 'net_free'
net/core/net_namespace.c: At top level:
net/core/net_namespace.c:104: warning: conflicting types for 'net_free'
net/core/net_namespace.c:104: error: static declaration of 'net_free' follows non-static declaration
net/core/net_namespace.c:97: error: previous implicit declaration of 'net_free' was here
make[2]: *** [net/core/net_namespace.o] Error 1

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/core/net_namespace.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

--- linux-2.6.24-rc2.orig/net/core/net_namespace.c
+++ linux-2.6.24-rc2/net/core/net_namespace.c
@@ -64,6 +64,20 @@ static struct net *net_alloc(void)
 	return kmem_cache_zalloc(net_cachep, GFP_KERNEL);
 }
 
+static void net_free(struct net *net)
+{
+	if (!net)
+		return;
+
+	if (unlikely(atomic_read(&net->use_count) != 0)) {
+		printk(KERN_EMERG "network namespace not free! Usage: %d\n",
+			atomic_read(&net->use_count));
+		return;
+	}
+
+	kmem_cache_free(net_cachep, net);
+}
+
 struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 {
 	struct net *new_net = NULL;
@@ -100,20 +114,6 @@ out:
 	return new_net;
 }
 
-static void net_free(struct net *net)
-{
-	if (!net)
-		return;
-
-	if (unlikely(atomic_read(&net->use_count) != 0)) {
-		printk(KERN_EMERG "network namespace not free! Usage: %d\n",
-			atomic_read(&net->use_count));
-		return;
-	}
-
-	kmem_cache_free(net_cachep, net);
-}
-
 static void cleanup_net(struct work_struct *work)
 {
 	struct pernet_operations *ops;
