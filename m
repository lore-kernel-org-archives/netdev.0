From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Date: Sun, 5 May 2013 03:13:34 +0200
Message-ID: <20130505011334.GB25454@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <1367615050-3894-2-git-send-email-ccross@android.com>
 <20130504130440.GC13770@amd.pavel.ucw.cz>
 <CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
 <20130504225715.GB24276@amd.pavel.ucw.cz>
 <CAMbhsRS_cF7kF-QZ9BMBUS3ytU0ukRCbC3D549HW_XOsQbEZhg@mail.gmail.com>
 <20130505000528.GA25454@amd.pavel.ucw.cz>
 <CAMbhsRQso4fW_DVL6U3zfbX3YbLsTy8-rUA-fo61Aw93bU+sQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
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
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMbhsRQso4fW_DVL6U3zfbX3YbLsTy8-rUA-fo61Aw93bU+sQQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat 2013-05-04 17:23:01, Colin Cross wrote:
> On Sat, May 4, 2013 at 5:05 PM, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> wrote:
> > Hi!
> >
> >> >> >> --- a/kernel/exit.c
> >> >> >> +++ b/kernel/exit.c
> >> >> >> @@ -835,7 +835,7 @@ void do_exit(long code)
> >> >> >>       /*
> >> >> >>        * Make sure we are holding no locks:
> >> >> >>        */
> >> >> >> -     debug_check_no_locks_held(tsk);
> >> >> >> +     debug_check_no_locks_held();
> >> >> >
> >> >> > Is task guaranteed == current?
> >> >>
> >> >> Yes, the first line of do_exit is:
> >> >>         struct task_struct *tsk = current;
> >> >
> >> > Aha, I understand it now.
> >> >
> >> > Accessing current is slower than local variable. So your "new" code
> >> > will work but will be slower. Please revert this part.
> >>
> >> Using current instead of passing in tsk was done at Andrew Morton's
> >> suggestion, and makes no difference from the freezer's perspective
> >> since it would have to use current to get the task to pass in, so I'm
> >> going to leave it as is.
> >
> > Well, current is:
> >
> > static inline struct thread_info *current_thread_info(void)
> > {
> >         register unsigned long sp asm ("sp");
> >         return (struct thread_info *)(sp & ~(THREAD_SIZE - 1));
> > }
> >
> > #define get_current() (current_thread_info()->task)
> >
> > #define current get_current()
> >
> > Instead of passing computed value to debug_check_no_locks_held(), you
> > force it to be computed again. do_exit() performance matters for
> > configure scripts, etc.
> >
> > I'd say it makes sense to keep the optimalization. akpm can correct
> > me.
> 
> That translates to 3 instructions, with no memory accesses:
> c0008350:       e1a0300d        mov     r3, sp
> c0008354:       e3c32d7f        bic     r2, r3, #8128   ; 0x1fc0
> c0008358:       e3c2203f        bic     r2, r2, #63     ; 0x3f

On ARM, you are right. It seems to have memory access on s390 and
x86-64. Ok, it is probably going to be in cache, but...

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
