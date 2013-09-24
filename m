From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] vxlan: Use RCU apis to access sk_user_data.
Date: Mon, 23 Sep 2013 22:28:21 -0700
Message-ID: <1380000501-13969-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:54413 "HELO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750714Ab3IXF2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 01:28:37 -0400
Received: by mail-ie0-f174.google.com with SMTP id u16so8100923iet.5
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 22:28:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of RCU api makes vxlan code easier to understand.  It also
fixes bug due to missing ACCESS_ONCE() on sk_user_data dereference.
In rare case without ACCESS_ONCE() compiler might omit vs on
sk_user_data dereference.
Compiler can use vs as alias for sk->sk_user_data, resulting in
multiple sk_user_data dereference in rcu read context which
could change.

CC: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |    9 +++------
 include/net/sock.h  |    2 ++
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d1292fe..3519a71 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -952,8 +952,7 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
-	smp_wmb();
-	vs->sock->sk->sk_user_data = NULL;
+	rcu_assign_pointer(sk_user_data_rcu(vs->sock->sk), NULL);
 	vxlan_notify_del_rx_port(sk);
 	spin_unlock(&vn->sock_lock);
 
@@ -1048,8 +1047,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	port = inet_sk(sk)->inet_sport;
 
-	smp_read_barrier_depends();
-	vs = (struct vxlan_sock *)sk->sk_user_data;
+	vs = rcu_dereference(sk_user_data_rcu(sk));
 	if (!vs)
 		goto drop;
 
@@ -2302,8 +2300,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	atomic_set(&vs->refcnt, 1);
 	vs->rcv = rcv;
 	vs->data = data;
-	smp_wmb();
-	vs->sock->sk->sk_user_data = vs;
+	rcu_assign_pointer(sk_user_data_rcu(vs->sock->sk), vs);
 
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
diff --git a/include/net/sock.h b/include/net/sock.h
index 6ba2e7b..ffd1356 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -409,6 +409,8 @@ struct sock {
 	void                    (*sk_destruct)(struct sock *sk);
 };
 
+#define sk_user_data_rcu(sk) ((*((void __rcu **)&(sk)->sk_user_data)))
+
 /*
  * SK_CAN_REUSE and SK_NO_REUSE on a socket mean that the socket is OK
  * or not whether his port will be reused by someone else. SK_FORCE_REUSE
-- 
1.7.1
