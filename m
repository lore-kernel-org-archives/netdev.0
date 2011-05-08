From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 08 May 2011 23:00:47 +0200
Message-ID: <1304888447.3207.66.camel@edumazet-laptop>
References: <1304793749.3207.26.camel@edumazet-laptop>
	 <1304838742.3207.45.camel@edumazet-laptop>
	 <F57561A93EFF5E88729A8D53@nimrod.local>
	 <7B76F9D75FD26D716624004B@nimrod.local>
	 <20110508125028.GK2641@linux.vnet.ibm.com>
	 <B2891EFD056565BBD4DBCE16@nimrod.local>
	 <20110508134425.GL2641@linux.vnet.ibm.com>
	 <C449131127D58077CB25C9D8@Ximines.local>
	 <20110508144749.GR2641@linux.vnet.ibm.com>
	 <AB9DE9E04289CF29CA79CC67@Ximines.local>
	 <20110508154854.GT2641@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34306 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab1EHVAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 17:00:53 -0400
Received: by wwa36 with SMTP id 36so5129541wwa.1
        for <netdev@vger.kernel.org>; Sun, 08 May 2011 14:00:52 -0700 (PDT)
In-Reply-To: <20110508154854.GT2641@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 08 mai 2011 =C3=A0 08:48 -0700, Paul E. McKenney a =C3=A9cr=
it :
> On Sun, May 08, 2011 at 04:17:42PM +0100, Alex Bligh wrote:
> >=20
> > If 6 jiffies per call to ensure cpus are idle is a fact of life,
> > then the question goes back to why interface removal is waiting
> > for rcu readers to be released synchronously, as opposed to
> > doing the update bits synchronously, then doing the reclaim
> > element (freeing the memory) afterwards using call_rcu.
>=20
> This would speed things up considerably, assuming that there is no
> other reason to block for an RCU grace period.
>=20

Thats not so simple... Things are modular and better be safe than crash=
,
on a very rare event (device dismantles are not the thing we expect to
do very often. Only special needs might need to perform hundred of them
per minute...)

=46or example, in the VLAN dismantle phase (ip link del eth0.103)
we have 3 calls to synchronize_rcu() and one call to rcu_barrier()

[ the 'extra' synchronize_rcu() call comes from unregister_vlan_dev() ]

Maybe with new VLAN model, we could now remove this synchronize_net()
call from vlan code. Jesse what do you think ?
Once vlan_group_set_device(grp, vlan_id, NULL) had been called, why
should we respect one rcu grace period at all, given dev is queued to
unregister_netdevice_queue() [ which has its own couples of
synchronize_net() / rcu_barrier() ]


The real scalability problem of device dismantles comes from the fact
that all these waits are done under RTNL mutex. This is the real killer
because you cannot use your eight cpus, even if you are willing to.

We can probably speed things, but we should consider the following user
actions :

ip link add link eth0 vlan103 type vlan id 103
ip link del vlan103
ip link add link eth1 vlan103 type vlan id 103

The "link del" command should return to user only if the minimum things
had been done, to make sure the following "link add" wont fail
mysteriously.



