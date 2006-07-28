From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules
	Framework
Date: Fri, 28 Jul 2006 11:25:27 +0200
Message-ID: <1154078728.23563.21.camel@localhost.localdomain>
References: <20060726221100.325687073@postel.suug.ch>
	 <20060726221849.807482409@postel.suug.ch>
	 <Pine.LNX.4.64.0607270158001.4779@d.namei>
	 <20060726.230230.111423566.davem@davemloft.net>
	 <20060727223931.GZ14627@postel.suug.ch>  <44C94529.5080605@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-41wQMkJqqxJ6qWPftWk0"
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	jmorris@namei.org, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront1.citynet.nu ([217.10.96.36]:4528 "EHLO
	mailfront1.citynet.nu") by vger.kernel.org with ESMTP
	id S1161118AbWG1J0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 05:26:04 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44C94529.5080605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-41wQMkJqqxJ6qWPftWk0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-07-28 at 00:58 +0200, Patrick McHardy wrote:

> > +int fib_rules_lookup(struct fib_rules_ops *ops, struct flowi *fl,
> > +		     int flags, struct fib_lookup_arg *arg)
> > +{
> > +	struct fib_rule *rule;
> > +	int err;
> > +
> > +	rcu_read_lock();
> > +
> > +	list_for_each_entry(rule, ops->rules_list, list) {
>=20
> Shouldn't that be list_for_each_entry_rcu?

Yes that's correct, it should.

> > +		if (rule->ifname[0] && (rule->ifindex !=3D fl->iif))
> > +			continue;
> > +
> > +		if (!ops->match(rule, fl, flags))
> > +			continue;
> > +
> > +		rcu_read_unlock();
> > +
> > +		err =3D ops->action(rule, fl, flags, arg);
> > +		if (err !=3D -EAGAIN) {
> > +			fib_rule_get(rule);
> > +			arg->rule =3D rule;
> > +			goto out;
> > +		}
> > +	}
> > +
> > +	err =3D -ENETUNREACH;
> > +out:
> > +	rcu_read_unlock();
>=20
> rcu_read_unlock might get called multiple times in the list iteration
> and once again here.

Yes, the rcu_read_unlock() in the list iteration is misplaced, it
shouldn't be there. Besides the unbalanced lock/unlocks it suffers from
the general issue described below

As a somewhat related note, I've just digged a bit through RCU land,
talked to dipankar and mckenney, and discovered that rcu_read_lock() /
rcu_read_unlock() aren't strictly needed in softirqs since preempt is
already disabled in softirqs. This means that you can use the result of
the rcu read-side critical outside of the rcu_read_lock() /
rcu_read_unlock() section. BUT this changes with the -rt kernel where
softirqs are preemptable and where rcu_read_lock() / rcu_read_unlock()
doesn't disable/enable preempt anymore, which means the rcu read-side
critical section is also preemptable. This means that we can get
preempted in the read-side critical section but the resulting grace
period won't occur until rcu_read_unlock() is called, which means that
using results of an read-side critical section outside of the critical
section is just not going to work in softirqs in -rt kernels.
I'm sure Ingo has reviewed the RCU usage in softirqs but I don't know if
there's been any changes in this area after his review.

--=20
/Martin

--=-41wQMkJqqxJ6qWPftWk0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQBEydgHWm2vlfa207ERAnjPAJ4+oQSUxGHGHBnZtF29TLpYz1mZMgCgsC7H
WYkxWVg44jFQHGPIrAZuTV0=
=KhOD
-----END PGP SIGNATURE-----

--=-41wQMkJqqxJ6qWPftWk0--

