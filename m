From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: What protects rcu_dereference() in __in6_dev_get()?
Date: Fri, 15 Jan 2010 07:53:09 -0800
Message-ID: <20100115155309.GF6770@linux.vnet.ibm.com>
References: <20100114183215.GA16866@linux.vnet.ibm.com> <4B500217.6070908@gmail.com> <20100115151559.GD6770@linux.vnet.ibm.com> <4B5089CA.2050202@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, peterz@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:35471 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753378Ab0AOPxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 10:53:11 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0FFjCGg015898
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 10:45:12 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0FFrAcO106698
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 10:53:10 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0FFr9cD025545
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 10:53:10 -0500
Content-Disposition: inline
In-Reply-To: <4B5089CA.2050202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2010 at 04:29:14PM +0100, Eric Dumazet wrote:
> Le 15/01/2010 16:15, Paul E. McKenney a =E9crit :
> > On Fri, Jan 15, 2010 at 06:50:15AM +0100, Eric Dumazet wrote:
> >> __in6_dev_get() is called either with rcu_read_lock()/rcu_read_unl=
ock() protection,
> >> or with the RTNL mutex held.
> >=20
> > Very good!  So I make a lockdep_rtnl_is_held() in net/core/rtnetlin=
k.c:
> >=20
> > 	#ifdef CONFIG_PROVE_LOCKING
> > 	int lockdep_rtnl_is_held(void)
> > 	{
> > 		return lockdep_is_held(&rtnl_mutex);
> > 	}
> > 	EXPORT_SYMBOL(lockdep_rtnl_is_held);
> > 	#endif /* #ifdef CONFIG_PROVE_LOCKING */
> >=20
> > Then I make __in6_dev_get() look as follows:
> >=20
> > 	static inline struct inet6_dev *
> > 	__in6_dev_get(struct net_device *dev)
> > 	{
> > 		return rcu_dereference_check(dev->ip6_ptr,
> > 					     rcu_read_lock_held() ||
> > 					     lockdep_rtnl_is_held());
> > 	}
> >=20
> > Seem reasonable?
>=20
> I guess so, but is lockdep_is_held(&mutex) actually cheking this mute=
x is owned by us ?

Indeed it does!  But only if lockdep is enabled.  When lockdep is -not-
enabled, rcu_dereference_check() ignores its second argument.

> If another thread is the owner, we could miss a bug.

That s why I created a new lockdep_rtnl_is_held() rather than using the
existing rtnl_is_locked().

							Thanx, Paul
