From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Wed, 8 Mar 2017 14:43:44 -0800
Message-ID: <CA+55aFwaNhP918b0zgpP8G6qGXHP+Qw69hEV+271tPMXu1+p8A@mail.gmail.com>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
 <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net>
 <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com> <58C08535.3070000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, "the arch/x86 maintainers" <x86@kernel.org>,
        Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        David Miller <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58C08535.3070000@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 8, 2017 at 2:27 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
> The issue seems to be accessing buff first (can be read or write access)
> and then doing set_memory_ro() doesn't make it read-only immediately,
> meaning the subsequent call into probe_kernel_write() will succeed without
> error.
>
> Then, if I don't touch buff first and only do the set_memory_ro() seems
> to work and probe_kernel_write() will then fail as expected due to pages
> being read-only now.

Ok, that definitely sounds like a TLB invalidate didn't happen.

> Now, if I access buff, do the set_memory_ro() and then a msleep(0), for
> example, it "kind of" works most of the time (see last log extract below),
> and probe_kernel_write() will fail.

Yeah, very much consistent with a missing TLB invalidate. Scheduling
will end up invalidating it, although if it's a global page even that
might not do it (but eventually the entry will just get flushed due to
other activity).

> None of this seems an issue with x86_64 and the test_setmem runs fine all
> the time, same for the actual BPF stuff.

The code does look somewhat confused about when to actually flush
things - see my earlier note about NX - but it would seem to always do
__flush_tlb_all() unless I missed something. At least as long as
CPA_FLUSHTLB is set. Maybe some case forgets to set that..

       Linus
