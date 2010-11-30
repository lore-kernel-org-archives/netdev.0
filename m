From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/8] inetpeer: Add v6 peers tree, abstract root properly.
Date: Tue, 30 Nov 2010 13:22:09 -0800 (PST)
Message-ID: <20101130.132209.245417408.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58860
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751933Ab0K3VVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 16:21:42 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5178324C088
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:22:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add the ipv6 peer tree instance, and adapt remaining
direct references to 'v4_peers' as needed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inetpeer.c |   27 ++++++++++++++++++---------
 1 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index c96dc51..1c1335b 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -79,15 +79,24 @@ static const struct inet_peer peer_fake_node = {
 	.avl_height	= 0
 };
 
-static struct inet_peer_base {
+struct inet_peer_base {
 	struct inet_peer __rcu *root;
 	spinlock_t	lock;
 	int		total;
-} v4_peers = {
+};
+
+static struct inet_peer_base v4_peers = {
 	.root		= peer_avl_empty_rcu,
 	.lock		= __SPIN_LOCK_UNLOCKED(v4_peers.lock),
 	.total		= 0,
 };
+
+static struct inet_peer_base v6_peers = {
+	.root		= peer_avl_empty_rcu,
+	.lock		= __SPIN_LOCK_UNLOCKED(v6_peers.lock),
+	.total		= 0,
+};
+
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
 
 /* Exported for sysctl_net_ipv4.  */
@@ -415,9 +424,14 @@ static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base)
 		inet_putpeer(p);
 }
 
+static struct inet_peer_base *family_to_base(int family)
+{
+	return (family == AF_INET ? &v4_peers : &v6_peers);
+}
+
 static struct inet_peer_base *peer_to_base(struct inet_peer *p)
 {
-	return &v4_peers;
+	return family_to_base(p->daddr.family);
 }
 
 /* May be called with local BH enabled. */
@@ -457,11 +471,6 @@ static int cleanup_once(unsigned long ttl)
 	return 0;
 }
 
-static struct inet_peer_base *family_to_base(int family)
-{
-	return &v4_peers;
-}
-
 /* Called with or without local BH being disabled. */
 struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int create)
 {
@@ -521,7 +530,7 @@ struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int create)
 
 static int compute_total(void)
 {
-	return v4_peers.total;
+	return v4_peers.total + v6_peers.total;
 }
 
 /* Called with local BH disabled. */
-- 
1.7.3.2

