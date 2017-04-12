From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Subject: [RFC PATCH linux 0/2] net sched actions: access to uninitialized data and error handling
Date: Wed, 12 Apr 2017 16:21:38 +0200
Message-ID: <20170412142140.26649-1-w.bumiller@proxmox.com>
Cc: linux-kernel@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxmox.maurer-it.com ([212.186.127.180]:20167 "EHLO
        proxmox.maurer-it.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754261AbdDLOad (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:30:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1045ba77a ("net sched actions: Add support for user cookies")
added code to net/sched/act_api.c's tcf_action_init_1 using the `tb`
nlattr array unconditionally, while it was otherwise used as well as
initialized only when `name == NULL`:

	if (name == NULL) {
		err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);

In the other case `nla` is instead passed over to ->init to be parsed
there (using a different set of TCA_ enum values, iow. TCA_ACT_COOKIE
then "clashes" with some other value). This lead to the following three
example commands resulting in errors (sometimes followed by more traces
and hangups some time later (although the hangups happened seconds or
sometimes minutes later, sometimes not at all - results differed between
different kernel versions (linux git-master vs ubuntu's mainline 4.11
rc6 vs. pve 4.10.5 (based off ubuntu's zesty kernel where the commit is
cherry-picked)...))):

 # ip link add ve0 type veth peer name ve0b
 # tc qdisc add dev ve0 handle ffff: ingress
 # tc filter add dev ve0 parent ffff: prio 50 basic police rate 1000bps burst 1000b drop

The 3rd command would sometimes succeed, sometimes error with:

 RTNETLINK answers: Invalid argument
 We have an error talking to the kernel

and sometimes error with:

 RTNETLINK answers: Cannot allocate memory
 We have an error talking to the kernel

In the latter case I assume `cklen` became negative, which passes the
TC_COOKIE_MAX_SIZE check since it is signed but becomes unsigned later
in kmemdup() (see the crash dump below)

When the `tc filter add` command fails a backtrace shows up in dmesg,
added below.

I'm not sure why the TC_ACT_COOKIE code was added to tcf_action_init_1
where it is now. It makes me think that it's supposed to be available
universally, but the `name == NULL` check for how nla is used or passed
to ->init() shows that the there are various different TC_ACT_* enums in
use at this point, hence the 'RFC' part of the patches, I'm not that
familiar with the code yet.

Backtrace when running `tc filter add`:

    Apr 12 11:31:38 testmachine kernel: ------------[ cut here ]------------
    Apr 12 11:31:38 testmachine kernel: WARNING: CPU: 7 PID: 16596 at mm/page_alloc.c:3541 __alloc_pages_slowpath+0x9fe/0xba0
    Apr 12 11:31:38 testmachine kernel: Modules linked in: act_police cls_basic sch_ingress veth nfsv3 nfs_acl nfs lockd grace ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables xt_mac ipt_REJECT nf_reject_ipv4 xt_physdev xt_comment nf_conntrack_ipv4 nf_defrag_ipv4 xt_tcpudp xt_mark xt_set xt_addrtype xt_multiport xt_conntrack nf_conntrack ip_set_hash_net ip_set arc4 md4 nls_utf8 cifs ccm fscache ipta
    Apr 12 11:31:38 testmachine kernel:  snd_hda_codec_realtek snd_hda_codec_generic aesni_intel aes_x86_64 crypto_simd drm_kms_helper glue_helper cryptd drm snd_hda_intel intel_cstate snd_hda_codec i2c_algo_bit fb_sys_fops snd_hda_core joydev syscopyarea snd_hwdep sysfillrect input_leds sysimgblt intel_rapl_perf snd_pcm snd_timer snd pcspkr soundcore mei_me lpc_ich mei shpchp tpm_infineon mac_hid wmi acpi_pad video vhost_net vhost macv
    Apr 12 11:31:38 testmachine kernel: CPU: 7 PID: 16596 Comm: tc Tainted: P           O    4.10.5-1-pve #1
    Apr 12 11:31:38 testmachine kernel: Hardware name: ASUS All Series/Z97-A, BIOS 2801 11/11/2015
    Apr 12 11:31:38 testmachine kernel: Call Trace:
    Apr 12 11:31:38 testmachine kernel:  dump_stack+0x63/0x81
    Apr 12 11:31:38 testmachine kernel:  __warn+0xcb/0xf0
    Apr 12 11:31:38 testmachine kernel:  warn_slowpath_null+0x1d/0x20
    Apr 12 11:31:38 testmachine kernel:  __alloc_pages_slowpath+0x9fe/0xba0
    Apr 12 11:31:38 testmachine kernel:  ? get_page_from_freelist+0x46a/0xb20
    Apr 12 11:31:38 testmachine kernel:  ? schedule+0x36/0x80
    Apr 12 11:31:38 testmachine kernel:  ? schedule_timeout+0x22a/0x3f0
    Apr 12 11:31:38 testmachine kernel:  __alloc_pages_nodemask+0x209/0x260
    Apr 12 11:31:38 testmachine kernel:  alloc_pages_current+0x95/0x140
    Apr 12 11:31:38 testmachine kernel:  kmalloc_order+0x18/0x40
    Apr 12 11:31:38 testmachine kernel:  kmalloc_order_trace+0x24/0xa0
    Apr 12 11:31:38 testmachine kernel:  __kmalloc_track_caller+0x1e5/0x200
    Apr 12 11:31:38 testmachine kernel:  kmemdup+0x20/0x50
    Apr 12 11:31:38 testmachine kernel:  nla_memdup_cookie+0x55/0x90
    Apr 12 11:31:38 testmachine kernel:  tcf_action_init_1+0xcc/0x230
    Apr 12 11:31:38 testmachine kernel:  tcf_exts_validate+0x52/0x110
    Apr 12 11:31:38 testmachine kernel:  basic_change+0x194/0x4d2 [cls_basic]
    Apr 12 11:31:38 testmachine kernel:  tc_ctl_tfilter+0x54d/0x9a0
    Apr 12 11:31:38 testmachine kernel:  rtnetlink_rcv_msg+0xe6/0x210
    Apr 12 11:31:38 testmachine kernel:  ? __kmalloc_node_track_caller+0x1f0/0x2a0
    Apr 12 11:31:38 testmachine kernel:  ? __alloc_skb+0x87/0x1e0
    Apr 12 11:31:38 testmachine kernel:  ? rtnl_newlink+0x860/0x860
    Apr 12 11:31:38 testmachine kernel:  netlink_rcv_skb+0xa4/0xc0
    Apr 12 11:31:38 testmachine kernel:  rtnetlink_rcv+0x28/0x30
    Apr 12 11:31:38 testmachine kernel:  netlink_unicast+0x18c/0x220
    Apr 12 11:31:38 testmachine kernel:  netlink_sendmsg+0x2f7/0x3b0
    Apr 12 11:31:38 testmachine kernel:  ? aa_sock_msg_perm+0x61/0x150
    Apr 12 11:31:38 testmachine kernel:  sock_sendmsg+0x38/0x50
    Apr 12 11:31:38 testmachine kernel:  ___sys_sendmsg+0x2c2/0x2d0
    Apr 12 11:31:38 testmachine kernel:  ? schedule+0x36/0x80
    Apr 12 11:31:38 testmachine kernel:  ? ptrace_stop+0x20a/0x2a0
    Apr 12 11:31:38 testmachine kernel:  ? ptrace_do_notify+0x98/0xc0
    Apr 12 11:31:38 testmachine kernel:  __sys_sendmsg+0x54/0x90
    Apr 12 11:31:38 testmachine kernel:  SyS_sendmsg+0x12/0x20
    Apr 12 11:31:38 testmachine kernel:  do_syscall_64+0x5b/0xc0
    Apr 12 11:31:38 testmachine kernel:  entry_SYSCALL64_slow_path+0x25/0x25
    Apr 12 11:31:38 testmachine kernel: RIP: 0033:0x7f0aef7d0a77
    Apr 12 11:31:38 testmachine kernel: RSP: 002b:00007ffe88627568 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
    Apr 12 11:31:38 testmachine kernel: RAX: ffffffffffffffda RBX: 0000000058edf3fc RCX: 00007f0aef7d0a77
    Apr 12 11:31:38 testmachine kernel: RDX: 0000000000000000 RSI: 00007ffe886275b0 RDI: 0000000000000003
    Apr 12 11:31:38 testmachine kernel: RBP: 00007ffe886275b0 R08: 0000000000000001 R09: 0000000000000050
    Apr 12 11:31:38 testmachine kernel: R10: 00000000000005e9 R11: 0000000000000246 R12: 00007ffe886275f0
    Apr 12 11:31:38 testmachine kernel: R13: 00005619ea31ee00 R14: 00007ffe8862f690 R15: 0000000000000000
    Apr 12 11:31:38 testmachine kernel: ---[ end trace be009b606808485e ]---

Which would later on be followed by different kinds of hangups,
sometimes with more seemingly unrelated crash dumps such as:

    Apr 12 11:38:50 testmachine kernel: general protection fault: 0000 [#1] SMP
    Apr 12 11:38:50 testmachine kernel: Modules linked in: act_police cls_basic sch_ingress veth nfsv3 nfs_acl nfs lockd grace ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables xt_mac ipt_REJECT nf_reject_ipv4 xt_physdev xt_comment nf_conntrack_ipv4 nf_defrag_ipv4 xt_tcpudp xt_mark xt_set xt_addrtype xt_multiport xt_conntrack nf_conntrack ip_set_hash_net ip_set arc4 md4 nls_utf8 cifs ccm fscache ipta
    Apr 12 11:38:50 testmachine kernel:  snd_hda_codec_realtek snd_hda_codec_generic aesni_intel aes_x86_64 crypto_simd drm_kms_helper glue_helper cryptd drm snd_hda_intel intel_cstate snd_hda_codec i2c_algo_bit fb_sys_fops snd_hda_core joydev syscopyarea snd_hwdep sysfillrect input_leds sysimgblt intel_rapl_perf snd_pcm snd_timer snd pcspkr soundcore mei_me lpc_ich mei shpchp tpm_infineon mac_hid wmi acpi_pad video vhost_net vhost macv
    Apr 12 11:38:50 testmachine kernel: CPU: 7 PID: 4829 Comm: chromium Tainted: P        W  O    4.10.5-1-pve #1
    Apr 12 11:38:50 testmachine kernel: Hardware name: ASUS All Series/Z97-A, BIOS 2801 11/11/2015
    Apr 12 11:38:50 testmachine kernel: task: ffff93679b132d00 task.stack: ffffa479a0e00000
    Apr 12 11:38:50 testmachine kernel: RIP: 0010:kmem_cache_alloc_trace+0x7b/0x190
    Apr 12 11:38:50 testmachine kernel: RSP: 0018:ffffa479a0e03ad0 EFLAGS: 00010202
    Apr 12 11:38:50 testmachine kernel: RAX: 0000000000000000 RBX: 00000000014000c0 RCX: 0000000000005291
    Apr 12 11:38:50 testmachine kernel: RDX: 0000000000005290 RSI: 00000000014000c0 RDI: 000000000001c5c0
    Apr 12 11:38:50 testmachine kernel: RBP: ffffa479a0e03b00 R08: ffff9367bfbdc5c0 R09: ffff936724698580
    Apr 12 11:38:50 testmachine kernel: R10: 0017ffffc0040038 R11: 0000000000000007 R12: 00000000014000c0
    Apr 12 11:38:50 testmachine kernel: R13: ffff93679f003b80 R14: ffffffffc0b9090f R15: ffff93679f003b80
    Apr 12 11:38:50 testmachine kernel: FS:  00007f5a069c4040(0000) GS:ffff9367bfbc0000(0000) knlGS:0000000000000000
    Apr 12 11:38:50 testmachine kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
    Apr 12 11:38:50 testmachine kernel: CR2: 00007f5a068de000 CR3: 00000007ccb8b000 CR4: 00000000001426e0
    Apr 12 11:38:50 testmachine kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
    Apr 12 11:38:50 testmachine kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
    Apr 12 11:38:50 testmachine kernel: Call Trace:
    Apr 12 11:38:50 testmachine kernel:  i915_gem_object_get_pages_internal+0x6f/0x250 [i915]
    Apr 12 11:38:50 testmachine kernel:  ? kmem_cache_alloc+0x185/0x1a0
    Apr 12 11:38:50 testmachine kernel:  ____i915_gem_object_get_pages+0x20/0x60 [i915]
    Apr 12 11:38:50 testmachine kernel:  __i915_gem_object_get_pages+0x52/0x60 [i915]
    Apr 12 11:38:50 testmachine kernel:  i915_gem_batch_pool_get+0x11d/0x180 [i915]
    Apr 12 11:38:50 testmachine kernel:  i915_gem_do_execbuffer.isra.38+0x1027/0x1790 [i915]
    Apr 12 11:38:50 testmachine kernel:  ? shmem_getpage_gfp+0xf9/0xc20
    Apr 12 11:38:50 testmachine kernel:  i915_gem_execbuffer2+0xc5/0x240 [i915]
    Apr 12 11:38:50 testmachine kernel:  drm_ioctl+0x21b/0x4c0 [drm]
    Apr 12 11:38:50 testmachine kernel:  ? i915_gem_execbuffer+0x310/0x310 [i915]
    Apr 12 11:38:50 testmachine kernel:  ? __seccomp_filter+0x67/0x250
    Apr 12 11:38:50 testmachine kernel:  do_vfs_ioctl+0xa3/0x610
    Apr 12 11:38:50 testmachine kernel:  ? __secure_computing+0x3f/0xd0
    Apr 12 11:38:50 testmachine kernel:  ? syscall_trace_enter+0xcd/0x2e0
    Apr 12 11:38:50 testmachine kernel:  SyS_ioctl+0x79/0x90
    Apr 12 11:38:50 testmachine kernel:  do_syscall_64+0x5b/0xc0
    Apr 12 11:38:50 testmachine kernel:  entry_SYSCALL64_slow_path+0x25/0x25
    Apr 12 11:38:50 testmachine kernel: RIP: 0033:0x7f59fba67ca7
    Apr 12 11:38:50 testmachine kernel: RSP: 002b:00007ffd39778868 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
    Apr 12 11:38:50 testmachine kernel: RAX: ffffffffffffffda RBX: 000024e398f52800 RCX: 00007f59fba67ca7
    Apr 12 11:38:50 testmachine kernel: RDX: 00007ffd397788b0 RSI: 0000000040406469 RDI: 00000000000000a4
    Apr 12 11:38:50 testmachine kernel: RBP: 00007ffd397788b0 R08: 0000000000000000 R09: 0000000000000000
    Apr 12 11:38:50 testmachine kernel: R10: 0000000000000000 R11: 0000000000000246 R12: 0000000040406469
    Apr 12 11:38:50 testmachine kernel: R13: 00000000000000a4 R14: 000024e399dd82c0 R15: 0000000000000070
    Apr 12 11:38:50 testmachine kernel: Code: 08 65 4c 03 05 e7 de 9e 68 49 83 78 10 00 4d 8b 10 0f 84 e0 00 00 00 4d 85 d2 0f 84 d7 00 00 00 49 63 47 20 49 8b 3f 48 8d 4a 01 <49> 8b 1c 02 4c 89 d0 65 48 0f c7 0f 0f 94 c0 84 c0 74 bb 49 63 
    Apr 12 11:38:50 testmachine kernel: RIP: kmem_cache_alloc_trace+0x7b/0x190 RSP: ffffa479a0e03ad0
    Apr 12 11:38:50 testmachine kernel: general protection fault: 0000 [#2] SMP
    Apr 12 11:38:50 testmachine kernel: general protection fault: 0000 [#3] SMP

or:

    Apr 12 09:19:35 testmachine kernel: BUG: unable to handle kernel NULL pointer dereference at 000000000000019c
    Apr 12 09:19:35 testmachine kernel: IP: __free_pages+0x5/0x30
    Apr 12 09:19:35 testmachine kernel: PGD 0 
    Apr 12 09:19:35 testmachine kernel:
    Apr 12 09:19:35 testmachine kernel: Oops: 0002 [#1] SMP
    Apr 12 09:19:35 testmachine kernel: Modules linked in: act_police cls_basic sch_ingress veth nfsv3 nfs_acl nfs lockd grace ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables xt_mac ipt_REJECT nf_reject_ipv4 xt_physdev xt_comment nf_conntrack_ipv4 nf_defrag_ipv4 xt_tcpudp xt_mark xt_set xt_addrtype xt_multiport xt_conntrack nf_conntrack ip_set_hash_net ip_set arc4 md4 nls_utf8 cifs ccm fscache ipta
    Apr 12 09:19:35 testmachine kernel:  aes_x86_64 crypto_simd glue_helper cryptd intel_cstate snd_hda_codec_realtek snd_hda_codec_generic i915 intel_rapl_perf snd_hda_intel drm_kms_helper input_leds joydev snd_hda_codec drm snd_hda_core snd_hwdep i2c_algo_bit fb_sys_fops snd_pcm syscopyarea snd_timer sysfillrect sysimgblt snd soundcore mei_me shpchp lpc_ich mei pcspkr tpm_infineon wmi video mac_hid acpi_pad vhost_net vhost macvtap mac
    Apr 12 09:19:35 testmachine kernel: CPU: 2 PID: 69 Comm: kworker/2:1 Tainted: P        W  O    4.10.5-1-pve #1
    Apr 12 09:19:35 testmachine kernel: Hardware name: ASUS All Series/Z97-A, BIOS 2801 11/11/2015
    Apr 12 09:19:35 testmachine kernel: Workqueue: events __i915_gem_free_work [i915]
    Apr 12 09:19:35 testmachine kernel: task: ffff88885b134380 task.stack: ffffa7e243410000
    Apr 12 09:19:35 testmachine kernel: RIP: 0010:__free_pages+0x5/0x30
    Apr 12 09:19:35 testmachine kernel: RSP: 0018:ffffa7e243413d18 EFLAGS: 00010206
    Apr 12 09:19:35 testmachine kernel: RAX: 00000000000ffff8 RBX: ffff888762473460 RCX: ffff888762473470
    Apr 12 09:19:35 testmachine kernel: RDX: ffff888762473460 RSI: 0000000000000014 RDI: 0000000000000180
    Apr 12 09:19:35 testmachine kernel: RBP: ffffa7e243413d38 R08: 0000000000000000 R09: 0000000000000000
    Apr 12 09:19:35 testmachine kernel: R10: ffff8887dd8c1080 R11: 0000000000000000 R12: ffff8887624738f0
    Apr 12 09:19:35 testmachine kernel: R13: 00000000ffffffff R14: ffff8887dd8c0440 R15: 0000000000000000
    Apr 12 09:19:35 testmachine kernel: FS:  0000000000000000(0000) GS:ffff88887fa80000(0000) knlGS:0000000000000000
    Apr 12 09:19:35 testmachine kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
    Apr 12 09:19:35 testmachine kernel: CR2: 000000000000019c CR3: 0000000476e09000 CR4: 00000000001426e0
    Apr 12 09:19:35 testmachine kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
    Apr 12 09:19:35 testmachine kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
    Apr 12 09:19:35 testmachine kernel: Call Trace:
    Apr 12 09:19:35 testmachine kernel:  ? internal_free_pages+0x40/0x80 [i915]
    Apr 12 09:19:35 testmachine kernel:  i915_gem_object_put_pages_internal+0x1f/0x30 [i915]
    Apr 12 09:19:35 testmachine kernel:  __i915_gem_object_put_pages.part.62+0x11d/0x180 [i915]
    Apr 12 09:19:35 testmachine kernel:  ? dma_fence_context_alloc+0x20/0x20
    Apr 12 09:19:35 testmachine kernel:  __i915_gem_free_objects+0x161/0x330 [i915]
    Apr 12 09:19:35 testmachine kernel:  __i915_gem_free_work+0x33/0x50 [i915]
    Apr 12 09:19:35 testmachine kernel:  process_one_work+0x1fc/0x4b0
    Apr 12 09:19:35 testmachine kernel:  worker_thread+0x4b/0x500
    Apr 12 09:19:35 testmachine kernel:  kthread+0x101/0x140
    Apr 12 09:19:35 testmachine kernel:  ? process_one_work+0x4b0/0x4b0
    Apr 12 09:19:35 testmachine kernel:  ? kthread_create_on_node+0x60/0x60
    Apr 12 09:19:35 testmachine kernel:  ret_from_fork+0x2c/0x40
    Apr 12 09:19:35 testmachine kernel: Code: ff 41 b8 05 00 00 00 31 c9 4c 89 ea 4c 89 fe e8 a2 e0 ff ff e9 1e ff ff ff 0f 1f 00 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 <f0> ff 4f 1c 75 0e 55 85 f6 48 89 e5 74 08 e8 48 e4 ff ff 5d f3 
    Apr 12 09:19:35 testmachine kernel: RIP: __free_pages+0x5/0x30 RSP: ffffa7e243413d18
    Apr 12 09:19:35 testmachine kernel: CR2: 000000000000019c
    Apr 12 09:19:35 testmachine kernel: ---[ end trace 89cb022ec57f7bd1 ]---

Wolfgang Bumiller (2):
  net sched actions: fix access to uninitialized data
  net sched actions: fix refcount decrement on error

 net/sched/act_api.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

-- 
2.11.0
