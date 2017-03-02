From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 24/26] ocfs2: reduce stack size with KASAN
Date: Thu, 2 Mar 2017 23:59:22 +0100
Message-ID: <CAK8P3a2ZQR8ukt6Aky7onD2Y=b+Cz+pp+C0+Svb2EyK2474j-g@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-25-arnd@arndb.de>
 <1488476770.2179.6.camel@perches.com> <CAK8P3a1gW9UqMKD2ijzxMH4rv1zAji0GUoz+bLY_oi0yvLU1cw@mail.gmail.com>
 <1488494428.2179.23.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488494428.2179.23.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 2, 2017 at 11:40 PM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2017-03-02 at 23:22 +0100, Arnd Bergmann wrote:
>> On Thu, Mar 2, 2017 at 6:46 PM, Joe Perches <joe@perches.com> wrote:
>> > On Thu, 2017-03-02 at 17:38 +0100, Arnd Bergmann wrote:
>> > > The internal logging infrastructure in ocfs2 causes special warning code to be
>> > > used with KASAN, which produces rather large stack frames:
>> > > fs/ocfs2/super.c: In function 'ocfs2_fill_super':
>> > > fs/ocfs2/super.c:1219:1: error: the frame size of 3264 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
>> >
>> > At least by default it doesn't seem to.
>> >
>> > gcc 6.2 allyesconfig, CONFIG_KASAN=y
>> > with either CONFIG_KASAN_INLINE or CONFIG_KASAN_OUTLINE
>> >
>> > gcc doesn't emit a stack warning
>>
>> The warning is disabled until patch 26/26. which picks the 3072 default.
>> The 3264 number was with gcc-7, which is worse than gcc-6 since it enables
>> an extra check.
>>
>> > > By simply passing the mask by value instead of reference, we can avoid the
>> > > problem completely.
>> >
>> > Any idea why that's so?
>>
>> With KASAN, every time we inline the function, the compiler has to allocate
>> space for another copy of the variable plus a redzone to detect whether
>> passing it by reference into another function causes an overflow at runtime.
>
> These logging functions aren't inlined.

Sorry, my mistake. In this case mlog() is a macro, not an inline functions.
The effect is the same though.

> You're referring to the stack frame?

The stack frame of the function that calls mlog(), yes.
>
> Still doesn't make sense to me.
>
> None of the logging functions are inlined as they are all
> EXPORT_SYMBOL.

mlog() is placed in the calling function.

> This just changes a pointer to a u64, which is the same
> size on x86-64 (and is of course larger on x86-32).

KASAN decides that passing a pointer to _m into an extern function
(_mlog_printk) is potentially dangerous, as that function might
keep a reference to that pointer after it goes out of scope,
or it might not know the correct length of the stack object pointed to.

We can see from looking at the __mlog_printk() function definition
that it's actually safe, but the compiler cannot see that when looking
at another source file.

> Perhaps KASAN has the odd behavior and working around
> KASAN's behavior may not be the proper thing to do.

Turning off KASAN fixes the problem, but the entire purpose of
KASAN is to identify code that is potentially dangerous.

> Maybe if CONFIG_KASAN is set, the minimum stack should
> be increased via THREAD_SIZE_ORDER or some such.

This is what happened in 3f181b4d8652 ("lib/Kconfig.debug:
disable -Wframe-larger-than warnings with KASAN=y").

I'm trying to revert that patch so we actually get warnings
again about functions that are still dangerous. I picked 3072
as an arbitrary limit, as there are only a handful of files
that use larger stack frames in the worst case, but we can
only use that limit after fixing up all the warnings it shows.

       Arnd
