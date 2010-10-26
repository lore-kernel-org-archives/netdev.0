From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 10/14] ixgbe: Update ixgbe to use new vlan accleration.
Date: Mon, 25 Oct 2010 17:08:30 -0700
Message-ID: <AANLkTinGe-p3EspYGJbNSY7L=pC6nA+g_MDgC8=NeUVQ@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-11-git-send-email-jesse@nicira.com>
	<AANLkTindxJD1a5UPV+6vWbDEeMUTy1QgPs1X8pT-b69D@mail.gmail.com>
	<1288029009.1808.1.camel@pjaxe>
	<AANLkTi=R9f3oAdVAG1MyyTwEqBGRaBj8mtLPg15R2BjW@mail.gmail.com>
	<4CC5FE81.4020606@intel.com>
	<AANLkTim68bfo54XsoPbbDUGa4evPA2vSmJbSTs-LZv=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:44895 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757170Ab0JZAIc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 20:08:32 -0400
Received: by wwb34 with SMTP id 34so90541wwb.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 17:08:31 -0700 (PDT)
In-Reply-To: <AANLkTim68bfo54XsoPbbDUGa4evPA2vSmJbSTs-LZv=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/10/25 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
> W dniu 26 pa=BCdziernika 2010 00:02 u=BFytkownik John Fastabend
> <john.r.fastabend@intel.com> napisa=B3:
>> On 10/25/2010 2:40 PM, Micha=B3 Miros=B3aw wrote:
>>> W dniu 25 pa=BCdziernika 2010 19:50 u=BFytkownik Peter P Waskiewicz=
 Jr
>>> <peter.p.waskiewicz.jr@intel.com> napisa=B3:
>>>> On Fri, 2010-10-22 at 06:24 -0700, Micha=B3 Miros=B3aw wrote:
>>>>> 2010/10/21 Jesse Gross <jesse@nicira.com>:
>>>>>> Make the ixgbe driver use the new vlan accleration model.
>>>>> [...]
>>>>>> --- a/drivers/net/ixgbe/ixgbe_main.c
>>>>>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>>>>>> @@ -954,17 +954,13 @@ static void ixgbe_receive_skb(struct ixgbe=
_q_vector *q_vector,
>>>>>> =A0 =A0 =A0 =A0bool is_vlan =3D (status & IXGBE_RXD_STAT_VP);
>>>>>> =A0 =A0 =A0 =A0u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
>>>>>>
>>>>>> - =A0 =A0 =A0 if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
>>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (adapter->vlgrp && is_vlan && (=
tag & VLAN_VID_MASK))
>>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_gro_receive(n=
api, adapter->vlgrp, tag, skb);
>>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_gro_receive(n=
api, skb);
>>>>>> - =A0 =A0 =A0 } else {
>>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (adapter->vlgrp && is_vlan && (=
tag & VLAN_VID_MASK))
>>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_hwaccel_rx(sk=
b, adapter->vlgrp, tag);
>>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_rx(skb);
>>>>>> - =A0 =A0 =A0 }
>>>>>> + =A0 =A0 =A0 if (is_vlan && (tag & VLAN_VID_MASK))
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __vlan_hwaccel_put_tag(skb, tag);
>>>>>
>>>>> I know that this is carried over from the driver, but why tag =3D=
=3D 0 is
>>>>> treated differently here? VID0 is somewhat special, as normally i=
t
>>>>> means 802.1p packet, but i.e. in embedded world people are using =
it as
>>>>> normal VID. It would be nice to have this handled consistently in=
 the
>>>>> VLAN core - deliver to base dev (tag stripped) if vlan 0 is not
>>>>> configured and to vlan dev if it is.
>>>>
>>>> ixgbe handles VLAN 0 differently because that's the tag that's use=
d when
>>>> DCB is enabled, and no VLAN is configured. =A0We have to insert th=
e 802.1p
>>>> tag for DCB to work, but the OS won't know about the 802.1q tag, a=
nd
>>>> ends up dropping the frame. =A0So we enable VLAN ID 0 in the HW an=
d tell
>>>> it to strip the tag, so we can still pass the frame up the stack.
>>>
>>> So that's actually (part of) what I'm proposing but done at driver =
level.
>> I agree this should be handled outside the driver. Something like th=
is should
>> do,
>
> Current code (Linus' tree, so with Jesse's VLAN rework applied) shoul=
d
> work exactly as I proposed in my original mail - VLAN 0 is treated as
> 802.1p (stripped and delivered to original dev) unless vlan device
> with id 0 is configured. (Patch untested).

Yes, the current vlan acceleration path should work correctly in this
case.  There are definitely a few things that can be improved though:

1. The non-accelerated path doesn't handle things in the same way,
which is inherently not good.  It doesn't drop packets to vlan 0 but
it does run them through the network stack again on the same device.
The acceleration code simply allows it to continue onto the protocol
handlers.  This can have strange results, i.e. packets will show up
twice in tcpdump (tagged and untagged) on non-accelerated but once
(tagged) on accelerated.

2.  In the ixgbe driver we should be able to handle vlan 0 in a less
special manner.  In addition to delivering accelerated tags to vlan 0,
we should also be able to avoid DCB forcing on vlan stripping.
