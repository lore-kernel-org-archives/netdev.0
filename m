From: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 02/16] freezer: add unsafe versions of freezable
 helpers for CIFS
Date: Tue, 7 May 2013 14:11:26 -0400
Message-ID: <20130507141126.199956b2@tlielax.poochiereds.net>
References: <CAMbhsRQ1i_dFctwjkqjg3=GJdEc8ReEDk=NnEFEXj8u3MaEqDA@mail.gmail.com>
	<1367949125-21809-1-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1367949125-21809-1-git-send-email-ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue,  7 May 2013 10:52:05 -0700
Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:

> CIFS calls wait_event_freezekillable_unsafe with a VFS lock held,
> which is unsafe and will cause lockdep warnings when 6aa9707
> "lockdep: check that no locks held at freeze time" is reapplied
> (it was reverted in dbf520a).  CIFS shouldn't be doing this, but
> it has long-running syscalls that must hold a lock but also
> shouldn't block suspend.  Until CIFS freeze handling is rewritten
> to use a signal to exit out of the critical section, add a new
> wait_event_freezekillable_unsafe helper that will not run the
> lockdep test when 6aa9707 is reapplied, and call it from CIFS.
> 
> In practice the likley result of holding the lock while freezing
> is that a second task blocked on the lock will never freeze,
> aborting suspend, but it is possible to manufacture a case using
> the cgroup freezer, the lock, and the suspend freezer to create
> a deadlock.  Silencing the lockdep warning here will allow
> problems to be found in other drivers that may have a more
> serious deadlock risk, and prevent new problems from being added.
> 
> Acked-by: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
> Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
> ---
> v4:
>   Corrected to include CIFS wait_for_response hunk.
>   The rest of this series is still at v3.
> 
>  fs/cifs/transport.c     |  2 +-
>  include/linux/freezer.h | 13 +++++++++++++
>  2 files changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/cifs/transport.c b/fs/cifs/transport.c
> index 1a52868..e7f22f8 100644
> --- a/fs/cifs/transport.c
> +++ b/fs/cifs/transport.c
> @@ -452,7 +452,7 @@ wait_for_response(struct TCP_Server_Info *server, struct mid_q_entry *midQ)
>  {
>  	int error;
>  
> -	error = wait_event_freezekillable(server->response_q,
> +	error = wait_event_freezekillable_unsafe(server->response_q,
>  				    midQ->mid_state != MID_REQUEST_SUBMITTED);
>  	if (error < 0)
>  		return -ERESTARTSYS;
> diff --git a/include/linux/freezer.h b/include/linux/freezer.h
> index 5b31e21c..d3c038e 100644
> --- a/include/linux/freezer.h
> +++ b/include/linux/freezer.h
> @@ -212,6 +212,16 @@ static inline bool freezer_should_skip(struct task_struct *p)
>  	__retval;							\
>  })
>  
> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
> +#define wait_event_freezekillable_unsafe(wq, condition)			\
> +({									\
> +	int __retval;							\
> +	freezer_do_not_count();						\
> +	__retval = wait_event_killable(wq, (condition));		\
> +	freezer_count_unsafe();						\
> +	__retval;							\
> +})
> +
>  #define wait_event_freezable(wq, condition)				\
>  ({									\
>  	int __retval;							\
> @@ -277,6 +287,9 @@ static inline void set_freezable(void) {}
>  #define wait_event_freezekillable(wq, condition)		\
>  		wait_event_killable(wq, condition)
>  
> +#define wait_event_freezekillable_unsafe(wq, condition)			\
> +		wait_event_killable(wq, condition)
> +
>  #endif /* !CONFIG_FREEZER */
>  
>  #endif	/* FREEZER_H_INCLUDED */

Looks fine...

Reviewed-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
