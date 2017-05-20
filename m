From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next] geneve: always fill CSUM6_RX configuration
Date: Sat, 20 May 2017 09:35:03 -0400
Message-ID: <20170520133503.GM9969@rhel7>
References: <20170518195956.12686-1-e@erig.me>
 <CAOrHB_CKLgriV3XjG1fBHvyB9GQQ3GXOT8+ggmtLXFz3cvj56Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752929AbdETNfG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 May 2017 09:35:06 -0400
Content-Disposition: inline
In-Reply-To: <CAOrHB_CKLgriV3XjG1fBHvyB9GQQ3GXOT8+ggmtLXFz3cvj56Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 06:57:46PM -0700, Pravin Shelar wrote:
> On Thu, May 18, 2017 at 12:59 PM, Eric Garver <e@erig.me> wrote:
> > CSMU6_RX is relevant for collect_metadata as well. As such leave it
> > outside of the dev's IPv4/IPv6 checks.
> >
> Can you explain it bit? is this flag used with ipv4 tunnels?

It's used with collect_metadata as both ipv4 and ipv6 sockets will be
created.

openvswitch recently gained support for creating tunnels with rtnetlink.
It sets COLLECT_METADATA and CSUM6_RX. After create, it does a get to
verify the device got created with all the requested configuration. The
verify was failing due to CSUM6_RX not being returned.

Since ip_tunnel_info_af() defaults to returning AF_INET, we fall into
the IPv4 case and CSUM6_RX is never returned. Other relevant areas that
call ip_tunnel_info_af() do so using the info from the skb, not the
geneve_dev.

I hope that made it clear. Thanks for taking a look.

Eric.

> > Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> > Signed-off-by: Eric Garver <e@erig.me>
> > ---
> >  drivers/net/geneve.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> > index dec5d563ab19..f557d1dc3f9b 100644
> > --- a/drivers/net/geneve.c
> > +++ b/drivers/net/geneve.c
> > @@ -1311,13 +1311,13 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
> >                 if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
> >                                !(info->key.tun_flags & TUNNEL_CSUM)))
> >                         goto nla_put_failure;
> > -
> > -               if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
> > -                              !geneve->use_udp6_rx_checksums))
> > -                       goto nla_put_failure;
> >  #endif
> >         }
> >
> > +       if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
> > +                      !geneve->use_udp6_rx_checksums))
> > +               goto nla_put_failure;
> > +
> >         if (nla_put_u8(skb, IFLA_GENEVE_TTL, info->key.ttl) ||
> >             nla_put_u8(skb, IFLA_GENEVE_TOS, info->key.tos) ||
> >             nla_put_be32(skb, IFLA_GENEVE_LABEL, info->key.label))
> > --
> > 2.12.0
> >
