From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 9/9] AF_UNIX: implement poll(POLLOUT) for multicast sockets
Date: Mon, 22 Nov 2010 18:36:22 +0000
Message-ID: <1290450982-17480-9-git-send-email-alban.crequy@collabora.co.uk>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:38644 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757404Ab0KVSkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 13:40:03 -0500
In-Reply-To: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a socket subscribed to a multicast group has its incoming queue full, it
can either block the emission to the multicast group or let the messages be
dropped. The latter is useful to monitor all messages without slowing down the
traffic.

It is specified with the flag UNIX_MREQ_DROP_WHEN_FULL when the multicast group
is joined.

poll(POLLOUT) is implemented by checking all receiving queues of subscribed
sockets. If only one of them has its receiving queue full and does not have
UNIX_MREQ_DROP_WHEN_FULL, the multicast socket is not writeable.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 include/net/af_unix.h |    5 +++++
 net/unix/af_unix.c    |   38 ++++++++++++++++++++++++++++++++++++--
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index c82b5f8..d18499a 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -59,6 +59,10 @@ struct unix_skb_parms {
 /* ON UNIX_JOIN_GROUP: the messages will also be received by the peer */
 #define UNIX_MREQ_SEND_TO_PEER		0x04
 
+/* ON UNIX_JOIN_GROUP: just drop the message instead of blocking if the
+ * receiving queue is full */
+#define UNIX_MREQ_DROP_WHEN_FULL	0x08
+
 struct unix_mreq
 {
 	struct sockaddr_un	address;
@@ -84,6 +88,7 @@ struct unix_sock {
 	unsigned int		is_mcast_addr : 1;
 	unsigned int		mcast_auto_join : 1;
 	unsigned int		mcast_send_to_peer : 1;
+	unsigned int		mcast_drop_when_peer_full : 1;
 
 	/* These multicast fields are protected by the global spinlock
 	 * unix_multicast_lock */
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index d3d6270..36ee1fe 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -128,7 +128,8 @@ static atomic_long_t unix_nr_socks;
 struct sock_item {
 	struct sock *s;
 	struct sk_buff *skb;
-	int to_deliver;
+	unsigned int to_deliver : 1;
+	unsigned int drop_when_full : 1;
 };
 
 struct sock_set {
@@ -876,6 +877,8 @@ static int unix_find_multicast_members(struct sock_set *set,
 		set->items[set->cnt].s = &node->member->sk;
 		set->items[set->cnt].skb = NULL;
 		set->items[set->cnt].to_deliver = 1;
+		set->items[set->cnt].drop_when_full =
+			!!(node->flags & UNIX_MREQ_DROP_WHEN_FULL);
 		set->cnt++;
 	}
 
@@ -886,6 +889,8 @@ static int unix_find_multicast_members(struct sock_set *set,
 		set->items[set->cnt].s = unix_peer(sender);
 		set->items[set->cnt].skb = NULL;
 		set->items[set->cnt].to_deliver = 1;
+		set->items[set->cnt].drop_when_full =
+			unix_sk(sender)->mcast_drop_when_peer_full;
 		set->cnt++;
 	}
 
@@ -970,6 +975,7 @@ try_again:
 		set->items[0].s = dest;
 		set->items[0].skb = NULL;
 		set->items[0].to_deliver = 1;
+		set->items[0].drop_when_full = 0;
 	}
 	spin_unlock(&unix_multicast_lock);
 
@@ -1805,6 +1811,7 @@ restart:
 			kfree_skb(others_set->items[i].skb);
  
 			if (multicast_delivery) {
+				/* FIXME: check drop_when_full */
 				unix_state_unlock(cur);
 				others_set->items[i].to_deliver = 0;
 				continue;
@@ -1957,7 +1964,10 @@ static int unix_mc_join(struct socket *sock, struct unix_mreq *mreq)
 	node->flags = mreq->flags;
 
 	unix_state_lock(sock->sk);
-	unix_sk(sock->sk)->mcast_send_to_peer = !!(mreq->flags & UNIX_MREQ_SEND_TO_PEER);
+	unix_sk(sock->sk)->mcast_send_to_peer =
+		!!(mreq->flags & UNIX_MREQ_SEND_TO_PEER);
+	unix_sk(sock->sk)->mcast_drop_when_peer_full =
+		!!(mreq->flags & UNIX_MREQ_DROP_WHEN_FULL);
 	unix_state_unlock(sock->sk);
 
 	spin_lock(&unix_multicast_lock);
@@ -2258,6 +2268,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out_unlock;
 	}
 
+	/* FIXME: wake up peers on the multicast group too */
 	wake_up_interruptible_sync_poll(&u->peer_wait,
 					POLLOUT | POLLWRNORM | POLLWRBAND);
 
@@ -2613,6 +2624,9 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 {
 	struct sock *sk = sock->sk, *other;
 	unsigned int mask, writable;
+	struct sock_set *others;
+	int err = 0;
+	int i;
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask = 0;
@@ -2652,6 +2666,26 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 		}
 		sock_put(other);
 	}
+	/*
+	 * On multicast sockets, we need to check if the receiving queue is
+	 * full on all peers who don't have UNIX_MREQ_DROP_WHEN_FULL.
+	 */
+	others = unix_find_multicast_recipients(sk, NULL, &err);
+	if (!others)
+		goto skip_multicast;
+	for (i = 0 ; i < others->cnt ; i++) {
+		if (others->items[i].drop_when_full)
+			continue;
+		if (unix_peer(others->items[i].s) != sk) {
+			sock_poll_wait(file,
+				&unix_sk(others->items[i].s)->peer_wait, wait);
+			if (unix_recvq_full(others->items[i].s))
+				writable = 0;
+		}
+	}
+	kfree_sock_set(others);
+
+skip_multicast:
 
 	if (writable)
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
-- 
1.7.1

