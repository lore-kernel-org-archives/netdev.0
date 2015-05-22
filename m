From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?=
	<marmarek@invisiblethingslab.com>
Subject: xen-netfront crash when detaching network while some network activity
Date: Fri, 22 May 2015 13:49:32 +0200
Message-ID: <20150522114932.GC8664@mail-itl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QRj9sO5tAVLaXnSD"
Cc: xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:37803 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756420AbbEVLtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 07:49:39 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 8D6F52079A
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 07:49:38 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--QRj9sO5tAVLaXnSD
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

I'm experiencing xen-netfront crash when doing xl network-detach while
some network activity is going on at the same time. It happens only when
domU has more than one vcpu. Not sure if this matters, but the backend
is in another domU (not dom0). I'm using Xen 4.2.2. It happens on kernel
3.9.4 and 4.1-rc1 as well.

Steps to reproduce:
1. Start the domU with some network interface
2. Call there 'ping -f some-IP'
3. Call 'xl network-detach NAME 0'

The crash message:
[   54.163670] page:ffffea00004bddc0 count:0 mapcount:0 mapping:
(null) index:0x0
[   54.163692] flags: 0x3fff8000008000(tail)
[   54.163704] page dumped because:
VM_BUG_ON_PAGE(atomic_read(&page->_count) =3D=3D 0)
[   54.163726] ------------[ cut here ]------------
[   54.163734] kernel BUG at include/linux/mm.h:343!
[   54.163742] invalid opcode: 0000 [#1] SMP=20
[   54.163752] Modules linked in:
[   54.163762] CPU: 1 PID: 24 Comm: xenwatch Not tainted
4.1.0-rc1-1.pvops.qubes.x86_64 #4
[   54.163773] task: ffff8800133c4c00 ti: ffff880012c94000 task.ti:
ffff880012c94000
[   54.163782] RIP: e030:[<ffffffff811843cc>]  [<ffffffff811843cc>]
__free_pages+0x4c/0x50
[   54.163800] RSP: e02b:ffff880012c97be8  EFLAGS: 00010292
[   54.163808] RAX: 0000000000000044 RBX: 000077ff80000000 RCX:
0000000000000044
[   54.163817] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
ffff880013d0ea00
[   54.163826] RBP: ffff880012c97be8 R08: 00000000000000f2 R09:
0000000000000000
[   54.163835] R10: 00000000000000f2 R11: ffffffff8185efc0 R12:
0000000000000000
[   54.163844] R13: ffff880011814200 R14: ffff880012f77000 R15:
0000000000000004
[   54.163860] FS:  00007f735f0d8740(0000) GS:ffff880013d00000(0000)
knlGS:0000000000000000
[   54.163870] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[   54.163878] CR2: 0000000001652c50 CR3: 0000000012112000 CR4:
0000000000002660
[   54.163892] Stack:
[   54.163901]  ffff880012c97c08 ffffffff81184430 0000000000000011
0000000000000004
[   54.163922]  ffff880012c97c38 ffffffff814100c6 ffff87ffffffffff
ffff880011f20d88
[   54.163943]  ffff880011814200 ffff880011f20000 ffff880012c97ca8
ffffffff814d34e6
[   54.163964] Call Trace:
[   54.163977]  [<ffffffff81184430>] free_pages+0x60/0x70
[   54.163994]  [<ffffffff814100c6>]
gnttab_end_foreign_access+0x136/0x170
[   54.164012]  [<ffffffff814d34e6>]
xennet_disconnect_backend.isra.24+0x166/0x390
[   54.164030]  [<ffffffff814d37a8>] xennet_remove+0x38/0xd0
[   54.164045]  [<ffffffff8141a009>] xenbus_dev_remove+0x59/0xc0
[   54.164059]  [<ffffffff81479d27>] __device_release_driver+0x87/0x120
[   54.164528]  [<ffffffff81479de3>] device_release_driver+0x23/0x30
[   54.164528]  [<ffffffff81479658>] bus_remove_device+0x108/0x180
[   54.164528]  [<ffffffff81475861>] device_del+0x141/0x270
[   54.164528]  [<ffffffff814186a0>] ?
unregister_xenbus_watch+0x1d0/0x1d0
[   54.164528]  [<ffffffff814759b2>] device_unregister+0x22/0x80
[   54.164528]  [<ffffffff81419e5f>] xenbus_dev_changed+0xaf/0x200
[   54.164528]  [<ffffffff816ad346>] ?
_raw_spin_unlock_irqrestore+0x16/0x20
[   54.164528]  [<ffffffff814186a0>] ?
unregister_xenbus_watch+0x1d0/0x1d0
[   54.164528]  [<ffffffff8141bdb9>] frontend_changed+0x29/0x60
[   54.164528]  [<ffffffff814186a0>] ?
unregister_xenbus_watch+0x1d0/0x1d0
[   54.164528]  [<ffffffff8141872e>] xenwatch_thread+0x8e/0x150
[   54.164528]  [<ffffffff810be2b0>] ? wait_woken+0x90/0x90
[   54.164528]  [<ffffffff81099958>] kthread+0xd8/0xf0
[   54.164528]  [<ffffffff81099880>] ?
kthread_create_on_node+0x1b0/0x1b0
[   54.164528]  [<ffffffff816adde2>] ret_from_fork+0x42/0x70
[   54.164528]  [<ffffffff81099880>] ?
kthread_create_on_node+0x1b0/0x1b0
[   54.164528] Code: f6 74 0c e8 67 f5 ff ff 5d c3 0f 1f 44 00 00 31 f6
e8 99 fd ff ff 5d c3 0f 1f 80 00 00 00 00 48 c7 c6 78 29 a1 81 e8 d4 37
02 00 <0f> 0b 66 90 66 66 66 66 90 48 85 ff 75 06 f3 c3 0f 1f 40 00 55=20
[   54.164528] RIP  [<ffffffff811843cc>] __free_pages+0x4c/0x50
[   54.164528]  RSP <ffff880012c97be8>
[   54.166002] ---[ end trace 6b847bc27fec6d36 ]---

Any ideas how to fix this? I guess xennet_disconnect_backend should take
some lock.

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--QRj9sO5tAVLaXnSD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVXxfMAAoJENuP0xzK19cs610IAJZSGIWYVz0wFPsqjPOiwZXC
Lyntv7d/W0Kvbg9fStjn0WM8B6YJHCBerueryuxFmJ4vxVV8joTsfWC12XpxbFO4
rmY15cJDPfeKdfZP91RhzfOy6sZjx4Rw7MVA5UkTeZeOH80uAOJ9Sz8cEcWSG5lZ
oOS+7vq2AJ8oJ/jHsLqCCfGwiu1ZozbPCZfpiOWgLVf0ei3aKBt1A63Fmv/dlecS
UMvD7UN8/Svcg31OL31JKtmA+zPbDDIq1hInT371ZI2hnkiZ34WH0zzH+RO3Zdcw
ECqLO51L0yocn8f3lsB9XnQwEVvLMG2Pi/AKaKMuO6i+vyM49qy6IytaL1bWEHU=
=182s
-----END PGP SIGNATURE-----

--QRj9sO5tAVLaXnSD--
