From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] l2tp_eth: fix memory allocation
Date: Fri, 23 Apr 2010 13:01:52 +0200
Message-ID: <20100423110151.GB2853@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kleptog@svana.org, jchapman@katalix.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440Ab0DWLCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 07:02:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since .size is set properly in "struct pernet_operations l2tp_eth_net_ops",
allocating space for "struct l2tp_eth_net" by hand is not correct, even causes
memory leakage.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index ca1164a..58c6c4c 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -276,43 +276,16 @@ out:
 
 static __net_init int l2tp_eth_init_net(struct net *net)
 {
-	struct l2tp_eth_net *pn;
-	int err;
-
-	pn = kzalloc(sizeof(*pn), GFP_KERNEL);
-	if (!pn)
-		return -ENOMEM;
+	struct l2tp_eth_net *pn = net_generic(net, l2tp_eth_net_id);
 
 	INIT_LIST_HEAD(&pn->l2tp_eth_dev_list);
 	spin_lock_init(&pn->l2tp_eth_lock);
 
-	err = net_assign_generic(net, l2tp_eth_net_id, pn);
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
-static __net_exit void l2tp_eth_exit_net(struct net *net)
-{
-	struct l2tp_eth_net *pn;
-
-	pn = net_generic(net, l2tp_eth_net_id);
-	/*
-	 * if someone has cached our net then
-	 * further net_generic call will return NULL
-	 */
-	net_assign_generic(net, l2tp_eth_net_id, NULL);
-	kfree(pn);
 }
 
 static __net_initdata struct pernet_operations l2tp_eth_net_ops = {
 	.init = l2tp_eth_init_net,
-	.exit = l2tp_eth_exit_net,
 	.id   = &l2tp_eth_net_id,
 	.size = sizeof(struct l2tp_eth_net),
 };
