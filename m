From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH v3 13/16] futex: use freezable blocking call)
Date: Tue, 23 Jul 2013 03:41:42 +0200
Message-ID: <15305281.aClQ8XUG9t@vostro.rjw.lan>
References: <1367884221-20462-1-git-send-email-ccross@android.com> <CA+55aFzUVPJe96z8V0F-znc8ZcpJid7LEeYww80M-Mx=S91tAA@mail.gmail.com> <CAMbhsRReF9xB597i9CcCj7D1P5kvB4cc0JmDQYeboqi11Kp99A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Michael Leun <lkml20130126-yS7QfQBdiAdyjo5WHAzKoQ@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-nfs <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Darren Hart <dvhart-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMbhsRReF9xB597i9CcCj7D1P5kvB4cc0JmDQYeboqi11Kp99A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday, July 22, 2013 05:42:49 PM Colin Cross wrote:
> On Mon, Jul 22, 2013 at 5:32 PM, Linus Torvalds
> <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > On Mon, Jul 22, 2013 at 4:55 PM, Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
> >>
> >> I think the right solution is to add a flag to the freezing task that
> >> marks it unfreezable.  I  think PF_NOFREEZE would work, although it is
> >> normally used on kernel threads, can you see if the attached patch
> >> helps?
> >
> > Hmm. That does seem to be the right thing to do, but I wonder about
> > the *other* callers of freeze_processes() IOW, kexec and friends.
> >
> > So maybe we should do this in {freeze|thaw}_processes() itself, and
> > just make the rule be that the caller of freeze_processes() itself is
> > obviously not frozen, and has to be the same one that then thaws
> > things?
> >
> > Colin? Rafael? Comments?
> >
> >                 Linus
> 
> I was worried about clearing the flag in thaw_processes().  If a
> kernel thread with PF_NOFREEZE set ever called thaw_processes(), which
> autosleep might do, it would clear the flag.  Or if a different thread
> called freeze_processes() and thaw_processes().

Is that legitimate?

> All the other callers besides the SNAPSHOT_FREEZE ioctl stay in the kernel
> between freeze_processes() and thaw_processes(), which makes the fanout of
> places that could call try_to_freeze() much more controllable.
> 
> Using a new flag that operates like PF_NOFREEZE but doesn't conflict
> with it, or a nofreeze_depth counter, would also work.

Well, that would be robust enough.  At least if the purpose of that new flag
is clearly specified, people hopefully won't be tempted to optimize it away in
the future.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
