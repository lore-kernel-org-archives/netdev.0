From: Phil Sutter <phil.sutter@viprinet.com>
Subject: Re: [PATCH] packet: fix leakage of tx_ring memory
Date: Fri, 1 Feb 2013 17:21:20 +0100
Message-ID: <20130201162120.GA5543@philter.vipri.net>
References: <1359727032-7999-1-git-send-email-phil.sutter@viprinet.com>
 <510BE7B4.8070202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Johann Baudy <johann.baudy@gnu-log.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.vipri.net ([89.207.250.15]:35546 "EHLO zimbra.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab3BAQVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 11:21:52 -0500
Content-Disposition: inline
In-Reply-To: <510BE7B4.8070202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2013 at 05:05:08PM +0100, Daniel Borkmann wrote:
> On 02/01/2013 02:57 PM, Phil Sutter wrote:
> > When releasing a packet socket, the routine packet_set_ring() is re=
used
> > to free rings instead of allocating them. But when calling it for t=
he
> > first time, it fills req->tp_block_nr with the value of rb->pg_vec_=
len
> > which in the second invocation makes it bail out since req->tp_bloc=
k_nr
> > is greater zero but req->tp_block_size is zero.
> >
> > This patch solves the problem by passing a zeroed auto-variable to
> > packet_set_ring() upon each invocation from packet_release().
> >
> > As far as I can tell, this issue exists even since 69e3c75 (net: TX=
_RING
> > and packet mmap), i.e. the original inclusion of TX ring support in=
to
> > af_packet, but applies only to sockets with both RX and TX ring
> > allocated, which is probably why this was unnoticed all the time.
> >
> > Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>
> > Cc: Johann Baudy <johann.baudy@gnu-log.net>
> > Cc: stable@kernel.org
> > ---
>=20
> [...]
>=20
> > +static int packet_free_ring(struct sock *sk, int tx_ring)
> > +{
> > +	union tpacket_req_u req_u =3D { 0 };
> > +
> > +	return packet_set_ring(sk, &req_u, 1, tx_ring);
> > +}
> > +
> >   /*
> >    *	Close a PACKET socket. This is fairly simple. We immediately g=
o
> >    *	to 'closed' state and remove our protocol entry in the device =
list.
> > @@ -2338,7 +2345,6 @@ static int packet_release(struct socket *sock=
)
> >   	struct sock *sk =3D sock->sk;
> >   	struct packet_sock *po;
> >   	struct net *net;
> > -	union tpacket_req_u req_u;
> >
> >   	if (!sk)
> >   		return 0;
> > @@ -2364,13 +2370,11 @@ static int packet_release(struct socket *so=
ck)
> >
> >   	packet_flush_mclist(sk);
> >
> > -	memset(&req_u, 0, sizeof(req_u));
> > -
> >   	if (po->rx_ring.pg_vec)
> > -		packet_set_ring(sk, &req_u, 1, 0);
> > +		packet_free_ring(sk, 0);
> >
> >   	if (po->tx_ring.pg_vec)
> > -		packet_set_ring(sk, &req_u, 1, 1);
> > +		packet_free_ring(sk, 1);
>=20
> Good catch!
>=20
> Nitpicking:
>=20
> I think it would be easier / more readable to simply move the memset =
into
> the two ifs than introducing an extra function for just doing that.

Yes, this was just how my fix looked like initially, but I didn't like
the resulting code duplication. Indeed, the extra function adds another
point of code flow redirection. On the other hand, it implicitly points
out that basically the same is done for both rings.

In my point of view, both ways are equally acceptable. If you prefer th=
e
other one for mainline inclusion, just let me know and I submit an
appropriate patch.

> (Also don't cc stable, since David is deciding about this anyway.)

Oh, OK. Thanks for the hint. Every time I wonder how to do this the
right way, seems I haven't found the correct documentation for it yet.
Moreover, stable@kernel.org isn't even valid. I shouldn't have trusted
google (http://www.kernel.org/doc/Documentation/stable_kernel_rules.txt=
)
over my local clones. ;)


Best wishes,

Phil Sutter
Software Engineer

--=20
Viprinet Europe GmbH
Mainzer Str. 43
55411 Bingen am Rhein
Germany

Phone/Zentrale:               +49 6721 49030-0
Direct line/Durchwahl:        +49 6721 49030-134
=46ax:                          +49 6721 49030-109

phil.sutter@viprinet.com
http://www.viprinet.com

Registered office/Sitz der Gesellschaft: Bingen am Rhein, Germany
Commercial register/Handelsregister: Amtsgericht Mainz HRB44090
CEO/Gesch=C3=A4ftsf=C3=BChrer: Simon Kissel
