From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Mon, 4 Apr 2011 22:29:02 +0200
Message-ID: <20110404202901.GA3657@psychotron.redhat.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com>
 <4D989100.1090207@gmail.com>
 <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com>
 <4D996B30.3080408@gmail.com>
 <20110404071453.GA2791@psychotron.redhat.com>
 <4D9A1530.1010102@gmail.com>
 <m1d3l1eqw8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Jesse Gross <jesse@kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754960Ab1DDU3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 16:29:32 -0400
Content-Disposition: inline
In-Reply-To: <m1d3l1eqw8.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 04, 2011 at 09:51:51PM CEST, ebiederm@xmission.com wrote:
>Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> writes:
>
>> Le 04/04/2011 09:14, Jiri Pirko a =E9crit :
>>> Mon, Apr 04, 2011 at 08:54:40AM CEST, nicolas.2p.debian@gmail.com w=
rote:
>>>> Le 03/04/2011 22:38, Jesse Gross a =E9crit :
>> <snip>
>>>>> It would be nice to merge all of this together.  One complication=
 is
>>>>> the interaction of bridging and vlan on the same device.  Some pe=
ople
>>>>> want to have a bridge for each vlan and a bridge for untagged pac=
kets.
>>>>>   On older kernels with vlan accelerated hardware this was possib=
le
>>>>> because vlan devices would get packets before bridging and on cur=
rent
>>>>> kernels it is possible with ebtables rules.  If we use rx_handler=
 for
>>>>> both I believe we would need to extend it some to allow multiple
>>>>> handlers.
>>>>
>>>> I totally agree.
>>>
>>> I do not. The reason I do vlan_untag early is so actually emulates
>>> hw acceleration. The reason is to make rx path of hwaccel an
>>> nonhwaccel similar. If you move vlan untag to rx_handler, this goal
>>> wouldn't be achieved.
>>
>> Need to think more about that point.
>>
>>>> Remember that Jiri's original proposal (last summer) was to have
>>>> several rx_handlers per net_device. I still think we need several =
of
>>>> them, because the network stack need to be generic and allow for a=
ny
>>>> complex stacking setup. The rx_handler framework may need to be
>>>> enhanced for that, but I think it is the right tool to do all thos=
e
>>>> per net_device specific features.
>>>>
>>>>>> This would also cause protocol handlers to receive the untouched=
 (tagged)
>>>>>> frame, if no setup required the frame to be untagged, which I th=
ink is the
>>>>>> right thing to do.
>>>>>
>>>>> At the very least we need to make sure that these packets are mar=
ked
>>>>> as PACKET_OTHERHOST because protocol handlers don't pay attention=
 to
>>>>> the vlan field.
>>>>
>>>> Agreed.
>>>>
>>>>>>> @@ -3177,7 +3183,7 @@ ncls:
>>>>>>>                        ret =3D deliver_skb(skb, pt_prev, orig_d=
ev);
>>>>>>>                        pt_prev =3D NULL;
>>>>>>>                }
>>>>>>> -             if (vlan_hwaccel_do_receive(&skb)) {
>>>>>>> +             if (vlan_do_receive(&skb)) {
>>>>>>>                        ret =3D __netif_receive_skb(skb);
>>>>>>>                        goto out;
>>>>>>>                } else if (unlikely(!skb))
>>>>>>
>>>>>> Why are you calling __netif_receive_skb here? Can't we simply go=
to
>>>>>> another_round?
>>>>>
>>>>> This code (other than the name change) predates the
>>>>> another_round/rx_handler changes.
>>>>
>>>> Yes, you are right. Let's keep this for a possible follow-up patch=
,
>>>> to avoid skb reinjection when it is not strictly necessary.
>>>
>>> To do another round here was my attention do do in follow up patch =
(I'm
>>> still figuring out how to move this effectively into rx_handlers)
>>
>> So you want to move vlan_do_receive into an rx_handler, but want unt=
agging to
>> stay hard-coded at the beginning of __netif_receive_skb. I don't thi=
nk I
>> understand the rational behind that.
>
>__netif_receive_skb is actually late for untagging.  eth_type_trans
>would be better but not path of control into __netif_receive_skb
>actually calls eth_type_trans.

Why __netif_receive_skb is late?

>
>Eric
>
