From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Sat, 16 May 2009 08:40:29 -0400
Message-ID: <20090516124029.GA21086@localhost.localdomain>
References: <20090514004548.GA14428@localhost.localdomain> <20090514010359.GL6752@linux.vnet.ibm.com> <20090514123300.GA7166@hmsreliant.think-freely.org> <20090514124407.GP3517@psychotron.englab.brq.redhat.com> <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515065102.GB25620@psychotron.englab.brq.redhat.com> <20090515105909.GA7745@hmsreliant.think-freely.org> <20090515112736.GG25620@psychotron.englab.brq.redhat.com> <20090515160702.GE7745@hmsreliant.think-freely.org> <4A0DB06D.7000805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45886 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056AbZEPMkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 08:40:45 -0400
Content-Disposition: inline
In-Reply-To: <4A0DB06D.7000805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 08:11:57PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
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
>=20
> > +
> > +		spin_lock(&trace_state_lock);
> > +		if (found && (trace_state =3D=3D TRACE_OFF)) {
> > +			list_del_rcu(&new_stat->list);
> > +			call_rcu(&new_stat->rcu, free_dm_hw_stat);
> > +		}
> > +		spin_unlock(&trace_state_lock);
> > +		break;
>=20
>=20
>=20
>=20
> Its not clear that you use trace_state_lock as the lock guarding all =
this.
>=20
> If this is the case I suggest a plain and straight forward :
>=20
> case NETDEV_UNREGISTER:
> 	spin_lock(&trace_state_lock);
> 	if (trace_state =3D=3D TRACE_OFF) {
> 		list_for_each_entry(new_stat, &hw_stats_list, list) {
> 			if (new_stat->dev =3D=3D dev) {
> 				new_stat->dev =3D NULL;
> 				list_del_rcu(&new_stat->list);
> 				call_rcu(&new_stat->rcu, free_dm_hw_stat);
> 				break;
> 			}
> 		}
> 	}
> 	spin_unlock(&trace_state_lock);
> 	break;
>=20
>=20
>=20
I was thinking about this last night, and I agree, that I think your so=
lution
would be better here (my solution might be racy with regards to a trace=
 state
change resulting in leaked memory.  I'll post a new patch monday.  Sorr=
y for the
trouble.

Neil

