From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 4/9] em28xx: fix em28xx_dvb_init for KASAN
Date: Mon, 25 Sep 2017 23:47:45 -0700
Message-ID: <CAK8P3a37Ts5q7BvA2JWse87huyAp+=e18CUXEt8731RrBnB+Ow@mail.gmail.com>
References: <20170922212930.620249-1-arnd@arndb.de> <20170922212930.620249-5-arnd@arndb.de>
 <063D6719AE5E284EB5DD2968C1650D6DD007F521@AcuExch.aculab.com> <CAK8P3a1zxjMsQTBPijCo8FJjEU5aRVTr7n_NZ1YM2UnDPKoRLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireles
To: David Laight <David.Laight@aculab.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a1zxjMsQTBPijCo8FJjEU5aRVTr7n_NZ1YM2UnDPKoRLw@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2017 at 11:32 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Mon, Sep 25, 2017 at 7:41 AM, David Laight <David.Laight@aculab.com> wrote:
>> From: Arnd Bergmann
>>> Sent: 22 September 2017 22:29
>> ...
>>> It seems that this is triggered in part by using strlcpy(), which the
>>> compiler doesn't recognize as copying at most 'len' bytes, since strlcpy
>>> is not part of the C standard.
>>
>> Neither is strncpy().
>>
>> It'll almost certainly be a marker in a header file somewhere,
>> so it should be possibly to teach it about other functions.
>
> I'm currently travelling and haven't investigated in detail, but from
> taking a closer look here, I found that the hardened 'strlcpy()'
> in include/linux/string.h triggers it. There is also a hardened
> (much shorted) 'strncpy()' that doesn't trigger it in the same file,
> and having only the extern declaration of strncpy also doesn't.

And a little more experimenting leads to this simple patch that fixes
the problem:

--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -254,7 +254,7 @@ __FORTIFY_INLINE size_t strlcpy(char *p, const
char *q, size_t size)
        size_t q_size = __builtin_object_size(q, 0);
        if (p_size == (size_t)-1 && q_size == (size_t)-1)
                return __real_strlcpy(p, q, size);
-       ret = strlen(q);
+       ret = __builtin_strlen(q);
        if (size) {
                size_t len = (ret >= size) ? size - 1 : ret;
                if (__builtin_constant_p(len) && len >= p_size)

The problem is apparently that the fortified strlcpy calls the fortified strlen,
which in turn calls strnlen and that ends up calling the extern '__real_strnlen'
that gcc cannot reduce to a constant expression for a constant input.

Not sure if that change is the best fix, but it seems to address the problem in
this driver and probably leads to better code in other places as well.

          Arnd
