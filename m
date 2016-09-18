From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: skb_splice_bits() and large chunks in pipe (was Re:
 xfs_file_splice_read: possible circular locking dependency detected
Date: Sun, 18 Sep 2016 23:31:17 +0100
Message-ID: <20160918223117.GH2356@ZenIV.linux.org.uk>
References: <CA+55aFwHQMjO4-vtfB9-ytc=o+DRo-HXVGckvXLboUxgpwb7_g@mail.gmail.com>
 <20160909221945.GQ2356@ZenIV.linux.org.uk>
 <CA+55aFzTOOB6oEVaaGD0N7Uznk-W9+ULPwzsxS_L_oZqGVSeLA@mail.gmail.com>
 <20160914031648.GB2356@ZenIV.linux.org.uk>
 <CA+55aFznQaOWoSMNphgGJJWZ=8-odrc0DAUMzfGPQe+_N4UgNA@mail.gmail.com>
 <20160914042559.GC2356@ZenIV.linux.org.uk>
 <20160917082007.GA6489@ZenIV.linux.org.uk>
 <20160917190023.GA8039@ZenIV.linux.org.uk>
 <20160918193112.GF2356@ZenIV.linux.org.uk>
 <CA+55aFx5Y=Rddw3ObnOm-XSUkJezfxzNGuTckD2ChVmJRNsD2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <axboe@kernel.dk>, Nick Piggin <npiggin@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFx5Y=Rddw3ObnOm-XSUkJezfxzNGuTckD2ChVmJRNsD2g@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 18, 2016 at 01:12:21PM -0700, Linus Torvalds wrote:

> So if the splice code ends up being confused by "this is not just
> inside a single page", then the splice code is buggy, I think.
> 
> Why would splice_write() cases be confused anyway? A filesystem needs
> to be able to handle the case of "this needs to be split" regardless,
> since even if the source buffer were to fit in a page, the offset
> might obviously mean that the target won't fit in a page.

What worries me is iov_iter_get_pages() and friends.  The calling conventions
are
	size = iov_iter_get_pages(iter, pages, maxlen, maxpages, &start);

They are convenient enough for most of the callers - we fill an array of
pages, the first (and only in bvec case) one having start bytes skipped.

The thing is, the calculation of the number of pages returned is broken
in this case; normally it's ROUND_DIV_UP(start + n, PAGE_SIZE).  That,
of course, gets broken even by the offset being large enough.  We don't
have that many users of that thing (and iov_iter_get_pages_alloc()), but
it'll need careful review.  What's more, looking at those shows other
fun issues:
        sg_init_table(sgl->sg, npages + 1);

        for (i = 0, len = n; i < npages; i++) {
                int plen = min_t(int, len, PAGE_SIZE - off);

                sg_set_page(sgl->sg + i, sgl->pages[i], plen, off);

and that'll instantly blow up, due to PAGE_SIZE - off possibly becoming
negative.  That's af_alg_make_sg(), and it shouldn't see anything
coming from pipe buffers (right now the only way for that to happen is
iter_file_splice_write()), but the things like e.g. dio_refill_pages()
might, and they also get seriously confused by that.  Worse, some of those
callers have calling conventions that have similar problems of their own.

At the moment there are 11 callers (10 in mainline; one more added in
conversion of vmsplice_to_pipe() to new pipe locking, but it's irrelevant
anyway - it gets fed an iovec-backed iov_iter).  I'm looking through those
right now, hopefully will come up with something sane...
