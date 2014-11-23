From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [fuse-devel] [PATCH 4/6] fs/fuse: support compiling out splice
Date: Sun, 23 Nov 2014 15:23:02 -0800
Message-ID: <20141123232302.GA12456@thin>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
 <1416752468-1626-5-git-send-email-pieter@boesman.nl>
 <CAFLxGvxq3Mr9n8xMO_fPZDhrGmBh=WKyU0+RF13JBdjssX6qfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pieter Smith <pieter@boesman.nl>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Bertrand Jacquin <beber@meleeweb.net>,
	Oleg Nesterov <oleg@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Eric Dumazet <edumazet@google.com>,
	=?utf-8?B?6JSh5q2j6b6Z?= <zhenglong.cai@cs2c.com.cn>,
	Jeff Layton <jlayton@poochiereds.net>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Peter Foley <pefoley2@pefoley.com>,
	Hugh Dickins <hughd@google.com>,
	Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Mel Gorman <mgorman@suse.de>, Matt Turner <mattst88@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"open list:FUSE: FILESYSTEM..." <fuse-devel@lists.sourceforge.net>,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Catalina Mocanu <cat
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAFLxGvxq3Mr9n8xMO_fPZDhrGmBh=WKyU0+RF13JBdjssX6qfw@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 23, 2014 at 11:29:08PM +0100, Richard Weinberger wrote:
> On Sun, Nov 23, 2014 at 3:20 PM, Pieter Smith <pieter@boesman.nl> wrote:
> > To implement splice support, fs/fuse makes use of nosteal_pipe_buf_ops. This
> > struct is exported by fs/splice. The goal of the larger patch set is to
> > completely compile out fs/splice, so uses of the exported struct need to be
> > compiled out along with fs/splice.
> >
> > This patch therefore compiles out splice support in fs/fuse when
> > CONFIG_SYSCALL_SPLICE is undefined.
> >
> > Signed-off-by: Pieter Smith <pieter@boesman.nl>
> > ---
> >  fs/fuse/dev.c      | 4 ++--
> >  include/linux/fs.h | 6 ++++++
> >  2 files changed, 8 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
> > index ca88731..f8f92a4 100644
> > --- a/fs/fuse/dev.c
> > +++ b/fs/fuse/dev.c
> > @@ -1291,7 +1291,7 @@ static ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
> >         return fuse_dev_do_read(fc, file, &cs, iov_length(iov, nr_segs));
> >  }
> >
> > -static ssize_t fuse_dev_splice_read(struct file *in, loff_t *ppos,
> > +static ssize_t __maybe_unused fuse_dev_splice_read(struct file *in, loff_t *ppos,
> >                                     struct pipe_inode_info *pipe,
> >                                     size_t len, unsigned int flags)
> >  {
> > @@ -2144,7 +2144,7 @@ const struct file_operations fuse_dev_operations = {
> >         .llseek         = no_llseek,
> >         .read           = do_sync_read,
> >         .aio_read       = fuse_dev_read,
> > -       .splice_read    = fuse_dev_splice_read,
> > +       .splice_read    = __splice_p(fuse_dev_splice_read),
> >         .write          = do_sync_write,
> >         .aio_write      = fuse_dev_write,
> >         .splice_write   = fuse_dev_splice_write,
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index a957d43..04c0975 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -2443,6 +2443,12 @@ extern int blkdev_fsync(struct file *filp, loff_t start, loff_t end,
> >                         int datasync);
> >  extern void block_sync_page(struct page *page);
> >
> > +#ifdef CONFIG_SYSCALL_SPLICE
> > +#define __splice_p(x) x
> > +#else
> > +#define __splice_p(x) NULL
> > +#endif
> > +
> 
> This needs to go into a different patch.
> One logical change per patch please. :-)

Easy enough to merge this one into the patch introducing
CONFIG_SYSCALL_SPLICE, then.

- Josh Triplett
