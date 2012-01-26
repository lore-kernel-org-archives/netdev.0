From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] caif: Fix crash due to uninitialized net name-space.
Date: Thu, 26 Jan 2012 07:14:18 +0100
Message-ID: <1327558458.2605.23.camel@edumazet-laptop>
References: <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
	 <1327523631-3480-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: levinsasha928@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	davej@redhat.com, sjurbren@gmail.com
To: Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42852 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab2AZGOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 01:14:24 -0500
In-Reply-To: <1327523631-3480-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 21:33 +0100, Sjur Br=C3=A6ndeland a =
=C3=A9crit :
> net_generic() calls BUG_ON() if called with uninitialized
> network name-space. Add check if net is initialized before
> calling net_generic(). This fixes the following oops:
>=20
> [  200.752016] kernel BUG at include/net/netns/generic.h:40!
> ...
> [  200.752016]  [<ffffffff825c3cea>] ? get_cfcnfg+0x3a/0x180
> [  200.752016]  [<ffffffff821cf0b0>] ? lockdep_rtnl_is_held+0x10/0x20
> [  200.752016]  [<ffffffff825c41be>] caif_device_notify+0x2e/0x530
> [  200.752016]  [<ffffffff810d61b7>] notifier_call_chain+0x67/0x110
> [  200.752016]  [<ffffffff810d67c1>] raw_notifier_call_chain+0x11/0x2=
0
> [  200.752016]  [<ffffffff821bae82>] call_netdevice_notifiers+0x32/0x=
60
> [  200.752016]  [<ffffffff821c2b26>] register_netdevice+0x196/0x300
> [  200.752016]  [<ffffffff821c2ca9>] register_netdev+0x19/0x30
> [  200.752016]  [<ffffffff81c1c67a>] loopback_net_init+0x4a/0xa0
> [  200.752016]  [<ffffffff821b5e62>] ops_init+0x42/0x180
> [  200.752016]  [<ffffffff821b600b>] setup_net+0x6b/0x100
> [  200.752016]  [<ffffffff821b6466>] copy_net_ns+0x86/0x110
> [  200.752016]  [<ffffffff810d5789>] create_new_namespaces+0xd9/0x190
>=20
> Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
> Tested-by: Sasha Levin <levinsasha928@gmail.com>
>=20
> ---
>=20
> Hi Sasha and Dave,
>=20
> [Sasha]
> >Works for me.
> Thank you Sasha for reporting this bug and testing my patch,
> I appreciate it.
>=20
> [Dave]
> >Please post all networking patches CC:'d
> Sorry, I missed the obvious.
> I'm resending the same patch as yesterday, this time to:netdev
> and with "Tested-by: Sasha". Please apply to net.
>=20
> Thanks,
> Sjur
>=20
>  net/caif/caif_dev.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
> index 673728a..6110ade 100644
> --- a/net/caif/caif_dev.c
> +++ b/net/caif/caif_dev.c
> @@ -371,6 +371,14 @@ static int caif_device_notify(struct notifier_bl=
ock *me, unsigned long what,
>  	struct cflayer *layer, *link_support;
>  	int head_room =3D 0;
>  	struct caif_device_entry_list *caifdevs;
> +	int len;
> +
> +	rcu_read_lock();
> +	len =3D rcu_dereference(dev_net(dev)->gen)->len;
> +	rcu_read_unlock();
> +
> +	if (caif_net_id =3D=3D 0 || caif_net_id > len)
> +		return 0;
> =20
>  	cfg =3D get_cfcnfg(dev_net(dev));
>  	caifdevs =3D caif_device_list(dev_net(dev));

This looks wrong.

This should not be needed, something is broken elsewhere.
