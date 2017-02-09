From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH RFC net] net/mlx5e: Add preemption enable/disable around TC statistics upcall
Date: Thu,  9 Feb 2017 17:38:43 +0200
Message-ID: <1486654723-25777-1-git-send-email-ogerlitz@mellanox.com>
Cc: Amir Vadai <amir@vadai.me>, Ido Schimmel <idosch@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Roi Dayan <roid@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39696 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753954AbdBIPjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 10:39:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running with CONFIG_PREEMPT set, I get a

BUG: using smp_processor_id() in preemptible [00000000] code: tc/3793

asserion from the TC action (mirred) stats_update callback, when the do

	_bstats_cpu_update(this_cpu_ptr(a->cpu_bstats), bytes, packets)

As done by commit 66860be "nfp: bpf: allow offloaded filters to update stats",
disabling/enabling preemption around the TC upcall solves that.

Fixes: aad7e08d39bd ('net/mlx5e: Hardware offloaded flower filter statistics support')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

I marked it as RFC, since I wasn't fully sure on the nature of the 
problem, nor if this is the direction we should take to the fix.

(gdb) l *(tcf_stats_update+0x56)
0xf2 is in tcf_stats_update (net/sched/act_mirred.c:241).
236                                  u64 lastuse)
237     {
238             struct tcf_mirred *m = to_mirred(a);
239             struct tcf_t *tm = &m->tcf_tm;
240
241             _bstats_cpu_update(this_cpu_ptr(a->cpu_bstats), bytes, packets);
242             tm->lastuse = lastuse;
243     }
244
245     static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,

[86229.444670] BUG: using smp_processor_id() in preemptible [00000000] code: tc/3793
[86229.444738] caller is debug_smp_processor_id+0x17/0x19
[86229.444780] CPU: 7 PID: 3793 Comm: tc Tainted: G           O    4.10.0-rc7+ #21
[86229.444841] Hardware name: Supermicro X8DTU/X8DTU, BIOS 2.1c       08/03/2012
[86229.444884] Call Trace:
[86229.444917]  dump_stack+0xb1/0xfe
[86229.444953]  ? _atomic_dec_and_lock+0x8a/0x8a
[86229.444992]  ? ___ratelimit+0x1cc/0x1db
[86229.445031]  check_preemption_disabled+0x16f/0x185
[86229.445072]  debug_smp_processor_id+0x17/0x19
[86229.445115]  tcf_stats_update+0x56/0x117 [act_mirred]
[86229.445293]  mlx5e_stats_flower+0x785/0x7c8 [mlx5_core]
[86229.445471]  ? mlx5e_delete_flower+0xb6a/0xb6a [mlx5_core]
[86229.445515]  ? tcf_action_dump_old+0x6a/0x75
[86229.445559]  ? tcf_action_dump_1+0x1c6/0x246
[86229.445598]  ? tcf_action_dump+0x15a/0x1e2
[86229.445637]  ? tcf_exts_dump+0x323/0x4ee
[86229.445675]  ? tcf_action_copy_stats+0x83/0x19f
[86229.445715]  ? memset+0x31/0x38
[86229.445750]  ? memcpy+0x45/0x4c
[86229.445920]  mlx5e_rep_ndo_setup_tc+0x17d/0x1ae [mlx5_core]
[86229.445969]  fl_dump+0xb3a/0x106d [cls_flower]
[86229.446142]  ? mlx5e_rep_open+0xd0/0xd0 [mlx5_core]
[86229.446189]  ? fl_dump_key_val+0x71/0x71 [cls_flower]
[86229.446230]  ? tcf_action_dump_1+0x1c6/0x246
[86229.446269]  ? debug_lockdep_rcu_enabled+0x2a/0x6a
[86229.446314]  ? fl_dump+0x95d/0x106d [cls_flower]
[86229.446357]  ? tcf_action_dump+0x15a/0x1e2
[86229.446401]  ? fl_dump_key_val+0x71/0x71 [cls_flower]
[86229.446442]  ? tcf_exts_dump+0x323/0x4ee
[86229.446481]  ? tcf_action_copy_stats+0x83/0x19f
[86229.446521]  ? tcf_action_init+0x3ca/0x3ca
[86229.446560]  ? tcf_exts_change+0x25b/0x25b
[86229.446598]  ? memcpy+0x45/0x4c
[86229.446632]  ? __nla_put+0x20/0x25
[86229.446668]  ? tcf_exts_dump_stats+0x75/0x7d
[86229.446706]  ? memset+0x31/0x38
[86229.446743]  ? __nla_put+0x20/0x25
[86229.446778]  ? nla_put+0xc3/0xd1
[86229.446815]  tcf_fill_node+0x313/0x393
[86229.446853]  tcf_node_dump+0x11c/0x12b
[86229.446895]  fl_walk+0x123/0x195 [cls_flower]
[86229.446936]  tc_dump_tfilter+0x525/0x670
[86229.446976]  ? tfilter_notify+0x158/0x158
[86229.447014]  ? tcf_fill_node+0x393/0x393
[86229.447051]  ? lock_acquire+0x21c/0x347
[86229.447087]  netlink_dump+0x216/0x4b1
[86229.447127]  __netlink_dump_start+0x2de/0x34d
[86229.447167]  rtnetlink_rcv_msg+0x3f7/0x516
[86229.447206]  ? tfilter_notify+0x158/0x158
[86229.447244]  ? rtnl_newlink+0xc98/0xc98
[86229.447280]  ? lock_acquire+0x21c/0x347
[86229.447318]  ? tfilter_notify+0x158/0x158
[86229.447355]  ? netlink_deliver_tap+0x4a0/0x4cc
[86229.447394]  ? rtnl_newlink+0xc98/0xc98
[86229.447430]  netlink_rcv_skb+0xae/0x109
[86229.447467]  rtnetlink_rcv+0x23/0x2a
[86229.447504]  netlink_unicast+0x287/0x368
[86229.447544]  ? netlink_sendskb+0x30/0x30
[86229.447580]  ? pid_nr_ns+0xaf/0xbe
[86229.447616]  netlink_sendmsg+0x76f/0x7a7
[86229.447653]  ? nlmsg_notify+0xe8/0xe8
[86229.447690]  ? nlmsg_notify+0xe8/0xe8
[86229.447727]  sock_sendmsg+0xa5/0xc3
[86229.447764]  ___sys_sendmsg+0x3f1/0x4f2
[86229.447801]  ? copy_msghdr_from_user+0x28c/0x28c
[86229.447841]  ? ___sys_sendmsg+0x4f2/0x4f2
[86229.447879]  ? add_mm_counter_fast+0xbe/0xbe
[86229.447917]  ? __mod_node_page_state+0x43/0xee
[86229.447956]  ? do_wp_page+0x32d/0x9a9
[86229.447992]  ? __lock_acquire+0xae/0x1977
[86229.448030]  ? do_wp_page+0x335/0x9a9
[86229.448066]  ? finish_mkwrite_fault+0x240/0x240
[86229.448106]  ? __handle_mm_fault+0xc80/0x1194
[86229.448146]  ? __handle_mm_fault+0xcba/0x1194
[86229.448185]  ? __fget_light+0xf1/0x11c
[86229.448222]  ? __fdget+0x13/0x15
[86229.448257]  __sys_sendmsg+0xbf/0x11d
[86229.448294]  ? __sys_sendmsg+0xbf/0x11d
[86229.448332]  ? SyS_shutdown+0x13f/0x13f
[86229.448370]  ? __do_page_fault+0x67d/0x762
[86229.448407]  ? handle_mm_fault+0x584/0x5e7
[86229.448445]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[86229.448486]  SyS_sendmsg+0x12/0x1c
[86229.448526]  entry_SYSCALL_64_fastpath+0x18/0xad
[86229.448564] RIP: 0033:0x7f50a1e156a0
[86229.448598] RSP: 002b:00007ffcf35289c8 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
[86229.448662] RAX: ffffffffffffffda RBX: ffffffff81160a11 RCX: 00007f50a1e156a0
[86229.448709] RDX: 0000000000000000 RSI: 00007ffcf3528a10 RDI: 0000000000000003
[86229.448756] RBP: ffff880537df7f98 R08: 000000000065ee40 R09: 0000000000000000
[86229.448801] R10: 00000000000005e1 R11: 0000000000000246 R12: 000000000065a320
[86229.448847] R13: 000000000065f0b0 R14: 0000000000000003 R15: 0000000000000000
[86229.448897]  ? trace_hardirqs_off_caller+0x1f/0x135

 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 237bd5b..9dddc65 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1093,10 +1093,14 @@ int mlx5e_stats_flower(struct mlx5e_priv *priv,
 
 	mlx5_fc_query_cached(counter, &bytes, &packets, &lastuse);
 
+	preempt_disable();
+
 	tcf_exts_to_list(f->exts, &actions);
 	list_for_each_entry(a, &actions, list)
 		tcf_action_stats_update(a, bytes, packets, lastuse);
 
+	preempt_enable();
+
 	return 0;
 }
 
-- 
2.3.7
