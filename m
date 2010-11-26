From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix __inet_inherit_port() to correctly increment
 bsockets and num_owners
Date: Fri, 26 Nov 2010 11:47:57 +0100
Message-ID: <1290768477.2855.97.camel@edumazet-laptop>
References: <751926.73238.qm@web53707.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43827 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430Ab0KZKsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 05:48:02 -0500
Received: by fxm15 with SMTP id 15so587721fxm.19
        for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 02:48:00 -0800 (PST)
In-Reply-To: <751926.73238.qm@web53707.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nagendra Tomar <tomer_iisc@yahoo.com>

Le vendredi 26 novembre 2010 =C3=A0 01:40 -0800, Nagendra Tomar a =C3=A9=
crit :
>=20
> --- On Fri, 26/11/10, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> >=20
> > OK so you'll have to make a proof, because current code
> > seems to work ;)
> >=20
> >=20
>=20
> ok, so I printed hashinfo->bsockets and tb->num_owners inside
> __inet_put_port() and I could see both of them to be -ve. All we need
> to do is establish and terminate a connection. I used netcat for that=
=2E
>=20
> The only place 'bsockets' and 'num_owners' are used is
> inet_csk_get_port() and the only effect that they might have is on th=
e
> choice of the port to be used for binding.=20
> 'bsockets' is used as a hint to stop searching for a free port (and
> instead share an already used port) when we know that all the ports
> could be used up.
> 'num_owners' is used to find the port which is least shared (to
> balance the 'owners' list) in case we need to share a port.
>=20
> Since both of these are used as optimizations (in the bind path), the=
y
> do not affect correctness and hence the code works even with these
> values not being updated correctly.

Hmm, thanks for clarification.

bsockets / mnum_owners iscount is indeed an 'optimization' problem.

Problem is your patch is not applicable to current tree.

In order to submit it to stable team, you should first post a patch for
next/current kernel (net-next-2.6 tree).

David will decide if its net-2.6 material or not.

You could add in your changelog the problem comes from commit=20
a9d8f9110d7e953c (inet: Allowing more than 64k connections and heavily
optimize bind(0)), included in 2.6.30, to ease stable team work.

On current tree your patch would be :

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 1b344f3..3c0369a 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -133,8 +133,7 @@ int __inet_inherit_port(struct sock *sk, struct soc=
k *child)
 			}
 		}
 	}
-	sk_add_bind_node(child, &tb->owners);
-	inet_csk(child)->icsk_bind_hash =3D tb;
+	inet_bind_hash(child, tb, port);
 	spin_unlock(&head->lock);
=20
 	return 0;


