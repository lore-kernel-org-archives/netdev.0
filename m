From: Lance Richardson <lrichard@redhat.com>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Mon, 28 Nov 2016 12:54:07 -0500 (EST)
Message-ID: <1428298236.4223309.1480355647336.JavaMail.zimbra@redhat.com>
References: <20161125120947.142c3af5@canb.auug.org.au> <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com> <20161125134520.68ca0969@canb.auug.org.au> <alpine.DEB.2.20.1611250503250.22094@aurora.sdinet.de> <20161127142340.3a5c197e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sven-Haegar Koch <haegar@sdinet.de>,
        Eli Cooper <elicooper@gmx.com>, netdev@vger.kernel.org,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:42173 "EHLO
        mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbcK1RyY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:54:24 -0500
In-Reply-To: <20161127142340.3a5c197e@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Stephen Rothwell" <sfr@canb.auug.org.au>
> To: "Sven-Haegar Koch" <haegar@sdinet.de>
> Cc: "Eli Cooper" <elicooper@gmx.com>, netdev@vger.kernel.org, "Eric Dumazet" <eric.dumazet@gmail.com>
> Sent: Saturday, November 26, 2016 10:23:40 PM
> Subject: Re: Large performance regression with 6in4 tunnel (sit)
> 
> Hi Sven-Haegar,
> 
> On Fri, 25 Nov 2016 05:06:53 +0100 (CET) Sven-Haegar Koch <haegar@sdinet.de>
> wrote:
> >
> > Somehow this problem description really reminds me of a report on
> > netdev a bit ago, which the following patch fixed:
> > 
> > commit 9ee6c5dc816aa8256257f2cd4008a9291ec7e985
> > Author: Lance Richardson <lrichard@redhat.com>
> > Date:   Wed Nov 2 16:36:17 2016 -0400
> > 
> >     ipv4: allow local fragmentation in ip_finish_output_gso()
> >     
> >     Some configurations (e.g. geneve interface with default
> >     MTU of 1500 over an ethernet interface with 1500 MTU) result
> >     in the transmission of packets that exceed the configured MTU.
> >     While this should be considered to be a "bad" configuration,
> >     it is still allowed and should not result in the sending
> >     of packets that exceed the configured MTU.
> > 
> > Could this be related?
> > 
> > I suppose it would be difficult to test this patch on this machine?
> 
> The kernel I am running on is based on 4.7.8, so the above patch
> doesn't come close to applying. Most fo what it is reverting was
> introduced in commit 359ebda25aa0 ("net/ipv4: Introduce IPSKB_FRAG_SEGS
> bit to inet_skb_parm.flags") in v4.8-rc1.
> 
> --
> Cheers,
> Stephen Rothwell
> 

This should be equivalent for 4.7.x:

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4bd4921..8a253e2 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -224,8 +224,7 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
        int ret = 0;
 
        /* common case: locally created skb or seglen is <= mtu */
-       if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
-             skb_gso_network_seglen(skb) <= mtu)
+       if (skb_gso_network_seglen(skb) <= mtu)
                return ip_finish_output2(net, sk, skb);
 
        /* Slowpath -  GSO segment length is exceeding the dst MTU.
