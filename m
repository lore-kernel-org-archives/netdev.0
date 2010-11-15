From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: network device reference leak with net-next
Date: Tue, 16 Nov 2010 00:25:43 +0100
Message-ID: <1289863543.3364.24.camel@edumazet-laptop>
References: <20101115105646.0cc823ce@nehalam>
	 <1289847840.2607.120.camel@edumazet-laptop>
	 <20101115111024.3b3377be@nehalam>  <4CE1BFCE.70105@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, lorenzo@google.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	brian.haley@hp.com, maze@google.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:62461 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758111Ab0KOXZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 18:25:51 -0500
Received: by wwi18 with SMTP id 18so34738wwi.1
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 15:25:49 -0800 (PST)
In-Reply-To: <4CE1BFCE.70105@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 novembre 2010 =C3=A0 15:18 -0800, John Fastabend a =C3=A9cr=
it :
> On 11/15/2010 11:10 AM, Stephen Hemminger wrote:
> > On Mon, 15 Nov 2010 20:04:00 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> >> Le lundi 15 novembre 2010 =C3=A0 10:56 -0800, Stephen Hemminger a =
=C3=A9crit :
> >>> This is a new regression (doesn't exist with 2.6.36)
> >>>
> >>> If I shutdown KVM instance with Virt manager, the virtual
> >>> interfaces in the bridge aren't getting cleaned up because
> >>> of leftover reference count.
> >>>
> >>>
> >>> [ 9781.050474] unregister_netdevice: waiting for vnet1 to become =
free. Usage count =3D 1
> >>> [ 9785.143400] virbr4: port 3(vnet6) entering forwarding state
> >>> [ 9785.177194] virbr4: port 3(vnet6) entering disabled state
> >>> [ 9785.201129] device vnet6 left promiscuous mode
> >>> [ 9785.201135] virbr4: port 3(vnet6) entering disabled state
> >>> [ 9791.286950] unregister_netdevice: waiting for vnet1 to become =
free. Usage count =3D 1
> >>> [ 9795.461526] unregister_netdevice: waiting for vnet6 to become =
free. Usage count =3D 1
> >>> [ 9801.523398] unregister_netdevice: waiting for vnet1 to become =
free. Usage count =3D 1
> >>> --
> >>
> >> Is the refcount stay forever to 1, or eventually reaches 0 ?
> >>
> >>
> >>
> >=20
> > Stays 1 for as long as I waited about 10 minutes
> >=20
>=20
> Similar refcount error with ixgbe bisected to this patch,
>=20
> commit 2de795707294972f6c34bae9de713e502c431296
> Author: Lorenzo Colitti <lorenzo@google.com>
> Date:   Wed Oct 27 18:16:49 2010 +0000
>=20
>     ipv6: addrconf: don't remove address state on ifdown if the addre=
ss is being kept
>=20
>     Currently, addrconf_ifdown does not delete statically configured =
IPv6
>     addresses when the interface is brought down. The intent is that =
when
>     the interface comes back up the address will be usable again. How=
ever,
>     this doesn't actually work, because the system stops listening on=
 the
>     corresponding solicited-node multicast address, so the address ca=
nnot
>     respond to neighbor solicitations and thus receive traffic. Also,=
 the
>     code notifies the rest of the system that the address is being de=
leted
>     (e.g, RTM_DELADDR), even though it is not. Fix it so that none of=
 this
>     state is updated if the address is being kept on the interface.
>=20
>     Tested: Added a statically configured IPv6 address to an interfac=
e,
>     started ping, brought link down, brought link up again. When link=
 came
>     up ping kept on going and "ip -6 maddr" showed that the host was =
still
>     subscribed to there
>=20
>     Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
>=20
> Quick glance looks like an in6_ifa_put is missed?
>=20
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2754,13 +2754,13 @@ Hunk #1, a/net/ipv6/addrconf.c static int add=
rconf_ifdown(struct net_device *dev, int how)
>                         ifa->state =3D INET6_IFADDR_STATE_DEAD;
>                         spin_unlock_bh(&ifa->state_lock);
>=20
> -                       if (state =3D=3D INET6_IFADDR_STATE_DEAD) {
> -                               in6_ifa_put(ifa);
> -                       } else {
> +                       if (state !=3D INET6_IFADDR_STATE_DEAD) {
>                                 __ipv6_ifa_notify(RTM_DELADDR, ifa);
>                                 atomic_notifier_call_chain(&inet6addr=
_chain,
>                                                            NETDEV_DOW=
N, ifa);
>                         }
> +
> +                       in6_ifa_put(ifa);
>                         write_lock_bh(&idev->lock);
>                 }
>         }
>=20
> With a quick hack the above seems to resolve the issue but I'll need =
to review the ipv6 stuff to be sure this is sane.
>=20
> Thanks,
> John.

Your machine is faster than mine ;)

Yes this commit seems buggy, thanks for finding the problem !



