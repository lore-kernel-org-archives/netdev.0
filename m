From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net,stable] net: cdc_mbim: __vlan_find_dev_deep need
 rcu_read_lock
Date: Fri, 02 May 2014 14:57:41 -0700
Message-ID: <1399067861.2140.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399066111-22803-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Suarez <gsuarez@smithmicro.com>,
	Oliver Neukum <oliver@neukum.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:44750 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbaEBV5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 17:57:43 -0400
In-Reply-To: <1399066111-22803-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-02 at 23:28 +0200, Bj=C3=B8rn Mork wrote:
> Fixes this warning introduced by commit 5b8f15f78e6f
> ("net: cdc_mbim: handle IPv6 Neigbor Solicitations"):
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [ INFO: suspicious RCU usage. ]
> 3.15.0-rc3 #213 Tainted: G        W  O
> -------------------------------
> net/8021q/vlan_core.c:69 suspicious rcu_dereference_check() usage!
>=20
> other info that might help us debug this:
>=20
> rcu_scheduler_active =3D 1, debug_locks =3D 1
> no locks held by ksoftirqd/0/3.
>=20
> stack backtrace:
> CPU: 0 PID: 3 Comm: ksoftirqd/0 Tainted: G        W  O  3.15.0-rc3 #2=
13
> Hardware name: LENOVO 2776LEG/2776LEG, BIOS 6EET55WW (3.15 ) 12/19/20=
11
>  0000000000000001 ffff880232533bf0 ffffffff813a5ee6 0000000000000006
>  ffff880232530090 ffff880232533c20 ffffffff81076b94 0000000000000081
>  0000000000000000 ffff8802085ac000 ffff88007fc8ea00 ffff880232533c50
> Call Trace:
>  [<ffffffff813a5ee6>] dump_stack+0x4e/0x68
>  [<ffffffff81076b94>] lockdep_rcu_suspicious+0xfa/0x103
>  [<ffffffff813978a6>] __vlan_find_dev_deep+0x54/0x94
>  [<ffffffffa04a1938>] cdc_mbim_rx_fixup+0x379/0x66a [cdc_mbim]
>  [<ffffffff813ab76f>] ? _raw_spin_unlock_irqrestore+0x3a/0x49
>  [<ffffffff81079671>] ? trace_hardirqs_on_caller+0x192/0x1a1
>  [<ffffffffa059bd10>] usbnet_bh+0x59/0x287 [usbnet]
>  [<ffffffff8104067d>] tasklet_action+0xbb/0xcd
>  [<ffffffff81040057>] __do_softirq+0x14c/0x30d
>  [<ffffffff81040237>] run_ksoftirqd+0x1f/0x50
>  [<ffffffff8105f13e>] smpboot_thread_fn+0x172/0x18e
>  [<ffffffff8105efcc>] ? SyS_setgroups+0xdf/0xdf
>  [<ffffffff810594b0>] kthread+0xb5/0xbd
>  [<ffffffff813a84b1>] ? __wait_for_common+0x13b/0x170
>  [<ffffffff810593fb>] ? __kthread_parkme+0x5c/0x5c
>  [<ffffffff813b147c>] ret_from_fork+0x7c/0xb0
>  [<ffffffff810593fb>] ? __kthread_parkme+0x5c/0x5c
>=20
> Fixes: 5b8f15f78e6f ("net: cdc_mbim: handle IPv6 Neigbor Solicitation=
s")
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
> Please add this to the stable v3.13 and v3.14 queues as well.  Thanks=
=2E
>=20
>=20
>  drivers/net/usb/cdc_mbim.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
> index c9f3281506af..34b5c5cc27ed 100644
> --- a/drivers/net/usb/cdc_mbim.c
> +++ b/drivers/net/usb/cdc_mbim.c
> @@ -204,13 +204,16 @@ static void do_neigh_solicit(struct usbnet *dev=
, u8 *buf, u16 tci)
>  		return;
> =20
>  	/* need to send the NA on the VLAN dev, if any */
> -	if (tci)
> +	if (tci) {
> +		rcu_read_lock();
>  		netdev =3D __vlan_find_dev_deep(dev->net, htons(ETH_P_8021Q),
> -					      tci);
> -	else
> +					      tci & VLAN_VID_MASK);
> +		rcu_read_unlock();
> +		if (!netdev)
> +			return;
> +	} else {
>  		netdev =3D dev->net;
> -	if (!netdev)
> -		return;
> +	}
> =20
>  	in6_dev =3D in6_dev_get(netdev);
>  	if (!in6_dev)


While this 'removes' the warning, this doesn't solve the fundamental
problem.

If you write :

rcu_read_lock();
netdev =3D __vlan_find_dev_deep(...)
rcu_read_unlock();

Then you cannot dereference netdev safely after the unlock.

In order to do so, you need to take a reference on netdev (aka
dev_hold()) before doing rcu_read_unlock();

And of course, release it later (aka dev_put()) when you are done with
netdev.
