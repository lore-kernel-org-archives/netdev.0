From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: net_families __rcu annotations
Date: Wed, 10 Nov 2010 21:50:44 +0100
Message-ID: <1289422244.17691.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38252 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab0KJUus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 15:50:48 -0500
Received: by wwb39 with SMTP id 39so1187974wwb.1
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 12:50:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use modern RCU API / annotations for net_families array.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/socket.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 3ca2fd9..c898df7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -156,7 +156,7 @@ static const struct file_operations socket_file_ops = {
  */
 
 static DEFINE_SPINLOCK(net_family_lock);
-static const struct net_proto_family *net_families[NPROTO] __read_mostly;
+static const struct net_proto_family __rcu *net_families[NPROTO] __read_mostly;
 
 /*
  *	Statistics counters of the socket lists
@@ -1200,7 +1200,7 @@ int __sock_create(struct net *net, int family, int type, int protocol,
 	 * requested real, full-featured networking support upon configuration.
 	 * Otherwise module support will break!
 	 */
-	if (net_families[family] == NULL)
+	if (rcu_access_pointer(net_families[family]) == NULL)
 		request_module("net-pf-%d", family);
 #endif
 
@@ -2332,10 +2332,11 @@ int sock_register(const struct net_proto_family *ops)
 	}
 
 	spin_lock(&net_family_lock);
-	if (net_families[ops->family])
+	if (rcu_dereference_protected(net_families[ops->family],
+				      lockdep_is_held(&net_family_lock)))
 		err = -EEXIST;
 	else {
-		net_families[ops->family] = ops;
+		rcu_assign_pointer(net_families[ops->family], ops);
 		err = 0;
 	}
 	spin_unlock(&net_family_lock);
@@ -2363,7 +2364,7 @@ void sock_unregister(int family)
 	BUG_ON(family < 0 || family >= NPROTO);
 
 	spin_lock(&net_family_lock);
-	net_families[family] = NULL;
+	rcu_assign_pointer(net_families[family], NULL);
 	spin_unlock(&net_family_lock);
 
 	synchronize_rcu();


