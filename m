From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 11:38:25 -0600
Message-ID: <CAGXu5jJpFwiDR_o=oarN_2vDr56cwQ=Bg-5NikUmDtxtzWnAcQ@mail.gmail.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
 <1489678147-21404-8-git-send-email-elena.reshetova@intel.com> <1489683534.28631.231.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Elena Reshetova <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        bridge@lists.linux-foundation.org,
        LKML <linux-kernel@vger.kernel.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489683534.28631.231.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 16, 2017 at 10:58 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-16 at 17:28 +0200, Elena Reshetova wrote:
>> refcount_t type and corresponding API should be
>> used instead of atomic_t when the variable is used as
>> a reference counter. This allows to avoid accidental
>> refcounter overflows that might lead to use-after-free
>> situations.
>
>
> ...
>
>>  static __always_inline void sock_hold(struct sock *sk)
>>  {
>> -     atomic_inc(&sk->sk_refcnt);
>> +     refcount_inc(&sk->sk_refcnt);
>>  }
>>
>
> While I certainly see the value of these refcount_t, we have a very
> different behavior on these atomic_inc() which were doing a single
> inlined LOCK RMW on x86.

I think we can certainly investigate arch-specific ways to improve the
performance, but the consensus seemed to be that getting the
infrastructure in and doing the migration was the first set of steps.

> We now call an external function performing a
> atomic_read(), various ops/tests, then atomic_cmpxchg_relaxed(), in a
> loop, loosing the nice ability for x86 of preventing live locks.
>
> Looks a lot of bloat, just to be able to chase hypothetical bugs in the
> kernel.
>
> I would love to have a way to enable extra debugging when I want a debug
> kernel, like LOCKDEP or KASAN.
>
> By adding all this bloat, we assert linux kernel is terminally buggy and
> every atomic_inc() we did was suspicious, and need to be always
> instrumented/validated.

This IS the assertion, unfortunately. With average 5 year lifetimes on
security flaws[1], and many of the last couple years' public exploits
being refcount flaws[2], this is something we have to get done. We
need the default kernel to be much more self-protective, and this is
one of many places to make it happen.

I am, of course, biased, but I think the evidence of actual
refcounting attacks outweighs the theoretical performance cost of
these changes. If there is a realistic workflow that shows actual
problems, let's examine it and find a solution for that as a separate
part of this work without blocking this migration.

-Kees

[1] https://outflux.net/blog/archives/2016/10/18/security-bug-lifetime/
[2] http://kernsec.org/wiki/index.php/Bug_Classes/Integer_overflow

-- 
Kees Cook
Pixel Security
