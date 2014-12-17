From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 1/2] geneve: Remove socket and offload handlers at destruction.
Date: Tue, 16 Dec 2014 18:25:31 -0800
Message-ID: <1418783132-99230-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:49348 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750939AbaLQCcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 21:32:41 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so15312596pad.41
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 18:32:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sockets aren't currently removed from the the global list when
they are destroyed. In addition, offload handlers need to be cleaned
up as well.

Fixes: 0b5e8b8e ("net: Add Geneve tunneling protocol driver")
CC: Andy Zhou <azhou@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/ipv4/geneve.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index a457232..5a47188 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -159,6 +159,15 @@ static void geneve_notify_add_rx_port(struct geneve_sock *gs)
 	}
 }
 
+static void geneve_notify_del_rx_port(struct geneve_sock *gs)
+{
+	struct sock *sk = gs->sock->sk;
+	sa_family_t sa_family = sk->sk_family;
+
+	if (sa_family == AF_INET)
+		udp_del_offload(&gs->udp_offloads);
+}
+
 /* Callback from net/ipv4/udp.c to receive packets */
 static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
@@ -312,9 +321,17 @@ EXPORT_SYMBOL_GPL(geneve_sock_add);
 
 void geneve_sock_release(struct geneve_sock *gs)
 {
+	struct net *net = sock_net(gs->sock->sk);
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+
 	if (!atomic_dec_and_test(&gs->refcnt))
 		return;
 
+	spin_lock(&gn->sock_lock);
+	hlist_del_rcu(&gs->hlist);
+	geneve_notify_del_rx_port(gs);
+	spin_unlock(&gn->sock_lock);
+
 	queue_work(geneve_wq, &gs->del_work);
 }
 EXPORT_SYMBOL_GPL(geneve_sock_release);
-- 
1.9.1
