From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Wed, 16 Jun 2010 09:01:04 -0700
Message-ID: <20100616160104.GC2457@linux.vnet.ibm.com>
References: <20100610145915.721a86b7@nehalam>
 <20100610224839.GA22469@gondor.apana.org.au>
 <20100611021142.GA24490@gondor.apana.org.au>
 <20100615.113940.245399246.davem@davemloft.net>
 <1276657139.19249.50.camel@edumazet-laptop>
 <20100616050808.GD2911@linux.vnet.ibm.com>
 <1276669281.19249.62.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	shemminger@vyatta.com, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, mpm@selenic.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:45583 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759205Ab0FPQBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 12:01:07 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5GFkILZ000564
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 11:46:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5GG16w6080056
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 12:01:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5GG14wd004565
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 12:01:05 -0400
Content-Disposition: inline
In-Reply-To: <1276669281.19249.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 16, 2010 at 08:21:21AM +0200, Eric Dumazet wrote:
> Le mardi 15 juin 2010 =E0 22:08 -0700, Paul E. McKenney a =E9crit :
> > On Wed, Jun 16, 2010 at 04:58:59AM +0200, Eric Dumazet wrote:
> > >=20
> > > Paul, could you please explain if current lockdep rules are corre=
ct, or could be relaxed ?
> > >=20
> > > I thought :
> > >=20
> > > rcu_read_lock_bh();
> > >=20
> > > was a shorthand to
> > >=20
> > > local_disable_bh();
> > > rcu_read_lock();
> >=20
> > In CONFIG_TREE_RCU and CONFIG_TINY_RCU, rcu_read_lock_bh() is actua=
lly
> > shorthand for only local_disable_bh().  Therefore, rcu_dereference(=
)
> > will scream if only rcu_read_lock_bh() is held.
> >=20
> > However, in CONFIG_PREEMPT_TREE_RCU, rcu_read_lock_bh() is its own
> > mechanism that does local_disable_bh() but has its own set of grace
> > periods, independent of those of rcu_read_lock().
> >=20
> > > Why lockdep is not able to make a correct diagnostic ?
> >=20
> > Here is the situation I am concerned about:
> >=20
> > o	Task 0 does rcu_read_lock(), then p=3Drcu_dereference_bh().
> > 	If we make the change you are asking for, rcu_dereference_bh()
> > 	is OK with this.
> >=20
> > o	Task 0 now is preempted before finishing its RCU read-side
> > 	critical section.
> >=20
> > o	Task 1 removes the data element referenced by pointer p,
> > 	then invokes synchronize_rcu_bh().
> >=20
> > o	Task 0 does not block synchronize_rcu_bh(), so the grace
> > 	period completes.
> >=20
> > o	Task 1 frees up the data element referenced by pointer p,
> > 	which might be reallocated as some other type, unmapped,
> > 	or whatever else.
> >=20
> > o	Task 0 resumes, and is sadly disappointed when the data
> > 	element referenced by pointer p has been swept out from
> > 	under it.
> >=20
> > Or am I missing something here?
> >=20
>=20
> Nice thing with RCU is that I learn new things every day ;)
>=20
> Thanks Paul, I'll try to remember all the details ! ;)

;-)

But just to be clear...  All but one use of RCU-bh is in networking,
so if you guys need something different from RCU-bh, let's talk!

And I learn something new about RCU every day as well.  One of today's
lessons is that networking is no longer the only user of RCU-bh.  ;-)

							Thanx, Paul
