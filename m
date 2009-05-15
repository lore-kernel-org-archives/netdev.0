From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Fri, 15 May 2009 07:12:41 -0400
Message-ID: <20090515111241.GC7745@hmsreliant.think-freely.org>
References: <4A05230B.6070806@cosmosbay.com> <20090512163044.GD5019@hmsreliant.think-freely.org> <20090513182354.GH6752@linux.vnet.ibm.com> <20090514004548.GA14428@localhost.localdomain> <20090514010359.GL6752@linux.vnet.ibm.com> <20090514123300.GA7166@hmsreliant.think-freely.org> <20090514124407.GP3517@psychotron.englab.brq.redhat.com> <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515065102.GB25620@psychotron.englab.brq.redhat.com> <4A0D1BB8.10204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58637 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbZEOLMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 07:12:55 -0400
Content-Disposition: inline
In-Reply-To: <4A0D1BB8.10204@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 09:37:28AM +0200, Eric Dumazet wrote:
> Jiri Pirko a =E9crit :
> > Thu, May 14, 2009 at 07:29:54PM CEST, nhorman@tuxdriver.com wrote:
> >> On Thu, May 14, 2009 at 02:44:08PM +0200, Jiri Pirko wrote:
> >>>> +
> >>>> +		/*
> >>>> +		 * Clean the device list
> >>>> +		 */
> >>>> +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> >>> 		^^^^^^^^^^^^^^^^^^^^^^^
> >>> This is meaningless here. Use list_for_each_entry_rcu only under =
rcu_read_lock.
> >>> Also it would be good to use list_for_each_entry_safe here since =
you're
> >>> modifying the list.
> >>>
> >> The definition of list_for_each_entry_rcu specifically says its sa=
fe against
> >> list-mutation primitives, so its fine.  Although you are correct, =
in that its
> >> safety is dependent on the protection of rcu_read_lock(), so I'll =
add that in.
> >=20
> > You are right that list_for_each_entry_rcu is safe against list-mut=
ation
> > primitives. But there's no need for this on the update side when yo=
u hold a writer
> > spinlock. Here I think it's better (and also less confusing) to use=
 ordinary
> > list_for_each_entry which in this case must be list_for_each_entry_=
safe.
>=20
> Absolutely.
>=20
> RCU is tricky, and must be well understood. Using the right verbs is =
really needed
> to help everybody read the code and be able to understand it quickly =
and maintain it
> if needed.
>=20
> In this particular case, the list_for_each_entry_rcu() is a litle bit=
 more
> expensive than regular list_for_each_entry(), as it includes addition=
nal barriers.
>=20
> Just reading code like this :
>=20
> +	spin_lock(&trace_state_lock);
> +		rcu_read_lock();
> +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> +			if (new_stat->dev =3D=3D NULL) {
> +				list_del_rcu(&new_stat->list);
> +				call_rcu(&new_stat->rcu, free_dm_hw_stat);
> +			}
> +		}
> +		rcu_read_unlock();
> +	spin_unlock(&trace_state_lock);
>=20
> We *know* something is wrong, as rcu_read_lock() is supposed to guard=
 a readside,
> so having both rcu_read_lock() and list_del_rcu() is certainly wrong,=
 we dont have=20
> to actually understand what is really done by the algorithm.
>=20
> So following is much better : (but maybe not correct... I let you=20
> check if list_for_each_entry_safe() would not be better here, since
> you delete elements in a list while iterating in it)
>=20
> Maybe you can add a break; after call_rcu() if you know only one elem=
ent
> can match the "if (new_stat->dev =3D=3D NULL) " condition, and use no=
rmal list_for_each_entry()
>=20
> +	spin_lock(&trace_state_lock);
> +		list_for_each_entry(new_stat, &hw_stats_list, list) {
> +			if (new_stat->dev =3D=3D NULL) {
> +				list_del_rcu(&new_stat->list);
> +				call_rcu(&new_stat->rcu, free_dm_hw_stat);
> +			}
> +		}
> +	spin_unlock(&trace_state_lock);
>=20
> Even if the 'wrong' version was not buggy (no crashes or corruption),=
 the 'right' one
> is a commonly used construct in kernel that most dev are able to read=
 without asking=20
> themselves "is is correct or not ? Dont we have something strange her=
e ?"
>=20
> Neil, you need to read more code playing with RCU to get familiar wit=
h it, we all did same
> errors in the past :)
>=20

Thanks :)
So help me understand something here then.  The trace_state_lock has no
intention of protecting the actual read side of this list (the the napi=
 trace
hook that this patch adds).  My understanding of list_for_each_entry_rc=
u and
list_del_rcu, was that even with a call list_del_rcu, the list remained
unchanged unti a quiescent point was passed by all cpus (which is detec=
ted via
the counter in rcu_read_[un]lock.  How is it insufficient to use
rcu_read_[un]lock here to implement that protection?  I agree it looks
counterintuitive, but it makes sense to me from a function standpoint.

=46urther to that point, given the example that you have above of what =
you think
_should_ work, is exactly what I have in the set_all_monitor_trace func=
tion
currently (saving for the conversion of list_for_each_entry_rcu to
list_for_each_entry_safe and the removal of the read_lock).  If those c=
hanges
improve performance, then I can get behind them, but I don't see what p=
roblem
they avoid if I don't use them.  Can you clarify that?

Regards
Neil

>=20
>=20
