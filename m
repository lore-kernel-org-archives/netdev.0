From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH v2 03/11] tty: kbd: reduce stack size with KASAN
Date: Fri, 16 Jun 2017 14:07:48 -0700
Message-ID: <CAKdAkRR-3ZJd6VX0rPiA9qEBxGRptzTSypno6FqzbDyHRgD2XA@mail.gmail.com>
References: <20170614211556.2062728-1-arnd@arndb.de> <20170614211556.2062728-4-arnd@arndb.de>
 <20170615045221.GA26687@kroah.com> <20170615045347.GA26913@kroah.com>
 <CAK8P3a32abgm7H7s=dOTkLus3K9o79hRJ31s0eyEVZW30E9p7g@mail.gmail.com>
 <20170616130215.GC31057@kroah.com> <CAK8P3a2upDpcxGCLomyjvsXHfyeTyPmSj9qvymSsgf4pE+spDg@mail.gmail.com>
 <20170616155859.gn2einuermlncaku@var.youpi.perso.aquilenet.fr>
 <CAKdAkRQsVU42wGRmtAgVaEvHXaU1A=B=k8pHh6QiPOM847tqVA@mail.gmail.com> <CAK8P3a2_pZb_9UT-py_35C5WZ=siyhdE_pgZJKYFaoRdznEo_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Samuel Thibault <samuel.thibault@ens-lyon.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Jiri Slaby <jslaby@suse.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a2_pZb_9UT-py_35C5WZ=siyhdE_pgZJKYFaoRdznEo_A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2017 at 1:56 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Fri, Jun 16, 2017 at 7:29 PM, Dmitry Torokhov
> <dmitry.torokhov@gmail.com> wrote:
>> On Fri, Jun 16, 2017 at 8:58 AM, Samuel Thibault
>> <samuel.thibault@ens-lyon.org> wrote:
>>> I'm however afraid we'd have to mark a lot of static functions that way,
>>> depending on the aggressivity of gcc... I'd indeed really argue that gcc
>>> should consider stack usage when inlining.
>>>
>>> static int f(int foo) {
>>>         char c[256];
>>>         g(c, foo);
>>> }
>>>
>>> is really not something that I'd want to see the compiler to inline.
>>
>> Why would not we want it be inlined? What we do not want us several
>> calls having _separate_ instances of 'c' generated on the stack, all
>> inlined calls should share 'c'. And of course if we have f1, f2, and
>> f3 with c1, c2, and c3, GCC should not blow up the stack inlining and
>> allocating stack for all 3 of them beforehand.
>>
>> But this all seems to me issue that should be solved in toolchain, not
>> trying to play whack-a-mole with kernel sources.
>
> The problem for the Samuel's example is that
>
> a) the "--param asan-stack=1" option in KASAN does blow up the
>    stack, which is why the annotation is now called 'noinline_if_stackbloat'.
>
> b) The toolchain cannot solve the problem, as most instances of the
>    problem (unlike kbd_put_queue) force the inlining unless you build
>    with the x86-specific CONFIG_OPTIMIZE_INLINING.

If inlining done right there should be no change in stack size,
because if calls are not inlined then stack storage is "shared"
between calls, and it should similarly be shared when calls are
inlined. And that is toolchain issue.

-- 
Dmitry
