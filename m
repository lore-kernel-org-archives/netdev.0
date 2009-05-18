From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: 2.6.30-rc6: Reported regressions from 2.6.29
Date: Mon, 18 May 2009 17:45:50 +0200
Message-ID: <20090518154550.GB22133@redhat.com>
References: <_AjETDMbIoL.A.DcH.RYzDKB@chimera> <20090517073327.GC1583@elte.hu> <20090518145725.GB18607@redhat.com> <20090518151102.GA6241@elte.hu> <alpine.LFD.2.01.0905180819130.3301@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Jonathan Corbet <corbet@lwn.net>, Martin Bammer <mrb74@gmx.at>,
	Jeff Garzik <jgarzik@pobox.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0905180819130.3301@localhost.localdomain>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/18, Linus Torvalds wrote:
>
> On Mon, 18 May 2009, Ingo Molnar wrote:
> >
> > Btw., why did the patch (and the revert) make any difference to the
> > test? Timing differences look improbable.
>
> It's the change from
>
> 	!signal_group_exit(signal)
>
> to
>
> 	!sig_kernel_only(signr)
>
> and quite frankly, I still don't see the point.

Previously,

	!signal_group_exit(signal)

meant: we do not know what should we do, let's ignore this signal.
Unless the multithreaded init does exec, in this case we should
respect SIGKILL.

With the recent changes, sig_kernel_only() means: we already checked
we should handle SIGKILL/SIGSTOP when this signal was queued.

> The comment seems to be wrong too:
>
>     If SIGSTOP/SIGKILL originate from a descendant of container-init they are
>     never queued (i.e dropped in sig_ignored() in an earler patch).
>
>     If SIGSTOP/SIGKILL originate from parent namespace, the signal is queued
>     and container-init processes the signal.
>
> since the bug was that the SIGSTOP (from within the same container) was
> _not_ ignored like the comment says.

Yes, the changelog could be better because it ignores ptrace issues. But
this was discussed,

>From http://marc.info/?t=123222433100001

	Yes we should handle SIGSTOP fine if it sent from the parent namespace.

	Also. Currently it is possible to ptrace the global init, but even
	ptracer can't stop it (but ptrace_stop() works). With these patches
	ptracer can stop init.

	I forgot to mention this behaviour change, imho this side-effect
	is good.

So, at least this change is not "by accident".

Oleg.

