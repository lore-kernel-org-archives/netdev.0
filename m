From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
Date: Tue, 21 Sep 2010 11:23:13 +0200
Message-ID: <1285060993.2617.163.camel@edumazet-laptop>
References: <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
	 <1284717448.3391.75.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
	 <20100920.085857.98907191.davem@davemloft.net>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86F80270@MNEXMB2.qlogic.org>
	 <1285058073.2617.73.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86F80278@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59310 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756467Ab0IUJXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 05:23:18 -0400
Received: by fxm3 with SMTP id 3so1247469fxm.19
        for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 02:23:17 -0700 (PDT)
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F86F80278@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 septembre 2010 =C3=A0 03:41 -0500, Amit Salecha a =C3=A9cri=
t :

> > Amit, if you believe this is a problem, you should address it for a=
ll
> > NICS, not only qlcnic.
> >=20
> > Qlcnic was lying to stack, because it consumed 2Kbytes blocs and
> > pretended they were consuming skb->len bytes.
> > (assuming MTU=3D1500, problem is worse if MTU is bigger)
> >=20
> > So in order to improve "throughput", you were allowing for memory
> > exhaust and freeze of the _machine_ ?
> >
> This won't lead to such problem. truesize is used for accounting only=
=2E

You must have big machines in your lab and never hit OOM ?

You really should take a look on various files in net/core, net/ipv4
trees. And files like "/proc/sys/net/tcp_mem", "/proc/sys/net/udp_mem"

In fact, truesize is _underestimated_ : (we dont account for struct
skb_shared_info) and kmalloc() rounding

We probably should use this patch (without having to check all possible
net drivers !)

Problem is this would slow down alloc_skb(), so this patch is not for
inclusion.

cheap alternative would be to use=20

size + sizeof(struct sk_buff) + SKB_DATA_ALIGN(sizeof(struct skb_shared=
_info))

If you think about it, when 128bit arches come, truesize will grow anyw=
ay.
If some tuning is needed in our stack, we'll do it.

(socket api SO_RCVBUF/ SO_SNDBUF is the problem, because
 applications are not aware of packetization or kernel internals)

SOCK_MIN_RCVBUF is way too small, since sizeof(struct sk_buff)=20
is already close to 256. I guess we cannot even receive a single frame.

 include/net/sock.h |    2 +-
 net/core/skbuff.c  |    2 +-
 net/core/sock.c    |    8 ++++----
 3 files changed, 6 insertions(+), 6 deletions(-)


diff --git a/include/net/sock.h b/include/net/sock.h
index 8ae97c4..348fc9e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1558,7 +1558,7 @@ static inline void sk_wake_async(struct sock *sk,=
 int how, int band)
 }
=20
 #define SOCK_MIN_SNDBUF 2048
-#define SOCK_MIN_RCVBUF 256
+#define SOCK_MIN_RCVBUF 1024
=20
 static inline void sk_stream_moderate_sndbuf(struct sock *sk)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 752c197..5ab2e8e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -196,7 +196,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_=
t gfp_mask,
 	 * the tail pointer in struct sk_buff!
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb->truesize =3D size + sizeof(struct sk_buff);
+	skb->truesize =3D ksize(data) + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 	skb->head =3D data;
 	skb->data =3D data;
diff --git a/net/core/sock.c b/net/core/sock.c
index f3a06c4..803e041 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -535,10 +535,10 @@ int sock_setsockopt(struct socket *sock, int leve=
l, int optname,
 			val =3D sysctl_wmem_max;
 set_sndbuf:
 		sk->sk_userlocks |=3D SOCK_SNDBUF_LOCK;
-		if ((val * 2) < SOCK_MIN_SNDBUF)
+		if ((val * 4) < SOCK_MIN_SNDBUF)
 			sk->sk_sndbuf =3D SOCK_MIN_SNDBUF;
 		else
-			sk->sk_sndbuf =3D val * 2;
+			sk->sk_sndbuf =3D val * 4;
=20
 		/*
 		 *	Wake up sending tasks if we
@@ -579,10 +579,10 @@ set_rcvbuf:
 		 * returning the value we actually used in getsockopt
 		 * is the most desirable behavior.
 		 */
-		if ((val * 2) < SOCK_MIN_RCVBUF)
+		if ((val * 4) < SOCK_MIN_RCVBUF)
 			sk->sk_rcvbuf =3D SOCK_MIN_RCVBUF;
 		else
-			sk->sk_rcvbuf =3D val * 2;
+			sk->sk_rcvbuf =3D val * 4;
 		break;
=20
 	case SO_RCVBUFFORCE:


