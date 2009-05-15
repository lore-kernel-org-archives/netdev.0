From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Fri, 15 May 2009 15:53:21 -0400
Message-ID: <20090515195321.GH7745@hmsreliant.think-freely.org>
References: <20090514010359.GL6752@linux.vnet.ibm.com> <20090514123300.GA7166@hmsreliant.think-freely.org> <20090514124407.GP3517@psychotron.englab.brq.redhat.com> <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515065102.GB25620@psychotron.englab.brq.redhat.com> <20090515105909.GA7745@hmsreliant.think-freely.org> <20090515112736.GG25620@psychotron.englab.brq.redhat.com> <20090515160702.GE7745@hmsreliant.think-freely.org> <4A0DB06D.7000805@cosmosbay.com> <20090515112345.66b8230e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>, Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40167 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbZEOTxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 15:53:36 -0400
Content-Disposition: inline
In-Reply-To: <20090515112345.66b8230e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 11:23:45AM -0700, Stephen Hemminger wrote:
> On Fri, 15 May 2009 20:11:57 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
> > Neil Horman a =E9crit :
> > > +static int dropmon_net_event(struct notifier_block *ev_block,
> > > +			unsigned long event, void *ptr)
> > > +{
> > > +	struct net_device *dev =3D ptr;
> > > +	struct dm_hw_stat_delta *new_stat =3D NULL;
> > > +	int found =3D 0;
> > > +
> > > +	switch (event) {
> > > +	case NETDEV_REGISTER:
> > > +		new_stat =3D kzalloc(sizeof(struct dm_hw_stat_delta), GFP_KERN=
EL);
> > > +
> > > +		if (!new_stat)
> > > +			goto out;
> > > +
> > > +		new_stat->dev =3D dev;
> > > +		INIT_RCU_HEAD(&new_stat->rcu);
> > > +		spin_lock(&trace_state_lock);
> > > +		list_add_rcu(&new_stat->list, &hw_stats_list);
> > > +		spin_unlock(&trace_state_lock);
> > > +		break;
> > > +	case NETDEV_UNREGISTER:
> > > +		rcu_read_lock();
> > > +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> > > +			if (new_stat->dev =3D=3D dev)
> > > +				new_stat->dev =3D NULL;
> > > +				found =3D 1;
> > > +				break;
> > > +		}
> > > +		rcu_read_unlock();
> >=20
> > This is racy, unless caller already owns a lock.
> >=20
> > If caller aleady owns a lock, you dont need :
> >=20
> > rcu_read_lock()
> > list_for_each_entry_rcu()
> > rcu_read_unlock();
>=20
> RTNL mutex is always held on notification call backs.
> Actually why is trace_state_lock needed at all? Why not
> just use the RTNL mutex?
>=20
Theres also a need for this mutex to protect simeoustaneous state chang=
es to the
tracer from userspace.  I suppose I could use the rtnl lock for that, b=
ut I
think this is more readable.

Neil

>=20
>=20
> --=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
