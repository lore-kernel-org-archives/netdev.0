From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: [PATCH v2 03/11] tty: kbd: reduce stack size with KASAN
Date: Wed, 14 Jun 2017 23:28:34 +0200
Message-ID: <20170614212834.mtmq3wlnq525qkiz@var.youpi.perso.aquilenet.fr>
References: <20170614211556.2062728-1-arnd@arndb.de>
 <20170614211556.2062728-4-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170614211556.2062728-4-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Arnd Bergmann, on mer. 14 juin 2017 23:15:38 +0200, wrote:
> As reported by kernelci, some functions in the VT code use significant
> amounts of kernel stack when local variables get inlined into the caller
> multiple times:
> 
> drivers/tty/vt/keyboard.c: In function 'kbd_keycode':
> drivers/tty/vt/keyboard.c:1452:1: error: the frame size of 2240 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]
> 
> Annotating those functions as noinline_if_stackbloat prevents the inlining
> and reduces the overall stack usage in this driver.


> --- a/drivers/tty/vt/keyboard.c
> +++ b/drivers/tty/vt/keyboard.c
> @@ -301,13 +301,13 @@ int kbd_rate(struct kbd_repeat *rpt)
>  /*
>   * Helper Functions.
>   */
> -static void put_queue(struct vc_data *vc, int ch)
> +static noinline_if_stackbloat void put_queue(struct vc_data *vc, int ch)
>  {
>  	tty_insert_flip_char(&vc->port, ch, 0);
>  	tty_schedule_flip(&vc->port);
>  }

I'm surprised that this be able generate so much stack use: the
tty_insert_flip_char inline only uses a pointer and an int.

And I'm surprised that multiple inlines can accumulate stack usage.

I however agree that it's a bad idea to inline it in functions where
it's called so many times (and we're talking about the keyboard anyway).

> -static void puts_queue(struct vc_data *vc, char *cp)
> +static noinline_if_stackbloat void puts_queue(struct vc_data *vc, char *cp)

I don't see why, it's only called once in the callers. k_fn, however, is
called several times in k_pad, so that could be why, but then it's
rather be the inlining of k_fn which is a bad idea.

> -static void fn_send_intr(struct vc_data *vc)
> +static noinline_if_stackbloat void fn_send_intr(struct vc_data *vc)

This one is only referenced, not called, I don't see how that could pose
problem.

Samuel
