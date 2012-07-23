From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net, cgroup: Fix boot failure due to iteration of uninitialized
 list
Date: Mon, 23 Jul 2012 09:15:05 +0800
Message-ID: <500CA599.6030907@cn.fujitsu.com>
References: <20120719162532.23505.85946.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mark.d.rustad@intel.com,
	john.r.fastabend@intel.com, lizefan@huawei.com
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120719162532.23505.85946.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8820=E6=97=A5 00:27, Srivatsa S. Bhat =E5=
=86=99=E9=81=93:
> After commit ef209f15 (net: cgroup: fix access the unallocated memory=
 in
> netprio cgroup), boot fails with the following NULL pointer dereferen=
ce:
>=20
> Initializing cgroup subsys devices
> Initializing cgroup subsys freezer
> Initializing cgroup subsys net_cls
> Initializing cgroup subsys blkio
> Initializing cgroup subsys perf_event
> Initializing cgroup subsys net_prio
> BUG: unable to handle kernel NULL pointer dereference at 000000000000=
0698
> IP: [<ffffffff8145e8d6>] cgrp_create+0xf6/0x190
> PGD 0
> Oops: 0000 [#1] SMP
> CPU 0
> Modules linked in:
>=20
> Pid: 0, comm: swapper/0 Not tainted 3.5.0-rc7-mandeep #1 IBM IBM Syst=
em x -[7870C4Q]-/68Y8033
> RIP: 0010:[<ffffffff8145e8d6>]  [<ffffffff8145e8d6>] cgrp_create+0xf6=
/0x190
> RSP: 0000:ffffffff81a01ea8  EFLAGS: 00010213
> RAX: 0000000000000000 RBX: ffffffffffffff10 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000246 RDI: ffffffff81aa70a0
> RBP: ffffffff81a01ed8 R08: 0000000000000000 R09: 0000000000000000
> R10: ffff8808ff8641c0 R11: 6e697a696c616974 R12: 0000000000000001
> R13: ffff8808ff8641c0 R14: 0000000000000000 R15: 0000000000093970
> FS:  0000000000000000(0000) GS:ffff8808ffc00000(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000698 CR3: 0000000001a0b000 CR4: 00000000000006b0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process swapper/0 (pid: 0, threadinfo ffffffff81a00000, task ffffffff=
81a13420)
> Stack:
>  ffffffff81a01eb8 ffffffff818060ff ffffffff81d75ec8 ffffffff81aa8960
>  ffffffff81aa8960 ffffffff81b4c2c0 ffffffff81a01ef8 ffffffff81b1cb78
>  0000000000000018 0000000000000048 ffffffff81a01f18 ffffffff81b1ce13
> Call Trace:
>  [<ffffffff81b1cb78>] cgroup_init_subsys+0x83/0x169
>  [<ffffffff81b1ce13>] cgroup_init+0x36/0x119
>  [<ffffffff81affef7>] start_kernel+0x3ba/0x3ef
>  [<ffffffff81aff95b>] ? kernel_init+0x27b/0x27b
>  [<ffffffff81aff356>] x86_64_start_reservations+0x131/0x136
>  [<ffffffff81aff45e>] x86_64_start_kernel+0x103/0x112
> Code: 01 48 3d f8 e1 ec 81 48 8d 98 10 ff ff ff 75 1b eb 73 0f 1f 00 =
48 8b 83 f0 00 00 00 48 3d f8 e1 ec 81 48 8d 98 10 ff ff ff 74 5a <48> =
8b 83 88 07 00 00 48 85 c0 74 de 44 3b 60 10 76 d8 44 89 e6
> RIP  [<ffffffff8145e8d6>] cgrp_create+0xf6/0x190
>  RSP <ffffffff81a01ea8>
> CR2: 0000000000000698
> ---[ end trace a7919e7f17c0a725 ]---
> Kernel panic - not syncing: Attempted to kill the idle task!
>=20
> The code corresponds to:
>=20
> update_netdev_tables():
>         for_each_netdev(&init_net, dev) {
>                 map =3D rtnl_dereference(dev->priomap);  <---- HERE
>=20
>=20
> The list head is initialized in netdev_init(), which is called much
> later than cgrp_create(). So the problem is that we are calling
> update_netdev_tables() way too early (in cgrp_create()), which will
> end up traversing the not-yet-circular linked list. So at some point,
> the dev pointer will become NULL and hence dev->priomap becomes an
> invalid access.
>=20
> To fix this, just remove the update_netdev_tables() function entirely=
,
> since it appears that write_update_netdev_table() will handle things
> just fine.

The reason I add update_netdev_tables in cgrp_create is to avoid additi=
onal
bound checkings when we accessing the dev->priomap.priomap.

Eric,can we revert this commit 91c68ce2b26319248a32d7baa1226f819d283758=
 now?
I think it's safe enough to access priomap without bound check.

Thanks
