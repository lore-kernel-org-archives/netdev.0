From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 09/13] vxlan: provide access function for vxlan socket address family
Date: Tue, 18 Aug 2015 22:33:18 +0200
Message-ID: <a07e8ad2f7cfc3153d569a2b3f366bf17b2f348a.1439929916.git.jbenc@redhat.com>
References: <cover.1439929916.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753413AbbHRUdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:33:51 -0400
In-Reply-To: <cover.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 8 ++++----
 include/net/vxlan.h | 5 +++++
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e4b8ab63d0fa..d5ca1d7e0b81 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -236,7 +236,7 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, sa_family_t family,
 
 	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
 		if (inet_sk(vs->sock->sk)->inet_sport == port &&
-		    inet_sk(vs->sock->sk)->sk.sk_family == family &&
+		    vxlan_get_sk_family(vs) == family &&
 		    vs->flags == flags)
 			return vs;
 	}
@@ -625,7 +625,7 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 	struct net_device *dev;
 	struct sock *sk = vs->sock->sk;
 	struct net *net = sock_net(sk);
-	sa_family_t sa_family = sk->sk_family;
+	sa_family_t sa_family = vxlan_get_sk_family(vs);
 	__be16 port = inet_sk(sk)->inet_sport;
 	int err;
 
@@ -650,7 +650,7 @@ static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 	struct net_device *dev;
 	struct sock *sk = vs->sock->sk;
 	struct net *net = sock_net(sk);
-	sa_family_t sa_family = sk->sk_family;
+	sa_family_t sa_family = vxlan_get_sk_family(vs);
 	__be16 port = inet_sk(sk)->inet_sport;
 
 	rcu_read_lock();
@@ -2390,7 +2390,7 @@ void vxlan_get_rx_port(struct net_device *dev)
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
 		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
 			port = inet_sk(vs->sock->sk)->inet_sport;
-			sa_family = vs->sock->sk->sk_family;
+			sa_family = vxlan_get_sk_family(vs);
 			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
 							    port);
 		}
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index e4534f1b2d8c..43677e6b9c43 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -241,3 +241,8 @@ static inline void vxlan_get_rx_port(struct net_device *netdev)
 }
 #endif
 #endif
+
+static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
+{
+	return vs->sock->sk->sk_family;
+}
-- 
1.8.3.1
