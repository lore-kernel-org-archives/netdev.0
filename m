From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: Fix highmem support in non-TSO
 egress path
Date: Thu, 22 Jan 2015 09:17:18 -0300
Message-ID: <54C0EA4E.2070208@free-electrons.com>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com> <1421844850-30886-3-git-send-email-ezequiel.garcia@free-electrons.com> <20150121174049.GW26493@n2100.arm.linux.org.uk> <54C03786.2060101@free-electrons.com> <20150122001103.GY26493@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	B38611@freescale.com, fabio.estevam@freescale.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:43438 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751744AbbAVMTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:19:23 -0500
In-Reply-To: <20150122001103.GY26493@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2015 09:11 PM, Russell King - ARM Linux wrote:
> On Wed, Jan 21, 2015 at 08:34:30PM -0300, Ezequiel Garcia wrote:
>> I have just realised that the non-TSO and the TSO paths must work
>> simultaneously (we don't know which path an egress skb will take).
>>
>> So, with these patches, the unmapping is done using dma_unmap_page()=
 which
>> is only correct if the skb took the non-TSO paths. In other words,
>> these fixes are wrong (although I have no idea the effect of
>> using dma_unmap_page on a mapping done with dma_map_single).
>>
>> And the problem is that in the TSO path, the linear and the non-line=
ar
>> fragments use the same kind of descriptors, so we can't distinguish
>> them in the cleanup, and can't decide if _single or _page should be =
used.
>>
>> Any ideas?
>=20
> Or, maybe, if davem would reply, we might come to the conclusion (as
> I previously pointed out) that it's not a driver issue, but a netdev
> core issue:
>=20
> static netdev_features_t harmonize_features(struct sk_buff *skb,
>         netdev_features_t features)
> {
> ...
>         if (skb->ip_summed !=3D CHECKSUM_NONE &&
>             !can_checksum_protocol(features, type)) {
>                 features &=3D ~NETIF_F_ALL_CSUM;
>         } else if (illegal_highdma(skb->dev, skb)) {
>                 features &=3D ~NETIF_F_SG;
>         }
>=20
> The problem is when the first "if" is true (as is the case with IPv6 =
on
> mv643xx_eth.c), we clear NETIF_F_ALL_CSUM, but leave NETIF_F_SG set.
>=20
> Had that first if been false, we would've called illegal_highdma(), a=
nd
> found that the skb contains some highmem fragments, but the device do=
es
> *not* have NETIF_F_HIGHDMA set, and so that second "if" would be true=
=2E
> The result of that is NETIF_F_SG is cleared.
>=20
> In this case, in validate_xmit_skb(), skb_needs_linearize() would be
> false for a skb with fragments, causing the skb to be linearised.  I'=
ve
> not completely traced the GSO path, but I'd assume that does somethin=
g
> similar (which I think skb_segment() handles.)
>=20
> So, I'm wondering whether the above should be:
>=20
> static netdev_features_t harmonize_features(struct sk_buff *skb,
>         netdev_features_t features)
> {
> ...
>         if (skb->ip_summed !=3D CHECKSUM_NONE &&
>             !can_checksum_protocol(features, type)) {
>                 features &=3D ~NETIF_F_ALL_CSUM;
>         }
>=20
>         if (illegal_highdma(skb->dev, skb)) {
>                 features &=3D ~NETIF_F_SG;
>         }
>=20
> So that we get NETIF_F_SG turned off for all cases (irrespective of t=
he
> NETIF_F_ALL_CSUM test) if we see a skb with highmem and we the device
> does not support highdma.
>=20
> Yes, the code above hasn't changed in functionality for a long time, =
but
> that doesn't mean it isn't buggy, and isn't the cause of our current =
bug.
>=20

Hm, that's interesting.

> However, it would be far better to have the drivers fixed for the sak=
e
> of performance - it's only this dma_map_page() thing that is the real
> cause of the problem in these drivers.
>=20

Yes, I have just sent a v2 to fix the mv643xx_eth driver (non-TSO path)=
=2E
If that works, I'll see about preparing a fix for mvneta, and for both
egress paths.

> Looking at TSO, it seems madness that it doesn't support highmem:
>=20
> void tso_start(struct sk_buff *skb, struct tso_t *tso)
> {
> ...
>         tso->data =3D skb->data + hdr_len;
> ...
>                 tso->data =3D page_address(frag->page.p) + frag->page=
_offset;
>=20
> Of course, this would all be a lot easier for drivers if all drivers =
had
> to worry about was a struct page, offset and size, rather than having=
 to
> track whether each individual mapping of a transmit packet was mapped
> with dma_map_single() or dma_map_page().
>=20
> That all said, what I really care about is the regression which basic=
ally
> makes 3.18 unusable on this hardware and seeing _some_ kind of resolu=
tion
> to that regression - I don't care if it doesn't quite perform, what I=
 care
> about is that the network driver doesn't oops the kernel.
>=20

Thanks for all the info!
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
