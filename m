From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 20:50:22 +0100
Message-ID: <20150401195022.GC889@ZenIV.linux.org.uk>
References: <20141208180824.GC22149@ZenIV.linux.org.uk>
 <CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
 <20141208182012.GE22149@ZenIV.linux.org.uk>
 <CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
 <20141208184632.GG22149@ZenIV.linux.org.uk>
 <CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
 <20150401023311.GL29656@ZenIV.linux.org.uk>
 <CA+55aFx0XbzyPJ8zYkSauhTAPVgkqTW5EubaZhg=QgOGHRGkpw@mail.gmail.com>
 <20150401180801.GA889@ZenIV.linux.org.uk>
 <CA+55aFyOZ5LD-mAOb_OafJe-VMy0hxrgOCB5hJ=GXJAFP7e8dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyOZ5LD-mAOb_OafJe-VMy0hxrgOCB5hJ=GXJAFP7e8dQ@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 01, 2015 at 11:26:38AM -0700, Linus Torvalds wrote:
> On Wed, Apr 1, 2015 at 11:08 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > IOW, do you have a problem with obtaining a pointer to kernel page and
> > immediately shoving it into scatterlist?
> 
> And just to clarify, yes I do. Why the f*ck wasn't it a struct page to
> begin with? And why do you think that a scatter-list is somehow "safe"
> and guarantees people won't be playing (invalid and completely broken)
> games with page counters etc that you cannot play for those things?

Point taken.  What do you think about sg_set_buf() and sg_init_one()?

> If this is just about finit_module(), then dammit, why the f*ck does
> it even try to do zero-copy in the first place?

Mostly because there's no way to tell the filesystem that we don't want
zero-copy deep in the bowels of underlying driver...

> But if that's the only
> use, maybe we can improve on kernel_read() to do some aio-read on the
> raw pages instead. And change the "info->hdr" thing to not just do a
> blind vmalloc, but actually do the page allocations and then do
> vmap_page_range() to map in the end result after IO etc.

Can do, but that would depend on 9p getting converted to read_iter/write_iter
in a sane way ;-) (and that's worth doing for a lot of other reasons, which
is what had brought me to net/9p in the first place).

That might actually be a good idea - for ITER_BVEC we know that page is
a normal one (not many originators of such - __swap_writepage() and
pipe_buffer ones), so making iov_iter_get_pages() work for those wouldn't
be a problem...

kernel_read() is a wrong helper, though - it should just use vfs_read_iter().
We are -><- that close to making it work on all "normal files" - the only
exceptions right now are ncpfs (fixed in local tree), coda (ditto) and 9p.

> IOW, it's fine to do IO on 'struct page', but it should be
> *controlled* and you damn well need to _own_ that struct page and its
> lifetime, no just "look up random struct page from some kernel
> address".

I certainly agree that throwing pointers to weird pages around is generally
a bad idea, but lifetime is not an issue, AFAICS - if somebody manages to do
vfree() the destination of your read right under you, you are already very
deep in trouble.

Speaking of weird pages, some of vmalloc_to_page() users look very strange -
netlink_mmap(), in particular...
