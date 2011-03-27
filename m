From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] vlan: Fix duplicate delivery of vlan 0 packets to ETH_P_ALL packet sockets
Date: Sat, 26 Mar 2011 23:27:38 -0700
Message-ID: <m1zkoh9ixx.fsf@fess.ebiederm.org>
References: <m1sjugi2d0.fsf@fess.ebiederm.org>
	<AANLkTinYDOAbF8TO_LA9UccEnBNCqLEyx7mpDBtfmH8z@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	=?utf-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41090 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab1C0G1q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 02:27:46 -0400
In-Reply-To: <AANLkTinYDOAbF8TO_LA9UccEnBNCqLEyx7mpDBtfmH8z@mail.gmail.com>
	(Jesse Gross's message of "Wed, 23 Mar 2011 13:59:25 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse@nicira.com> writes:

> On Mon, Mar 21, 2011 at 2:35 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> For vlan data coming in from nics without vlan hardware accelleratio=
n we
>> get two copies of vlan packets with vlan id 0 on pf_packet sockets, =
causing
>> userspace to break. =C2=A0This is caused by delivering the same pack=
et to the same
>> networking device more than once.
>
> I agree that this is a problem and the code consolidation is very nic=
e
> but I'm concerned that there is extra complexity for the rest of the
> system to counterbalance what is saved here.
>
>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>> index ce8e3ab..a0849b9 100644
>> --- a/net/8021q/vlan_core.c
>> +++ b/net/8021q/vlan_core.c
>> +void emulate_vlan_hwaccel(struct sk_buff *skb)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 struct vlan_hdr *vhdr =3D (struct vlan_hdr *)=
skb->data;
>> + =C2=A0 =C2=A0 =C2=A0 __be16 proto;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 if (!pskb_may_pull(skb, VLAN_HLEN))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 __vlan_hwaccel_put_tag(skb, vhdr->h_vlan_TCI)=
;
>> + =C2=A0 =C2=A0 =C2=A0 skb_pull_rcsum(skb, VLAN_HLEN);
>
> Doesn't this break things which push the header back on?  Bridging
> pushes ETH_HLEN before forwarding but here it will be a garbage value
> due to the extra vlan header.  AF_PACKET pushes the mac header back
> on, which in this case includes the original vlan header.  However,
> since we've also put the tag in skb->vlan_tci, won't it appear to be
> double tagged?

Probably that part does indeed look like a bug, and my testing certainl=
y
shows that there are problems with my patch.

> More generally, even though we pull the tag off the skb it's pretty
> common on the receive path to look backwards into previous headers.
> Given that this can happen, I think it's somewhat confusing/fragile t=
o
> have packet data which effectively should not be there.  It also adds
> a third case to any generic vlan handling code: tag in packet (can
> still happen, such as on transmit), received on vlan accelerated NIC =
-
> tag in skb but not in packet, receive on non-vlan accelerated NIC -
> tag in both skb and packet.
>
> If we actually removed the tag in the emulated case that would avoid
> these concerns but would, of course, add extra overhead in some
> situations.

The only extra overhead I can really see is the need to put the vlan
tag back on in a few instances.   Moving the ethernet addresses around
in the packet (the cost of adding/removing the vlan header) since they
are in a hot cacheline doesn't concern me very much.

But we definitely need to do something to fix the regression for
pf_packet sockets.

Eric

