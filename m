From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 7/7] ipv4: speedup ipv6 tunnels dismantle
Date: Mon, 18 Sep 2017 12:07:33 -0700
Message-ID: <20170918190733.26272-8-edumazet@google.com>
References: <20170918190733.26272-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:44850 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751372AbdIRTHz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:07:55 -0400
Received: by mail-pf0-f175.google.com with SMTP id e1so716125pfk.1
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:07:54 -0700 (PDT)
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
net_namespace        126    282   5504    1    2 : tunables    8    4    0 : slabdata    126    282      0

real    1m38.965s
user    0m0.688s
sys     0m37.017s

After patch:
$ time ./add_del_unshare.sh
net_namespace        135    291   5504    1    2 : tunables    8    4    0 : slabdata    135    291      0

real	0m22.117s
user	0m0.728s
sys	0m35.328s

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip_tunnels.h |  3 ++-
 net/ipv4/ip_gre.c        | 22 +++++++++-------------
 net/ipv4/ip_tunnel.c     | 13 ++++++++++---
 net/ipv4/ip_vti.c        |  7 +++----
 net/ipv4/ipip.c          |  7 +++----
 5 files changed, 27 insertions(+), 25 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 992652856fe8c7c1032e0f5f92ce7ee5aa0119da..b41a1e057fcec9d6e4c5a0c1cafd1f1d537ccd53 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -258,7 +258,8 @@ int ip_tunnel_get_iflink(const struct net_device *dev);
 int ip_tunnel_init_net(struct net *net, unsigned int ip_tnl_net_id,
 		       struct rtnl_link_ops *ops, char *devname);
 
-void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
+void ip_tunnel_delete_nets(struct list_head *list_net, unsigned int id,
+			   struct rtnl_link_ops *ops);
 
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0162fb955b33abf18514cbfd482e72a0ebce6e48..9cee986ac6b8ed04ff95e193fe1e8e60e74d84a9 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1013,15 +1013,14 @@ static int __net_init ipgre_init_net(struct net *net)
 	return ip_tunnel_init_net(net, ipgre_net_id, &ipgre_link_ops, NULL);
 }
 
-static void __net_exit ipgre_exit_net(struct net *net)
+static void __net_exit ipgre_exit_batch_net(struct list_head *list_net)
 {
-	struct ip_tunnel_net *itn = net_generic(net, ipgre_net_id);
-	ip_tunnel_delete_net(itn, &ipgre_link_ops);
+	ip_tunnel_delete_nets(list_net, ipgre_net_id, &ipgre_link_ops);
 }
 
 static struct pernet_operations ipgre_net_ops = {
 	.init = ipgre_init_net,
-	.exit = ipgre_exit_net,
+	.exit_batch = ipgre_exit_batch_net,
 	.id   = &ipgre_net_id,
 	.size = sizeof(struct ip_tunnel_net),
 };
@@ -1540,15 +1539,14 @@ static int __net_init ipgre_tap_init_net(struct net *net)
 	return ip_tunnel_init_net(net, gre_tap_net_id, &ipgre_tap_ops, "gretap0");
 }
 
-static void __net_exit ipgre_tap_exit_net(struct net *net)
+static void __net_exit ipgre_tap_exit_batch_net(struct list_head *list_net)
 {
-	struct ip_tunnel_net *itn = net_generic(net, gre_tap_net_id);
-	ip_tunnel_delete_net(itn, &ipgre_tap_ops);
+	ip_tunnel_delete_nets(list_net, gre_tap_net_id, &ipgre_tap_ops);
 }
 
 static struct pernet_operations ipgre_tap_net_ops = {
 	.init = ipgre_tap_init_net,
-	.exit = ipgre_tap_exit_net,
+	.exit_batch = ipgre_tap_exit_batch_net,
 	.id   = &gre_tap_net_id,
 	.size = sizeof(struct ip_tunnel_net),
 };
@@ -1559,16 +1557,14 @@ static int __net_init erspan_init_net(struct net *net)
 				  &erspan_link_ops, "erspan0");
 }
 
-static void __net_exit erspan_exit_net(struct net *net)
+static void __net_exit erspan_exit_batch_net(struct list_head *net_list)
 {
-	struct ip_tunnel_net *itn = net_generic(net, erspan_net_id);
-
-	ip_tunnel_delete_net(itn, &erspan_link_ops);
+	ip_tunnel_delete_nets(net_list, erspan_net_id, &erspan_link_ops);
 }
 
 static struct pernet_operations erspan_net_ops = {
 	.init = erspan_init_net,
-	.exit = erspan_exit_net,
+	.exit_batch = erspan_exit_batch_net,
 	.id   = &erspan_net_id,
 	.size = sizeof(struct ip_tunnel_net),
 };
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e9805ad664ac24c3405ad015cfaab89dc1c95279..a85a798b521093b38ff2d73b23eba9f26a6bbf0d 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -1056,21 +1056,28 @@ static void ip_tunnel_destroy(struct ip_tunnel_net *itn, struct list_head *head,
 			/* If dev is in the same netns, it has already
 			 * been added to the list by the previous loop.
 			 */
+// TODO use list_empty(&t->dev->unreg_list) in unregister_netdevice_queue ?
 			if (!net_eq(dev_net(t->dev), net))
 				unregister_netdevice_queue(t->dev, head);
 	}
 }
 
-void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops)
+void ip_tunnel_delete_nets(struct list_head *net_list, unsigned int id,
+			   struct rtnl_link_ops *ops)
 {
+	struct ip_tunnel_net *itn;
+	struct net *net;
 	LIST_HEAD(list);
 
 	rtnl_lock();
-	ip_tunnel_destroy(itn, &list, ops);
+	list_for_each_entry(net, net_list, exit_list) {
+		itn = net_generic(net, id);
+		ip_tunnel_destroy(itn, &list, ops);
+	}
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
-EXPORT_SYMBOL_GPL(ip_tunnel_delete_net);
+EXPORT_SYMBOL_GPL(ip_tunnel_delete_nets);
 
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		      struct ip_tunnel_parm *p, __u32 fwmark)
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 5ed63d25095062d44dacfd291e227290d24ea0ed..02d70ca99db16f2a50e3e179a05e74b535865f46 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -452,15 +452,14 @@ static int __net_init vti_init_net(struct net *net)
 	return 0;
 }
 
-static void __net_exit vti_exit_net(struct net *net)
+static void __net_exit vti_exit_batch_net(struct list_head *list_net)
 {
-	struct ip_tunnel_net *itn = net_generic(net, vti_net_id);
-	ip_tunnel_delete_net(itn, &vti_link_ops);
+	ip_tunnel_delete_nets(list_net, vti_net_id, &vti_link_ops);
 }
 
 static struct pernet_operations vti_net_ops = {
 	.init = vti_init_net,
-	.exit = vti_exit_net,
+	.exit_batch = vti_exit_batch_net,
 	.id   = &vti_net_id,
 	.size = sizeof(struct ip_tunnel_net),
 };
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index fb1ad22b5e292d5669c70b5640ad3207c353c6bb..1e47818e38c766a3dab63dfa6bfa9610fa9550ac 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -634,15 +634,14 @@ static int __net_init ipip_init_net(struct net *net)
 	return ip_tunnel_init_net(net, ipip_net_id, &ipip_link_ops, "tunl0");
 }
 
-static void __net_exit ipip_exit_net(struct net *net)
+static void __net_exit ipip_exit_batch_net(struct list_head *list_net)
 {
-	struct ip_tunnel_net *itn = net_generic(net, ipip_net_id);
-	ip_tunnel_delete_net(itn, &ipip_link_ops);
+	ip_tunnel_delete_nets(list_net, ipip_net_id, &ipip_link_ops);
 }
 
 static struct pernet_operations ipip_net_ops = {
 	.init = ipip_init_net,
-	.exit = ipip_exit_net,
+	.exit_batch = ipip_exit_batch_net,
 	.id   = &ipip_net_id,
 	.size = sizeof(struct ip_tunnel_net),
 };
-- 
2.14.1.690.gbb1197296e-goog
