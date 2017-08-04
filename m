From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: Re: [PATCH v2 05/11] mtd: cfi: reduce stack size with KASAN
Date: Fri, 4 Aug 2017 12:56:54 +0200
Message-ID: <20170804125654.2d59e6d5@bbrezillon>
References: <20170614211556.2062728-1-arnd@arndb.de>
        <20170614211556.2062728-6-arnd@arndb.de>
        <20170804094254.369140c0@bbrezillon>
        <CAK8P3a2p6w_yx82SC796n6dqZwE1=s7Mad5TLqcdK=pJ0Uiy=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Marek Vasut <marek.vasut@gmail.com>,
        Richard Weinberger <richard@nod.at>,
        Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>,
        linux-mtd <linux-mtd@lists.infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a2p6w_yx82SC796n6dqZwE1=s7Mad5TLqcdK=pJ0Uiy=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Aug 2017 11:09:53 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Fri, Aug 4, 2017 at 9:42 AM, Boris Brezillon
> <boris.brezillon@free-electrons.com> wrote:
> > On Wed, 14 Jun 2017 23:15:40 +0200
> > Arnd Bergmann <arnd@arndb.de> wrote:
> >  
> >> When CONFIG_KASAN is used, we consume a lot of extra stack space:
> >>
> >> drivers/mtd/chips/cfi_cmdset_0020.c: In function 'do_write_buffer':
> >> drivers/mtd/chips/cfi_cmdset_0020.c:603:1: error: the frame size of 2184 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> >> drivers/mtd/chips/cfi_cmdset_0020.c: In function 'cfi_staa_erase_varsize':
> >> drivers/mtd/chips/cfi_cmdset_0020.c:972:1: error: the frame size of 1936 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> >> drivers/mtd/chips/cfi_cmdset_0001.c: In function 'do_write_buffer':
> >> drivers/mtd/chips/cfi_cmdset_0001.c:1841:1: error: the frame size of 1776 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> >>
> >> This marks some functions as noinline_if_stackbloat to keep reduce the
> >> overall stack size.
> >>
> >> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> >> ---
> >>  drivers/mtd/chips/cfi_cmdset_0020.c | 8 ++++----
> >>  include/linux/mtd/map.h             | 8 ++++----
> >>  2 files changed, 8 insertions(+), 8 deletions(-)
> >>
> >> diff --git a/drivers/mtd/chips/cfi_cmdset_0020.c b/drivers/mtd/chips/cfi_cmdset_0020.c
> >> index 7d342965f392..5eee5e883f55 100644
> >> --- a/drivers/mtd/chips/cfi_cmdset_0020.c
> >> +++ b/drivers/mtd/chips/cfi_cmdset_0020.c
> >> @@ -244,7 +244,7 @@ static struct mtd_info *cfi_staa_setup(struct map_info *map)
> >>  }
> >>
> >>
> >> -static inline int do_read_onechip(struct map_info *map, struct flchip *chip, loff_t adr, size_t len, u_char *buf)
> >> +static noinline_if_stackbloat int do_read_onechip(struct map_info *map, struct flchip *chip, loff_t adr, size_t len, u_char *buf)  
> >
> > Why do we even need to mark those functions inline in the first place?
> > Isn't the compiler smart enough to decide when it should inline things?  
> 
> I'm pretty sure it doesn't need the 'inline' keywork. I see that the code was
> addedlike this in linux-2.4.0-test3pre3 along with the rest of the mtd layer,
> so it has always been 'inline' and nobody ever bothered to remove that
> during later cleanups.
> 
> We could probably just mark this function as 'noinline' here and never
> inline it,
> but I would rather not add more than one variant of noinline_if_stackbloat:
> almost all other users of noinline_if_stackbloat are for functions that have
> to be inline in normal builds, so it is defined as being either
> 'inline' or 'noinline'
> depending on whether KASAN is active.

Okay. Let's keep it like that then.
