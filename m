From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Thu, 22 Jul 2010 21:46:55 +0900
Message-ID: <201007222146.FGC09386.OFOtFQOVFMJSLH@I-love.SAKURA.ne.jp>
References: <201007220441.o6M4fcmC093106@www262.sakura.ne.jp>
	<20100721.214517.236270570.davem@davemloft.net>
	<201007220502.o6M52GJU098071@www262.sakura.ne.jp>
	<20100721.220611.267376790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100721.220611.267376790.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> > Then, why does below proposal lose information?
> 
> Peek changes state, now it's possible that two processes end up
> receiving the packet.

Indeed. We will need to protect sock->ops->recvmsg() call using a lock like

 static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 				       struct msghdr *msg, size_t size, int flags)
 {
+	int err;
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
 	sock_update_classid(sock->sk);
 
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
 	si->size = size;
 	si->flags = flags;
 
-	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
+	err = security_socket_read_lock(sock);
+	if (err)
+		return err;
+	err = sock->ops->recvmsg(iocb, sock, msg, size, flags);
+	security_socket_read_unlock(sock);
+	return err;
 }

in addition to security_socket_recvmsg_force_peek() and
security_socket_post_recvmsg().

But locks like above break MSG_DONTWAIT since recv() without MSG_DONTWAIT
calls wait_for_packet() inside __skb_recv_datagram().
To make MSG_DONTWAIT work, I have to do like below.

 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 				    int *peeked, int *err)
(...snipped...)
 	do {
 		/* Again only user level code calls this function, so nothing
 		 * interrupt level will suddenly eat the receive_queue.
 		 *
 		 * Look at current nfs client by the way...
 		 * However, this function was corrent in any case. 8)
 		 */
 		unsigned long cpu_flags;
 
+		/* < 0 if lock failed, 0 if no need to lock, > 0 if locked */
+		int serialized = security_socket_read_lock(sk);
+		if (serialized < 0) {
+			error = serialized;
+			goto no_packet;
+		} else if (serialized > 0) {
+			int err;
+			spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
+			skb = skb_peek(&sk->sk_receive_queue);
+			spin_unlock_irqrestore(&sk->sk_receive_queue.lock,
+					       cpu_flags);
+			if (!skb)
+				goto no_skb;
+			err = security_socket_pre_recvmsg(sk, skb);
+			if (err < 0) {
+				error = err;
+				security_socket_read_unlock(sk);
+				goto no_packet;
+			}
+		}
+
 		spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
 		skb = skb_peek(&sk->sk_receive_queue);
 		if (skb) {
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
 				skb->peeked = 1;
 				atomic_inc(&skb->users);
 			} else
 				__skb_unlink(skb, &sk->sk_receive_queue);
 		}
 		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 
+no_skb:
+		if (serialized > 0)
+			security_socket_read_unlock(sk);
 		if (skb)
 			return skb;
 
 		/* User doesn't want to wait */
 		error = -EAGAIN;
 		if (!timeo)
 			goto no_packet;
 
 	} while (!wait_for_packet(sk, err, &timeo));
(...snipped...)
 }

Inserting LSM hooks like above will be the only way to work properly (i.e.
handle MSG_DONTWAIT and avoid showing the same message to multiple readers
and keep the queue's state unchanged upon error).
But you said ( http://marc.info/?l=linux-netdev&m=124022463014713&w=2 )

> We worked so hard to split out this common code, it is simply
> a non-starter for anyone to start putting protocol specific test
> into here, or even worse to move this code back to being locally
> copied into every protocol implementation.

when I proposed inserting LSM hooks into __skb_recv_datagram()
( http://marc.info/?l=linux-netdev&m=124022463014672&w=2 ).
So, I have no way to allow performing permission checks based on combination of
"process who issued recv() request" and "source address/port of the message
which the process is about to pick up" without breaking things (unless you
accept inserting LSM hooks into __skb_recv_datagram())...
