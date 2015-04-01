From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 14:57:12 -0700
Message-ID: <CA+55aFwZ44R1wv32TxnLwA5ZoZLCD6AOooOJHDUTmSPu0nBpXA@mail.gmail.com>
References: <CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
	<20141208182012.GE22149@ZenIV.linux.org.uk>
	<CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
	<20141208184632.GG22149@ZenIV.linux.org.uk>
	<CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
	<20150401023311.GL29656@ZenIV.linux.org.uk>
	<CA+55aFx0XbzyPJ8zYkSauhTAPVgkqTW5EubaZhg=QgOGHRGkpw@mail.gmail.com>
	<20150401180801.GA889@ZenIV.linux.org.uk>
	<CA+55aFyOZ5LD-mAOb_OafJe-VMy0hxrgOCB5hJ=GXJAFP7e8dQ@mail.gmail.com>
	<CA+55aFxVVoZTGwibiNE9AtjPZ41ODQcNBKkQEepV5fiG=QsKfg@mail.gmail.com>
	<20150401201538.GD889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150401201538.GD889@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 1, 2015 at 1:15 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> Umm...  Tangentially related question - do we have any IO codepaths where
> a pointer to page might stick around indefinitely?

Well, the one obvious case is "splice()", where things might sit
around forever in the pipe buffer. But that is fairly explicit, and
splice does have the "release" callback to notify you when it finally
does drop.

For something like regular read/write (or, aio_read with waiting for
completion), I don't see how anybody could really ever keep a
reference around to after the completion unless it has some odd
RCU-like freeing.

And for regular vmalloc'ed pages, I actually think that the page
refcounting *should* work fine. I'd still prefer to never see code
that doesn't directly own the area do it, because I could certainly
_imagine_ people playing games with  vmap_page_range() (eg doing
things like mapping in partial hugepages or something odd like that).

Put another way: I think that it's fine if somebody does "vmalloc()"
and then does "vmalloc_to_page()" to look up the pages it just
allocated.

I'm *not* nearly as happy with code that does

   if (is_vmalloc(addr)) vmalloc_to_page()

because that basically says "I don't know what this allocation is, but
if somebody plays around in vmalloc space, I'll just look up the
pages".

And yeah, it probably works fine. It just makes me really really
nervous. We use that vmalloc space for some mmio mappings too, don't
we? Worry9ing about things like that just make me go "auugh".

                        Linus
