From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: NULL pointer dereference at skb_queue_tail()
Date: Fri, 9 Jan 2015 22:20:08 +0900
Message-ID: <201501092220.DIB43754.FFMQOSJLOOHVtF@I-love.SAKURA.ne.jp>
References: <201412252222.HIF57826.OQFSVFFOMHLOJt@I-love.SAKURA.ne.jp>
	<201501052150.CIG69242.FFVOLQOJFHtMSO@I-love.SAKURA.ne.jp>
	<CAHA+R7Mq=vhSCqJsE5dn7PGg39R8Nh+m1RT0F-KcoBU99GdpWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:64646 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbbAINUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 08:20:17 -0500
In-Reply-To: <CAHA+R7Mq=vhSCqJsE5dn7PGg39R8Nh+m1RT0F-KcoBU99GdpWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang wrote:
> On Mon, Jan 5, 2015 at 4:50 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > Tetsuo Handa wrote:
> >> I can reproduce below oops when testing Linux 3.18 with memory allocation
> >> failure injection module at https://lkml.org/lkml/2014/12/25/64 .
> >
> > I can reliably reproduce this oops with current linux.git using memory
> > allocation failure injection module. There is a possibility of memory
> > corruption since this oops always occurs immediately after memory
> > allocation failure within GPU/DRM code. I want to check whether
> > fields of structures have expected values or not.
> 
> Looks like the skb->prev and/or skb->next in the skb queue is corrupted,
> but I don't see why. We do play some magic on these pointers recently,
> but it should not be related with unix socket at all.

Yes, I saw skb->prev == NULL while skb->next != NULL. And I saw various
different oops shown below depending on timing.

Is there code which set skb->prev or skb->next to NULL after it was
initialized with non-NULL? If there is no such code, this could be
memory corruption.

> 
> Is it possible for you to check if this is a regression of recent kernel?
> We only have few changes in unix socket recently, and I don't see they
> could cause this bug.

Would you tell me which versions to test?
I confirmed that this problem exists at least since 3.14.
I haven't hit this problem with 3.12 because I hit different problem
before hitting this problem. So far I didn't hit this problem with 3.10.


[  244.389630] BUG: unable to handle kernel paging request at 00000000bf38b1f5
[  244.391428] IP: [<ffffffff81646a51>] unix_detach_fds.isra.25+0x21/0x50
[  244.393050] PGD 7aabf067 PUD 0 
[  244.393865] Oops: 0000 [#1] SMP 
[  244.394694] Modules linked in: stap_1d434baec036a3abf082a3f3fc53e337_9804(OE) ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel dm_mirror aesni_intel dm_region_hash dm_log glue_helper dm_mod lrw gf128mul ablk_helper cryptd ppdev vmw_balloon parport_pc microcode pcspkr serio_raw vmw_vmci parport shpchp i2c_piix4 nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput sd_mod ata_generic pata_acpi e1000 ata_piix mptspi libata scsi_transport_spi m
 ptscsih mptbase floppy
[  244.413886] CPU: 2 PID: 9936 Comm: Xorg Tainted: G        W  OE  3.19.0-rc3+ #9
[  244.415807] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  244.418438] task: ffff88007a7d3d40 ti: ffff88007ab88000 task.ti: ffff88007ab88000
[  244.420269] RIP: 0010:[<ffffffff81646a51>]  [<ffffffff81646a51>] unix_detach_fds.isra.25+0x21/0x50
[  244.422517] RSP: 0018:ffff88007ab8bb48  EFLAGS: 00010206
[  244.423823] RAX: 00000000bf38b1f5 RBX: 0000000000000000 RCX: 0000000000000014
[  244.425580] RDX: 0000000000000004 RSI: ffff88007b4b4800 RDI: ffff88007ab8bbf8
[  244.427312] RBP: ffff88007ab8bb58 R08: 0000000000000014 R09: ffff88007ae54000
[  244.429070] R10: ffff88007ae54000 R11: ffff88007a7d3d40 R12: ffff88007ab8bbf8
[  244.430816] R13: ffff88007b4b4800 R14: ffff88003a806990 R15: ffff88003a806900
[  244.432555] FS:  00007fe2e1976980(0000) GS:ffff88007fc80000(0000) knlGS:0000000000000000
[  244.434477] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  244.435859] CR2: 00000000bf38b1f5 CR3: 000000007aa31000 CR4: 00000000000407e0
[  244.437626] Stack:
[  244.438124]  0000000000000000 0000000000000000 ffff88007ab8bc68 ffffffff816486cb
[  244.439987]  dead000000200200 ffff88001db00700 ffff88007a7d3d40 ffff88007ab8bc28
[  244.441889]  ffff88007a7d3d40 ffff88003a806bb0 0000000000000001 ffff88007ae54000
[  244.443778] Call Trace:
[  244.444376]  [<ffffffff816486cb>] unix_stream_recvmsg+0x57b/0x840
[  244.445850]  [<ffffffff811c7530>] ? poll_select_copy_remaining+0x130/0x130
[  244.447504]  [<ffffffff81589c96>] sock_recvmsg+0x76/0x90
[  244.448777]  [<ffffffff8158b8fe>] ? copy_msghdr_from_user+0x15e/0x1f0
[  244.450331]  [<ffffffff8158bd84>] ___sys_recvmsg+0xe4/0x200
[  244.451660]  [<ffffffff81337180>] ? timerqueue_add+0x60/0xb0
[  244.453018]  [<ffffffff810ce4c9>] ? enqueue_hrtimer+0x29/0x90
[  244.454390]  [<ffffffff810cea70>] ? __hrtimer_start_range_ns+0x260/0x360
[  244.455995]  [<ffffffff811d0745>] ? __fget_light+0x25/0x70
[  244.457313]  [<ffffffff8158c762>] __sys_recvmsg+0x42/0x80
[  244.458625]  [<ffffffff8158c7b2>] SyS_recvmsg+0x12/0x20
[  244.459871]  [<ffffffff816a52e9>] system_call_fastpath+0x12/0x17
[  244.461334] Code: 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 8b 46 38 48 89 e5 41 54 49 89 fc 53 48 89 07 48 c7 46 38 00 00 00 00 48 8b 07 <0f> bf 18 83 eb 01 79 0b eb 1e 0f 1f 44 00 00 49 8b 04 24 48 63 
[  244.467598] RIP  [<ffffffff81646a51>] unix_detach_fds.isra.25+0x21/0x50
[  244.469201]  RSP <ffff88007ab8bb48>
[  244.470055] CR2: 00000000bf38b1f5

[ 1511.728498] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[ 1511.730551] IP: [<ffffffff8159342b>] skb_dequeue+0x4b/0x80
[ 1511.731987] PGD 0 
[ 1511.732523] Oops: 0002 [#1] SMP 
[ 1511.733406] Modules linked in: stap_1d434baec036a3abf082a3f3fc53e337_2788(OE) ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel dm_mirror ghash_clmulni_intel dm_region_hash dm_log aesni_intel dm_mod glue_helper lrw gf128mul ablk_helper cryptd vmw_balloon ppdev microcode serio_raw pcspkr parport_pc vmw_vmci parport shpchp i2c_piix4 nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput sd_mod ata_generic pata_acpi mptspi ata_piix e1000 scsi_transport_spi libata m
 ptscsih mptbase floppy
[ 1511.752609] CPU: 2 PID: 2972 Comm: pool Tainted: G        W  OE  3.19.0-rc3+ #9
[ 1511.754400] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[ 1511.757001] task: ffff880036d29180 ti: ffff8800791bc000 task.ti: ffff8800791bc000
[ 1511.758830] RIP: 0010:[<ffffffff8159342b>]  [<ffffffff8159342b>] skb_dequeue+0x4b/0x80
[ 1511.760787] RSP: 0018:ffff8800791bfb78  EFLAGS: 00010082
[ 1511.762047] RAX: 0000000000000296 RBX: ffff88007a8d7380 RCX: 0000000000000000
[ 1511.763765] RDX: 0000000000000000 RSI: 0000000000000296 RDI: ffff88007a8d77a4
[ 1511.765583] RBP: ffff8800791bfb98 R08: 0000000000000296 R09: 0000000000000000
[ 1511.767359] R10: ffff8800799cb4b0 R11: ffff88007a22b410 R12: ffff88007a8d7790
[ 1511.769116] R13: ffff88007a8d77a4 R14: ffff88007a8d7790 R15: 0000000000000001
[ 1511.770866] FS:  0000000000000000(0000) GS:ffff88007fc80000(0000) knlGS:0000000000000000
[ 1511.772854] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1511.774239] CR2: 0000000000000008 CR3: 0000000001c14000 CR4: 00000000000407e0
[ 1511.776042] Stack:
[ 1511.776558]  ffff88007a8d776c ffff88007a8d7700 ffff88007a8d776c ffff88007a8d7a80
[ 1511.778449]  ffff8800791bfbf8 ffffffff81648030 0000000100c2e630 ffff880000000000
[ 1511.780372]  0000000000000000 0000000000000000 0000000000000000 ffff8800799cb480
[ 1511.782290] Call Trace:
[ 1511.782921]  [<ffffffff81648030>] unix_release_sock+0x1d0/0x2b0
[ 1511.784410]  [<ffffffff81648131>] unix_release+0x21/0x40
[ 1511.785721]  [<ffffffff8158ab8f>] sock_release+0x1f/0x90
[ 1511.787029]  [<ffffffff8158ac12>] sock_close+0x12/0x20
[ 1511.788323]  [<ffffffff811b531f>] __fput+0xdf/0x1e0
[ 1511.789514]  [<ffffffff811b546e>] ____fput+0xe/0x10
[ 1511.790720]  [<ffffffff81087dac>] task_work_run+0xcc/0xf0
[ 1511.792072]  [<ffffffff8106eae8>] do_exit+0x2d8/0xb40
[ 1511.793290]  [<ffffffff810779af>] ? recalc_sigpending+0x1f/0x60
[ 1511.794718]  [<ffffffff8106f3df>] do_group_exit+0x3f/0xa0
[ 1511.796074]  [<ffffffff8107a6f2>] get_signal+0x1d2/0x6f0
[ 1511.797396]  [<ffffffff810134e8>] do_signal+0x28/0x720
[ 1511.798653]  [<ffffffff81013c2c>] do_notify_resume+0x4c/0x90
[ 1511.800057]  [<ffffffff816a5587>] int_signal+0x12/0x17
[ 1511.801334] Code: 00 49 8b 1c 24 4c 39 e3 74 46 48 85 db 74 23 41 83 6c 24 10 01 48 8b 0b 48 8b 53 08 48 c7 03 00 00 00 00 48 c7 43 08 00 00 00 00 <48> 89 51 08 48 89 0a 48 89 c6 4c 89 ef e8 53 17 11 00 48 83 c4 
[ 1511.807711] RIP  [<ffffffff8159342b>] skb_dequeue+0x4b/0x80
[ 1511.809118]  RSP <ffff8800791bfb78>
[ 1511.809995] CR2: 0000000000000008

[  149.357455] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[  149.359965] IP: [<ffffffff8159342b>] skb_dequeue+0x4b/0x80
[  149.361412] PGD 0 
[  149.361931] Oops: 0002 [#1] SMP 
[  149.362787] Modules linked in: stap_1d434baec036a3abf082a3f3fc53e337_2459(OE) ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel dm_mirror ghash_clmulni_intel dm_region_hash dm_log aesni_intel dm_mod glue_helper lrw gf128mul ablk_helper cryptd ppdev vmw_balloon microcode parport_pc pcspkr serio_raw parport vmw_vmci shpchp i2c_piix4 nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput ata_generic pata_acpi sd_mod ata_piix mptspi e1000 scsi_transport_spi mptscsih
  libata mptbase floppy
[  149.382152] CPU: 0 PID: 2608 Comm: gnome-shell Tainted: G        W  OE  3.19.0-rc3+ #9
[  149.384226] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  149.386705] task: ffff88007ad5d780 ti: ffff88007a630000 task.ti: ffff88007a630000
[  149.388606] RIP: 0010:[<ffffffff8159342b>]  [<ffffffff8159342b>] skb_dequeue+0x4b/0x80
[  149.390496] RSP: 0018:ffff88007a633b78  EFLAGS: 00010097
[  149.391740] RAX: 0000000000000296 RBX: ffff88007ad6ad80 RCX: 0000000000000000
[  149.393627] RDX: ffff88003a87fae8 RSI: 0000000000000292 RDI: ffff88007ad6e624
[  149.395312] RBP: ffff88007a633b98 R08: 0000000000000296 R09: 0000000000000000
[  149.397071] R10: ffff88003eeb4030 R11: ffff88007a2dfc10 R12: ffff88007ad6e610
[  149.398745] R13: ffff88007ad6e624 R14: ffff88007ad6e610 R15: 0000000000000001
[  149.400434] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[  149.402266] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  149.403924] CR2: 0000000000000008 CR3: 0000000001c14000 CR4: 00000000000407f0
[  149.405701] Stack:
[  149.406206]  ffff88007ad6e5ec ffff88007ad6e580 ffff88007ad6e5ec ffff88007ad6b480
[  149.408086]  ffff88007a633bf8 ffffffff81647fc4 000000013eeb2dc8 ffff880000000000
[  149.409863]  0000000000000000 0000000000000000 0000000000000000 ffff88003eeb4000
[  149.411670] Call Trace:
[  149.412242]  [<ffffffff81647fc4>] unix_release_sock+0x164/0x2b0
[  149.413838]  [<ffffffff81648131>] unix_release+0x21/0x40
[  149.415089]  [<ffffffff8158ab8f>] sock_release+0x1f/0x90
[  149.416382]  [<ffffffff8158ac12>] sock_close+0x12/0x20
[  149.417581]  [<ffffffff811b531f>] __fput+0xdf/0x1e0
[  149.418869]  [<ffffffff811b546e>] ____fput+0xe/0x10
[  149.420026]  [<ffffffff81087dac>] task_work_run+0xcc/0xf0
[  149.421313]  [<ffffffff8106eae8>] do_exit+0x2d8/0xb40
[  149.422495]  [<ffffffff810779af>] ? recalc_sigpending+0x1f/0x60
[  149.423925]  [<ffffffff8106f3df>] do_group_exit+0x3f/0xa0
[  149.425173]  [<ffffffff8107a6f2>] get_signal+0x1d2/0x6f0
[  149.426408]  [<ffffffff810134e8>] do_signal+0x28/0x720
[  149.427573]  [<ffffffff8101fe4b>] ? __restore_xstate_sig+0x8b/0x680
[  149.429030]  [<ffffffff81013c2c>] do_notify_resume+0x4c/0x90
[  149.430351]  [<ffffffff816a5587>] int_signal+0x12/0x17
[  149.431511] Code: 00 49 8b 1c 24 4c 39 e3 74 46 48 85 db 74 23 41 83 6c 24 10 01 48 8b 0b 48 8b 53 08 48 c7 03 00 00 00 00 48 c7 43 08 00 00 00 00 <48> 89 51 08 48 89 0a 48 89 c6 4c 89 ef e8 53 17 11 00 48 83 c4 
[  149.437473] RIP  [<ffffffff8159342b>] skb_dequeue+0x4b/0x80
[  149.438803]  RSP <ffff88007a633b78>
[  149.439599] CR2: 0000000000000008

[  144.274609] BUG: unable to handle kernel NULL pointer dereference at 0000000000000002
[  144.276557] IP: [<ffffffff81599f40>] skb_copy_datagram_iter+0xe0/0x260
[  144.278178] PGD 7a26e067 PUD 7a26b067 PMD 0 
[  144.279300] Oops: 0000 [#1] SMP 
[  144.280129] Modules linked in: stap_1d434baec036a3abf082a3f3fc53e337_2457(OE) ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel dm_mirror aesni_intel dm_region_hash glue_helper dm_log lrw gf128mul dm_mod ablk_helper cryptd ppdev vmw_balloon microcode parport_pc serio_raw pcspkr vmw_vmci parport shpchp i2c_piix4 nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput sd_mod ata_generic pata_acpi mptspi scsi_transport_spi e1000 mptscsih ata_piix
  mptbase libata floppy
[  144.299002] CPU: 2 PID: 2348 Comm: gnome-shell Tainted: G        W  OE  3.19.0-rc3+ #9
[  144.300902] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  144.303443] task: ffff880078008000 ti: ffff88007a298000 task.ti: ffff88007a298000
[  144.305231] RIP: 0010:[<ffffffff81599f40>]  [<ffffffff81599f40>] skb_copy_datagram_iter+0xe0/0x260
[  144.307397] RSP: 0018:ffff88007a29bbc8  EFLAGS: 00010202
[  144.308726] RAX: 0000000000000002 RBX: 0000000000001000 RCX: 00000000c698e000
[  144.310443] RDX: ffff88007a29be78 RSI: 0000000039672000 RDI: ffff88007a139180
[  144.312144] RBP: ffff88007a29bc18 R08: 0000000000001000 R09: ffff88007b1e0c80
[  144.313834] R10: 0000000000000000 R11: ffff880078008000 R12: 0000000000000000
[  144.315559] R13: ffff88007a139180 R14: 0000000039672000 R15: ffff88007a138a80
[  144.317261] FS:  00007fc870c36a00(0000) GS:ffff88007fc80000(0000) knlGS:0000000000000000
[  144.319169] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  144.320562] CR2: 0000000000000002 CR3: 000000007b5f5000 CR4: 00000000000407e0
[  144.322289] Stack:
[  144.322784]  0000000000000008 ffff88007a151000 00000000c698e000 ffff88007a29be78
[  144.324668]  ffff88007a29bca8 0000000000000000 0000000000000000 ffff88007a139180
[  144.326564]  ffff88007a138b10 ffff88007a138a80 ffff88007a29bd28 ffffffff8164865b
[  144.328422] Call Trace:
[  144.329021]  [<ffffffff8164865b>] unix_stream_recvmsg+0x50b/0x840
[  144.330484]  [<ffffffff811c7530>] ? poll_select_copy_remaining+0x130/0x130
[  144.332121]  [<ffffffff81589c96>] sock_recvmsg+0x76/0x90
[  144.333389]  [<ffffffff811d0745>] ? __fget_light+0x25/0x70
[  144.334714]  [<ffffffff811d07a3>] ? __fdget+0x13/0x20
[  144.335934]  [<ffffffff8158a1c7>] ? sockfd_lookup_light+0x17/0x70
[  144.337383]  [<ffffffff8158a860>] SYSC_recvfrom+0xe0/0x160
[  144.338693]  [<ffffffff81103264>] ? __audit_syscall_entry+0xb4/0x110
[  144.340222]  [<ffffffff8102140c>] ? do_audit_syscall_entry+0x6c/0x70
[  144.341753]  [<ffffffff810227b3>] ? syscall_trace_enter_phase1+0x123/0x180
[  144.343385]  [<ffffffff8158c2ee>] SyS_recvfrom+0xe/0x10
[  144.344651]  [<ffffffff816a52e9>] system_call_fastpath+0x12/0x17
[  144.346100] Code: 83 c7 10 89 da 4c 89 ee ff d1 49 8b 0f 48 85 c9 75 e9 8b 4d c0 85 c9 0f 8f 76 ff ff ff 41 8b 85 cc 00 00 00 49 03 85 d0 00 00 00 <80> 38 00 0f 84 98 00 00 00 45 31 ff 0f 1f 40 00 49 63 d7 48 83 
[  144.352303] RIP  [<ffffffff81599f40>] skb_copy_datagram_iter+0xe0/0x260
[  144.353900]  RSP <ffff88007a29bbc8>
[  144.354829] CR2: 0000000000000002

[  141.981007] BUG: unable to handle kernel paging request at ffff88013b831cc0
[  141.982931] IP: [<ffffffff81594dd5>] __alloc_skb+0x165/0x2b0
[  141.984465] PGD 1f2b067 PUD 0 
[  141.985334] Oops: 0002 [#1] SMP 
[  141.986357] Modules linked in: stap_1d434baec036a3abf082a3f3fc53e337_4681(OE) ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel dm_mirror glue_helper dm_region_hash dm_log lrw dm_mod gf128mul ablk_helper cryptd ppdev vmw_balloon parport_pc microcode serio_raw vmw_vmci pcspkr parport shpchp i2c_piix4 nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput ata_generic sd_mod pata_acpi ata_piix libata mptspi e1000 scsi_transport_spi m
 ptscsih mptbase floppy
[  142.006491] CPU: 3 PID: 610 Comm: Xorg Tainted: G        W  OE  3.19.0-rc3+ #9
[  142.008230] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  142.010776] task: ffff880078898000 ti: ffff88007be24000 task.ti: ffff88007be24000
[  142.012551] RIP: 0010:[<ffffffff81594dd5>]  [<ffffffff81594dd5>] __alloc_skb+0x165/0x2b0
[  142.014522] RSP: 0018:ffff88007be27aa8  EFLAGS: 00010246
[  142.015810] RAX: 00000000ffffffff RBX: ffff88003b831c00 RCX: 00000000ffffffff
[  142.017512] RDX: ffff88013b831cc0 RSI: 0000000000000000 RDI: ffff88003b831cc8
[  142.019255] RBP: ffff88007be27af8 R08: 00000000ffffffc0 R09: 0000000000000200
[  142.020966] R10: ffffffff81594cbe R11: ffff88007f803700 R12: ffff88003b831d00
[  142.022673] R13: 00000000ffffffff R14: ffff88007f803700 R15: 0000000000000100
[  142.024378] FS:  00007fae44c35980(0000) GS:ffff88007fcc0000(0000) knlGS:0000000000000000
[  142.026300] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  142.027657] CR2: ffff88013b831cc0 CR3: 00000000780ea000 CR4: 00000000000407e0
[  142.029383] Stack:
[  142.029865]  ffff880000000000 0000000000000001 ffff88007b232ec0 0000000000000000
[  142.031710]  ffff8800780483c8 0000000000000003 0000000000000000 ffff88007be27ba8
[  142.033531]  ffff880078f06200 0000000000000000 ffff88007be27b58 ffffffff8159567c
[  142.035344] Call Trace:
[  142.035950]  [<ffffffff8159567c>] alloc_skb_with_frags+0x5c/0x1e0
[  142.037356]  [<ffffffff81096440>] ? wake_up_state+0x20/0x20
[  142.038865]  [<ffffffff8158f9d6>] sock_alloc_send_pskb+0x196/0x250
[  142.040323]  [<ffffffff810aaeb4>] ? __wake_up_sync_key+0x54/0x70
[  142.041769]  [<ffffffff8164a237>] ? wait_for_unix_gc+0x27/0xa0
[  142.043181]  [<ffffffff81647aba>] unix_stream_sendmsg+0x2aa/0x430
[  142.044582]  [<ffffffff8158a9e3>] sock_aio_write+0x103/0x140
[  142.045979]  [<ffffffff811b2fbc>] do_sync_readv_writev+0x4c/0x80
[  142.047370]  [<ffffffff811b4965>] do_readv_writev+0x1e5/0x280
[  142.048756]  [<ffffffff810ce4c9>] ? enqueue_hrtimer+0x29/0x90
[  142.050119]  [<ffffffff811d0745>] ? __fget_light+0x25/0x70
[  142.051432]  [<ffffffff81103264>] ? __audit_syscall_entry+0xb4/0x110
[  142.052891]  [<ffffffff811b4a89>] vfs_writev+0x39/0x50
[  142.054119]  [<ffffffff811b4bba>] SyS_writev+0x4a/0xd0
[  142.055307]  [<ffffffff811034f6>] ? __audit_syscall_exit+0x236/0x2e0
[  142.056821]  [<ffffffff816a52e9>] system_call_fastpath+0x12/0x17
[  142.058259] Code: b6 83 90 00 00 00 83 e0 f7 09 c8 b9 ff ff ff ff 85 f6 88 83 90 00 00 00 b8 ff ff ff ff 66 89 8b c2 00 00 00 66 89 83 c6 00 00 00 <48> c7 02 00 00 00 00 48 c7 42 08 00 00 00 00 48 c7 42 10 00 00 
[  142.064326] RIP  [<ffffffff81594dd5>] __alloc_skb+0x165/0x2b0
[  142.065719]  RSP <ffff88007be27aa8>
[  142.066536] CR2: ffff88013b831cc0

[  202.125577] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  202.127781] IP: [<ffffffff81593577>] skb_queue_tail+0x37/0x60
[  202.129471] PGD 7909a067 PUD 7c0ab067 PMD 0 
[  202.130709] Oops: 0002 [#1] SMP 
[  202.131655] Modules linked in: stap_1d434baec036a3abf082a3f3fc53e337_4681(OE) ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul dm_mirror crc32_pclmul crc32c_intel dm_region_hash dm_log ghash_clmulni_intel aesni_intel dm_mod glue_helper lrw gf128mul ablk_helper cryptd ppdev vmw_balloon parport_pc microcode pcspkr vmw_vmci serio_raw parport shpchp i2c_piix4 nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput sd_mod ata_generic pata_acpi mptspi scsi_transport_spi e1000 mptscsih ata_piix
  mptbase libata floppy [last unloaded: stap_1d434baec036a3abf082a3f3fc53e337_4681]
[  202.154006] CPU: 0 PID: 2884 Comm: Xorg Tainted: G        W  OE  3.19.0-rc3+ #9
[  202.155953] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  202.158788] task: ffff88004b048000 ti: ffff88007b590000 task.ti: ffff88007b590000
[  202.160770] RIP: 0010:[<ffffffff81593577>]  [<ffffffff81593577>] skb_queue_tail+0x37/0x60
[  202.162999] RSP: 0018:ffff88007b593bc8  EFLAGS: 00010046
[  202.164409] RAX: 0000000000000292 RBX: ffff88007a426990 RCX: 0000000000000000
[  202.166246] RDX: 0000000000000000 RSI: 0000000000000292 RDI: ffff88007a4269a4
[  202.168089] RBP: ffff88007b593be8 R08: 0000000000000292 R09: 0000000000000300
[  202.169992] R10: ffffffff81594cbe R11: ffff88007f803600 R12: ffff88007a426990
[  202.171916] R13: ffff88007a4269a4 R14: 0000000000000000 R15: ffff88007a426900
[  202.173815] FS:  00007f8233198980(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[  202.175936] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  202.177467] CR2: 0000000000000000 CR3: 000000004eb73000 CR4: 00000000000407f0
[  202.179411] Stack:
[  202.179967]  0000000000000020 ffff88007a426990 0000000000000020 0000000000000000
[  202.182006]  ffff88007b593ca8 ffffffff816479ed ffff88007a426990 ffff88007b593d10
[  202.184061]  0000002000000000 ffff88007b593cc8 0000000000000020 ffff88007a426bf8
[  202.186124] Call Trace:
[  202.186817]  [<ffffffff816479ed>] unix_stream_sendmsg+0x1dd/0x430
[  202.188440]  [<ffffffff8158a9e3>] sock_aio_write+0x103/0x140
[  202.189938]  [<ffffffff811b2fbc>] do_sync_readv_writev+0x4c/0x80
[  202.191531]  [<ffffffff811b4965>] do_readv_writev+0x1e5/0x280
[  202.193053]  [<ffffffff811d0745>] ? __fget_light+0x25/0x70
[  202.194496]  [<ffffffff81103264>] ? __audit_syscall_entry+0xb4/0x110
[  202.196181]  [<ffffffff811b4a89>] vfs_writev+0x39/0x50
[  202.197506]  [<ffffffff811b4bba>] SyS_writev+0x4a/0xd0
[  202.198855]  [<ffffffff811034f6>] ? __audit_syscall_exit+0x236/0x2e0
[  202.200550]  [<ffffffff816a52e9>] system_call_fastpath+0x12/0x17
[  202.202137] Code: 8d 6f 14 41 54 49 89 f4 53 48 89 fb 4c 89 ef 48 83 ec 08 e8 dc 19 11 00 48 8b 53 08 49 89 1c 24 4c 89 ef 48 89 c6 49 89 54 24 08 <4c> 89 22 83 43 10 01 4c 89 63 08 e8 09 16 11 00 48 83 c4 08 5b 
[  202.208943] RIP  [<ffffffff81593577>] skb_queue_tail+0x37/0x60
[  202.210471]  RSP <ffff88007b593bc8>
[  202.211382] CR2: 0000000000000000

[  313.016314] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  313.018432] IP: [<ffffffff81593577>] skb_queue_tail+0x37/0x60
[  313.019982] PGD 79fe4067 PUD 7879b067 PMD 0 
[  313.021183] Oops: 0002 [#1] SMP 
[  313.022081] Modules linked in: stap_1d434baec036a3abf082a3f3fc53e337_4681(OE) ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul dm_mirror crc32_pclmul dm_region_hash crc32c_intel dm_log ghash_clmulni_intel aesni_intel dm_mod glue_helper lrw gf128mul ablk_helper cryptd ppdev vmw_balloon microcode serio_raw parport_pc pcspkr vmw_vmci shpchp parport i2c_piix4 nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput sd_mod ata_generic pata_acpi ata_piix libata mptspi scsi_transport_spi mptscsi
 h e1000 mptbase floppy
[  313.041970] CPU: 0 PID: 2928 Comm: Xorg Tainted: G        W  OE  3.19.0-rc3+ #9
[  313.043692] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  313.046200] task: ffff88007a3fa300 ti: ffff880079f08000 task.ti: ffff880079f08000
[  313.047972] RIP: 0010:[<ffffffff81593577>]  [<ffffffff81593577>] skb_queue_tail+0x37/0x60
[  313.049940] RSP: 0018:ffff880079f0bbc8  EFLAGS: 00010046
[  313.051209] RAX: 0000000000000292 RBX: ffff88007a0c3510 RCX: 0000000000000000
[  313.052892] RDX: 0000000000000000 RSI: 0000000000000292 RDI: ffff88007a0c3524
[  313.054572] RBP: ffff880079f0bbe8 R08: 0000000000000292 R09: 0000000000000300
[  313.056254] R10: ffffffff81594cbe R11: ffff88007f803600 R12: ffff88007a0c3510
[  313.057957] R13: ffff88007a0c3524 R14: 0000000000000000 R15: ffff88007a0c3480
[  313.059642] FS:  00007fa68e9b5980(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[  313.061536] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  313.062881] CR2: 0000000000000000 CR3: 000000007c026000 CR4: 00000000000407f0
[  313.064617] Stack:
[  313.065110]  0000000000000020 ffff88007a0c3510 0000000000000020 0000000000000000
[  313.066962]  ffff880079f0bca8 ffffffff816479ed ffff88007a0c3510 ffff880079f0bd10
[  313.068809]  0000002000000000 ffff880079f0bcc8 0000000000000020 ffff88007a0c3778
[  313.070667] Call Trace:
[  313.071263]  [<ffffffff816479ed>] unix_stream_sendmsg+0x1dd/0x430
[  313.072710]  [<ffffffff8158a9e3>] sock_aio_write+0x103/0x140
[  313.074281]  [<ffffffff811b2fbc>] do_sync_readv_writev+0x4c/0x80
[  313.075706]  [<ffffffff811b4965>] do_readv_writev+0x1e5/0x280
[  313.077070]  [<ffffffff810ce4c9>] ? enqueue_hrtimer+0x29/0x90
[  313.078437]  [<ffffffff811d0745>] ? __fget_light+0x25/0x70
[  313.079731]  [<ffffffff81103264>] ? __audit_syscall_entry+0xb4/0x110
[  313.081225]  [<ffffffff811b4a89>] vfs_writev+0x39/0x50
[  313.082450]  [<ffffffff811b4bba>] SyS_writev+0x4a/0xd0
[  313.083680]  [<ffffffff811034f6>] ? __audit_syscall_exit+0x236/0x2e0
[  313.085186]  [<ffffffff816a52e9>] system_call_fastpath+0x12/0x17
[  313.086609] Code: 8d 6f 14 41 54 49 89 f4 53 48 89 fb 4c 89 ef 48 83 ec 08 e8 dc 19 11 00 48 8b 53 08 49 89 1c 24 4c 89 ef 48 89 c6 49 89 54 24 08 <4c> 89 22 83 43 10 01 4c 89 63 08 e8 09 16 11 00 48 83 c4 08 5b 
[  313.093012] RIP  [<ffffffff81593577>] skb_queue_tail+0x37/0x60
[  313.094408]  RSP <ffff880079f0bbc8>
[  313.095233] CR2: 0000000000000000

[  207.542992] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  207.545125] IP: [<ffffffff81536cc3>] skb_queue_tail+0x33/0x50
[  207.546719] PGD 49067 PUD 1a3067 PMD 0 
[  207.547815] Oops: 0002 [#1] SMP 
[  207.548725] Modules linked in: stap_a22ae6d0c4bc77fa650b27434e28e712_2992(OF) ip6t_rpfilter ip6t_REJECT ipt_REJECT xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel dm_mirror glue_helper dm_region_hash lrw gf128mul dm_log ablk_helper dm_mod cryptd microcode vmw_balloon ppdev parport_pc serio_raw pcspkr vmw_vmci parport shpchp i2c_piix4 nfsd auth_rpcgss nfs_acl lockd sunrpc uinput sd_mod ata_generic pata_acpi mptspi scsi_transport_spi mpt
 scsih mptbase ata_piix libata e1000 floppy
[  207.568456] CPU: 3 PID: 3016 Comm: Xorg Tainted: GF       W  O 3.14.0+ #12
[  207.570127] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  207.572653] task: ffff88007bf4baa0 ti: ffff88007a230000 task.ti: ffff88007a230000
[  207.574431] RIP: 0010:[<ffffffff81536cc3>]  [<ffffffff81536cc3>] skb_queue_tail+0x33/0x50
[  207.576378] RSP: 0018:ffff88007a231c70  EFLAGS: 00010046
[  207.577655] RAX: 0000000000000246 RBX: ffff8800221c4190 RCX: 0000000000000000
[  207.579361] RDX: 0000000000000000 RSI: 0000000000000246 RDI: ffff8800221c41a4
[  207.581034] RBP: ffff88007a231c88 R08: 0000000000000246 R09: 0000000000000300
[  207.582752] R10: ffff88003c3cc900 R11: 0000000000000020 R12: ffff8800221c4190
[  207.584445] R13: ffff8800221c41a4 R14: ffff8800221c4100 R15: 0000000000000000
[  207.586114] FS:  00007f91fc263980(0000) GS:ffff88007fcc0000(0000) knlGS:0000000000000000
[  207.588011] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  207.589752] CR2: 0000000000000000 CR3: 0000000000139000 CR4: 00000000000407e0
[  207.591514] Stack:
[  207.592046]  ffff8800221c4190 0000000000000020 0000000000000000 ffff88007a231d30
[  207.594108]  ffffffff815e2018 ffff8800221c4190 0000002000000059 ffff88007a231d40
[  207.596194]  0000000000000020 ffff8800221c43e8 ffff88007a231d78 ffff88007b22ef80
[  207.598156] Call Trace:
[  207.598774]  [<ffffffff815e2018>] unix_stream_sendmsg+0x1b8/0x3f0
[  207.600297]  [<ffffffff8152dde7>] sock_aio_write+0xd7/0xf0
[  207.601750]  [<ffffffff811d1eb8>] ? fsnotify+0x228/0x2f0
[  207.603077]  [<ffffffff81190e9c>] do_sync_readv_writev+0x4c/0x80
[  207.604638]  [<ffffffff81192300>] do_readv_writev+0xb0/0x220
[  207.606030]  [<ffffffff8108c91a>] ? __hrtimer_start_range_ns+0x1aa/0x380
[  207.607678]  [<ffffffff8142154e>] ? vmw_unlocked_ioctl+0x4e/0x70
[  207.609322]  [<ffffffff811a3e60>] ? do_vfs_ioctl+0x2e0/0x4c0
[  207.610728]  [<ffffffff811924f0>] vfs_writev+0x30/0x60
[  207.612081]  [<ffffffff8119263a>] SyS_writev+0x4a/0xd0
[  207.613369]  [<ffffffff81645da9>] system_call_fastpath+0x16/0x1b
[  207.614896] Code: e5 41 55 4c 8d 6f 14 41 54 49 89 f4 53 48 89 fb 4c 89 ef e8 00 7c 10 00 48 8b 53 08 49 89 1c 24 4c 89 ef 48 89 c6 49 89 54 24 08 <4c> 89 22 83 43 10 01 4c 89 63 08 e8 dd 79 10 00 5b 41 5c 41 5d 
[  207.621107] RIP  [<ffffffff81536cc3>] skb_queue_tail+0x33/0x50
[  207.622519]  RSP <ffff88007a231c70>
[  207.623354] CR2: 0000000000000000
