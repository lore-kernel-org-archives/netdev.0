From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register accessors
Date: Tue, 16 May 2017 17:11:58 +0200
Message-ID: <CAK8P3a0AqAqWA5FHThKVJtJhymOYZH8F9puR+xOg=xMgtfE4cQ@mail.gmail.com>
References: <20170515134711.2770374-1-arnd@arndb.de> <20170515142520.GA13996@redhat.com>
 <20170515.103951.2305484593464882104.davem@davemloft.net> <20170516115511.GA4230@redhat.com>
 <20170516142342.GA6086@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Daniel Golle <daniel-g5gK2j5usbvCyp4qypjU+w@public.gmane.org>,
        Mathias Kresin <dev-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        =?UTF-8?Q?Tomislav_Po=C5=BEega?= <pozega.tomislav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Serge Vasilugin <vasilugin-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org>,
        Roman Yeryomin <roman-9zmcapQ0v8Q@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170516142342.GA6086-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 4:23 PM, Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, May 16, 2017 at 01:55:17PM +0200, Stanislaw Gruszka wrote:
>> On Mon, May 15, 2017 at 10:39:51AM -0400, David Miller wrote:
>> > From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> > Date: Mon, 15 May 2017 16:28:01 +0200
>> >
>> > > On Mon, May 15, 2017 at 03:46:55PM +0200, Arnd Bergmann wrote:
>> > >> With CONFIG_KASAN enabled and gcc-7, we get a warning about rather high
>> > >> stack usage (with a private patch set I have to turn on this warning,
>> > >> which I intend to get into the next kernel release):
>> > >>
>> > >> wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_bw_filter_calibration':
>> > >> wireless/ralink/rt2x00/rt2800lib.c:7990:1: error: the frame size of 2144 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
>> > >>
>> > >> The problem is that KASAN inserts a redzone around each local variable that
>> > >> gets passed by reference, and the newly added function has a lot of them.
>> > >> We can easily avoid that here by changing the calling convention to have
>> > >> the output as the return value of the function. This should also results in
>> > >> smaller object code, saving around 4KB in .text with KASAN, or 2KB without
>> > >> KASAN.
>> > >>
>> > >> Fixes: 41977e86c984 ("rt2x00: add support for MT7620")
>> > >> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
>> > >> ---
>> > >>  drivers/net/wireless/ralink/rt2x00/rt2800lib.c | 319 +++++++++++++------------
>> > >>  1 file changed, 164 insertions(+), 155 deletions(-)
>> > >
>> > > We have read(, &val) calling convention since forever in rt2x00 and that
>> > > was never a problem. I dislike to change that now to make some tools
>> > > happy, I think problem should be fixed in the tools instead.
>> >
>> > Passing return values by reference is and always has been a really
>> > poor way to achieve what these functions are doing.
>> >
>> > And frankly, whilst the tool could see what's going on here better, we
>> > should be making code easier rather than more difficult to audit.
>> >
>> > I am therefore very much in favor of Arnd's change.
>> >
>> > This isn't even a situation where there are multiple return values,
>> > such as needing to signal an error and return an unsigned value at the
>> > same time.
>> >
>> > These functions return _one_ value, and therefore they should be
>> > returned as a true return value.
>>
>> In rt2x00 driver we use poor convention in other kind of registers
>> accessors like bbp, mac, eeprom. I dislike to changing only rfcsr
>> accessors and leaving others in the old way. And changing all accessors
>> would be massive and error prone change, which I'm not prefer either.
>>
>> Arnd, could this be fixed by refactoring rt2800_bw_filter_calibration()
>> function (which is enormous and definitely should be split into smaller
>> subroutines) ? If not, I would accept this patch.
>
> Does below patch make things better with KASAN compilation ?

Yes, that fixes the warning I got:

Before:

$ make -s EXTRA_CFLAGS=-Wframe-larger-than=500
/git/arm-soc/drivers/net/wireless/ralink/rt2x00/rt2800lib.c: In
function 'rt2800_bw_filter_calibration':
/git/arm-soc/drivers/net/wireless/ralink/rt2x00/rt2800lib.c:7990:1:
error: the frame size of 2144 bytes is larger than 500 bytes
[-Werror=frame-larger-than=]

$ size drivers/net/wireless/ralink/rt2x00/built-in.o    text   data
bss    dec    hex filename
 255979  39442   1536 296957  487fd
drivers/net/wireless/ralink/rt2x00/built-in.o

With your patch:

$ make -s EXTRA_CFLAGS=-Wframe-larger-than=500
/git/arm-soc/drivers/net/wireless/ralink/rt2x00/rt2800lib.c: In
function 'rt2800_bw_filter_calibration':
/git/arm-soc/drivers/net/wireless/ralink/rt2x00/rt2800lib.c:7956:1:
warning: the frame size of 576 bytes is larger than 300 bytes
[-Wframe-larger-than=]

$ size drivers/net/wireless/ralink/rt2x00/built-in.o
   text   data    bss    dec    hex filename
 254367  39538   1536 295441  48211
drivers/net/wireless/ralink/rt2x00/built-in.o

With my 300kb patch:
$ make -s EXTRA_CFLAGS=-Wframe-larger-than=300
$ size drivers/net/wireless/ralink/rt2x00/built-in.o
 237312  39442   1536 278290  43f12
drivers/net/wireless/ralink/rt2x00/built-in.o

I passed -Wframe-larger-than=500 here to see the actual stack consumption.
The 2144 bytes are definitely worrying, 576 bytes are generally harmless. My
larger patch improves stack consumption and code size further: it brings all
six functions that had >300 byte stacks below that, but it is not really needed
with your change.

      Arnd
