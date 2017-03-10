From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Fri, 10 Mar 2017 01:13:54 +0100
Message-ID: <58C1EFC2.7090309@iogearbox.net>
References: <58C19607.6000605@iogearbox.net> <CA+55aFyxM--wyvxXGhBOqdJHcdC_kKvGYpv-C5SpYvRNkbEmGw@mail.gmail.com> <CA+55aFyu-LHqMaZBaa7VNamxhUR99F4Xr+nL9esLDUBhotopVg@mail.gmail.com> <58C19F67.3040509@iogearbox.net> <58C1C9DC.7070509@iogearbox.net> <20170309215547.jmdzznlkzaxwu2pf@pd.tnic> <20170309220732.ufqoqlawktsi2gao@pd.tnic> <58C1D305.8090802@iogearbox.net> <20170309224820.5invcnhvr2tl3ges@pd.tnic> <CA+55aFy5vi3af5VBuG6ZOdTeKNxqGSq64J-EkrjaRhGVKXPy0A@mail.gmail.com> <20170309234411.wec53iexfz6skmpl@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Borislav Petkov <bp@suse.de>,
        Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309234411.wec53iexfz6skmpl@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2017 12:44 AM, Borislav Petkov wrote:
> On Thu, Mar 09, 2017 at 03:26:02PM -0800, Linus Torvalds wrote:
>> So should all of commit ("c109bf95992b x86/cpufeature: Remove
>> cpu_has_pge") just be reverted (and then marked for stable)?
>>
>> Or do we have some alternate plan?
>
> I think we want to do this:
>
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 6fa85944af83..fc5abff9b7fd 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -188,7 +188,7 @@ static inline void __native_flush_tlb_single(unsigned long addr)
>
>   static inline void __flush_tlb_all(void)
>   {
> -	if (static_cpu_has(X86_FEATURE_PGE))
> +	if (boot_cpu_has(X86_FEATURE_PGE))
>   		__flush_tlb_global();
>   	else
>   		__flush_tlb();
> ---
>
> but it is late here so I'd prefer to do a real patch tomorrow when I'm
> not almost sleeping on the keyboard. Unless Daniel wants to write one
> and test it now.

I think we're in the same time zone. ;) I could send something
official tomorrow cooking a changelog with analysis, but I don't
mind at all if you want to go ahead with that either. Feel free
to add my SoB or Tested-by to it.

>> This has apparently been going on for a long while (it got merged into
>> 4.7), but presumably it only actually _matters_ if lguest is enabled
>> and used and we've triggered that lguest_arch_host_init() code.
>
> That's what I gather too, yes.
>
> What sane code would go and clear X86_FEATURE_PGE?!? :-)))
>
>> Maybe it's the lguest games with PGE that need to be removed?
>
> Well, as far as I can read the comment in lguest_arch_host_init(), it
> does some monkey business with switching to the guest kernel where
> global pages are not present anymore... or something. So it sounds to me
> like lguest would break if we removed the games but I have no idea what
> it does with that.
>
> And besides, the small hunk above restores the situation before
> ("c109bf95992b x86/cpufeature: Remove cpu_has_pge") so applying it would
> actually be a no-brainer.

Agree, looks only that hunk changed in behavior from c109bf95992b
("x86/cpufeature: Remove cpu_has_pge").

> Thanks.
