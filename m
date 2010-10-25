From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v2 10/14] ixgbe: Update ixgbe to use new vlan accleration.
Date: Tue, 26 Oct 2010 01:23:55 +0200
Message-ID: <AANLkTim68bfo54XsoPbbDUGa4evPA2vSmJbSTs-LZv=Q@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-11-git-send-email-jesse@nicira.com>
	<AANLkTindxJD1a5UPV+6vWbDEeMUTy1QgPs1X8pT-b69D@mail.gmail.com>
	<1288029009.1808.1.camel@pjaxe>
	<AANLkTi=R9f3oAdVAG1MyyTwEqBGRaBj8mtLPg15R2BjW@mail.gmail.com>
	<4CC5FE81.4020606@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:34745 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932156Ab0JYXX4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 19:23:56 -0400
Received: by qyk10 with SMTP id 10so2273684qyk.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 16:23:55 -0700 (PDT)
In-Reply-To: <4CC5FE81.4020606@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 26 pa=BCdziernika 2010 00:02 u=BFytkownik John Fastabend
<john.r.fastabend@intel.com> napisa=B3:
> On 10/25/2010 2:40 PM, Micha=B3 Miros=B3aw wrote:
>> W dniu 25 pa=BCdziernika 2010 19:50 u=BFytkownik Peter P Waskiewicz =
Jr
>> <peter.p.waskiewicz.jr@intel.com> napisa=B3:
>>> On Fri, 2010-10-22 at 06:24 -0700, Micha=B3 Miros=B3aw wrote:
>>>> 2010/10/21 Jesse Gross <jesse@nicira.com>:
>>>>> Make the ixgbe driver use the new vlan accleration model.
>>>> [...]
>>>>> --- a/drivers/net/ixgbe/ixgbe_main.c
>>>>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>>>>> @@ -954,17 +954,13 @@ static void ixgbe_receive_skb(struct ixgbe_=
q_vector *q_vector,
>>>>> =A0 =A0 =A0 =A0bool is_vlan =3D (status & IXGBE_RXD_STAT_VP);
>>>>> =A0 =A0 =A0 =A0u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
>>>>>
>>>>> - =A0 =A0 =A0 if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (adapter->vlgrp && is_vlan && (t=
ag & VLAN_VID_MASK))
>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_gro_receive(na=
pi, adapter->vlgrp, tag, skb);
>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_gro_receive(na=
pi, skb);
>>>>> - =A0 =A0 =A0 } else {
>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (adapter->vlgrp && is_vlan && (t=
ag & VLAN_VID_MASK))
>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_hwaccel_rx(skb=
, adapter->vlgrp, tag);
>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_rx(skb);
>>>>> - =A0 =A0 =A0 }
>>>>> + =A0 =A0 =A0 if (is_vlan && (tag & VLAN_VID_MASK))
>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __vlan_hwaccel_put_tag(skb, tag);
>>>>
>>>> I know that this is carried over from the driver, but why tag =3D=3D=
 0 is
>>>> treated differently here? VID0 is somewhat special, as normally it
>>>> means 802.1p packet, but i.e. in embedded world people are using i=
t as
>>>> normal VID. It would be nice to have this handled consistently in =
the
>>>> VLAN core - deliver to base dev (tag stripped) if vlan 0 is not
>>>> configured and to vlan dev if it is.
>>>
>>> ixgbe handles VLAN 0 differently because that's the tag that's used=
 when
>>> DCB is enabled, and no VLAN is configured. =A0We have to insert the=
 802.1p
>>> tag for DCB to work, but the OS won't know about the 802.1q tag, an=
d
>>> ends up dropping the frame. =A0So we enable VLAN ID 0 in the HW and=
 tell
>>> it to strip the tag, so we can still pass the frame up the stack.
>>
>> So that's actually (part of) what I'm proposing but done at driver l=
evel.
> I agree this should be handled outside the driver. Something like thi=
s should
> do,

Current code (Linus' tree, so with Jesse's VLAN rework applied) should
work exactly as I proposed in my original mail - VLAN 0 is treated as
802.1p (stripped and delivered to original dev) unless vlan device
with id 0 is configured. (Patch untested).

Best Regards,
Micha=B3 Miros=B3aw
---

ixgbe: Enable VLAN 0

Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index f856312..1544368 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -956,7 +956,7 @@ static void ixgbe_receive_skb(struct
ixgbe_q_vector *q_vector,
 	bool is_vlan =3D (status & IXGBE_RXD_STAT_VP);
 	u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);

-	if (is_vlan && (tag & VLAN_VID_MASK))
+	if (is_vlan)
 		__vlan_hwaccel_put_tag(skb, tag);

 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
