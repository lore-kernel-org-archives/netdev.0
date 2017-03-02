From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 24/26] ocfs2: reduce stack size with KASAN
Date: Thu, 02 Mar 2017 14:40:28 -0800
Message-ID: <1488494428.2179.23.camel@perches.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
         <20170302163834.2273519-25-arnd@arndb.de>
         <1488476770.2179.6.camel@perches.com>
         <CAK8P3a1gW9UqMKD2ijzxMH4rv1zAji0GUoz+bLY_oi0yvLU1cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kasan-dev <kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
        Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
        Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-build-reports-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAK8P3a1gW9UqMKD2ijzxMH4rv1zAji0GUoz+bLY_oi0yvLU1cw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-02 at 23:22 +0100, Arnd Bergmann wrote:
> On Thu, Mar 2, 2017 at 6:46 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> > On Thu, 2017-03-02 at 17:38 +0100, Arnd Bergmann wrote:
> > > The internal logging infrastructure in ocfs2 causes special warning code to be
> > > used with KASAN, which produces rather large stack frames:
> > > fs/ocfs2/super.c: In function 'ocfs2_fill_super':
> > > fs/ocfs2/super.c:1219:1: error: the frame size of 3264 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
> > 
> > At least by default it doesn't seem to.
> > 
> > gcc 6.2 allyesconfig, CONFIG_KASAN=y
> > with either CONFIG_KASAN_INLINE or CONFIG_KASAN_OUTLINE
> > 
> > gcc doesn't emit a stack warning
> 
> The warning is disabled until patch 26/26. which picks the 3072 default.
> The 3264 number was with gcc-7, which is worse than gcc-6 since it enables
> an extra check.
> 
> > > By simply passing the mask by value instead of reference, we can avoid the
> > > problem completely.
> > 
> > Any idea why that's so?
> 
> With KASAN, every time we inline the function, the compiler has to allocate
> space for another copy of the variable plus a redzone to detect whether
> passing it by reference into another function causes an overflow at runtime.

These logging functions aren't inlined.
You're referring to the stack frame?

> > >  On 64-bit architectures, this is also more efficient,
> > 
> > Efficient true, but the same overall stack no?
> 
> Here is what I see with CONFIG_FRAME_WARN=300 and x86_64-linux-gcc-6.3.1:
> 
> before:
[]
> fs/ocfs2/super.c:1219:1: error: the frame size of 552 bytes is larger
> than 300 bytes [-Werror=frame-larger-than=]
> 
> after:
> fs/ocfs2/super.c: In function 'ocfs2_fill_super':
> fs/ocfs2/super.c:1219:1: error: the frame size of 472 bytes is larger
> than 300 bytes [-Werror=frame-larger-than=]
> 
> and with gcc-7.0.1 (including -fsanitize-address-use-after-scope), before:
[]
> fs/ocfs2/super.c:1219:1: error: the frame size of 3264 bytes is larger
> than 300 bytes [-Werror=frame-larger-than=]
> 
> after:
> fs/ocfs2/super.c: In function 'ocfs2_fill_super':
> fs/ocfs2/super.c:1219:1: error: the frame size of 704 bytes is larger
> than 300 bytes [-Werror=frame-larger-than=]

Still doesn't make sense to me.

None of the logging functions are inlined as they are all
EXPORT_SYMBOL.

This just changes a pointer to a u64, which is the same
size on x86-64 (and is of course larger on x86-32).

Perhaps KASAN has the odd behavior and working around
KASAN's behavior may not be the proper thing to do.

Maybe if CONFIG_KASAN is set, the minimum stack should
be increased via THREAD_SIZE_ORDER or some such.
