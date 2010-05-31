From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: sock_queue_err_skb() dont mess with sk_forward_alloc
Date: Mon, 31 May 2010 18:02:46 +0200
Message-ID: <1275321766.3291.100.camel@edumazet-laptop>
References: <20100526031943.GA28295@kryten>
	 <20100526.005634.48509140.davem@davemloft.net>
	 <1274868776.2672.96.camel@edumazet-laptop>
	 <20100529.002124.149815573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: anton@samba.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46303 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160Ab0EaQIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 12:08:55 -0400
Received: by wyi11 with SMTP id 11so328985wyi.19
        for <netdev@vger.kernel.org>; Mon, 31 May 2010 09:08:53 -0700 (PDT)
In-Reply-To: <20100529.002124.149815573.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 29 mai 2010 =C3=A0 00:21 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 26 May 2010 12:12:56 +0200
>=20
> > [PATCH] net: fix sk_forward_alloc corruptions
> >=20
> > As David found out, sock_queue_err_skb() should be called with sock=
et
> > lock hold, or we risk sk_forward_alloc corruption, since we use non
> > atomic operations to update this field.
> >=20
> > This patch adds bh_lock_sock()/bh_unlock_sock() pair to three spots=
=2E
> > (BH already disabled)
> >=20
> > 1) skb_tstamp_tx()=20
> > 2) Before calling ip_icmp_error(), in __udp4_lib_err()=20
> > 3) Before calling ipv6_icmp_error(), in __udp6_lib_err()
> >=20
> > Reported-by: Anton Blanchard <anton@samba.org>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> This wasn't the direct cause of Anton's problems but is
> a serious legitimate bug.
>=20
> So, applied, thanks!

Thats embarrassing...

I believe there is still a problem with sock_queue_err_skb(), sorry
Dave :(

There is also a problem in ip_recv_error(), not called with socket
locked, skb freed -> potential corruption.

If current socket is 'owned' by a user thread, then we can still corrup=
t
sk_forward_alloc, even if we use bh_lock_sock()

I dont think we need to have another backlog for such case, maybe we
could account for skb->truesize in sk_rmem_alloc (this is atomic), and
not account for sk_mem_charge ?

Another possibility would be to store in skb the backlog function
pointer, so that backlog is generic (normal packets and error packets
handled in same backlog queue), instead of using a protocol provided
pointer. But thats more complex and error prone.

Thanks

[PATCH] net: sock_queue_err_skb() dont mess with sk_forward_alloc

Correct sk_forward_alloc handling for error_queue would need to use a
backlog of frames that softirq handler could not deliver because socket
is owned by user thread. Or extend backlog processing to be able to
process normal and error packets.

Another possibility is to not use mem charge for error queue, this is
what I implemented in this patch.

Note: this reverts commit 29030374
(net: fix sk_forward_alloc corruptions), since we dont need to lock
socket anymore.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |   15 +--------------
 net/core/skbuff.c  |   30 ++++++++++++++++++++++++++++--
 net/ipv4/udp.c     |    6 ++----
 net/ipv6/udp.c     |    6 ++----
 4 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ca241ea..731150d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1524,20 +1524,7 @@ extern void sk_stop_timer(struct sock *sk, struc=
t timer_list* timer);
=20
 extern int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
=20
-static inline int sock_queue_err_skb(struct sock *sk, struct sk_buff *=
skb)
-{
-	/* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
-	   number of warnings when compiling with -W --ANK
-	 */
-	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
-	    (unsigned)sk->sk_rcvbuf)
-		return -ENOMEM;
-	skb_set_owner_r(skb, sk);
-	skb_queue_tail(&sk->sk_error_queue, skb);
-	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skb->len);
-	return 0;
-}
+extern int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb);
=20
 /*
  *	Recover an error report and clear atomically
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4e7ac09..9f07e74 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2965,6 +2965,34 @@ int skb_cow_data(struct sk_buff *skb, int tailbi=
ts, struct sk_buff **trailer)
 }
 EXPORT_SYMBOL_GPL(skb_cow_data);
=20
+static void sock_rmem_free(struct sk_buff *skb)
+{
+	struct sock *sk =3D skb->sk;
+
+	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+}
+
+/*
+ * Note: We dont mem charge error packets (no sk_forward_alloc changes=
)
+ */
+int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
+{
+	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
+	    (unsigned)sk->sk_rcvbuf)
+		return -ENOMEM;
+
+	skb_orphan(skb);
+	skb->sk =3D sk;
+	skb->destructor =3D sock_rmem_free;
+	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+
+	skb_queue_tail(&sk->sk_error_queue, skb);
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk, skb->len);
+	return 0;
+}
+EXPORT_SYMBOL(sock_queue_err_skb);
+
 void skb_tstamp_tx(struct sk_buff *orig_skb,
 		struct skb_shared_hwtstamps *hwtstamps)
 {
@@ -2997,9 +3025,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	serr->ee.ee_errno =3D ENOMSG;
 	serr->ee.ee_origin =3D SO_EE_ORIGIN_TIMESTAMPING;
=20
-	bh_lock_sock(sk);
 	err =3D sock_queue_err_skb(sk, skb);
-	bh_unlock_sock(sk);
=20
 	if (err)
 		kfree_skb(skb);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 50678f9..eec4ff4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -633,11 +633,9 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info,=
 struct udp_table *udptable)
 	if (!inet->recverr) {
 		if (!harderr || sk->sk_state !=3D TCP_ESTABLISHED)
 			goto out;
-	} else {
-		bh_lock_sock(sk);
+	} else
 		ip_icmp_error(sk, skb, err, uh->dest, info, (u8 *)(uh+1));
-		bh_unlock_sock(sk);
-	}
+
 	sk->sk_err =3D err;
 	sk->sk_error_report(sk);
 out:
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3048f90..87be586 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -466,11 +466,9 @@ void __udp6_lib_err(struct sk_buff *skb, struct in=
et6_skb_parm *opt,
 	if (sk->sk_state !=3D TCP_ESTABLISHED && !np->recverr)
 		goto out;
=20
-	if (np->recverr) {
-		bh_lock_sock(sk);
+	if (np->recverr)
 		ipv6_icmp_error(sk, skb, err, uh->dest, ntohl(info), (u8 *)(uh+1));
-		bh_unlock_sock(sk);
-	}
+
 	sk->sk_err =3D err;
 	sk->sk_error_report(sk);
 out:


