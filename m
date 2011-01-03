From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Mon, 03 Jan 2011 10:08:52 +0100
Message-ID: <1294045732.19666.6.camel@wall-e>
References: <1294007971-18878-1-git-send-email-stefani@seibold.net>
	 <1294008562.2535.263.camel@edumazet-laptop>
	 <1294008917.18963.3.camel@wall-e>
	 <alpine.LNX.2.00.1101022356550.11481@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com,
	daniel.baluta@gmail.com, jochen@jochen.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1101022356550.11481@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, den 03.01.2011, 00:04 +0100 schrieb Jesper Juhl:
> On Sun, 2 Jan 2011, Stefani Seibold wrote:
>=20
> > Am Sonntag, den 02.01.2011, 23:49 +0100 schrieb Eric Dumazet:
> > > Le dimanche 02 janvier 2011 =E0 23:39 +0100, stefani@seibold.net =
a =E9crit :
> > > > +
> > > > +/*
> > > > + * Create a new destination descriptor for the given IPV4 addr=
ess and port
> > > > + */
> > > > +static struct udpcp_dest *new_dest(struct sock *sk, __be32 add=
r, __be16 port)
> > > > +{
> > > > +	struct udpcp_dest *dest;
> > > > +	struct udpcp_sock *usk =3D udpcp_sk(sk);
> > > > +
> > > > +	if (usk->connections >=3D udpcp_max_connections)
> > > > +		return NULL;
> > > > +
> > > > +	dest =3D kzalloc(sizeof(*dest), sk->sk_allocation);
> > > > +
> > > > +	if (dest) {
> > > > +		usk->connections++;
> > > > +		skb_queue_head_init(&dest->xmit);
> > > > +		dest->addr =3D addr;
> > > > +		dest->port =3D port;
> > > > +		dest->ackmode =3D UDPCP_ACK;
> > > > +		list_add_tail(&dest->list, &usk->destlist);
> > > > +	}
> > > > +
> > > > +	return dest;
> > > > +}
> > > > +
> > >=20
> > > Hmm, so 'connections' is increased, never decreased.
> > >=20
> > > This seems a fatal flaw in this protocol, since a malicious user =
can
> > > easily fill the list with garbage, and block regular communicatio=
ns.
> >=20
> > You are right, there is now way to detect which connection is no lo=
nger
> > needed. I have not designed this protocol, so i cannot fix it.=20
> >=20
> > But in our environment this will be used together with an firewall
> > and/or ipsec. In this case it it safe.
> >=20
>=20
> Hmm, the first thing that springs into my head as a possible band-aid=
=20
> (which is probbaly wrong for many reasons I've not considered, so fee=
l=20
> free to shoot it down) is; couldn't we use a timer (set to some outra=
geous=20
> high value by default and admin tunable) that would decrement=20
> 'connections' (discount dead connections) when there has not been any=
=20
> acctivity for a huge period of time? Kill off connections that have b=
een=20
> idle for ages.
>=20

This will not work for two reasons:

- First there is no way to detect a dead connection. A connection can
stay for a very long time without data transfer.

- Second it will not save against a attack where all communication slot=
s
will be eaten by an attacker and then new valid connections will be not
handled.

The only thing what is possible to make an ioctl call which allows the
user land client to cancel connections.=20

But this will be in my opinion dead code, because white lists of truste=
d
address must be fostered and this will make the upgrading of a
infrastructure to complicate.
