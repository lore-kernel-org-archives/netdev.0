From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Wed, 8 Mar 2017 11:25:40 -0800
Message-ID: <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
 <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, "the arch/x86 maintainers" <x86@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58B88353.2010508@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding x86 people too, since this seems to be something off about
ARCH_HAS_SET_MEMORY for x86-32.

The code seems to be shared between x86-32 and 64, I'm not seeing why
set_memory_r[ow]() should fail on one but not the other.

Considering that it seems to be flaky even on 32-bit, maybe it's
timing-related, or possibly related to TLB sizes or whatever (ie more
likely hidden by a larger TLB on more modern hardware?)

Anyway, just looking at change_page_attr_set_clr(), I notice that the
page alias checking treats NX specially:

        /* No alias checking for _NX bit modifications */
        checkalias = (pgprot_val(mask_set) | pgprot_val(mask_clr)) != _PAGE_NX;

which seems insane. Why would NX be different from other protection
bits (like _PAGE_RW)?

But that doesn't explain why the bpf code would have issues with this
all only on x86-32.

Maybe somebody else can see why ARCH_HAS_SET_MEMORY would depend on
64-bit only..

               Linus

On Thu, Mar 2, 2017 at 12:40 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 03/02/2017 09:23 PM, Fengguang Wu wrote:
> [...]
>>
>> I confirm that the below patch provided by Daniel fixes the above
>> issues on mainline kernel, too. Where should this patch be sent to?
>
>
> If nobody objects, I could send it to -net tree via Dave due to being
> BPF related, but I don't mind sending it elsewhere too (f.e. Linus
> directly?) in order to stop your bot from continuing to send such mails.
>
> The issue seems only related to i386 and doesn't trigger each time with
> Fengguang's kernel config and qemu image when I try to reproduce it.
> set_memory_ro()/set_memory_rw() on i386 seems to work in general, but
> when it's used/reproduced, from time to time (perhaps some corner-case?)
> it looks like that memory area can have issues much later on after being
> fed back to the allocator which then causes a GPF from random locations.
> Gut feeling, it might be an issue in set_memory_*() that my commit
> uncovered. Still looking into it, but mean-time I could just send the
> below, sure.
>
> Thanks,
> Daniel
>
>
>> It'd be very noisy if all these Oops hit the upcoming RC1 kernel.
>>
>> Daniel thinks there may be deeper problem in i386 set_memory_rw().
>> However that could take much longer time to debug.
>>
>> Thanks,
>> Fengguang
>> ---
>>
>> Re: [bpf] 9d876e79df:  BUG: unable to handle kernel paging request at
>> 653a8346
>>
>>> On Tue, Feb 28, 2017 at 04:39:36PM +0100, Daniel Borkmann wrote:
>>
>>
>> I have a rough feeling what it is, but I didn't have cycles to work on
>> it yet (due to travel, sorry about that). The issue is likely shut down
>> by just doing:
>>
>> ---
>> arch/x86/Kconfig |    2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> --- linux.orig/arch/x86/Kconfig    2017-03-03 03:44:35.962022996 +0800
>> +++ linux/arch/x86/Kconfig    2017-03-03 03:44:35.962022996 +0800
>> @@ -54,7 +54,7 @@ config X86
>>      select ARCH_HAS_KCOV            if X86_64
>>      select ARCH_HAS_MMIO_FLUSH
>>      select ARCH_HAS_PMEM_API        if X86_64
>> -    select ARCH_HAS_SET_MEMORY
>> +    select ARCH_HAS_SET_MEMORY        if X86_64
>>      select ARCH_HAS_SG_CHAIN
>>      select ARCH_HAS_STRICT_KERNEL_RWX
>>      select ARCH_HAS_STRICT_MODULE_RWX
>
>
