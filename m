From: Iulius Curt <iulius.curt@gmail.com>
Subject: [RFC] packet: change call of synchronize_net to call_rcu
Date: Tue,  4 Sep 2012 17:16:55 +0300
Message-ID: <1346768215-5194-1-git-send-email-icurt@ixiacom.com>
Cc: edumazet@google.com, daniel.borkmann@tik.ee.ethz.ch,
	xemul@parallels.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dbaluta@ixiacom.com,
	Iulius Curt <icurt@ixiacom.com>,
	Sorin Dumitru <sdumitru@ixiacom.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

synchronize_net is called every time we close a PF_PACKET socket which is
causing performance loss when doing this on many sockets.

Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>
Signed-off-by: Iulius Curt <icurt@ixiacom.com>
---
Statistics using test program [1]

Sockets count  |  Not patched  |  Patched
_________________________________________
    1 000 000  |       1.28 s  |   1.22 s
    5 000 000  |        7.3 s  |   6.25 s
   50 000 000  |      72.89 s  |  64.41 s

[1] http://pastebin.com/xQ9BziaP
---
 net/packet/af_packet.c |   46 ++++++++++++++++++++++++++++++++++++----------
 net/packet/internal.h  |    1 +
 2 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 5dafe84..7b60135 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2299,6 +2299,32 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
 		return packet_snd(sock, msg, len);
 }
 
+void packet_release_finish(struct sock *sk, int null)
+{
+	struct socket *sock = sk->sk_socket;
+
+	sock_orphan(sk);
+	/* Modifing this after the socket has been released
+	 * might lead to memory corruption so we don't do it */
+	if (null)
+		sock->sk = NULL;
+
+	/* Purge queues */
+
+	skb_queue_purge(&sk->sk_receive_queue);
+	sk_refcnt_debug_release(sk);
+
+	sock_put(sk);
+}
+
+void packet_release_rcu(struct rcu_head *rcu)
+{
+	struct packet_sock *po = container_of(rcu, struct packet_sock, rcu_head);
+	struct sock *sk = &po->sk;
+
+	packet_release_finish(sk, 0);
+}
+
 /*
  *	Close a PACKET socket. This is fairly simple. We immediately go
  *	to 'closed' state and remove our protocol entry in the device list.
@@ -2310,6 +2336,7 @@ static int packet_release(struct socket *sock)
 	struct packet_sock *po;
 	struct net *net;
 	union tpacket_req_u req_u;
+	int postpone = 0;
 
 	if (!sk)
 		return 0;
@@ -2326,7 +2353,10 @@ static int packet_release(struct socket *sock)
 	preempt_enable();
 
 	spin_lock(&po->bind_lock);
-	unregister_prot_hook(sk, false);
+	if (po->running) {
+		postpone = 1;
+		__unregister_prot_hook(sk, false);
+	}
 	if (po->prot_hook.dev) {
 		dev_put(po->prot_hook.dev);
 		po->prot_hook.dev = NULL;
@@ -2345,19 +2375,15 @@ static int packet_release(struct socket *sock)
 
 	fanout_release(sk);
 
-	synchronize_net();
 	/*
 	 *	Now the socket is dead. No more input will appear.
 	 */
-	sock_orphan(sk);
-	sock->sk = NULL;
-
-	/* Purge queues */
-
-	skb_queue_purge(&sk->sk_receive_queue);
-	sk_refcnt_debug_release(sk);
+	if (postpone) {
+		call_rcu(&po->rcu_head, packet_release_rcu);
+		return 0;
+	}
 
-	sock_put(sk);
+	packet_release_finish(sk, 1);
 	return 0;
 }
 
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 44945f6..5778c12 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -104,6 +104,7 @@ struct packet_sock {
 	int			ifindex;	/* bound device		*/
 	__be16			num;
 	struct packet_mclist	*mclist;
+	struct rcu_head		rcu_head;
 	atomic_t		mapped;
 	enum tpacket_versions	tp_version;
 	unsigned int		tp_hdrlen;
-- 
1.7.9.5
