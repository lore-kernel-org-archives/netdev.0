From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 5/5] AF_UNIX: deliver the data to all the multicast peers
Date: Fri, 24 Sep 2010 18:25:16 +0100
Message-ID: <1285349116-17529-5-git-send-email-alban.crequy@collabora.co.uk>
References: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbus@freedesktop.org, Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With multicast sockets, unix_stream_sendmsg() needs to deliver the data to
zero, one or several recipients. skb_clone() is used to get as many sk_buff as
recipients.

If a multicast peer is too slow to receive the packets, it will block the
sender at some point in sock_alloc_send_skb().

A sender can receive SIGPIPE caused by an unique peer on the multicast group.
This is probably not what we want.

I tested this with a few peers and either sending data, receiving data or just
sleeping.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 net/unix/af_unix.c |   77 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 53 insertions(+), 24 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f259849..01cb603 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1640,10 +1640,10 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
 	struct sock **others = NULL;
+	struct sock **others_cur = NULL;
 	int max_others;
 	struct sockaddr_un *sunaddr = msg->msg_name;
 	int err, size;
-	struct sk_buff *skb;
 	int sent = 0;
 	struct scm_cookie tmp_scm;
 	bool fds_sent = false;
@@ -1668,15 +1668,22 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		other = unix_peer(sk);
 		if (!other)
 			goto out_err;
+		err = -ENOMEM;
+		others = kzalloc(2 * sizeof(void *), GFP_KERNEL);
+		if (!others)
+			goto out_err;
+		others[0] = other;
 	} else {
 		sunaddr = NULL;
-		err = -ENOTCONN;
 		max_others = atomic_read(&unix_nr_multicast_socks);
+		err = -ENOMEM;
 		others = kzalloc((max_others + 1) * sizeof(void *), GFP_KERNEL);
+		if (!others)
+			goto out_err;
 		unix_find_other(sock_net(sk), u->addr->name,
 		    u->addr->len, 0, u->addr->hash, 1, others, max_others, &err);
+		err = -ENOTCONN;
 		other = others[0];
-		kfree(others);
 		if (!other)
 			goto out_err;
 	}
@@ -1685,6 +1692,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		goto pipe_err;
 
 	while (sent < len) {
+		struct sk_buff *skb;
+		struct sk_buff *skb_cloned;
 		/*
 		 *	Optimisation for the fact that under 0.01% of X
 		 *	messages typically need breaking up.
@@ -1718,43 +1727,61 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		 */
 		size = min_t(int, size, skb_tailroom(skb));
 
-		memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
-		/* Only send the fds in the first buffer */
-		if (siocb->scm->fp && !fds_sent) {
-			err = unix_attach_fds(siocb->scm, skb);
-			if (err) {
-				kfree_skb(skb);
-				goto out_err;
-			}
-			fds_sent = true;
-		}
-
 		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
 			kfree_skb(skb);
 			goto out_err;
 		}
 
-		unix_state_lock(other);
+		others_cur = others;
+		while (*others_cur != NULL) {
+			skb_cloned = skb_clone(skb, GFP_KERNEL);
+			if (!skb_cloned) {
+				kfree_skb(skb);
+				goto out_err;
+			}
+			skb_set_owner_w(skb_cloned, sk);
+
+			memcpy(UNIXCREDS(skb_cloned), &siocb->scm->creds, sizeof(struct ucred));
+			/* Only send the fds in the first buffer of each
+ 			 * recipient */
+			if (siocb->scm->fp && !fds_sent) {
+				err = unix_attach_fds(siocb->scm, skb_cloned);
+				if (err) {
+					kfree_skb(skb);
+					kfree_skb(skb_cloned);
+					goto out_err;
+				}
+			}
+
+			unix_state_lock(*others_cur);
 
-		if (sock_flag(other, SOCK_DEAD) ||
-		    (other->sk_shutdown & RCV_SHUTDOWN))
-			goto pipe_err_free;
+			if (sock_flag(*others_cur, SOCK_DEAD) ||
+			    ((*others_cur)->sk_shutdown & RCV_SHUTDOWN)) {
+				unix_state_unlock(*others_cur);
+				kfree_skb(skb);
+				kfree_skb(skb_cloned);
+				goto pipe_err;
+			}
 
-		skb_queue_tail(&other->sk_receive_queue, skb);
-		unix_state_unlock(other);
-		other->sk_data_ready(other, size);
+			skb_queue_tail(&(*others_cur)->sk_receive_queue,
+			    skb_cloned);
+			unix_state_unlock(*others_cur);
+			(*others_cur)->sk_data_ready(*others_cur, size);
+			others_cur++;
+		}
+		kfree_skb(skb);
+		fds_sent = true;
 		sent += size;
 	}
 
 	scm_destroy(siocb->scm);
 	siocb->scm = NULL;
+	if (others)
+		kfree(others);
 
 	return sent;
 
-pipe_err_free:
-	unix_state_unlock(other);
-	kfree_skb(skb);
 pipe_err:
 	if (sent == 0 && !(msg->msg_flags&MSG_NOSIGNAL))
 		send_sig(SIGPIPE, current, 0);
@@ -1762,6 +1789,8 @@ pipe_err:
 out_err:
 	scm_destroy(siocb->scm);
 	siocb->scm = NULL;
+	if (others)
+		kfree(others);
 	return sent ? : err;
 }
 
-- 
1.7.1
