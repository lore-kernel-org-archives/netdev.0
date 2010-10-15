From: Jesse Gross <jesse@nicira.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Fri, 15 Oct 2010 14:33:23 -0700
Message-ID: <AANLkTi=MYxSUzVUF2sf1G32Z2EcjhfyOJ4EZyv5ePGWM@mail.gmail.com>
References: <20100929113757.GA23755@core.hellgate.ch>
	<AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	<20100930080703.GA10827@core.hellgate.ch>
	<AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
	<4CB81BF1.1050906@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59423 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab0JOVdZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 17:33:25 -0400
Received: by iwn35 with SMTP id 35so1315646iwn.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 14:33:24 -0700 (PDT)
In-Reply-To: <4CB81BF1.1050906@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 2:16 AM, Guillaume Gaudonville
<guillaume.gaudonville@6wind.com> wrote:
> Jesse Gross wrote:
>>
>> On Thu, Sep 30, 2010 at 1:07 AM, Roger Luethi <rl@hellgate.ch> wrote=
:
>>
>>>
>>> On Wed, 29 Sep 2010 10:44:26 -0700, Jesse Gross wrote:
>>>
>>>>
>>>> On Wed, Sep 29, 2010 at 4:37 AM, Roger Luethi <rl@hellgate.ch> wro=
te:
>>>>
>>>>>
>>>>> I noticed packets for unknown VLANs getting silently dropped even=
 in
>>>>> promiscuous mode (this is true only for the hardware accelerated =
path).
>>>>> netif_nit_deliver was introduced specifically to prevent that, bu=
t the
>>>>> function gets called only _after_ packets from unknown VLANs have=
 been
>>>>> dropped.
>>>>>
>>>>
>>>> Some drivers are fixing this on a case by case basis by disabling
>>>> hardware accelerated VLAN stripping when in promiscuous mode, i.e.=
:
>>>>
>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git=
;a=3Dcommit;h=3D5f6c01819979afbfec7e0b15fe52371b8eed87e8
>>>>
>>>> However, at this point it is more or less random which drivers do
>>>> this. =A0It would obviously be much better if it were consistent.
>>>>
>>>
>>> My understanding is this. Hardware VLAN tagging and stripping can a=
lways
>>> be
>>> enabled. The kernel passes 802.1Q information along with the stripp=
ed
>>> header to libpcap which reassembles the original header where neces=
sary.
>>> Works for me.
>>>
>>
>> Sorry, I misread your original post as saying that the VLAN header
>> gets dropped, rather than the entire packet. =A0I agree that this is=
 how
>> it should work but not necessarily how it does work (again, dependin=
g
>> on the driver). =A0Here's the problem that I was talking about:
>>
>> Most drivers have a snippet of code that looks something like this
>> (taken from ixgbe):
>>
>> if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
>> =A0 =A0 =A0 =A0vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
>> else
>> =A0 =A0 =A0 =A0napi_gro_receive(napi, skb);
>>
>> At this point the VLAN has already been stripped in hardware. =A0If
>> there is no VLAN group configured on the device then we hit the seco=
nd
>> case. =A0The VLAN header was removed from the SKB and the tag variab=
le
>> is unused. =A0It is no longer possible for libpcap to reconstruct th=
e
>> header because the information was thrown away (even the fact that
>> there was a VLAN tag at all).
>>
>> There are a couple ways to fix this:
>>
>> * Turn off VLAN stripping when in promiscuous mode (as done by the i=
xgbe
>> driver)
>>
>
> This is not totally true: if changing the MTU ixgbe_change_mtu will c=
all:
> ixgbe_reinit_locked--> ixgbe_up --> ixgbe_configure:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0--> ixgbe_set_rx_mode: flag IFF_PROMIS=
C is tested
> ixgbe_vlan_filter_enable is not called
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0--> ixgbe_restore_vlan --> ixgbe_vlan_=
rx_register: flag
> IFF_PROMISC is not tested ixgbe_vlan_filter_enable
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 will be called.
>
> In fact it should happen each time we configure something which needs=
 a
> reset of the device. Why don't add a test
> on flag promiscuous directly in ixgbe_vlan_filter_enable? Or do it on=
 each
> call, if we want to allow a device in promiscuous
> mode to enable this feature.
>
> What do you think?

I can believe that there are paths that lead to this not working
correctly.  That was actually my larger point: this is something that
is commonly not implemented correctly in drivers.  Rather than try to
study every driver my goal is to just avoid the problem completely by
handling vlan acceleration centrally in the networking core.  I sent
out an RFC patch series a few days ago that should solve this problem:

http://marc.info/?l=3Dlinux-netdev&m=3D128700022614170&w=3D3
