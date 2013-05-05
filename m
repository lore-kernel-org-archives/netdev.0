From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Date: Mon, 6 May 2013 00:12:34 +0200
Message-ID: <20130505221234.GA18470@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <20130505092318.GD22239@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Paul Walmsley <paul-DWxLp4Yu+b8AvxtiuMwx3w@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ben Chan <benchan-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130505092318.GD22239-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi!

> > NFS calls the freezable helpers with locks held, which is unsafe
> > and caused lockdep warnings when 6aa9707 "lockdep: check that no
> > locks held at freeze time" was applied (reverted in dbf520a).
> > Add new *_unsafe versions of the helpers that will not run the
> > lockdep test when 6aa9707 is reapplied, and call them from NFS.
> > 
> > Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
> > ---
> >  fs/nfs/inode.c          |  2 +-
> >  fs/nfs/nfs3proc.c       |  2 +-
> >  fs/nfs/nfs4proc.c       |  4 ++--
> >  include/linux/freezer.h | 42 +++++++++++++++++++++++++++++++++++++++++-
> >  net/sunrpc/sched.c      |  2 +-
> >  5 files changed, 46 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index 1f94167..53cbee5 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -79,7 +79,7 @@ int nfs_wait_bit_killable(void *word)
> >  {
> >  	if (fatal_signal_pending(current))
> >  		return -ERESTARTSYS;
> > -	freezable_schedule();
> > +	freezable_schedule_unsafe();
> 
> I'd suggest naming such variants _unkillable() instead of _unsafe().
> 
> There's nothing inherently 'unsafe' about it: the user asked for a hard 
> NFS mount and is getting it: with the side effect that it exposes the 
> machine to network delays in a 'hard' way as well. Which means suspend may 
> block indefinitely as well on network failure.

You only want to use _unsafe() variants when you enter refrigerator
with locks held.

And entering refrigerator with locks is tricky... and unsafe :-). It
is not directly related to killability.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
