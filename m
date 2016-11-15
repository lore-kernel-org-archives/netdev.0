From: Andrei Vagin <avagin@gmail.com>
Subject: linux-next: net->netns_ids is used after calling idr_destroy for it
Date: Mon, 14 Nov 2016 22:23:27 -0800
Message-ID: <CANaxB-x7FgxpAwpa-RgOvUptrCRUmAE6NFm3As+LuXUE=fHJyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35317 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932337AbcKOGX2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 01:23:28 -0500
Received: by mail-it0-f66.google.com with SMTP id b123so20151195itb.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 22:23:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

cleanup_net() calls idr_destroy(net->netns_ids) for network namespaces
and then it calls unregister_netdevice_many() which calls
idr_alloc(net0>netns_ids). It looks wrong, doesn't it?

I compiled the kernel with the next patch:
diff --git a/lib/idr.c b/lib/idr.c
index 6098336..c0a3a32 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -636,6 +636,8 @@ void idr_destroy(struct idr *idp)
                struct idr_layer *p = get_from_free_list(idp);
                kmem_cache_free(idr_layer_cache, p);
        }
+
+       idp->top = 0xdeaddead;
 }
 EXPORT_SYMBOL(idr_destroy);

and it crashed as expected:

[  306.974024] BUG: unable to handle kernel paging request at 00000000deade6bd
[  306.977724] IP: [<ffffffff8b445085>] _find_next_bit.part.0+0x15/0x70
[  306.978490] PGD 20dfa067 [  306.978781] PUD 0
[  306.979043]
[  306.979230] Oops: 0000 [#1] SMP
[  306.979607] Modules linked in: macvlan tun bridge stp llc
nf_conntrack_netlink udp_diag tcp_diag inet_diag netlink_diag
af_packet_diag unix_diag binfmt_misc veth nf_conntrack_ipv4
nf_defrag_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack
nf_conntrack nfnetlink ip6table_filter ip6_tables sunrpc ppdev
crc32c_intel joydev virtio_balloon virtio_net i2c_piix4 parport_pc
parport acpi_cpufreq tpm_tis tpm_tis_core tpm virtio_blk serio_raw
virtio_pci ata_generic virtio_ring virtio pata_acpi
[  306.985236] CPU: 1 PID: 6 Comm: kworker/u4:0 Not tainted 4.9.0-rc5+ #91
[  306.986005] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.9.1-1.fc24 04/01/2014
[  306.987024] Workqueue: netns cleanup_net
[  306.987511] task: ffff8ca63cb5a540 task.stack: ffff9e3240340000
[  306.988207] RIP: 0010:[<ffffffff8b445085>]  [<ffffffff8b445085>]
_find_next_bit.part.0+0x15/0x70
[  306.989246] RSP: 0018:ffff9e3240343970  EFLAGS: 00010046
[  306.989871] RAX: ffffffffffffffff RBX: 0000000000000000 RCX: 0000000000000000
[  306.990713] RDX: 0000000000000000 RSI: 0000000000000100 RDI: 00000000deade6bd
[  306.991548] RBP: ffff9e3240343980 R08: ffffffffffffffff R09: ffffffffffffffff
[  306.992383] R10: 00000000f314d32d R11: 0000000000000000 R12: 00000000ffffffff
[  306.993277] R13: 00000000fffffff8 R14: 00000000deaddead R15: 0000000000000000
[  306.994117] FS:  0000000000000000(0000) GS:ffff8ca63fd00000(0000)
knlGS:0000000000000000
[  306.995068] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  306.995744] CR2: 00000000deade6bd CR3: 0000000059aec000 CR4: 00000000000006e0
[  306.996586] DR0: 00000000000100a0 DR1: 0000000000000000 DR2: 0000000000000000
[  306.997423] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  306.998258] Stack:
[  306.998503]  ffff9e3240343980 ffffffff8b44511d ffff9e32403439e0
ffffffff8b42f819
[  306.999434]  0000000000000000 0208002000000007 ffff8ca6289d80c0
ffff9e32403439f8
[  307.000365]  0000000000000000 000000007fffffff ffff8ca61f09b200
ffff8ca6289d80c0
[  307.001296] Call Trace:
[  307.001594]  [<ffffffff8b44511d>] ? find_next_zero_bit+0x1d/0x20
[  307.002307]  [<ffffffff8b42f819>] idr_get_empty_slot+0x189/0x370
[  307.003012]  [<ffffffff8b42fa5e>] idr_alloc+0x5e/0x110
[  307.003631]  [<ffffffff8b70bd88>] ? peernet2id_alloc+0x38/0xb0
[  307.004321]  [<ffffffff8b70ac3d>] __peernet2id_alloc+0x6d/0x90
[  307.005003]  [<ffffffff8b70bda5>] peernet2id_alloc+0x55/0xb0
[  307.005673]  [<ffffffff8b731216>] rtnl_fill_ifinfo+0xaa6/0x10a0
[  307.006368]  [<ffffffff8b112458>] ? rcu_read_lock_sched_held+0x58/0x60
[  307.007136]  [<ffffffff8b6ffe2b>] ? __alloc_skb+0x9b/0x1e0
[  307.007780]  [<ffffffff8b733073>] rtmsg_ifinfo_build_skb+0x73/0xd0
[  307.008509]  [<ffffffff8b7125d5>] rollback_registered_many+0x295/0x390
[  307.009282]  [<ffffffff8b712765>] unregister_netdevice_many+0x25/0x80
[  307.010047]  [<ffffffff8b7138a5>] default_device_exit_batch+0x145/0x170
[  307.010825]  [<ffffffff8b0e7b10>] ? finish_wait+0x70/0x70
[  307.011465]  [<ffffffff8b70ae52>] ops_exit_list.isra.4+0x52/0x60
[  307.012175]  [<ffffffff8b70c17f>] cleanup_net+0x1bf/0x2a0
[  307.012811]  [<ffffffff8b0b616f>] process_one_work+0x1ff/0x660
[  307.013548]  [<ffffffff8b0b60f4>] ? process_one_work+0x184/0x660
[  307.014259]  [<ffffffff8b0b661e>] worker_thread+0x4e/0x480
[  307.014906]  [<ffffffff8b0b65d0>] ? process_one_work+0x660/0x660
[  307.015617]  [<ffffffff8b0bd2a4>] kthread+0xf4/0x110
[  307.016209]  [<ffffffff8b0bd1b0>] ? kthread_park+0x60/0x60
[  307.016857]  [<ffffffff8b872efa>] ret_from_fork+0x2a/0x40
