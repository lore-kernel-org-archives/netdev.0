From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #14301] WARNING: at net/ipv4/af_inet.c:154
Date: Sat, 03 Oct 2009 10:52:47 +0200
Message-ID: <4AC710DF.5070705@gmail.com>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.mdH.sMTxKB@chimera> <4AC70D20.4060009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Ralf Hildebrandt <Ralf.Hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AC70D20.4060009-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =C3=A9crit :
> Rafael J. Wysocki a =C3=A9crit :
>> This message has been generated automatically as a part of a report
>> of regressions introduced between 2.6.30 and 2.6.31.
>>
>> The following bug entry is on the current list of known regressions
>> introduced between 2.6.30 and 2.6.31.  Please verify if it still sho=
uld
>> be listed and let me know (either way).
>>
>>
>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14301
>> Subject		: WARNING: at net/ipv4/af_inet.c:154
>> Submitter	: Ralf Hildebrandt <Ralf.Hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org>
>> Date		: 2009-09-30 12:24 (2 days old)
>> References	: http://marc.info/?l=3Dlinux-kernel&m=3D125431350218137&=
w=3D4
>>
>>
>=20
> If commit d99927f4d93f36553699573b279e0ff98ad7dea6
> (net: Fix sock_wfree() race) doesnt fix this problem, then
> maybe we should take a look at an old patch.
>=20
> < data mining... running... output results to lkml/netdev >
>=20
> Random guesses
>=20
>  1) : commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
> (net: Move rx skb_orphan call to where needed)
>=20
> A similar problem on SCTP was fixed by commit=20
> 1bc4ee4088c9a502db0e9c87f675e61e57fa1734
> (sctp: fix warning at inet_sock_destruct() while release sctp socket)
>=20
> 2) CORK and UDP sockets
>   It seems we can leave an UDP socket with a frame in sk_write_queue
>   Purge of this queue is done by udp_flush_pending_frames()
>    This calls ip_flush_pending_frames()
>    But this function only calls kfree_skb(), not sk_wmem_free_skb()..=
=2E
>=20
>=20
> Could you try following patch ?
>=20

Hmm, I missed the ip_cork_release(), here is an updated version.


[PATCH] net: UDP should not use ip_flush_pending_frames()

Now xmit UDP messages are charged, we must take care of calling right
skb freeing function.

In case a close() is performed on a socket where CORKED frame
is still queued in sk_write_queue, calling ip_flush_pending_frames()
leads to sk_forward_alloc leak.

=46ix this by calling sk_write_queue_purge() and ip_cork_release()
instead.

Reported-by: Ralf Hildebrandt <Ralf.Hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org>
Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/ip.h    |    1 +
 include/net/sock.h  |   10 ++++++++++
 include/net/tcp.h   |   10 ----------
 net/ipv4/tcp.c      |    2 +-
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv4/udp.c      |    3 ++-
 6 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 2f47e54..c8d8828 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -117,6 +117,7 @@ extern int		ip_generic_getfrag(void *from, char *to=
, int offset, int len, int od
 extern ssize_t		ip_append_page(struct sock *sk, struct page *page,
 				int offset, size_t size, int flags);
 extern int		ip_push_pending_frames(struct sock *sk);
+extern void     ip_cork_release(struct inet_sock *);
 extern void		ip_flush_pending_frames(struct sock *sk);
=20
 /* datagram.c */
diff --git a/include/net/sock.h b/include/net/sock.h
index 1621935..7c80fec 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -882,6 +882,16 @@ static inline void sk_wmem_free_skb(struct sock *s=
k, struct sk_buff *skb)
 	__kfree_skb(skb);
 }
=20
+/* write queue abstraction */
+static inline void sk_write_queue_purge(struct sock *sk)
+{
+	struct sk_buff *skb;
+
+	while ((skb =3D __skb_dequeue(&sk->sk_write_queue)) !=3D NULL)
+		sk_wmem_free_skb(sk, skb);
+	sk_mem_reclaim(sk);
+}
+
 /* Used by processes to "lock" a socket state, so that
  * interrupts and bottom half handlers won't change it
  * from under us. It essentially blocks any incoming
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..4c7036a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1220,16 +1220,6 @@ static inline void		tcp_put_md5sig_pool(void)
 	put_cpu();
 }
=20
-/* write queue abstraction */
-static inline void tcp_write_queue_purge(struct sock *sk)
-{
-	struct sk_buff *skb;
-
-	while ((skb =3D __skb_dequeue(&sk->sk_write_queue)) !=3D NULL)
-		sk_wmem_free_skb(sk, skb);
-	sk_mem_reclaim(sk);
-}
-
 static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
 {
 	return skb_peek(&sk->sk_write_queue);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 64d0af6..0124f5b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1992,7 +1992,7 @@ int tcp_disconnect(struct sock *sk, int flags)
=20
 	tcp_clear_xmit_timers(sk);
 	__skb_queue_purge(&sk->sk_receive_queue);
-	tcp_write_queue_purge(sk);
+	sk_write_queue_purge(sk);
 	__skb_queue_purge(&tp->out_of_order_queue);
 #ifdef CONFIG_NET_DMA
 	__skb_queue_purge(&sk->sk_async_wait_queue);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7cda24b..76e59df 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1845,7 +1845,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	tcp_cleanup_congestion_control(sk);
=20
 	/* Cleanup up the write buffer. */
-	tcp_write_queue_purge(sk);
+	sk_write_queue_purge(sk);
=20
 	/* Cleans up our, hopefully empty, out_of_order_queue. */
 	__skb_queue_purge(&tp->out_of_order_queue);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6ec6a8a..b6370d0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -464,7 +464,8 @@ void udp_flush_pending_frames(struct sock *sk)
 	if (up->pending) {
 		up->len =3D 0;
 		up->pending =3D 0;
-		ip_flush_pending_frames(sk);
+		sk_write_queue_purge(sk);
+		ip_cork_release(inet_sk(sk));
 	}
 }
 EXPORT_SYMBOL(udp_flush_pending_frames);
