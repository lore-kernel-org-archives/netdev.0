From: Jesse Gross <jesse@nicira.com>
Subject: Re: vlan_get_tag()
Date: Thu, 24 Mar 2011 12:49:14 -0700
Message-ID: <AANLkTimgA1Gv1=f1HOpz0nt8ukG6fPAmWZbyn=eG-XEh@mail.gmail.com>
References: <AANLkTimg9hAq_ZeCLV1sM830z8T_yZ_-+cVUnYBEfk+M@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andrew Strohman <astrohman@simplexinvestments.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44586 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933872Ab1CXTtf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 15:49:35 -0400
Received: by vws1 with SMTP id 1so295782vws.19
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2011 12:49:34 -0700 (PDT)
In-Reply-To: <AANLkTimg9hAq_ZeCLV1sM830z8T_yZ_-+cVUnYBEfk+M@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 12:11 PM, Andrew Strohman
<astrohman@simplexinvestments.com> wrote:
> Hello,
>
> Lately, I was messing around with the linux kernel code, and I wanted
> to look up the Vlan ID for a given sk_buff. =A0 Instead of manually
> pulling the ID out of the sk_buff object, I used this in
> linux/include/linux/if_vlan.h
>
>
> /**
> =A0327 * vlan_get_tag - get the VLAN ID from the skb
> =A0328 * @skb: skbuff to query
> =A0329 * @vlan_tci: buffer to store vlaue
> =A0330 *
> =A0331 * Returns error if the skb is not VLAN tagged
> =A0332 */
> =A0333static inline int vlan_get_tag(const struct sk_buff *skb, u16 *=
vlan_tci)
> =A0334{
> =A0335 =A0 =A0 =A0 =A0if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
> =A0336 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return __vlan_hwaccel_get_tag(s=
kb, vlan_tci);
> =A0337 =A0 =A0 =A0 =A0} else {
> =A0338 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return __vlan_get_tag(skb, vlan=
_tci);
> =A0339 =A0 =A0 =A0 =A0}
> =A0340}
>
>
>
> Everything worked fine until I change the CoS value of my packets, an=
d
> then all the sudden the VLAN IDs that where returned from this
> function were wrong.=A0 I believe I see why:
>
> /**
> =A0306 * __vlan_hwaccel_get_tag - get the VLAN ID that is in @skb->cb=
[]
> =A0307 * @skb: skbuff to query
> =A0308 * @vlan_tci: buffer to store vlaue
> =A0309 *
> =A0310 * Returns error if @skb->vlan_tci is not set correctly
> =A0311 */
> =A0312static inline int __vlan_hwaccel_get_tag(const struct sk_buff *=
skb,
> =A0313 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 u16 *vlan_tci)
> =A0314{
> =A0315 =A0 =A0 =A0 =A0if (vlan_tx_tag_present(skb)) {
> =A0316 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*vlan_tci =3D vlan_tx_tag_get(s=
kb);
> =A0317 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> =A0318 =A0 =A0 =A0 =A0} else {
> =A0319 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*vlan_tci =3D 0;
> =A0320 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0321 =A0 =A0 =A0 =A0}
> =A0322}
>
>
> #define vlan_tx_tag_get(__skb) =A0 =A0 =A0 =A0 =A0((__skb)->vlan_tci =
& ~VLAN_TAG_PRESENT)
>
>
>
> #define VLAN_TAG_PRESENT =A0 =A0 =A0 =A0VLAN_CFI_MASK
> #define VLAN_CFI_MASK =A0 =A0 =A0 =A0 =A0 0x1000 /* Canonical Format =
Indicator */
>
>
>
> So, to me it seems like this function really returns the entire tci
> with the CFI bit zeroed out, not the VLAN ID. =A0Perhaps, instead of
> doing: =A0((__skb)->vlan_tci & ~VLAN_TAG_PRESENT), it should do
> ((__skb)->vlan_tci & VLAN_VID_MASK)?

It does return the entire TCI.  It looks like some of the comments are
out of date but the code is correct.  If you want just the VID then
you should mask it yourself.
