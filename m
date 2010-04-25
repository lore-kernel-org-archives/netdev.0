From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
	amount of outgoing connections (unable to bind ... )
Date: Sun, 25 Apr 2010 17:26:42 +0300
Message-ID: <20100425142642.GA11411@redhat.com>
References: <20100421003022.GA3107@ioremap.net> <1271828799.7895.1287.camel@edumazet-laptop> <20100421082559.GA32475@ioremap.net> <1271840535.7895.1612.camel@edumazet-laptop> <20100421095812.GA14778@ioremap.net> <1271849253.7895.1929.camel@edumazet-laptop> <20100421182723.GA17202@ioremap.net> <1271875416.7895.3033.camel@edumazet-laptop> <20100421185837.GB21249@ioremap.net> <1271877975.7895.3171.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070Ab0DYOar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Apr 2010 10:30:47 -0400
Content-Disposition: inline
In-Reply-To: <1271877975.7895.3171.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 09:26:15PM +0200, Eric Dumazet wrote:
> Le mercredi 21 avril 2010 =E0 22:58 +0400, Evgeniy Polyakov a =E9crit=
 :
>=20
> > Damn it, I tried multiple times :)
> > You are right of course!
> >=20
>=20
> Here is a formal patch then :)
>=20
> [PATCH] tcp: bind() fix when many ports are bound
>=20
> Port autoselection done by kernel only works when number of bound
> sockets is under a threshold (typically 30000).
>=20
> When this threshold is over, we must check if there is a conflict bef=
ore
> exiting first loop in inet_csk_get_port()
>=20
> Change inet_csk_bind_conflict() to forbid two reuse-enabled sockets t=
o
> bind on same (address,port) tuple (with a non ANY address)
>=20
> Same change for inet6_csk_bind_conflict()
>=20
> Reported-by: Gaspar Chilingarov <gasparch@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/inet_connection_sock.c  |   16 +++++++++++-----
>  net/ipv6/inet6_connection_sock.c |   15 ++++++++++-----
>  2 files changed, 21 insertions(+), 10 deletions(-)
>=20
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
> index e0a3e35..78cbc39 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -70,13 +70,17 @@ int inet_csk_bind_conflict(const struct sock *sk,
>  		    (!sk->sk_bound_dev_if ||
>  		     !sk2->sk_bound_dev_if ||
>  		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if)) {
> +			const __be32 sk2_rcv_saddr =3D inet_rcv_saddr(sk2);
> +
>  			if (!reuse || !sk2->sk_reuse ||
>  			    sk2->sk_state =3D=3D TCP_LISTEN) {
> -				const __be32 sk2_rcv_saddr =3D inet_rcv_saddr(sk2);
>  				if (!sk2_rcv_saddr || !sk_rcv_saddr ||
>  				    sk2_rcv_saddr =3D=3D sk_rcv_saddr)
>  					break;
> -			}
> +			} else if (reuse && sk2->sk_reuse &&
> +				   sk2_rcv_saddr &&
> +				   sk2_rcv_saddr =3D=3D sk_rcv_saddr)
> +				break;
>  		}
>  	}
>  	return node !=3D NULL;
> @@ -120,9 +124,11 @@ again:
>  						smallest_size =3D tb->num_owners;
>  						smallest_rover =3D rover;
>  						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
> -							spin_unlock(&head->lock);
> -							snum =3D smallest_rover;
> -							goto have_snum;
> +							if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
> +								spin_unlock(&head->lock);
> +								snum =3D smallest_rover;
> +								goto have_snum;
> +							}
>  						}
>  					}
>  					goto next;
> diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connec=
tion_sock.c
> index 0c5e3c3..fb6959c 100644
> --- a/net/ipv6/inet6_connection_sock.c
> +++ b/net/ipv6/inet6_connection_sock.c
> @@ -42,11 +42,16 @@ int inet6_csk_bind_conflict(const struct sock *sk=
,
>  		if (sk !=3D sk2 &&
>  		    (!sk->sk_bound_dev_if ||
>  		     !sk2->sk_bound_dev_if ||
> -		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if) &&
> -		    (!sk->sk_reuse || !sk2->sk_reuse ||
> -		     sk2->sk_state =3D=3D TCP_LISTEN) &&
> -		     ipv6_rcv_saddr_equal(sk, sk2))
> -			break;
> +		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if)) {
> +			if ((!sk->sk_reuse || !sk2->sk_reuse ||
> +			     sk2->sk_state =3D=3D TCP_LISTEN) &&
> +			     ipv6_rcv_saddr_equal(sk, sk2))
> +				break;
> +			else if (sk->sk_reuse && sk2->sk_reuse &&
> +				!ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
> +				ipv6_rcv_saddr_equal(sk, sk2))
> +				break;
> +		}
>  	}
> =20
>  	return node !=3D NULL;
>=20

With this applied, my box crashes on boot:
rhel6 beta userspace, v2.6.34-rc5-204-gddc9b34 kernel.
2.6.34-rc5 kernel boots fine.
the crash seems to be around net/ipv6/inet6_connection_sock.c:50
after reverting fda48a0d7a8412cedacda46a9c0bf8ef9cd13559,
the crash goes away.

I created https://bugzilla.kernel.org/show_bug.cgi?id=3D15847
to track this.

Oops below:

BUG: unable to handle kernel NULL pointer dereference at
0000000000000004
IP: [<ffffffffa02b99aa>] inet6_csk_bind_conflict+0x6a/0x110 [ipv6]
PGD 0=20
Oops: 0000 [#1] SMP=20
last sysfs file:
/sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/net/eth0/ifindex
CPU 9=20
Modules linked in: ip6t_REJECT nf_conntrack_ipv6 ip6table_filter
ip6_tables ipv6 dm_mirror dm_region_hash dm_log igb i2c_i801 sg iTCO_wd=
t
iTCO_vendor_support shpchp ioatdma dca pcspkr sr_mod cdrom ext4 mbcache
jbd2 sd_mod ata_generic crc_t10dif pata_acpi ahci pata_jmicron radeon
ttm drm_kms_helper drm i2c_algo_bit i2c_core dm_mod [last unloaded:
scsi_wait_scan]

Pid: 1640, comm: master Not tainted 2.6.34-rc5-mst #1 X8DTN/X8DTN
RIP: 0010:[<ffffffffa02b99aa>]  [<ffffffffa02b99aa>]
inet6_csk_bind_conflict+0x6a/0x110 [ipv6]
RSP: 0018:ffff8803357a7d98  EFLAGS: 00010293
RAX: 0000000000000000 RBX: ffff880335709440 RCX: 0000000000000000
RDX: 0000000000020011 RSI: ffff880335709440 RDI: ffff880334c61e78
RBP: ffff8803357a7db8 R08: 0000000000000019 R09: 0000000000000019
R10: 00000000000000d4 R11: 0000000000000400 R12: ffff880335709468
R13: ffff880334c61800 R14: ffff880335489500 R15: ffffffff8225d700
=46S:  00007feacd26f7c0(0000) GS:ffff8801c5700000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000004 CR3: 00000003341ef000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process master (pid: 1640, threadinfo ffff8803357a6000, task
ffff880334225540)
Stack:
 0000000000000000 ffffffff8225b500 ffffc9001251ced0 ffff880334c61800
<0> ffff8803357a7e48 ffffffff81418fa8 ffff880300000019 ffffffff8149ceb6
<0> 0000000536306140 0000000000000246 ffff8803357a7e08 0000000000000246
Call Trace:
 [<ffffffff81418fa8>] inet_csk_get_port+0x238/0x450
 [<ffffffff8149ceb6>] ? _raw_spin_lock_bh+0x16/0x40
 [<ffffffff8149ce15>] ? _raw_read_unlock_bh+0x15/0x20
 [<ffffffffa0290226>] ? ipv6_chk_addr+0xe6/0x100 [ipv6]

--=20
MST
