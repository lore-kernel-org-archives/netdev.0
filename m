From: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Date: Sun, 5 May 2013 11:18:44 +0200
Message-ID: <20130505091844.GC22239@gmail.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <1367615050-3894-2-git-send-email-ccross@android.com>
 <20130504130440.GC13770@amd.pavel.ucw.cz>
 <CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
 <20130504225715.GB24276@amd.pavel.ucw.cz>
 <CAMbhsRS_cF7kF-QZ9BMBUS3ytU0ukRCbC3D549HW_XOsQbEZhg@mail.gmail.com>
 <20130505000528.GA25454@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
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
Content-Disposition: inline
In-Reply-To: <20130505000528.GA25454-tWAi6jLit6GreWDznjuHag@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> wrote:

> Hi!
> 
> > >> >> --- a/kernel/exit.c
> > >> >> +++ b/kernel/exit.c
> > >> >> @@ -835,7 +835,7 @@ void do_exit(long code)
> > >> >>       /*
> > >> >>        * Make sure we are holding no locks:
> > >> >>        */
> > >> >> -     debug_check_no_locks_held(tsk);
> > >> >> +     debug_check_no_locks_held();
> > >> >
> > >> > Is task guaranteed == current?
> > >>
> > >> Yes, the first line of do_exit is:
> > >>         struct task_struct *tsk = current;
> > >
> > > Aha, I understand it now.
> > >
> > > Accessing current is slower than local variable. So your "new" code
> > > will work but will be slower. Please revert this part.
> > 
> > Using current instead of passing in tsk was done at Andrew Morton's
> > suggestion, and makes no difference from the freezer's perspective
> > since it would have to use current to get the task to pass in, so I'm
> > going to leave it as is.
> 
> Well, current is:
> 
> static inline struct thread_info *current_thread_info(void)
> {
>         register unsigned long sp asm ("sp");
>         return (struct thread_info *)(sp & ~(THREAD_SIZE - 1));
> }

That's the old 32-bit x86 trick to compute 'current' from the kernel stack 
pointer.

It can be done better - for example on platforms with optimized percpu 
variables (x86-64) it looks like this:

static inline struct thread_info *current_thread_info(void)
{
        struct thread_info *ti;
        ti = (void *)(this_cpu_read_stable(kernel_stack) +
                      KERNEL_STACK_OFFSET - THREAD_SIZE);
        return ti;
}

Which turns the computation of 'current' into a single instruction. For 
example, to access current->pid [which fields is at offset 0x2a4], we get:

    3ad0:       65 48 8b 04 25 00 00    mov    %gs:0x0,%rax
    3ad7:       00 00
    3ad9:       8b 80 a4 02 00 00       mov    0x2a4(%rax),%eax

I also agree with the removal of the 'tsk' parameter because the function 
itself internally assumes that tsk == current.

[ We could perhaps rename the function to 
  debug_check_no_locks_held_curr(), to make it clear it operates on the 
  current task. ]

Thanks,

	Ingo
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
