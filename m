From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6 tunnels
Date: Wed, 3 Sep 2003 13:17:56 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309031232010.5039-100000@rhea.tcs.hut.fi>
References: <20030903.063705.89449634.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Cc: davem@redhat.com, <pekkas@netcore.fi>, <usagi-core@linux-ipv6.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030903.063705.89449634.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> In article <20030902043534.05fc6586.davem@redhat.com> (at Tue, 2 Sep 2003 04:35:34 -0700), "David S. Miller" <davem@redhat.com> says:
>
> > On Mon, 1 Sep 2003 17:24:42 +0300 (EEST)
> > Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:
> >
> > > Ok, this incremental patch to my previous addrconf.c patch generates a
> > > link-local address to the IPv6 tunnel device. It first tries to inherit
> > > the EUI64 identifier of some other device and if this fails, uses a
> > > random interface id.
> >
> > Yoshfuji, do you mind if I apply his patch 5 and "5/5+1"?
>
> Well, I have a question and a comment.
>
>         if (ifp->idev->cnf.forwarding == 0 &&
>             (dev->flags&IFF_LOOPBACK) == 0 &&
> +           dev->type != ARPHRD_TUNNEL6 &&
>             (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
>                 struct in6_addr all_routers;
>
> Why?

The other end of the tunnel might not yet be set up to receive the packet,
which causes an ICMP error message to be sent back to the sender.

Besides, RS and RA over a ipv6-in-ipv6 tunnel is a _bad_ idea. A default
route through a tunnel without more advanced (policy/flow/srcaddr/? based)
routing schemes can lead to local routing loops.

Come to think of it a more elegant solution might be:

        if (ifp->idev->cnf.forwarding == 0 &&
            (dev->flags&IFF_LOOPBACK) == 0 &&
+           ifp->idev->cnf.rtr_solicits > 0 &&
            (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
                struct in6_addr all_routers;

and set both idev->cnf.rtr_solicits = 0 and idev->cnf.accept_ra = 0 for
ARPHRD_TUNNEL6 devices

> Comment: this strategy is the "default."
> We can (or even should) do this stretegy whenever we failed to
> ipv6_generate_eui64() in addrconf_dev_config().

Should I send a separate patch to enable the random interface ids in
addrconf_dev_config()?

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
