From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path similar
 to hw-accel
Date: Mon, 04 Apr 2011 21:00:00 +0200
Message-ID: <4D9A1530.1010102@gmail.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com> <4D989100.1090207@gmail.com> <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com> <4D996B30.3080408@gmail.com> <20110404071453.GA2791@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@kernel.org>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, xiaosuo@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64986 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab1DDTAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 15:00:05 -0400
Received: by wya21 with SMTP id 21so4942957wya.19
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 12:00:04 -0700 (PDT)
In-Reply-To: <20110404071453.GA2791@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/04/2011 09:14, Jiri Pirko a =E9crit :
> Mon, Apr 04, 2011 at 08:54:40AM CEST, nicolas.2p.debian@gmail.com wro=
te:
>> Le 03/04/2011 22:38, Jesse Gross a =E9crit :
<snip>
>>> It would be nice to merge all of this together.  One complication i=
s
>>> the interaction of bridging and vlan on the same device.  Some peop=
le
>>> want to have a bridge for each vlan and a bridge for untagged packe=
ts.
>>>   On older kernels with vlan accelerated hardware this was possible
>>> because vlan devices would get packets before bridging and on curre=
nt
>>> kernels it is possible with ebtables rules.  If we use rx_handler f=
or
>>> both I believe we would need to extend it some to allow multiple
>>> handlers.
>>
>> I totally agree.
>
> I do not. The reason I do vlan_untag early is so actually emulates
> hw acceleration. The reason is to make rx path of hwaccel an
> nonhwaccel similar. If you move vlan untag to rx_handler, this goal
> wouldn't be achieved.

Need to think more about that point.

>> Remember that Jiri's original proposal (last summer) was to have
>> several rx_handlers per net_device. I still think we need several of
>> them, because the network stack need to be generic and allow for any
>> complex stacking setup. The rx_handler framework may need to be
>> enhanced for that, but I think it is the right tool to do all those
>> per net_device specific features.
>>
>>>> This would also cause protocol handlers to receive the untouched (=
tagged)
>>>> frame, if no setup required the frame to be untagged, which I thin=
k is the
>>>> right thing to do.
>>>
>>> At the very least we need to make sure that these packets are marke=
d
>>> as PACKET_OTHERHOST because protocol handlers don't pay attention t=
o
>>> the vlan field.
>>
>> Agreed.
>>
>>>>> @@ -3177,7 +3183,7 @@ ncls:
>>>>>                        ret =3D deliver_skb(skb, pt_prev, orig_dev=
);
>>>>>                        pt_prev =3D NULL;
>>>>>                }
>>>>> -             if (vlan_hwaccel_do_receive(&skb)) {
>>>>> +             if (vlan_do_receive(&skb)) {
>>>>>                        ret =3D __netif_receive_skb(skb);
>>>>>                        goto out;
>>>>>                } else if (unlikely(!skb))
>>>>
>>>> Why are you calling __netif_receive_skb here? Can't we simply goto
>>>> another_round?
>>>
>>> This code (other than the name change) predates the
>>> another_round/rx_handler changes.
>>
>> Yes, you are right. Let's keep this for a possible follow-up patch,
>> to avoid skb reinjection when it is not strictly necessary.
>
> To do another round here was my attention do do in follow up patch (I=
'm
> still figuring out how to move this effectively into rx_handlers)

So you want to move vlan_do_receive into an rx_handler, but want untagg=
ing to stay hard-coded at the=20
beginning of __netif_receive_skb. I don't think I understand the ration=
al behind that.
