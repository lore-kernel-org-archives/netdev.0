From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] net: remove sock_iocb
Date: Wed, 4 Feb 2015 15:29:02 +0800
Message-ID: <54D1CA3E.80502@windriver.com>
References: <1422464693-7827-1-git-send-email-hch@lst.de> <20150128.232211.1157376728217761804.davem@davemloft.net> <20150129075721.GD29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <hch@lst.de>
To: Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54793 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbbBDH3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 02:29:16 -0500
In-Reply-To: <20150129075721.GD29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2015 03:57 PM, Al Viro wrote:
> On Wed, Jan 28, 2015 at 11:22:11PM -0800, David Miller wrote:
>> From: Christoph Hellwig <hch@lst.de>
>> Date: Wed, 28 Jan 2015 18:04:53 +0100
>>
>>> The sock_iocb structure is allocate on stack for each read/write-like
>>> operation on sockets, and contains various fields of which only the
>>> embedded msghdr and sometimes a pointer to the scm_cookie is ever used.
>>> Get rid of the sock_iocb and put a msghdr directly on the stack and pass
>>> the scm_cookie explicitly to netlink_mmap_sendmsg.
>>>
>>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>
>> Looks good, applied, thanks.
> 
> You know, that's getting _really_ interesting.  The thing is, now
> there's only one ->sendmsg() instance using iocb argument at all,
> and it's a really weird one.  TIPC.  Which only compares it with
> NULL, and that - to tell the normal calls (== done by sock_sendmsg()
> et.al.) from tipc_{accept,connect}()-generated ones.  And the way
> it's used is
>         if (iocb)
>                 lock_sock(sk);
> in tipc_send_stream().  IOW, "tipc_accept() and tipc_connect() would like
> to use the guts of tipc_send_stream(), but they are already holding the
> socket locked; let's just pass NULL iocb (which net/socket.c never does)
> to tell it to leave the fucking lock alone, thank you very much".
> 
> And no ->recvmsg() are using iocb at all now.  How about we take the
> guts of tipc_send_stream() into a helper function and have tipc_accept/connect
> use _that_?  Then we could drop iocb argument completely and for ->sendmsg()
> it would be the difference between 4 and 3 arguments, which has interesting
> effects on certain register-starved architectures...
> 
> While we are at it, size (both for sendmsg and recvmsg) is always equal to
> iov_iter_count(&msg->msg_iter), so that's not the only redundant argument
> there...
> 
> Comments?

Below is a demonstrated patch to not use iocb argument in tipc socket:

Subject: [PATCH] tipc: Don't use iocb argument in socket layer

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c |   44 ++++++++++++++++++++++++++++++--------------
 1 file changed, 30 insertions(+), 14 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 679a220..8362feb 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -116,6 +116,9 @@ static int tipc_sk_withdraw(struct tipc_sock *tsk,
uint scope,
 static struct tipc_sock *tipc_sk_lookup(struct net *net, u32 portid);
 static int tipc_sk_insert(struct tipc_sock *tsk);
 static void tipc_sk_remove(struct tipc_sock *tsk);
+static int __tipc_send_stream(struct socket *sock, struct msghdr *m,
+			      size_t dsz);
+static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t
dsz);

 static const struct proto_ops packet_ops;
 static const struct proto_ops stream_ops;
@@ -886,6 +889,18 @@ static int tipc_wait_for_sndmsg(struct socket
*sock, long *timeo_p)
 static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 			struct msghdr *m, size_t dsz)
 {
+	struct sock *sk = sock->sk;
+	int ret;
+
+	lock_sock(sk);
+	ret = __tipc_sendmsg(sock, m, dsz);
+	release_sock(sk);
+
+	return ret;
+}
+
+static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t
dsz)
+{
 	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
@@ -909,9 +924,6 @@ static int tipc_sendmsg(struct kiocb *iocb, struct
socket *sock,
 	if (dsz > TIPC_MAX_USER_MSG_SIZE)
 		return -EMSGSIZE;

-	if (iocb)
-		lock_sock(sk);
-
 	if (unlikely(sock->state != SS_READY)) {
 		if (sock->state == SS_LISTENING) {
 			rc = -EPIPE;
@@ -990,9 +1002,6 @@ new_mtu:
 			__skb_queue_purge(&head);
 	} while (!rc);
 exit:
-	if (iocb)
-		release_sock(sk);
-
 	return rc;
 }

@@ -1042,6 +1051,18 @@ static int tipc_send_stream(struct kiocb *iocb,
struct socket *sock,
 			    struct msghdr *m, size_t dsz)
 {
 	struct sock *sk = sock->sk;
+	int ret;
+
+	lock_sock(sk);
+	ret = __tipc_send_stream(sock, m, dsz);
+	release_sock(sk);
+
+	return ret;
+}
+
+static int __tipc_send_stream(struct socket *sock, struct msghdr *m,
size_t dsz)
+{
+	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
@@ -1055,7 +1076,7 @@ static int tipc_send_stream(struct kiocb *iocb,
struct socket *sock,

 	/* Handle implied connection establishment */
 	if (unlikely(dest)) {
-		rc = tipc_sendmsg(iocb, sock, m, dsz);
+		rc = __tipc_sendmsg(sock, m, dsz);
 		if (dsz && (dsz == rc))
 			tsk->sent_unacked = 1;
 		return rc;
@@ -1063,9 +1084,6 @@ static int tipc_send_stream(struct kiocb *iocb,
struct socket *sock,
 	if (dsz > (uint)INT_MAX)
 		return -EMSGSIZE;

-	if (iocb)
-		lock_sock(sk);
-
 	if (unlikely(sock->state != SS_CONNECTED)) {
 		if (sock->state == SS_DISCONNECTING)
 			rc = -EPIPE;
@@ -1108,8 +1126,6 @@ next:
 			__skb_queue_purge(&head);
 	} while (!rc);
 exit:
-	if (iocb)
-		release_sock(sk);
 	return sent ? sent : rc;
 }

@@ -1874,7 +1890,7 @@ static int tipc_connect(struct socket *sock,
struct sockaddr *dest,
 		if (!timeout)
 			m.msg_flags = MSG_DONTWAIT;

-		res = tipc_sendmsg(NULL, sock, &m, 0);
+		res = __tipc_sendmsg(sock, &m, 0);
 		if ((res < 0) && (res != -EWOULDBLOCK))
 			goto exit;

@@ -2030,7 +2046,7 @@ static int tipc_accept(struct socket *sock, struct
socket *new_sock, int flags)
 		struct msghdr m = {NULL,};

 		tsk_advance_rx_queue(sk);
-		tipc_send_packet(NULL, new_sock, &m, 0);
+		__tipc_send_stream(new_sock, &m, 0);
 	} else {
 		__skb_dequeue(&sk->sk_receive_queue);
 		__skb_queue_head(&new_sk->sk_receive_queue, buf);

Regards,
Ying

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
