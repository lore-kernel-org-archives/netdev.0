From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware	dropsrxpackets
Date: Fri, 15 May 2009 20:11:57 +0200
Message-ID: <4A0DB06D.7000805@cosmosbay.com>
References: <20090512163044.GD5019@hmsreliant.think-freely.org> <20090513182354.GH6752@linux.vnet.ibm.com> <20090514004548.GA14428@localhost.localdomain> <20090514010359.GL6752@linux.vnet.ibm.com> <20090514123300.GA7166@hmsreliant.think-freely.org> <20090514124407.GP3517@psychotron.englab.brq.redhat.com> <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515065102.GB25620@psychotron.englab.brq.redhat.com> <20090515105909.GA7745@hmsreliant.think-freely.org> <20090515112736.GG25620@psychotron.englab.brq.redhat.com> <20090515160702.GE7745@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39425 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757151AbZEOSMY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 14:12:24 -0400
In-Reply-To: <20090515160702.GE7745@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> +static int dropmon_net_event(struct notifier_block *ev_block,
> +			unsigned long event, void *ptr)
> +{
> +	struct net_device *dev =3D ptr;
> +	struct dm_hw_stat_delta *new_stat =3D NULL;
> +	int found =3D 0;
> +
> +	switch (event) {
> +	case NETDEV_REGISTER:
> +		new_stat =3D kzalloc(sizeof(struct dm_hw_stat_delta), GFP_KERNEL);
> +
> +		if (!new_stat)
> +			goto out;
> +
> +		new_stat->dev =3D dev;
> +		INIT_RCU_HEAD(&new_stat->rcu);
> +		spin_lock(&trace_state_lock);
> +		list_add_rcu(&new_stat->list, &hw_stats_list);
> +		spin_unlock(&trace_state_lock);
> +		break;
> +	case NETDEV_UNREGISTER:
> +		rcu_read_lock();
> +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> +			if (new_stat->dev =3D=3D dev)
> +				new_stat->dev =3D NULL;
> +				found =3D 1;
> +				break;
> +		}
> +		rcu_read_unlock();

This is racy, unless caller already owns a lock.

If caller aleady owns a lock, you dont need :

rcu_read_lock()
list_for_each_entry_rcu()
rcu_read_unlock();

> +
> +		spin_lock(&trace_state_lock);
> +		if (found && (trace_state =3D=3D TRACE_OFF)) {
> +			list_del_rcu(&new_stat->list);
> +			call_rcu(&new_stat->rcu, free_dm_hw_stat);
> +		}
> +		spin_unlock(&trace_state_lock);
> +		break;




Its not clear that you use trace_state_lock as the lock guarding all th=
is.

If this is the case I suggest a plain and straight forward :

case NETDEV_UNREGISTER:
	spin_lock(&trace_state_lock);
	if (trace_state =3D=3D TRACE_OFF) {
		list_for_each_entry(new_stat, &hw_stats_list, list) {
			if (new_stat->dev =3D=3D dev) {
				new_stat->dev =3D NULL;
				list_del_rcu(&new_stat->list);
				call_rcu(&new_stat->rcu, free_dm_hw_stat);
				break;
			}
		}
	}
	spin_unlock(&trace_state_lock);
	break;


