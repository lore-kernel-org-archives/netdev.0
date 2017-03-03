From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 00/26] bring back stack frame warning with KASAN
Date: Fri, 3 Mar 2017 13:54:00 +0100
Message-ID: <CAK8P3a1tek+4zWwHJtXO=r7Zqe7atwrPk70hWcM_Qp_Ekv9KHw@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <CAG_fn=UVcLhP8mH6tvzqZUn4u9T4pnQw8bMf=qccNro59VcABw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG_fn=UVcLhP8mH6tvzqZUn4u9T4pnQw8bMf=qccNro59VcABw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 1:25 PM, Alexander Potapenko <glider@google.com> wrote:
> On Thu, Mar 2, 2017 at 5:38 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> It took a long while to get this done, but I'm finally ready
>> to send the first half of the KASAN stack size patches that
>> I did in response to the kernelci.org warnings.
>>
>> As before, it's worth mentioning that things are generally worse
>> with gcc-7.0.1 because of the addition of -fsanitize-address-use-after-scope
>> that are not present on kernelci, so my randconfig testing found
>> a lot more than kernelci did.
>>
>> The main areas are:
>>
>> - READ_ONCE/WRITE_ONCE cause problems in lots of code
>> - typecheck() causes huge problems in a few places
>> - I'm introducing "noinline_for_kasan" and use it in a lot
>>   of places that suffer from inline functions with local variables
>>   - netlink, as used in various parts of the kernel
>>   - a number of drivers/media drivers
>>   - a handful of wireless network drivers
>> - kmemcheck conflicts with -fsanitize-address-use-after-scope
>>
>> This series lets us add back a stack frame warning for 3072 bytes
>> with -fsanitize-address-use-after-scope, or 2048 bytes without it.
>>
>> I have a follow-up series that further reduces the stack frame
>> warning limit to 1280 bytes for all 64-bit architectures, and
>> 1536 bytes with basic KASAN support (no -fsanitize-address-use-after-scope).
>> For now, I'm only posting the first half, in order to keep
>> it (barely) reviewable.
>
> Can you please elaborate on why do you need this? Are you trying to
> squeeze KASAN into some embedded device?
> Noinlines sprayed over the codebase are hard to maintain, and certain
> compiler changes may cause bloated stack frames in other places.
> Maybe it should be enough to just increase the stack frame limit in
> KASAN builds, as Dmitry suggested previously?

The current state of mainline has doubled the kernel stack size with
KASAN, and completely turned off the warning for per-function
stack frames. In some cases, this is completely broken as we have
functions that exceed even the 32kb per-thread stacks by themselves,
so I want to turn on the warning again and fix all the outliers.

The hard part is deciding what size is reasonable for a given function,
as smaller limits cause more harmless warnings while larger limits
can hide more actual problems. Before running into the KASAN
problem, I had already determined that we can lower the warning
limit for 64-bit architectures from 2048 bytes to 1280 with just
a handful of patches that are generally a good cleanup anyway.

This led me to picking three separate warning limits, based on
what I found reasonable to work around in the code:

3072 bytes with -fsanitize-address-use-after-scope
1536 bytes with KASAN but without -fsanitize-address-use-after-scope
1280 bytes on 64-bit without KASAN
1024 bytes on 32-bit architectures

If we use higher limits, the patch series will get a bit shorter. For
the limits above, I needed a total of 51 patches, while this shorter
series of 26 patches has slightly laxer limits:

3072 bytes with -fsanitize-address-use-after-scope
2048 bytes on 64-bit architectures with or without KASAN, but
          without  -fsanitize-address-use-after-scope
1024 bytes on 32-bit architectures

The individual patches should list the highest frame size I ran
into, so I can try to reduce the number of patches if you have
a suggestion for a different set of limits.

       Arnd
