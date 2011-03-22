From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH][v3] dev : fix mtu check when TSO is enabled
Date: Mon, 21 Mar 2011 19:31:42 -0700
Message-ID: <AANLkTikFsXmLV-CXD-AjthUhiJ834-G6_F9LrRNaZYTR@mail.gmail.com>
References: <1300135190-14093-1-git-send-email-daniel.lezcano@free.fr>
 <20110314.165929.232913682.davem@davemloft.net> <4D7F7054.70409@free.fr>
 <20110315111756.64b5f4b1@nehalam> <4D80C179.8000900@free.fr>
 <20110316083510.5b9d8c72@nehalam> <4D80E302.9010806@free.fr>
 <20110316094535.5ac6acd8@nehalam> <m1pqpkf5cw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	kaber@trash.net, nightnord@gmail.com, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:60191 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756320Ab1CVCcD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 22:32:03 -0400
Received: by qyg14 with SMTP id 14so5629734qyg.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 19:32:02 -0700 (PDT)
In-Reply-To: <m1pqpkf5cw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2011 at 3:58 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Stephen Hemminger <shemminger@vyatta.com> writes:
>
>> On Wed, 16 Mar 2011 17:19:14 +0100
>> Daniel Lezcano <daniel.lezcano@free.fr> wrote:
>>
>>> On 03/16/2011 04:35 PM, Stephen Hemminger wrote:
>>> > On Wed, 16 Mar 2011 14:56:09 +0100
>>> > Daniel Lezcano<daniel.lezcano@free.fr> =A0wrote:
>>> >
>>> >> On 03/15/2011 07:17 PM, Stephen Hemminger wrote:
>>> >>> On Tue, 15 Mar 2011 14:57:40 +0100
>>> >>> Daniel Lezcano<daniel.lezcano@free.fr> =A0 wrote:
>>> >>>
>>> >>>> On 03/15/2011 12:59 AM, David Miller wrote:
>>> >>>>> From: Daniel Lezcano<daniel.lezcano@free.fr>
>>> >>>>> Date: Mon, 14 Mar 2011 21:39:50 +0100
>>> >>>>>
>>> >>>>>> + =A0 =A0 len =3D dev->mtu + dev->hard_header_len + VLAN_HLE=
N;
>>> >>>>>> + =A0 =A0 if (skb->len< =A0 =A0len)
>>> >>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>>> >>>>> This is not a correct translation of the original test:
>>> >>>>>
>>> >>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(skb->len> =A0 =A0(dev-=
>mtu + dev->hard_header_len + VLAN_HLEN)))) {
>>> >>>>> You need to use "<=3D" in your version, which currently rejec=
ts all
>>> >>>>> full sized frames. :-)
>>> >>>> Right, thanks.
>>> >>>>
>>> >>>>>> +
>>> >>>>>> + =A0 =A0 /* if TSO is enabled, we don't care about the leng=
th as the packet
>>> >>>>>> + =A0 =A0 =A0* could be forwarded without being segmented be=
fore
>>> >>>>>> + =A0 =A0 =A0*/
>>> >>>>>> + =A0 =A0 if (skb->dev&& =A0 =A0skb->dev->features& =A0 =A0N=
ETIF_F_TSO)
>>> >>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>>> >>>>> I am trying to understand why you aren't simply checking also=
 if this
>>> >>>>> is a segmented frame? =A0Perhaps skb_is_gso()&& =A0 =A0device=
 has NETIF_F_TSO
>>> >>>>> set?
>>> >>>> Maybe I am misunderstanding but the packet was forwarded by an=
other device.
>>> >>>> In our case from macvlan:
>>> >>>>
>>> >>>> macvlan_start_xmit
>>> >>>> =A0 =A0 =A0 =A0macvlan_queue_xmit
>>> >>>> =A0 =A0 =A0 =A0 =A0 =A0dest->forward
>>> >>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_skb_forward
>>> >>>>
>>> >>>> When we reached dev_skb_forward, that means we passed through
>>> >>>> dev_hard_start_xmit where the packet was already segmented so =
we should
>>> >>>> exit at the first test (skb->len< =A0 len). I don't see the po=
int of adding
>>> >>>> the skb_is_gso.
>>> >>>> But maybe I am missing something, can you explain ?
>>> >>> The macvlan device only has one downstream device (slave).
>>> >>> If kernel is working properly, macvlan device should have a sub=
set
>>> >>> of the features of the underlying device
>>> >> Right, dev->features =3D lowerdev->features& =A0MACVLAN_FEATURES
>>> >>
>>> >>> and macvlan device should
>>> >>> have same MTU as underlying device.
>>> >> Right,
>>> >>
>>> >> ...
>>> >>
>>> >> =A0 =A0if (!tb[IFLA_MTU])
>>> >> =A0 =A0 =A0 =A0 =A0 dev->mtu =3D lowerdev->mtu;
>>> >>
>>> >> ...
>>> >>> If the feature/MTU flags
>>> >>> were correct, then the path calling macvlan should be respectin=
g
>>> >>> the MTU.
>>> >> But if the TSO is enabled on the macvlan (inherited from eg e100=
0), the
>>> >> packet won't be fragmented to the mtu size no ?
>>> > That is the responsiblity of the hardware that receives the packe=
t.
>>> > Macvlan should be passing it through to the lowerdev and since th=
e hardware
>>> > supports TSO, it will fragment it.
>>>
>>> Ok, but in the case the macvlan is in bridge mode, the dev_skb_forw=
ard
>>> function will forward the packet (which is not fragmented) to to an=
other
>>> macvlan port without going through the hardware driver. In this
>>> function, the packet length is checked against the mtu size and of
>>> course the packet is dropped in case the lower device support the T=
SO
>>> (if the packet is larger than the mtu size). Dave suggested to chec=
k
>>> skb_is_gso and against the TSO feature of the macvlan but I don't
>>> understand why we should check skb_is_gso too.
>>>
>>> =A0 =A0 =A0if (skb_is_gso(skb)&& =A0(skb->dev&& =A0skb->dev->featur=
es& =A0NETIF_F_TSO))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;
>>>
>>>
>>
>> Then it is up to macvlan to do the same thing as bridge code.
>>
>> static inline unsigned packet_length(const struct sk_buff *skb)
>> {
>> =A0 =A0 =A0 return skb->len - (skb->protocol =3D=3D htons(ETH_P_8021=
Q) ? VLAN_HLEN : 0);
>> }
>
> Which is incorrect in this context. =A0skb->len at this point in the =
code
> includes the ethernet header, as we are down below dev_queue_xmit.
>
> The test really does need to be dev->mtu + dev->hard_header_len.
>
> As for conditionally include the VLAN_HLEN that is likely doable but =
I
> think if we are being pedantic that case needs to deal with accelerat=
ed
> vlan headers.

If vlan acceleration is in use then the protocol is not ETH_P_8021Q
and the tag is not included in skb->len.
