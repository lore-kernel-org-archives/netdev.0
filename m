From: Eli Cooper <elicooper@gmx.com>
Subject: Re: [PATCH v2] ip6_tunnel: Clear IP6CB in ip6_tnl_xmit() after
 encapsulation
Date: Fri, 28 Oct 2016 13:13:45 +0800
Message-ID: <9a1bb72b-246d-021a-236c-f523832964ac@gmx.com>
References: <20161028015241.23258-1-elicooper@gmx.com>
 <CALx6S36O_MUQw4vWKUoW-ZgCTg9PJrPjNHwuEWTDG9t=BxQv3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:57885 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751401AbcJ1FOF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 01:14:05 -0400
In-Reply-To: <CALx6S36O_MUQw4vWKUoW-ZgCTg9PJrPjNHwuEWTDG9t=BxQv3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/10/28 10:17, Tom Herbert wrote:
> On Thu, Oct 27, 2016 at 6:52 PM, Eli Cooper <elicooper@gmx.com> wrote:
>> > skb->cb may contain data from previous layers. In the observed scenario,
>> > the garbage data were misinterpreted as IP6CB(skb)->frag_max_size, so
>> > that small packets sent through the tunnel are mistakenly fragmented.
>> >
>> > This patch clears the control buffer for the next layer, after an IPv6
>> > header is installed.
>> >
> Nice catch, but can you rectify this with what udp_tunnel6_xmit_skb is
> doing. udp_tunnel6_xmit_skb calls ip6tunnel_xmit directly. Looks like
> we do
>
> memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED
>                             | IPSKB_REROUTED);
>
> Is this what we should be doing in ip6_tnl_xmit also, or is
> udp_tunnel6_xmit_skb broken because it doesn't zero all the cb?

udp_tunnel6_xmit_skb() is also broken, I can confirm. Actually I found
it pretty easy to reproduce by having a netns or router forwarding
between two tunnels established with another two namespaces or hosts.
The router sends out packets with IPv6 Fragment headers, even when the
packet is too small to really get fragmented.

The control buffer, by definition, is private to the layer having the
skb queued at the moment. As David has pointed out in v1 of this patch,
cb is either interpreted as IPCB or as IP6CB, and in this case, it will
be IP6CB after ip6tunnel_xmit(). So I think it is best that all the
IP6CB gets cleared before it is pushed to the next layer. Maybe we
should clear IP6CB in ip6tunnel_xmit(), rather than in every tunnel's codes?

By the way, I don't see any point in setting IPCB(skb)->flags in
udp_tunnel6_xmit_skb(). It will not be interpreted as IPCB any further
past ip6tunnel_xmit(), even if it were not cleared. Plus, nothing seems
to use these flags anyway.

Thanks,
Eli
