From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Question about memory leak detector giving false positive report for net/core/flow.c
Date: Mon, 26 Sep 2011 23:17:24 +0800
Message-ID: <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "\"Eric Dumaze\"t" <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Huajun Li <huajun.li.lee@gmail.com>
To: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48867 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab1IZPRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 11:17:25 -0400
Received: by fxe4 with SMTP id 4so6156685fxe.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 08:17:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Memory leak detector gives following memory leak report, it seems the
report is triggered by net/core/flow.c, but actually, it should be a
false positive report.
So, is there any idea from kmemleak side to fix/disable this false
positive report like this?
Yes, kmemleak_not_leak(...) could disable it, but is it suitable for this case ?

BTW, I wrote a simple test code to emulate net/core/flow.c behavior at
this stage which triggers the report, and it could also make kmemleak
give similar report, please check below test code:

kernel version:
#uname -a
Linux 3.1.0-rc7 #22 SMP Tue Sep 26 05:43:01 CST 2011 x86_64 x86_64
x86_64 GNU/Linux

memory leak report:
-------------------------------------------------------------------------------------------
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



Simple test code to reproduce a similar report:
-----------------------------------------------------------------------------------------
MODULE_LICENSE("GPL");

struct test {
        int *pt;
};

static struct test __percpu *percpu;

static int __init test_init(void)
{
        int i;

        percpu = alloc_percpu(struct test);
        if (!percpu)
                return -ENOMEM;

        for_each_online_cpu(i) {
                struct test *p = per_cpu_ptr(percpu, i);
                p->pt = kmalloc(sizeof(int), GFP_KERNEL);
        }

        return 0;
}

static void __exit test_exit(void)
{
        int i;

        for_each_possible_cpu(i) {
                struct test *p = per_cpu_ptr(percpu, i);
                if (p->pt)
                        kfree(p->pt);
        }

        if (percpu)
                free_percpu(percpu);
}
module_init(test_init);
module_exit(test_exit);
