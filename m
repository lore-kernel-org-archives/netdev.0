From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH] Make inet_twsk_put similar to sock_put
Date: Wed, 6 May 2009 01:48:19 -0300
Message-ID: <20090506044819.GL2675@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45778 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbZEFEzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 00:55:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By separating the freeing code from the refcounting decrementing.
Probably reducing icache pressure when we still have reference counts to
go.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 8554d0e..68a8d89 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -49,19 +49,22 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 	inet_twsk_put(tw);
 }
 
-void inet_twsk_put(struct inet_timewait_sock *tw)
+static noinline void inet_twsk_free(struct inet_timewait_sock *tw)
 {
-	if (atomic_dec_and_test(&tw->tw_refcnt)) {
-		struct module *owner = tw->tw_prot->owner;
-		twsk_destructor((struct sock *)tw);
+	struct module *owner = tw->tw_prot->owner;
+	twsk_destructor((struct sock *)tw);
 #ifdef SOCK_REFCNT_DEBUG
-		printk(KERN_DEBUG "%s timewait_sock %p released\n",
-		       tw->tw_prot->name, tw);
+	pr_debug("%s timewait_sock %p released\n", tw->tw_prot->name, tw);
 #endif
-		release_net(twsk_net(tw));
-		kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
-		module_put(owner);
-	}
+	release_net(twsk_net(tw));
+	kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
+	module_put(owner);
+}
+
+void inet_twsk_put(struct inet_timewait_sock *tw)
+{
+	if (atomic_dec_and_test(&tw->tw_refcnt))
+		inet_twsk_free(tw);
 }
 EXPORT_SYMBOL_GPL(inet_twsk_put);
 
