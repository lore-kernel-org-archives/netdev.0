From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 24/26] ocfs2: reduce stack size with KASAN
Date: Thu, 2 Mar 2017 23:22:26 +0100
Message-ID: <CAK8P3a1gW9UqMKD2ijzxMH4rv1zAji0GUoz+bLY_oi0yvLU1cw@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-25-arnd@arndb.de>
 <1488476770.2179.6.camel@perches.com>
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
In-Reply-To: <1488476770.2179.6.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 2, 2017 at 6:46 PM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2017-03-02 at 17:38 +0100, Arnd Bergmann wrote:
>> The internal logging infrastructure in ocfs2 causes special warning code to be
>> used with KASAN, which produces rather large stack frames:
>
>> fs/ocfs2/super.c: In function 'ocfs2_fill_super':
>> fs/ocfs2/super.c:1219:1: error: the frame size of 3264 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
>
> At least by default it doesn't seem to.
>
> gcc 6.2 allyesconfig, CONFIG_KASAN=y
> with either CONFIG_KASAN_INLINE or CONFIG_KASAN_OUTLINE
>
> gcc doesn't emit a stack warning

The warning is disabled until patch 26/26. which picks the 3072 default.
The 3264 number was with gcc-7, which is worse than gcc-6 since it enables
an extra check.

>> By simply passing the mask by value instead of reference, we can avoid the
>> problem completely.
>
> Any idea why that's so?

With KASAN, every time we inline the function, the compiler has to allocate
space for another copy of the variable plus a redzone to detect whether
passing it by reference into another function causes an overflow at runtime.

>>  On 64-bit architectures, this is also more efficient,
>
> Efficient true, but the same overall stack no?

Here is what I see with CONFIG_FRAME_WARN=300 and x86_64-linux-gcc-6.3.1:

before:
fs/ocfs2/super.c: In function 'ocfs2_parse_options.isra.3':
fs/ocfs2/super.c:1508:1: error: the frame size of 352 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]
fs/ocfs2/super.c: In function 'ocfs2_enable_quotas':
fs/ocfs2/super.c:974:1: error: the frame size of 344 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]
fs/ocfs2/super.c: In function 'ocfs2_fill_super':
fs/ocfs2/super.c:1219:1: error: the frame size of 552 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]

after:
fs/ocfs2/super.c: In function 'ocfs2_fill_super':
fs/ocfs2/super.c:1219:1: error: the frame size of 472 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]

and with gcc-7.0.1 (including -fsanitize-address-use-after-scope), before:
fs/ocfs2/super.c: In function 'ocfs2_check_volume':
fs/ocfs2/super.c:2512:1: error: the frame size of 768 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]
fs/ocfs2/super.c: In function 'ocfs2_statfs':
fs/ocfs2/super.c:1717:1: error: the frame size of 320 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]
fs/ocfs2/super.c: In function 'ocfs2_parse_options.isra.3':
fs/ocfs2/super.c:1508:1: error: the frame size of 464 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]
fs/ocfs2/super.c: In function 'ocfs2_enable_quotas':
fs/ocfs2/super.c:974:1: error: the frame size of 320 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]
fs/ocfs2/super.c: In function 'ocfs2_remount':
fs/ocfs2/super.c:752:1: error: the frame size of 568 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]
fs/ocfs2/super.c: In function 'ocfs2_initialize_super.isra.8':
fs/ocfs2/super.c:2339:1: error: the frame size of 1712 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]
fs/ocfs2/super.c: In function 'ocfs2_fill_super':
fs/ocfs2/super.c:1219:1: error: the frame size of 3264 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]

after:
fs/ocfs2/super.c: In function 'ocfs2_fill_super':
fs/ocfs2/super.c:1219:1: error: the frame size of 704 bytes is larger
than 300 bytes [-Werror=frame-larger-than=]

     Arnd
