From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 09 Mar 2017 22:32:12 +0100
Message-ID: <58C1C9DC.7070509@iogearbox.net>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com> <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net> <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com> <58C08535.3070000@iogearbox.net> <CAGXu5jLB_+47FEJYTYJ5u6-u+vOBpWo_0tWuiNKnGmuMjL-mMQ@mail.gmail.com> <7af7bcc9-9115-be9f-2240-a022487e9b70@redhat.com> <CAGXu5jLm3jbJoQAsBsTiiQGK1==JTnSkN_GLsuBGqFvAz5B3AQ@mail.gmail.com> <58C152F1.9090004@iogearbox.net> <alpine.DEB.2.20.1703091409080.3521@nanos> <58C157E6.1010909@iogearbox.net> <alpine.DEB.2.20.1703091547460.3521@nanos> <58C19607.6000605@iogearbox.net> <CA+55aFyxM--wyvxXGhBOqdJHcdC_kKvGYpv-C5SpYvRNkbEmGw@mail.gmail.com> <CA+55aFyu-LHqMaZBaa7VNamxhUR99F4Xr+nL9esLDUBhotopVg@mail.gmail.com> <58C19F67.3040509@iogearbox.
 net>
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
        "David S. Miller" <davem@davemloft.net>, bp@suse.de
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58C19F67.3040509@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ + Borislav ]

On 03/09/2017 07:31 PM, Daniel Borkmann wrote:
> On 03/09/2017 07:15 PM, Linus Torvalds wrote:
>> On Thu, Mar 9, 2017 at 10:10 AM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>>>
>>> Very odd. We should always have PGE (0x0080) set in cr4 (if the CPU
>>> supports it).
>>
>> Daniel, do you see the code in probe_page_size_mask() triggering?
>>
>>          /* Enable PGE if available */
>>          if (boot_cpu_has(X86_FEATURE_PGE)) {
>>                  cr4_set_bits_and_update_boot(X86_CR4_PGE);
>>                  __supported_pte_mask |= _PAGE_GLOBAL;
>
> We do have boot_cpu_has(X86_FEATURE_PGE) and go indeed into this
> branch here. So it seems something must be clearing it later, hmm.
>
>>          } else
>>                  __supported_pte_mask &= ~_PAGE_GLOBAL;
>>
>> but maybe there's something wrong with the percpu cr4 caching?

So, I think I got a little bit further. To the printk's I added
previously in the test_setmem code that run on the problematic
kernel, I now extended them into:

   printk("static_cpu X86_FEATURE_PGE:%u\n",     static_cpu_has(X86_FEATURE_PGE));
   printk("boot_cpu   X86_FEATURE_PGE:%u\n",       boot_cpu_has(X86_FEATURE_PGE));
   printk("static_cpu X86_FEATURE_INVPCID:%u\n", static_cpu_has(X86_FEATURE_INVPCID));
   printk("boot_cpu   X86_FEATURE_INVPCID:%u\n",   boot_cpu_has(X86_FEATURE_INVPCID));

And here's what I get in the log:

"-cpu kvm64" gives:

[    8.426865] static_cpu X86_FEATURE_PGE:1
[    8.427148] boot_cpu   X86_FEATURE_PGE:0
[    8.427428] static_cpu X86_FEATURE_INVPCID:0
[    8.427732] boot_cpu   X86_FEATURE_INVPCID:0

"-cpu host" gives:

[    8.426408] static_cpu X86_FEATURE_PGE:1
[    8.426726] boot_cpu   X86_FEATURE_PGE:0
[    8.427037] static_cpu X86_FEATURE_INVPCID:1
[    8.427375] boot_cpu   X86_FEATURE_INVPCID:1

This means at that point in time static_cpu_has(X86_FEATURE_PGE) is
not the same as boot_cpu_has(X86_FEATURE_PGE).

The code that switches this off is in lguest_arch_host_init(). Right
before that, both are X86_FEATURE_PGE:1, X86_FEATURE_INVPCID:0 for
the "-cpu kvm64" case.

Then, the lguest code does:

	get_online_cpus();
	if (boot_cpu_has(X86_FEATURE_PGE)) { /* We have a broader idea of "global". */
		/* Remember that this was originally set (for cleanup). */
		cpu_had_pge = 1;
		/*
		 * adjust_pge is a helper function which sets or unsets the PGE
		 * bit on its CPU, depending on the argument (0 == unset).
		 */
		on_each_cpu(adjust_pge, (void *)0, 1);
		/* Turn off the feature in the global feature set. */
		clear_cpu_cap(&boot_cpu_data, X86_FEATURE_PGE);
	}
	put_online_cpus();

So, adjust_pge() clears X86_CR4_PGE, and boot cpu has X86_FEATURE_PGE
unset. This means, with static_cpu_has(X86_FEATURE_PGE) still 1, we
run into using cr4 for TLB flushing with no X86_CR4_PGE bit set (which
doesn't trigger the flush), whereas we should be using cr3 for flushing
from that point onwards instead.

I tried with this one, and things seem to work again:

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 6fa8594..fc5abff 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -188,7 +188,7 @@ static inline void __native_flush_tlb_single(unsigned long addr)

  static inline void __flush_tlb_all(void)
  {
-       if (static_cpu_has(X86_FEATURE_PGE))
+       if (boot_cpu_has(X86_FEATURE_PGE))
                 __flush_tlb_global();
         else
                 __flush_tlb();

Presumably coming from c109bf95992b ("x86/cpufeature: Remove cpu_has_pge")?

Thanks,
Daniel
