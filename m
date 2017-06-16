From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH v2 03/11] tty: kbd: reduce stack size with KASAN
Date: Fri, 16 Jun 2017 10:29:45 -0700
Message-ID: <CAKdAkRQsVU42wGRmtAgVaEvHXaU1A=B=k8pHh6QiPOM847tqVA@mail.gmail.com>
References: <20170614211556.2062728-1-arnd@arndb.de> <20170614211556.2062728-4-arnd@arndb.de>
 <20170615045221.GA26687@kroah.com> <20170615045347.GA26913@kroah.com>
 <CAK8P3a32abgm7H7s=dOTkLus3K9o79hRJ31s0eyEVZW30E9p7g@mail.gmail.com>
 <20170616130215.GC31057@kroah.com> <CAK8P3a2upDpcxGCLomyjvsXHfyeTyPmSj9qvymSsgf4pE+spDg@mail.gmail.com>
 <20170616155859.gn2einuermlncaku@var.youpi.perso.aquilenet.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Samuel Thibault <samuel.thibault@ens-lyon.org>,
        Arnd Bergmann <arnd@arndb.de>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170616155859.gn2einuermlncaku@var.youpi.perso.aquilenet.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2017 at 8:58 AM, Samuel Thibault
<samuel.thibault@ens-lyon.org> wrote:
> Arnd Bergmann, on ven. 16 juin 2017 17:41:47 +0200, wrote:
>> The problem are the 'ch' and 'flag' variables that are passed into
>> tty_insert_flip_char by value, and from there into
>> tty_insert_flip_string_flags by reference.  In this case, kasan tries
>> to detect whether tty_insert_flip_string_flags() does any out-of-bounds
>> access on the pointers and adds 64 bytes redzone around each of
>> the two variables.
>
> Ouch.
>
>> gcc-6.3.1 happens to inline 16 calls of tty_insert_flip_char() into

I wonder if we should stop marking tty_insert_flip_char() as inline.

>> kbd_keycode(), so the stack size grows from 168 bytes to
>> 168+(16*2*64) = 2216 bytes. There are 10 calls to put_queue()
>> in to_utf8(), 12 in emulate_raw() and another 4 in kbd_keycode()
>> itself.
>
> That's why I agreed for put_queue :)
>
> I'm however afraid we'd have to mark a lot of static functions that way,
> depending on the aggressivity of gcc... I'd indeed really argue that gcc
> should consider stack usage when inlining.
>
> static int f(int foo) {
>         char c[256];
>         g(c, foo);
> }
>
> is really not something that I'd want to see the compiler to inline.

Why would not we want it be inlined? What we do not want us several
calls having _separate_ instances of 'c' generated on the stack, all
inlined calls should share 'c'. And of course if we have f1, f2, and
f3 with c1, c2, and c3, GCC should not blow up the stack inlining and
allocating stack for all 3 of them beforehand.

But this all seems to me issue that should be solved in toolchain, not
trying to play whack-a-mole with kernel sources.

Thanks.

-- 
Dmitry
