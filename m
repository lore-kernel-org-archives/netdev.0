From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 07:46:39 +0200
Message-ID: <1271828799.7895.1287.camel@edumazet-laptop>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <4BCE33B9.8050101@candelatech.com>
	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
	 <4BCE392F.60104@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
	 <1271808314.7895.614.camel@edumazet-laptop>
	 <20100421003022.GA3107@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:61968 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab0DUFqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 01:46:48 -0400
Received: by bwz25 with SMTP id 25so7604516bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 22:46:46 -0700 (PDT)
In-Reply-To: <20100421003022.GA3107@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 04:30 +0400, Evgeniy Polyakov a =C3=A9=
crit :
> On Wed, Apr 21, 2010 at 02:05:14AM +0200, Eric Dumazet (eric.dumazet@=
gmail.com) wrote:
> > I believe the bsockets 'optimization' is a bug, we should remove it=
=2E
> >=20
> > This is a stable candidate (2.6.30+)
> >=20
> > [PATCH net-next-2.6] tcp: remove bsockets count
> >=20
> > Counting number of bound sockets to avoid a loop is buggy, since we=
 cant
> > know how many IP addresses are in use. When threshold is reached, w=
e try
> > 5 random slots and can fail while there are plenty available ports.
>=20
> To return back to exponential bind() times you need to revert the who=
le
> original patch including magic 5 number, not only bsockets.
>=20
> But actual problem is not in this digit, but in a deeper logic.
> Previously we scanned the whole table, now we have 5 attempts to
> find out at least one bucket (without conflict) we will insert
> new socket into. Apparently for large number of addresses it is possi=
ble
> that all 5 times we will randomly select those buckets which conflict=
s.
> As dumb solution we can increase 'attempt' number to infinite one, or
> fallback to whole-table-search after several random attempts, which i=
s a
> bit more clever I think.
>=20

Hmm, maybe I am blind, but on the case the threshold is reached, we don=
t
have 5 attempts "to find out at least one bucket (without conflict)"

We just take the first entry from the random starting point, _without_
checking we have a conflict.

if (net_eq(ib_net(tb), net) && tb->port =3D=3D rover) {
	if (tb->fastreuse > 0 &&
	    sk->sk_reuse &&
	    sk->sk_state !=3D TCP_LISTEN &&
	    (tb->num_owners < smallest_size || smallest_size =3D=3D -1)) {
		smallest_size =3D tb->num_owners;
		smallest_rover =3D rover;
		if (atomic_read(&hashinfo->bsockets) > (high-low)+1) {
			spin_unlock(&head->lock);
			snum =3D smallest_rover;   // We select this, without checking for
conflicts.
			goto have_snum;
		}
	}


Then we goto to "have_snum" label

Then we realize (selected_IP, randomport) is already in use.
End of first try.

We redo the thing 5 times, so we only look at 5 slots out of
32000-64000.

Maybe the fix would need to check if there is a conflict before doing
the "goto have_snum"

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index e0a3e35..0498daf 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -120,9 +120,11 @@ again:
 						smallest_size =3D tb->num_owners;
 						smallest_rover =3D rover;
 						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
-							spin_unlock(&head->lock);
-							snum =3D smallest_rover;
-							goto have_snum;
+							if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb))
+								spin_unlock(&head->lock);
+								snum =3D smallest_rover;
+								goto have_snum;
+							}
 						}
 					}
 					goto next;


