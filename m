From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Thu, 22 Jul 2010 14:02:16 +0900
Message-ID: <201007220502.o6M52GJU098071@www262.sakura.ne.jp>
References: <201007220338.o6M3citW076383@www262.sakura.ne.jp> <20100721.210636.197931242.davem@davemloft.net> <201007220441.o6M4fcmC093106@www262.sakura.ne.jp> <20100721.214517.236270570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:64047 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab0GVFCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 01:02:19 -0400
In-Reply-To: <20100721.214517.236270570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Tetsuo Handa
> Date: Thu, 22 Jul 2010 13:41:38 +0900
> 
> > Excuse me, below check is made inside recvmsg() and may return error if
> > SELinux's policy has changed after the select() said "ready" and before
> > security_socket_recvmsg() is called. No?
> 
> It does this before pulling the packet out of the receive queue of the
> socket.  It's like signalling a parameter error to the process, no
> socket state is changed.

So, we agreed that security_socket_recvmsg() is allowed to return error code
rather than available data even if both conditions

1) Application makes poll() on UDP socket in blocking mode, and UDP
   reports that receive data is available

and

2) Application, after such a poll() call, makes a blocking recvmsg() call
   and no other activity has occurred on the socket meanwhile

are met.

Then, why does below proposal lose information?
The message is not removed if security_socket_post_recvmsg() returned error code.

 int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len, int noblock, int flags, int *addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
 	struct sk_buff *skb;
 	unsigned int ulen;
 	int peeked;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
 	bool slow;
+	bool peek_forced;
 
 	/*
 	 *      Check any passed addresses
 	 */
 	if (addr_len)
 		*addr_len = sizeof(*sin);
 
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len);
 
+	/* LSM wants to decide permission based on skb? */
+	peek_forced = security_socket_recvmsg_force_peek(sk);
 try_again:
-	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				  &peeked, &err);
+	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0) |
+				  (peek_forced ? MSG_PEEK : 0), &peeked, &err);
 	if (!skb)
 		goto out;
+	if (peek_forced) {
+		err = security_socket_post_recvmsg(sk, skb);
+		if (err < 0) {
+			/*
+			 * Do not remove this message from queue because LSM
+			 * decided not to deliver this message to the caller.
+			 */
+			peek_forced = false;
+			goto out_free;
+		}
+	}
 
 	ulen = skb->len - sizeof(struct udphdr);
 	if (len > ulen)
 		len = ulen;
 	else if (len < ulen)
 		msg->msg_flags |= MSG_TRUNC;
(...snipped...)
 out_free:
+	if (peek_forced && !(flags & MSG_PEEK)) {
+		/*
+		 * Remove this message from queue because this message was
+		 * peeked for LSM but the caller did not ask to peek.
+		 */
+		slow = lock_sock_fast(sk);
+		skb_kill_datagram(sk, skb, flags);
+		unlock_sock_fast(sk, slow);
+		goto out;
+	}
 	skb_free_datagram_locked(sk, skb);
 out:
 	return err;
(...snipped...)
 }

