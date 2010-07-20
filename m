From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Tue, 20 Jul 2010 17:20:32 +0200
Message-ID: <1279639232.2498.82.camel@edumazet-laptop>
References: <1279631789.2498.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50438 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932392Ab0GTPUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 11:20:37 -0400
Received: by eya25 with SMTP id 25so1310293eya.19
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 08:20:35 -0700 (PDT)
In-Reply-To: <1279631789.2498.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 juillet 2010 =C3=A0 15:16 +0200, Eric Dumazet a =C3=A9crit =
:
> Please note following potential bug was discovered by code review, an=
d
> my patch not even tested, please double check !
>=20
> Thanks
>=20
> [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
>=20
> commit 1dacc76d0014=20
> (net/compat/wext: send different messages to compat tasks)
> introduced a race condition on netlink, in case MSG_PEEK is used.
>=20
> An skb given by skb_recv_datagram() might be shared, we must clone it
> before any modification, or risk fatal corruption.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Oh well, skb_copy() or skb_unshare() is needed.

[PATCH net-next-2.6 v2] netlink: netlink_recvmsg() fix

commit 1dacc76d0014=20
(net/compat/wext: send different messages to compat tasks)
introduced a race condition on netlink, in case MSG_PEEK is used.

An skb given by skb_recv_datagram() might be shared, we must copy it
before any modification, or risk fatal corruption.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netlink/af_netlink.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7aeaa83..1537fa5 100644
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
@@ -1440,7 +1440,12 @@ static int netlink_recvmsg(struct kiocb *kiocb, =
struct socket *sock,
 			kfree_skb(skb);
 			skb =3D compskb;
 		} else {
-			frag =3D skb_shinfo(skb)->frag_list;
+			skb =3D skb_unshare(skb, GFP_KERNEL);
+			if (!skb) {
+				err =3D -ENOMEM;
+				goto out;
+			}
+			kfree_skb(skb_shinfo(skb)->frag_list);
 			skb_shinfo(skb)->frag_list =3D NULL;
 		}
 	}
@@ -1477,10 +1482,6 @@ static int netlink_recvmsg(struct kiocb *kiocb, =
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


