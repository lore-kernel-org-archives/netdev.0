From: Jesse Gross <jesse@kernel.org>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path similar
 to hw-accel
Date: Sun, 3 Apr 2011 13:38:00 -0700
Message-ID: <BANLkTin-VVOLQgPA7+CrtBdntnO-0C+R+g@mail.gmail.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com> <4D989100.1090207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, xiaosuo@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41249 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415Ab1DCUiW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 16:38:22 -0400
Received: by vws1 with SMTP id 1so3735163vws.19
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2011 13:38:21 -0700 (PDT)
In-Reply-To: <4D989100.1090207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 3, 2011 at 8:23 AM, Nicolas de Peslo=FCan
<nicolas.2p.debian@gmail.com> wrote:
> Le 02/04/2011 12:26, Jiri Pirko a =E9crit :
>>
>> Now there are 2 paths for rx vlan frames. When rx-vlan-hw-accel is
>> enabled, skb is untagged by NIC, vlan_tci is set and the skb gets in=
to
>> vlan code in __netif_receive_skb - vlan_hwaccel_do_receive.
>>
>> For non-rx-vlan-hw-accel however, tagged skb goes thru whole
>> __netif_receive_skb, it's untagged in ptype_base hander and reinject=
ed
>>
>> This incosistency is fixed by this patch. Vlan untagging happens ear=
ly in
>> __netif_receive_skb so the rest of code (ptype_all handlers, rx_hand=
lers)
>> see the skb like it was untagged by hw.
>>
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>

You saw Eric B.'s recent patch trying to tackle the same issues, right?=
:
http://permalink.gmane.org/gmane.linux.network/190229

>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 3da9fb0..bfe9fce 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3130,6 +3130,12 @@ another_round:
>>
>> =A0 =A0 =A0 =A0__this_cpu_inc(softnet_data.processed);
>>
>> + =A0 =A0 =A0 if (skb->protocol =3D=3D cpu_to_be16(ETH_P_8021Q)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D vlan_untag(skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!skb))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 }
>> +
>
> I like the general idea of this patch, but I don't like the idea of
> re-inserting specific code inside __netif_receive_skb.
>
> You made a great work removing most - if not all - device specific pa=
rts
> from __netif_receive_skb, by introducing rx_handler.
>
> I think the above part (and vlan_untag) should be moved to a vlan_rx_=
handler
> that would be set on the net_devices that are the parent of a vlan
> net_device and are NOT hwaccel.
>
> vlan_rx_handler would return RX_HANDLER_ANOTHER if skb holds a tagged=
 frame
> (skb->dev changed) and RX_HANDLER_PASS if skb holds an untagged frame
> (skb->dev unchanged).

It would be nice to merge all of this together.  One complication is
the interaction of bridging and vlan on the same device.  Some people
want to have a bridge for each vlan and a bridge for untagged packets.
 On older kernels with vlan accelerated hardware this was possible
because vlan devices would get packets before bridging and on current
kernels it is possible with ebtables rules.  If we use rx_handler for
both I believe we would need to extend it some to allow multiple
handlers.

>
> This would also cause protocol handlers to receive the untouched (tag=
ged)
> frame, if no setup required the frame to be untagged, which I think i=
s the
> right thing to do.

At the very least we need to make sure that these packets are marked
as PACKET_OTHERHOST because protocol handlers don't pay attention to
the vlan field.

>
>> @@ -3177,7 +3183,7 @@ ncls:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D deliver_skb(skb,=
 pt_prev, orig_dev);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pt_prev =3D NULL;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (vlan_hwaccel_do_receive(&skb)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (vlan_do_receive(&skb)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __netif_receive_=
skb(skb);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (unlikely(!skb))
>
> Why are you calling __netif_receive_skb here? Can't we simply goto
> another_round?

This code (other than the name change) predates the
another_round/rx_handler changes.
