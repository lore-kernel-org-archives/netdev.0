From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] vxlan: Optimize vxlan rcv
Date: Tue,  3 Sep 2013 09:44:44 -0700
Message-ID: <1378226684-7751-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:44947 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932217Ab3ICQou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 12:44:50 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so6640689pad.30
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 09:44:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan-udp-recv function lookup vxlan_sock struct on every packet
recv by using udp-port number. we can use sk->sk_user_data to
store vxlan_sock and avoid lookup.
I have open coded rcu-api to store and read vxlan_sock from
sk_user_data to avoid sparse warning as sk_user_data is not
__rcu pointer.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6b560f3..7de131f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -916,6 +916,8 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
+	smp_wmb();
+	vs->sock->sk->sk_user_data = NULL;
 	spin_unlock(&vn->sock_lock);
 
 	queue_work(vxlan_wq, &vs->del_work);
@@ -1009,7 +1011,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	port = inet_sk(sk)->inet_sport;
 
-	vs = vxlan_find_sock(sock_net(sk), port);
+	smp_read_barrier_depends();
+	vs = (struct vxlan_sock *)sk->sk_user_data;
 	if (!vs)
 		goto drop;
 
@@ -2236,6 +2239,8 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	atomic_set(&vs->refcnt, 1);
 	vs->rcv = rcv;
 	vs->data = data;
+	smp_wmb();
+	vs->sock->sk->sk_user_data = vs;
 
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
-- 
1.7.1
