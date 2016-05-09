From: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: NFSroot hangs with bad unlock balance in Linux next
Date: Mon, 9 May 2016 08:12:19 -0700
Message-ID: <20160509151219.GF5995@atomide.com>
References: <20160505220344.GE5995@atomide.com>
 <20160508141629.GF2694@ZenIV.linux.org.uk>
 <20160509073235.GI2694@ZenIV.linux.org.uk>
 <CANn89iK5H-SokYE1r+OO3sPmQ1vpGqYGbE4x1QLn44wdyvH0cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
To: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANn89iK5H-SokYE1r+OO3sPmQ1vpGqYGbE4x1QLn44wdyvH0cw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> [160509 07:16]:
> On Mon, May 9, 2016 at 12:32 AM, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org> wrote:
> > On Sun, May 08, 2016 at 03:16:29PM +0100, Al Viro wrote:
> >
> >> Very strange.  We grab that rwsem at the entry into nfs_call_unlink()
> >> and then either release it there and return or call nfs_do_call_unlink().
> >> Which arranges for eventual call of nfs_async_unlink_release() (via
> >> ->rpc_release); nfs_async_unlink_release() releases the rwsem.  Nobody else
> >> releases it (on the read side, that is).
> >>
> >> The only kinda-sorta possibility I see here is that the inode we are
> >> unlocking in that nfs_async_unlink_release() is not the one we'd locked
> >> in nfs_call_unlink() that has lead to it.  That really shouldn't happen,
> >> though...  Just to verify whether that's what we are hitting, could you
> >> try to reproduce that thing with the patch below on top of -next and see
> >> if it triggers any of those WARN_ON?

Thanks no warnings with that patch though.

> > D'oh...  Lockdep warnings are easy to trigger (and, AFAICS, bogus).
> > up_read/down_read in fs/nfs/unlink.c should be replaced with
> > up_read_non_owner/down_read_non_owner, lest the lockdep gets confused.
> > Hangs are different - I've no idea what's triggering those.  I've seen
> > something similar on that -next, but not on work.lookups.
> >
> > The joy of bisecting -next...  <a couple of hours later>
> > 9317bb69824ec8d078b0b786b6971aedb0af3d4f is the first bad commit
> > commit 9317bb69824ec8d078b0b786b6971aedb0af3d4f
> > Author: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> > Date:   Mon Apr 25 10:39:32 2016 -0700
> >
> >     net: SOCKWQ_ASYNC_NOSPACE optimizations
> >
> > Reverting changes to sk_set_bit/sk_clear_bit gets rid of the hangs.  Plain
> > revert gives a conflict, since there had been additional change in
> > "net: SOCKWQ_ASYNC_WAITDATA optimizations"; removing both fixed the hangs.
> >
> > Note that hangs appear without any fs/nfs/unlink.c modifications being
> > there.  When the hang happens it affects NFS traffic; ssh session still
> > works fine until it steps on a filesystem operation on NFS (i.e. you
> > can use builtins, access procfs, etc.)
> 
> Yeah, the issue was reported last week (
> http://www.spinics.net/lists/netdev/msg375777.html ),
> and I could not convince myself to add a new sock flag,  like
> SOCK_FASYNC_STICKY.
> 
> (Just in case NFS would ever call sock_fasync() with an empty
> fasync_list, and SOCK_FASYNC would be cleared again.

Yeah applying the test patch from the url above makes things work
for me again.

Regards,

Tony
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
