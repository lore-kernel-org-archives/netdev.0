From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 9 Mar 2017 09:48:20 -0800
Message-ID: <CA+55aFyxvUx0J=p8jh8N1a80Vt+f6M-rg=L3zxyiv69bOYhkKQ@mail.gmail.com>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
 <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net>
 <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com>
 <58C08535.3070000@iogearbox.net> <CAGXu5jLB_+47FEJYTYJ5u6-u+vOBpWo_0tWuiNKnGmuMjL-mMQ@mail.gmail.com>
 <7af7bcc9-9115-be9f-2240-a022487e9b70@redhat.com> <CAGXu5jLm3jbJoQAsBsTiiQGK1==JTnSkN_GLsuBGqFvAz5B3AQ@mail.gmail.com>
 <58C152F1.9090004@iogearbox.net> <alpine.DEB.2.20.1703091409080.3521@nanos>
 <58C157E6.1010909@iogearbox.net> <58C16C6A.2060400@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, "the arch/x86 maintainers" <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33890 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932703AbdCIRsr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 12:48:47 -0500
In-Reply-To: <58C16C6A.2060400@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 9, 2017 at 6:53 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
> Fwiw, I tried switching from using cr4
> (__native_flush_tlb_global_irq_disabled())
> to slower cr3 (__native_flush_tlb()) in "-cpu kvm64" mode, and it looks like
> it also lets all test cases pass (rodata_test, test_setmem, test_bpf), no
> corruption happening, etc.

Ok. I think this is conclusive: the qemu "-cpu kvm64" case is
definitely broken, since changing CR4.PGE is definitely
architecturally defined to flush all TLB entries.

This is not a guest kernel bug.

Of course, the bug may still be in the *host* kernel. Maybe the
emulation does something wrong. I see

        if (((cr4 ^ old_cr4) & pdptr_bits) ||
            (!(cr4 & X86_CR4_PCIDE) && (old_cr4 & X86_CR4_PCIDE)))
                kvm_mmu_reset_context(vcpu);

(where pdptr_bits includes the PGE bit), but I'm not sure if emulation
is supposed to do something else too.

                   Linus
