From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 4/11] use ether_addr_equal_64bits
Date: Mon, 6 Jan 2014 10:24:51 +0100
Message-ID: <CAMuHMdXZQO7jj+V2mMyyLgDoz6iSLJ25+55Yow-Acb1=tE5sMg@mail.gmail.com>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
	<1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>
	<1388429761.4410.1.camel@jlt4.sipsolutions.net>
	<alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>
	<1388438724.4573.2.camel@jlt4.sipsolutions.net>
	<20131230215701.GA4938@khazad-dum.debian.net>
	<1388445188.18164.0.camel@jlt4.sipsolutions.net>
	<CANUX_P0PX1g8uHJUHYoB4UyMMgbtLas0_pf4TYrLTgND5V37rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANUX_P0PX1g8uHJUHYoB4UyMMgbtLas0_pf4TYrLTgND5V37rg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 31, 2013 at 7:26 AM, Emmanuel Grumbach <egrumbach@gmail.com> wrote:
> On Tue, Dec 31, 2013 at 1:13 AM, Johannes Berg
> <johannes@sipsolutions.net> wrote:
>>
>> On Mon, 2013-12-30 at 19:57 -0200, Henrique de Moraes Holschuh wrote:
>> > On Mon, 30 Dec 2013, Johannes Berg wrote:
>> > > On Mon, 2013-12-30 at 20:58 +0100, Julia Lawall wrote:
>> > > > > Is there any way we could catch (sparse, or some other script?) that
>> > > > > struct reorganising won't break the condition needed ("within a
>> > > > > structure that contains at least two more bytes")?
>> > > >
>> > > > What kind of reorganizing could happen?  Do you mean that the programmer
>> > > > might do at some time in the future, or something the compiler might do?
>> > >
>> > > I'm just thinking of a programmer, e.g. changing a struct like this:
>> > >
>> > >  struct foo {
>> > >    u8 addr[ETH_ALEN];
>> > > -  u16 dummy;
>> > >  };
>> > >
>> > > for example.
>> >
>> > That is easily resolved by:
>> >
>> > struct foo {
>> >       u8 addr[ETH_ALEN];
>> >       u16 required_padding;   /* do not remove upon pain of death */
>> > };

Adding the u16 also changes the alignment of the whole struct. So it may
cost one additional byte _in front of_ the struct.

<asking-stupid-question-see-answer-below>
While you're at it, why not just making a new 64-bit aligned type for
Ethernet addresses, so it'll also work for
!CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS?
</asking-stupid-question-see-answer-below>

>> That'd be a stupid waste of struct space. If anything, there should be
>> *only* a comment saying that at least two bytes are needed - I'd still
>> prefer an automated check.
>
> Frankly I am not sure I like the patch. This flow is not a fast path

I also don't like it. To me this sounds like wasting space for nothing.
BTW, would it be that more expensive to always do a 32+16 bit
comparison?

> at all. While I don't really care for the waste in iwlwifi (because
> there isn't), I don't see the real point is make the code more
> sensitive to changes to earn basically nothing.

Thanks to this discussion, my eye fell on:

static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
{
        const u16 *a = (const u16 *) addr1;
        const u16 *b = (const u16 *) addr2;

        BUILD_BUG_ON(ETH_ALEN != 6);
        return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
}

What if addr1 or addr2 are odd, and this is running on an architecture that
doesn't support unaligned accesses at all?? Have we been lucky forever?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
