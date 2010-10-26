From: Jesse Gross <jesse@nicira.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Mon, 25 Oct 2010 17:40:57 -0700
Message-ID: <AANLkTinH1Q4iq1_wg7HU_==khAtKOTZ2gz79s_EfzLYP@mail.gmail.com>
References: <20100929113757.GA23755@core.hellgate.ch>
	<AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	<20100930080703.GA10827@core.hellgate.ch>
	<AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
	<4CB81BF1.1050906@6wind.com>
	<AANLkTi=MYxSUzVUF2sf1G32Z2EcjhfyOJ4EZyv5ePGWM@mail.gmail.com>
	<4CC58AB9.4090903@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44931 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919Ab0JZAk7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 20:40:59 -0400
Received: by wwe15 with SMTP id 15so4144464wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 17:40:58 -0700 (PDT)
In-Reply-To: <4CC58AB9.4090903@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 25, 2010 at 6:48 AM, Guillaume Gaudonville
<guillaume.gaudonville@6wind.com> wrote:
> Jesse Gross wrote:
>>
>> On Fri, Oct 15, 2010 at 2:16 AM, Guillaume Gaudonville
>> <guillaume.gaudonville@6wind.com> wrote:
>>
>>>
>>> Jesse Gross wrote:
>>>
>>>>
>>>> On Thu, Sep 30, 2010 at 1:07 AM, Roger Luethi <rl@hellgate.ch> wro=
te:
>>>>
>>>>
>>>>>
>>>>> On Wed, 29 Sep 2010 10:44:26 -0700, Jesse Gross wrote:
>>>>>
>>>>>
>>>>>>
>>>>>> On Wed, Sep 29, 2010 at 4:37 AM, Roger Luethi <rl@hellgate.ch> w=
rote:
>>>>>>
>>>>>>
>>>>>>>
>>>>>>> I noticed packets for unknown VLANs getting silently dropped ev=
en in
>>>>>>> promiscuous mode (this is true only for the hardware accelerate=
d
>>>>>>> path).
>>>>>>> netif_nit_deliver was introduced specifically to prevent that, =
but
>>>>>>> the
>>>>>>> function gets called only _after_ packets from unknown VLANs ha=
ve
>>>>>>> been
>>>>>>> dropped.
>>>>>>>
>>>>>>>
>>>>>>
>>>>>> Some drivers are fixing this on a case by case basis by disablin=
g
>>>>>> hardware accelerated VLAN stripping when in promiscuous mode, i.=
e.:
>>>>>>
>>>>>>
>>>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.g=
it;a=3Dcommit;h=3D5f6c01819979afbfec7e0b15fe52371b8eed87e8
>>>>>>
>>>>>> However, at this point it is more or less random which drivers d=
o
>>>>>> this. =A0It would obviously be much better if it were consistent=
=2E
>>>>>>
>>>>>>
>>>>>
>>>>> My understanding is this. Hardware VLAN tagging and stripping can
>>>>> always
>>>>> be
>>>>> enabled. The kernel passes 802.1Q information along with the stri=
pped
>>>>> header to libpcap which reassembles the original header where
>>>>> necessary.
>>>>> Works for me.
>>>>>
>>>>>
>>>>
>>>> Sorry, I misread your original post as saying that the VLAN header
>>>> gets dropped, rather than the entire packet. =A0I agree that this =
is how
>>>> it should work but not necessarily how it does work (again, depend=
ing
>>>> on the driver). =A0Here's the problem that I was talking about:
>>>>
>>>> Most drivers have a snippet of code that looks something like this
>>>> (taken from ixgbe):
>>>>
>>>> if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
>>>> =A0 =A0 =A0 vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
>>>> else
>>>> =A0 =A0 =A0 napi_gro_receive(napi, skb);
>>>>
>>>> At this point the VLAN has already been stripped in hardware. =A0I=
f
>>>> there is no VLAN group configured on the device then we hit the se=
cond
>>>> case. =A0The VLAN header was removed from the SKB and the tag vari=
able
>>>> is unused. =A0It is no longer possible for libpcap to reconstruct =
the
>>>> header because the information was thrown away (even the fact that
>>>> there was a VLAN tag at all).
>>>>
>>>> There are a couple ways to fix this:
>>>>
>>>> * Turn off VLAN stripping when in promiscuous mode (as done by the=
 ixgbe
>>>> driver)
>>>>
>>>>
>>>
>>> This is not totally true: if changing the MTU ixgbe_change_mtu will=
 call:
>>> ixgbe_reinit_locked--> ixgbe_up --> ixgbe_configure:
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 --> ixgbe_set_rx_mode: flag IFF_PROMISC=
 is tested
>>> ixgbe_vlan_filter_enable is not called
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 --> ixgbe_restore_vlan --> ixgbe_vlan_r=
x_register: flag
>>> IFF_PROMISC is not tested ixgbe_vlan_filter_enable
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0will be called.
>>>
>>> In fact it should happen each time we configure something which nee=
ds a
>>> reset of the device. Why don't add a test
>>> on flag promiscuous directly in ixgbe_vlan_filter_enable? Or do it =
on
>>> each
>>> call, if we want to allow a device in promiscuous
>>> mode to enable this feature.
>>>
>>> What do you think?
>>>
>>
>> I can believe that there are paths that lead to this not working
>> correctly. =A0That was actually my larger point: this is something t=
hat
>> is commonly not implemented correctly in drivers. =A0Rather than try=
 to
>> study every driver my goal is to just avoid the problem completely b=
y
>> handling vlan acceleration centrally in the networking core. =A0I se=
nt
>> out an RFC patch series a few days ago that should solve this proble=
m:
>>
>> http://marc.info/?l=3Dlinux-netdev&m=3D128700022614170&w=3D3
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>
> Thank you, I'm going to check these patches and try to apply them in =
our
> kernel.

An updated set of patches has been merged into net-2.6, so you might
want to try that instead.
