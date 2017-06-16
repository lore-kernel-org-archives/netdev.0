From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 03/11] tty: kbd: reduce stack size with KASAN
Date: Fri, 16 Jun 2017 17:41:47 +0200
Message-ID: <CAK8P3a2upDpcxGCLomyjvsXHfyeTyPmSj9qvymSsgf4pE+spDg@mail.gmail.com>
References: <20170614211556.2062728-1-arnd@arndb.de> <20170614211556.2062728-4-arnd@arndb.de>
 <20170615045221.GA26687@kroah.com> <20170615045347.GA26913@kroah.com>
 <CAK8P3a32abgm7H7s=dOTkLus3K9o79hRJ31s0eyEVZW30E9p7g@mail.gmail.com> <20170616130215.GC31057@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170616130215.GC31057@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2017 at 3:02 PM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Fri, Jun 16, 2017 at 02:01:57PM +0200, Arnd Bergmann wrote:
>> On Thu, Jun 15, 2017 at 6:53 AM, Greg Kroah-Hartman
>> <gregkh@linuxfoundation.org> wrote:
>> > On Thu, Jun 15, 2017 at 06:52:21AM +0200, Greg Kroah-Hartman wrote:
>> >> On Wed, Jun 14, 2017 at 11:15:38PM +0200, Arnd Bergmann wrote:
>> >> > -static void put_queue(struct vc_data *vc, int ch)
>> >> > +static noinline_if_stackbloat void put_queue(struct vc_data *vc, int ch)
>> >> >  {
>> >> >     tty_insert_flip_char(&vc->port, ch, 0);
>> >> >     tty_schedule_flip(&vc->port);
>> >> >  }
>> >>
>> >> Ugh, really?  We have to start telling gcc not to be stupid here?
>> >> That's not going to be easy, and will just entail us doing this all over
>> >> the place, right?
>> >>
>> >> The code isn't asking to be inlined, so why is gcc allowing it to be
>> >> done that way?  Doesn't that imply gcc is the problem here?
>> >
>> > Wait, you are now, in this patch, _asking_ for it to be inlined.  How is
>> > that solving anything?
>>
>> The three functions that gain the attribute are all those that gcc decided
>> to inline for itself. Usually gcc makes reasonable inlining decisions, so
>> I left the existing behavior my marking them as 'inline' without
>> CONFIG_KASAN and 'noinline' when KASAN is enabled.
>
> But why should we have to care about this?  If gcc wanted to inline
> them, and it did so in a way that blows up the stack, that would be a
> gcc bug, right?  Why do I have to tell gcc "don't inline", when really,
> I never told it to inline it in the first place?

I don't think gcc takes stack size into account when making the inlining
decisions. Without the address sanitizer, inlining won't normally have
any negative effects on the overall stack size, and may even help save
a few bytes for the caller-saved registers.

You could argue that the gcc inlining algorithm is buggy in combination
with kasan, but what does that help you? In most instances of this
problem, we actually force the inlining (see the other patches in this
series), so making gcc smarter would not help much either.

>> Would you rather see this patch instead?
>>
>> diff --git a/include/linux/tty_flip.h b/include/linux/tty_flip.h
>> index c28dd523f96e..25348c5ffcb7 100644
>> --- a/include/linux/tty_flip.h
>> +++ b/include/linux/tty_flip.h
>> @@ -13,8 +13,8 @@ extern int tty_prepare_flip_string(struct tty_port *port,
>>  extern void tty_flip_buffer_push(struct tty_port *port);
>>  void tty_schedule_flip(struct tty_port *port);
>>
>> -static inline int tty_insert_flip_char(struct tty_port *port,
>> -                                       unsigned char ch, char flag)
>> +static noinline_if_stackbloat int
>> +tty_insert_flip_char(struct tty_port *port, unsigned char ch, char flag)
>>  {
>>         struct tty_buffer *tb = port->buf.tail;
>>         int change;
>>
>> This is just as good at eliminating the crazy stack usage in vt/keyboard.o,
>> but it will also impact all other users of that function.
>
> How is this function blowing up the stack?  We have 2 variables being
> added, that's it.  Are we really that low on stack that 2 words is too
> much?

The 'tb' and 'change' variables don't hurt here, they just get optimized
away. The problem are the 'ch' and 'flag' variables that are passed into
tty_insert_flip_char by value, and from there into
tty_insert_flip_string_flags by reference.  In this case, kasan tries
to detect whether tty_insert_flip_string_flags() does any out-of-bounds
access on the pointers and adds 64 bytes redzone around each of
the two variables.

gcc-6.3.1 happens to inline 16 calls of tty_insert_flip_char() into
kbd_keycode(), so the stack size grows from 168 bytes to
168+(16*2*64) = 2216 bytes. There are 10 calls to put_queue()
in to_utf8(), 12 in emulate_raw() and another 4 in kbd_keycode()
itself. On ARM64, it happens to decide differently and presumably
doesn't inline tty_insert_flip_char() and kbd_keycode() into
kbd_keycode(), so the maximum stack size isn't as bad, but
the problem still exists.

> And no, we shouldn't need to do this.  It sounds like ksan is the
> problem here...

Of course kasan is the problem, but it really just does whatever we
asked it to do, and cannot do any better as long as we inline many
copies of tty_insert_flip_char() into kbd_keycode().

       Arnd
