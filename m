From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH V3] netxen: fix ethtool rx_dropped information in ethtool get_ethtool_stats()
Date: Sun, 20 Jul 2014 10:52:46 +0800
Message-ID: <CABawtvPUW1-svB0-BV8YjP4cZrDLvBoN7YnYaa0sVaVbAe8GLQ@mail.gmail.com>
References: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com>
	<C562D0E12CBDE44E8A0CCAB77060096701283AD344@AVMB1.qlogic.org>
	<049BCC6F-0A2E-421A-9873-0B7ED6FFB3AC@gmail.com>
	<20140719101946.GA4319@electric-eye.fr.zoreil.com>
	<CABawtvP4+B_smOyi-=vt56KuUthzHF9L059PXP4ekXA7KPk_Dw@mail.gmail.com>
	<20140719162816.GB7590@electric-eye.fr.zoreil.com>
	<48774298-8C91-42A9-A5F2-4EAB789F356B@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Ethan Zhao <ethan.zhao@oracle.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:62138 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbaGTCwr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2014 22:52:47 -0400
In-Reply-To: <48774298-8C91-42A9-A5F2-4EAB789F356B@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,
   Regarding the r8169 chip, there is no other data fields exported to
user via ethtool
except for those dumped from hardware statistic counters in 8169 driver=
=2E

   But for Intel 82598 NIC and its driver ixgbe, it exports not only
those fields dumped from hardware statistic counters, like:

     {"rx_missed_errors", IXGB_NETDEV_STAT(stats.rx_missed_errors)},

    also some info like following, these stats are collected from net c=
ore.

    {"rx_packets", IXGB_NETDEV_STAT(stats.rx_packets)},
    {"tx_packets", IXGB_NETDEV_STAT(stats.tx_packets)},
    {"rx_bytes", IXGB_NETDEV_STAT(stats.rx_bytes)},
    {"tx_bytes", IXGB_NETDEV_STAT(stats.tx_bytes)},
    {"rx_errors", IXGB_NETDEV_STAT(stats.rx_errors)},
    {"tx_errors", IXGB_NETDEV_STAT(stats.tx_errors)},
    {"rx_dropped", IXGB_NETDEV_STAT(stats.rx_dropped)},
    {"tx_dropped", IXGB_NETDEV_STAT(stats.tx_dropped)},


   As to netxen and its hardware.  does it have hardware statistic
counter ?  I don't care, As I know follow fields exported via ethtool
should be collected from software(net core / driver ):

    {"xmit_called", NETXEN_NIC_STAT(stats.xmitcalled)},
{"xmit_finished", NETXEN_NIC_STAT(stats.xmitfinished)},
{"rx_dropped", NETXEN_NIC_STAT(stats.rxdropped)},
{"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
{"csummed", NETXEN_NIC_STAT(stats.csummed)},

  So fix the rx_dropped field with my patch is the right way. the
patch is not intended to dump hardware statistic counters.


Thanks,
Ethan




On Sun, Jul 20, 2014 at 8:43 AM, Ethan Zhao <ethan.kernel@gmail.com> wr=
ote:
>
>
>> =E5=9C=A8 2014=E5=B9=B47=E6=9C=8820=E6=97=A5=EF=BC=8C=E4=B8=8A=E5=8D=
=8812:28=EF=BC=8CFrancois Romieu <romieu@fr.zoreil.com> =E5=86=99=E9=81=
=93=EF=BC=9A
>>
>> Ethan Zhao <ethan.kernel@gmail.com> :
>>>> On Sat, Jul 19, 2014 at 6:19 PM, Francois Romieu <romieu@fr.zoreil=
=2Ecom> wrote:
>>>> Ethan Zhao <ethan.kernel@gmail.com> :
>> [...]
>>>> I'd rather see ethtool stats provides one of those:
>>>> 1. hardware stats only
>>>  Sounds very clear, is it done clear, if so we need other tools ?
>>> Then why net core increase dev->dropped like
>>>
>>> atomic_long_inc(&skb->dev->rx_dropped);
>>>
>>> and mess some of the info to dev. just let ifconfig report it witho=
ut detail ?
>>
>> (side note: ifconfig is a bit 90ish)
>>
>> Regarding the "without details" part, I don't expect ifconfig to tel=
l users
>> that packets are dropped at net/core/dev.c:3279 because of empty sof=
tnet_data
>> queue in enqueue_to_backlog. More to the point below.
>>
>> [...]
>>>> 2. needs works. 1. hurts any requirement where it would priviously=
 had
>>>> been so easy to add a few lines of code in the driver and push the=
 mess
>>>> straight from kernel to the end user application.
>>>
>>>  Maybe some guys think that is enough to mess them together while n=
ot
>>> identify the information from net core or driver. that is better th=
an
>>> lose info /no info.
>>
>> Probably.
>>
>>> My case is user could be confused when run 'ifconfig' and 'ethtool'
>>> to this netxen device. ifconfig reports packets dropped. but ethtoo=
l
>>> says zero. does that mean it is not issue of driver forever ?
>>
>> s/driver/hardware/
>>
>> Hardware correctly delivers packets if ethtool says zero [*]
>>
>> "correctly" must be understood in the context of said hardware abili=
ties.
>>
>> [*] Of course we don't live in a world of unicorns and it's almost
>>    unavoidable to check drivers's code to figure which stats are _re=
ally_
>>    hardware only in ethtool output.
>>
>> A part of ethtool if close to bare metal abilities - including proto=
col
>> offloading related ones - whereas ifconfig provides a software orien=
ted
>> vision of layer 2 operations.
>>
>> <digressio>
>> People at QLogic have not included *any* hardware counter in their
>> netxen ethtool stats code. Nada, keud. It's a bit deceptive for a gi=
gabit
>> ethernet card and http://www.qlogic.com/Search/Pages/Search.aspx?k=3D=
NX2031
>> gives no hint.
>> </digressio>
>>
>> I won't claim it's intuitive. However:
>>
>> $ LANG=3DC man ifconfig
>> [...]
>> NOTE
>>       This  program  is obsolete!  For replacement check ip addr and=
 ip link.
>>       For statistics use ip -s link.
>>
>> $ LANG=3DC man ip
>> [...]
>>     -f, -family <FAMILY>
>>              Specifies the protocol family to use. The protocol fami=
ly iden-
>>              tifier can be one of inet, inet6, bridge, ipx, dnet or =
link.  If
>>              this option is not present, the protocol family is gues=
sed from
>>              other arguments.  If the rest of the command line does =
not give
>>              enough information to guess the family, ip falls back t=
o the
>>              default one, usually inet or any.  link is a special fa=
mily
>>                                                 ^^^^^^^^^^^^^^^^^^^^=
^^^^
>>              identifier meaning that no networking protocol is invol=
ved.
>>              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^=
^^^
>>
>> (huh, "special"...)
>>
>> $ LANG=3DC man ethtool
>> [...]
>>      -S --statistics
>>              Queries the specified network device for NIC- and drive=
r-specif-
>>              ic statistics.
>>
>> Some code stands between drivers and the upper part of the topmost
>> no-networking-procol layer, whence the differing stats: they are not
>> the same thing. Users can understand it.
>>
>>> who could tell where the packets are dropped, and for what ?
>>
>> One can't always answer beyond some coarse implementation level. The=
re is
>> no such thing as a kernel MIB for the net core internal details.
>>
>> Would you disagree that some of those - rx_dropped locations for ins=
tance -
>> are better kept in the scope of debug and trace utilities ?
>>
> Of course I disagree it is the scope of debug and trace utilities. Th=
at is not fair or the original purpose the dropped info was collected i=
nto dev - >stat, it is dev specific
>
>
>>> So I would like the name of the data fields that ethtool output is =
be
>>> better defined. Instead of saying is not covered by ethtool.
>>
>> I respectfully disagree.
>>
>> ethtool and ip are two different tools.
>
> you leave us without a tool to track the net core part. Would you lik=
e to hack the kernel code and rebuild just for peek the dropping packet=
s ?
>>
>> Regarding netxen driver, I do not want more ip / ifconfig stats in
>> ethtool code. It's quite the opposite: netxen ethtool code has no
>> business duplicating those and it should instead focus on real hardw=
are
> You are ignoring the implementation fact of many drivers' ethtool par=
t.  You should persuade the authors of those drivers to delete those un=
related part in their ethtool code,
> More radically, and maybe you should write patches to fix them to kee=
p their focus. That is to prove you have principle and always fight for=
 it.
>
>
>
> Thanks,
> Ethan
>> stats.
>>
>> --
>> Ueimor
