From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 01/26] compiler: introduce noinline_for_kasan annotation
Date: Fri, 3 Mar 2017 15:30:37 +0100
Message-ID: <CAK8P3a3+8wxsUntUnOteOv8_p=yBZLk-4Uu-HGM17o9n9OqteQ@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-2-arnd@arndb.de>
 <7e7a62de-3b79-6044-72fa-4ade418953d1@virtuozzo.com> <CAG_fn=WayMEnBO4pzuxQ5jgn-ii6vrALuOex5Ei1ZhzMR7_tjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG_fn=WayMEnBO4pzuxQ5jgn-ii6vrALuOex5Ei1ZhzMR7_tjg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 2:55 PM, Alexander Potapenko <glider@google.com> wrote:
> On Fri, Mar 3, 2017 at 2:50 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

>>> @@ -416,6 +416,17 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
>>>   */
>>>  #define noinline_for_stack noinline
>>>
>>> +/*
>>> + * CONFIG_KASAN can lead to extreme stack usage with certain patterns when
>>> + * one function gets inlined many times and each instance requires a stack
>>> + * ckeck.
>>> + */
>>> +#ifdef CONFIG_KASAN
>>> +#define noinline_for_kasan noinline __maybe_unused
>>
>>
>> noinline_iff_kasan might be a better name.  noinline_for_kasan gives the impression
>> that we always noinline function for the sake of kasan, while noinline_iff_kasan
>> clearly indicates that function is noinline only if kasan is used.

Fine with me. I actually tried to come up with a name that implies that the
symbol is actually "inline" (or even __always_inline_ without KASAN, but
couldn't think of any good name for it.

> FWIW we may be facing the same problem with other compiler-based
> tools, e.g. KMSAN (which isn't there yet).
> So it might be better to choose a macro name that doesn't use the name "KASAN".
> E.g. noinline_iff_memtool (or noinline_iff_memory_tool if that's not too long).
> WDYT?

Would KMSAN also force local variables to be non-overlapping the way that
asan-stack=1 and -fsanitize-address-use-after-scope do? As I understood it,
KMSAN would add extra code for maintaining the uninit bits, but in an example
like this

int f(int *);
static inline __attribute__((always_inline)) int g(void)
{
    int i;
    f(&i);
    return i;
}
int f(void)
{
     return g()+g()+g()+g();
}

each of the four copies of 'i' could have the same location on the stack
and get marked uninitialized again before calling f(). We only need
noinline_for_kasan (whatever we end up calling that) for compiler
features that force each instance of 'i' to have its own stack redzone.

     Arnd
