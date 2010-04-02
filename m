From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 10/12] l2tp: Add L2TP ethernet pseudowire support
Date: Fri, 2 Apr 2010 09:21:07 -0700
Message-ID: <20100402162107.GF2549@linux.vnet.ibm.com>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>
 <20100330161819.9628.10853.stgit@bert.katalix.com>
 <20100330093252.60d9cbee@nehalam>
 <4BB31761.2090906@katalix.com>
 <20100331173836.GG2461@linux.vnet.ibm.com>
 <20100402152402.GA6017@linux.vnet.ibm.com>
 <1270223931.11099.7.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Chapman <jchapman@katalix.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:45283 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186Ab0DBQVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 12:21:14 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o32GIV8L017510
	for <netdev@vger.kernel.org>; Fri, 2 Apr 2010 12:18:31 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o32GL8AQ114576
	for <netdev@vger.kernel.org>; Fri, 2 Apr 2010 12:21:08 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o32GL8rh029179
	for <netdev@vger.kernel.org>; Fri, 2 Apr 2010 12:21:08 -0400
Content-Disposition: inline
In-Reply-To: <1270223931.11099.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 02, 2010 at 05:58:51PM +0200, Eric Dumazet wrote:
> Le vendredi 02 avril 2010 =E0 08:24 -0700, Paul E. McKenney a =E9crit=
 :
> > On Wed, Mar 31, 2010 at 10:38:36AM -0700, Paul E. McKenney wrote:
>=20
> > > The list_is_last() is RCU-safe already, since the ->next pointer =
is
> > > only compared, never dereferenced.  I suggest adding a comment to=
 its
> > > header stating that it is RCU-safe.
> > >=20
> > > Feel free to create a list_for_each_entry_safe_rcu(), and I will =
be
> > > happy to review it.
> >=20
> > Right.  When using RCU, list_for_each_entry_safe_rcu() is not neede=
d,
> > because destruction of the element you removed doesn't happen until=
 the
> > end of a subsequent grace period.  By which time you will be done w=
ith
> > your RCU read-side critical section.
> >=20
> > So you can just use list_for_each_entry_rcu(), you do not need a ne=
w
> > list_for_each_entry_safe_rcu().
> >=20
> > But you did have me going for a bit!!!  ;-)
>=20
> Just wondering Paul if you need to rest :)

In this case, I most certainly needed to have engaged my brain more
fully before hitting "send".  :-/

> list_for_each_entry_safe_rcu() is not needed not because of various (=
and
> very intersting) reasons you gave !!!
>=20
> But because list_for_each_entry_safe() is OK, since if we are in a
> destroy phase, we are a writer, and can use regular list primitive.
>=20
> Remember _rcu() versions of list iterators are for readers, and reade=
rs
> are NOT supposed to delete an item from the list !

Yes, RCU readers had better have acquired the update-side lock before
modifying the list.  And then there would be some debate as to whether
they were still readers.  For example, while reading one list under RCU
protection, you might be modifying a subordinate list while holding the
corresponding lock.

And in the networking code, you would also need to convince the usual
suspects, including Eric, that upgrading to writer in the middle of an
RCU read-side critical section was the right thing to be doing in the
first place!

							Thanx, Paul
