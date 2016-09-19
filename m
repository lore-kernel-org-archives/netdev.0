From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: skb_splice_bits() and large chunks in pipe (was Re:
 xfs_file_splice_read: possible circular locking dependency detected
Date: Mon, 19 Sep 2016 01:22:59 +0100
Message-ID: <20160919002258.GJ2356@ZenIV.linux.org.uk>
References: <20160909221945.GQ2356@ZenIV.linux.org.uk>
 <CA+55aFzTOOB6oEVaaGD0N7Uznk-W9+ULPwzsxS_L_oZqGVSeLA@mail.gmail.com>
 <20160914031648.GB2356@ZenIV.linux.org.uk>
 <CA+55aFznQaOWoSMNphgGJJWZ=8-odrc0DAUMzfGPQe+_N4UgNA@mail.gmail.com>
 <20160914042559.GC2356@ZenIV.linux.org.uk>
 <20160917082007.GA6489@ZenIV.linux.org.uk>
 <20160917190023.GA8039@ZenIV.linux.org.uk>
 <20160918193112.GF2356@ZenIV.linux.org.uk>
 <CA+55aFx5Y=Rddw3ObnOm-XSUkJezfxzNGuTckD2ChVmJRNsD2g@mail.gmail.com>
 <20160918223117.GH2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Jens Axboe <axboe@kernel.dk>, Nick Piggin <npiggin@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60222 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932405AbcISAXC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 20:23:02 -0400
Content-Disposition: inline
In-Reply-To: <20160918223117.GH2356@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2016 at 11:31:17PM +0100, Al Viro wrote:

> At the moment there are 11 callers (10 in mainline; one more added in
> conversion of vmsplice_to_pipe() to new pipe locking, but it's irrelevant
> anyway - it gets fed an iovec-backed iov_iter).  I'm looking through those
> right now, hopefully will come up with something sane...

FWIW, I wonder how many of those users are ready to cope with compound
pages in the first place; they end up passed to
	* skb_fill_page_desc().  Probably OK (as in all of them, modulo
calculating the number of pages and ranges for them).
	* shoved into scatterlist, which gets passed to virtqueue_add_sgs().
Need to check virtio to see what happens there.
	* shoved into nfs ->wb_page and fed into nfs_pageio_add_request() and
machinery behind it.  These, BTW, are reachable by pipe_buffer-derived ones
at the moment (splice to O_DIRECT nfs file).  The code looks like it's
playing fast and loose with ->wb_page - in some cases it's an NFS pagecache
one, in some - anything from userland, and there are places like
	inode = page_file_mapping(req->wb_page)->host;
which will do nasty things if they are ever reached by the second kind.
nfs_pgio_rpcsetup() looks like it won't be happy with compound pages, but
again, I'm not familiar enough with that code to tell if it's reachable
from nfs_pageio_add_request().
	* shoved into scatterlist, which gets fed into crypto/*.c machinery.
No way for a pipe_buffer stuff to get there, fortunately, because I would
be very surprised if it works correctly with compound pages and large
ranges in those.
	* shoved into lustre ->ldp_pages; almost certainly not ready for
compound pages.
	* fed to ceph_osd_data_pages_init(); again, practically certain not
to be ready.
	* put into dio_submit ->pages[], eventually fed to bio_add_page();
that might be fixable, but it would take some massage in fs/direct-io.c
	* fuse - probably OK, but that's only on a fairly cursory look.

It certainly won't be easy to verify in details ;-/
