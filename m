From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: Fix udp_poll() and ioctl()
Date: Fri, 09 Oct 2009 16:43:40 +0200
Message-ID: <4ACF4C1C.4050505@gmail.com>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.mdH.sMTxKB@chimera> <4AC70D20.4060009@gmail.com> <4AC710DF.5070705@gmail.com> <4AC78F7C.40908@gmail.com> <4ACCB6BE.5040602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Ralf Hildebrandt <Ralf.Hildebrandt@charite.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Takahiro Yasui <tyasui@redhat.com>,
	Hideo Aoki <haoki@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761013AbZJIOpJ@vger.kernel.org>
In-Reply-To: <4ACCB6BE.5040602@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =C3=A9crit :
> Eric Dumazet a =C3=A9crit :
>> Eric Dumazet a =C3=A9crit :
>>> Eric Dumazet a =C3=A9crit :
>>>> Rafael J. Wysocki a =C3=A9crit :
>>>>> This message has been generated automatically as a part of a repo=
rt
>>>>> of regressions introduced between 2.6.30 and 2.6.31.
>>>>>
>>>>> The following bug entry is on the current list of known regressio=
ns
>>>>> introduced between 2.6.30 and 2.6.31.  Please verify if it still =
should
>>>>> be listed and let me know (either way).
>>>>>
>>>>>
>>>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14301
>>>>> Subject		: WARNING: at net/ipv4/af_inet.c:154
>>>>> Submitter	: Ralf Hildebrandt <Ralf.Hildebrandt@charite.de>
>>>>> Date		: 2009-09-30 12:24 (2 days old)
>>>>> References	: http://marc.info/?l=3Dlinux-kernel&m=3D1254313502181=
37&w=3D4
>>>>>
>> Investigation still needed...
>>
>=20
> OK, my last (buggy ???) feeling is about commit 95766fff6b9a78d1
>=20
> [UDP]: Add memory accounting.
>=20
> (Its a two years old patch, oh well...)
>=20
> Problem is the udp_poll() :
>=20
> We check the first frame to be dequeued from sk_receive_queue has a g=
ood checksum.
>=20
> If it doesnt, we drop the frame ( calling kfree_skb(skb); )
>=20
> Problem is now we perform memory accounting on UDP, this kfree_skb()
> should be done with socket locked, but are we allowed to
> call lock_sock() from this udp_poll() context ?
>=20

It seems we can lock_sock() from udp_poll() context, so here is a patch=
=2E

[PATCH] udp: Fix udp_poll()

udp_poll() can in some circumstances drop frames with incorrect checksu=
ms.

Problem is we now have to lock the socket while dropping frames, or ris=
k
sk_forward corruption.

This bug is present since commit 95766fff6b9a78d1
([UDP]: Add memory accounting.)

While we are at it, we can correct ioctl(SIOCINQ) to also drop bad fram=
es.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/udp.c |   73 +++++++++++++++++++++++++++--------------------
 1 files changed, 43 insertions(+), 30 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6ec6a8a..d0d436d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -841,6 +841,42 @@ out:
 	return ret;
 }
=20
+
+/**
+ *	first_packet_length	- return length of first packet in receive queu=
e
+ *	@sk: socket
+ *
+ *	Drops all bad checksum frames, until a valid one is found.
+ *	Returns the length of found skb, or 0 if none is found.
+ */
+static unsigned int first_packet_length(struct sock *sk)
+{
+	struct sk_buff_head list_kill, *rcvq =3D &sk->sk_receive_queue;
+	struct sk_buff *skb;
+	unsigned int res;
+
+	__skb_queue_head_init(&list_kill);
+
+	spin_lock_bh(&rcvq->lock);
+	while ((skb =3D skb_peek(rcvq)) !=3D NULL &&
+		udp_lib_checksum_complete(skb)) {
+		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
+				 IS_UDPLITE(sk));
+		__skb_unlink(skb, rcvq);
+		__skb_queue_tail(&list_kill, skb);
+	}
+	res =3D skb ? skb->len : 0;
+	spin_unlock_bh(&rcvq->lock);
+
+	if (!skb_queue_empty(&list_kill)) {
+		lock_sock(sk);
+		__skb_queue_purge(&list_kill);
+		sk_mem_reclaim_partial(sk);
+		release_sock(sk);
+	}
+	return res;
+}
+
 /*
  *	IOCTL requests applicable to the UDP protocol
  */
@@ -857,21 +893,16 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned =
long arg)
=20
 	case SIOCINQ:
 	{
-		struct sk_buff *skb;
-		unsigned long amount;
+		unsigned int amount =3D first_packet_length(sk);
=20
-		amount =3D 0;
-		spin_lock_bh(&sk->sk_receive_queue.lock);
-		skb =3D skb_peek(&sk->sk_receive_queue);
-		if (skb !=3D NULL) {
+		if (amount)
 			/*
 			 * We will only return the amount
 			 * of this packet since that is all
 			 * that will be read.
 			 */
-			amount =3D skb->len - sizeof(struct udphdr);
-		}
-		spin_unlock_bh(&sk->sk_receive_queue.lock);
+			amount -=3D sizeof(struct udphdr);
+
 		return put_user(amount, (int __user *)arg);
 	}
=20
@@ -1540,29 +1571,11 @@ unsigned int udp_poll(struct file *file, struct=
 socket *sock, poll_table *wait)
 {
 	unsigned int mask =3D datagram_poll(file, sock, wait);
 	struct sock *sk =3D sock->sk;
-	int 	is_lite =3D IS_UDPLITE(sk);
=20
 	/* Check for false positives due to checksum errors */
-	if ((mask & POLLRDNORM) &&
-	    !(file->f_flags & O_NONBLOCK) &&
-	    !(sk->sk_shutdown & RCV_SHUTDOWN)) {
-		struct sk_buff_head *rcvq =3D &sk->sk_receive_queue;
-		struct sk_buff *skb;
-
-		spin_lock_bh(&rcvq->lock);
-		while ((skb =3D skb_peek(rcvq)) !=3D NULL &&
-		       udp_lib_checksum_complete(skb)) {
-			UDP_INC_STATS_BH(sock_net(sk),
-					UDP_MIB_INERRORS, is_lite);
-			__skb_unlink(skb, rcvq);
-			kfree_skb(skb);
-		}
-		spin_unlock_bh(&rcvq->lock);
-
-		/* nothing to see, move along */
-		if (skb =3D=3D NULL)
-			mask &=3D ~(POLLIN | POLLRDNORM);
-	}
+	if ((mask & POLLRDNORM) && !(file->f_flags & O_NONBLOCK) &&
+	    !(sk->sk_shutdown & RCV_SHUTDOWN) && !first_packet_length(sk))
+		mask &=3D ~(POLLIN | POLLRDNORM);
=20
 	return mask;
=20
