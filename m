From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] pppoe: RCU locking in get_item_by_addr()
Date: Mon, 02 Nov 2009 06:51:22 +0100
Message-ID: <4AEE735A.4020601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54721 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbZKBFvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 00:51:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Note : this patch depends on dev_get_by_name_rcu(), not yet comitted.

Thanks

[PATCH net-next-2.6] pppoe: RCU locking in get_item_by_addr()

Use dev_get_by_name_rcu() instead of dev_get_by_name(),
to avoid touching device refcount in hotpath.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/pppoe.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 2559991..60c8d23 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -250,20 +250,19 @@ static inline struct pppox_sock *get_item_by_addr(struct net *net,
 {
 	struct net_device *dev;
 	struct pppoe_net *pn;
-	struct pppox_sock *pppox_sock;
+	struct pppox_sock *pppox_sock = NULL;
 
 	int ifindex;
 
-	dev = dev_get_by_name(net, sp->sa_addr.pppoe.dev);
-	if (!dev)
-		return NULL;
-
-	ifindex = dev->ifindex;
-	pn = net_generic(net, pppoe_net_id);
-	pppox_sock = get_item(pn, sp->sa_addr.pppoe.sid,
+	rcu_read_lock();
+	dev = dev_get_by_name_rcu(net, sp->sa_addr.pppoe.dev);
+	if (dev) {
+		ifindex = dev->ifindex;
+		pn = net_generic(net, pppoe_net_id);
+		pppox_sock = get_item(pn, sp->sa_addr.pppoe.sid,
 				sp->sa_addr.pppoe.remote, ifindex);
-	dev_put(dev);
-
+	}
+	rcu_read_unlock();
 	return pppox_sock;
 }
 
