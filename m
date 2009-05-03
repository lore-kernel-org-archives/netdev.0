From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/2] netns 2/2: extract net_create()
Date: Mon, 4 May 2009 03:28:47 +0400
Message-ID: <20090503232847.GG16631@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:4583 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755462AbZECX17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 19:27:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_create() will be used by C/R to create fresh netns on restart.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 net/core/net_namespace.c |   44 ++++++++++++++++++++------------------------
 1 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 4488010..6b3edc9 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -115,38 +115,34 @@ static void net_free(struct net *net)
 	kmem_cache_free(net_cachep, net);
 }
 
-struct net *copy_net_ns(unsigned long flags, struct net *old_net)
+static struct net *net_create(void)
 {
-	struct net *new_net = NULL;
-	int err;
-
-	if (!(flags & CLONE_NEWNET))
-		return get_net(old_net);
-
-	err = -ENOMEM;
-	new_net = net_alloc();
-	if (!new_net)
-		goto out_err;
+	struct net *net;
+	int rv;
 
+	net = net_alloc();
+	if (!net)
+		return ERR_PTR(-ENOMEM);
 	mutex_lock(&net_mutex);
-	err = setup_net(new_net);
-	if (!err) {
+	rv = setup_net(net);
+	if (rv == 0) {
 		rtnl_lock();
-		list_add_tail(&new_net->list, &net_namespace_list);
+		list_add_tail(&net->list, &net_namespace_list);
 		rtnl_unlock();
 	}
 	mutex_unlock(&net_mutex);
+	if (rv < 0) {
+		net_free(net);
+		return ERR_PTR(rv);
+	}
+	return net;
+}
 
-	if (err)
-		goto out_free;
-out:
-	return new_net;
-
-out_free:
-	net_free(new_net);
-out_err:
-	new_net = ERR_PTR(err);
-	goto out;
+struct net *copy_net_ns(unsigned long flags, struct net *old_net)
+{
+	if (!(flags & CLONE_NEWNET))
+		return get_net(old_net);
+	return net_create();
 }
 
 static void cleanup_net(struct work_struct *work)
