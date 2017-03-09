From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 9 Mar 2017 14:09:00 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1703091248410.3521@nanos>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com> <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net> <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Mar 2017, Linus Torvalds wrote:

> Adding x86 people too, since this seems to be something off about
> ARCH_HAS_SET_MEMORY for x86-32.
> 
> The code seems to be shared between x86-32 and 64, I'm not seeing why
> set_memory_r[ow]() should fail on one but not the other.

Indeed.

> Considering that it seems to be flaky even on 32-bit, maybe it's
> timing-related, or possibly related to TLB sizes or whatever (ie more
> likely hidden by a larger TLB on more modern hardware?)

The only difference I can see is the way how __tlb_flush_all() is
happening. We have 3 variants:

   invpcid_flush_all()  - depends on X86_FEATURE_INVPCID and X86_FEATURE_PGE
   cr4 based flush	- depends on X86_FEATURE_PGE
   cr3 based flush

No idea which variant is used in that failure case.

> Anyway, just looking at change_page_attr_set_clr(), I notice that the
> page alias checking treats NX specially:
> 
>         /* No alias checking for _NX bit modifications */
>         checkalias = (pgprot_val(mask_set) | pgprot_val(mask_clr)) != _PAGE_NX;
> 
> which seems insane. Why would NX be different from other protection
> bits (like _PAGE_RW)?

The reason is that the alias mapping should never be executable at all.

Thanks,

	tglx
