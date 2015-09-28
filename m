From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH] Fix false positives in can_checksum_protocol()
Date: Mon, 28 Sep 2015 10:03:13 -0700
Message-ID: <CALx6S34Bs8pOyGXEOvABdG16wyWZuhsg5G4sO_vJgCnz0xxi5A@mail.gmail.com>
References: <1443185758.4674.44.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33663 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933924AbbI1RDP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 13:03:15 -0400
Received: by iofh134 with SMTP id h134so182170070iof.0
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 10:03:13 -0700 (PDT)
In-Reply-To: <1443185758.4674.44.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2015 at 5:55 AM, David Woodhouse <dwmw2@infradead.org> =
wrote:
> The check in harmonize_features() is supposed to match the skb agains=
t
> the features of the device in question, and prevent us from handing a
> skb to a device which can't handle it.
>
> It doesn't work correctly. A device with NETIF_F_IP_CSUM or
> NETIF_F_IPV6_CSUM capabilities is only required to checksum TCP or UD=
P,
> on Legacy IP and IPv6 respectively. But the existing check will allow
> us to pass it *any* ETH_P_IP/ETH_P_IPV6 packets for hardware checksum
> offload.
>
> Depending on the driver in use, this leads to a BUG, a WARNING, or ju=
st
> silent data corruption.
>
> This is one approach to fixing that, and my test program at
> http://bombadil.infradead.org/~dwmw2/raw.c can no longer trivially
> reproduce the problem.
>
> The test does now have false *negatives*, but those shouldn't happen
> for locally-generated packets; only packets injected from af_packet,
> tun, virtio_net and other places that allow us to inject
> CHECKSUM_PARTIAL packets in order to make use of hardware offload
> features. And false negatives aren't anywhere near as much of a probl=
em
> as false positives are =E2=80=94 we just finish the checksum in softw=
are and
> send the packet anyway.
>
> It would be possible to fix those false negatives, if we really wante=
d
> to =E2=80=94 perhaps by adding an additional bit in the skbuff which =
indicates
> that it *is* a TCP or UDP packet, rather than using ->sk->sk_protocol=
=2E
> Then that bit could be set if appropriate in skb_partial_csum_set(), =
as
> well as the places where we locally generate such packets. And the
> check in can_checksum_protocol() would just check for that bit.
>
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ---
> Since can_checksum_protocol is inline, the compiler ought to know tha=
t
> it doesn't even need to dereference skb->sk in the case where the
> device has the NETIF_F_GEN_CSUM feature. So the additional check shou=
ld
> not slow down the (hopefully) common case in the fast path.
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 2d15e38..76c8330 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3628,15 +3628,23 @@ struct sk_buff *skb_gso_segment(struct sk_buf=
f *skb, netdev_features_t features)
>  __be16 skb_network_protocol(struct sk_buff *skb, int *depth);
>
>  static inline bool can_checksum_protocol(netdev_features_t features,
> -                                        __be16 protocol)
> -{
> -       return ((features & NETIF_F_GEN_CSUM) ||
> -               ((features & NETIF_F_V4_CSUM) &&
> -                protocol =3D=3D htons(ETH_P_IP)) ||
> -               ((features & NETIF_F_V6_CSUM) &&
> -                protocol =3D=3D htons(ETH_P_IPV6)) ||
> -               ((features & NETIF_F_FCOE_CRC) &&
> -                protocol =3D=3D htons(ETH_P_FCOE)));
> +                                        __be16 protocol, u8 sk_proto=
col)
> +{
> +       if ((features & NETIF_F_GEN_CSUM) ||
> +           ((features & NETIF_F_FCOE_CRC) && protocol =3D=3D htons(E=
TH_P_FCOE)))
> +               return 1;
> +
> +       /* NETIF_F_V[46]_CSUM are defined to work only on TCP and UDP=
=2E
> +        * That is, when it needs to start checksumming at the transp=
ort
> +        * header, and place the result at an offset of either 6 (for=
 UDP)
> +        * or 16 (for TCP).
> +        */
> +       if ((((features & NETIF_F_V4_CSUM) && protocol =3D=3D htons(E=
TH_P_IP)) ||
> +            ((features & NETIF_F_V6_CSUM) && protocol =3D=3D htons(E=
TH_P_IPV6))) &&
> +           (sk_protocol =3D=3D IPPROTO_TCP || sk_protocol =3D=3D IPP=
ROTO_UDP))
> +               return 1;
> +
Relying on skb->sk->sk_protocol is problematic. This is making the
assumption that the checksum being offloaded for the packet is the
same as that of the protocol for the socket-- this may not be the case
when we are offloading an outer checksum in encapsulation. Currently
this wouldn't a be problem since we're probably only offloading outer
UDP checksums, but if we ever start trying to offload other outer
checksums (e.g. GRE) then this probably doesn't work so well. Also,
this doesn't help those drivers that that can offload TCP and UDP for
IPv6 but only if there are no extension headers, in those case the
driver needs to look at the packet to see if it is a "simple" UDP/TCP
packet.

AFAIK, the only non UDP/TCP transport IP checksum in the stack is GRE
checksum which as I pointed out we don't attempt to offload. So the
only way to trip the bug that you are seeing is probably through a
userspace packet interface like in the test code. I think this
actually might expose a much more serious issue. Looking at tun.c, I
don't see anything that validates that the csum_start and csum_offset
provided by userspace actually refers to a sane checksum offset. Not
only is this a way to ask the stack to perform checksums for non
TCP/UDP, but it actually seems like the interface could be used by a
malicious application to have a device arbitrarily overwrite two bytes
anywhere in the packet with it's own data far below the stack,
netfilter, routing. To really fix this we should probably be doing
validation in tun, if the checksum isn't for TCP or UDP then call
skb_checksum_help before sending the packet into the stack.

Tom

> +       return 0;
>  }
>
>  #ifdef CONFIG_BUG
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6bb6470..3c40957 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2613,7 +2613,8 @@ static netdev_features_t harmonize_features(str=
uct sk_buff *skb,
>         features =3D net_mpls_features(skb, features, type);
>
>         if (skb->ip_summed !=3D CHECKSUM_NONE &&
> -           !can_checksum_protocol(features, type)) {
> +           !can_checksum_protocol(features, type,
> +                                  skb->sk ? skb->sk->sk_protocol : 0=
)) {
>                 features &=3D ~NETIF_F_ALL_CSUM;
>         } else if (illegal_highdma(skb->dev, skb)) {
>                 features &=3D ~NETIF_F_SG;
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index dad4dd3..9126c6f 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3004,7 +3004,8 @@ struct sk_buff *skb_segment(struct sk_buff *hea=
d_skb,
>                 return ERR_PTR(-EINVAL);
>
>         csum =3D !head_skb->encap_hdr_csum &&
> -           !!can_checksum_protocol(features, proto);
> +               !!can_checksum_protocol(features, proto,
> +                               head_skb->sk ? head_skb->sk->sk_proto=
col : 0);
>
>         headroom =3D skb_headroom(head_skb);
>         pos =3D skb_headlen(head_skb);
> --
> David Woodhouse                            Open Source Technology Cen=
tre
> David.Woodhouse@intel.com                              Intel Corporat=
ion
>
