From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v3 02/16] freezer: add unsafe versions of freezable
 helpers for CIFS
Date: Tue, 7 May 2013 10:47:36 -0700
Message-ID: <CAMbhsRQ1i_dFctwjkqjg3=GJdEc8ReEDk=NnEFEXj8u3MaEqDA@mail.gmail.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<1367884221-20462-3-git-send-email-ccross@android.com>
	<20130507060730.03364687@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-nfs <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130507060730.03364687-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 7, 2013 at 3:07 AM, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon,  6 May 2013 16:50:07 -0700
> Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
>
>> CIFS calls wait_event_freezekillable_unsafe with a VFS lock held,
>> which is unsafe and will cause lockdep warnings when 6aa9707
>> "lockdep: check that no locks held at freeze time" is reapplied
>> (it was reverted in dbf520a).  CIFS shouldn't be doing this, but
>> it has long-running syscalls that must hold a lock but also
>> shouldn't block suspend.  Until CIFS freeze handling is rewritten
>> to use a signal to exit out of the critical section, add a new
>> wait_event_freezekillable_unsafe helper that will not run the
>> lockdep test when 6aa9707 is reapplied, and call it from CIFS.
>>
>> In practice the likley result of holding the lock while freezing
>> is that a second task blocked on the lock will never freeze,
>> aborting suspend, but it is possible to manufacture a case using
>> the cgroup freezer, the lock, and the suspend freezer to create
>> a deadlock.  Silencing the lockdep warning here will allow
>> problems to be found in other drivers that may have a more
>> serious deadlock risk, and prevent new problems from being added.
>>
>> Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
>> ---
>>  include/linux/freezer.h | 13 +++++++++++++
>>  1 file changed, 13 insertions(+)
>>
>> diff --git a/include/linux/freezer.h b/include/linux/freezer.h
>> index 5b31e21c..d3c038e 100644
>> --- a/include/linux/freezer.h
>> +++ b/include/linux/freezer.h
>> @@ -212,6 +212,16 @@ static inline bool freezer_should_skip(struct task_struct *p)
>>       __retval;                                                       \
>>  })
>>
>> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
>> +#define wait_event_freezekillable_unsafe(wq, condition)                      \
>> +({                                                                   \
>> +     int __retval;                                                   \
>> +     freezer_do_not_count();                                         \
>> +     __retval = wait_event_killable(wq, (condition));                \
>> +     freezer_count_unsafe();                                         \
>> +     __retval;                                                       \
>> +})
>> +
>>  #define wait_event_freezable(wq, condition)                          \
>>  ({                                                                   \
>>       int __retval;                                                   \
>> @@ -277,6 +287,9 @@ static inline void set_freezable(void) {}
>>  #define wait_event_freezekillable(wq, condition)             \
>>               wait_event_killable(wq, condition)
>>
>> +#define wait_event_freezekillable_unsafe(wq, condition)                      \
>> +             wait_event_killable(wq, condition)
>> +
>>  #endif /* !CONFIG_FREEZER */
>>
>>  #endif       /* FREEZER_H_INCLUDED */
>
> I think you also need to convert wait_for_response in the cifs code to
> use this helper. While it's a pretty straightforward change, you should
> probably cc linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org as well.
>
> --
> Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Oops, dropped a hunk which is why linux-cifs didn't get cc'd.  I will resend it.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
