From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e{,vf}: Fix out-of-bound cpumask read in IRQ
 affinity handler
Date: Wed, 16 Aug 2017 17:25:24 -0700
Message-ID: <1502929524.32783.3.camel@intel.com>
References: <ae9c9586f61e914dc1c6fe2e6ac1fb2bf07283bc.1502792828.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-igoboSCOi1syZkHLBgYe"
Cc: "David S . Miller" <davem@davemloft.net>,
        Alan Brady <alan.brady@intel.com>,
        Stefan Assmann <sassmann@redhat.com>
To: Stefano Brivio <sbrivio@redhat.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45691 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751853AbdHQAZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 20:25:25 -0400
In-Reply-To: <ae9c9586f61e914dc1c6fe2e6ac1fb2bf07283bc.1502792828.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-igoboSCOi1syZkHLBgYe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-08-15 at 12:30 +0200, Stefano Brivio wrote:
> The cpumask used in i40e{,vf}_irq_affinity_notify() is allocated
> by irq_affinity_notify() with alloc_cpumask_var(), which doesn't
> allocate NR_CPUS bits, but only nr_cpumask_bits bits. If we just
> dereference it, we'll read way more than what is allocated, e.g.
> 1024 bytes vs. 8 bytes allocated on x86_64 machine with 24 CPUs.
>=20
> Use cpumask_copy() instead. A comprehensive explanation is given
> in the comments about cpumask_var_t, in include/linux/cpumask.h.
>=20
> KASAN reports:
> [   25.242312] BUG: KASAN: slab-out-of-bounds in
> i40e_irq_affinity_notify+0x30/0x50 [i40e] at addr ffff880462eea960
> [   25.242315] Read of size 1024 by task kworker/2:1/170
> [   25.242322] CPU: 2 PID: 170 Comm: kworker/2:1 Not tainted 4.11.0-
> 22.el7a.x86_64 #1
> [   25.242325] Hardware name: HP ProLiant DL380 Gen9, BIOS P89
> 05/06/2015
> [   25.242336] Workqueue: events irq_affinity_notify
> [   25.242340] Call Trace:
> [   25.242350]  dump_stack+0x63/0x8d
> [   25.242358]  kasan_object_err+0x21/0x70
> [   25.242364]  kasan_report+0x288/0x540
> [   25.242397]  ? i40e_irq_affinity_notify+0x30/0x50 [i40e]
> [   25.242403]  check_memory_region+0x13c/0x1a0
> [   25.242408]  __asan_loadN+0xf/0x20
> [   25.242440]  i40e_irq_affinity_notify+0x30/0x50 [i40e]
> [   25.242446]  irq_affinity_notify+0x1b4/0x230
> [   25.242452]  ? irq_set_affinity_notifier+0x130/0x130
> [   25.242457]  ? kasan_slab_free+0x89/0xc0
> [   25.242466]  process_one_work+0x32f/0x6f0
> [   25.242472]  worker_thread+0x89/0x770
> [   25.242481]  ? pci_mmcfg_check_reserved+0xc0/0xc0
> [   25.242488]  kthread+0x18c/0x1e0
> [   25.242493]  ? process_one_work+0x6f0/0x6f0
> [   25.242499]  ? kthread_create_on_node+0xc0/0xc0
> [   25.242506]  ret_from_fork+0x2c/0x40
> [   25.242511] Object at ffff880462eea960, in cache kmalloc-8 size: 8
> [   25.242513] Allocated:
> [   25.242514] PID =3D 170
> [   25.242522]  save_stack_trace+0x1b/0x20
> [   25.242529]  save_stack+0x46/0xd0
> [   25.242533]  kasan_kmalloc+0xad/0xe0
> [   25.242537]  __kmalloc_node+0x12c/0x2b0
> [   25.242542]  alloc_cpumask_var_node+0x3c/0x60
> [   25.242546]  alloc_cpumask_var+0xe/0x10
> [   25.242550]  irq_affinity_notify+0x94/0x230
> [   25.242555]  process_one_work+0x32f/0x6f0
> [   25.242559]  worker_thread+0x89/0x770
> [   25.242564]  kthread+0x18c/0x1e0
> [   25.242568]  ret_from_fork+0x2c/0x40
> [   25.242569] Freed:
> [   25.242570] PID =3D 0
> [   25.242572] (stack is not available)
> [   25.242573] Memory state around the buggy address:
> [   25.242578]  ffff880462eea800: fc fc 00 fc fc 00 fc fc 00 fc fc 00
> fc fc fb fc
> [   25.242582]  ffff880462eea880: fc fb fc fc fb fc fc 00 fc fc 00 fc
> fc 00 fc fc
> [   25.242586] >ffff880462eea900: 00 fc fc 00 fc fc 00 fc fc fb fc fc
> 00 fc fc fc
> [ =20
> 25.242588]                                                         =20
> ^
> [   25.242592]  ffff880462eea980: fc fc fc fc fc fc fc fc fc fc fc fc
> fc fc fc fc
> [   25.242596]  ffff880462eeaa00: fc fc fc fc fc fc fc fc fc fc fc fc
> fc fc fc fc
> [   25.242597]
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> Fixes: 96db776a3682 ("i40e/i40evf: fix interrupt affinity bug")
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
> ---
> This should be considered for -stable, back to 4.10.
>=20
>  drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
>  drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

This is already resolved with a previous patch from Jacob Keller, see
the following commit in my tree:

commit f15ac286b0d111499e0fec4b50c8c870ad3b4573
Author: Jacob Keller <jacob.e.keller@intel.com>
Date:   Wed Aug 16 17:12:00 2017 -0700

    i40e: use cpumask_copy instead of direct assignment
   =20
    According to the header file cpumask.h, we shouldn't be directly
copying
    a cpumask_t, since its a bitmap and might not be copied correctly.
Lets
    use the provided cpumask_copy() function instead.
   =20
    Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
--=-igoboSCOi1syZkHLBgYe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlmU4nQACgkQ5W/vlVpL
7c5X5RAAiiz4lTkq/XSJal5iYSNVQOhV6em4rPOJ2s7XAHaw8pNy7fvaMJqWBUm8
sMuHPpFN2DmYhQ3hL2WFSda8FLR/m5SOYoKOEnTruO5zKfwP7FMMvB1uRLwHqLx0
1kvscnLwXvgHI9KCj+wQzAPbN0eMjrPVR0SIYEwIcgnP770w3qJ18DdZ06MsDkxB
wsbQD4qiSdJvohscJ36hRMUtw63xJ/8lowu6VVmJ70BOVHTlCRBwy/PqfbOjGoaa
v36cBNc2W8i4ZMJHjMvnDZJhBjMlmsl5xgAMOAocrCWgD983Q2l3Ap0JKIu70A++
7CBD0+qFVT9poVDoLhyQFtcgmyDzttx1JdnENMJTvy1ZEbMdT8cyOyft+pCIGQU1
M0vtvTyhIj39JACSViGZueVNNxetT4U2kMK9W2XOFVTTMJBDdbeb2qS29QDoWVyN
d2ILcQ4YR2sDQswVji9VkKu8LVmacg10ggf3a8BsdQKJ9kiKA6oe/cRoS1gSy+Dc
peVOZ/AgYZw91BQ1hEkRRohHe+xQpf1rcQWg5OGc42T3WRJTDygSOKdXwyR314wl
IZ9MESuz3eyqsxlCbzyq9hlGLNPHEpAigvM8kig6p0S83yMQTZ0RsLyiePAaJRx7
G/lHpNJpLNqi9/rVN7ZS1cW6v8nTABJjNUq5FEx6Ip/IEi9TxQM=
=Q/iQ
-----END PGP SIGNATURE-----

--=-igoboSCOi1syZkHLBgYe--
