From: Ulf samuelsson <netdev@emagii.com>
Subject: Re: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor PROPE state
Date: Thu, 12 Mar 2015 10:45:09 +0100
Message-ID: <CA716BBF-6431-44FC-ADA1-2F87402001F5@emagii.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com> <55013BD4.2080605@windriver.com> <5501518D.2070405@miraclelinux.com> <B35CF589-BE57-4F34-9CC2-A657F3DCF264@emagii.com> <55015C3E.9060009@miraclelinux.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yzhu1 <Yanjun.Zhu@windriver.com>,
	"brian.haley@hp.com" <brian.haley@hp.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"alexandre.dietsch@windriver.com" <alexandre.dietsch@windriver.com>,
	"clinton.slabbert@windriver.com" <clinton.slabbert@windriver.com>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ulf.samuelsson@ericsson.com" <ulf.samuelsson@ericsson.com>,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: =?utf-8?Q?YOSHIFUJI_Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out21.han.skanova.net ([195.67.226.208]:45622 "EHLO
	smtp-out21.han.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751467AbbCLJps convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 05:45:48 -0400
In-Reply-To: <55015C3E.9060009@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you want to send 3 unicasts followed by 3 broadcast,
you have to set mcast_solicit to 6.
This means you will send 6 broadcasts in incomplete state.

I think the following configuration is wanted:

Incomplete state: send 3 broadcast
Probe state: send 3 unicast, followed by 3 broadcast then goto STALE OR
                     Send 3 unicast, then go to STALE

Best Regards
Ulf Samuelsson
ulf@emagii.com
+46  (722) 427 437


> 12 mar 2015 kl. 10:28 skrev YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E  <hideaki.yoshifuji@miraclelinux.com>:
>=20
> Hi,
>=20
> Ulf samuelsson wrote:
>> That also means that you increase the number of broadcasts in incomp=
lete state.
>> Is that really desirable?
>=20
> In NUD_INCOMPLETE state, neighbour subsystem *skips* sending unicast =
probes
> and send multicast probes mcast_solicit times. If you do not increase
> the number of mcast_solicit, the number of multicast probes in
> NUD_INCOMPLETE will not increased.
>=20
> --yoshfuji
>=20
>>=20
>> Best Regards
>> Ulf Samuelsson
>> ulf@emagii.com
>> +46  (722) 427 437
>>=20
>>=20
>>> 12 mar 2015 kl. 09:42 skrev YOSHIFUJI Hideaki <hideaki.yoshifuji@mi=
raclelinux.com>:
>>>=20
>>> Hello.
>>>=20
>>> yzhu1 wrote:
>>>> The state machine is in the attachment.
>>>>=20
>>>> Best Regards!
>>>> Zhu Yanjun
>>>>> On 03/12/2015 02:58 PM, Zhu Yanjun wrote:
>>>>> V2:
>>>>>   set ARP_PROBE_BCAST default N.
>>>>>=20
>>>>> V1:
>>>>>   Have a problem with an HP router at a certain location, which
>>>>>   is configured to only answer to broadcast ARP requests.
>>>>>   That cannot be changed.
>>>>>=20
>>>>>   The first ARP request the kernel sends out, is a broadcast requ=
est,
>>>>>   which is fine, but after the reply, the kernel sends unicast re=
quests,
>>>>>   which will not get any replies.
>>>>>=20
>>>>>   The ARP entry will after some time enter STALE state,
>>>>>   and if nothing is done it will time out, and be removed.
>>>>>   This process takes to long, and I have been told that it is
>>>>>   difficult to makes changes that will eventually remove it.
>>>>>=20
>>>>>   Have tried to change the state from STALE to INCOMPLETE, which =
failed,
>>>>>   and then tried to change the state to PROBE which also failed.
>>>>>=20
>>>>>   The stack is only sending out unicasts, and never broadcast.
>>>>>   Is there any way to get the stack to send out a broadcast ARP
>>>>>   without having to wait for the entry to be removed?
>>>=20
>>> Neighbour subsystem will send multicast probes after unicast
>>> probes in NUD_PROBE state if mcast_solicit is more than
>>> ucast_solicit.  Try setting net.ipv4.neigh.*.ucast_solicit to
>>> the value less than net.ipv4.neigh.*.mcast_solicit, please?
>>> e.g.
>>>=20
>>> net.ipv4.neigh.eth0.mcast_solicit =3D 3
>>> net.ipv4.neigh.eth0.ucast_solicit =3D 1
>>>=20
>>> --yoshfuji
>>>=20
>>>=20
>>>>>=20
>>>>>   I think the recommended behaviour in IPv6 is to send out 3 unic=
asts
>>>>>   and if all fails, to send out broadcasts.
>>>>>=20
>>>>> Zhu Yanjun (1):
>>>>>   neighbour: Support broadcast ARP in neighbor PROPE state
>>>>>=20
>>>>>  include/net/neighbour.h        |  7 ++++++
>>>>>  include/uapi/linux/neighbour.h |  6 +++++
>>>>>  include/uapi/linux/sysctl.h    |  3 +++
>>>>>  kernel/sysctl_binary.c         |  3 +++
>>>>>  net/core/neighbour.c           | 44 ++++++++++++++++++++++++++++=
+---
>>>>>  net/ipv4/Kconfig               | 57 ++++++++++++++++++++++++++++=
++++++++++++++
>>>>>  net/ipv4/arp.c                 |  7 ++++--
>>>>>  7 files changed, 121 insertions(+), 6 deletions(-)
>>>=20
>>> --
>>> Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
>>> Technical Division, MIRACLE LINUX CORPORATION
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> --=20
> =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinux.=
com>
> =E3=83=9F=E3=83=A9=E3=82=AF=E3=83=AB=E3=83=BB=E3=83=AA=E3=83=8A=E3=83=
=83=E3=82=AF=E3=82=B9=E6=A0=AA=E5=BC=8F=E4=BC=9A=E7=A4=BE =E6=8A=80=E8=A1=
=93=E6=9C=AC=E9=83=A8 =E3=82=B5=E3=83=9D=E3=83=BC=E3=83=88=E9=83=A8
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
