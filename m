From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 03/11] tty: kbd: reduce stack size with KASAN
Date: Fri, 16 Jun 2017 15:02:15 +0200
Message-ID: <20170616130215.GC31057@kroah.com>
References: <20170614211556.2062728-1-arnd@arndb.de>
 <20170614211556.2062728-4-arnd@arndb.de>
 <20170615045221.GA26687@kroah.com>
 <20170615045347.GA26913@kroah.com>
 <CAK8P3a32abgm7H7s=dOTkLus3K9o79hRJ31s0eyEVZW30E9p7g@mail.gmail.com>
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
        Jiri Slaby <jslaby@suse.com>,
        Samuel Thibault <samuel.thibault@ens-lyon.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAK8P3a32abgm7H7s=dOTkLus3K9o79hRJ31s0eyEVZW30E9p7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2017 at 02:01:57PM +0200, Arnd Bergmann wrote:
> On Thu, Jun 15, 2017 at 6:53 AM, Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
> > On Thu, Jun 15, 2017 at 06:52:21AM +0200, Greg Kroah-Hartman wrote:
> >> On Wed, Jun 14, 2017 at 11:15:38PM +0200, Arnd Bergmann wrote:
> >> > As reported by kernelci, some functions in the VT code use significant
> >> > amounts of kernel stack when local variables get inlined into the caller
> >> > multiple times:
> >> >
> >> > drivers/tty/vt/keyboard.c: In function 'kbd_keycode':
> >> > drivers/tty/vt/keyboard.c:1452:1: error: the frame size of 2240 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]
> >> >
> >> > Annotating those functions as noinline_if_stackbloat prevents the inlining
> >> > and reduces the overall stack usage in this driver.
> >> >
> >> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> >> > ---
> >> >  drivers/tty/vt/keyboard.c | 6 +++---
> >> >  1 file changed, 3 insertions(+), 3 deletions(-)
> >> >
> >> > diff --git a/drivers/tty/vt/keyboard.c b/drivers/tty/vt/keyboard.c
> >> > index f4166263bb3a..c0d111444a0e 100644
> >> > --- a/drivers/tty/vt/keyboard.c
> >> > +++ b/drivers/tty/vt/keyboard.c
> >> > @@ -301,13 +301,13 @@ int kbd_rate(struct kbd_repeat *rpt)
> >> >  /*
> >> >   * Helper Functions.
> >> >   */
> >> > -static void put_queue(struct vc_data *vc, int ch)
> >> > +static noinline_if_stackbloat void put_queue(struct vc_data *vc, int ch)
> >> >  {
> >> >     tty_insert_flip_char(&vc->port, ch, 0);
> >> >     tty_schedule_flip(&vc->port);
> >> >  }
> >>
> >> Ugh, really?  We have to start telling gcc not to be stupid here?
> >> That's not going to be easy, and will just entail us doing this all over
> >> the place, right?
> >>
> >> The code isn't asking to be inlined, so why is gcc allowing it to be
> >> done that way?  Doesn't that imply gcc is the problem here?
> >
> > Wait, you are now, in this patch, _asking_ for it to be inlined.  How is
> > that solving anything?
> 
> The three functions that gain the attribute are all those that gcc decided
> to inline for itself. Usually gcc makes reasonable inlining decisions, so
> I left the existing behavior my marking them as 'inline' without
> CONFIG_KASAN and 'noinline' when KASAN is enabled.

But why should we have to care about this?  If gcc wanted to inline
them, and it did so in a way that blows up the stack, that would be a
gcc bug, right?  Why do I have to tell gcc "don't inline", when really,
I never told it to inline it in the first place?

> Would you rather see this patch instead?
> 
> diff --git a/include/linux/tty_flip.h b/include/linux/tty_flip.h
> index c28dd523f96e..25348c5ffcb7 100644
> --- a/include/linux/tty_flip.h
> +++ b/include/linux/tty_flip.h
> @@ -13,8 +13,8 @@ extern int tty_prepare_flip_string(struct tty_port *port,
>  extern void tty_flip_buffer_push(struct tty_port *port);
>  void tty_schedule_flip(struct tty_port *port);
> 
> -static inline int tty_insert_flip_char(struct tty_port *port,
> -                                       unsigned char ch, char flag)
> +static noinline_if_stackbloat int
> +tty_insert_flip_char(struct tty_port *port, unsigned char ch, char flag)
>  {
>         struct tty_buffer *tb = port->buf.tail;
>         int change;
> 
> This is just as good at eliminating the crazy stack usage in vt/keyboard.o,
> but it will also impact all other users of that function.

How is this function blowing up the stack?  We have 2 variables being
added, that's it.  Are we really that low on stack that 2 words is too
much?

And no, we shouldn't need to do this.  It sounds like ksan is the
problem here...

thanks,

greg k-h
