From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [RFC PATCHv2 net-next 1/2] tcp: RTO Restart (RTOR)
Date: Thu, 10 Dec 2015 07:51:46 +0100
Message-ID: <475C1718-ADEE-4839-AC8C-77E3C1353DF4@kau.se>
References: <cover.1449478261.git.per.hurtig@kau.se> <cover.1449561786.git.per.hurtig@kau.se> <8cd2c4817d86e30b09fe398c6bfcb7a89521bdb3.1449561786.git.per.hurtig@kau.se> <1449582430.7632.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Content-Type: multipart/signed; boundary="Apple-Mail=_C0929C80-70F5-47FA-867A-4A6A3E26A29B"; protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	ncardwell@google.com, nanditad@google.com, tom@herbertland.com,
	Yuchung Cheng <ycheng@google.com>, viro@zeniv.linux.org.uk,
	fw@strlen.de, mleitner@redhat.com, daniel@iogearbox.net,
	willemb@google.com, ilpo.jarvinen@helsinki.fi,
	pasi.sarolahti@iki.fi, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	=?utf-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	apetlund@simula.no, Michael Welzl <michawe@ifi.uio.no>,
	Mohammad Rajiullah <mohammad.rajiullah@kau.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:64969 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753063AbbLJHBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 02:01:31 -0500
In-Reply-To: <1449582430.7632.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_C0929C80-70F5-47FA-867A-4A6A3E26A29B
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8


> On 08 Dec 2015, at 14:47, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> On Tue, 2015-12-08 at 10:19 +0100, Per Hurtig wrote:
>=20
>> +static u32 tcp_unsent_pkts(const struct sock *sk, u32 ulimit)
>> +{
>> +	struct sk_buff *skb =3D tcp_send_head(sk);
>> +	u32 pkts =3D 0;
>> +
>> +	if (skb)
>> +		tcp_for_write_queue_from(skb, sk) {
>> +			pkts +=3D tcp_skb_pcount(skb);
>> +
>> +			if (ulimit && pkts >=3D ulimit)
>> +				return ulimit;
>> +		}
>> +
>> +	return pkts;
>> +}
>=20
>=20
> Considering Yuchung feedback, have you looked at using an =
approximation
> instead ?
>=20
> (ie using tp->write_seq - tp->snd_nxt)
>=20
>=20

Well, an approximation is rather =E2=80=9Cdangerous=E2=80=9D as missing =
a single packet
could inhibit the desired behaviour. If looping is undesired, I think a
better solution is to actually *not* do this check at all and instead =
rely
solely on the

tp->packets_out < TCP_RTORESTART_THRESH

check instead. The reason why the number of unsent packets was
included was only to fix a corner case where it should be possible
to use the modified restart, but impossible due to the conditioning.

However, this corner case is likely to not occur very often and we
may be better off with the simpler check.

The corner case (if I remember this correctly) is that the restart is
not triggered when you have 2 segments in flight and (i) have a
congestion window of exactly 3; or (ii) get a packet written to the =
socket
just between previous data transmission and the arrival of the
acknowledgment that triggers the restart.


=E2=80=94 Per


--Apple-Mail=_C0929C80-70F5-47FA-867A-4A6A3E26A29B
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCAAGBQJWaSEIAAoJEMzXVkqMT/z2PWsIAIwAQjR1/Tl4HnwkpwC8yYD+
OtvuzehnmYKRBnVjKpwsD1hzu1TmTL4XUeUK7qhplOvsrmRZNYcu0JGVprdAFqUF
z5liRTf1AiNhm/2qU0i5ATO5pd+lvM4t/0wEgfXlpERptj4SahhjFxHtDTqpLy6q
+SwHo1bDUa9jhI7kPAz39RcpqYlXJQNPQ6kPKeVvHBCsl69AOMqgt6KNCwDdLPqq
8fHc33eevPBrQ1DJCMI9pNcwIffBm5j0spi6JJnXWPAJRlrZKXVuD4K6T9OqbS8U
vx5hflWLQQaqJaHq6euCg2iA8CCnv4QMntlGe6H10bKx2qgYdDcNnNJ8PgszWGk=
=ViAS
-----END PGP SIGNATURE-----

--Apple-Mail=_C0929C80-70F5-47FA-867A-4A6A3E26A29B--
