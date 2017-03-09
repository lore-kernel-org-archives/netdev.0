From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 9 Mar 2017 10:10:33 -0800
Message-ID: <CA+55aFyxM--wyvxXGhBOqdJHcdC_kKvGYpv-C5SpYvRNkbEmGw@mail.gmail.com>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
 <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net>
 <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com>
 <58C08535.3070000@iogearbox.net> <CAGXu5jLB_+47FEJYTYJ5u6-u+vOBpWo_0tWuiNKnGmuMjL-mMQ@mail.gmail.com>
 <7af7bcc9-9115-be9f-2240-a022487e9b70@redhat.com> <CAGXu5jLm3jbJoQAsBsTiiQGK1==JTnSkN_GLsuBGqFvAz5B3AQ@mail.gmail.com>
 <58C152F1.9090004@iogearbox.net> <alpine.DEB.2.20.1703091409080.3521@nanos>
 <58C157E6.1010909@iogearbox.net> <alpine.DEB.2.20.1703091547460.3521@nanos> <58C19607.6000605@iogearbox.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58C19607.6000605@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 9, 2017 at 9:51 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
> What I see is that original cr4 is 0x610. The cpu_tlbstate.cr4 is
> consistent to native_read_cr4() and since cr4 is != 0, it tells me
> based on the comment in native_read_cr4() that cr4 seems to be
> supported. Thus, meaning we end up with writing ...
>
>   native_write_cr4(0x610);
>   native_write_cr4(0x610);
>
> ... twice, and this just doesn't trigger the desired TLB flush.

Very odd. We should always have PGE (0x0080) set in cr4 (if the CPU
supports it).

But yes, if PGE is clear then that certainly explains the bug, and
it's not an emulation issue.

> I changed the code into the following ...
>
>         cr4 = this_cpu_read(cpu_tlbstate.cr4);
>         /* clear PGE */
> -       native_write_cr4(cr4 & ~X86_CR4_PGE);
> +       native_write_cr4(cr4 ^ X86_CR4_PGE);
>         /* write old PGE again and flush TLBs */
>         native_write_cr4(cr4);

Yeah, good for debugging, but not a good patch in general. The only
valid reason for not having PGE enabled would be that the CPU doesn't
support PGE at all.

                    Linus
