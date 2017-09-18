From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/7] ipv6: speedup ipv6 tunnels dismantle
Date: Mon, 18 Sep 2017 12:07:32 -0700
Message-ID: <20170918190733.26272-7-edumazet@google.com>
References: <20170918190733.26272-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:46090 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbdIRTHu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:07:50 -0400
Received: by mail-pf0-f176.google.com with SMTP id e199so713192pfh.3
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:07:50 -0700 (PDT)
In-Reply-To: <20170918190733.26272-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement exit_batch() method to dismantle more devices
per round.

(rtnl_lock() ...
 unregister_netdevice_many() ...
 rtnl_unlock())

Tested:
$ cat add_del_unshare.sh
for i in `seq 1 40`
do
 (for j in `seq 1 100` ; do unshare -n /bin/true >/dev/null ; done) &
done
wait ; grep net_namespace /proc/slabinfo

Before patch :
$ time ./add_del_unshare.sh
net_namespace        110    267   5504    1    2 : tunables    8    4    0 : slabdata    110    267      0

real    3m25.292s
user    0m0.644s
sys     0m40.153s

After patch:

$ time ./add_del_unshare.sh
net_namespace        126    282   5504    1    2 : tunables    8    4    0 : slabdata    126    282      0

real	1m38.965s
user	0m0.688s
sys	0m37.017s

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_gre.c    |  8 +++++---
 net/ipv6/ip6_tunnel.c | 20 +++++++++++---------
 net/ipv6/ip6_vti.c    | 23 ++++++++++++++---------
 net/ipv6/sit.c        |  9 ++++++---
 4 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index b7a72d40933441f835708f55e2d8af371661a5fb..c82d41ef25e283ff92b1eed1f8b927c9d7b8f333 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1155,19 +1155,21 @@ static int __net_init ip6gre_init_net(struct net *net)
 	return err;
 }
 
-static void __net_exit ip6gre_exit_net(struct net *net)
+static void __net_exit ip6gre_exit_batch_net(struct list_head *net_list)
 {
+	struct net *net;
 	LIST_HEAD(list);
 
 	rtnl_lock();
-	ip6gre_destroy_tunnels(net, &list);
+	list_for_each_entry(net, net_list, exit_list)
+		ip6gre_destroy_tunnels(net, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
 
 static struct pernet_operations ip6gre_net_ops = {
 	.init = ip6gre_init_net,
-	.exit = ip6gre_exit_net,
+	.exit_batch = ip6gre_exit_batch_net,
 	.id   = &ip6gre_net_id,
 	.size = sizeof(struct ip6gre_net),
 };
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ae73164559d5c4d7f2650ae63c56d76dc93b165c..3d6df489b39f00014f330340927c4d11a64911c2 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -2167,17 +2167,16 @@ static struct xfrm6_tunnel ip6ip6_handler __read_mostly = {
 	.priority	=	1,
 };
 
-static void __net_exit ip6_tnl_destroy_tunnels(struct net *net)
+static void __net_exit ip6_tnl_destroy_tunnels(struct net *net, struct list_head *list)
 {
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 	struct net_device *dev, *aux;
 	int h;
 	struct ip6_tnl *t;
-	LIST_HEAD(list);
 
 	for_each_netdev_safe(net, dev, aux)
 		if (dev->rtnl_link_ops == &ip6_link_ops)
-			unregister_netdevice_queue(dev, &list);
+			unregister_netdevice_queue(dev, list);
 
 	for (h = 0; h < IP6_TUNNEL_HASH_SIZE; h++) {
 		t = rtnl_dereference(ip6n->tnls_r_l[h]);
@@ -2186,12 +2185,10 @@ static void __net_exit ip6_tnl_destroy_tunnels(struct net *net)
 			 * been added to the list by the previous loop.
 			 */
 			if (!net_eq(dev_net(t->dev), net))
-				unregister_netdevice_queue(t->dev, &list);
+				unregister_netdevice_queue(t->dev, list);
 			t = rtnl_dereference(t->next);
 		}
 	}
-
-	unregister_netdevice_many(&list);
 }
 
 static int __net_init ip6_tnl_init_net(struct net *net)
@@ -2235,16 +2232,21 @@ static int __net_init ip6_tnl_init_net(struct net *net)
 	return err;
 }
 
-static void __net_exit ip6_tnl_exit_net(struct net *net)
+static void __net_exit ip6_tnl_exit_batch_net(struct list_head *net_list)
 {
+	struct net *net;
+	LIST_HEAD(list);
+
 	rtnl_lock();
-	ip6_tnl_destroy_tunnels(net);
+	list_for_each_entry(net, net_list, exit_list)
+		ip6_tnl_destroy_tunnels(net, &list);
+	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
 
 static struct pernet_operations ip6_tnl_net_ops = {
 	.init = ip6_tnl_init_net,
-	.exit = ip6_tnl_exit_net,
+	.exit_batch = ip6_tnl_exit_batch_net,
 	.id   = &ip6_tnl_net_id,
 	.size = sizeof(struct ip6_tnl_net),
 };
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 79444a4bfd6d245b66a7edcefe2b5b32801bf2c0..714914d1bb987c46cc98817903ec7bcc367a1b2d 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -1052,23 +1052,22 @@ static struct rtnl_link_ops vti6_link_ops __read_mostly = {
 	.get_link_net	= ip6_tnl_get_link_net,
 };
 
-static void __net_exit vti6_destroy_tunnels(struct vti6_net *ip6n)
+static void __net_exit vti6_destroy_tunnels(struct vti6_net *ip6n,
+					    struct list_head *list)
 {
 	int h;
 	struct ip6_tnl *t;
-	LIST_HEAD(list);
 
 	for (h = 0; h < IP6_VTI_HASH_SIZE; h++) {
 		t = rtnl_dereference(ip6n->tnls_r_l[h]);
 		while (t) {
-			unregister_netdevice_queue(t->dev, &list);
+			unregister_netdevice_queue(t->dev, list);
 			t = rtnl_dereference(t->next);
 		}
 	}
 
 	t = rtnl_dereference(ip6n->tnls_wc[0]);
-	unregister_netdevice_queue(t->dev, &list);
-	unregister_netdevice_many(&list);
+	unregister_netdevice_queue(t->dev, list);
 }
 
 static int __net_init vti6_init_net(struct net *net)
@@ -1108,18 +1107,24 @@ static int __net_init vti6_init_net(struct net *net)
 	return err;
 }
 
-static void __net_exit vti6_exit_net(struct net *net)
+static void __net_exit vti6_exit_batch_net(struct list_head *net_list)
 {
-	struct vti6_net *ip6n = net_generic(net, vti6_net_id);
+	struct vti6_net *ip6n;
+	struct net *net;
+	LIST_HEAD(list);
 
 	rtnl_lock();
-	vti6_destroy_tunnels(ip6n);
+	list_for_each_entry(net, net_list, exit_list) {
+		ip6n = net_generic(net, vti6_net_id);
+		vti6_destroy_tunnels(ip6n, &list);
+	}
+	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
 
 static struct pernet_operations vti6_net_ops = {
 	.init = vti6_init_net,
-	.exit = vti6_exit_net,
+	.exit_batch = vti6_exit_batch_net,
 	.id   = &vti6_net_id,
 	.size = sizeof(struct vti6_net),
 };
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index ac912bb217471c048df3b76aa3d7b82886221dc1..a799f525861487ad5b822ab62cdc90f6ca06762f 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1848,19 +1848,22 @@ static int __net_init sit_init_net(struct net *net)
 	return err;
 }
 
-static void __net_exit sit_exit_net(struct net *net)
+static void __net_exit sit_exit_batch_net(struct list_head *net_list)
 {
 	LIST_HEAD(list);
+	struct net *net;
 
 	rtnl_lock();
-	sit_destroy_tunnels(net, &list);
+	list_for_each_entry(net, net_list, exit_list)
+		sit_destroy_tunnels(net, &list);
+
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
 
 static struct pernet_operations sit_net_ops = {
 	.init = sit_init_net,
-	.exit = sit_exit_net,
+	.exit_batch = sit_exit_batch_net,
 	.id   = &sit_net_id,
 	.size = sizeof(struct sit_net),
 };
-- 
2.14.1.690.gbb1197296e-goog
