From: shmulik.hen@intel.com
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 15:32:02 +0200 (IST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0303271406230.7106-100000@jrslxjul4.npdj.intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A01085638@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Dan Eble <dane@aiinet.com>,
	bond-devel <bonding-devel@lists.sourceforge.net>,
	bond-announce <bonding-announce@lists.sourceforge.net>,
	linux-netdev <netdev@oss.sgi.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-net <linux-net@vger.kernel.org>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A01085638@hasmsx403.iil.intel.com>
List-Id: netdev.vger.kernel.org

=46urther more, holding a lock_irq doesn't mean bottom halves are disab=
led
too, it just means interrupts are disabled and no *new* softirq can be
queued. Consider the following situation:

In bond_release() we hold write_lock_irqsave(&bond->lock, flags) and th=
en
do all the releasing stuff. If, for example, we need to call
dev_mc_upload() for the released slave, the following will happen

        spin_lock_bh(&dev->xmit_lock);
        __dev_mc_upload(dev);
        spin_unlock_bh(&dev->xmit_lock);

spin_unlock_bh() calls local_bh_enable() which checks local_bh_count. I=
f
local_bh_count reaches zero (and it does), it directly executes
do_softirq(). The check for in_interrupt() in do_softirq() is false and
the softirqs that were queued begin to run and process the Tx and Rx
backlogs. dev_queue_xmit() is called on the bond device which calls, le=
ts
say, bond_xmit_xor(). The first thing bond_xmit_xor() does is try to gr=
ab
read_lock_irqsave(&bond->lock, flags). Since this lock is already held =
by
bond_release(), and we're on the same cpu without any context switch,
we've got ourselves a deadlock. This actually happened to us and it too=
k us
a while to figure the system halt, but we've got the kdb trace to prove
it.

Specifically for bonding, as stated by Dan below, it is indeed not
necessary to hold a lock_irq in every entry point in the driver. From o=
ur
experience in previous projects, we discovered that it is sufficient to
just grab a read_lock when accessing the slaves list in any softirq lev=
el
function (receive, transmit and timer), and hold a write_lock_bh() only
when changing the slaves list in ioctl calls like bond_enslave(),
bond_release(), bond_release_all() which all run at user context.

We have created a version that uses the above scheme that is being test=
ed
by our QA group these days. Such a major change in the locking scheme
requires allot of testing to try and detect potential hidden bugs and
corner cases. We expect this will also increase the total throughput,
since interrupts won't be blocked each time a packet is being transmitt=
ed
or the miimon timer pops. We believe we will be able to post the patch
(+results) next week.


On Tue, 25 Mar 2003, Dan Eble wrote:
>=20
> (kernel is ppc 2.4.21-pre4)
>=20
> In bond_enslave() [drivers/net/bonding.c]:
>=20
> =A0=A0=A0=A0=A0=A0=A0 write_lock_irqsave(&bond->lock, flags);
> =A0=A0=A0=A0=A0=A0=A0 ...
> =A0=A0=A0=A0=A0=A0=A0 err =3D netdev_set_master(slave_dev, master_dev=
);
> =A0=A0=A0=A0=A0=A0=A0 ...
> =A0=A0=A0=A0=A0=A0=A0 write_unlock_irqrestore(&bond->lock, flags);
>=20
> In netdev_set_master() [net/core/dev.c]:
>=20
> =A0=A0=A0=A0=A0=A0=A0 rtmsg_ifinfo(RTM_NEWLINK, slave, IFF_SLAVE);
>=20
> In rtmsg_ifinfo() [net/core/rtnetlink.c]:
>=20
> =A0=A0=A0=A0=A0=A0=A0 skb =3D alloc_skb(size, GFP_KERNEL);
> =A0=A0=A0=A0=A0=A0=A0 ...
> =A0=A0=A0=A0=A0=A0=A0 netlink_broadcast(rtnl, skb, 0, RTMGRP_LINK, GF=
P_KERNEL);
>=20
> Doesn't this admit the possibility of sleeping with interrupts disabl=
ed?=A0
> I found it because I'm working on a driver that uses a master-slave
> relationship like the bonding driver, and decided I didn't really nee=
d to
> disable interrupts, so I tried using write_lock_bh()=A0 instead.=A0 T=
he
> result
> was an "alloc_skb called nonatomically from interrupt" message becaus=
e
> write_lock_bh() increments the local BH count (which seems reasonable=
).
>=20
> A bigger question: Why are the IRQ check and the BH check inconsisten=
t?
> That is, local_bh_count() says "yes" if you are currently running in =
BH
> context OR have disabled BHs; however, local_irq_count() says "yes" i=
f
> you
> are currently running in interrupt context, but it says nothing (as f=
ar
> as
> I have seen) about whether IRQs are enabled or disabled.=A0 Is this (=
a) the
> Right Way, (b) something that's more trouble to fix than to be burned=
-by
> once and then avoid for the rest of your life, or (c) totally horked?
>=20
> --
> Dan Eble <dane@aiinet.com>=A0 _____=A0 .
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 |=A0 _=A0 |/|
> Applied Innovation Inc.=A0=A0=A0 | |_| | |
> http://www.aiinet.com/=A0=A0=A0=A0 |__/|_|_|
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at=A0 http://vger.kernel.org/majordomo-info.html
>=20
>=20
>=20

--=20
| Shmulik Hen                                    |
| Israel Design Center (Jerusalem)               |
| LAN Access Division                            |
| Intel Communications Group, Intel corp.        |
