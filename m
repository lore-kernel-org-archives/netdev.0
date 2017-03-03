From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH 01/26] compiler: introduce noinline_for_kasan annotation
Date: Fri, 3 Mar 2017 15:33:16 +0100
Message-ID: <CAG_fn=X3PDDpX_K8Dhk-yCviC87ycRaX4X1d+rJENPZJK_rFmw@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-2-arnd@arndb.de>
 <7e7a62de-3b79-6044-72fa-4ade418953d1@virtuozzo.com> <CAG_fn=WayMEnBO4pzuxQ5jgn-ii6vrALuOex5Ei1ZhzMR7_tjg@mail.gmail.com>
 <CAK8P3a3+8wxsUntUnOteOv8_p=yBZLk-4Uu-HGM17o9n9OqteQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a3+8wxsUntUnOteOv8_p=yBZLk-4Uu-HGM17o9n9OqteQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 3:30 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Fri, Mar 3, 2017 at 2:55 PM, Alexander Potapenko <glider@google.com> w=
rote:
>> On Fri, Mar 3, 2017 at 2:50 PM, Andrey Ryabinin <aryabinin@virtuozzo.com=
> wrote:
>
>>>> @@ -416,6 +416,17 @@ static __always_inline void __write_once_size(vol=
atile void *p, void *res, int s
>>>>   */
>>>>  #define noinline_for_stack noinline
>>>>
>>>> +/*
>>>> + * CONFIG_KASAN can lead to extreme stack usage with certain patterns=
 when
>>>> + * one function gets inlined many times and each instance requires a =
stack
>>>> + * ckeck.
>>>> + */
>>>> +#ifdef CONFIG_KASAN
>>>> +#define noinline_for_kasan noinline __maybe_unused
>>>
>>>
>>> noinline_iff_kasan might be a better name.  noinline_for_kasan gives th=
e impression
>>> that we always noinline function for the sake of kasan, while noinline_=
iff_kasan
>>> clearly indicates that function is noinline only if kasan is used.
>
> Fine with me. I actually tried to come up with a name that implies that t=
he
> symbol is actually "inline" (or even __always_inline_ without KASAN, but
> couldn't think of any good name for it.
>
>> FWIW we may be facing the same problem with other compiler-based
>> tools, e.g. KMSAN (which isn't there yet).
>> So it might be better to choose a macro name that doesn't use the name "=
KASAN".
>> E.g. noinline_iff_memtool (or noinline_iff_memory_tool if that's not too=
 long).
>> WDYT?
>
> Would KMSAN also force local variables to be non-overlapping the way that
> asan-stack=3D1 and -fsanitize-address-use-after-scope do? As I understood=
 it,
> KMSAN would add extra code for maintaining the uninit bits, but in an exa=
mple
> like this
The thing is that KMSAN (and other tools that insert heavyweight
instrumentation) may cause heavy register spilling which will also
blow up the stack frames.
> int f(int *);
> static inline __attribute__((always_inline)) int g(void)
> {
>     int i;
>     f(&i);
>     return i;
> }
> int f(void)
> {
>      return g()+g()+g()+g();
> }
>
> each of the four copies of 'i' could have the same location on the stack
> and get marked uninitialized again before calling f(). We only need
> noinline_for_kasan (whatever we end up calling that) for compiler
> features that force each instance of 'i' to have its own stack redzone.
>
>      Arnd



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
