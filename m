From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Fri, 08 May 2009 17:12:39 +0200
Message-ID: <4A044BE7.3070308@cosmosbay.com>
References: <m31vqzwzae.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40237 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761459AbZEHPMt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 11:12:49 -0400
In-Reply-To: <m31vqzwzae.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa a =E9crit :
> Hi,
>=20
> Could NAPI or something similar be used for TX in addition to RX?
> Perhaps some driver already does that?
>=20
> I'm specifically thinking of IXP4xx Ethernet (and possibly WAN), thos=
e
> are 266-667 MHz ARM XScale CPUs and the interrupts handling just
> transmitted sk_buffs are a pain. Could I delay those interrupts
> somehow?

This is a pain yes, I agree. But some improvements can be done.
(even on drivers already using NAPI, especially if same interrupt
is used both for RX and RX queues)

=46or example, we can avoid the dst_release() cache miss if this
is done in start_xmit(), and not later in TX completion while freeing s=
kb.
I tried various patches in the past but unfortunatly it seems
only safe way to do this is in the driver xmit itself, not in core
network stack. This would need many patches, one for each driver.

Then, if your workload is UDP packets, a recent patch
avoided an expensive wakeup at TX completion time
(check commit bf368e4e70cd4e0f880923c44e95a4273d725ab4

http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3Dbf368e4e70cd4e0f880923c44e95a4273d725ab4

Unfortunatly this patch is only for 2.6.30, since it is based
on a new infrastructure from Davide Libenzi)

Then, additional work should be done to reduce cache lines
misses in sock_wfree()

This function currently touches many different cache lines
(one for sk_wmem_alloc, one for testing sk_flags, one
 to decrement sk_refcnt). And on UDP, extra cachelines because
we call sock_def_write_space(). Yes this sucks.

We could avoid touching sk_refcnt in several cases. We
need a reference count only for the whole packets attached to a socket,
granted we use atomic_add_return() and such functions to detect 0
transitions. That way, if a tcp stream always has some packets in fligh=
t,
TX completion would not have to decrement sk_refcnt.

=46ollowing patch (based on net-next-2.6) to illustrate my point :

[PATCH] net: reduce number of reference taken on sk_refcnt

Current sk_wmem_alloc schema uses a sk_refcnt taken for each packet
in flight. This hurts some workloads at TX completion time, because
sock_wfree() has three cache lines to touch at least.
(one for sk_wmem_alloc, one for testing sk_flags, one
 to decrement sk_refcnt)

We could use only one reference count, taken only when sk_wmem_alloc
is changed from or to ZERO value (ie one reference count for any number
of in-flight packets)

Not all atomic_add() must be changed to atomic_add_return(), if we
know current sk_wmem_alloc is already not null.

This patch reduces by one number of cache lines dirtied in sock_wfree()
and number of atomic operation in some workloads.=20

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --cc include/net/tcp.h
index ac37228,87d210b..0000000
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
diff --git a/include/net/sock.h b/include/net/sock.h
index 4bb1ff9..d57e88b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1213,14 +1213,17 @@ static inline int skb_copy_to_page(struct sock =
*sk, char __user *from,
  *
  * 	Inlined as it's very short and called for pretty much every
  *	packet ever received.
+ *	We take a reference on sock only if this is the first packet
+ *	accounted for. (one reference count for any number of in flight pac=
kets)
  */
=20
 static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *s=
k)
 {
-	sock_hold(sk);
 	skb->sk =3D sk;
 	skb->destructor =3D sock_wfree;
-	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+	if (atomic_add_return(skb->truesize, &sk->sk_wmem_alloc) =3D=3D
+	    skb->truesize)
+		sock_hold(sk);
 }
=20
 static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *s=
k)
diff --git a/net/core/sock.c b/net/core/sock.c
index 7dbf3ff..bf10084 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1170,12 +1170,17 @@ void __init sk_init(void)
 void sock_wfree(struct sk_buff *skb)
 {
 	struct sock *sk =3D skb->sk;
+	int res;
=20
 	/* In case it might be waiting for more memory. */
-	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
+	res =3D atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
 	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
 		sk->sk_write_space(sk);
-	sock_put(sk);
+	/*
+	 * No more packets in flight, we must release sock refcnt
+	 */
+	if (res =3D=3D 0)
+		sock_put(sk);
 }
=20
 /*

