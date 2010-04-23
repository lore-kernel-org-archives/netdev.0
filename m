From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] l2tp: fix memory allocation
Date: Fri, 23 Apr 2010 12:53:39 +0200
Message-ID: <20100423105338.GA2853@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kleptog@svana.org, jchapman@katalix.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab0DWKyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 06:54:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since .size is set properly in "struct pernet_operations l2tp_net_ops",
allocating space for "struct l2tp_net" by hand is not correct, even causes
memory leakage.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index ecc7aea..1712af1 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1617,14 +1617,9 @@ EXPORT_SYMBOL_GPL(l2tp_session_create);
 
 static __net_init int l2tp_init_net(struct net *net)
 {
-	struct l2tp_net *pn;
-	int err;
+	struct l2tp_net *pn = net_generic(net, l2tp_net_id);
 	int hash;
 
-	pn = kzalloc(sizeof(*pn), GFP_KERNEL);
-	if (!pn)
-		return -ENOMEM;
-
 	INIT_LIST_HEAD(&pn->l2tp_tunnel_list);
 	spin_lock_init(&pn->l2tp_tunnel_list_lock);
 
@@ -1633,33 +1628,11 @@ static __net_init int l2tp_init_net(struct net *net)
 
 	spin_lock_init(&pn->l2tp_session_hlist_lock);
 
-	err = net_assign_generic(net, l2tp_net_id, pn);
-	if (err)
-		goto out;
-
 	return 0;
-
-out:
-	kfree(pn);
-	return err;
-}
-
-static __net_exit void l2tp_exit_net(struct net *net)
-{
-	struct l2tp_net *pn;
-
-	pn = net_generic(net, l2tp_net_id);
-	/*
-	 * if someone has cached our net then
-	 * further net_generic call will return NULL
-	 */
-	net_assign_generic(net, l2tp_net_id, NULL);
-	kfree(pn);
 }
 
 static struct pernet_operations l2tp_net_ops = {
 	.init = l2tp_init_net,
-	.exit = l2tp_exit_net,
 	.id   = &l2tp_net_id,
 	.size = sizeof(struct l2tp_net),
 };
