From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH v2] ip6_tunnel: Clear IP6CB in ip6_tnl_xmit() after
 encapsulation
Date: Fri, 28 Oct 2016 19:07:57 +0300
Message-ID: <20161028190757.26be756c@halley>
References: <20161028015241.23258-1-elicooper@gmx.com>
        <CALx6S36O_MUQw4vWKUoW-ZgCTg9PJrPjNHwuEWTDG9t=BxQv3w@mail.gmail.com>
        <9a1bb72b-246d-021a-236c-f523832964ac@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>
To: Eli Cooper <elicooper@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38573 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756354AbcJ1QIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 12:08:11 -0400
Received: by mail-wm0-f42.google.com with SMTP id n67so124199273wme.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 09:08:10 -0700 (PDT)
In-Reply-To: <9a1bb72b-246d-021a-236c-f523832964ac@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 28 Oct 2016 13:13:45 +0800 Eli Cooper <elicooper@gmx.com> wrote:
> So I think it is best that all the
> IP6CB gets cleared before it is pushed to the next layer.

Just a comparison to the ipv4 world:

All tunnels (udp/ip based) end up calling iptunnel_xmit(), which:
 - scrubs the skb
 - clears any IPCB residues
 - installs the iphdr
 - invokes ip_local_out()

OTOH ip6_tnl_xmit:
 - scrubs the skb
 - installs the ipv6hdr
 - invokes ip6tunnel_xmit() - a thin wrapper to ip6_local_out()
 * missing: clearing cb

And OTOH udp_tunnel6_xmit_skb:
 - clears IPCB(skb)->opt and some IPCB(skb)->flags
   (why these 2 explicitly? and why at this point? and IPCB is no longer
    relevant...)
 - installs the ipv6hdr
 - invokes ip6tunnel_xmit() - a thin wrapper to ip6_local_out()
 * missing: scrub, clearing cb

> Maybe we
> should clear IP6CB in ip6tunnel_xmit(), rather than in every tunnel's codes?

This seems reasonable.

A potential issue might be whether it needs to be done earlier, although
I've reviewed current versions of both 'ip6_tnl_xmit' and
'udp_tunnel6_xmit_skb' and it looks okay. But please verify.

> By the way, I don't see any point in setting IPCB(skb)->flags in
> udp_tunnel6_xmit_skb(). It will not be interpreted as IPCB any further
> past ip6tunnel_xmit(), even if it were not cleared. Plus, nothing seems
> to use these flags anyway.

This seems right.

It was introduced in 6a93cc9052 "udp-tunnel: Add a few more UDP tunnel APIs".

If you checkout that tree, you'll notice same treatment to
IPCB(skb)->opt and IPCB(skb)->flags in l2tp_xmit_skb... maybe it was
just copied ;-)

Best,
Shmulik
