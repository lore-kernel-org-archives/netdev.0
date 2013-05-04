From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Date: Sat, 4 May 2013 15:04:40 +0200
Message-ID: <20130504130440.GC13770@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <1367615050-3894-2-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
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
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367615050-3894-2-git-send-email-ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri 2013-05-03 14:04:10, Colin Cross wrote:
> From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> 
> We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
> deadlock if the lock is later acquired in the suspend or hibernate path
> (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
> cgroup_freezer if a lock is held inside a frozen cgroup that is later
> acquired by a process outside that group.

Ok, but this does not explain why

> --- a/include/linux/debug_locks.h
> +++ b/include/linux/debug_locks.h
> @@ -51,7 +51,7 @@ struct task_struct;
>  extern void debug_show_all_locks(void);
>  extern void debug_show_held_locks(struct task_struct *task);
>  extern void debug_check_no_locks_freed(const void *from, unsigned long len);
> -extern void debug_check_no_locks_held(struct task_struct *task);
> +extern void debug_check_no_locks_held(void);
>  #else
>  static inline void debug_show_all_locks(void)
>  {

Removing task_struct argument from  those functions is good idea?

> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -835,7 +835,7 @@ void do_exit(long code)
>  	/*
>  	 * Make sure we are holding no locks:
>  	 */
> -	debug_check_no_locks_held(tsk);
> +	debug_check_no_locks_held();

Is task guaranteed == current?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
