From: Huajun Li <huajun.li.lee@gmail.com>
Subject: [PATCH 1/2] net: Disable false positive memory leak report
Date: Sat, 24 Sep 2011 23:57:06 +0800
Message-ID: <CA+v9cxao_66a1Jb2L4M3fmUvNv8+QzWTFMqu7Dxnh7a5Zyqt0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Huajun Li <huajun.li.lee@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37651 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab1IXP5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2011 11:57:07 -0400
Received: by fxe4 with SMTP id 4so4732097fxe.19
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2011 08:57:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Memory leak detector reports following false positive memory leak, the
patch disables it.

unreferenced object 0xffff880073a70000 (size 8192):
  comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8124db64>] create_object+0x144/0x360
    [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
    [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
    [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc0
    [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
    [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
    [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
    [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff880073a74290 (size 8192):
  comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8124db64>] create_object+0x144/0x360
    [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
    [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
    [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc0
    [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
    [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
    [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
    [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff


Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
---
 net/core/flow.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 555a456..ba3e617 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -365,6 +365,13 @@ static int __cpuinit
flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)

 	if (!fcp->hash_table) {
 		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu));
+		/*
+		 * Avoid a kmemleak false positive. The pointer to this block
+		 * is refferenced by per-CPU varaible, here just mark it as not
+		 * being a leak.
+		 */
+		kmemleak_not_leak(fcp->hash_table);
+
 		if (!fcp->hash_table) {
 			pr_err("NET: failed to allocate flow cache sz %zu\n", sz);
 			return -ENOMEM;
-- 
1.7.4.1
