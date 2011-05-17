From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net: add rcu protection to netdev->ifalias
Date: Tue, 17 May 2011 15:25:03 -0700
Message-ID: <20110517152503.2f7244f3@nehalam>
References: <1303980967.3360.60.camel@edumazet-laptop>
	<20110428084337.6b54603e@nehalam>
	<20110502.152733.48516094.davem@davemloft.net>
	<1305670692.6741.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40264 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756632Ab1EQWZH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 18:25:07 -0400
In-Reply-To: <1305670692.6741.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 May 2011 00:18:12 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 02 mai 2011 =C3=A0 15:27 -0700, David Miller a =C3=A9crit :
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Thu, 28 Apr 2011 08:43:37 -0700
> >=20
> > > On Thu, 28 Apr 2011 10:56:07 +0200
> > > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > >=20
> > >> Four years ago, Patrick made a change to hold rtnl mutex during =
netlink
> > >> dump callbacks.
> > >>=20
> > >> I believe it was a wrong move. This slows down concurrent dumps,=
 making
> > >> good old /proc/net/ files faster than rtnetlink in some situatio=
ns.
> > >>=20
> > >> This occurred to me because one "ip link show dev ..." was _very=
_ slow
> > >> on a workload adding/removing network devices in background.
> > >>=20
> > >> All dump callbacks are able to use RCU locking now, so this patc=
h does
> > >> roughly a revert of commits :
> > >>=20
> > >> 1c2d670f366 : [RTNETLINK]: Hold rtnl_mutex during netlink dump c=
allbacks
> > >> 6313c1e0992 : [RTNETLINK]: Remove unnecessary locking in dump ca=
llbacks
> > >>=20
> > >> This let writers fight for rtnl mutex and readers going full spe=
ed.
> > >>=20
> > >> It also takes care of phonet : phonet_route_get() is now called =
from rcu
> > >> read section. I renamed it to phonet_route_get_rcu()
> > >>=20
> > >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > >> Cc: Patrick McHardy <kaber@trash.net>
> > >> Cc: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> > >=20
> > > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > Applied, thanks everyone!
>=20
> I think we probably have to make some fixes, because rtnl_fill_ifinfo=
()
> can access fields that were previously protected with RTNL
>=20
> Let's see if it's doable, before considering re-adding rtnl_lock() in
> rtnl_dump_ifinfo() ?
>=20
> First step : dev->ifalias
>=20
> Its late here, I'll continue the work tomorrow.
>=20
> Thanks
>=20
> [PATCH net-next-2.6] net: add rcu protection to netdev->ifalias
>=20
> Avoid holding RTNL in show_ifalias() and rtnl_fill_ifinfo() to
> manipulate netdev->ifalias
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I am beginning to think the idea of optimizing case of "ip link show"
running in background with adding/removing network devices is silly.=20
And switching to RCU leads to all sorts of corner cases where only
partial data will be read. Is it really worth it?

