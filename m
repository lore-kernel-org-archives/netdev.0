From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: [PATCH v2 03/11] tty: kbd: reduce stack size with KASAN
Date: Thu, 15 Jun 2017 00:16:44 +0200
Message-ID: <20170614221644.sws7xgm5cgiia6oo@var.youpi.perso.aquilenet.fr>
References: <20170614211556.2062728-1-arnd@arndb.de>
 <20170614211556.2062728-4-arnd@arndb.de>
 <20170614212834.mtmq3wlnq525qkiz@var.youpi.perso.aquilenet.fr>
 <CAK8P3a0aOmof7bW0Pp=o8nVdQYsQxff9kdYaqkEhrfj-oEPy4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAK8P3a0aOmof7bW0Pp=o8nVdQYsQxff9kdYaqkEhrfj-oEPy4A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann, on mer. 14 juin 2017 23:56:39 +0200, wrote:
> > I however agree that it's a bad idea to inline it in functions where
> > it's called so many times (and we're talking about the keyboard anyway).
> >
> >> -static void puts_queue(struct vc_data *vc, char *cp)
> >> +static noinline_if_stackbloat void puts_queue(struct vc_data *vc, char *cp)
> >
> > I don't see why, it's only called once in the callers. k_fn, however, is
> > called several times in k_pad, so that could be why, but then it's
> > rather be the inlining of k_fn which is a bad idea.
> 
> It's called by applkey, which in turn is called by k_pad(),

k_pad calls applkey twice only. Is that really to be considered bloat?

> >> -static void fn_send_intr(struct vc_data *vc)
> >> +static noinline_if_stackbloat void fn_send_intr(struct vc_data *vc)
> >
> > This one is only referenced, not called, I don't see how that could pose
> > problem.
> 
> I was surprised by this as well, but it seems that gcc these days is
> smart enough to turn the indirect function calls for k_handler[type]
> and/or f_handler[value] into inlines again when it has already
> determined the index to be constant.

Cool :) But I don't see how it can see find it out constant. The only
fn_handler[] caller is k_spec, using value as index. The only caller of
f_handler[] is kbd_keycode, using type as index, and keysym&0xff as
value.  That is definitely not constant :)  And it's only one caller, I
don't see how that can bloat.

Samuel
