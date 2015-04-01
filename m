From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 03:33:11 +0100
Message-ID: <20150401023311.GL29656@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <20141208175805.GB22149@ZenIV.linux.org.uk>
 <20141208180824.GC22149@ZenIV.linux.org.uk>
 <CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
 <20141208182012.GE22149@ZenIV.linux.org.uk>
 <CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
 <20141208184632.GG22149@ZenIV.linux.org.uk>
 <CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 10:57:31AM -0800, Linus Torvalds wrote:
> actually, no we cannot. Thinking some more about it, that
> "get_page(page)" is wrong in _all_ cases. It actually works better for
> vmalloc pages than for normal 1:1 pages, since it's actually seriously
> and *horrendously* wrong for the case of random kernel addresses which
> may not even be refcounted to begin with.
> 
> So the whole "get_page()" thing is broken. Iterating over pages in a
> KVEC is simply wrong, wrong, wrong. It needs to fail.
> 
> Iterating over a KVEC to *copy* data is ok. But no page lookup stuff
> or page reference things.

Hmm...  FWIW, for ITER_KVEC the underlying data would bloody better not
go away anyway - vmalloc space or not.  Protecting the object from being
freed under us is caller's responsibility and caller can guarantee that.
Would a variant that does kmap_to_page()/vmalloc_to_page() _without_
get_page() for ITER_KVEC work sanely?

Of course, that would have to be used with matching primitive for releasing
those suckers - page_cache_release() for ITER_IOVEC (and ITER_BVEC, while
we are at it - those are backed with normal pages) and nothing for ITER_KVEC
ones.

It would make life much more pleasant for fuse and zerocopy side of 9p - the
latter does pretty much that kind of thing anyway...

Comments?
			Al, digging himself from under a huge pile of mail...
