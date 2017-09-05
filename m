From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] net: sched: don't use GFP_KERNEL under spin lock
Date: Tue,  5 Sep 2017 03:54:42 -0700
Message-ID: <20170905105442.30972-1-jakub.kicinski@netronome.com>
Cc: jiri@resnulli.us, Chris Mi <chrism@mellanox.com>,
        xiyou.wangcong@gmail.com, jhs@mojatatu.com,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35556 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbdIEK5C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 06:57:02 -0400
Received: by mail-pg0-f43.google.com with SMTP id 188so5363589pgb.2
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 03:57:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new TC IDR code uses GFP_KERNEL under spinlocks.  Which leads
to:

[  582.621091] BUG: sleeping function called from invalid context at ../mm/slab.h:416
[  582.629721] in_atomic(): 1, irqs_disabled(): 0, pid: 3379, name: tc
[  582.636939] 2 locks held by tc/3379:
[  582.641049]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff910354ce>] rtnetlink_rcv_msg+0x92e/0x1400
[  582.650958]  #1:  (&(&tn->idrinfo->lock)->rlock){+.-.+.}, at: [<ffffffff9110a5e0>] tcf_idr_create+0x2f0/0x8e0
[  582.662217] Preemption disabled at:
[  582.662222] [<ffffffff9110a5e0>] tcf_idr_create+0x2f0/0x8e0
[  582.672592] CPU: 9 PID: 3379 Comm: tc Tainted: G        W       4.13.0-rc7-debug-00648-g43503a79b9f0 #287
[  582.683432] Hardware name: Dell Inc. PowerEdge R730/072T6D, BIOS 2.3.4 11/08/2016
[  582.691937] Call Trace:
...
[  582.713332]  ? tcf_idr_create+0x2f0/0x8e0
[  582.717925]  ___might_sleep+0x40f/0x660
[  582.722336]  ? finish_task_switch+0xb90/0xb90
[  582.727315]  ? mark_held_locks+0xdd/0x190
[  582.731908]  __might_sleep+0xba/0x240
[  582.736125]  ? radix_tree_node_alloc.constprop.6+0x4a/0x450
[  582.742460]  kmem_cache_alloc+0x286/0x540
[  582.747055]  radix_tree_node_alloc.constprop.6+0x4a/0x450
[  582.753209]  idr_get_free_cmn+0x627/0xf80
...
[  582.815525]  idr_alloc_cmn+0x1a8/0x270
[  582.819821]  ? __raw_spin_lock_init+0x21/0x120
[  582.824914]  ? idr_replace+0x20/0x20
[  582.829013]  ? do_raw_spin_lock+0x1f0/0x1f0
[  582.833804]  tcf_idr_create+0x31b/0x8e0
...

Fixes: 65a206c01e8e ("net/sched: Change act_api and act_xxx modules to use IDR")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 net/sched/act_api.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 0eb545bcb247..a48e4b45722d 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -298,7 +298,7 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 	if (!index) {
 		spin_lock_bh(&idrinfo->lock);
 		err = idr_alloc_ext(idr, NULL, &idr_index, 1, 0,
-				    GFP_KERNEL);
+				    GFP_ATOMIC);
 		spin_unlock_bh(&idrinfo->lock);
 		if (err) {
 err3:
@@ -309,7 +309,7 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 	} else {
 		spin_lock_bh(&idrinfo->lock);
 		err = idr_alloc_ext(idr, NULL, NULL, index, index + 1,
-				    GFP_KERNEL);
+				    GFP_ATOMIC);
 		spin_unlock_bh(&idrinfo->lock);
 		if (err)
 			goto err3;
-- 
2.14.1
