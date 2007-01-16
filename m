From: "Nate Diller" <nate.diller@gmail.com>
Subject: Re: [PATCH -mm 0/10][RFC] aio: make struct kiocb private
Date: Mon, 15 Jan 2007 20:25:15 -0800
Message-ID: <5c49b0ed0701152025t2e9fdd6cld36b077f36c78afe@mail.gmail.com>
References: <20070116015450.9764.37697.patchbomb.py@nate-64.agami.com>
	 <20070116032347.GA3697@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "Christoph Hellwig" <hch@infradead.org>,
	"Nate Diller" <nate@agami.com>,
	"Nate Diller" <nate.diller@gmail.com>,
	"Andrew Morton" <akpm@osdl.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Benjamin LaHaise" <bcrl@kvack.org>,
	"Alexander Viro" <viro@zeniv.linux.org.uk>,
	"Suparna Bhattacharya" <suparna@in.ibm.com>,
	"Kenneth W Chen" <kenneth.w.chen@intel.com>,
	"David Brownell" <dbrownell@users.sourceforge.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	linux-aio@kvack.org, xfs-masters@oss.sgi.com
In-Reply-To: <20070116032347.GA3697@infradead.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/15/07, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Jan 15, 2007 at 05:54:50PM -0800, Nate Diller wrote:
> > This series is an attempt to generalize the async I/O paths to be
> > implementation agnostic.  It completely eliminates knowledge of
> > the kiocb structure in the generic code and makes it private within the
> > current aio code.  Things get noticeably cleaner without that layering
> > violation.
> >
> > The new interface takes a file_endio_t function pointer, and a private data
> > pointer, which would normally be aio_complete and a kiocb pointer,
> > respectively.  If the aio submission function gets back EIOCBQUEUED, that is
> > a guarantee that the endio function will be called, or *already has been
> > called*.  If the file_endio_t pointer provided to aio_[read|write] is NULL,
> > the FS must block on I/O completion, then return either the number of bytes
> > read, or an error.
>
> I don't really like this patchet at all.  At some point it's a lot nicer
> to have a lot of paramaters that are related and passed down a long
> callchain into a structure, and I think the aio code is over that threshold.
> The completion function cleanups look okay to me, but I'd rather add
> that completion function to struct kiocb instead of removing kiocb use.
>
> I have this slight feeling you want to use this completions for something
> else than the current aio code, if that's the case it would help
> if you could explain briefly in what direction your heading.

Actually I agree with you more than you might think.  I had intended
this to mesh with your struct iodesc idea, where iodesc would contain
the iovec pointer, nr_segs, iov_length, and whatever else needs to be
there, potentially even the endio function and its private data, tying
those to the iovec instead of a separate structure that needs to be
kept in sync.  There's a distinct layering that should exist between
things that should accompany the iovec transparently, and private data
that should be attached opaquely by layers above.

The biggest thing I have in mind for this patch, actually, is to fix
up the *sync* paths.  I don't think we should be waiting on sync I/O
at the *top* of the call stack, like with wait_on_sync_kiocb(), I'd
say the best place to wait is at the *bottom*, down in the I/O
scheduler.  This would make it a lot easier to clean up the completion
paths, because in the sync case, you'd be right back in process
context again as you traverse upward through the RAID, encryption,
loopback, directIO, FS log commit, etc.  It doesn't by itself
eliminate the need for all the threads and workqueues and such that
those layers each own, but it is a step in the right direction.

Now if you want to talk about long-term vaporware style ideas, yeah, I
do have my own thoughts on how aio should work.  And from Agami's
perspective, this patch also makes it easier for us to do certain
debugging traces that we wish to hack together, in order to profile
performance on our platform.  But I'd be hesitant to make those
arguments, cause they are largely irrelevant (we can obviously carry
the patch for debugging without buy-in from the community).  This is
the right thing to do from a design perspective.  Hopefully it enables
a new architecture that can reduce context switches in I/O completion,
and reduce overhead.  That's the real motive ;)

NATE
