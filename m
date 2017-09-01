From: Kees Cook <keescook@chromium.org>
Subject: Re: tip -ENOBOOT - bisected to locking/refcounts, x86/asm: Implement
 fast refcount overflow protection
Date: Fri, 1 Sep 2017 11:58:41 -0700
Message-ID: <CAGXu5jKiGFAp8Lp2Nt1yHg_nYsY_rfrUjMgOPTNxMLkbQ8V-ng@mail.gmail.com>
References: <1503996623.8323.20.camel@gmx.de> <CAGXu5jLYHy6Damtg_Pc4=G76OUiMV3fcY9+Ru1-Lmiq6VWEgsw@mail.gmail.com>
 <1504025721.6024.25.camel@gmx.de> <1504030207.6560.0.camel@gmx.de>
 <CAGXu5jKSWiZ8NkgUqO6G8fs5R06bMtdFBmZz9MMX-HAk8nXXNw@mail.gmail.com>
 <1504069332.8352.3.camel@gmx.de> <CAGXu5jJim=r8b+y1qQXtuzm9fPyv1tp9ANebxbCc9ic2c83_Mg@mail.gmail.com>
 <1504113212.5852.6.camel@gmx.de> <CAGXu5jJd80-0PJvB51x9ZDETPSoAtRVQ7dQ6HWwd0DYpKBgPFA@mail.gmail.com>
 <1504115735.5852.11.camel@gmx.de> <CAGXu5j+BLj6_LPfKs-vts-mbyJHu8D--WrmWbiT8Zbt-iD65KA@mail.gmail.com>
 <CAGXu5j+neSYAqb8=r42=jQ0LsJTGjCSdpgc9Hv+ipyAFURbCdw@mail.gmail.com>
 <1504145389.23109.4.camel@gmx.de> <CAGXu5jLKXEDdSpxxVM5oHHUWKbSTozx4FZRn70bQm4tQAhMqUQ@mail.gmail.com>
 <1504149176.23109.9.camel@gmx.de> <CAGXu5j+uNU+wqWoCV+Kpdp+DQer4E3VuwO0mtXiW3Dtw_61QKA@mail.gmail.com>
 <CAGXu5jKYPp5D+YxtqrJXsi48UUbjfeREngsys-dU1eP4RnnL+w@mail.gmail.com>
 <1504187918.27500.16.camel@gmx.de> <CAGXu5jL8Ueuw-DLY+Hz8Jd7NgqgyaaN8OVDicFxmcjBhScebOA@mail.gmail.com>
 <1504199967.666.16.camel@gmx.de> <CAGXu5j+RPDAP-dK+dizQV4prmWBhqU_G1PccWpME=924-2985w@mail.gmail.com>
 <1504249070.17604.20.camel@gmx.de> <1504271369.332.29.camel@gmx.de>
 <CAGXu5jJ+zq=4Un2JpwWk==sThEYeyqYuvesN6=H-1XeLxW_C0Q@mail.gmail.com> <1504288357.6035.21.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504288357.6035.21.camel@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 1, 2017 at 10:52 AM, Mike Galbraith <efault@gmx.de> wrote:
> On Fri, 2017-09-01 at 10:12 -0700, Kees Cook wrote:
>> On Fri, Sep 1, 2017 at 6:09 AM, Mike Galbraith <efault@gmx.de> wrote:
>> > On Fri, 2017-09-01 at 08:57 +0200, Mike Galbraith wrote:
>> >> On Thu, 2017-08-31 at 11:45 -0700, Kees Cook wrote:
>> >> > On Thu, Aug 31, 2017 at 10:19 AM, Mike Galbraith <efault@gmx.de> wrote:
>> >> > > On Thu, 2017-08-31 at 10:00 -0700, Kees Cook wrote:
>> >> > >>
>> >> > >> Oh! So it's gcc-version sensitive? That's alarming. Is this mapping correct:
>> >> > >>
>> >> > >> 4.8.5: WARN, eventual kernel hang
>> >> > >> 6.3.1, 7.0.1: WARN, but continues working
>> >> > >
>> >> > > Yeah, that's correct.  I find that troubling, simply because this gcc
>> >> > > version has been through one hell of a lot of kernels with me.  Yeah, I
>> >> > > know, that doesn't exempt it from having bugs, but color me suspicious.
>> >> >
>> >> > I still can't hit this with a 4.8.5 build. :(
>> >> >
>> >> > With _RATELIMIT removed, this should, in theory, report whatever goes
>> >> > negative first...
>> >>
>> >> I applied the other patch you posted, and built with gcc-6.3.1 to
>> >> remove the gcc-4.8.5 aspect.  Look below the resulting splat.
>> >
>> > Grr, that one has a in6_dev_getx() line missing for the first
>> > increment, where things go pear shaped.
>> >
>> > With that added, looking at counter both before, and after incl, with a
>> > trace_printk() in the exception handler showing it doing its saturate
>> > thing, irqs disabled across the whole damn refcount_inc(), and even
>> > booting box nr_cpus=1 for extra credit...
>> >
>> > HTH can that first refcount_inc() get there?
>> >
>> > # tracer: nop
>> > #
>> > #                              _-----=> irqs-off
>> > #                             / _----=> need-resched
>> > #                            | / _---=> hardirq/softirq
>> > #                            || / _--=> preempt-depth
>> > #                            ||| /     delay
>> > #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
>> > #              | |       |   ||||       |         |
>> >          systemd-1     [000] d..1     1.937284: in6_dev_getx: PRE refs.counter:3
>> >          systemd-1     [000] d..1     1.937295: ex_handler_refcount: *(int *)regs->cx = -1073741824
>> >          systemd-1     [000] d..1     1.937296: in6_dev_getx: POST refs.counter:-1073741824
>>
>> O_o
>>
>> Can you paste the disassembly of in6_dev_getx? I can't understand how
>> we're landing in the exception handler.
>
> I was hoping you'd say that.
>
>    0xffffffff816b2f72 <+0>:     push   %rbp
>    0xffffffff816b2f73 <+1>:     mov    %rsp,%rbp
>    0xffffffff816b2f76 <+4>:     push   %r12
>    0xffffffff816b2f78 <+6>:     push   %rbx
>    0xffffffff816b2f79 <+7>:     incl   %gs:0x7e95a2d0(%rip)        # 0xd250 <__preempt_count>
>    0xffffffff816b2f80 <+14>:    mov    0x308(%rdi),%rbx
>    0xffffffff816b2f87 <+21>:    test   %rbx,%rbx
>    0xffffffff816b2f8a <+24>:    je     0xffffffff816b2feb <in6_dev_getx+121>
>    0xffffffff816b2f8c <+26>:    callq  *0xffffffff81c35a00
>    0xffffffff816b2f93 <+33>:    mov    %rax,%r12
>    0xffffffff816b2f96 <+36>:    callq  *0xffffffff81c35a10
>    0xffffffff816b2f9d <+43>:    mov    0x769ad4(%rip),%rsi        # 0xffffffff81e1ca78 <trace_printk_fmt.21733>
>    0xffffffff816b2fa4 <+50>:    mov    0xf0(%rbx),%edx
>    0xffffffff816b2faa <+56>:    mov    $0xffffffff816b2f8c,%rdi
>    0xffffffff816b2fb1 <+63>:    callq  0xffffffff81171fc0 <__trace_bprintk>
>    0xffffffff816b2fb6 <+68>:    lock incl 0xf0(%rbx)
>    0xffffffff816b2fbd <+75>:    js     0xffffffff816b2fbf <in6_dev_getx+77>
>    0xffffffff816b2fbf <+77>:    lea    0xf0(%rbx),%rcx
>    0xffffffff816b2fc6 <+84>:    (bad)
>    0xffffffff816b2fc8 <+86>:    mov    0x769a99(%rip),%rsi        # 0xffffffff81e1ca68 <trace_printk_fmt.21744>
>    0xffffffff816b2fcf <+93>:    mov    0xf0(%rbx),%edx
>    0xffffffff816b2fd5 <+99>:    mov    $0xffffffff816b2f8c,%rdi
>    0xffffffff816b2fdc <+106>:   callq  0xffffffff81171fc0 <__trace_bprintk>
>    0xffffffff816b2fe1 <+111>:   mov    %r12,%rdi
>    0xffffffff816b2fe4 <+114>:   callq  *0xffffffff81c35a08
>    0xffffffff816b2feb <+121>:   decl   %gs:0x7e95a25e(%rip)        # 0xd250 <__preempt_count>
>    0xffffffff816b2ff2 <+128>:   mov    %rbx,%rax
>    0xffffffff816b2ff5 <+131>:   pop    %rbx
>    0xffffffff816b2ff6 <+132>:   pop    %r12
>    0xffffffff816b2ff8 <+134>:   pop    %rbp
>    0xffffffff816b2ff9 <+135>:   retq
>
> I don't get the section business at all, +75 looks to me like we're
> gonna trap no matter what.. as we appear to be doing.

The section stuff is supposed to be a trick to push the error case off
into the .text.unlikely area to avoid needing a jmp over the handler
and with possibly some redundancy removal done by the compiler (though
this appears to be rather limited) if it notices a bunch of error
paths are the same. However, in your disassembly, it's inline (!!) in
the code, as if "pushsection" and "popsection" were entirely ignored.

And when I make my own in6_dev_getx(), I see the same disassembly:

   0xffffffff818a757b <+181>:   lock incl 0x1e0(%rbx)
   0xffffffff818a7582 <+188>:   js     0xffffffff818a7584 <in6_dev_getx+190>
   0xffffffff818a7584 <+190>:   lea    0x1e0(%rbx),%rcx
   0xffffffff818a758b <+197>:   (bad)

Which is VERY different from how it looks in other places!

e.g. from lkdtm_REFCOUNT_INC_SATURATED:

   0xffffffff815657df <+47>:    lock incl -0xc(%rbp)
   0xffffffff815657e3 <+51>:    js     0xffffffff81565cac
...
   0xffffffff81565cac:  lea    -0xc(%rbp),%rcx
   0xffffffff81565cb0:  (bad)

So, at least I can reproduce this in the build now. I must not be
exercising these paths. FWIW, this is with Ubuntu's 6.3.0 gcc.

I'll try to figure out what's going on here...

-Kees

-- 
Kees Cook
Pixel Security
