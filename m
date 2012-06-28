From: Tom Parkin <tparkin@katalix.com>
Subject: Re: LOCKDEP complaints in l2tp_xmit_skb()
Date: Thu, 28 Jun 2012 15:33:02 +0100
Message-ID: <20120628143302.GB2507@raven>
References: <20120627111152.GA2531@raven>
 <1340866572.26242.312.camel@edumazet-glaptop>
 <1340873862.13187.5.camel@edumazet-glaptop>
 <1340882551.13187.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Fba/0zbH8Xs+Fj9o"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40921 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752276Ab2F1OdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2012 10:33:09 -0400
Content-Disposition: inline
In-Reply-To: <1340882551.13187.96.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Fba/0zbH8Xs+Fj9o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 28, 2012 at 01:22:31PM +0200, Eric Dumazet wrote:
> On Thu, 2012-06-28 at 10:57 +0200, Eric Dumazet wrote:
> > On Thu, 2012-06-28 at 08:56 +0200, Eric Dumazet wrote:
> >=20
> > > [PATCH] net: Qdisc busylock gets its own lockdep class
> > >=20
> > > Tom Parkin reported following LOCKDEP splat :
> > ..
> > >=20
> > > Instruct lockdep that each Qdisc busylock is independant, or else
> > > bonding or various tunnels can trigger a splat.
> > >=20
> > > Reported-by: Tom Parkin <tparkin@katalix.com>
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > > ---
> >=20
> > I reproduced the bug using a bond0 device, adding a qdisc on it,
> > (one Qdisc on bond0, and a Qdisc on the slave too)
> >=20
> > Problem with this patch is I have following message :
> >=20
> > BUG: key ffff88..... not in .data!
> >=20
> > No more LOCKDEP splat, but patch not good as is.
>=20
> I tested the alternative following patch with my bonding setup,
> could you test it with l2tp ?
>

I've tested against my l2tp test configuration and I still see LOCKDEP
splats:

2tp_core: L2TP core driver, V2.0
2tp_netlink: L2TP netlink interface
2tp_eth: L2TP ethernet pseudowire support (L2TPv3)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
 INFO: possible recursive locking detected ]
=2E5.0-rc2-net-lockdep-u64-sync-007-+ #1 Not tainted
--------------------------------------------
wapper/0/0 is trying to acquire lock:
(slock-AF_INET){+.-...}, at: [<f862abff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_c=
ore]

ut task is already holding lock:
(slock-AF_INET){+.-...}, at: [<c15333d7>] ip_send_reply+0x107/0x2b0

ther info that might help us debug this:
Possible unsafe locking scenario:

      CPU0
      ----
 lock(slock-AF_INET);
 lock(slock-AF_INET);

*** DEADLOCK ***

May be due to missing lock nesting notation

 locks held by swapper/0/0:
#0:  (rcu_read_lock){.+.+..}, at: [<c14f7824>] __netif_receive_skb+0xe4/0x8=
d0
#1:  (rcu_read_lock){.+.+..}, at: [<c152bd4c>] ip_local_deliver_finish+0x3c=
/0x4c0
#2:  (slock-AF_INET){+.-...}, at: [<c15333d7>] ip_send_reply+0x107/0x2b0
#3:  (rcu_read_lock){.+.+..}, at: [<c1531456>] ip_finish_output+0x106/0x710
#4:  (rcu_read_lock_bh){.+....}, at: [<c14fa670>] dev_queue_xmit+0x0/0xbd0

tack backtrace:
id: 0, comm: swapper/0 Not tainted 3.5.0-rc2-net-lockdep-u64-sync-007-+ #1
all Trace:
[<c10a7b32>] __lock_acquire+0xd52/0x17d0
[<c10a334b>] ? trace_hardirqs_off+0xb/0x10
[<c10a8b48>] lock_acquire+0x88/0x120
[<f862abff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
[<c16157bb>] _raw_spin_lock+0x3b/0x70
[<f862abff>] ? l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
[<f862abff>] l2tp_xmit_skb+0x13f/0x8e0 [l2tp_core]
[<f851a32d>] l2tp_eth_dev_xmit+0x2d/0x40 [l2tp_eth]
[<c14fa32f>] dev_hard_start_xmit+0x49f/0x7e0
[<c14f9ee1>] ? dev_hard_start_xmit+0x51/0x7e0
[<c1515819>] sch_direct_xmit+0xa9/0x250
[<c16157e1>] ? _raw_spin_lock+0x61/0x70
[<c14fa83f>] dev_queue_xmit+0x1cf/0xbd0
[<c14fa670>] ? dev_hard_start_xmit+0x7e0/0x7e0
[<c1531537>] ip_finish_output+0x1e7/0x710
[<c1531456>] ? ip_finish_output+0x106/0x710
[<c1532770>] ? ip_output+0x60/0x120
[<c10a585b>] ? trace_hardirqs_on+0xb/0x10
[<c153278b>] ip_output+0x7b/0x120
[<c1532fc9>] ? __ip_make_skb+0x229/0x360
[<c1531b95>] ip_local_out+0x25/0x80
[<c1533117>] ip_send_skb+0x17/0x70
[<c153319b>] ip_push_pending_frames+0x2b/0x40
[<c1533495>] ip_send_reply+0x1c5/0x2b0
[<c107efef>] ? sched_clock_cpu+0xcf/0x150
[<c154f253>] tcp_v4_send_ack+0x1a3/0x260
[<c1552430>] ? tcp_timewait_state_process+0x90/0x3c0
[<c15514ef>] tcp_v4_rcv+0x3ff/0xc20
[<c152bdff>] ip_local_deliver_finish+0xef/0x4c0
[<c152bd4c>] ? ip_local_deliver_finish+0x3c/0x4c0
[<c152c40f>] ip_local_deliver+0x3f/0x80
[<c152b844>] ip_rcv_finish+0x174/0x640
[<c152c671>] ip_rcv+0x221/0x320
[<c14f7f11>] __netif_receive_skb+0x7d1/0x8d0
[<c14f7824>] ? __netif_receive_skb+0xe4/0x8d0
[<c14f80b7>] process_backlog+0xa7/0x170
[<c14f88dd>] net_rx_action+0x11d/0x210
[<c104d990>] ? local_bh_enable_ip+0xd0/0xd0
[<c104da27>] __do_softirq+0x97/0x1f0
[<c104d990>] ? local_bh_enable_ip+0xd0/0xd0
<IRQ>  [<c104ddce>] ? irq_exit+0x7e/0xa0
[<c161e02b>] ? do_IRQ+0x4b/0xc0
[<c161de75>] ? common_interrupt+0x35/0x3c
[<c10380d5>] ? native_safe_halt+0x5/0x10
[<c1018bdf>] ? default_idle+0x4f/0x1e0
[<c1018dc1>] ? amd_e400_idle+0x51/0x100
[<c10199c9>] ? cpu_idle+0xb9/0xe0
[<c15eab3e>] ? rest_init+0x112/0x124
[<c15eaa2c>] ? __read_lock_failed+0x14/0x14
[<c1907a11>] ? start_kernel+0x376/0x37c
[<c19074d6>] ? repair_env_string+0x51/0x51
[<c19072f8>] ? i386_start_kernel+0x9b/0xa2

--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--Fba/0zbH8Xs+Fj9o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJP7GseAAoJEJSMBmUKuovQvvAH/3KSTO0DEIFtP7rdNaQS5Wn0
iMq8BjOhZdgtZod++8ayuXEmvT+gOZj+WMzOtsHMYl2lyiniRTZWUJMuvuWcjm9Y
RI5Wb6Jvva2Lb+b62dDvdriwvSL6R43EXXt1lBZ9ft0xM6gDof/jR9VmBKaqjwxA
kvhMR75Ckc4qAQPzC4Fhrc5pQHEJVnpq9FAXWey+PTgpQu0B5KzG9CKPxP8FBbZd
TS63PxxfoLDkbSiWl/GoN3k1Stm0gLQmTFPmHd0PbNVwYJcrHz4X2lJ6dusRNLkH
RB83pOhy+dnli2zi1q0dCLmTEIhaIZv3qC3jpEioyOgToRArArfR9Vk48YvjnkU=
=qi1R
-----END PGP SIGNATURE-----

--Fba/0zbH8Xs+Fj9o--
