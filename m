From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
 dropsrxpackets
Date: Fri, 15 May 2009 11:23:45 -0700
Message-ID: <20090515112345.66b8230e@nehalam>
References: <20090512163044.GD5019@hmsreliant.think-freely.org>
	<20090513182354.GH6752@linux.vnet.ibm.com>
	<20090514004548.GA14428@localhost.localdomain>
	<20090514010359.GL6752@linux.vnet.ibm.com>
	<20090514123300.GA7166@hmsreliant.think-freely.org>
	<20090514124407.GP3517@psychotron.englab.brq.redhat.com>
	<20090514172954.GA3867@hmsreliant.think-freely.org>
	<20090515065102.GB25620@psychotron.englab.brq.redhat.com>
	<20090515105909.GA7745@hmsreliant.think-freely.org>
	<20090515112736.GG25620@psychotron.englab.brq.redhat.com>
	<20090515160702.GE7745@hmsreliant.think-freely.org>
	<4A0DB06D.7000805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35594 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbZEOSXu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 14:23:50 -0400
In-Reply-To: <4A0DB06D.7000805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 May 2009 20:11:57 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Neil Horman a =C3=A9crit :
> > +static int dropmon_net_event(struct notifier_block *ev_block,
> > +			unsigned long event, void *ptr)
> > +{
> > +	struct net_device *dev =3D ptr;
> > +	struct dm_hw_stat_delta *new_stat =3D NULL;
> > +	int found =3D 0;
> > +
> > +	switch (event) {
> > +	case NETDEV_REGISTER:
> > +		new_stat =3D kzalloc(sizeof(struct dm_hw_stat_delta), GFP_KERNEL=
);
> > +
> > +		if (!new_stat)
> > +			goto out;
> > +
> > +		new_stat->dev =3D dev;
> > +		INIT_RCU_HEAD(&new_stat->rcu);
> > +		spin_lock(&trace_state_lock);
> > +		list_add_rcu(&new_stat->list, &hw_stats_list);
> > +		spin_unlock(&trace_state_lock);
> > +		break;
> > +	case NETDEV_UNREGISTER:
> > +		rcu_read_lock();
> > +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> > +			if (new_stat->dev =3D=3D dev)
> > +				new_stat->dev =3D NULL;
> > +				found =3D 1;
> > +				break;
> > +		}
> > +		rcu_read_unlock();
>=20
> This is racy, unless caller already owns a lock.
>=20
> If caller aleady owns a lock, you dont need :
>=20
> rcu_read_lock()
> list_for_each_entry_rcu()
> rcu_read_unlock();

RTNL mutex is always held on notification call backs.
Actually why is trace_state_lock needed at all? Why not
just use the RTNL mutex?



--=20
