From: Eric Paris <eparis@redhat.com>
Subject: [PATCH] secmark: do not return early if there was no error
Date: Wed, 13 Oct 2010 16:21:05 -0400
Message-ID: <20101013202105.15011.60553.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, jengelh@medozas.de,
	paul.moore@hp.com, jmorris@namei.org
To: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 4a5a5c73 attempted to pass decent error messages back to userspace for
netfilter errors.  In xt_SECMARK.c however the patch screwed up and returned
on 0 (aka no error) early and didn't finish setting up secmark.  This results
in a kernel BUG if you use SECMARK.

------------[ cut here ]------------
kernel BUG at net/netfilter/xt_SECMARK.c:38!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/devices/system/cpu/cpu2/cache/index2/shared_cpu_map
CPU 0
Modules linked in: xt_SECMARK iptable_mangle nfs lockd fscache nfs_acl
auth_rpcgss sunrpc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables
uinput virtio_net virtio_balloon i2c_piix4 i2c_core joydev microcode ipv6
virtio_blk virtio_pci virtio_ring virtio [last unloaded: speedstep_lib]

Pid: 0, comm: swapper Not tainted 2.6.36-0.8.rc2.git0.fc15.x86_64 #1 /KVM
RIP: 0010:[<ffffffffa022117d>]  [<ffffffffa022117d>] secmark_tg+0x17/0x2e [xt_SECMARK]
RSP: 0018:ffff880003e03a40  EFLAGS: 00010202
RAX: ffff88001f3074b0 RBX: ffff88001f3073f0 RCX: ffff88001f307490
RDX: ffff88001f307401 RSI: ffff880003e03b30 RDI: ffff88001f18e500
RBP: ffff880003e03a40 R08: 0000000000000002 R09: ffff880003e03a10
R10: ffff880003fd2ad8 R11: ffffffff00000001 R12: ffff88001a85d498
R13: ffffe8ffff808240 R14: ffff88001ac133ae R15: ffff88001f18e500
FS:  0000000000000000(0000) GS:ffff880003e00000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000073b130 CR3: 000000000fdc0000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff81a00000, task
ffffffff81a4b020)
Stack:
ffff880003e03b90 ffffffff814599ff 0000000000003a18 0000000000000000
ffff880003e03b70 ffffffffffffffb8 0000000000000000 ffffffff82a39d60
ffff880003e03a90 ffffffff8140db60 ffff880003e03ae0 ffffffff8140f2c0
Call Trace:
 <IRQ>
[<ffffffff814599ff>] ipt_do_table+0x58a/0x6e2
[<ffffffff8140db60>] ? rcu_read_unlock+0x21/0x23
[<ffffffff8140f2c0>] ? nf_conntrack_find_get+0xb4/0xc7
[<ffffffffa021b182>] iptable_mangle_hook+0x10a/0x120 [iptable_mangle]
[<ffffffff8140c226>] nf_iterate+0x46/0x89
[<ffffffff8141d2e8>] ? ip_rcv_finish+0x0/0x3c6
[<ffffffff8140c2e1>] nf_hook_slow+0x78/0xe3
[<ffffffff8141d2e8>] ? ip_rcv_finish+0x0/0x3c6
[<ffffffff81472f06>] ? run_filter+0x0/0xc0
[<ffffffff813e6802>] ? dev_seq_stop+0x8/0x10
[<ffffffff8141d2e8>] ? ip_rcv_finish+0x0/0x3c6
[<ffffffff8141d9a9>] NF_HOOK.clone.6+0x46/0x58
[<ffffffff8141dd93>] ip_rcv+0x21f/0x24c
[<ffffffff813e7d43>] __netif_receive_skb+0x3e0/0x40a
[<ffffffff813e8834>] netif_receive_skb+0x6c/0x73
[<ffffffffa00c954e>] virtnet_poll+0x55b/0x6cb [virtio_net]
[<ffffffff8107fb92>] ? lock_release+0x19a/0x1a6
[<ffffffff813e9bc4>] net_rx_action+0xb1/0x1e3
[<ffffffff8107d64b>] ? print_lock_contention_bug+0x1b/0xd5
[<ffffffff8100ac1c>] ? call_softirq+0x1c/0x30
[<ffffffff8105752a>] __do_softirq+0xfa/0x1cf
[<ffffffff8107fb92>] ? lock_release+0x19a/0x1a6
[<ffffffff8100ac1c>] call_softirq+0x1c/0x30
[<ffffffff8100c3d9>] do_softirq+0x4b/0xa2
[<ffffffff810576d0>] irq_exit+0x4a/0x8c
[<ffffffff814a198d>] do_IRQ+0x9d/0xb4
[<ffffffff8149b813>] ret_from_intr+0x0/0x16
 <EOI>
[<ffffffff81010faf>] ? default_idle+0x3c/0x61
[<ffffffff8102c7b1>] ? native_safe_halt+0xb/0xd
[<ffffffff810800c0>] ? trace_hardirqs_on+0xd/0xf
[<ffffffff81010fb4>] default_idle+0x41/0x61
[<ffffffff8100830b>] cpu_idle+0xb3/0x10f
[<ffffffff814824c3>] rest_init+0xb7/0xbe
[<ffffffff8148240c>] ? rest_init+0x0/0xbe
[<ffffffff81d76c50>] start_kernel+0x412/0x41d
[<ffffffff81d762c6>] x86_64_start_reservations+0xb1/0xb5
[<ffffffff81d763c2>] x86_64_start_kernel+0xf8/0x107
Code: 41 8a 04 24 88 05 1c 05 00 00 5a 89 d8 5b 41 5c 41 5d c9 c3 55 48 89 e5
0f 1f 44 00 00 48 8b 46 08 8a 10 3a 15 fd 04 00 00 74 02 <0f> 0b fe ca 75 0e
8b 40 04 89 87 b4 00 00 00 83 c8 ff c9 c3 0f
RIP  [<ffffffffa022117d>] secmark_tg+0x17/0x2e [xt_SECMARK]
RSP <ffff880003e03a40>
---[ end trace 9aa5d06a71143e74 ]---

Signed-off-by: Eric Paris <eparis@redhat.com>
Acked-by: Paul Moore <paul.moore@hp.com>
Acked-by: James Morris <jmorris@namei.org>
---

 net/netfilter/xt_SECMARK.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index 23b2d6c..364ad16 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -101,7 +101,7 @@ static int secmark_tg_check(const struct xt_tgchk_param *par)
 	switch (info->mode) {
 	case SECMARK_MODE_SEL:
 		err = checkentry_selinux(info);
-		if (err <= 0)
+		if (err)
 			return err;
 		break;
 

