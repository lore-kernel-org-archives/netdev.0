From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] arp: avoid sending ucast probes to
 00:00:00:00:00:00
Date: Thu, 01 Dec 2016 16:17:15 -0800
Message-ID: <1480637835.18162.353.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480632994-12128-1-git-send-email-mahesh@bandewar.net>
         <1480634129.18162.350.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAF2d9jgQFxRFxvGSZ9vaswe27TvEY2Y-D8E1J279-gXLGfO-xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: Mahesh Bandewar
         =?UTF-8?Q?=28=E0=A4=AE=E0=A4=B9=E0=A5=87=E0=A4=B6_?=
         =?UTF-8?Q?=E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE?=
         =?UTF-8?Q?=E0=A4=B0=29?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34915 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752680AbcLBASS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 19:18:18 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so6062582pga.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 16:18:17 -0800 (PST)
In-Reply-To: <CAF2d9jgQFxRFxvGSZ9vaswe27TvEY2Y-D8E1J279-gXLGfO-xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 15:47 -0800, Mahesh Bandewar (महेश बंडेवार) wrote:
> [...]
> >> @@ -371,10 +372,12 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
> >>
> >>       probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES);
> >>       if (probes < 0) {
> >> +             memset(&null_dev_hw_addr, 0, dev->addr_len);
> >>               if (!(neigh->nud_state & NUD_VALID))
> >>                       pr_debug("trying to ucast probe in NUD_INVALID\n");
> >>               neigh_ha_snapshot(dst_ha, neigh, dev);
> >> -             dst_hw = dst_ha;
> >> +             if (memcmp(&dst_ha, &null_dev_hw_addr, dev->addr_len) != 0)
> >> +                     dst_hw = dst_ha;
> >>       } else {
> >>               probes -= NEIGH_VAR(neigh->parms, APP_PROBES);
> >>               if (probes < 0) {
> >
> > Why is is an IPv4 specific issue ?
> I think the issue is that neigh_ha_snapshot() gets neigh->ha
> unconditionally even if the neigh state is NUD_INVALID.
> 
> > What about IPv6 ?
> Well it's not ARP. The ndisc_solicit() calls ndisc_send_ns() with
> neigh parameter for unicast probe while call with NULL for the
> broadcast probe case. However it does not use this parameter in
> unicast case and probably relies on the route-entry. Hence it is not
> subjected to the same issue.

Well, it looks like the issue is in neighbour code.

Fact that IPv6 might not be impacted is not the point.



> >
> >
> > I would try something in neighbour code, maybe :
> >
> > diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> > index 782dd866366554e53dda3e6c69c807ec90bd0e08..fdfb177eecb6a9b1479eedde457cb1f652d32c68 100644
> > --- a/net/core/neighbour.c
> > +++ b/net/core/neighbour.c
> > @@ -916,7 +916,10 @@ static void neigh_timer_handler(unsigned long arg)
> >                         neigh_dbg(2, "neigh %p is probed\n", neigh);
> >                         neigh->nud_state = NUD_PROBE;
> >                         neigh->updated = jiffies;
> > -                       atomic_set(&neigh->probes, 0);
> > +                       atomic_set(&neigh->probes,
> > +                                  (neigh->output == neigh_blackhole) ?
> > +                                       NEIGH_VAR(neigh->parms, UCAST_PROBES) :
> > +                                       0);
> This would work if we change the above line (in arp_solicit() code)
> from 'if (probes < 0)' to 'if (probes <= 0)'.

Then code at line 973 is wrong ?

atomic_set(&neigh->probes,
           NEIGH_VAR(neigh->parms, UCAST_PROBES));

That would be a more serious issue :)
