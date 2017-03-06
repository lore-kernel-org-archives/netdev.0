From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net] bpf: disable broken write protection on i386
Date: Mon, 6 Mar 2017 10:11:14 -0800
Message-ID: <CAGXu5jJO=Nwq-ja9+yc==R2d-TAJmMv7eT4v9GYF5v8agqxUnQ@mail.gmail.com>
References: <f722fcb96307fa6c449bbe2f19a4fe9797272678.1488596969.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Laura Abbott <labbott@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36057 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753160AbdCFSjb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 13:39:31 -0500
Received: by mail-io0-f176.google.com with SMTP id l7so119714829ioe.3
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 10:38:45 -0800 (PST)
In-Reply-To: <f722fcb96307fa6c449bbe2f19a4fe9797272678.1488596969.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 3, 2017 at 7:23 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Since d2852a224050 ("arch: add ARCH_HAS_SET_MEMORY config") and
> 9d876e79df6a ("bpf: fix unlocking of jited image when module ronx
> not set") that uses the former, Fengguang reported random corruptions
> on his i386 test machine [1]. On i386 there is no JIT available,
> and since his kernel config doesn't have kernel modules enabled,
> there was also no DEBUG_SET_MODULE_RONX enabled before which would
> set interpreted bpf_prog image as read-only like we do in various
> other cases for quite some time now, e.g. x86_64, arm64, etc. Thus,
> the difference with above commits was that we now used set_memory_ro()
> and set_memory_rw() on i386, which resulted in these issues. When
> reproducing this with Fengguang's config and qemu image, I changed
> lib/test_bpf.c to be run during boot instead of relying on trinity
> to fiddle with cBPF.
>
> The issues I saw with the BPF test suite when set_memory_ro() and
> set_memory_rw() is used to write protect image on i386 is that after
> a number of tests I noticed a corruption happening in bpf_prog_realloc().
> Specifically, fp_old's content gets corrupted right *after* the
> (unrelated) __vmalloc() call and contains only zeroes right after
> the call instead of the original prog data. fp_old should have been
> freed later on via __bpf_prog_free() *after* we copied all the data
> over to the newly allocated fp. Result looks like:
>
>   [...]
>   [   13.107240] test_bpf: #249 JMP_JSET_X: if (0x3 & 0x2) return 1 jited:0 17 PASS
>   [   13.108182] test_bpf: #250 JMP_JSET_X: if (0x3 & 0xffffffff) return 1 jited:0 17 PASS
>   [   13.109206] test_bpf: #251 JMP_JA: Jump, gap, jump, ... jited:0 16 PASS
>   [   13.110493] test_bpf: #252 BPF_MAXINSNS: Maximum possible literals jited:0 12 PASS
>   [   13.111885] test_bpf: #253 BPF_MAXINSNS: Single literal jited:0 8 PASS
>   [   13.112804] test_bpf: #254 BPF_MAXINSNS: Run/add until end jited:0 6341 PASS
>   [   13.177195] test_bpf: #255 BPF_MAXINSNS: Too many instructions PASS
>   [   13.177689] test_bpf: #256 BPF_MAXINSNS: Very long jump jited:0 9 PASS
>   [   13.178611] test_bpf: #257 BPF_MAXINSNS: Ctx heavy transformations
>   [   13.178713] BUG: unable to handle kernel NULL pointer dereference at 00000034
>   [   13.179740] IP: bpf_prog_realloc+0x5b/0x90
>   [   13.180017] *pde = 00000000
>   [   13.180017]
>   [   13.180017] Oops: 0002 [#1] DEBUG_PAGEALLOC
>   [   13.180017] CPU: 0 PID: 1 Comm: swapper Not tainted 4.10.0-57268-gd627975-dirty #50
>   [   13.180017] task: 401ec000 task.stack: 401f2000
>   [   13.180017] EIP: bpf_prog_realloc+0x5b/0x90
>   [   13.180017] EFLAGS: 00210246 CPU: 0
>   [   13.180017] EAX: 00000000 EBX: 57ae1000 ECX: 00000000 EDX: 57ae1000
>   [   13.180017] ESI: 00000019 EDI: 57b07000 EBP: 401f3e74 ESP: 401f3e68
>   [   13.180017]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
>   [   13.180017] CR0: 80050033 CR2: 00000034 CR3: 12cb1000 CR4: 00000610
>   [   13.180017] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>   [   13.180017] DR6: fffe0ff0 DR7: 00000400
>   [   13.180017] Call Trace:
>   [   13.180017]  bpf_prepare_filter+0x317/0x3a0
>   [   13.180017]  bpf_prog_create+0x65/0xa0
>   [   13.180017]  test_bpf_init+0x1ca/0x628
>   [   13.180017]  ? test_hexdump_init+0xb5/0xb5
>   [   13.180017]  do_one_initcall+0x7c/0x11c
>   [...]
>
> When using trinity from Fengguang's reproducer, the corruptions were
> at inconsistent places, presumably from code dealing with allocations
> and seeing similar effects as mentioned above.
>
> Not using set_memory_ro() and set_memory_rw() lets the test suite
> run just fine as expected, thus it looks like using set_memory_*()
> on i386 seems broken and mentioned commits just uncovered it. Also,
> for checking, I enabled DEBUG_RODATA_TEST for that kernel.
>
> Latter shows that memory protecting the kernel seems not working either
> on i386 (!). Test suite output:
>
>   [...]
>   [   12.692836] Write protecting the kernel text: 13416k
>   [   12.693309] Write protecting the kernel read-only data: 5292k
>   [   12.693802] rodata_test: test data was not read only
>   [...]
>
> Work-around to not enable ARCH_HAS_SET_MEMORY for i386 is not optimal
> as it doesn't fix the issue in presumably broken set_memory_*(), but
> it at least avoids people avoid having to deal with random corruptions
> that are hard to track down for the time being until a real fix can
> be found.

Wow. Uhm, so, something must be _really_ broken. i386 should have no
problem with using the set_memory_*() functions. The fact that
DEBUG_RODATA_TEST failed is also pretty crazy, but may be unrelated
(that test was just refactored too).

Is it possible that it's just the enabling of set_memory_*() for the
non-modular case? The ARCH_HAS_SET_MEMORY commit is just a convenience
config; i386 has had those functions for a while now, and they're the
same between x86_64 and i386. O_o Perhaps they aren't safe on i386 for
non-modular addresses?

I do a few X86_32 and 64 differences in arch/x86/mm/pageattr.c,
though. I wonder about __set_pmd_pte(), but I haven't looked closely
at x86 paging code before...

>
>   [1] https://lkml.org/lkml/2017/3/2/648
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Alexei Starovoitov <ast@kernel.org>
> ---
>  [ Sending to -net as bpf related, but I don't mind to route it
>    elsewhere, too. ]
>
>  arch/x86/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index cc98d5a..626dc6a 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -54,7 +54,7 @@ config X86
>         select ARCH_HAS_KCOV                    if X86_64
>         select ARCH_HAS_MMIO_FLUSH
>         select ARCH_HAS_PMEM_API                if X86_64
> -       select ARCH_HAS_SET_MEMORY
> +       select ARCH_HAS_SET_MEMORY              if X86_64
>         select ARCH_HAS_SG_CHAIN
>         select ARCH_HAS_STRICT_KERNEL_RWX
>         select ARCH_HAS_STRICT_MODULE_RWX
> --
> 1.9.3
>

I'm okay with this patch since only BPF pays attention to that CONFIG,
but we need to fix the problem. :)

-Kees

-- 
Kees Cook
Pixel Security
