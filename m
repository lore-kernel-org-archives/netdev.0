From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 5/9] AF_UNIX: Deliver message to several recipients in case of multicast
Date: Mon, 22 Nov 2010 18:36:18 +0000
Message-ID: <1290450982-17480-5-git-send-email-alban.crequy@collabora.co.uk>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

unix_dgram_sendmsg() implements the delivery both for SOCK_DGRAM and
SOCK_SEQPACKET Unix sockets.

The delivery is done in an atomic way: either the message is delivered to all
recipients or none, even in case of interruptions or errors.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 net/unix/af_unix.c |  247 +++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 188 insertions(+), 59 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3cc9695..9207393 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1553,16 +1553,17 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
-	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr = msg->msg_name;
-	struct sock *other = NULL;
+	struct sock_set *others_set = NULL;
 	int namelen = 0; /* fake GCC */
 	int err;
 	unsigned hash;
 	struct sk_buff *skb;
+	int i;
 	long timeo;
 	struct scm_cookie tmp_scm;
+	int multicast_delivery = !!u->mcast_subscriptions_cnt;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1580,12 +1581,30 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		if (err < 0)
 			goto out;
 		namelen = err;
-	} else {
+	} else if (!multicast_delivery) {
+		struct sock *other;
 		sunaddr = NULL;
 		err = -ENOTCONN;
 		other = unix_peer_get(sk);
 		if (!other)
 			goto out;
+		err = -ENOMEM;
+		others_set = kmalloc(sizeof(struct sock_set)
+				     + sizeof(struct sock_item),
+				     GFP_KERNEL);
+		if (!others_set)
+			goto out;
+		others_set->cnt = 1;
+		sock_hold(other);
+		others_set->items[0].s = other;
+		others_set->items[0].skb = NULL;
+		others_set->items[0].to_deliver = 1;
+	} else {
+		sunaddr = NULL;
+		err = -ENOTCONN;
+		others_set = unix_find_multicast_recipients(sk, NULL, &err);
+		if (!others_set)
+			goto out;
 	}
 
 	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr
@@ -1613,90 +1632,200 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
 
 restart:
-	if (!other) {
+	if (!others_set) {
+		struct sock *other;
+		struct unix_sock *otheru;
 		err = -ECONNRESET;
 		if (sunaddr == NULL)
 			goto out_free;
 
-		other = unix_find_other(net, sunaddr, namelen, sk->sk_type,
-					hash, &err);
-		if (other == NULL)
+		other = unix_find_other(sock_net(sk), sunaddr, namelen,
+					sk->sk_type, hash, &err);
+		if (!other)
 			goto out_free;
+		otheru = unix_sk(other);
+
+		if (otheru->is_mcast_addr) {
+			/* FIXME: we should send to the requested recipient
+			 * specified in sendto(...dest_addr) instead of the
+			 * recipient specified by setsockopt... */
+			sock_put(other);
+			others_set = unix_find_multicast_recipients(sk, other,
+								    &err);
+			if (!others_set)
+				goto out_free;
+		} else {
+			others_set = kmalloc(sizeof(struct sock_set)
+					     + sizeof(struct sock_item),
+					     GFP_KERNEL);
+			if (!others_set)
+				goto out_free;
+			others_set->cnt = 1;
+			others_set->items[0].s = other;
+			others_set->items[0].skb = NULL;
+			others_set->items[0].to_deliver = 1;
+		}
 	}
 
-	unix_state_lock(other);
-	err = -EPERM;
-	if (!unix_may_send(sk, other))
-		goto out_unlock;
+	for (i = 0 ; i < others_set->cnt ; i++) {
+		struct sock *cur = others_set->items[i].s;
 
-	if (sock_flag(other, SOCK_DEAD)) {
-		/*
-		 *	Check with 1003.1g - what should
-		 *	datagram error
-		 */
-		unix_state_unlock(other);
-		sock_put(other);
+		others_set->items[i].skb = skb_clone(skb, GFP_KERNEL);
+		if (!others_set->items[i].skb) {
+			err = -ENOMEM;
+			goto out_free;
+		}
+		skb_set_owner_w(others_set->items[i].skb, sk);
+	}
 
-		err = 0;
-		unix_state_lock(sk);
-		if (unix_peer(sk) == other) {
-			unix_peer(sk) = NULL;
-			unix_state_unlock(sk);
+	for (i = 0 ; i < others_set->cnt ; i++) {
+		struct sock *cur = others_set->items[i].s;
 
-			unix_dgram_disconnected(sk, other);
-			sock_put(other);
-			err = -ECONNREFUSED;
-		} else {
-			unix_state_unlock(sk);
+		if (!others_set->items[i].to_deliver)
+			continue;
+
+		unix_state_lock(cur);
+		err = -EPERM;
+		if (!multicast_delivery && !unix_may_send(sk, cur)) {
+			others_set->items[i].to_deliver = 0;
+			unix_state_unlock(cur);
+			kfree_skb(others_set->items[i].skb);
+			if (multicast_delivery)
+				continue;
+			else
+				goto out_free;
 		}
 
-		other = NULL;
-		if (err)
-			goto out_free;
-		goto restart;
+		if (sock_flag(cur, SOCK_DEAD)) {
+			/*
+			 *	Check with 1003.1g - what should
+			 *	datagram error
+			 */
+			unix_state_unlock(cur);
+
+			err = 0;
+			unix_state_lock(sk);
+			if (unix_peer(sk) == cur) {
+				unix_peer(sk) = NULL;
+				unix_state_unlock(sk);
+
+				unix_dgram_disconnected(sk, cur);
+				sock_put(cur);
+				err = -ECONNREFUSED;
+			} else {
+				unix_state_unlock(sk);
+			}
+
+			kfree_skb(others_set->items[i].skb);
+			if (err)
+				goto out_free;
+
+			if (multicast_delivery) {
+				others_set->items[i].to_deliver = 0;
+				continue;
+			} else {
+				kfree_sock_set(others_set);
+				others_set = NULL;
+				goto restart;
+			}
+		}
+
+		err = -EPIPE;
+		if (cur->sk_shutdown & RCV_SHUTDOWN) {
+			unix_state_unlock(cur);
+			kfree_skb(others_set->items[i].skb);
+			if (multicast_delivery) {
+				others_set->items[i].to_deliver = 0;
+				continue;
+			} else {
+				goto out_free;
+			}
+		}
+
+		if (sk->sk_type != SOCK_SEQPACKET) {
+			err = security_unix_may_send(sk->sk_socket,
+						     cur->sk_socket);
+			if (err) {
+				unix_state_unlock(cur);
+				kfree_skb(others_set->items[i].skb);
+				if (multicast_delivery) {
+					others_set->items[i].to_deliver = 0;
+					continue;
+				} else {
+					goto out_free;
+				}
+			}
+		}
+
+		if (unix_peer(cur) != sk && unix_recvq_full(cur)) {
+			kfree_skb(others_set->items[i].skb);
+ 
+			if (multicast_delivery) {
+				unix_state_unlock(cur);
+				others_set->items[i].to_deliver = 0;
+				continue;
+			} else {
+				if (!timeo) {
+					unix_state_unlock(cur);
+					err = -EAGAIN;
+					goto out_free;
+				}
+
+				timeo = unix_wait_for_peer(cur, timeo);
+
+				err = sock_intr_errno(timeo);
+				if (signal_pending(current))
+					goto out_free;
+
+				kfree_sock_set(others_set);
+				others_set = NULL;
+				goto restart;
+			}
+		}
 	}
 
-	err = -EPIPE;
-	if (other->sk_shutdown & RCV_SHUTDOWN)
-		goto out_unlock;
+	for (i = 0 ; i < others_set->cnt ; i++) {
+		struct sock *cur = others_set->items[i].s;
 
-	if (sk->sk_type != SOCK_SEQPACKET) {
-		err = security_unix_may_send(sk->sk_socket, other->sk_socket);
-		if (err)
-			goto out_unlock;
+		if (!others_set->items[i].to_deliver)
+			continue;
+
+		if (sock_flag(cur, SOCK_RCVTSTAMP))
+			__net_timestamp(others_set->items[i].skb);
+
+		skb_queue_tail(&cur->sk_receive_queue,
+			       others_set->items[i].skb);
 	}
 
-	if (unix_peer(other) != sk && unix_recvq_full(other)) {
-		if (!timeo) {
-			err = -EAGAIN;
-			goto out_unlock;
-		}
+	for (i = 0 ; i < others_set->cnt ; i++) {
+		struct sock *cur = others_set->items[i].s;
 
-		timeo = unix_wait_for_peer(other, timeo);
+		if (!others_set->items[i].to_deliver)
+			continue;
 
-		err = sock_intr_errno(timeo);
-		if (signal_pending(current))
-			goto out_free;
+		unix_state_unlock(cur);
+	}
 
-		goto restart;
+	for (i = 0 ; i < others_set->cnt ; i++) {
+		struct sock *cur = others_set->items[i].s;
+
+		if (!others_set->items[i].to_deliver)
+			continue;
+
+		cur->sk_data_ready(cur, len);
 	}
 
-	if (sock_flag(other, SOCK_RCVTSTAMP))
-		__net_timestamp(skb);
-	skb_queue_tail(&other->sk_receive_queue, skb);
-	unix_state_unlock(other);
-	other->sk_data_ready(other, len);
-	sock_put(other);
+	kfree_skb(skb);
 	scm_destroy(siocb->scm);
+	if (others_set)
+		kfree_sock_set(others_set);
 	return len;
 
-out_unlock:
-	unix_state_unlock(other);
 out_free:
 	kfree_skb(skb);
 out:
-	if (other)
-		sock_put(other);
+	if (others_set)
+		kfree_sock_set(others_set);
 	scm_destroy(siocb->scm);
 	return err;
 }
-- 
1.7.1
