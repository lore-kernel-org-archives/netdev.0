From: Kees Cook <keescook@chromium.org>
Subject: Re: tip -ENOBOOT - bisected to locking/refcounts, x86/asm: Implement
 fast refcount overflow protection
Date: Wed, 30 Aug 2017 21:10:37 -0700
Message-ID: <CAGXu5jKYPp5D+YxtqrJXsi48UUbjfeREngsys-dU1eP4RnnL+w@mail.gmail.com>
References: <1503996623.8323.20.camel@gmx.de> <CAGXu5jLYHy6Damtg_Pc4=G76OUiMV3fcY9+Ru1-Lmiq6VWEgsw@mail.gmail.com>
 <1504025721.6024.25.camel@gmx.de> <1504030207.6560.0.camel@gmx.de>
 <CAGXu5jKSWiZ8NkgUqO6G8fs5R06bMtdFBmZz9MMX-HAk8nXXNw@mail.gmail.com>
 <1504069332.8352.3.camel@gmx.de> <CAGXu5jJim=r8b+y1qQXtuzm9fPyv1tp9ANebxbCc9ic2c83_Mg@mail.gmail.com>
 <1504113212.5852.6.camel@gmx.de> <CAGXu5jJd80-0PJvB51x9ZDETPSoAtRVQ7dQ6HWwd0DYpKBgPFA@mail.gmail.com>
 <1504115735.5852.11.camel@gmx.de> <CAGXu5j+BLj6_LPfKs-vts-mbyJHu8D--WrmWbiT8Zbt-iD65KA@mail.gmail.com>
 <CAGXu5j+neSYAqb8=r42=jQ0LsJTGjCSdpgc9Hv+ipyAFURbCdw@mail.gmail.com>
 <1504145389.23109.4.camel@gmx.de> <CAGXu5jLKXEDdSpxxVM5oHHUWKbSTozx4FZRn70bQm4tQAhMqUQ@mail.gmail.com>
 <1504149176.23109.9.camel@gmx.de> <CAGXu5j+uNU+wqWoCV+Kpdp+DQer4E3VuwO0mtXiW3Dtw_61QKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>,
        "David S. Miller" <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5j+uNU+wqWoCV+Kpdp+DQer4E3VuwO0mtXiW3Dtw_61QKA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 9:01 PM, Kees Cook <keescook@chromium.org> wrote:
> On Wed, Aug 30, 2017 at 8:12 PM, Mike Galbraith <efault@gmx.de> wrote:
>> On Wed, 2017-08-30 at 19:27 -0700, Kees Cook wrote:
>>
>>> Interesting! Can you try with 633547973ffc3 ("net: convert
>>> sk_buff.users from atomic_t to refcount_t") reverted? I'll see if
>>> running haveged will help me trigger this on my system...
>>
>> With that (plus 230cd1279d001 fix to it) reverted, vbox boots.
>
> Wonderful! Thank you so much for helping track this down.
>
> So, it seems that sk_buff.users will need some more special attention
> before we can convert it to refcount.
>
> x86-refcount will saturate with refcount_dec_and_test() if the result
> is negative. But that would mean at least starting at 0. FULL should
> have WARNed in this case, so I remain slightly confused why it was
> missed by FULL.

Actually, if this is a race condition it's possible that FULL is slow
enough to miss it...

I bet something briefly takes the refcount negative, and with
unchecked atomics, it come back up positive again during the race.
FULL may miss the race, and x86-refcount will catch it and saturate...

-Kees

-- 
Kees Cook
Pixel Security
