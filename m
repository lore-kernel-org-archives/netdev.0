From: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor PROPE
 state
Date: Wed, 18 Mar 2015 19:34:12 +0900
Message-ID: <550954A4.2070900@miraclelinux.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com> <55013BD4.2080605@windriver.com> <5501518D.2070405@miraclelinux.com> <55093C76.3030208@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hideaki.yoshifuji@miraclelinux.com,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: Ulf Samuelsson <ulf.samuelsson@ericsson.com>,
	yzhu1 <Yanjun.Zhu@windriver.com>, brian.haley@hp.com,
	davem@davemloft.net, alexandre.dietsch@windriver.com,
	clinton.slabbert@windriver.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og107.obsmtp.com ([64.18.2.167]:47733 "HELO
	exprod7og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755130AbbCRKeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:34:18 -0400
Received: by mail-pa0-f46.google.com with SMTP id cy3so38457317pad.3
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 03:34:18 -0700 (PDT)
In-Reply-To: <55093C76.3030208@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ulf Samuelsson wrote:
>
> On 03/12/2015 09:42 AM, YOSHIFUJI Hideaki wrote:
>> Hello.
>>
>> yzhu1 wrote:
>>> The state machine is in the attachment.
>>>
>>> Best Regards!
>>> Zhu Yanjun
>>> On 03/12/2015 02:58 PM, Zhu Yanjun wrote:
>>>> V2:
>>>>    set ARP_PROBE_BCAST default N.
>>>>
>>>> V1:
>>>>    Have a problem with an HP router at a certain location, which
>>>>    is configured to only answer to broadcast ARP requests.
>>>>    That cannot be changed.
>>>>
>>>>    The first ARP request the kernel sends out, is a broadcast requ=
est,
>>>>    which is fine, but after the reply, the kernel sends unicast re=
quests,
>>>>    which will not get any replies.
>>>>
>>>>    The ARP entry will after some time enter STALE state,
>>>>    and if nothing is done it will time out, and be removed.
>>>>    This process takes to long, and I have been told that it is
>>>>    difficult to makes changes that will eventually remove it.
>>>>
>>>>    Have tried to change the state from STALE to INCOMPLETE, which =
failed,
>>>>    and then tried to change the state to PROBE which also failed.
>>>>
>>>>    The stack is only sending out unicasts, and never broadcast.
>>>>    Is there any way to get the stack to send out a broadcast ARP
>>>>    without having to wait for the entry to be removed?
>>
>> Neighbour subsystem will send multicast probes after unicast
>> probes in NUD_PROBE state if mcast_solicit is more than
>> ucast_solicit.  Try setting net.ipv4.neigh.*.ucast_solicit to
>> the value less than net.ipv4.neigh.*.mcast_solicit, please?
>> e.g.
>>
>> net.ipv4.neigh.eth0.mcast_solicit =3D 3
>> net.ipv4.neigh.eth0.ucast_solicit =3D 1
>>
>> --yoshfuji
>>
> I dont see how, and I would like to focus on code discussion.
>
> Below is simplified pseudo code of the timer handler
> after you have reached REACHABLE the first time.
>
>      "mcast_solicit" is not used at all.
>
> It is only used when in INCOMPLETE state as far as I can tell.

OK, I found I made this change in 2003:

 From d12fd76789e80ae337408834f45dae7cba23fc55 Mon Sep 17 00:00:00 2001
=46rom: Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>
Date: Sun, 6 Jul 2003 23:32:45 +1000
Subject: [PATCH] [NET] Send only unicast NSs in PROBE state.

---
  net/core/neighbour.c | 4 +++-
  1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c640ad5..001fdb4 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -608,7 +608,9 @@ next_elt:
  static __inline__ int neigh_max_probes(struct neighbour *n)
  {
  	struct neigh_parms *p =3D n->parms;
-	return p->ucast_probes + p->app_probes + p->mcast_probes;
+	return (n->nud_state & NUD_PROBE ?
+		p->ucast_probes :
+		p->ucast_probes + p->app_probes + p->mcast_probes);
  }


As I recall, I was hesitating adding new sysctl knob, but now I am
okay to have knob to enable mcast probes in PROBE state as well.
(By default, it should NOT send multicast probe (expecially for IPv6)
in PROBE state.)

How about these?
- introduce probe_mcast_probes knob, default to 0.
- Change neigh_max_probes() to reflect that.

Then, arp_colisit() and ndict_solicit() should send multicast probes
in PROBE state as well, if probe_mcast_probes is set to positive
value.

Will this work for you?

Regards,

--yoshfuji

>
>
> Best Regards,
> Ulf Samuelsson
>
>
>
>>
>>>>
>>>>    I think the recommended behaviour in IPv6 is to send out 3 unic=
asts
>>>>    and if all fails, to send out broadcasts.
>>>>
>>>> Zhu Yanjun (1):
>>>>    neighbour: Support broadcast ARP in neighbor PROPE state
>>>>
>>>>   include/net/neighbour.h        |  7 ++++++
>>>>   include/uapi/linux/neighbour.h |  6 +++++
>>>>   include/uapi/linux/sysctl.h    |  3 +++
>>>>   kernel/sysctl_binary.c         |  3 +++
>>>>   net/core/neighbour.c           | 44 ++++++++++++++++++++++++++++=
+---
>>>>   net/ipv4/Kconfig               | 57 ++++++++++++++++++++++++++++=
++++++++++++++
>>>>   net/ipv4/arp.c                 |  7 ++++--
>>>>   7 files changed, 121 insertions(+), 6 deletions(-)
>>>>
>>>
>>
>

--=20
=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinux.co=
m>
=E3=83=9F=E3=83=A9=E3=82=AF=E3=83=AB=E3=83=BB=E3=83=AA=E3=83=8A=E3=83=83=
=E3=82=AF=E3=82=B9=E6=A0=AA=E5=BC=8F=E4=BC=9A=E7=A4=BE =E6=8A=80=E8=A1=93=
=E6=9C=AC=E9=83=A8 =E3=82=B5=E3=83=9D=E3=83=BC=E3=83=88=E9=83=A8
