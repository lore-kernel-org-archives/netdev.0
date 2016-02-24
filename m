From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [Y2038] [PATCH 8/8] net: sunrpc: Replace CURRENT_TIME by current_fs_time()
Date: Wed, 24 Feb 2016 16:08:23 +0100
Message-ID: <3612929.btSLWR6eWu@wuerfel>
References: <1456154274-30487-1-git-send-email-deepa.kernel@gmail.com> <1456154274-30487-9-git-send-email-deepa.kernel@gmail.com> <CAHQdGtR26gqy7GzWui-bnb+W5W1PnUL_=okBZwz+XFmj_Q4A3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Deepa Dinamani <deepa.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Linux FS-devel Mailing List <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
To: y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHQdGtR26gqy7GzWui-bnb+W5W1PnUL_=okBZwz+XFmj_Q4A3A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 22 February 2016 10:34:31 Trond Myklebust wrote:
> > diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> > index 31789ef..bab3187 100644
> > --- a/net/sunrpc/rpc_pipe.c
> > +++ b/net/sunrpc/rpc_pipe.c
> > @@ -477,7 +477,9 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
> >                 return NULL;
> >         inode->i_ino = get_next_ino();
> >         inode->i_mode = mode;
> > -       inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
> > +       inode->i_atime = current_fs_time(sb);
> > +       inode->i_mtime = inode->i_atime;
> > +       inode->i_ctime = inode->i_atime;
> >         switch (mode & S_IFMT) {
> >         case S_IFDIR:
> >                 inode->i_fop = &simple_dir_operations;
> 
> Why would we care? This is a pseudo-fs. There is no expectation w.r.t.
> timestamp accuracy or resolution.

As Deepa said, the primary goal is to unify the interface, so we have only
one place function that handles setting the time in an inode, and we want
to avoid CURRENT_TIME, as that is currently used in a couple of places
for things other than inode timestamps that we don't want to convert to
64-bit times at the same time.

current_fs_time() has a very small overhead compared to CURRENT_TIME,
if you think it's worth avoiding that, we could introduce a
current_pseudo_fs_time() function that does not take a superblock
argument but is more tied to inode timestamps than CURRENT_TIME is.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
