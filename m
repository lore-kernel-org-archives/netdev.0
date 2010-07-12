From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Oops in neighbour.c 2.6.26.8
Date: Mon, 12 Jul 2010 23:48:54 +0200
Message-ID: <1278971334.2465.4.camel@edumazet-laptop>
References: <452968.10877.qm@web52007.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Doug Kehn <rdkehn@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40190 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624Ab0GLVs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 17:48:59 -0400
Received: by wwi17 with SMTP id 17so489417wwi.1
        for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 14:48:57 -0700 (PDT)
In-Reply-To: <452968.10877.qm@web52007.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 juillet 2010 =C3=A0 13:55 -0700, Doug Kehn a =C3=A9crit :
> Hi All,
>=20
> I know my kernel version is old.  I'm working on an embedded system
> and updating to a newer kernel is time consuming.  Having said that,
> there are not that many differences in neighbour.c between 2.6.26.8
> and the newer kernel revisions.
>=20
> The Oops (included below) only occurs when configuring DMVPN (GRE +
> openNHRP) and a GRE Remote address is configured.  I found and
> included the neighbour.c patch outlined in
> http://web.archiveorange.com/archive/v/iRKxruZnSerMcYadyaYq.  This
> patch did not eliminate the Oops.  The Oops I observed was in
> neigh_update_hhs. neigh->dev->header_ops is NULL thus the line
>=20
> void (*update)(struct hh_cache*, const struct net_device*, const
> unsigned char *)
> =3D neigh->dev->header_ops->cache_update;
>=20
> causes the Oops.  The dev associated with the NULL header_ops was the
> GRE interface.  The following patch guards against the possibility
> that headers_ops is NULL.
>=20
> --- neighbour.c.old	2010-07-12 15:29:24.000000000 -0500
> +++ neighbour.c	2010-07-12 15:32:28.000000000 -0500
> @@ -945,7 +945,10 @@
>  {
>  	struct hh_cache *hh;
>  	void (*update)(struct hh_cache*, const struct net_device*, const
> unsigned char *)
> -		=3D neigh->dev->header_ops->cache_update;
> +		=3D NULL;
> +
> +	if (neigh->dev->header_ops)
> +		update =3D neigh->dev->header_ops->cache_update;
> =20
>  	if (update) {
>  		for (hh =3D neigh->hh; hh; hh =3D hh->hh_next) {
>=20
> I'm not sure if the above patch is the proper fix.  Since
> neigh_update_hhs in newer kernels is identical to 2.6.26.8, I thought
> I'd post my findings and solicit feedback.
>=20
> Regards,
> ...doug
>=20
>=20
> Unable to handle kernel NULL pointer dereference at virtual address
> 00000010
> pgd =3D c745c000
> [00000010] *pgd=3D07fe6031, *pte=3D00000000, *ppte=3D00000000
> Internal error: Oops: 17 [#1]
> Modules linked in: ppp_synctty ppp_async ppp_generic crc_ccitt slhc
> sierra md5 e
> cb arc4 authenc xfrm4_tunnel xfrm_user tunnel4 ipcomp deflate ah4 esp=
4
> aead cbc=20
> hmac sha1_generic des_generic aes_generic cryptomgr crypto_null
> crypto_blkcipher
>  crypto_hash crypto_algapi af_key ipt_MASQUERADE xt_state xt_mac
> xt_tcpudp xt_mu
> ltiport xt_dscp xt_CLASSIFY xt_DSCP xt_MARK iptable_mangle iptable_na=
t
> nf_nat xt
> _conntrack nf_conntrack_ipv4 nf_conntrack iptable_filter ip_tables
> x_tables usbs
> erial ehci_hcd usbcore spidev ixp4xx_spi ssp rtc_s35390a rtc_core
> i2c_gpio i2c_a
> lgo_bit i2c_dev i2c_core ip_gre 8021q bridge ks8842_pci ixp4xx_eth
> ixp4xx_qmgr i
> xp4xx_npe llc firmware_class ctdfs_irq ctdfs_ioreset ctdfs_cmb
> ctdfs_wdt ctdfs_b
> eep ctdfs_reedswitch ctdfs_cpld ctdfs
> CPU: 0    Not tainted  (2.6.26.8 #14)
> PC is at neigh_update+0x1f8/0x3bc
> LR is at 0x3f5840d4
> pc : [<c016dca8>]    lr : [<3f5840d4>]    psr: 40000013
> sp : c7449c38  ip : 0000001c  fp : c7449c6c
> r10: c75457c4  r9 : 80000001  r8 : 00000040
> r7 : c7541028  r6 : 00000002  r5 : c75457a0  r4 : c75457c4
> r3 : 00000000  r2 : 00000000  r1 : c754102c  r0 : c75457c4
> Flags: nZcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> Control: 000039ff  Table: 0745c000  DAC: 00000015
> Process opennhrp (pid: 1110, stack limit =3D 0xc7448260)
> Stack: (0xc7449c38 to 0xc744a000)
> 9c20:                                                       c7412000
> 00000000=20
> 9c40: 00000040 c75457a0 c026b4f0 c7541020 c7412000 c7541000 c7541028
> c7541010=20
> 9c60: c7449cb0 c7449c70 c016eacc c016dabc 00000000 00000000 c754101c
> c7541024=20
> 9c80: 00000000 00000000 0000002c c7541000 0000000c 00000002 00000003
> fffffffc=20
> 9ca0: c7c32ba0 c7449ce4 c7449cb4 c0170a6c c016e8ec 22222222 c7f1a0a0
> c7541000=20
> 9cc0: c7f1a0a0 c0170880 c7449d1c c7443600 00000000 00000000 c7449d00
> c7449ce8=20
> 9ce0: c017c460 c017088c c7f1a0a0 0000002c c7f1a0a0 c7449d14 c7449d04
> c0170870=20
> 9d00: c017c418 c7c37e00 c7449d48 c7449d18 c017beec c0170858 0000002c
> 7fffffff=20
> 9d20: 00000000 c7f1a0a0 c7443600 c7449f58 c7838ce0 c7449e1c 00000000
> c7449d94=20
> 9d40: c7449d4c c017c1f8 c017bcd8 c7f1a5e0 0000002c 00000000 00000456
> 00000000=20
> 9d60: 00000000 00000000 00000000 c7da4640 c7449f58 c7449d98 0000002c
> c7449ef8=20
> 9d80: 00000000 00000008 c7449e74 c7449d98 c015a31c c017bfa0 00000000
> c7541200=20
> 9da0: 00000000 00000001 ffffffff 00000000 00000000 00000000 00000000
> 00000000=20
> 9dc0: c7da4640 00000000 00000000 c7449e3c c7da4640 c004b89c c7449dd8
> c7449dd8=20
> 9de0: c740d005 0000004f c7449e1c 00000000 00000000 0000004f 00000456
> 00000000=20
> 9e00: 00000000 00000000 00000000 c7449e2c 00000000 c7449eac c7f861a0
> 00000001=20
> 9e20: c7449e60 c7449ef8 0000002c c7838ce0 c7449ef8 c7449d58 c7449f58
> c7449e78=20
> 9e40: 00000128 c7449ef8 c7449ef8 00000008 00000000 c7449f58 c0161f74
> c7449f38=20
> 9e60: 00000000 c7838ce0 c7449fa4 c7449e78 c015a4ec c015a278 00100000
> 00000000=20
> 9e80: 00000000 c7449eac c7449f30 c7449f80 fffffdee c7449f58 c7449ea8
> c007c1f8=20
> 9ea0: c0159130 00000000 00000000 c0086ed0 c008631c 00000000 00000001
> ffffffff=20
> 9ec0: c7f861a0 00000000 00000000 00000000 00000000 c7da4640 00000000
> 00000000=20
> 9ee0: c7c0c320 c7da4640 c004b89c c7449eec c7449eec 00000000 bedcfa38
> 00000000=20
> 9f00: c0025fd4 c7449f2c 00000024 0000004f c7448000 0000000f 00000000
> 00000003=20
> 9f20: 0000000b 00000000 00000000 c78042e4 00000002 c78041e4 0000004f
> c7449f80=20
> 9f40: c7449f78 00000000 0000000d 000000ae c0020c44 c7449fa4 c7449e78
> 0000000c=20
> 9f60: c7449ef8 00000001 00000000 00000000 00000000 00000000 ffffff97
> 000392d0=20
> 9f80: bedcf9cc bedcfcd4 00000128 c0020c44 c7448000 0000934c 00000000
> c7449fa8=20
> 9fa0: c0020aa0 c015a348 000392d0 bedcf9cc 00000008 bedcf938 00000000
> 00000008=20
> 9fc0: 000392d0 bedcf9cc bedcfcd4 bedcfc50 00000002 0001022c 0000934c
> bedcf978=20
> 9fe0: 000290c8 bedcf920 0002148c 4008ca98 00000010 00000008 00000000
> 00000000=20
> Backtrace:=20
> [<c016dab0>] (neigh_update+0x0/0x3bc) from [<c016eacc>] (neigh_add
> +0x1ec/0x278)
> [<c016e8e0>] (neigh_add+0x0/0x278) from [<c0170a6c>]
> (rtnetlink_rcv_msg+0x1ec/0x
> 228)
> [<c0170880>] (rtnetlink_rcv_msg+0x0/0x228) from [<c017c460>]
> (netlink_rcv_skb+0x
> 54/0xb8)
> [<c017c40c>] (netlink_rcv_skb+0x0/0xb8) from [<c0170870>]
> (rtnetlink_rcv+0x24/0x
> 34)
>  r6:c7f1a0a0 r5:0000002c r4:c7f1a0a0
> [<c017084c>] (rtnetlink_rcv+0x0/0x34) from [<c017beec>]
> (netlink_unicast+0x220/0
> x2c8)
>  r4:c7c37e00
> [<c017bccc>] (netlink_unicast+0x0/0x2c8) from [<c017c1f8>]
> (netlink_sendmsg+0x26
> 4/0x278)
> [<c017bf94>] (netlink_sendmsg+0x0/0x278) from [<c015a31c>]
> (sock_sendmsg+0xb0/0x
> d0)
> [<c015a26c>] (sock_sendmsg+0x0/0xd0) from [<c015a4ec>] (sys_sendmsg
> +0x1b0/0x20c)
>  r6:c7838ce0 r5:00000000 r4:c7449f38
> [<c015a33c>] (sys_sendmsg+0x0/0x20c) from [<c0020aa0>]
> (ret_fast_syscall+0x0/0x2
> c)
> Code: e5d320f0 ebfe51d7 e595300c e59330b0 (e5937010)=20
> Kernel panic - not syncing: Fatal exception in interrupt
>=20
>=20
>=20

Hi Doug !

I confirm I get a panic on latest kernel too (net-next-2.6) and x86
machine.

ip tunnel add netb mode gre remote 172.19.20.21 local 172.16.17.18 ttl =
255
ip link set netb up
ip addr add 10.0.1.1 dev netb
ip route add 10.0.2.0/24 dev netb
ip neigh add 10.0.1.2 dev netb
ip neigh change 10.0.1.2 lladdr 01:02:03:04 dev netb

Your fix seems fine to me.

Thanks


