From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFT 3/3] iptables: lock free counters
Date: Mon, 9 Feb 2009 09:14:37 -0800
Message-ID: <20090209091437.5d5cbf48@extreme>
References: <20090204001202.724266235@vyatta.com>
	<20090204001755.808036408@vyatta.com>
	<4989071E.5000803@cosmosbay.com>
	<4990515B.3070409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56782 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753842AbZBIROj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 12:14:39 -0500
In-Reply-To: <4990515B.3070409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 09 Feb 2009 16:52:59 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Eric Dumazet wrote:
> > Stephen Hemminger a =C3=A9crit :
> >> @@ -939,14 +973,30 @@ static struct xt_counters * alloc_counte
> >>  	counters =3D vmalloc_node(countersize, numa_node_id());
> >> =20
> >>  	if (counters =3D=3D NULL)
> >> -		return ERR_PTR(-ENOMEM);
> >> +		goto nomem;
> >> +
> >> +	tmp =3D xt_alloc_table_info(private->size);
> >> +	if (!tmp)
> >> +		goto free_counters;
> >> +
> >=20
> >> +	xt_zero_table_entries(tmp);
> > This is not correct. We must copy rules and zero counters on the co=
pied stuff.
>=20
> Indeed.
It is in next version.

> >>  static int
> >>  do_add_counters(struct net *net, void __user *user, unsigned int =
len, int compat)
> >> @@ -1393,13 +1422,14 @@ do_add_counters(struct net *net, void __
> >>  		goto free;
> >>  	}
> >> =20
> >> -	write_lock_bh(&t->lock);
> >> +	mutex_lock(&t->lock);
> >>  	private =3D t->private;
> >>  	if (private->number !=3D num_counters) {
> >>  		ret =3D -EINVAL;
> >>  		goto unlock_up_free;
> >>  	}
> >> =20
> >> +	preempt_disable();
> >>  	i =3D 0;
> >>  	/* Choose the copy that is on our node */
>=20
> This isn't actually necessary, its merely an optimization. Since this
> can take quite a while, it might be nicer not to disable preempt.

Need to stay on same cpu, to avoid race of preempt and two cpu's updati=
ng
same counter entry (and 64 bit counter update is not atomic)
