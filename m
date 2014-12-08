From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 10:57:31 -0800
Message-ID: <CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
	<20141208164650.GB29028@node.dhcp.inet.fi>
	<20141208175805.GB22149@ZenIV.linux.org.uk>
	<20141208180824.GC22149@ZenIV.linux.org.uk>
	<CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
	<20141208182012.GE22149@ZenIV.linux.org.uk>
	<CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
	<20141208184632.GG22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141208184632.GG22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 8, 2014 at 10:46 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Mon, Dec 08, 2014 at 10:37:51AM -0800, Linus Torvalds wrote:
>
>> How about we make "kernel_read()" just clear O_DIRECT? Does that fix
>> it to just use copies?
>
> Umm...  clearing O_DIRECT on struct file that might have other references
> to it isn't nice, to put it mildly...

Yeah.

> Frankly, stopping iov_iter_get_pages() on the first page in vmalloc/module
> space looks like the sanest strategy anyway.  We'd get the same behaviour
> as we used to, and as for finit_module(2), well... put "fails if given
> an O_DIRECT descriptor" and be done with that.

If it used to fail, then by all means, just make this a failure in the
new model. I really don't want to make core infrastructure silently
just call vmalloc_to_page() to make things "work".

And if it used to do "get_user_pages_fast()" then the old code really
didn't work on vmalloc ranges anyway, since that one checks for not
just _PAGE_PRESENT but also _PAGE_USER, which won't be set on a
vmalloc() page. In fact, it should have failed on *all* kernel pages.

> Alternatively, we can really go for
>         page = is_vmalloc_or_module_addr(addr) ? vmalloc_to_page(addr)
>                                                 : virt_to_page(addr)
>         *pages++ = get_page(page);

actually, no we cannot. Thinking some more about it, that
"get_page(page)" is wrong in _all_ cases. It actually works better for
vmalloc pages than for normal 1:1 pages, since it's actually seriously
and *horrendously* wrong for the case of random kernel addresses which
may not even be refcounted to begin with.

So the whole "get_page()" thing is broken. Iterating over pages in a
KVEC is simply wrong, wrong, wrong. It needs to fail.

Iterating over a KVEC to *copy* data is ok. But no page lookup stuff
or page reference things.

The old code that apparently used "get_user_pages_fast()" was ok
almost by mistake, because it fails on all kernel pages.

                       Linus
