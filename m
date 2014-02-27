From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] net-gre-gro: Fix a bug that breaks the forwarding path
Date: Thu, 27 Feb 2014 15:39:47 -0800
Message-ID: <CAPshTCgLo8ycMTtoa+D14+7pPxJaiC-jUzyR3PJcrMKFw9V0zA@mail.gmail.com>
References: <1393536377-32243-1-git-send-email-hkchu@google.com>
	<CAJZOPZKy7w-q5+pp=FgCs8LdQL6e16zAiJr89VMkh+h7obAArg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:37498 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaB0Xjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 18:39:48 -0500
Received: by mail-yh0-f42.google.com with SMTP id a41so3622261yho.1
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 15:39:48 -0800 (PST)
In-Reply-To: <CAJZOPZKy7w-q5+pp=FgCs8LdQL6e16zAiJr89VMkh+h7obAArg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 27, 2014 at 2:25 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>
> On Thu, Feb 27, 2014 at 11:26 PM, H.K. Jerry Chu <hkchu@google.com> wrote:
> > From: Jerry Chu <hkchu@google.com>
> >
> > I stumbled across a bug that was introduced by my own GRE-GRO
> > patch (bf5a755f5e9186406bbf50f4087100af5bd68e40
> > net-gre-gro: Add GRE support to the GRO stack) submitted a while
> > back that breaks the forwarding path because various GSO related
> > fields were not set. This will cause on the egress path either
> > the GSO code to fail, or a GRE-TSO capable (NETIF_F_GSO_GRE)
> > NICs to choke. The following fix has been tested for both cases.
> >
> > Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
> > ---
> >  net/core/dev.c           | 2 ++
> >  net/ipv4/af_inet.c       | 3 +++
> >  net/ipv4/gre_offload.c   | 3 +++
> >  net/ipv4/tcp_offload.c   | 2 +-
> >  net/ipv6/tcpv6_offload.c | 2 +-
> >  5 files changed, 10 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index b1b0c8d..75517d8 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4045,6 +4045,8 @@ static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
> >         skb->vlan_tci = 0;
> >         skb->dev = napi->dev;
> >         skb->skb_iif = 0;
> > +       skb->encapsulation = 0;
> > +       skb_shinfo(skb)->gso_type = 0;
> >
> >         napi->skb = skb;
> >  }
> > diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> > index ecd2c3f..68229ca 100644
> > --- a/net/ipv4/af_inet.c
> > +++ b/net/ipv4/af_inet.c
> > @@ -1431,6 +1431,9 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
> >         int proto = iph->protocol;
> >         int err = -ENOSYS;
> >
> > +       if (skb->encapsulation)
> > +               skb_set_inner_network_header(skb, nhoff);
> > +
>
> Note that packets (e.g those who are UDP encapsulated) will pass here
> twice, once for the external IP header and once for the internal, so
> if the driver marks the encapsulation sign the inner header setting
> will happen twice, is that what we want?

The inner most hdr will be the last to set. But I don't know
all the rules regarding skb->encapsulation. E.g., in this patch
napi_reuse_skb() will reset skb->encapsulation. If that's problematic
then I could call skb_set_inner_network_header() inside gre_gro_receive()
(but that will require checking against "type" in order to compute the right
offset).

Jerry

>
>
> >         csum_replace2(&iph->check, iph->tot_len, newlen);
> >         iph->tot_len = newlen;
