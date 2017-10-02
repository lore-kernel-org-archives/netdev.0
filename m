From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 4/9] em28xx: fix em28xx_dvb_init for KASAN
Date: Mon, 2 Oct 2017 10:33:37 +0200
Message-ID: <CAK8P3a0WtHjvo6tOp79U4gKjLSRmVCAmjYU_xTVJfBL1Qe-hdQ@mail.gmail.com>
References: <20170922212930.620249-1-arnd@arndb.de> <20170922212930.620249-5-arnd@arndb.de>
 <063D6719AE5E284EB5DD2968C1650D6DD007F521@AcuExch.aculab.com>
 <CAK8P3a1zxjMsQTBPijCo8FJjEU5aRVTr7n_NZ1YM2UnDPKoRLw@mail.gmail.com>
 <CAK8P3a37Ts5q7BvA2JWse87huyAp+=e18CUXEt8731RrBnB+Ow@mail.gmail.com>
 <e7e6418e-4340-5057-aa17-800082aca5fb@virtuozzo.com> <CAK8P3a2C7DBTfQZvRi-QQfrfm1GXktFcXQRmXmzpF4SCa+BADA@mail.gmail.com>
 <2631e8a6-03f2-69ea-d889-afd9a345e7ef@virtuozzo.com> <CAK8P3a3BiPh+d4vcb4pbbOsZLegp6YGk+BU3L=71sxatTuk-GQ@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a3BiPh+d4vcb4pbbOsZLegp6YGk+BU3L=71sxatTuk-GQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 4:30 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Thu, Sep 28, 2017 at 6:09 AM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> On 09/27/2017 04:26 PM, Arnd Bergmann wrote:
>>> On Tue, Sep 26, 2017 at 9:49 AM, Andrey Ryabinin
>>> <aryabinin@virtuozzo.com> wrote:
>
>>> --- a/include/linux/string.h
>>> +++ b/include/linux/string.h
>>> @@ -227,7 +227,7 @@ static inline const char *kbasename(const char *path)
>>>  #define __FORTIFY_INLINE extern __always_inline __attribute__((gnu_inline))
>>>  #define __RENAME(x) __asm__(#x)
>>>
>>> -void fortify_panic(const char *name) __noreturn __cold;
>>> +void fortify_panic(const char *name) __cold;
>>>  void __read_overflow(void) __compiletime_error("detected read beyond
>>> size of object passed as 1st parameter");
>>>  void __read_overflow2(void) __compiletime_error("detected read beyond
>>> size of object passed as 2nd parameter");
>>>  void __read_overflow3(void) __compiletime_error("detected read beyond
>>> size of object passed as 3rd parameter");
>>>
>>> I don't immediately see why the __noreturn changes the behavior here, any idea?
>>>
>>
>>
>> At first I thought that this somehow might be related to __asan_handle_no_return(). GCC calls it
>> before noreturn function. So I made patch to remove generation of these calls (we don't need them in the kernel anyway)
>> but it didn't help. It must be something else than.
>
> I made a reduced test case yesterday (see http://paste.ubuntu.com/25628030/),
> and it shows the same behavior with and without the sanitizer, it uses 128
> bytes without the noreturn attribute and 480 bytes when its added, the sanitizer
> adds a factor of 1.5x on top. It's possible that I did something wrong while
> reducing, since the original driver file uses very little stack (a few hundred
> bytes) without -fsanitize=kernel-address, but finding out what happens in
> the reduced case may still help understand the other one.

This is now GCC PR82365, see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=82365

I've come up with a workaround, but I'm not sure if that is any better than the
alternatives, will send the patch as a follow-up in a bit.

     Arnd
