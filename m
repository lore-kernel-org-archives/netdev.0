From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] vlan: Fix duplicate delivery of vlan 0 packets to
 ETH_P_ALL packet sockets
Date: Wed, 23 Mar 2011 13:59:25 -0700
Message-ID: <AANLkTinYDOAbF8TO_LA9UccEnBNCqLEyx7mpDBtfmH8z@mail.gmail.com>
References: <m1sjugi2d0.fsf@fess.ebiederm.org>
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
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56538 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933284Ab1CWU7q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 16:59:46 -0400
Received: by vws1 with SMTP id 1so5998876vws.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 13:59:45 -0700 (PDT)
In-Reply-To: <m1sjugi2d0.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2011 at 2:35 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> For vlan data coming in from nics without vlan hardware accelleration=
 we
> get two copies of vlan packets with vlan id 0 on pf_packet sockets, c=
ausing
> userspace to break. =A0This is caused by delivering the same packet t=
o the same
> networking device more than once.

I agree that this is a problem and the code consolidation is very nice
but I'm concerned that there is extra complexity for the rest of the
system to counterbalance what is saved here.

> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index ce8e3ab..a0849b9 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> +void emulate_vlan_hwaccel(struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 struct vlan_hdr *vhdr =3D (struct vlan_hdr *)skb->data;
> + =A0 =A0 =A0 __be16 proto;
> +
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, VLAN_HLEN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 __vlan_hwaccel_put_tag(skb, vhdr->h_vlan_TCI);
> + =A0 =A0 =A0 skb_pull_rcsum(skb, VLAN_HLEN);

Doesn't this break things which push the header back on?  Bridging
pushes ETH_HLEN before forwarding but here it will be a garbage value
due to the extra vlan header.  AF_PACKET pushes the mac header back
on, which in this case includes the original vlan header.  However,
since we've also put the tag in skb->vlan_tci, won't it appear to be
double tagged?

More generally, even though we pull the tag off the skb it's pretty
common on the receive path to look backwards into previous headers.
Given that this can happen, I think it's somewhat confusing/fragile to
have packet data which effectively should not be there.  It also adds
a third case to any generic vlan handling code: tag in packet (can
still happen, such as on transmit), received on vlan accelerated NIC -
tag in skb but not in packet, receive on non-vlan accelerated NIC -
tag in both skb and packet.

If we actually removed the tag in the emulated case that would avoid
these concerns but would, of course, add extra overhead in some
situations.
