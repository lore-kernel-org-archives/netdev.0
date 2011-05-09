From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Scalability of interface creation and deletion
Date: Mon, 9 May 2011 00:11:15 -0700
Message-ID: <20110509071114.GA2608@linux.vnet.ibm.com>
References: <F57561A93EFF5E88729A8D53@nimrod.local>
 <7B76F9D75FD26D716624004B@nimrod.local>
 <20110508125028.GK2641@linux.vnet.ibm.com>
 <B2891EFD056565BBD4DBCE16@nimrod.local>
 <20110508134425.GL2641@linux.vnet.ibm.com>
 <C449131127D58077CB25C9D8@Ximines.local>
 <20110508144749.GR2641@linux.vnet.ibm.com>
 <AB9DE9E04289CF29CA79CC67@Ximines.local>
 <20110508154854.GT2641@linux.vnet.ibm.com>
 <1304888447.3207.66.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:46457 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989Ab1EIHLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 03:11:18 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p496mQ19013184
	for <netdev@vger.kernel.org>; Mon, 9 May 2011 02:48:26 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p497BHB1075392
	for <netdev@vger.kernel.org>; Mon, 9 May 2011 03:11:17 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p497BGGf026653
	for <netdev@vger.kernel.org>; Mon, 9 May 2011 03:11:17 -0400
Content-Disposition: inline
In-Reply-To: <1304888447.3207.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 08, 2011 at 11:00:47PM +0200, Eric Dumazet wrote:
> Le dimanche 08 mai 2011 =E0 08:48 -0700, Paul E. McKenney a =E9crit :
> > On Sun, May 08, 2011 at 04:17:42PM +0100, Alex Bligh wrote:
> > >=20
> > > If 6 jiffies per call to ensure cpus are idle is a fact of life,
> > > then the question goes back to why interface removal is waiting
> > > for rcu readers to be released synchronously, as opposed to
> > > doing the update bits synchronously, then doing the reclaim
> > > element (freeing the memory) afterwards using call_rcu.
> >=20
> > This would speed things up considerably, assuming that there is no
> > other reason to block for an RCU grace period.
>=20
> Thats not so simple... Things are modular and better be safe than cra=
sh,
> on a very rare event (device dismantles are not the thing we expect t=
o
> do very often. Only special needs might need to perform hundred of th=
em
> per minute...)

I was afraid of that, but had to ask...

> For example, in the VLAN dismantle phase (ip link del eth0.103)
> we have 3 calls to synchronize_rcu() and one call to rcu_barrier()
>=20
> [ the 'extra' synchronize_rcu() call comes from unregister_vlan_dev()=
 ]
>=20
> Maybe with new VLAN model, we could now remove this synchronize_net()
> call from vlan code. Jesse what do you think ?
> Once vlan_group_set_device(grp, vlan_id, NULL) had been called, why
> should we respect one rcu grace period at all, given dev is queued to
> unregister_netdevice_queue() [ which has its own couples of
> synchronize_net() / rcu_barrier() ]
>=20
>=20
> The real scalability problem of device dismantles comes from the fact
> that all these waits are done under RTNL mutex. This is the real kill=
er
> because you cannot use your eight cpus, even if you are willing to.
>=20
> We can probably speed things, but we should consider the following us=
er
> actions :
>=20
> ip link add link eth0 vlan103 type vlan id 103
> ip link del vlan103
> ip link add link eth1 vlan103 type vlan id 103
>=20
> The "link del" command should return to user only if the minimum thin=
gs
> had been done, to make sure the following "link add" wont fail
> mysteriously.

Hmmm...  One approach would be to use synchronize_rcu_expedited(), thou=
gh
that is a bit of a big hammer.

							Thanx, Paul
