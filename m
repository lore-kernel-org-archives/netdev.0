From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 7/8] net: ip_tunnel: remove 'csum_help' argument
 to iptunnel_handle_offloads
Date: Mon, 11 Jan 2016 10:15:32 -0800
Message-ID: <CAKgT0UeigRk03syFKNtQu7FR4-de-ShyBeyygEEfjRYZ4SEJ4A@mail.gmail.com>
References: <56901197.8040808@solarflare.com>
	<56901244.8060809@solarflare.com>
	<CAKgT0UdQzW2+n7S3YOhAJVZY-q5bjYaQB0jDn7AD3zp2ZrkGZg@mail.gmail.com>
	<CALx6S34MRoLw_JiHuyDANwoF9+u7k9R-UDb_RGP+L-d9D=f3WQ@mail.gmail.com>
	<CAKgT0UeZwSm4oKoydXWU3iWmjL5m6H=K=hJ2wAkp_GugbZJwjA@mail.gmail.com>
	<5693AD25.4020904@solarflare.com>
	<CAKgT0Ufw9djq-V8YAXjq21gg7rE5=-Dp4o4GmdGk+6Diu4mDNw@mail.gmail.com>
	<5693E6F8.7040806@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:35755 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358AbcAKSPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:15:32 -0500
Received: by mail-ig0-f196.google.com with SMTP id mw1so13251641igb.2
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 10:15:32 -0800 (PST)
In-Reply-To: <5693E6F8.7040806@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 9:31 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 11/01/16 16:39, Alexander Duyck wrote:
>> Your first patch is probably the best place for it.  Then when you
>> start setting false it doesn't introduce any errors.
> Will do.
>> Also I was doing a bit more work on the lco_csum function and think I
>> have come up with something a bit more elegant[...]  What I will do is
>> email you the full patch and the GSO patch I have as RFCs to look over
>> and possibly incorporate into your own.
> <snip>
>> +static inline __wsum lco_csum(struct sk_buff *skb)
>> +{
>> +       unsigned char *csum_start = skb_checksum_start(skb);
>> +       unsigned char *l4_hdr = skb_transport_header(skb);
>> +       __wsum partial;
>> +
>> +       partial = ~csum_unfold(*(__force __sum16 *)(csum_start +
>> +                                                   skb->csum_offset));
>> +       return csum_partial(l4_hdr, csum_start - l4_hdr, partial);
>> +}
>> +
> Looks OK to me.  I'd rather tack both of your patches onto the endof the
>  series, rather than incorporating your patch [1/2] directly into my patch
>  [1/8]; that way (a) the history allows to understand regular LCO before
>  adding in the GSO flavour, (b) you're credited for your improved lco_csum.

Actually if you don't plan to incorporate the function I am fine with
you just leaving it out for now.  I can focus on the GSO portions of
all this and rewrite this to just be an update of your patch.  Then
when you submit your patches and they are accepted I will submit the
GSO implementations.

> As for your patch [2/2], I don't pretend to understand GSO right now but it
>  looks plausible enough.  Perhaps you could add a document about GSO to go
>  alongside the checksum-offloads.txt one?

I don't know if we really need to.  The logic is essentially the same
as what you already have for the local checksum offload.  The only
difference is there is the GSO logic floating around in there to also
compute the outer checksum offload based on the inner that GSO had
already retained when it did the inner offload via software.

Feel free to just exclude it if you want.  I think there may be some
more work to be done on it, for example I am not sure if I actually
needed to move oflload_csum.  If I am not mistaken I think we might be
able to drop the skb->encap_hdr_csum the same way you dropped the
value from iptunnel_handle_offloads.  I might also spend some time
working on the GRE version of the patch as well.  Maybe I can see if
skb->encap_hdr_csum can be dropped.

> What testing haveyou done on your series?  When rebasing it I'll focus on
>  the tunnel types you haven't already tested.

I have been testing with the two Intel NICs I have using just VXLAN as
that was my focus.  I just submitted some patches to the Intel guys
that enable NETIF_F_HW_CSUM for igb, ixgbe, igbvf, and ixgbevf.  With
those patches in place I have been passing traffic without seeing any
issues.  I've been using wireshark to monitor the packets and verify
checksums on the receive side periodically.  It all seems to be
working correctly.

- Alex
