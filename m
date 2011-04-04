From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path similar
 to hw-accel
Date: Mon, 04 Apr 2011 08:54:40 +0200
Message-ID: <4D996B30.3080408@gmail.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com> <4D989100.1090207@gmail.com> <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, xiaosuo@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54011 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699Ab1DDGyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 02:54:46 -0400
Received: by wya21 with SMTP id 21so4401058wya.19
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2011 23:54:44 -0700 (PDT)
In-Reply-To: <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/04/2011 22:38, Jesse Gross a =E9crit :
> On Sun, Apr 3, 2011 at 8:23 AM, Nicolas de Peslo=FCan
> <nicolas.2p.debian@gmail.com>  wrote:
>> Le 02/04/2011 12:26, Jiri Pirko a =E9crit :
>>>
>>> Now there are 2 paths for rx vlan frames. When rx-vlan-hw-accel is
>>> enabled, skb is untagged by NIC, vlan_tci is set and the skb gets i=
nto
>>> vlan code in __netif_receive_skb - vlan_hwaccel_do_receive.
>>>
>>> For non-rx-vlan-hw-accel however, tagged skb goes thru whole
>>> __netif_receive_skb, it's untagged in ptype_base hander and reinjec=
ted
>>>
>>> This incosistency is fixed by this patch. Vlan untagging happens ea=
rly in
>>> __netif_receive_skb so the rest of code (ptype_all handlers, rx_han=
dlers)
>>> see the skb like it was untagged by hw.
>>>
>>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>
> You saw Eric B.'s recent patch trying to tackle the same issues, righ=
t?:
> http://permalink.gmane.org/gmane.linux.network/190229

Yes, of course I saw it.

>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 3da9fb0..bfe9fce 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -3130,6 +3130,12 @@ another_round:
>>>
>>>         __this_cpu_inc(softnet_data.processed);
>>>
>>> +       if (skb->protocol =3D=3D cpu_to_be16(ETH_P_8021Q)) {
>>> +               skb =3D vlan_untag(skb);
>>> +               if (unlikely(!skb))
>>> +                       goto out;
>>> +       }
>>> +
>>
>> I like the general idea of this patch, but I don't like the idea of
>> re-inserting specific code inside __netif_receive_skb.
>>
>> You made a great work removing most - if not all - device specific p=
arts
>> from __netif_receive_skb, by introducing rx_handler.
>>
>> I think the above part (and vlan_untag) should be moved to a vlan_rx=
_handler
>> that would be set on the net_devices that are the parent of a vlan
>> net_device and are NOT hwaccel.
>>
>> vlan_rx_handler would return RX_HANDLER_ANOTHER if skb holds a tagge=
d frame
>> (skb->dev changed) and RX_HANDLER_PASS if skb holds an untagged fram=
e
>> (skb->dev unchanged).
>
> It would be nice to merge all of this together.  One complication is
> the interaction of bridging and vlan on the same device.  Some people
> want to have a bridge for each vlan and a bridge for untagged packets=
=2E
>   On older kernels with vlan accelerated hardware this was possible
> because vlan devices would get packets before bridging and on current
> kernels it is possible with ebtables rules.  If we use rx_handler for
> both I believe we would need to extend it some to allow multiple
> handlers.

I totally agree.

Remember that Jiri's original proposal (last summer) was to have severa=
l rx_handlers per net_device.=20
I still think we need several of them, because the network stack need t=
o be generic and allow for=20
any complex stacking setup. The rx_handler framework may need to be enh=
anced for that, but I think=20
it is the right tool to do all those per net_device specific features.

>> This would also cause protocol handlers to receive the untouched (ta=
gged)
>> frame, if no setup required the frame to be untagged, which I think =
is the
>> right thing to do.
>
> At the very least we need to make sure that these packets are marked
> as PACKET_OTHERHOST because protocol handlers don't pay attention to
> the vlan field.

Agreed.

>>> @@ -3177,7 +3183,7 @@ ncls:
>>>                        ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>>                        pt_prev =3D NULL;
>>>                }
>>> -             if (vlan_hwaccel_do_receive(&skb)) {
>>> +             if (vlan_do_receive(&skb)) {
>>>                        ret =3D __netif_receive_skb(skb);
>>>                        goto out;
>>>                } else if (unlikely(!skb))
>>
>> Why are you calling __netif_receive_skb here? Can't we simply goto
>> another_round?
>
> This code (other than the name change) predates the
> another_round/rx_handler changes.

Yes, you are right. Let's keep this for a possible follow-up patch, to =
avoid skb reinjection when it=20
is not strictly necessary.

	Nicolas.
