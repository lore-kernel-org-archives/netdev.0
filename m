From: Timo Teras <timo.teras@iki.fi>
Subject: Re: ip_tunnel mtu calculation
Date: Sun, 30 Jun 2013 10:46:53 +0300
Message-ID: <20130630104653.2717bfde@vostro>
References: <20130629175701.73c17a16@vostro>
	<CALnjE+pTXGwhePigZRyfVORkgbpwRDF1hTBRnR24fcsqvsP9ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:64587 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab3F3Hqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 03:46:46 -0400
Received: by mail-ea0-f171.google.com with SMTP id m14so1498084eaj.30
        for <netdev@vger.kernel.org>; Sun, 30 Jun 2013 00:46:43 -0700 (PDT)
In-Reply-To: <CALnjE+pTXGwhePigZRyfVORkgbpwRDF1hTBRnR24fcsqvsP9ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Jun 2013 21:36:39 -0700
Pravin Shelar <pshelar@nicira.com> wrote:

> On Sat, Jun 29, 2013 at 7:57 AM, Timo Teras <timo.teras@iki.fi> wrote:
> > Hi,
> >
> > I'm reviewing changes since 3.9 to net-next and observed that, the
> > tunnel refactoring had the following change in ip_gre xmit path.
> >
> > In ip_tunnel_xmit() mtu is now calculated as:
> >         if (df)
> >                 mtu = dst_mtu(&rt->dst) - dev->hard_header_len
> >                                         - sizeof(struct iphdr);
> >         else
> >                 mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) :
> > dev->mtu;
> >
> > And it used to be in ip_gre.c: ipgre_tunnel_xmit():
> >         if (df)
> >                 mtu = dst_mtu(&rt->dst) - dev->hard_header_len -
> > tunnel->hlen; else
> >                 mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) :
> > dev->mtu;
> >
> > I notice that tunnel->hlen is replaced with sizeof(struct iphdr),
> > but in case of GRE those are not the same thing. And the refactored
> > ip_gre.c does not set hard_header_len either. So it would like the
> > mtu is now miscalculated (planning to give a full test-spin for
> > net-next next week).
> >
> > It seems the tunnel->hlen used to be the full length, including
> > sizeof(struct iphdr).
> >
> > But the new, refactored code seems exclude sizeof(struct iphdr) from
> > the tunnel->hlen. So would the following be appropriate?
> >
> This is ip-tunnel layer, skb has gre header pushed. so mtu does not
> need to account gre header when compared to skb->len.
>
> But I missed one comparison for mtu check where iph->tot-len is used
> rather that skb-len, which is correct length.
>
> gre module is using iph->tot_len for pmtu check which is wrong for
> gre-tap device. This bug is there even before restructuring.
> I will send out patch for ip-tunnels code for now.

This fixes only the first part of the problem.

The mtu is sent out few lines below as ICMP message. That MTU needs to
contain also the tunnel header's length. Other wise the remote gets
wrong impression of path mtu.

- Timo
