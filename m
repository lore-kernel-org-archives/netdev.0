From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH v3 13/16] futex: use freezable blocking call)
Date: Tue, 23 Jul 2013 23:43:21 +0200
Message-ID: <1374626689.YM8vFTr171@vostro.rjw.lan>
References: <1367884221-20462-1-git-send-email-ccross@android.com> <20130723200854.2046296b@xenia.leun.net> <CAMbhsRT6zOKLhG_uh=nA8H_3d7afhG+4jvWjvidY3fEguryP_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: Michael Leun <lkml20130126-yS7QfQBdiAdyjo5WHAzKoQ@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-nfs <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Darren Hart <dvhart-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMbhsRT6zOKLhG_uh=nA8H_3d7afhG+4jvWjvidY3fEguryP_Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday, July 23, 2013 11:29:57 AM Colin Cross wrote:
> On Tue, Jul 23, 2013 at 11:08 AM, Michael Leun
> <lkml20130126-yS7QfQBdiAdyjo5WHAzKoQ@public.gmane.org> wrote:
> > On Mon, 22 Jul 2013 16:55:58 -0700
> > Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
> >
> >> On Mon, Jul 22, 2013 at 4:02 PM, Michael Leun
> >> <lkml20130126-yS7QfQBdiAdyjo5WHAzKoQ@public.gmane.org> wrote:
> >> > On Mon,  6 May 2013 16:50:18 -0700
> >> > Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
> >> >
> >> >> Avoid waking up every thread sleeping in a futex_wait call during
> >> > [...]
> >> >
> >> > With 3.11-rc s2disk from suspend-utils stopped working: Frozen at
> >> > displaying 0% of saving image to disk.
> >> >
> >> > echo "1" >/sys/power/state still works.
> >> >
> >> > Bisecting yielded 88c8004fd3a5fdd2378069de86b90b21110d33a4,
> >> > reverting that from 3.11-rc2 makes s2disk working again.
> >> >
> >>
> >> I think the expanded use of the freezable_* helpers is exposing an
> >> existing bug in hibernation.  The SNAPSHOT_FREEZE ioctl calls
> >> freeze_processes(), which sets the global system_freezing_cnt and
> >> pm_freezing.  try_to_freeze_tasks then sends every process except
> >> current a signal which causes them all to end up in the refrigerator.
> >> The current task then returns back to userspace and continues its work
> >> to suspend to disk.  If that task ever hits a call to try_to_freeze()
> >> in the kernel, it will see system_freezing_cnt and pm_freezing=true
> >> and freeze, and suspend to disk will hang forever.  It could hit
> >> try_to_freeze() because of a signal delivered to the task, or from
> >> calling any syscall that uses a freezable_* helper like the one I
> >> added to sys_futex.
> >>
> >> I think the right solution is to add a flag to the freezing task that
> >> marks it unfreezable.  I  think PF_NOFREEZE would work, although it is
> >> normally used on kernel threads, can you see if the attached patch
> >> helps?
> >
> > That patch helps.
> >
> > BTW, the only machine I can reproduce this bug with is an i7-3630QM
> > notebook. Cannot reproduce on an Core Duo U1400 and cannot reproduce on
> > an i7 M 620.
> >
> > Are the sysreq backtraces still wanted? If so, any tip, how I could get
> > them saved?
> >
> >
> > --
> > MfG,
> >
> > Michael Leun
> >
> 
> Any chance that the failing machine has threads=y in the suspend.conf file?
> 
> Rafael, it appears that swsusp's suspend.c spawns new threads after
> calling the SNAPSHOT_FREEZE ioctl.  The PF_NOFREEZE (or the new flag)
> will get copied to those new threads, but nothing will clear the flag.
>  Should I just assume that the userspace suspend code will kill those
> threads before continuing with suspend?  Or maybe add a WARN_ON in the
> kernel if any threads besides current have the new flag set when the
> suspend ops that assume all of userspace is frozen are called?

Those threads should be killed by user space.  They are only spawned for
image saving/compression/encryption and should be waited for after that.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
