From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Wed, 21 Jul 2010 10:43:55 +0200
Message-ID: <1279701835.2452.17.camel@edumazet-laptop>
References: <1279631789.2498.71.camel@edumazet-laptop>
	 <1279639232.2498.82.camel@edumazet-laptop>
	 <1279699529.3707.5.camel@jlt3.sipsolutions.net>
	 <1279700420.2452.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43248 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933744Ab0GUIn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 04:43:58 -0400
Received: by wwj40 with SMTP id 40so1996524wwj.1
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 01:43:57 -0700 (PDT)
In-Reply-To: <1279700420.2452.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 juillet 2010 =C3=A0 10:20 +0200, Eric Dumazet a =C3=A9cr=
it :

> Nothing can touch this skb at the same time but us and our friends
> (consumers that did a skb_recv_datagram( MSG_PEEK ) operation).
>=20
> Oh well, I see skb_unshare() tests skb_cloned(). This is not what we
> want.
>=20

Here is V3 of this patch.

Thanks

[PATCH net-next-2.6 v3] netlink: netlink_recvmsg() fix

commit 1dacc76d0014=20
(net/compat/wext: send different messages to compat tasks)
introduced a race condition on netlink, in case MSG_PEEK is used.

An skb given by skb_recv_datagram() might be shared, we must copy it
before any modification, or risk fatal corruption.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netlink/af_netlink.c |   22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7aeaa83..0c86657 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1405,7 +1405,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, s=
truct socket *sock,
 	struct netlink_sock *nlk =3D nlk_sk(sk);
 	int noblock =3D flags&MSG_DONTWAIT;
 	size_t copied;
-	struct sk_buff *skb, *frag __maybe_unused =3D NULL;
+	struct sk_buff *skb;
 	int err;
=20
 	if (flags&MSG_OOB)
@@ -1440,7 +1440,21 @@ static int netlink_recvmsg(struct kiocb *kiocb, =
struct socket *sock,
 			kfree_skb(skb);
 			skb =3D compskb;
 		} else {
-			frag =3D skb_shinfo(skb)->frag_list;
+			/*
+			 * Before setting frag_list to NULL, we must get a
+			 * private copy of skb if shared (because of MSG_PEEK)
+			 */
+			if (skb_shared(skb) {
+				struct sk_buff *nskb;
+
+				nskb =3D pskb_copy(skb, GFP_KERNEL);
+				kfree_skb(skb);
+				skb =3D nskb;
+				err =3D -ENOMEM;
+				if (!skb)
+					goto out;
+			}
+			kfree_skb(skb_shinfo(skb)->frag_list);
 			skb_shinfo(skb)->frag_list =3D NULL;
 		}
 	}
@@ -1477,10 +1491,6 @@ static int netlink_recvmsg(struct kiocb *kiocb, =
struct socket *sock,
 	if (flags & MSG_TRUNC)
 		copied =3D skb->len;
=20
-#ifdef CONFIG_COMPAT_NETLINK_MESSAGES
-	skb_shinfo(skb)->frag_list =3D frag;
-#endif
-
 	skb_free_datagram(sk, skb);
=20
 	if (nlk->cb && atomic_read(&sk->sk_rmem_alloc) <=3D sk->sk_rcvbuf / 2=
)


