From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH V3] netxen: fix ethtool rx_dropped information in ethtool get_ethtool_stats()
Date: Sun, 20 Jul 2014 08:43:13 +0800
Message-ID: <48774298-8C91-42A9-A5F2-4EAB789F356B@gmail.com>
References: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com> <C562D0E12CBDE44E8A0CCAB77060096701283AD344@AVMB1.qlogic.org> <049BCC6F-0A2E-421A-9873-0B7ED6FFB3AC@gmail.com> <20140719101946.GA4319@electric-eye.fr.zoreil.com> <CABawtvP4+B_smOyi-=vt56KuUthzHF9L059PXP4ekXA7KPk_Dw@mail.gmail.com> <20140719162816.GB7590@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Ethan Zhao <ethan.zhao@oracle.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:55040 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbaGTAnV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2014 20:43:21 -0400
In-Reply-To: <20140719162816.GB7590@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> =D4=DA 2014=C4=EA7=D4=C220=C8=D5=A3=AC=C9=CF=CE=E712:28=A3=ACFrancois=
 Romieu <romieu@fr.zoreil.com> =D0=B4=B5=C0=A3=BA
>=20
> Ethan Zhao <ethan.kernel@gmail.com> :
>>> On Sat, Jul 19, 2014 at 6:19 PM, Francois Romieu <romieu@fr.zoreil.=
com> wrote:
>>> Ethan Zhao <ethan.kernel@gmail.com> :
> [...]
>>> I'd rather see ethtool stats provides one of those:
>>> 1. hardware stats only
>>  Sounds very clear, is it done clear, if so we need other tools ?
>> Then why net core increase dev->dropped like
>>=20
>> atomic_long_inc(&skb->dev->rx_dropped);
>>=20
>> and mess some of the info to dev. just let ifconfig report it withou=
t detail ?
>=20
> (side note: ifconfig is a bit 90ish)
>=20
> Regarding the "without details" part, I don't expect ifconfig to tell=
 users
> that packets are dropped at net/core/dev.c:3279 because of empty soft=
net_data
> queue in enqueue_to_backlog. More to the point below.
>=20
> [...]
>>> 2. needs works. 1. hurts any requirement where it would priviously =
had
>>> been so easy to add a few lines of code in the driver and push the =
mess
>>> straight from kernel to the end user application.
>>=20
>>  Maybe some guys think that is enough to mess them together while no=
t
>> identify the information from net core or driver. that is better tha=
n
>> lose info /no info.
>=20
> Probably.
>=20
>> My case is user could be confused when run 'ifconfig' and 'ethtool'
>> to this netxen device. ifconfig reports packets dropped. but ethtool
>> says zero. does that mean it is not issue of driver forever ?
>=20
> s/driver/hardware/
>=20
> Hardware correctly delivers packets if ethtool says zero [*]
>=20
> "correctly" must be understood in the context of said hardware abilit=
ies.
>=20
> [*] Of course we don't live in a world of unicorns and it's almost
>    unavoidable to check drivers's code to figure which stats are _rea=
lly_
>    hardware only in ethtool output.
>=20
> A part of ethtool if close to bare metal abilities - including protoc=
ol
> offloading related ones - whereas ifconfig provides a software orient=
ed
> vision of layer 2 operations.
>=20
> <digressio>
> People at QLogic have not included *any* hardware counter in their
> netxen ethtool stats code. Nada, keud. It's a bit deceptive for a gig=
abit
> ethernet card and http://www.qlogic.com/Search/Pages/Search.aspx?k=3D=
NX2031
> gives no hint.
> </digressio>
>=20
> I won't claim it's intuitive. However:
>=20
> $ LANG=3DC man ifconfig
> [...]
> NOTE
>       This  program  is obsolete!  For replacement check ip addr and =
ip link.
>       For statistics use ip -s link.
>=20
> $ LANG=3DC man ip
> [...]
>     -f, -family <FAMILY>
>              Specifies the protocol family to use. The protocol famil=
y iden-
>              tifier can be one of inet, inet6, bridge, ipx, dnet or l=
ink.  If
>              this option is not present, the protocol family is guess=
ed from
>              other arguments.  If the rest of the command line does n=
ot give
>              enough information to guess the family, ip falls back to=
 the
>              default one, usually inet or any.  link is a special fam=
ily
>                                                 ^^^^^^^^^^^^^^^^^^^^^=
^^^
>              identifier meaning that no networking protocol is involv=
ed.
>              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^=
^^
>=20
> (huh, "special"...)
>=20
> $ LANG=3DC man ethtool
> [...]
>      -S --statistics
>              Queries the specified network device for NIC- and driver=
-specif-
>              ic statistics.
>=20
> Some code stands between drivers and the upper part of the topmost
> no-networking-procol layer, whence the differing stats: they are not
> the same thing. Users can understand it.
>=20
>> who could tell where the packets are dropped, and for what ?
>=20
> One can't always answer beyond some coarse implementation level. Ther=
e is
> no such thing as a kernel MIB for the net core internal details.
>=20
> Would you disagree that some of those - rx_dropped locations for inst=
ance -
> are better kept in the scope of debug and trace utilities ?
>=20
Of course I disagree it is the scope of debug and trace utilities. That=
 is not fair or the original purpose the dropped info was collected int=
o dev - >stat, it is dev specific


>> So I would like the name of the data fields that ethtool output is b=
e
>> better defined. Instead of saying is not covered by ethtool.
>=20
> I respectfully disagree.
>=20
> ethtool and ip are two different tools.

you leave us without a tool to track the net core part. Would you like =
to hack the kernel code and rebuild just for peek the dropping packets =
?
>=20
> Regarding netxen driver, I do not want more ip / ifconfig stats in
> ethtool code. It's quite the opposite: netxen ethtool code has no
> business duplicating those and it should instead focus on real hardwa=
re
You are ignoring the implementation fact of many drivers' ethtool part.=
  You should persuade the authors of those drivers to delete those unre=
lated part in their ethtool code,
More radically, and maybe you should write patches to fix them to keep =
their focus. That is to prove you have principle and always fight for i=
t.



Thanks,
Ethan
> stats.=20
>=20
> --=20
> Ueimor
