From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] net: sched: fix use after free when tcf_chain_destroy is called multiple times
Date: Tue, 22 Aug 2017 22:46:49 +0200
Message-ID: <20170822204650.7016-2-jiri@resnulli.us>
References: <20170822204650.7016-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37696 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752765AbdHVUqz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 16:46:55 -0400
Received: by mail-wm0-f68.google.com with SMTP id t138so283977wmt.4
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 13:46:54 -0700 (PDT)
In-Reply-To: <20170822204650.7016-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The goto_chain termination action takes a reference of a chain. In that
case, there is an issue when block_put is called tcf_chain_destroy
directly. The follo-up call of tcf_chain_put by goto_chain action free
works with memory that is already freed. This was caught by kasan:

[  220.337908] BUG: KASAN: use-after-free in tcf_chain_put+0x1b/0x50
[  220.344103] Read of size 4 at addr ffff88036d1f2cec by task systemd-journal/261
[  220.353047] CPU: 0 PID: 261 Comm: systemd-journal Not tainted 4.13.0-rc5jiri+ #54
[  220.360661] Hardware name: Mellanox Technologies Ltd. Mellanox switch/Mellanox x86 mezzanine board, BIOS 4.6.5 08/02/2016
[  220.371784] Call Trace:
[  220.374290]  <IRQ>
[  220.376355]  dump_stack+0xd5/0x150
[  220.391485]  print_address_description+0x86/0x410
[  220.396308]  kasan_report+0x181/0x4c0
[  220.415211]  tcf_chain_put+0x1b/0x50
[  220.418949]  free_tcf+0x95/0xc0

So allow tcf_chain_destroy to be called multiple times, free only in
case the reference count drops to 0.

Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 9fd44c2..45cd34e 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -215,9 +215,17 @@ static void tcf_chain_flush(struct tcf_chain *chain)
 
 static void tcf_chain_destroy(struct tcf_chain *chain)
 {
-	list_del(&chain->list);
+	/* May be already removed from the list by the previous call. */
+	if (!list_empty(&chain->list))
+		list_del_init(&chain->list);
+
 	tcf_chain_flush(chain);
-	kfree(chain);
+
+	/* There might still be a reference held when we got here from
+	 * tcf_block_put. Wait for the user to drop reference before free.
+	 */
+	if (!chain->refcnt)
+		kfree(chain);
 }
 
 struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
-- 
2.9.3
