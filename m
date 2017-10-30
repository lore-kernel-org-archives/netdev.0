From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [run_timer_softirq] BUG: unable to handle kernel paging request
 at 0000000000010007
Date: Mon, 30 Oct 2017 12:29:47 -0700
Message-ID: <CA+55aFxA=+iO1cysMnLZz1iNd4W+gEf4Ys9FGoWM+zmuST2KOQ@mail.gmail.com>
References: <CA+55aFxSJGeN=2X-uX-on1Uq2Nb8+v1aiMDz5H1+tKW_N5Q+6g@mail.gmail.com>
 <20171029225155.qcum5i75awrt5tzm@wfg-t540p.sh.intel.com> <20171029234820.nzwavupqlv2iqo3m@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171029234820.nzwavupqlv2iqo3m@wfg-t540p.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 29, 2017 at 4:48 PM, Fengguang Wu <fengguang.wu@intel.com> wrote:
>
> Here are 3 dmesgs related to wireless and 1 from ethernet.

Fengguang, these would be lovelier still _if_ you have DEBUG_INFO
enabled on the kernel, and your script were to find things like
"symbol+0xhex/0xhex", and run "./scripts/faddr2line" on them.

So

> [  235.425464] BUG: unable to handle kernel paging request at 0000000000010007
> [  235.425470] IP: run_timer_softirq+0x13a/0x470

would also then have

   run_timer_softirq at timer.c:XYZ

which would make it easier to see exactly _what_ it is that faults. As
it is, I think there's a fair number of inlining that makes it hard to
see the cause, but that faddrtoline would make very obvious.

Finding that "symbol+xyz/abc" pattern should be fairly easy to
automate, and should fit the 0day model fairly well. No?

In this case, the trapping instruction ends up decoding to

   0: 4c 8d 6c c5 90        lea    -0x70(%rbp,%rax,8),%r13
   5: 49 8b 45 00          mov    0x0(%r13),%rax
   9: 48 85 c0              test   %rax,%rax
   c: 74 de                je     0xffffffffffffffec
   e: 4d 8b 7d 00          mov    0x0(%r13),%r15
  12: 4d 89 7c 24 08        mov    %r15,0x8(%r12)
  17: 0f 1f 44 00 00        nopl   0x0(%rax,%rax,1)
  1c: 49 8b 07              mov    (%r15),%rax
  1f: 49 8b 57 08          mov    0x8(%r15),%rdx
  23: 48 85 c0              test   %rax,%rax
  26: 48 89 02              mov    %rax,(%rdx)
  29: 74 04                je     0x2f
  2b:* 48 89 50 08          mov    %rdx,0x8(%rax) <-- trapping instruction
  2f: 41 f6 47 2a 20        testb  $0x20,0x2a(%r15)
  34: 49 c7 47 08 00 00 00 movq   $0x0,0x8(%r15)

and %rax has the value 0xffff, so yes, it will trap at 0x10007.

It's not trivial to see just *wjhat* access it is.

I *think* that "testb $32" is checking for TIMER_IRQSAFE in
expire_timers(), and that the oops is due to the list operations in
detach_timer() (inlined).

Which doesn't really help: it looks like the timer lists are corrupt.
With some luck, some register state could have the timer function
pointer in it, and we'd get a hint of *which* timer this is, but that
doesn't look to be the case here either.

I'm not seeing anything to really help debug this here.

               Linus
