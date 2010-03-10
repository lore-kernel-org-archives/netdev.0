From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 11:39:43 +0100
Message-ID: <1268217583.2880.2.camel@edumazet-laptop>
References: <20100228054012.GA7583@gondor.apana.org.au>
	 <201003092212.59627.arnd@arndb.de>
	 <20100310021410.GD6203@linux.vnet.ibm.com>
	 <201003101041.32518.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:36938 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754664Ab0CJKjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 05:39:47 -0500
Received: by bwz1 with SMTP id 1so4789313bwz.21
        for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 02:39:46 -0800 (PST)
In-Reply-To: <201003101041.32518.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 mars 2010 =C3=A0 10:41 +0100, Arnd Bergmann a =C3=A9crit=
 :
> On Wednesday 10 March 2010 03:14:10 Paul E. McKenney wrote:
> > On Tue, Mar 09, 2010 at 10:12:59PM +0100, Arnd Bergmann wrote:
> >
> > > I've just tried annotating net/ipv4/route.c like this and did not=
 get
> > > very far, because the same pointers are used for rcu and rcu_bh.
> > > Could you check if this is a false positive or an actual finding?
> >=20
> > Hmmm...  I am only seeing a call_rcu_bh() here, so unless I am miss=
ing
> > something, this is a real problem in TREE_PREEMPT_RCU kernels.  The
> > call_rcu_bh() only interacts with the rcu_read_lock_bh() readers, n=
ot
> > the rcu_read_lock() readers.
> >=20
> > One approach is to run freed blocks through both types of grace per=
iods,
> > I suppose.
>=20
> Well, if I introduce different __rcu and __rcu_bh address space annot=
ations,
> sparse would still not like that, because then you can only pass the =
annotated
> pointers into either rcu_dereference or rcu_dereference_bh.
>=20
> What the code seems to be doing here is in some places
>=20
> 	local_bh_disable();
> 	...
> 	rcu_read_lock();
> 	rcu_dereference(rt_hash_table[h].chain);
> 	rcu_read_unlock();
> 	...
> 	local_bh_enable();
>=20
> and in others
>=20
> 	rcu_read_lock_bh();
> 	rcu_dereference_bh(rt_hash_table[h].chain);
> 	rcu_read_unlock_bh();
>=20
> When rt_hash_table[h].chain gets the __rcu_bh annotation, we'd have t=
o
> turn first rcu_dereference into rcu_dereference_bh in order to have a=
 clean
> build with sparse. Would that change be
> a) correct from RCU perspective,
> b) desirable for code inspection, and
> c) lockdep-clean?
>=20

Its really rcu_dereference_bh() that could/should be used:
I see no problem changing


        local_bh_disable();
        ...
        rcu_read_lock();
        rcu_dereference(rt_hash_table[h].chain);
        rcu_read_unlock();
        ...
        local_bh_enable();


to


        local_bh_disable();
        ...
        rcu_read_lock();
        rcu_dereference_bh(rt_hash_table[h].chain);
        rcu_read_unlock();
        ...
        local_bh_enable();


