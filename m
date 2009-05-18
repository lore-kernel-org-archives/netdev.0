From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: 2.6.30-rc6: Reported regressions from 2.6.29
Date: Mon, 18 May 2009 17:31:15 +0200
Message-ID: <20090518153115.GA22133@redhat.com>
References: <_AjETDMbIoL.A.DcH.RYzDKB@chimera> <20090517073327.GC1583@elte.hu>
	<20090518145725.GB18607@redhat.com> <20090518151102.GA6241@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, DRI <dri-devel@lists.sourceforge.net>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Kumar Gala <galak@kernel.crashing.org>,
        Natalie Protasevich <protasnb@gmail.com>, Martin Bammer <mrb74@gmx.at>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Network Development <netdev@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Jeff Garzik <jgarzik@pobox.com>,
        Linux PM List <linux-pm@lists.linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20090518151102.GA6241@elte.hu>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 05/18, Ingo Molnar wrote:
>
> * Oleg Nesterov <oleg@redhat.com> wrote:
>
> > On 05/17, Ingo Molnar wrote:
> > >
> > > > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13107
> > > > Subject		: LTP 20080131 causes defunct processes w/2.6.30-rc1
> > > > Submitter	: Kumar Gala <galak@kernel.crashing.org>
> > > > Date		: 2009-04-09 15:43 (38 days old)
> > > > First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b3bfa0cba867f23365b81658b47efd906830879b
> > > > References	: http://marc.info/?l=linux-kernel&m=123929187208953&w=4
> > > > 		  http://lkml.org/lkml/2009/4/10/193
> > > > Handled-By	: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
> > >
> > > Oleg says in that thread that it's as-designed, and followup
> > > questions were not replied to (yet).
> >
> > Yes, I think this is false alarm. Perhaps I missed something, and
> > I am waiting for more info from Kumar, but it looks like ltp was
> > already changed to skip the "{ PTRACE_ATTACH, 1, EPERM }" test on
> > kernels after 2.6.25
>
> Btw., why did the patch (and the revert) make any difference to the
> test? Timing differences look improbable.

Because before this series /sbin/init always ignored SIGSTOP. Now,
ptracer does PTRACE_ATTACH and exits without clearing the pending
SIGSTOP. init dequeues this signal and becomes TASK_STOPPED.

Consider:

	$ sleep 1000 &
	[1] 875

	$ grep State: /proc/`pidof sleep`/status
	State:  S (sleeping)

	$ perl -e 'syscall 101, 16, 0+shift, 0,0' `pidof sleep`    # just PTRACE_ATTACH + exit

	[1]+  Stopped                 sleep 1000

	$ grep State: /proc/`pidof sleep`/status
	State:  T (stopped)

This is the "normal" behaviour, afaics the same happens with init now.

Oleg.
