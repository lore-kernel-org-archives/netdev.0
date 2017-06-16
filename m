From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 03/11] tty: kbd: reduce stack size with KASAN
Date: Fri, 16 Jun 2017 22:56:53 +0200
Message-ID: <CAK8P3a2_pZb_9UT-py_35C5WZ=siyhdE_pgZJKYFaoRdznEo_A@mail.gmail.com>
References: <20170614211556.2062728-1-arnd@arndb.de> <20170614211556.2062728-4-arnd@arndb.de>
 <20170615045221.GA26687@kroah.com> <20170615045347.GA26913@kroah.com>
 <CAK8P3a32abgm7H7s=dOTkLus3K9o79hRJ31s0eyEVZW30E9p7g@mail.gmail.com>
 <20170616130215.GC31057@kroah.com> <CAK8P3a2upDpcxGCLomyjvsXHfyeTyPmSj9qvymSsgf4pE+spDg@mail.gmail.com>
 <20170616155859.gn2einuermlncaku@var.youpi.perso.aquilenet.fr> <CAKdAkRQsVU42wGRmtAgVaEvHXaU1A=B=k8pHh6QiPOM847tqVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Samuel Thibault <samuel.thibault@ens-lyon.org>,
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
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKdAkRQsVU42wGRmtAgVaEvHXaU1A=B=k8pHh6QiPOM847tqVA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2017 at 7:29 PM, Dmitry Torokhov
<dmitry.torokhov@gmail.com> wrote:
> On Fri, Jun 16, 2017 at 8:58 AM, Samuel Thibault
> <samuel.thibault@ens-lyon.org> wrote:
>> Arnd Bergmann, on ven. 16 juin 2017 17:41:47 +0200, wrote:
>>> The problem are the 'ch' and 'flag' variables that are passed into
>>> tty_insert_flip_char by value, and from there into
>>> tty_insert_flip_string_flags by reference.  In this case, kasan tries
>>> to detect whether tty_insert_flip_string_flags() does any out-of-bounds
>>> access on the pointers and adds 64 bytes redzone around each of
>>> the two variables.
>>
>> Ouch.
>>
>>> gcc-6.3.1 happens to inline 16 calls of tty_insert_flip_char() into
>
> I wonder if we should stop marking tty_insert_flip_char() as inline.

That would be an easy solution, yes. tty_insert_flip_char() was
apparently meant to be optimized for the fast path to completely
avoid calling into another function, but that fast path got a bit more
complex with commit acc0f67f307f ("tty: Halve flip buffer
GFP_ATOMIC memory consumption").

If we move it out of line, the fast path optimization goes away and
we could just have a simple implementation like


int tty_insert_flip_char(struct tty_port *port, unsigned char ch, char flag)
{
        struct tty_buffer *tb = port->buf.tail;
        int flags = (flag == TTY_NORMAL) ? TTYB_NORMAL : 0;

        if (!__tty_buffer_request_room(port, 1, flags))
                return 0;

        if (~tb->flags & TTYB_NORMAL)
                *flag_buf_ptr(tb, tb->used) = flag;
        *char_buf_ptr(tb, tb->used++) = ch;

        return 1;
}

One rather simple change I found would actually avoid the warning
and would seem to actually give us better runtime behavior even
without KASAN:

diff --git a/include/linux/tty_flip.h b/include/linux/tty_flip.h
index c28dd523f96e..15d03a14ad0f 100644
--- a/include/linux/tty_flip.h
+++ b/include/linux/tty_flip.h
@@ -26,7 +26,7 @@ static inline int tty_insert_flip_char(struct tty_port *port,
                *char_buf_ptr(tb, tb->used++) = ch;
                return 1;
        }
-       return tty_insert_flip_string_flags(port, &ch, &flag, 1);
+       return tty_insert_flip_string_fixed_flag(port, &ch, flag, 1);
 }

 static inline int tty_insert_flip_string(struct tty_port *port,

This reduces the stack frame size for kbd_event() to 1256 bytes,
which is well within the limit, and it lets us keep the flag-less
buffers across a 'tb->used >= tb->size' condition. Calling
into tty_insert_flip_string_flags() today will allocate a flag buffer
if there isn't already one, even when it is not needed.

>> I'm however afraid we'd have to mark a lot of static functions that way,
>> depending on the aggressivity of gcc... I'd indeed really argue that gcc
>> should consider stack usage when inlining.
>>
>> static int f(int foo) {
>>         char c[256];
>>         g(c, foo);
>> }
>>
>> is really not something that I'd want to see the compiler to inline.
>
> Why would not we want it be inlined? What we do not want us several
> calls having _separate_ instances of 'c' generated on the stack, all
> inlined calls should share 'c'. And of course if we have f1, f2, and
> f3 with c1, c2, and c3, GCC should not blow up the stack inlining and
> allocating stack for all 3 of them beforehand.
>
> But this all seems to me issue that should be solved in toolchain, not
> trying to play whack-a-mole with kernel sources.

The problem for the Samuel's example is that

a) the "--param asan-stack=1" option in KASAN does blow up the
   stack, which is why the annotation is now called 'noinline_if_stackbloat'.

b) The toolchain cannot solve the problem, as most instances of the
   problem (unlike kbd_put_queue) force the inlining unless you build
   with the x86-specific CONFIG_OPTIMIZE_INLINING.

        Arnd
