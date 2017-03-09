From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 09 Mar 2017 18:51:03 +0100
Message-ID: <58C19607.6000605@iogearbox.net>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com> <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net> <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com> <58C08535.3070000@iogearbox.net> <CAGXu5jLB_+47FEJYTYJ5u6-u+vOBpWo_0tWuiNKnGmuMjL-mMQ@mail.gmail.com> <7af7bcc9-9115-be9f-2240-a022487e9b70@redhat.com> <CAGXu5jLm3jbJoQAsBsTiiQGK1==JTnSkN_GLsuBGqFvAz5B3AQ@mail.gmail.com> <58C152F1.9090004@iogearbox.net> <alpine.DEB.2.20.1703091409080.3521@nanos> <58C157E6.1010909@iogearbox.net> <alpine.DEB.2.20.1703091547460.3521@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1703091547460.3521@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 03:49 PM, Thomas Gleixner wrote:
> On Thu, 9 Mar 2017, Daniel Borkmann wrote:
>> On 03/09/2017 02:10 PM, Thomas Gleixner wrote:
>>> On Thu, 9 Mar 2017, Daniel Borkmann wrote:
>>>> With regard to CPA_FLUSHTLB that Linus mentioned, when I investigated
>>>> code paths in change_page_attr_set_clr(), I did see that CPA_FLUSHTLB
>>>> was set each time we switched attrs and a cpa_flush_range() was
>>>> performed (with the correct number of pages and cache set to 0). That
>>>> would be a __flush_tlb_all() eventually.
>>>>
>>>> Hmm, it indeed might seem likely that this could be an emulation bug.
>>>
>>> Which variant of __flush_tlb_all() is used when the test fails?
>>>
>>> Check for the following flags in /proc/cpuinfo: pge invpcid
>>
>> I added the following and booted with both variants:
>>
>> printk("X86_FEATURE_PGE:%u\n",     static_cpu_has(X86_FEATURE_PGE));
>> printk("X86_FEATURE_INVPCID:%u\n", static_cpu_has(X86_FEATURE_INVPCID));
>>
>> "-cpu host" gives:
>>
>> [    8.326117] X86_FEATURE_PGE:1
>> [    8.326381] X86_FEATURE_INVPCID:1
>>
>> "-cpu kvm64" gives:
>>
>> [    8.517069] X86_FEATURE_PGE:1
>> [    8.517393] X86_FEATURE_INVPCID:0
>
> That's the one which fails. So it's using the CR4 based flushing. Just ran
> a test on a physical system with PGE=1 and INVPCID=0. Works fine.
>
> Emulation problem?

So in the git qemu code base (target/i386/helper.c), cr3 vs cr4 looks
like the following, both sharing the tlb_flush() itself:

void cpu_x86_update_cr3(CPUX86State *env, target_ulong new_cr3)
{
     X86CPU *cpu = x86_env_get_cpu(env);

     env->cr[3] = new_cr3;
     if (env->cr[0] & CR0_PG_MASK) {
         qemu_log_mask(CPU_LOG_MMU,
                         "CR3 update: CR3=" TARGET_FMT_lx "\n", new_cr3);
         tlb_flush(CPU(cpu));
     }
}

void cpu_x86_update_cr4(CPUX86State *env, uint32_t new_cr4)
{
     X86CPU *cpu = x86_env_get_cpu(env);
     uint32_t hflags;

#if defined(DEBUG_MMU)
     printf("CR4 update: %08x -> %08x\n", (uint32_t)env->cr[4], new_cr4);
#endif
     if ((new_cr4 ^ env->cr[4]) &
         (CR4_PGE_MASK | CR4_PAE_MASK | CR4_PSE_MASK |
          CR4_SMEP_MASK | CR4_SMAP_MASK | CR4_LA57_MASK)) {
         tlb_flush(CPU(cpu));
     }

     [...]
}

I added some debugging around __native_flush_tlb_global_irq_disabled()
and if I understand it correctly, the idea of cr4 is that we need to
toggle X86_CR4_PGE in order to trigger a TLB flush.

What I see is that original cr4 is 0x610. The cpu_tlbstate.cr4 is
consistent to native_read_cr4() and since cr4 is != 0, it tells me
based on the comment in native_read_cr4() that cr4 seems to be
supported. Thus, meaning we end up with writing ...

   native_write_cr4(0x610);
   native_write_cr4(0x610);

... twice, and this just doesn't trigger the desired TLB flush. I
changed the code into the following ...

         cr4 = this_cpu_read(cpu_tlbstate.cr4);
         /* clear PGE */
-       native_write_cr4(cr4 & ~X86_CR4_PGE);
+       native_write_cr4(cr4 ^ X86_CR4_PGE);
         /* write old PGE again and flush TLBs */
         native_write_cr4(cr4);

... and the test cases seem to be working for me now with "-cpu kvm64",
so that seems to trigger the TLB we were missing.

I don't know enough about x86 internals to tell whether the change is
sane, though, but it seems at least for qemu fwiw. ;) Thoughts?

Thanks,
Daniel
