From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Thu, 22 Jul 2010 12:38:44 +0900
Message-ID: <201007220338.o6M3citW076383@www262.sakura.ne.jp>
References: <201007170114.GFC57373.SQJHOVtLFMOFFO@I-love.SAKURA.ne.jp> <20100716.123558.71592004.davem@davemloft.net> <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp> <20100721.114509.37203355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:52915 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab0GVDir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 23:38:47 -0400
In-Reply-To: <20100721.114509.37203355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Tetsuo Handa
> Date: Sat, 17 Jul 2010 10:17:10 +0900
> 
> > NETWORKING [IPv4/IPv6] maintainers and Paul, is below patch fine for you?
> 
> Unfortunately, after further consideration, I must reject this patch
> and also the post accept() LSM hook one.
> 
> Sorry.
> 
> I looked into history of the discussions on this issue, and I have found
> that the core issue with these hooks has not been addressed.
> 
> We must ensure that if:
> 
> 1) Application makes poll() on UDP socket in blocking mode, and UDP
>    reports that receive data is available
> 
> and
> 
> 2) Application, after such a poll() call, makes a blocking recvmsg() call
>    and no other activity has occurred on the socket meanwhile
> 
> Then we MUST return immediately with that available data.
> 
> This LSM hook, when it triggers, can violate this rule, even if you do
> this looping thing.
> 

Existing LSM hooks already violate this rule.
security_socket_accept() and security_socket_recvmsg() are allowed to return
immediately with error code instead of available data even if conditions (1)
and (2) are met.

> The post accept() hook has the same problems.
> 
> Here is where we originally discussed this, in detail:
> 
> http://www.spinics.net/lists/netdev/msg95660.html
> 
> Therefore, I think this shows that what Tomoyo is trying to do is
> fatally flawed.  We brought this fundamental issue up to you about a
> year ago, and the issue is still not addressed.
> 
> So consider very seriously, that what you are trying to do cannot be
> performed without breaking applications and API behavioral
> expectations.

LSM is something that breaks applications and API behavioral expectations.

For example, an application called access("/bin/sh", X_OK) and assumed that
execution of /bin/sh will be permitted unless somebody does chmod("/bin/sh", 0)
before the application calls execve("/bin/sh"). But however, if LSM's policy
changed from "allow execution of /bin/sh" to "deny execution of /bin/sh"
between access("/bin/sh", X_OK) and execve("/bin/sh"), the application was
broken by the LSM. Although such change unlikely happens in normal
circumstance, it can happen and we tolerate such breakage.

Another example. An application called select() on non-socket object (e.g.
regular file). The select() will say "read operation will not block" and
the application will call read() with expectations that read() returns
immediately with available data (or EOF) rather than error code unless
somebody does chmod("the file", 0). But however, if LSM's policy changed from
"allow reading the file" to "deny reading the file" between select() and
read(), the application was broken by the LSM. Although such change unlikely
happens in normal circumstance, it can happen and we tolerate such breakage.

Another example. An application called socket(), bind() and listen().
A connection request arrived and enqueued into the listening socket's backlog.
Now, select() starts saying "read operation will not block" and the application
calls accept() with expectations that accept() returns immediately with
established connection rather than error code. But however, if LSM's policy
changed from "allow picking up the connection" to "deny picking up the
connection" between select() and accept(), the application was broken by the
LSM. Although such change unlikely happens in normal circumstance, it can
happen and we tolerate such breakage.

The only difference between security_socket_accept()/security_socket_recvmsg()
and security_socket_post_accept()/security_socket_post_recvmsg() is that
the connection/datagram in the queue is removed or not when these LSM hooks
returned error code. Existing LSM hooks already made it impossible to return
available data even if conditions (1) and (2) are met.



Generally speaking, the connection/datagram being not removed from the queue
when these LSM hooks returned error code might be preferable. But for TOMOYO,
the connection/datagram being removed from the queue is preferable.
Reasons shown below.

TOMOYO is concerned with protecting applications with minimal side effects.
Being unable to boot the system by granting chmod("/sbin/init", 0) or being
unable to login to the system by granting rename("/etc/shadow", "/etc/shadow0")
or being unable to allocate CPU time for each application by making specific
applications to eat 100% of CPU time etc. are serious side effects for TOMOYO.

Say, there are 100 connections/datagrams in the socket's queue and 1 out of 100
is the connection/datagram which should not be delivered to the application.

(a) If the caller didn't close() the socket when security_socket_accept()/
    security_socket_recvmsg() returned error code, subsequent select() will say
    "read operation will not block" and the caller will immediately call
    accept()/recvmsg() again. This lets the application to spend 100% of CPU
    time for only 1 connection/datagram which can not be picked up. This is
    nearly DoS for server side and completely DoS for client side.

(b) If the caller close()d the socket when security_socket_accept()/
    security_socket_recvmsg() returned error code, all queued connections/
    datagrams are discarded. The connections/datagrams which should be
    delivered to the application are discarded (i.e. 99 connections/datagrams
    are disturbed by only 1 connection/datagram).
    Therefore, I will have to ask application developers to modify the
    application to call close(), socket(), bind(), listen(), accept()
    (regarding server side) and call close(), socket(), connect() (regarding
    client side) whenever security_socket_accept()/security_socket_recvmsg()
    returned an error. This is nearly DoS for client side.

Silently dropping the 1 connection/datagram with returning non-fatal error code
(e.g. -EAGAIN) (or wait for next connection/datagram unless MSG_DONTWAIT or
O_NONBLOCK is set) seems to give minimal side effects to both server side and
client side. But if you still cannot tolerate dropping the connection/datagram,
what about below idea?

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

where security_socket_recvmsg_force_peek() returns true (if LSM module wants to
do permission check based on skb) or false (if LSM module does not want to do
permission check based on skb) and security_socket_post_recvmsg() returns error
code (if LSM module decided not to deliver) or 0 (if LSM module decided to
deliver). security_socket_post_recvmsg() must not call skb_kill_datagram().
In this way, security_socket_post_recvmsg() can keep socket's queue state
intact like security_socket_recvmsg() (but side effects (a) and (b) remains as
well as security_socket_recvmsg() hook).

Do permission checks upon enqueue time and do not perform permission check upon
dequeue time cannot be an answer. Side effects with security_socket_accept()/
security_socket_recvmsg() are what SELinux is experiencing as well as TOMOYO
will experience. (Though, it seems to me that SELinux is not interested in such
side effects.)

Regards.
