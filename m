From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 20:23:31 +0100
Message-ID: <20150401192331.GB889@ZenIV.linux.org.uk>
References: <20141208180824.GC22149@ZenIV.linux.org.uk>
 <CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
 <20141208182012.GE22149@ZenIV.linux.org.uk>
 <CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
 <20141208184632.GG22149@ZenIV.linux.org.uk>
 <CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
 <20150401023311.GL29656@ZenIV.linux.org.uk>
 <CA+55aFx0XbzyPJ8zYkSauhTAPVgkqTW5EubaZhg=QgOGHRGkpw@mail.gmail.com>
 <20150401180801.GA889@ZenIV.linux.org.uk>
 <CA+55aFyP4C_x-SPLZZbJaSp6=_nJ01rVp1ABYg0kg_Boi4BfMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyP4C_x-SPLZZbJaSp6=_nJ01rVp1ABYg0kg_Boi4BfMQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 01, 2015 at 11:15:17AM -0700, Linus Torvalds wrote:
> Seriously.
> 
> If y9ou want an sg-table, how the hell do you know that some user
> won't be doing "get_page()" etc on the resulting pages?
> 
> Answer: you don't.  If you pass this off to networking or whatever,
> and it does some zero-copy thing, it may well be playing games with
> the 'struct page'. After all, that's why it exists in the first place.
> 
> So no. You *MUST*NOT* turn random vmalloc space (or non-vmalloc space,
> for that matter) kernel mappings into struct page arrays. It's wrong.
> It's fundamentally invalid crap.

For non-vmalloc space you've just described sg_set_buf() (and sg_init_one(),
which is a wrapper for it)...

> If there are specific cases where it is valid, those specific cases
> need to be special-cased.
> 
> NO WAY IN HELL do we add generic support for doing shit. Really. If p9
> does crazy crap, that is not an excuse to extend the crazy crap to
> more code.

OK...  The scenario you've described might actually be a real bug in
net/p9 - I'm not familiar enough with virtio to tell.  AFAICS, all it
wants with them is sg_phys() + length, which would be safe, but I could
easily be missing something...

Oh, well - virtio is already in somewhat incestous relationship with
iov_iter.  I wonder if an analogue of virtqueue_add_sgs() that would
take iov_iter would be the right approach long-term...

Anyway, for now I'll just switch p9_client_{read,write}() to saner
calling conventions and let it look into iov_iter internals in that one
place (p9_get_mapped_pages()).  For IOVEC_ITER case we can use
iov_iter_get_pages() there, for ITER_BVEC - pick the page from
iter->bvec->bv_page, for ITER_KVEC - take the first element of iter->kvec
and do that vmalloc_to_page()/virt_to_page() thing.

It's no worse than what we do right now, doesn't introduce new primitives
that would invite abuse and it allows to make things much simpler for
the rest of net/9p and for fs/9p...
