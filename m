From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Revert "net: minor cleanup to net_namespace.c."
Date: Sun, 12 Jun 2011 14:09:50 +0300
Message-ID: <20110612110950.GA11321@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rlandley@parallels.com, jpirko@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37893 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378Ab1FLLJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 07:09:56 -0400
Received: by bwz15 with SMTP id 15so3106507bwz.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 04:09:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

git revert 911cb193f3eb0370f20fbba712211e55ffede4de

	commit 911cb193f3eb0370f20fbba712211e55ffede4de
	Author: Rob Landley <rlandley@parallels.com>
	Date:   Fri Apr 15 02:26:25 2011 +0000
	
	    net: minor cleanup to net_namespace.c.
	    
	    Inline a small static function that's only ever called from one place.
	    
	    Signed-off-by: Rob Landley <rlandley@parallels.com>
	    Reviewed-by: Jiri Pirko <jpirko@redhat.com>
	    Signed-off-by: David S. Miller <davem@davemloft.net>

Rationale for net_create() still holds:
* C/R and other out-of-tree code uses or will use it,
* permissions checks are separate thing (and different in C/R case),
* one function doesn't hurt anything.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/net_namespace.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -210,14 +210,11 @@ static void net_free(struct net *net)
 	kmem_cache_free(net_cachep, net);
 }
 
-struct net *copy_net_ns(unsigned long flags, struct net *old_net)
+static struct net *net_create(void)
 {
 	struct net *net;
 	int rv;
 
-	if (!(flags & CLONE_NEWNET))
-		return get_net(old_net);
-
 	net = net_alloc();
 	if (!net)
 		return ERR_PTR(-ENOMEM);
@@ -236,6 +233,13 @@ struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 	return net;
 }
 
+struct net *copy_net_ns(unsigned long flags, struct net *old_net)
+{
+	if (!(flags & CLONE_NEWNET))
+		return get_net(old_net);
+	return net_create();
+}
+
 static DEFINE_SPINLOCK(cleanup_list_lock);
 static LIST_HEAD(cleanup_list);  /* Must hold cleanup_list_lock to touch */
 
