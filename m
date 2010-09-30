From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH 4/5] AF_UNIX: find peers on multicast Unix stream
 sockets
Date: Thu, 30 Sep 2010 20:24:29 +0100
Message-ID: <20100930202429.42808a38@chocolatine.cbg.collabora.co.uk>
References: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
 <1285349116-17529-4-git-send-email-alban.crequy@collabora.co.uk>
 <1285351237.2478.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285351237.2478.7.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Fri, 24 Sep 2010 20:00:37 +0200,
Eric Dumazet <eric.dumazet@gmail.com> a =C3=A9crit :

> Le vendredi 24 septembre 2010 =C3=A0 18:25 +0100, Alban Crequy a =C3=A9=
crit :
>=20
> > @@ -1612,7 +1671,12 @@ static int unix_stream_sendmsg(struct kiocb
> > *kiocb, struct socket *sock, } else {
> >  		sunaddr =3D NULL;
> >  		err =3D -ENOTCONN;
> > -		other =3D NULL; /* FIXME: get the list of other
> > connection */
> > +		max_others =3D atomic_read(&unix_nr_multicast_socks);
> > +		others =3D kzalloc((max_others + 1) * sizeof(void
> > *), GFP_KERNEL);
> > +		unix_find_other(sock_net(sk), u->addr->name,
> > +		    u->addr->len, 0, u->addr->hash, 1, others,
> > max_others, &err);
> > +		other =3D others[0];
> > +		kfree(others);
> >  		if (!other)
> >  			goto out_err;
> >  	}
>=20
> Seriously, this block sizing against unix_nr_multicast_socks is not
> scalable. What happens if we have 1000 sockets ?
> kzalloc() to clear 8000 bytes ?
> Its also unsafe.
>=20
> (say you kzalloc() a buffer for 2 sockets, and another cpu inserts a
> new socket. unix_find_socket_byname() can overflow the buffer)
>=20
>=20
> You should use a list, and allocates elements in
> unix_find_socket_byname()
>=20
> struct item {
> 	struct item *next;
> 	struct sock *s;
> };

Thanks for your review.

I cannot allocate elements directly in unix_find_socket_byname()
iteration after iteration because the spinlock "unix_table_lock" is
held. If I release the spinlock to allocate, the number of sockets in
the table may change.

I changed the code to count the sockets with the lock held and then
allocate. In the unfortunate case where the allocation is not big
enough (if another process inserts a new socket), it just tries again.

The code is available here. Please pull from:

git://git.collabora.co.uk/git/user/alban/linux-2.6.35.y/.git unix-multi=
cast2

It is still a work in progress. Missing pieces:

- The flow control does not work correctly: poll/select does not match
  the reality

- Atomic delivery: if a process is killed or interrupted in the middle
  of a delivery, only a subset of the recipients will get the message=20

- Some locking to provide the same delivery order to all the recipients
  when several senders run concurrently.

=46eedback welcome,

Alban Crequy
