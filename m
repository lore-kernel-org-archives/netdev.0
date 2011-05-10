From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: Fw: oops during unregister_netdevice interface enslaved to
	bond - regression
Date: Tue, 10 May 2011 15:14:38 +0200
Message-ID: <20110510131438.GA41522@tuxmaker.boeblingen.de.ibm.com>
References: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com> <1305017672.2614.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, ELELUECK@de.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:43262 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036Ab1EJNOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 09:14:40 -0400
Received: from d06nrmr1507.portsmouth.uk.ibm.com (d06nrmr1507.portsmouth.uk.ibm.com [9.149.38.233])
	by mtagate3.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p4ADEdPx005055
	for <netdev@vger.kernel.org>; Tue, 10 May 2011 13:14:39 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4ADEd9F2363630
	for <netdev@vger.kernel.org>; Tue, 10 May 2011 14:14:39 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4ADEcDA030374
	for <netdev@vger.kernel.org>; Tue, 10 May 2011 07:14:38 -0600
Content-Disposition: inline
In-Reply-To: <1305017672.2614.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2011 at 10:54:32AM +0200, Eric Dumazet wrote:
> Le mardi 10 mai 2011 =E0 10:17 +0200, Einar EL Lueck a =E9crit :
> > Hi Dave,
> >=20
> > Einar EL Lueck/Germany/IBM wrote on 04/29/2011 04:45:45 PM:
> >=20
> > > From:
> > >
> > > Einar EL Lueck/Germany/IBM
> > >
> > > To:
> > >
> > > opurdila@ixiacom.com, netdev@vger.kernel.org, linux-
> > > s390@vger.kernel.org, davem@davemloft.net
> > >
> > > Cc:
> > >
> > > Frank Blaschka/Germany/IBM@IBMDE
> > >
> > > Date:
> > >
> > > 04/29/2011 04:45 PM
> > >
> > > Subject:
> > >
> > > Re: oops during unregister_netdevice interface enslaved to bond -
> > regression
> > >
> > > Hi Octavian,
> > >
> > > On 04/15/2011 10:53 AM, Frank Blaschka wrote:
> > > > Hi Octavian,
> > > >
> > > > your commit 443457242beb6716b43db4d62fe148eab5515505 introduced
> > > this regression.
> > > > I have reviewed the net device unregister code but did not
> > > understand it very well.
> > > > I have seen the problem only in combination with bonding. Can y=
ou
> > > give me some help
> > > > how to go on with this problem. I can reproduced it very easy o=
n
> > asingle CPU
> > > > machine.
> > > >
> > >
> > > In this case rollback_registered_many iterates over the list of d=
evs
> > > that initially has just one device in it. In a loop it calls
> > > call_netdevice_notifiers(NETDEV_UNREGISTER, dev) which triggers t=
he
> > > bonding driver to call dev_close_many for the same device. That c=
all
> > > to dev_close_many leads to the addition of the same device to the
> > > list over which rollback_registered_many is iterating. Consequent=
ly,
> > > netdev_unregister_kobject(dev) is called twice for the same devic=
e.
> > > Frank captured the result in his mail.
> > >
> >=20
> > Calls to the *_many functions introduced by Octavian may never inte=
rleave
> > because
> > the traversed lists modify each other. This was the root cause for =
the
> > symptom that Frank discovered. Octavian is not a valid mail recipie=
nt
> > anymore and did not react from any new mail address. I suggest to r=
evert
> > the commit.
> >=20
>=20
> Hello Einar
>=20
> I am currently working on this stuff [adding even more batching and
> probably bugs as well ], so instead of revert I'll try to find a way =
to
> fix this.
>
great Thx!
=20
> If you already have a script to reproduce the bug on virtual devices =
on
> x86 (not on s390 machines I dont have ;) ), I'll appreciate having a
> copy of it.a

I just checked todays net-next tree, problem is still there.
I don't have an x86 box, but I was able to reproduce the problem
with the dummy device (on s/390)

# modprobe bonding
# modprobe dummy
# ifconfig bond0 up
# ifenslave bond0 dummy0
# rmmod dummy

oops looks very much the same as unsing a real device. Hope this helps =
=2E..
>=20
> Thanks for the reminder.
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
