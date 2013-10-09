From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG in net/l2tp/l2tp_core.c
Date: Wed, 09 Oct 2013 04:05:30 -0700
Message-ID: <1381316730.4971.16.camel@edumazet-glaptop.roam.corp.google.com>
References: <52552BDF.8070800@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois?= Cachereul <f.cachereul@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:62302 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab3JILFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 07:05:32 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so879244pab.13
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 04:05:31 -0700 (PDT)
In-Reply-To: <52552BDF.8070800@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-09 at 12:11 +0200, Fran=C3=A7ois Cachereul wrote:
> Hi,
>=20
> I got the following BUG when using l2tp modules with smp kernel.
> I noticed that l2tp_xmit_skb uses bh_lock_sock/bh_unlok_sock which
> doesn't seem to be correct because it does a lot of stuff and probabl=
y
> sleep before releasing the lock. I try replacing
> bh_lock_sock/bh_unlock_sock with lock_sock/release_sock and the BUG
> doesn't happened anymore. Is it correct ?
>=20
> Regards
> Fran=C3=A7ois
>=20

At first glance, you might read commit
6af88da14ee284aaad6e4326da09a89191ab6165
("l2tp: Fix locking in l2tp_core.c")

l2tp_eth_dev_xmit() is called from BH context, so you cannot use
lock_sock()

Try the following patch instead :

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index f0a7ada..ffda81e 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -353,7 +353,9 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, str=
uct socket *sock, struct msgh
 		goto error_put_sess_tun;
 	}
=20
+	local_bh_disable();
 	l2tp_xmit_skb(session, skb, session->hdr_len);
+	local_bh_enable();
=20
 	sock_put(ps->tunnel_sock);
 	sock_put(sk);
@@ -422,7 +424,9 @@ static int pppol2tp_xmit(struct ppp_channel *chan, =
struct sk_buff *skb)
 	skb->data[0] =3D ppph[0];
 	skb->data[1] =3D ppph[1];
=20
+	local_bh_disable();
 	l2tp_xmit_skb(session, skb, session->hdr_len);
+	local_bh_enable();
=20
 	sock_put(sk_tun);
 	sock_put(sk);
