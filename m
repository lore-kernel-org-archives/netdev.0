From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH 1/2] net: sched: fix handling of singleton qdiscs with
 qdisc_hash
Date: Tue, 16 Aug 2016 23:52:58 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608162349040.22028@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1608162339050.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Horman <simon.horman@netronome.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1608162339050.22028@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>

qdisc_match_from_root() is now iterating over per-netdevice qdisc 
hashtable instead of going through a linked-list of qdiscs (independently 
on the actual underlying netdev), which was the case before the switch to 
hashtable for qdiscs.

For singleton qdiscs, there is no underlying netdev associated though, and 
therefore dumping a singleton qdisc will panic, as qdisc_dev(root) will 
always be NULL.

 BUG: unable to handle kernel NULL pointer dereference at 0000000000000410
 IP: [<ffffffff8167efac>] qdisc_match_from_root+0x2c/0x70
 PGD 1aceba067 PUD 1aceb7067 PMD 0
 Oops: 0000 [#1] PREEMPT SMP
[ ... ]
 task: ffff8801ec996e00 task.stack: ffff8801ec934000
 RIP: 0010:[<ffffffff8167efac>]  [<ffffffff8167efac>] qdisc_match_from_root+0x2c/0x70
 RSP: 0018:ffff8801ec937ab0  EFLAGS: 00010203
 RAX: 0000000000000408 RBX: ffff88025e612000 RCX: ffffffffffffffd8
 RDX: 0000000000000000 RSI: 00000000ffff0000 RDI: ffffffff81cf8100
 RBP: ffff8801ec937ab0 R08: 000000000001c160 R09: ffff8802668032c0
 R10: ffffffff81cf8100 R11: 0000000000000030 R12: 00000000ffff0000
 R13: ffff88025e612000 R14: ffffffff81cf3140 R15: 0000000000000000
 FS:  00007f24b9af6740(0000) GS:ffff88026f280000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 0000000000000410 CR3: 00000001aceec000 CR4: 00000000001406e0
 Stack:
  ffff8801ec937ad0 ffffffff81681210 ffff88025dd51a00 00000000fffffff1
  ffff8801ec937b88 ffffffff81681e4e ffffffff81c42bc0 ffff880262431500
  ffffffff81cf3140 ffff88025dd51a10 ffff88025dd51a24 00000000ec937b38
 Call Trace:
  [<ffffffff81681210>] qdisc_lookup+0x40/0x50
  [<ffffffff81681e4e>] tc_modify_qdisc+0x21e/0x550
  [<ffffffff8166ae25>] rtnetlink_rcv_msg+0x95/0x220
  [<ffffffff81209602>] ? __kmalloc_track_caller+0x172/0x230
  [<ffffffff8166ad90>] ? rtnl_newlink+0x870/0x870
  [<ffffffff816897b7>] netlink_rcv_skb+0xa7/0xc0
  [<ffffffff816657c8>] rtnetlink_rcv+0x28/0x30
  [<ffffffff8168919b>] netlink_unicast+0x15b/0x210
  [<ffffffff81689569>] netlink_sendmsg+0x319/0x390
  [<ffffffff816379f8>] sock_sendmsg+0x38/0x50
  [<ffffffff81638296>] ___sys_sendmsg+0x256/0x260
  [<ffffffff811b1275>] ? __pagevec_lru_add_fn+0x135/0x280
  [<ffffffff811b1a90>] ? pagevec_lru_move_fn+0xd0/0xf0
  [<ffffffff811b1140>] ? trace_event_raw_event_mm_lru_insertion+0x180/0x180
  [<ffffffff811b1b85>] ? __lru_cache_add+0x75/0xb0
  [<ffffffff817708a6>] ? _raw_spin_unlock+0x16/0x40
  [<ffffffff811d8dff>] ? handle_mm_fault+0x39f/0x1160
  [<ffffffff81638b15>] __sys_sendmsg+0x45/0x80
  [<ffffffff81638b62>] SyS_sendmsg+0x12/0x20
  [<ffffffff810038e7>] do_syscall_64+0x57/0xb0

Fix this by special-casing singleton qdiscs (those that don't have 
underlying netdevice) and introduce immediate handling of those rather 
than trying to go over an underlying netdevice. We're in the same 
situation in tc_dump_qdisc_root() and tc_dump_tclass_root().

Ultimately, this will have to be slightly reworked so that we are actually 
able to show singleton qdiscs (noop) in the dump properly; but we're not 
currently doing that anyway, so no regression there, and better do this in 
a gradual manner.

Fixes: 59cc1f61f ("net: sched: convert qdisc linked list to hashtable")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Tested-by: Daniel Borkmann <daniel@iogearbox.net>
Reported-by: David Ahern <dsa@cumulusnetworks.com>
Tested-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 net/sched/sch_api.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c093d32..2b75d68 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -262,6 +262,9 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 {
 	struct Qdisc *q;
 
+	if (!qdisc_dev(root))
+		return (root->handle == handle ? root : NULL);
+
 	if (!(root->flags & TCQ_F_BUILTIN) &&
 	    root->handle == handle)
 		return root;
@@ -1456,6 +1459,10 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			goto done;
 		q_idx++;
 	}
+
+	if (!qdisc_dev(root))
+		goto out;
+
 	hash_for_each(qdisc_dev(root)->qdisc_hash, b, q, hash) {
 		if (q_idx < s_q_idx) {
 			q_idx++;
@@ -1781,6 +1788,9 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
 	if (tc_dump_tclass_qdisc(root, skb, tcm, cb, t_p, s_t) < 0)
 		return -1;
 
+	if (!qdisc_dev(root))
+		return 0;
+
 	hash_for_each(qdisc_dev(root)->qdisc_hash, b, q, hash) {
 		if (tc_dump_tclass_qdisc(q, skb, tcm, cb, t_p, s_t) < 0)
 			return -1;
-- 
1.9.2
