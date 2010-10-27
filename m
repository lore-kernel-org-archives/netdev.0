From: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Wed, 27 Oct 2010 10:32:27 +0200
Message-ID: <4CC7E39B.5080900@6wind.com>
References: <20100929113757.GA23755@core.hellgate.ch>	<AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>	<20100930080703.GA10827@core.hellgate.ch>	<AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>	<4CB81BF1.1050906@6wind.com>	<AANLkTi=MYxSUzVUF2sf1G32Z2EcjhfyOJ4EZyv5ePGWM@mail.gmail.com>	<4CC58AB9.4090903@6wind.com> <AANLkTinH1Q4iq1_wg7HU_==khAtKOTZ2gz79s_EfzLYP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40601 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488Ab0J0If0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 04:35:26 -0400
Received: by mail-wy0-f174.google.com with SMTP id 28so403644wyf.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 01:35:26 -0700 (PDT)
In-Reply-To: <AANLkTinH1Q4iq1_wg7HU_==khAtKOTZ2gz79s_EfzLYP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross wrote:
> On Mon, Oct 25, 2010 at 6:48 AM, Guillaume Gaudonville
> <guillaume.gaudonville@6wind.com> wrote:
>  =20
>> Jesse Gross wrote:
>>    =20
>>> On Fri, Oct 15, 2010 at 2:16 AM, Guillaume Gaudonville
>>> <guillaume.gaudonville@6wind.com> wrote:
>>>
>>>      =20
>>>> Jesse Gross wrote:
>>>>
>>>>        =20
>>>>> On Thu, Sep 30, 2010 at 1:07 AM, Roger Luethi <rl@hellgate.ch> wr=
ote:
>>>>>
>>>>>
>>>>>          =20
>>>>>> On Wed, 29 Sep 2010 10:44:26 -0700, Jesse Gross wrote:
>>>>>>
>>>>>>
>>>>>>            =20
>>>>>>> On Wed, Sep 29, 2010 at 4:37 AM, Roger Luethi <rl@hellgate.ch> =
wrote:
>>>>>>>
>>>>>>>
>>>>>>>              =20
>>>>>>>> I noticed packets for unknown VLANs getting silently dropped e=
ven in
>>>>>>>> promiscuous mode (this is true only for the hardware accelerat=
ed
>>>>>>>> path).
>>>>>>>> netif_nit_deliver was introduced specifically to prevent that,=
 but
>>>>>>>> the
>>>>>>>> function gets called only _after_ packets from unknown VLANs h=
ave
>>>>>>>> been
>>>>>>>> dropped.
>>>>>>>>
>>>>>>>>
>>>>>>>>                =20
>>>>>>> Some drivers are fixing this on a case by case basis by disabli=
ng
>>>>>>> hardware accelerated VLAN stripping when in promiscuous mode, i=
=2Ee.:
>>>>>>>
>>>>>>>
>>>>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.=
git;a=3Dcommit;h=3D5f6c01819979afbfec7e0b15fe52371b8eed87e8
>>>>>>>
>>>>>>> However, at this point it is more or less random which drivers =
do
>>>>>>> this.  It would obviously be much better if it were consistent.
>>>>>>>
>>>>>>>
>>>>>>>              =20
>>>>>> My understanding is this. Hardware VLAN tagging and stripping ca=
n
>>>>>> always
>>>>>> be
>>>>>> enabled. The kernel passes 802.1Q information along with the str=
ipped
>>>>>> header to libpcap which reassembles the original header where
>>>>>> necessary.
>>>>>> Works for me.
>>>>>>
>>>>>>
>>>>>>            =20
>>>>> Sorry, I misread your original post as saying that the VLAN heade=
r
>>>>> gets dropped, rather than the entire packet.  I agree that this i=
s how
>>>>> it should work but not necessarily how it does work (again, depen=
ding
>>>>> on the driver).  Here's the problem that I was talking about:
>>>>>
>>>>> Most drivers have a snippet of code that looks something like thi=
s
>>>>> (taken from ixgbe):
>>>>>
>>>>> if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
>>>>>       vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
>>>>> else
>>>>>       napi_gro_receive(napi, skb);
>>>>>
>>>>> At this point the VLAN has already been stripped in hardware.  If
>>>>> there is no VLAN group configured on the device then we hit the s=
econd
>>>>> case.  The VLAN header was removed from the SKB and the tag varia=
ble
>>>>> is unused.  It is no longer possible for libpcap to reconstruct t=
he
>>>>> header because the information was thrown away (even the fact tha=
t
>>>>> there was a VLAN tag at all).
>>>>>
>>>>> There are a couple ways to fix this:
>>>>>
>>>>> * Turn off VLAN stripping when in promiscuous mode (as done by th=
e ixgbe
>>>>> driver)
>>>>>
>>>>>
>>>>>          =20
>>>> This is not totally true: if changing the MTU ixgbe_change_mtu wil=
l call:
>>>> ixgbe_reinit_locked--> ixgbe_up --> ixgbe_configure:
>>>>               --> ixgbe_set_rx_mode: flag IFF_PROMISC is tested
>>>> ixgbe_vlan_filter_enable is not called
>>>>               --> ixgbe_restore_vlan --> ixgbe_vlan_rx_register: f=
lag
>>>> IFF_PROMISC is not tested ixgbe_vlan_filter_enable
>>>>                    will be called.
>>>>
>>>> In fact it should happen each time we configure something which ne=
eds a
>>>> reset of the device. Why don't add a test
>>>> on flag promiscuous directly in ixgbe_vlan_filter_enable? Or do it=
 on
>>>> each
>>>> call, if we want to allow a device in promiscuous
>>>> mode to enable this feature.
>>>>
>>>> What do you think?
>>>>
>>>>        =20
>>> I can believe that there are paths that lead to this not working
>>> correctly.  That was actually my larger point: this is something th=
at
>>> is commonly not implemented correctly in drivers.  Rather than try =
to
>>> study every driver my goal is to just avoid the problem completely =
by
>>> handling vlan acceleration centrally in the networking core.  I sen=
t
>>> out an RFC patch series a few days ago that should solve this probl=
em:
>>>
>>> http://marc.info/?l=3Dlinux-netdev&m=3D128700022614170&w=3D3
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>      =20
>> Thank you, I'm going to check these patches and try to apply them in=
 our
>> kernel.
>>    =20
>
> An updated set of patches has been merged into net-2.6, so you might
> want to try that instead.
>  =20
Ok I will, thank you.

--=20
Guillaume Gaudonville
6WIND
Software Engineer

Tel: +33 1 39 30 92 63
Mob: +33 6 47 85 34 33
=46ax: +33 1 39 30 92 11
guillaume.gaudonville@6wind.com
www.6wind.com
Join the Multicore Packet Processing Forum: www.multicorepacketprocessi=
ng.com

Ce courriel ainsi que toutes les pi=E8ces jointes, est uniquement desti=
n=E9 =E0 son ou ses destinataires. Il contient des informations confide=
ntielles qui sont la propri=E9t=E9 de 6WIND. Toute r=E9v=E9lation, dist=
ribution ou copie des informations qu'il contient est strictement inter=
dite. Si vous avez re=E7u ce message par erreur, veuillez imm=E9diateme=
nt le signaler =E0 l'=E9metteur et d=E9truire toutes les donn=E9es re=E7=
ues

This e-mail message, including any attachments, is for the sole use of =
the intended recipient(s) and contains information that is confidential=
 and proprietary to 6WIND. All unauthorized review, use, disclosure or =
distribution is prohibited. If you are not the intended recipient, plea=
se contact the sender by reply e-mail and destroy all copies of the ori=
ginal message.

