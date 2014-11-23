From: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [fuse-devel] [PATCH 4/6] fs/fuse: support compiling out splice
Date: Sun, 23 Nov 2014 23:29:08 +0100
Message-ID: <CAFLxGvxq3Mr9n8xMO_fPZDhrGmBh=WKyU0+RF13JBdjssX6qfw@mail.gmail.com>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
	<1416752468-1626-5-git-send-email-pieter@boesman.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Bertrand Jacquin <beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?B?6JSh5q2j6b6Z?= <zhenglong.cai-TJRtMXcVgQTM1kAEIRd3EQ@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>,
	Peter Foley <pefoley2-lY0TAiDIAFlBDgjK7y7TUQ@public.gmane.org>,
	Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Xiao Guangrong <xiaoguangrong-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"open list:FUSE: FILESYSTEM..." <fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>,
	Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>,
	Catalina Mocanu
To: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1416752468-1626-5-git-send-email-pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 23, 2014 at 3:20 PM, Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org> wrote:
> To implement splice support, fs/fuse makes use of nosteal_pipe_buf_ops. This
> struct is exported by fs/splice. The goal of the larger patch set is to
> completely compile out fs/splice, so uses of the exported struct need to be
> compiled out along with fs/splice.
>
> This patch therefore compiles out splice support in fs/fuse when
> CONFIG_SYSCALL_SPLICE is undefined.
>
> Signed-off-by: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
> ---
>  fs/fuse/dev.c      | 4 ++--
>  include/linux/fs.h | 6 ++++++
>  2 files changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
> index ca88731..f8f92a4 100644
> --- a/fs/fuse/dev.c
> +++ b/fs/fuse/dev.c
> @@ -1291,7 +1291,7 @@ static ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
>         return fuse_dev_do_read(fc, file, &cs, iov_length(iov, nr_segs));
>  }
>
> -static ssize_t fuse_dev_splice_read(struct file *in, loff_t *ppos,
> +static ssize_t __maybe_unused fuse_dev_splice_read(struct file *in, loff_t *ppos,
>                                     struct pipe_inode_info *pipe,
>                                     size_t len, unsigned int flags)
>  {
> @@ -2144,7 +2144,7 @@ const struct file_operations fuse_dev_operations = {
>         .llseek         = no_llseek,
>         .read           = do_sync_read,
>         .aio_read       = fuse_dev_read,
> -       .splice_read    = fuse_dev_splice_read,
> +       .splice_read    = __splice_p(fuse_dev_splice_read),
>         .write          = do_sync_write,
>         .aio_write      = fuse_dev_write,
>         .splice_write   = fuse_dev_splice_write,
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index a957d43..04c0975 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2443,6 +2443,12 @@ extern int blkdev_fsync(struct file *filp, loff_t start, loff_t end,
>                         int datasync);
>  extern void block_sync_page(struct page *page);
>
> +#ifdef CONFIG_SYSCALL_SPLICE
> +#define __splice_p(x) x
> +#else
> +#define __splice_p(x) NULL
> +#endif
> +

This needs to go into a different patch.
One logical change per patch please. :-)

-- 
Thanks,
//richard
