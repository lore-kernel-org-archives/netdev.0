From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: introduce primary_lazy option
Date: Tue, 25 Aug 2009 11:41:21 -0700
Message-ID: <16215.1251225681@death.nxdomain.ibm.com>
References: <20090814105938.GE3457@psychotron.englab.brq.redhat.com> <4A859057.3020606@free.fr> <20090817114938.GA3416@psychotron.englab.brq.redhat.com> <4A89C3B1.3070509@free.fr> <20090818124550.GB3539@psychotron.englab.brq.redhat.com> <4A8D4427.8080004@free.fr> <20090824111619.GC4018@psychotron.englab.brq.redhat.com> <4A92ACA6.7070600@free.fr> <20090824152002.GD4018@psychotron.englab.brq.redhat.com> <697.1251135317@death.nxdomain.ibm.com> <20090825064351.GA3426@psychotron.englab.brq.redhat.com> <4A941FD9.6050304@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, Jiri Pirko <jpirko@redhat.com>
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FNicolas=5Fde=5FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:58688 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755804AbZHYSlY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 14:41:24 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7PIe02U019982
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 14:40:00 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7PIfQLw256504
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 14:41:26 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7PIfPBV005865
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 14:41:26 -0400
In-reply-to: <4A941FD9.6050304@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:

>Jiri Pirko wrote:
>> Mon, Aug 24, 2009 at 07:35:17PM CEST, fubar@us.ibm.com wrote:
>>> 	I'm still unclear as to why it's better to add another special
>>> case option to bonding instead of changing this in user space, othe=
r
>>> than it'd be a change to user space (initscripts / sysconfig).
>>>
>>> 	The way I see it, this patch is adding a mechanism that says,
>>> effectively, "make slave X the active slave, but do it only once."
>>> There is already a way to do that in bonding (sysfs, as above, or
>>> ifenslave -c); I am reluctant to add another without good reason.
>>=20
>> Hello Jay.
>>=20
>> As I already replied you once it's not only about selecting a slave =
at the
>> start. It's also about following:
>>=20
>> Imagine you have bond with 3 slaves:
>> eth0            eth1            eth2
>> UP(curr)        UP              UP
>> DOWN            UP(curr)        UP
>> UP              UP(curr)        UP
>> UP              DOWN            UP(curr)
>>=20
>> eth2 ends up being current active but we prefer eth0 (as primary int=
erface).
>> This is not desirable and is solved by primary_lazy option.
>>=20
>> Jirka
>>=20
>>> 	I'm not necessarily against the "weight" business in general.
>>> For the purposes of this discussion, however, it's a big complex
>>> solution to a pretty simple problem, and the "weight" system still =
has
>>> to have special sauce added it to to handle this special case.
>>>
>>> 	Last, presuming for the moment that this goes forward as an
>>> option to bonding, I think this should be named something along the
>>> lines of "make_active" (or perhaps "make_active_once", but that's a=
 bit
>>> long).  The option has the effect of making the specified slave the
>>> active slave one time, then the option setting is cleared.
>
>Hi Jay,
>
> From what I understand from Jirka's needs, the exact expected behavio=
rs are :
>
>1/ If a slave is active, keep it active, even if the primary comes bac=
k up.
>2/ If the current slave just failed, choose the new active slave, givi=
ng=20
>priority to the master.
>
>Selecting the active slave at startup (by using ifenslave -c or writin=
g into=20
>/sys/class/net/bond0/bonding/active_slave) would solve 1, but not 2.

	Yah, I had missed step 2.  I'd still call it something other
than "lazy," though; "passive" sounds better to me.

>Also, I suggested to change 1 in this way :
>
>1/ If a slave is active, keep it active, even if the primary comes bac=
k up,=20
>*except if the speed of the primary is better than the speed of the ac=
tive slave*.
>
>Thinking about all that, I start feeling that some sort of user space =
system to=20
>select the "best" slave would be better. If we can design a NETLINK in=
terface to=20
>report events (slave up, slave down...) to user space, then any user s=
pace=20
>daemon would be able to tell bonding what to do. Only if no process re=
gister to=20
>receive those events would bonding use the normal slave selection rule=
s.

	This has been discussed more than once in the past, but hasn't
ever really gotten anywhere.  I suspect the main impediment is the lack
of a suitable API.

>Designing such a NETLINK interface would replace my proposed weight op=
tion (at=20
>least for best slave selection in active-backup mode and for best aggr=
egator=20
>selection in 802.3ad mode). It would also solve the problem reported b=
y Jirka=20
>and so replace the proposed primary_lazy option.

	Yes, a lot of the decision making at failover could be moved
into a user space daemon.  The daemon, I think, should be optional; if
the basic selection policies are sufficient, then there's no need for a
trip to user space and back.

>Any way, NETLINK is something that is supposed to come into bonding at=
 some=20
>times, because we know that the sysfs purists hate the sysfs bonding s=
tuff and=20
>that NETLINK is the target to setup networking.

	I'm not a big fan of the sysfs API, either; it seemed like a
good idea at the time.  It's certainly better than ifenslave in terms o=
f
features, but some of it is pretty convoluted, and there are things tha=
t
just can't be done from within sysfs.

	I recall seeing a note from Stephen Hemminger not too long ago
(a month or two ago) that he was working on a netlink API for bonding,
but I don't know how far that ever got.

	One quesiton is, if a netlink API is implemented, whether to
convert ifenslave, or deprecate ifenslave and put the various bonding
functions into ip.

	If a netlink API is on the relatively near horizon (say, within
a few months), then I'm less inclined to put in the "lazy" option, sinc=
e
it would just become baggage carried forward for the next several years
(until the sysfs API could be deprecated and removed).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
