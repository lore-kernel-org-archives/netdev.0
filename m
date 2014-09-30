From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: fix another crash in cls_tcindex
Date: Tue, 30 Sep 2014 16:07:23 -0700
Message-ID: <1412118444-29179-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:52475 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaI3XHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 19:07:40 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so5708452pad.3
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 16:07:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following crash:

[  166.670795] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  166.674230] IP: [<ffffffff814b739f>] __list_del_entry+0x5c/0x98
[  166.674230] PGD d0ea5067 PUD ce7fc067 PMD 0
[  166.674230] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  166.674230] CPU: 1 PID: 775 Comm: tc Not tainted 3.17.0-rc6+ #642
[  166.674230] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  166.674230] task: ffff8800d03c4d20 ti: ffff8800cae7c000 task.ti: ffff8800cae7c000
[  166.674230] RIP: 0010:[<ffffffff814b739f>]  [<ffffffff814b739f>] __list_del_entry+0x5c/0x98
[  166.674230] RSP: 0018:ffff8800cae7f7d0  EFLAGS: 00010207
[  166.674230] RAX: 0000000000000000 RBX: ffff8800cba8d700 RCX: ffff8800cba8d700
[  166.674230] RDX: 0000000000000000 RSI: dead000000200200 RDI: ffff8800cba8d700
[  166.674230] RBP: ffff8800cae7f7d0 R08: 0000000000000001 R09: 0000000000000001
[  166.674230] R10: 0000000000000000 R11: 000000000000859a R12: ffffffffffffffe8
[  166.674230] R13: ffff8800cba8c5b8 R14: 0000000000000001 R15: ffff8800cba8d700
[  166.674230] FS:  00007fdb5f04a740(0000) GS:ffff88011a800000(0000) knlGS:0000000000000000
[  166.674230] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  166.674230] CR2: 0000000000000000 CR3: 00000000cf929000 CR4: 00000000000006e0
[  166.674230] Stack:
[  166.674230]  ffff8800cae7f7e8 ffffffff814b73e8 ffff8800cba8d6e8 ffff8800cae7f828
[  166.674230]  ffffffff817caeec 0000000000000046 ffff8800cba8c5b0 ffff8800cba8c5b8
[  166.674230]  0000000000000000 0000000000000001 ffff8800cf8e33e8 ffff8800cae7f848
[  166.674230] Call Trace:
[  166.674230]  [<ffffffff814b73e8>] list_del+0xd/0x2b
[  166.674230]  [<ffffffff817caeec>] tcf_action_destroy+0x4c/0x71
[  166.674230]  [<ffffffff817ca0ce>] tcf_exts_destroy+0x20/0x2d
[  166.674230]  [<ffffffff817ec2b5>] tcindex_delete+0x196/0x1b7

struct list_head can not be simply copied and we should always init it.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_tcindex.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 8d0e83d..30f10fb 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -254,10 +254,15 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	cp->tp = tp;
 
 	if (p->perfect) {
+		int i;
+
 		cp->perfect = kmemdup(p->perfect,
 				      sizeof(*r) * cp->hash, GFP_KERNEL);
 		if (!cp->perfect)
 			goto errout;
+		for (i = 0; i < cp->hash; i++)
+			tcf_exts_init(&cp->perfect[i].exts,
+				      TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 		balloc = 1;
 	}
 	cp->h = p->h;
@@ -353,6 +358,9 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		f = kzalloc(sizeof(*f), GFP_KERNEL);
 		if (!f)
 			goto errout_alloc;
+		f->key = handle;
+		tcindex_filter_result_init(&f->result);
+		f->next = NULL;
 	}
 
 	if (tb[TCA_TCINDEX_CLASSID]) {
@@ -376,9 +384,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		struct tcindex_filter *nfp;
 		struct tcindex_filter __rcu **fp;
 
-		f->key = handle;
-		f->result = new_filter_result;
-		f->next = NULL;
+		tcf_exts_change(tp, &f->result.exts, &r->exts);
 
 		fp = cp->h + (handle % cp->hash);
 		for (nfp = rtnl_dereference(*fp);
-- 
1.8.3.1
