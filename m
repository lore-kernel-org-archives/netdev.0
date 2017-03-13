From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] x86-32: fix tlb flushing when lguest clears PGE
Date: Sun, 12 Mar 2017 20:02:00 -0600
Message-ID: <CAGXu5jLoR628xoFdSFs_PeW5AD-aYv9yMz2AbKjMZfkN77vaNg@mail.gmail.com>
References: <25c41ad9eca164be4db9ad84f768965b7eb19d9e.1489191673.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Borislav Petkov <bp@suse.de>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        "x86@kernel.org" <x86@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Laura Abbott <labbott@redhat.com>,
        Ingo Molnar <mingo@kernel.org>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Rusty Russell <rusty@rustcorp.com.au>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <25c41ad9eca164be4db9ad84f768965b7eb19d9e.1489191673.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Are there nominations for most comprehensive changelog of the year? :)
This is awesome.

-Kees

On Fri, Mar 10, 2017 at 6:31 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Fengguang reported [1] random corruptions from various locations on
> x86-32 after commits d2852a224050 ("arch: add ARCH_HAS_SET_MEMORY
> config") and 9d876e79df6a ("bpf: fix unlocking of jited image when
> module ronx not set") that uses the former. While x86-32 doesn't
> have a JIT like x86_64, the bpf_prog_lock_ro() and bpf_prog_unlock_ro()
> got enabled due to ARCH_HAS_SET_MEMORY, whereas Fengguang's test
> kernel doesn't have module support built in and therefore never
> had the DEBUG_SET_MODULE_RONX setting enabled.
>
> After investigating the crashes further, it turned out that using
> set_memory_ro() and set_memory_rw() didn't have the desired effect,
> for example, setting the pages as read-only on x86-32 would still
> let probe_kernel_write() succeed without error. This behavior would
> manifest itself in situations where the vmalloc'ed buffer was accessed
> prior to set_memory_*() such as in case of bpf_prog_alloc(). In
> cases where it wasn't, the page attribute changes seemed to have
> taken effect, leading to the conclusion that a TLB invalidate
> didn't happen. Moreover, it turned out that this issue reproduced
> with qemu in "-cpu kvm64" mode, but not for "-cpu host". When the
> issue occurs, change_page_attr_set_clr() did trigger a TLB flush
> as expected via __flush_tlb_all() through cpa_flush_range(), though.
>
> There are 3 variants for issuing a TLB flush: invpcid_flush_all()
> (depends on CPU feature bits X86_FEATURE_INVPCID, X86_FEATURE_PGE),
> cr4 based flush (depends on X86_FEATURE_PGE), and cr3 based flush.
> For "-cpu host" case in my setup, the flush used invpcid_flush_all()
> variant, whereas for "-cpu kvm64", the flush was cr4 based. Switching
> the kvm64 case to cr3 manually worked fine, and further investigating
> the cr4 one turned out that X86_CR4_PGE bit was not set in cr4
> register, meaning the __native_flush_tlb_global_irq_disabled() wrote
> cr4 twice with the same value instead of clearing X86_CR4_PGE in the
> first write to trigger the flush.
>
> It turned out that X86_CR4_PGE was cleared from cr4 during init
> from lguest_arch_host_init() via adjust_pge(). The X86_FEATURE_PGE
> bit is also cleared from there due to concerns of using PGE in
> guest kernel that can lead to hard to trace bugs (see bff672e630a0
> ("lguest: documentation V: Host") in init()). The CPU feature bits
> are cleared in dynamic boot_cpu_data, but they never propagated to
> __flush_tlb_all() as it uses static_cpu_has() instead of boot_cpu_has()
> for testing which variant of TLB flushing to use, meaning they still
> used the old setting of the host kernel.
>
> Clearing via setup_clear_cpu_cap(X86_FEATURE_PGE) so this would
> propagate to static_cpu_has() checks is too late at this point as
> sections have been patched already, so for now, it seems reasonable
> to switch back to boot_cpu_has(X86_FEATURE_PGE) as it was prior to
> commit c109bf95992b ("x86/cpufeature: Remove cpu_has_pge"). This
> lets the TLB flush trigger via cr3 as originally intended, properly
> makes the new page attributes visible and thus fixes the crashes
> seen by Fengguang.
>
>   [1] https://lkml.org/lkml/2017/3/1/344
>
> Fixes: c109bf95992b ("x86/cpufeature: Remove cpu_has_pge")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  arch/x86/include/asm/tlbflush.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 6fa8594..fc5abff 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -188,7 +188,7 @@ static inline void __native_flush_tlb_single(unsigned long addr)
>
>  static inline void __flush_tlb_all(void)
>  {
> -       if (static_cpu_has(X86_FEATURE_PGE))
> +       if (boot_cpu_has(X86_FEATURE_PGE))
>                 __flush_tlb_global();
>         else
>                 __flush_tlb();
> --
> 1.9.3
>



-- 
Kees Cook
Pixel Security
