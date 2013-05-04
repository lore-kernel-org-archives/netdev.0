From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Date: Sat, 4 May 2013 16:49:56 -0700
Message-ID: <CAMbhsRS_cF7kF-QZ9BMBUS3ytU0ukRCbC3D549HW_XOsQbEZhg@mail.gmail.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<1367615050-3894-2-git-send-email-ccross@android.com>
	<20130504130440.GC13770@amd.pavel.ucw.cz>
	<CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
	<20130504225715.GB24276@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
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
	Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ben Chan <benchan-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130504225715.GB24276-tWAi6jLit6GreWDznjuHag@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, May 4, 2013 at 3:57 PM, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> wrote:
> On Sat 2013-05-04 13:27:23, Colin Cross wrote:
>> On Sat, May 4, 2013 at 6:04 AM, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> wrote:
>> > On Fri 2013-05-03 14:04:10, Colin Cross wrote:
>> >> From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>> >>
>> >> We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
>> >> deadlock if the lock is later acquired in the suspend or hibernate path
>> >> (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
>> >> cgroup_freezer if a lock is held inside a frozen cgroup that is later
>> >> acquired by a process outside that group.
>> >
>> > Ok, but this does not explain why
>> >
>> >> --- a/include/linux/debug_locks.h
>> >> +++ b/include/linux/debug_locks.h
>> >> @@ -51,7 +51,7 @@ struct task_struct;
>> >>  extern void debug_show_all_locks(void);
>> >>  extern void debug_show_held_locks(struct task_struct *task);
>> >>  extern void debug_check_no_locks_freed(const void *from, unsigned long len);
>> >> -extern void debug_check_no_locks_held(struct task_struct *task);
>> >> +extern void debug_check_no_locks_held(void);
>> >>  #else
>> >>  static inline void debug_show_all_locks(void)
>> >>  {
>> >
>> > Removing task_struct argument from  those functions is good idea?
>>
>> This is an existing patch that was merged in 3.9 and then reverted
>> again, so it has already been reviewed and accepted once.
>
> Well, it was also reverted once :-).

It was reverted because of problems in NFS, not because of any problem
with this patch.

>> >> --- a/kernel/exit.c
>> >> +++ b/kernel/exit.c
>> >> @@ -835,7 +835,7 @@ void do_exit(long code)
>> >>       /*
>> >>        * Make sure we are holding no locks:
>> >>        */
>> >> -     debug_check_no_locks_held(tsk);
>> >> +     debug_check_no_locks_held();
>> >
>> > Is task guaranteed == current?
>>
>> Yes, the first line of do_exit is:
>>         struct task_struct *tsk = current;
>
> Aha, I understand it now.
>
> Accessing current is slower than local variable. So your "new" code
> will work but will be slower. Please revert this part.

Using current instead of passing in tsk was done at Andrew Morton's
suggestion, and makes no difference from the freezer's perspective
since it would have to use current to get the task to pass in, so I'm
going to leave it as is.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
