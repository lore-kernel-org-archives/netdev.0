From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] vlan: Fix duplicate delivery of vlan 0 packets to
 ETH_P_ALL packet sockets
Date: Fri, 1 Apr 2011 18:41:34 -0700
Message-ID: <AANLkTinFdUdxTF1qWr22YGsqw+bXeMYiV7QHwpXioxd3@mail.gmail.com>
References: <m1sjugi2d0.fsf@fess.ebiederm.org> <AANLkTinYDOAbF8TO_LA9UccEnBNCqLEyx7mpDBtfmH8z@mail.gmail.com>
 <m1zkoh9ixx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42387 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265Ab1DBBlz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 21:41:55 -0400
Received: by bwz15 with SMTP id 15so2901615bwz.19
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2011 18:41:54 -0700 (PDT)
In-Reply-To: <m1zkoh9ixx.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 26, 2011 at 11:27 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Jesse Gross <jesse@nicira.com> writes:
>
>> On Mon, Mar 21, 2011 at 2:35 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>>
>>> For vlan data coming in from nics without vlan hardware accellerati=
on we
>>> get two copies of vlan packets with vlan id 0 on pf_packet sockets,=
 causing
>>> userspace to break. =A0This is caused by delivering the same packet=
 to the same
>>> networking device more than once.
>>
>> I agree that this is a problem and the code consolidation is very ni=
ce
>> but I'm concerned that there is extra complexity for the rest of the
>> system to counterbalance what is saved here.
>>
>>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>>> index ce8e3ab..a0849b9 100644
>>> --- a/net/8021q/vlan_core.c
>>> +++ b/net/8021q/vlan_core.c
>>> +void emulate_vlan_hwaccel(struct sk_buff *skb)
>>> +{
>>> + =A0 =A0 =A0 struct vlan_hdr *vhdr =3D (struct vlan_hdr *)skb->dat=
a;
>>> + =A0 =A0 =A0 __be16 proto;
>>> +
>>> + =A0 =A0 =A0 if (!pskb_may_pull(skb, VLAN_HLEN))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>> +
>>> + =A0 =A0 =A0 __vlan_hwaccel_put_tag(skb, vhdr->h_vlan_TCI);
>>> + =A0 =A0 =A0 skb_pull_rcsum(skb, VLAN_HLEN);
>>
>> Doesn't this break things which push the header back on? =A0Bridging
>> pushes ETH_HLEN before forwarding but here it will be a garbage valu=
e
>> due to the extra vlan header. =A0AF_PACKET pushes the mac header bac=
k
>> on, which in this case includes the original vlan header. =A0However=
,
>> since we've also put the tag in skb->vlan_tci, won't it appear to be
>> double tagged?
>
> Probably that part does indeed look like a bug, and my testing certai=
nly
> shows that there are problems with my patch.
>
>> More generally, even though we pull the tag off the skb it's pretty
>> common on the receive path to look backwards into previous headers.
>> Given that this can happen, I think it's somewhat confusing/fragile =
to
>> have packet data which effectively should not be there. =A0It also a=
dds
>> a third case to any generic vlan handling code: tag in packet (can
>> still happen, such as on transmit), received on vlan accelerated NIC=
 -
>> tag in skb but not in packet, receive on non-vlan accelerated NIC -
>> tag in both skb and packet.
>>
>> If we actually removed the tag in the emulated case that would avoid
>> these concerns but would, of course, add extra overhead in some
>> situations.
>
> The only extra overhead I can really see is the need to put the vlan
> tag back on in a few instances. =A0 Moving the ethernet addresses aro=
und
> in the packet (the cost of adding/removing the vlan header) since the=
y
> are in a hot cacheline doesn't concern me very much.

Yes, you're probably right.  It likely rare that we hit this path at
all, unlikely that we'll need to put it back, and, as you say, it's in
a hot cacheline.  In that case, it seems like a reasonable approach to
me.

>
> But we definitely need to do something to fix the regression for
> pf_packet sockets.

I agree.
