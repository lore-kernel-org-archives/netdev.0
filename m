From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH 01/26] compiler: introduce noinline_for_kasan annotation
Date: Fri, 3 Mar 2017 14:55:35 +0100
Message-ID: <CAG_fn=WayMEnBO4pzuxQ5jgn-ii6vrALuOex5Ei1ZhzMR7_tjg@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-2-arnd@arndb.de>
 <7e7a62de-3b79-6044-72fa-4ade418953d1@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Arnd Bergmann <arnd@arndb.de>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7e7a62de-3b79-6044-72fa-4ade418953d1@virtuozzo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 2:50 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
>
>
> On 03/02/2017 07:38 PM, Arnd Bergmann wrote:
>> When CONFIG_KASAN is set, we can run into some code that uses incredible
>> amounts of kernel stack:
>>
>> drivers/staging/dgnc/dgnc_neo.c:1056:1: error: the frame size of 11112 b=
ytes is larger than 2048 bytes [-Werror=3Dframe-larger-than=3D]
>> drivers/media/i2c/cx25840/cx25840-core.c:4960:1: error: the frame size o=
f 94000 bytes is larger than 2048 bytes [-Werror=3Dframe-larger-than=3D]
>> drivers/media/dvb-frontends/stv090x.c:3430:1: error: the frame size of 5=
312 bytes is larger than 3072 bytes [-Werror=3Dframe-larger-than=3D]
>>
>> This happens when a sanitizer uses stack memory each time an inline func=
tion
>> gets called. This introduces a new annotation for those functions to mak=
e
>> them either 'inline' or 'noinline' dependning on the CONFIG_KASAN symbol=
.
>>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>>  include/linux/compiler.h | 11 +++++++++++
>>  1 file changed, 11 insertions(+)
>>
>> diff --git a/include/linux/compiler.h b/include/linux/compiler.h
>> index f8110051188f..56b90897a459 100644
>> --- a/include/linux/compiler.h
>> +++ b/include/linux/compiler.h
>> @@ -416,6 +416,17 @@ static __always_inline void __write_once_size(volat=
ile void *p, void *res, int s
>>   */
>>  #define noinline_for_stack noinline
>>
>> +/*
>> + * CONFIG_KASAN can lead to extreme stack usage with certain patterns w=
hen
>> + * one function gets inlined many times and each instance requires a st=
ack
>> + * ckeck.
>> + */
>> +#ifdef CONFIG_KASAN
>> +#define noinline_for_kasan noinline __maybe_unused
>
>
> noinline_iff_kasan might be a better name.  noinline_for_kasan gives the =
impression
> that we always noinline function for the sake of kasan, while noinline_if=
f_kasan
> clearly indicates that function is noinline only if kasan is used.
FWIW we may be facing the same problem with other compiler-based
tools, e.g. KMSAN (which isn't there yet).
So it might be better to choose a macro name that doesn't use the name "KAS=
AN".
E.g. noinline_iff_memtool (or noinline_iff_memory_tool if that's not too lo=
ng).
WDYT?
>> +#else
>> +#define noinline_for_kasan inline
>> +#endif
>> +
>>  #ifndef __always_inline
>>  #define __always_inline inline
>>  #endif
>>
>
> --
> You received this message because you are subscribed to the Google Groups=
 "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgi=
d/kasan-dev/7e7a62de-3b79-6044-72fa-4ade418953d1%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
