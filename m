From: Mike Galbraith <efault@gmx.de>
Subject: Re: tip -ENOBOOT - bisected to locking/refcounts, x86/asm:
 Implement fast refcount overflow protection
Date: Fri, 01 Sep 2017 21:24:10 +0200
Message-ID: <1504293850.6217.4.camel@gmx.de>
References: <1503996623.8323.20.camel@gmx.de>
         <CAGXu5jLYHy6Damtg_Pc4=G76OUiMV3fcY9+Ru1-Lmiq6VWEgsw@mail.gmail.com>
         <1504025721.6024.25.camel@gmx.de> <1504030207.6560.0.camel@gmx.de>
         <CAGXu5jKSWiZ8NkgUqO6G8fs5R06bMtdFBmZz9MMX-HAk8nXXNw@mail.gmail.com>
         <1504069332.8352.3.camel@gmx.de>
         <CAGXu5jJim=r8b+y1qQXtuzm9fPyv1tp9ANebxbCc9ic2c83_Mg@mail.gmail.com>
         <1504113212.5852.6.camel@gmx.de>
         <CAGXu5jJd80-0PJvB51x9ZDETPSoAtRVQ7dQ6HWwd0DYpKBgPFA@mail.gmail.com>
         <1504115735.5852.11.camel@gmx.de>
         <CAGXu5j+BLj6_LPfKs-vts-mbyJHu8D--WrmWbiT8Zbt-iD65KA@mail.gmail.com>
         <CAGXu5j+neSYAqb8=r42=jQ0LsJTGjCSdpgc9Hv+ipyAFURbCdw@mail.gmail.com>
         <1504145389.23109.4.camel@gmx.de>
         <CAGXu5jLKXEDdSpxxVM5oHHUWKbSTozx4FZRn70bQm4tQAhMqUQ@mail.gmail.com>
         <1504149176.23109.9.camel@gmx.de>
         <CAGXu5j+uNU+wqWoCV+Kpdp+DQer4E3VuwO0mtXiW3Dtw_61QKA@mail.gmail.com>
         <CAGXu5jKYPp5D+YxtqrJXsi48UUbjfeREngsys-dU1eP4RnnL+w@mail.gmail.com>
         <1504187918.27500.16.camel@gmx.de>
         <CAGXu5jL8Ueuw-DLY+Hz8Jd7NgqgyaaN8OVDicFxmcjBhScebOA@mail.gmail.com>
         <1504199967.666.16.camel@gmx.de>
         <CAGXu5j+RPDAP-dK+dizQV4prmWBhqU_G1PccWpME=924-2985w@mail.gmail.com>
         <1504249070.17604.20.camel@gmx.de> <1504271369.332.29.camel@gmx.de>
         <CAGXu5jJ+zq=4Un2JpwWk==sThEYeyqYuvesN6=H-1XeLxW_C0Q@mail.gmail.com>
         <1504288357.6035.21.camel@gmx.de>
         <CAGXu5jKiGFAp8Lp2Nt1yHg_nYsY_rfrUjMgOPTNxMLkbQ8V-ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jKiGFAp8Lp2Nt1yHg_nYsY_rfrUjMgOPTNxMLkbQ8V-ng@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-09-01 at 11:58 -0700, Kees Cook wrote:
> 
> The section stuff is supposed to be a trick to push the error case off
> into the .text.unlikely area to avoid needing a jmp over the handler
> and with possibly some redundancy removal done by the compiler (though
> this appears to be rather limited) if it notices a bunch of error
> paths are the same. However, in your disassembly, it's inline (!!) in
> the code, as if "pushsection" and "popsection" were entirely ignored.
> 
> And when I make my own in6_dev_getx(), I see the same disassembly:
> 
>    0xffffffff818a757b <+181>:   lock incl 0x1e0(%rbx)
>    0xffffffff818a7582 <+188>:   js     0xffffffff818a7584 <in6_dev_getx+190>
>    0xffffffff818a7584 <+190>:   lea    0x1e0(%rbx),%rcx
>    0xffffffff818a758b <+197>:   (bad)
> 
> Which is VERY different from how it looks in other places!
> 
> e.g. from lkdtm_REFCOUNT_INC_SATURATED:
> 
>    0xffffffff815657df <+47>:    lock incl -0xc(%rbp)
>    0xffffffff815657e3 <+51>:    js     0xffffffff81565cac
> ...
>    0xffffffff81565cac:  lea    -0xc(%rbp),%rcx
>    0xffffffff81565cb0:  (bad)
> 
> So, at least I can reproduce this in the build now. I must not be
> exercising these paths. FWIW, this is with Ubuntu's 6.3.0 gcc.
> 
> I'll try to figure out what's going on here...

Heh, make in6_dev_getx() __always_inline.

       swapper/0-1     [000] d..1     1.438587: ip6_route_init_special_entries: PRE refs.counter:3
       swapper/0-1     [000] d..1     1.438590: ip6_route_init_special_entries: POST refs.counter:4
       swapper/0-1     [000] d..1     1.438591: ip6_route_init_special_entries: PRE refs.counter:4
       swapper/0-1     [000] d..1     1.438592: ip6_route_init_special_entries: POST refs.counter:5
       swapper/0-1     [000] d..1     1.438592: ip6_route_init_special_entries: PRE refs.counter:5
       swapper/0-1     [000] d..1     1.438593: ip6_route_init_special_entries: POST refs.counter:6

	-Mike
