From: Cong Wang <cwang@twopensource.com>
Subject: use after free again...
Date: Mon, 24 Aug 2015 23:02:02 -0700
Message-ID: <CAHA+R7Mr03t5NQMhdeY0ygHM5+nzMecoQL7TFOMNmR1+OgCQ7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:35025 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbbHYGCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 02:02:03 -0400
Received: by ykbi184 with SMTP id i184so145692977ykb.2
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 23:02:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jiri,

In your commit 61adedf3e3f1d3f032c5a6a299978d91eff6d555 ("route: move
lwtunnel state to dst_entry"), how the hell could the following piece
be correct? :-/


@@ -264,6 +266,7 @@ again:
                kfree(dst);
        else
                kmem_cache_free(dst->ops->kmem_cachep, dst);
+       lwtstate_put(dst->lwtstate);


There is clearly a kfree(dst) before dereferencing dst... And I got a
nice crash:

[   33.160081] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
[   33.164285] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.2.0-rc7+ #166
[   33.164285] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   33.164285] task: ffff88010656d280 ti: ffff880106570000 task.ti:
ffff880106570000
[   33.164285] RIP: 0010:[<ffffffff8182f91b>]  [<ffffffff8182f91b>]
dst_destroy+0xa6/0xef
[   33.164285] RSP: 0018:ffff880107603e38  EFLAGS: 00010202
[   33.164285] RAX: 0000000000000001 RBX: ffff8800d225a000 RCX: ffffffff82250fd0
[   33.164285] RDX: 0000000000000001 RSI: ffffffff82250fd0 RDI: 6b6b6b6b6b6b6b6b
[   33.164285] RBP: ffff880107603e58 R08: 0000000000000001 R09: 0000000000000001
[   33.164285] R10: 000000000000b530 R11: ffff880107609000 R12: 0000000000000000
[   33.164285] R13: ffffffff82343c40 R14: 0000000000000000 R15: ffffffff8182fb4f
[   33.164285] FS:  0000000000000000(0000) GS:ffff880107600000(0000)
knlGS:0000000000000000
[   33.164285] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   33.164285] CR2: 00007fcabd9d3000 CR3: 00000000d7279000 CR4: 00000000000006e0
[   33.164285] Stack:
[   33.164285]  ffffffff82250fd0 ffff8801077d6f00 ffffffff82253c40
ffff8800d225a000
[   33.164285]  ffff880107603e68 ffffffff8182fb5d ffff880107603f08
ffffffff810d795e
[   33.164285]  ffffffff810d7648 ffff880106574000 ffff88010656d280
ffff88010656d280
[   33.164285] Call Trace:
[   33.164285]  <IRQ>
[   33.164285]  [<ffffffff8182fb5d>] dst_destroy_rcu+0xe/0x1d
[   33.164285]  [<ffffffff810d795e>] rcu_process_callbacks+0x618/0x7eb
[   33.164285]  [<ffffffff810d7648>] ? rcu_process_callbacks+0x302/0x7eb
[   33.164285]  [<ffffffff8182fb4f>] ? dst_gc_task+0x1eb/0x1eb
[   33.164285]  [<ffffffff8107e11b>] __do_softirq+0x178/0x39f
[   33.164285]  [<ffffffff8107e52e>] irq_exit+0x41/0x95
[   33.164285]  [<ffffffff81a4f215>] smp_apic_timer_interrupt+0x34/0x40
[   33.164285]  [<ffffffff81a4d5cd>] apic_timer_interrupt+0x6d/0x80
[   33.164285]  <EOI>
[   33.164285]  [<ffffffff8100b968>] ? default_idle+0x21/0x32
[   33.164285]  [<ffffffff8100b966>] ? default_idle+0x1f/0x32
[   33.164285]  [<ffffffff8100bf19>] arch_cpu_idle+0xf/0x11
[   33.164285]  [<ffffffff810b0bc7>] default_idle_call+0x1f/0x21
[   33.164285]  [<ffffffff810b0dce>] cpu_startup_entry+0x1ad/0x273
[   33.164285]  [<ffffffff8102fe67>] start_secondary+0x135/0x156


I cooked a _quick_ patch to fix it. I can send it formally if it looks
good to you, if not, feel free to send a better fix before me.

diff --git a/net/core/dst.c b/net/core/dst.c
index 50dcdbb..477035e 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -262,11 +262,12 @@ again:
        if (dst->dev)
                dev_put(dst->dev);

+       lwtstate_put(dst->lwtstate);
+
        if (dst->flags & DST_METADATA)
                kfree(dst);
        else
                kmem_cache_free(dst->ops->kmem_cachep, dst);
-       lwtstate_put(dst->lwtstate);

        dst = child;
        if (dst) {
