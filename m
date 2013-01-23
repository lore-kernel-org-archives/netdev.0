From: Yannick Koehler <yannick@koehler.name>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 11:39:59 -0500
Message-ID: <CAJ4BwwHrrSE9LRLdJaVu+3CvdSRNb6i_8tM7McrQ4R=toDZQFw@mail.gmail.com>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
	<20130123095943.GA7317@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Yannick Koehler <yannick@koehler.name>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:65138 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231Ab3AWQkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 11:40:01 -0500
Received: by mail-we0-f172.google.com with SMTP id x10so571485wey.31
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 08:39:59 -0800 (PST)
In-Reply-To: <20130123095943.GA7317@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch should fix an issue where unix socket buffer remains
accounted as part of the socket sndbuf (sk_wmem_alloc) instead of
being accounted as part of the receiving socket rcvbuf
(sk_rmem_alloc), leading to a situation where if one of the receiving
socket isn't calling recvfrom() the sending socket can no more send to
any of its listeners, even those which properly behave.  This could
create a DOS situation where the unix socket is reachable by many
users on the same linux machine.

diff -uprN -X linux-3.6-vanilla/Documentation/dontdiff
linux-3.6-vanilla/include/net/af_unix.h
linux-3.6/include/net/af_unix.h
--- linux-3.6-vanilla/include/net/af_unix.h 2012-09-30 19:47:46.000000000 -0400
+++ linux-3.6/include/net/af_unix.h 2013-01-23 11:21:35.000000000 -0500
@@ -34,6 +34,8 @@ struct unix_skb_parms {
 #ifdef CONFIG_SECURITY_NETWORK
  u32 secid; /* Security ID */
 #endif
+ char peer_name[UNIX_PATH_MAX];
+ int peer_namelen;
 };

 #define UNIXCB(skb) (*(struct unix_skb_parms *)&((skb)->cb))
diff -uprN -X linux-3.6-vanilla/Documentation/dontdiff
linux-3.6-vanilla/net/rxrpc/ar-internal.h
linux-3.6/net/rxrpc/ar-internal.h
--- linux-3.6-vanilla/net/rxrpc/ar-internal.h 2012-09-30
19:47:46.000000000 -0400
+++ linux-3.6/net/rxrpc/ar-internal.h 2013-01-23 11:00:43.000000000 -0500
@@ -77,7 +77,7 @@ struct rxrpc_sock {

 /*
  * RxRPC socket buffer private variables
- * - max 48 bytes (struct sk_buff::cb)
+ * - max 160 bytes (struct sk_buff::cb)
  */
 struct rxrpc_skb_priv {
  struct rxrpc_call *call; /* call with which associated */
diff -uprN -X linux-3.6-vanilla/Documentation/dontdiff
linux-3.6-vanilla/net/unix/af_unix.c linux-3.6/net/unix/af_unix.c
--- linux-3.6-vanilla/net/unix/af_unix.c 2012-09-30 19:47:46.000000000 -0400
+++ linux-3.6/net/unix/af_unix.c 2013-01-23 11:26:00.000000000 -0500
@@ -1425,6 +1425,19 @@ static void maybe_add_creds(struct sk_bu
  }
 }

+static void unix_backup_addr(struct sk_buff *skb, struct sock *sk)
+{
+ struct unix_sock *u = unix_sk(sk);
+
+ if (u->addr) {
+ memcpy(UNIXCB(skb).peer_name, u->addr->name, u->addr->len);
+ UNIXCB(skb).peer_namelen = u->addr->len;
+ } else {
+ UNIXCB(skb).peer_name[0] = 0;
+ UNIXCB(skb).peer_namelen = 0;
+ }
+}
+
 /*
  * Send AF_UNIX data.
  */
@@ -1579,9 +1592,19 @@ restart:
  goto restart;
  }

+ if (atomic_read(&other->sk_rmem_alloc) + skb->truesize >=
+    (unsigned)other->sk_rcvbuf) {
+ err = -EAGAIN;
+ goto out_unlock;
+ }
+
+ /* Backup source address into sk_buff :: cb */
+ unix_backup_addr(skb, sk);
+
  if (sock_flag(other, SOCK_RCVTSTAMP))
  __net_timestamp(skb);
  maybe_add_creds(skb, sock, other);
+ skb_set_owner_r(skb, other);
  skb_queue_tail(&other->sk_receive_queue, skb);
  if (max_level > unix_sk(other)->recursion_level)
  unix_sk(other)->recursion_level = max_level;
@@ -1696,7 +1719,17 @@ static int unix_stream_sendmsg(struct ki
     (other->sk_shutdown & RCV_SHUTDOWN))
  goto pipe_err_free;

+ if (atomic_read(&other->sk_rmem_alloc) + skb->truesize >=
+    (unsigned)other->sk_rcvbuf) {
+ err = -EAGAIN;
+ goto pipe_err_free;
+ }
+
+ /* Backup source address into sk_buff :: cb */
+ unix_backup_addr(skb, sk);
+
  maybe_add_creds(skb, sock, other);
+ skb_set_owner_r(skb, other);
  skb_queue_tail(&other->sk_receive_queue, skb);
  if (max_level > unix_sk(other)->recursion_level)
  unix_sk(other)->recursion_level = max_level;
@@ -1754,15 +1787,10 @@ static int unix_seqpacket_recvmsg(struct
  return unix_dgram_recvmsg(iocb, sock, msg, size, flags);
 }

-static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
+static void unix_restore_addr(struct msghdr *msg, struct unix_skb_parms *parms)
 {
- struct unix_sock *u = unix_sk(sk);
-
- msg->msg_namelen = 0;
- if (u->addr) {
- msg->msg_namelen = u->addr->len;
- memcpy(msg->msg_name, u->addr->name, u->addr->len);
- }
+ msg->msg_namelen = parms->peer_namelen;
+ memcpy(msg->msg_name, parms->peer_name, parms->peer_namelen);
 }

 static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
@@ -1807,7 +1835,7 @@ static int unix_dgram_recvmsg(struct kio
  POLLOUT | POLLWRNORM | POLLWRBAND);

  if (msg->msg_name)
- unix_copy_addr(msg, skb->sk);
+ unix_restore_addr(msg, &(UNIXCB(skb)));

  if (size > skb->len - skip)
  size = skb->len - skip;
@@ -2007,7 +2035,7 @@ again:

  /* Copy address just once */
  if (sunaddr) {
- unix_copy_addr(msg, skb->sk);
+ unix_restore_addr(msg, &(UNIXCB(skb)));
  sunaddr = NULL;
  }


2013/1/23 Hannes Frederic Sowa <hannes@stressinduktion.org>:
> On Mon, Jan 21, 2013 at 09:01:53PM -0500, Yannick Koehler wrote:
>>   I believe that the problem is that once we move the skb into the
>> client's receive queue we need to decrease the sk_wmem_alloc variable
>> of the server socket since that skb is no more tied to the server.
>> The code should then account for this memory as part of the
>> sk_rmem_alloc variable on the client's socket.  The function
>> "skb_set_owner_r(skb,owner)" would seem to be the function to do that,
>> so it would seem to me.
>
> Your analysis does make sense. Could you cook a patch?
>
> Thanks,
>
>   Hannes
>



-- 
Yannick Koehler
Courriel: yannick@koehler.name
Blog: http://corbeillepensees.blogspot.com
