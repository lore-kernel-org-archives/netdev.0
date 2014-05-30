From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] LISP: Locator/Identifier Separation Protocol
Date: Thu, 29 May 2014 17:13:26 -0700
Message-ID: <CA+mtBx--drm2PLO5jrfN=6J-8OnAvaP6HefHo-Ck7EqH-d3scw@mail.gmail.com>
References: <E5B7A820-EF96-4F50-81F8-DE7714105D89@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:39030 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaE3AN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 20:13:27 -0400
Received: by mail-ig0-f180.google.com with SMTP id c1so191049igq.13
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 17:13:26 -0700 (PDT)
In-Reply-To: <E5B7A820-EF96-4F50-81F8-DE7714105D89@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 2:05 PM, Christopher White
<chris@logicalelegance.com> wrote:
> This is a static tunnel implementation of LISP as described in RFC 6830:
>   http://tools.ietf.org/html/rfc6830
>
> This driver provides point-to-point LISP dataplane
> encapsulation/decapsulation for statically configured endpoints. It provides
> support for IPv4 in IPv4 and IPv6 in IPv4. IPv6 outer headers are not
> supported yet. Instance ID is supported on a per device basis.
>

Hi Chris,

Please look at my recent patches to standardize checksum handling for
UDP tunnel implementations. This should also include configuration to
enable UDP4 csums, as well as enabling zero csums in TX or RX for UDP6
when you implement v6 support. Some more specific comments are inline.

Thanks,
Tom

> +static int handle_offloads(struct sk_buff *skb)
> +{
> +       if (skb_is_gso(skb)) {
> +               int err = skb_unclone(skb, GFP_ATOMIC);
> +               if (unlikely(err))
> +                       return err;
> +
> +               skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
> +       } else if (skb->ip_summed != CHECKSUM_PARTIAL) {
> +               skb->ip_summed = CHECKSUM_NONE;
> +       }
> +
> +       return 0;
> +}
> +
This should now just call iptunnel_handle_offloads with maybe setting
type to be SKB_GSO_UDP_TUNNEL_CSUM. See vxlan.c and my patches to
support UDP tunnels with csums.

> +       /* If the NIC driver gave us an encapsulated packet
> +        * with the encapsulation mark, the device checksummed it
> +        * for us. Otherwise force the upper layers to verify it.
> +        */
> +       if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL) ||
> +           !skb->encapsulation)
> +               skb->ip_summed = CHECKSUM_NONE;
> +
Checksum validation for UDP tunnels is now done in UDP so this should
be unnecessary.
