From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 4/9] em28xx: fix em28xx_dvb_init for KASAN
Date: Wed, 27 Sep 2017 06:26:21 -0700
Message-ID: <CAK8P3a2C7DBTfQZvRi-QQfrfm1GXktFcXQRmXmzpF4SCa+BADA@mail.gmail.com>
References: <20170922212930.620249-1-arnd@arndb.de> <20170922212930.620249-5-arnd@arndb.de>
 <063D6719AE5E284EB5DD2968C1650D6DD007F521@AcuExch.aculab.com>
 <CAK8P3a1zxjMsQTBPijCo8FJjEU5aRVTr7n_NZ1YM2UnDPKoRLw@mail.gmail.com>
 <CAK8P3a37Ts5q7BvA2JWse87huyAp+=e18CUXEt8731RrBnB+Ow@mail.gmail.com> <e7e6418e-4340-5057-aa17-800082aca5fb@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Laight <David.Laight@aculab.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
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
        "linux-wireless@v
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <e7e6418e-4340-5057-aa17-800082aca5fb@virtuozzo.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2017 at 9:49 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 09/26/2017 09:47 AM, Arnd Bergmann wrote:
>> On Mon, Sep 25, 2017 at 11:32 PM, Arnd Bergmann <arnd@arndb.de> wrote:

>> +       ret = __builtin_strlen(q);
>
>
> I think this is not correct. Fortified strlen called here on purpose. If sizeof q is known at compile time
> and 'q' contains not-null fortified strlen() will panic.

Ok, got it.

>>         if (size) {
>>                 size_t len = (ret >= size) ? size - 1 : ret;
>>                 if (__builtin_constant_p(len) && len >= p_size)
>>
>> The problem is apparently that the fortified strlcpy calls the fortified strlen,
>> which in turn calls strnlen and that ends up calling the extern '__real_strnlen'
>> that gcc cannot reduce to a constant expression for a constant input.
>
>
> Per my observation, it's the code like this:
>         if ()
>                 fortify_panic(__func__);
>
>
> somehow prevent gcc to merge several "struct i2c_board_info info;" into one stack slot.
> With the hack bellow, stack usage reduced to ~1,6K:

1.6k is also what I see with my patch, or any other approach I tried
that changes
string.h. With the split up em28xx_dvb_init() function (and without
changes to string.h),
I got down to a few hundred bytes for the largest handler.

> ---
>  include/linux/string.h | 4 ----
>  1 file changed, 4 deletions(-)
>
> diff --git a/include/linux/string.h b/include/linux/string.h
> index 54d21783e18d..9a96ff3ebf94 100644
> --- a/include/linux/string.h
> +++ b/include/linux/string.h
> @@ -261,8 +261,6 @@ __FORTIFY_INLINE __kernel_size_t strlen(const char *p)
>         if (p_size == (size_t)-1)
>                 return __builtin_strlen(p);
>         ret = strnlen(p, p_size);
> -       if (p_size <= ret)
> -               fortify_panic(__func__);
>         return ret;
>  }
>
> @@ -271,8 +269,6 @@ __FORTIFY_INLINE __kernel_size_t strnlen(const char *p, __kernel_size_t maxlen)
>  {
>         size_t p_size = __builtin_object_size(p, 0);
>         __kernel_size_t ret = __real_strnlen(p, maxlen < p_size ? maxlen : p_size);
> -       if (p_size <= ret && maxlen != ret)
> -               fortify_panic(__func__);
>         return ret;

I've reduced it further to this change:

--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -227,7 +227,7 @@ static inline const char *kbasename(const char *path)
 #define __FORTIFY_INLINE extern __always_inline __attribute__((gnu_inline))
 #define __RENAME(x) __asm__(#x)

-void fortify_panic(const char *name) __noreturn __cold;
+void fortify_panic(const char *name) __cold;
 void __read_overflow(void) __compiletime_error("detected read beyond
size of object passed as 1st parameter");
 void __read_overflow2(void) __compiletime_error("detected read beyond
size of object passed as 2nd parameter");
 void __read_overflow3(void) __compiletime_error("detected read beyond
size of object passed as 3rd parameter");

I don't immediately see why the __noreturn changes the behavior here, any idea?

>> Not sure if that change is the best fix, but it seems to address the problem in
>> this driver and probably leads to better code in other places as well.
>>
>
> Probably it would be better to solve this on the strlcpy side, but I haven't found the way to do this right.
> Alternative solutions:
>
>  - use memcpy() instead of strlcpy(). All source strings are smaller than I2C_NAME_SIZE, so we could
>    do something like this - memcpy(info.type, "si2168", sizeof("si2168"));
>    Also this should be faster.

This would be very similar to the patch I posted at the start of this
thread to use strncpy(), right?
I was hoping that changing strlcpy() here could also improve other
users that might run into
the same situation, but stay below the 2048-byte stack frame limit.

>  - Move code under different "case:" in the switch(dev->model) to the separate function should help as well.
>    But it might be harder to backport into stables.

Agreed, I posted this in earlier versions of the patch series, see
https://patchwork.kernel.org/patch/9601025/

The new patch was a result of me trying to come up with a less
invasive version to
make it easier to backport, since I would like to backport the last
patch in the series
that depends on all the earlier ones.

         Arnd
