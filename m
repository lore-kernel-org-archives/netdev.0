From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What protects rcu_dereference() in __in6_dev_get()?
Date: Fri, 15 Jan 2010 16:29:14 +0100
Message-ID: <4B5089CA.2050202@gmail.com>
References: <20100114183215.GA16866@linux.vnet.ibm.com> <4B500217.6070908@gmail.com> <20100115151559.GD6770@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, peterz@infradead.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49098 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113Ab0AOPaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 10:30:09 -0500
In-Reply-To: <20100115151559.GD6770@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/01/2010 16:15, Paul E. McKenney a =E9crit :
> On Fri, Jan 15, 2010 at 06:50:15AM +0100, Eric Dumazet wrote:
>> __in6_dev_get() is called either with rcu_read_lock()/rcu_read_unloc=
k() protection,
>> or with the RTNL mutex held.
>=20
> Very good!  So I make a lockdep_rtnl_is_held() in net/core/rtnetlink.=
c:
>=20
> 	#ifdef CONFIG_PROVE_LOCKING
> 	int lockdep_rtnl_is_held(void)
> 	{
> 		return lockdep_is_held(&rtnl_mutex);
> 	}
> 	EXPORT_SYMBOL(lockdep_rtnl_is_held);
> 	#endif /* #ifdef CONFIG_PROVE_LOCKING */
>=20
> Then I make __in6_dev_get() look as follows:
>=20
> 	static inline struct inet6_dev *
> 	__in6_dev_get(struct net_device *dev)
> 	{
> 		return rcu_dereference_check(dev->ip6_ptr,
> 					     rcu_read_lock_held() ||
> 					     lockdep_rtnl_is_held());
> 	}
>=20
> Seem reasonable?

I guess so, but is lockdep_is_held(&mutex) actually cheking this mutex =
is owned by us ?

If another thread is the owner, we could miss a bug.

