From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: WARNING: kernel stack frame pointer at ffff880156a5fea0 in bash:2103
 has bad value 00007ffec7d87e50
Date: Tue, 26 Sep 2017 23:59:29 +0200
Message-ID: <59CACDC1.2030909@iogearbox.net>
References: <2656822.vqnppgTvlm@blindfold> <20170926040900.mlhx3bw7j7zn42qa@ast-mbp> <1598510.AHGpDp18sh@blindfold>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jpoimboe@redhat.com, mingo@kernel.org
To: Richard Weinberger <richard@sigma-star.at>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1598510.AHGpDp18sh@blindfold>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/26/2017 11:51 PM, Richard Weinberger wrote:
> Alexei,
>
> CC'ing Josh and Ingo.
>
> Am Dienstag, 26. September 2017, 06:09:02 CEST schrieb Alexei Starovoitov:
>> On Mon, Sep 25, 2017 at 11:23:31PM +0200, Richard Weinberger wrote:
>>> Hi!
>>>
>>> While playing with bcc's opensnoop tool on Linux 4.14-rc2 I managed to
>>> trigger this splat:
>>>
>>> [  297.629773] WARNING: kernel stack frame pointer at ffff880156a5fea0 in
>>> bash:2103 has bad value 00007ffec7d87e50
>>> [  297.629777] unwind stack type:0 next_sp:          (null) mask:0x6
>>> graph_idx:0
>>> [  297.629783] ffff88015b207ae0: ffff88015b207b68 (0xffff88015b207b68)
>>> [  297.629790] ffff88015b207ae8: ffffffffb163c00e
>>> (__save_stack_trace+0x6e/
>>> 0xd0)
>>> [  297.629792] ffff88015b207af0: 0000000000000000 ...
>>> [  297.629795] ffff88015b207af8: ffff880156a58000 (0xffff880156a58000)
>>> [  297.629799] ffff88015b207b00: ffff880156a60000 (0xffff880156a60000)
>>> [  297.629800] ffff88015b207b08: 0000000000000000 ...
>>> [  297.629803] ffff88015b207b10: 0000000000000006 (0x6)
>>> [  297.629806] ffff88015b207b18: ffff880151b02700 (0xffff880151b02700)
>>> [  297.629809] ffff88015b207b20: 0000010100000000 (0x10100000000)
>>> [  297.629812] ffff88015b207b28: ffff880156a5fea0 (0xffff880156a5fea0)
>>> [  297.629815] ffff88015b207b30: ffff88015b207ae0 (0xffff88015b207ae0)
>>> [  297.629818] ffff88015b207b38: ffffffffc0050282 (0xffffffffc0050282)
>>> [  297.629819] ffff88015b207b40: 0000000000000000 ...
>>> [  297.629822] ffff88015b207b48: 0000000001000000 (0x1000000)
>>> [  297.629825] ffff88015b207b50: ffff880157b98280 (0xffff880157b98280)
>>> [  297.629828] ffff88015b207b58: ffff880157b98380 (0xffff880157b98380)
>>> [  297.629831] ffff88015b207b60: ffff88015ad2b500 (0xffff88015ad2b500)
>>> [  297.629834] ffff88015b207b68: ffff88015b207b78 (0xffff88015b207b78)
>>> [  297.629838] ffff88015b207b70: ffffffffb163c086
>>> (save_stack_trace+0x16/0x20) [  297.629841] ffff88015b207b78:
>>> ffff88015b207da8 (0xffff88015b207da8) [  297.629847] ffff88015b207b80:
>>> ffffffffb18a8ed6 (save_stack+0x46/0xd0) [  297.629850] ffff88015b207b88:
>>> 000000400000000c (0x400000000c)
>>> [  297.629852] ffff88015b207b90: ffff88015b207ba0 (0xffff88015b207ba0)
>>> [  297.629855] ffff88015b207b98: ffff880100000000 (0xffff880100000000)
>>> [  297.629859] ffff88015b207ba0: ffffffffb163c086
>>> (save_stack_trace+0x16/0x20) [  297.629864] ffff88015b207ba8:
>>> ffffffffb18a8ed6 (save_stack+0x46/0xd0) [  297.629868] ffff88015b207bb0:
>>> ffffffffb18a9752 (kasan_slab_free+0x72/0xc0)
>> Thanks for the report!
>> I'm not sure I understand what's going on here.
>> It seems you have kasan enabled and it's trying to do save_stack()
>> and something crashing?
>> I don't see any bpf related helpers in the stack trace.
>> Which architecture is this? and .config ?
>> Is bpf jit enabled? If so, make sure that net.core.bpf_jit_kallsyms=1
>
> I found some time to dig a little further.
> It seems to happen only when CONFIG_DEBUG_SPINLOCK is enabled, please see the
> attached .config. The JIT is off.
> KAsan is also not involved at all, the regular stack saving machinery from the
> trace framework initiates the stack unwinder.
>
> The issue arises as soon as in pre_handler_kretprobe() raw_spin_lock_irqsave()
> is being called.
> It happens on all releases that have commit c32c47c68a0a ("x86/unwind: Warn on
> bad frame pointer").
> Interestingly it does not happen when I run
> samples/kprobes/kretprobe_example.ko. So, BPF must be involved somehow.

Some time ago, Josh fixed this one here, seems perhaps related in
some way; it was triggerable back then from one of the BPF tracing
samples if I recall correctly:

commit a8b7a92318b6d7779f6d8e9aa6ba0e3de01a8943
Author: Josh Poimboeuf <jpoimboe@redhat.com>
Date:   Wed Apr 12 13:47:12 2017 -0500

     x86/unwind: Silence entry-related warnings

     A few people have reported unwinder warnings like the following:

       WARNING: kernel stack frame pointer at ffffc90000fe7ff0 in rsync:1157 has bad value           (null)
       unwind stack type:0 next_sp:          (null) mask:2 graph_idx:0
       ffffc90000fe7f98: ffffc90000fe7ff0 (0xffffc90000fe7ff0)
       ffffc90000fe7fa0: ffffffffb7000f56 (trace_hardirqs_off_thunk+0x1a/0x1c)
       ffffc90000fe7fa8: 0000000000000246 (0x246)
       ffffc90000fe7fb0: 0000000000000000 ...
       ffffc90000fe7fc0: 00007ffe3af639bc (0x7ffe3af639bc)
       ffffc90000fe7fc8: 0000000000000006 (0x6)
       ffffc90000fe7fd0: 00007f80af433fc5 (0x7f80af433fc5)
       ffffc90000fe7fd8: 00007ffe3af638e0 (0x7ffe3af638e0)
       ffffc90000fe7fe0: 00007ffe3af638e0 (0x7ffe3af638e0)
       ffffc90000fe7fe8: 00007ffe3af63970 (0x7ffe3af63970)
       ffffc90000fe7ff0: 0000000000000000 ...
       ffffc90000fe7ff8: ffffffffb7b74b9a (entry_SYSCALL_64_after_swapgs+0x17/0x4f)

     This warning can happen when unwinding a code path where an interrupt
     occurred in x86 entry code before it set up the first stack frame.
     Silently ignore any warnings for this case.

     Reported-by: Daniel Borkmann <daniel@iogearbox.net>
     Reported-by: Dave Jones <davej@codemonkey.org.uk>
     Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
     Acked-by: Thomas Gleixner <tglx@linutronix.de>
     Cc: Andy Lutomirski <luto@kernel.org>
     Cc: Borislav Petkov <bp@alien8.de>
     Cc: Brian Gerst <brgerst@gmail.com>
     Cc: Denys Vlasenko <dvlasenk@redhat.com>
     Cc: H. Peter Anvin <hpa@zytor.com>
     Cc: Linus Torvalds <torvalds@linux-foundation.org>
     Cc: Peter Zijlstra <peterz@infradead.org>
     Fixes: c32c47c68a0a ("x86/unwind: Warn on bad frame pointer")
     Link: http://lkml.kernel.org/r/dbd6838826466a60dc23a52098185bc973ce2f1e.1492020577.git.jpoimboe@redhat.com
     Signed-off-by: Ingo Molnar <mingo@kernel.org>

> Here is another variant of the warning, it matches the attached .config:
>
> [   42.729039] WARNING: kernel stack frame pointer at ffff99ef4076bea0 in
> opensnoop:2008 has bad value 0000000000000008
> [   42.729041] unwind stack type:0 next_sp:          (null) mask:0x2
> graph_idx:0
> [   42.729042] ffff99ef4076bcb0: ffff99ef4076bd38 (0xffff99ef4076bd38)
> [   42.729044] ffff99ef4076bcb8: ffffffffac42781e (__save_stack_trace+0x6e/
> 0xd0)
> [   42.729044] ffff99ef4076bcc0: 0000000000000000 ...
> [   42.729045] ffff99ef4076bcc8: ffff99ef40768000 (0xffff99ef40768000)
> [   42.729045] ffff99ef4076bcd0: ffff99ef4076c000 (0xffff99ef4076c000)
> [   42.729045] ffff99ef4076bcd8: 0000000000000000 ...
> [   42.729046] ffff99ef4076bce0: 0000000000000002 (0x2)
> [   42.729046] ffff99ef4076bce8: ffff8a1c39163fc0 (0xffff8a1c39163fc0)
> [   42.729047] ffff99ef4076bcf0: 0000000100000000 (0x100000000)
> [   42.729047] ffff99ef4076bcf8: ffff99ef4076bea0 (0xffff99ef4076bea0)
> [   42.729048] ffff99ef4076bd00: ffff99ef4076bcb0 (0xffff99ef4076bcb0)
> [   42.729048] ffff99ef4076bd08: ffffffffc00b302f (0xffffffffc00b302f)
> [   42.729048] ffff99ef4076bd10: 0000000000000000 ...
> [   42.729049] ffff99ef4076bd18: ffff8a1c39163fc0 (0xffff8a1c39163fc0)
> [   42.729049] ffff99ef4076bd20: 0000000000000000 ...
> [   42.729052] ffff99ef4076bd28: ffffffffadb9ccc0 (lock_classes
> +0x55500/0x29fec0)
> [   42.729052] ffff99ef4076bd30: 0000000000000000 ...
> [   42.729052] ffff99ef4076bd38: ffff99ef4076bd48 (0xffff99ef4076bd48)
> [   42.729053] ffff99ef4076bd40: ffffffffac427896 (save_stack_trace+0x16/0x20)
> [   42.729054] ffff99ef4076bd48: ffff99ef4076bd98 (0xffff99ef4076bd98)
> [   42.729055] ffff99ef4076bd50: ffffffffac4a18d5 (__lock_acquire.isra.
> 34+0x525/0x700)
> [   42.729055] ffff99ef4076bd58: 0000000000000000 ...
> [   42.729055] ffff99ef4076bd68: ffff99ef00000411 (0xffff99ef00000411)
> [   42.729056] ffff99ef4076bd70: 0000000000000046 (0x46)
> [   42.729056] ffff99ef4076bd78: 0000000000000000 ...
> [   42.729057] ffff99ef4076bd98: ffff99ef4076be00 (0xffff99ef4076be00)
> [   42.729057] ffff99ef4076bda0: ffffffffac4a224a (lock_acquire+0xca/0x170)
> [   42.729059] ffff99ef4076bda8: ffffffffac50a2cd (pre_handler_kretprobe+0x3d/
> 0x1b0)
> [   42.729059] ffff99ef4076bdb0: 0000000100000000 (0x100000000)
> [   42.729060] ffff99ef4076bdb8: ffff8a1c00000000 (0xffff8a1c00000000)
> [   42.729063] ffff99ef4076bdc0: 0000000000000046 (0x46)
> [   42.729063] ffff99ef4076bdc8: 00000001ac47ee61 (0x1ac47ee61)
> [   42.729064] ffff99ef4076bdd0: ffff8a1c37b0e0d0 (0xffff8a1c37b0e0d0)
> [   42.729064] ffff99ef4076bdd8: ffff8a1c37b0e0b8 (0xffff8a1c37b0e0b8)
> [   42.729067] ffff99ef4076bde0: 0000000000000082 (0x82)
> [   42.729067] ffff99ef4076bde8: ffff8a1c37b0e0b8 (0xffff8a1c37b0e0b8)
> [   42.729067] ffff99ef4076bdf0: ffff99ef4076beb0 (0xffff99ef4076beb0)
> [   42.729068] ffff99ef4076bdf8: ffff8a1c39163fc0 (0xffff8a1c39163fc0)
> [   42.729068] ffff99ef4076be00: ffff99ef4076be28 (0xffff99ef4076be28)
> [   42.729070] ffff99ef4076be08: fffffffface13e56 (_raw_spin_lock_irqsave
> +0x46/0x60)
> [   42.729071] ffff99ef4076be10: ffffffffac50a2cd (pre_handler_kretprobe+0x3d/
> 0x1b0)
> [   42.729072] ffff99ef4076be18: ffff8a1c37b0e010 (0xffff8a1c37b0e010)
> [   42.729072] ffff99ef4076be20: ffff8a1c37b0e010 (0xffff8a1c37b0e010)
> [   42.729073] ffff99ef4076be28: ffff99ef4076be60 (0xffff99ef4076be60)
> [   42.729074] ffff99ef4076be30: ffffffffac50a2cd (pre_handler_kretprobe+0x3d/
> 0x1b0)
> [   42.729074] ffff99ef4076be38: ffff8a1c37b0e010 (0xffff8a1c37b0e010)
> [   42.729074] ffff99ef4076be40: ffff8a1c38cc1780 (0xffff8a1c38cc1780)
> [   42.729075] ffff99ef4076be48: ffff99ef4076beb0 (0xffff99ef4076beb0)
> [   42.729075] ffff99ef4076be50: 000055b4ef12d1b0 (0x55b4ef12d1b0)
> [   42.729076] ffff99ef4076be58: 000055b4ee9920a0 (0x55b4ee9920a0)
> [   42.729076] ffff99ef4076be60: ffff99ef4076be88 (0xffff99ef4076be88)
> [   42.729077] ffff99ef4076be68: ffffffffac509f6a (opt_pre_handler+0x3a/0x60)
> [   42.729078] ffff99ef4076be70: 0000000000000246 (0x246)
> [   42.729078] ffff99ef4076be78: 000055b4ef12cd70 (0x55b4ef12cd70)
> [   42.729079] ffff99ef4076be80: 0000000000000001 (0x1)
> [   42.729079] ffff99ef4076be88: ffff99ef4076bea0 (0xffff99ef4076bea0)
> [   42.729080] ffff99ef4076be90: ffffffffac442721 (optimized_callback
> +0x81/0x90)
> [   42.729081] ffff99ef4076be98: 000055b4ef134d50 (0x55b4ef134d50)
> [   42.729081] ffff99ef4076bea0: 0000000000000008 (0x8)
> [   42.729082] ffff99ef4076bea8: ffffffffc00b302f (0xffffffffc00b302f)
> [   42.729082] ffff99ef4076beb0: 000055b4ee9920a0 (0x55b4ee9920a0)
> [   42.729083] ffff99ef4076beb8: 000055b4ef12d1b0 (0x55b4ef12d1b0)
> [   42.729083] ffff99ef4076bec0: 0000000000000001 (0x1)
> [   42.729084] ffff99ef4076bec8: 000055b4ef12cd70 (0x55b4ef12cd70)
> [   42.729084] ffff99ef4076bed0: 0000000000000008 (0x8)
> [   42.729084] ffff99ef4076bed8: 000055b4ef134d50 (0x55b4ef134d50)
> [   42.729085] ffff99ef4076bee0: ffff8a1c39163fc0 (0xffff8a1c39163fc0)
> [   42.729085] ffff99ef4076bee8: 0000000000000000 ...
> [   42.729086] ffff99ef4076bef0: 0000000000000001 (0x1)
> [   42.729086] ffff99ef4076bef8: 0000000000000008 (0x8)
> [   42.729086] ffff99ef4076bf00: 0000000000000002 (0x2)
> [   42.729087] ffff99ef4076bf08: 0000000000000000 ...
> [   42.729087] ffff99ef4076bf10: 00000000000001b6 (0x1b6)
> [   42.729087] ffff99ef4076bf18: 0000000000000000 ...
> [   42.729088] ffff99ef4076bf20: 000055b4ef12d1b0 (0x55b4ef12d1b0)
> [   42.729088] ffff99ef4076bf28: ffffffffffffffff (0xffffffffffffffff)
> [   42.729090] ffff99ef4076bf30: ffffffffac5c5031 (SyS_open+0x1/0x20)
> [   42.729090] ffff99ef4076bf38: 0000000000000010 (0x10)
> [   42.729090] ffff99ef4076bf40: 0000000000000293 (0x293)
> [   42.729091] ffff99ef4076bf48: ffff99ef4076bf50 (0xffff99ef4076bf50)
> [   42.729092] ffff99ef4076bf50: fffffffface13f77 (entry_SYSCALL_64_fastpath
> +0x1a/0xaa)
> [   42.729092] ffff99ef4076bf58: 0000000000000026 (0x26)
> [   42.729093] ffff99ef4076bf60: 00007f276f5e2600 (0x7f276f5e2600)
> [   42.729093] ffff99ef4076bf68: 0000000000000001 (0x1)
> [   42.729094] ffff99ef4076bf70: 0000000000000026 (0x26)
> [   42.729094] ffff99ef4076bf78: 000055b4ef1035d0 (0x55b4ef1035d0)
> [   42.729094] ffff99ef4076bf80: 0000000000000026 (0x26)
> [   42.729095] ffff99ef4076bf88: 0000000000000246 (0x246)
> [   42.729095] ffff99ef4076bf90: 0000000000000000 ...
> [   42.729095] ffff99ef4076bf98: 0000000000000001 (0x1)
> [   42.729096] ffff99ef4076bfa0: 0000000000000008 (0x8)
> [   42.729096] ffff99ef4076bfa8: ffffffffffffffda (0xffffffffffffffda)
> [   42.729097] ffff99ef4076bfb0: 00007f276f3234e0 (0x7f276f3234e0)
> [   42.729097] ffff99ef4076bfb8: 00000000000001b6 (0x1b6)
> [   42.729097] ffff99ef4076bfc0: 0000000000000000 ...
> [   42.729098] ffff99ef4076bfc8: 000055b4ef12d1b0 (0x55b4ef12d1b0)
> [   42.729098] ffff99ef4076bfd0: 0000000000000002 (0x2)
> [   42.729099] ffff99ef4076bfd8: 00007f276f3234e0 (0x7f276f3234e0)
> [   42.729099] ffff99ef4076bfe0: 0000000000000033 (0x33)
> [   42.729100] ffff99ef4076bfe8: 0000000000000246 (0x246)
> [   42.729100] ffff99ef4076bff0: 00007ffd98082448 (0x7ffd98082448)
> [   42.729100] ffff99ef4076bff8: 000000000000002b (0x2b)
>
> Thanks,
> //richard
>
