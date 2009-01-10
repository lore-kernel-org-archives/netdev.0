From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sat, 10 Jan 2009 08:40:05 +0100
Message-ID: <496850D5.8040907@cosmosbay.com>
References: <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com> <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com> <20090109212400.GA3727@1wt.eu> <20090109220737.GA4111@1wt.eu> <4967CBB9.1060403@cosmosbay.com> <20090109221744.GA4819@1wt.eu> <20090109224258.GA10257@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	ben@zeus.com, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39160 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbZAJHk6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:40:58 -0500
In-Reply-To: <20090109224258.GA10257@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> On Fri, Jan 09, 2009 at 11:17:44PM +0100, Willy Tarreau (w@1wt.eu) wr=
ote:
>> However I'm OK for the !timeo before release_sock/lock_sock. I just
>> don't know if we can put the rest of the if above or not. I don't
>> know what changes we're supposed to collect by doing release_sock/
>> lock_sock before the if().
>=20
> Not to interrupt the discussion, but for the clarification, that
> release_sock/lock_sock is used to process the backlog accumulated whi=
le
> socket was locked. And while dropping additional pair before the fina=
l
> release is ok, but moving this itself should be thought of twice.
>=20

Hum... I just caught the release_sock(sk)/lock_sock(sk) done in skb_spl=
ice_bits()

So :

1) the release_sock/lock_sock done in tcp_splice_read() is not necessar=
y
to process backlog. Its already done in skb_splice_bits()

2) If we loop in tcp_read_sock() calling skb_splice_bits() several time=
s
then we should perform the following tests inside this loop ?

if (sk->sk_err || sk->sk_state =3D=3D TCP_CLOSE || (sk->sk_shutdown & R=
CV_SHUTDOWN) ||
   signal_pending(current)) break;

And removie them from tcp_splice_read() ?



