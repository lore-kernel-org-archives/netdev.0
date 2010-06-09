From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Tue, 8 Jun 2010 18:53:55 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: DRI <dri-devel@lists.sourceforge.net>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>,
        Maciej Rutecki <maciej.rutecki@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>, Carl Worth <cworth@cworth.org>,
        Eric Anholt <eric@anholt.net>, Venkatesh Pallipadi <venki@google.com>,
        Jens Axboe <jaxboe@fusionio.com>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera>
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



[ Added lots of cc's to direct specific people to look at the regressions =

  that may or may not be theirs... ]

On Wed, 9 Jun 2010, Rafael J. Wysocki wrote:
>
>  * Quite a few of the already reported regressions may be related to the =
bug
>    fixed by 386f40c86d6c8d5b717ef20620af1a750d0dacb4 (Revert "tty: fix a =
little
>    bug in scrup, vt.c"), so reporters please retest with this commit appl=
ied.]

>From a quick look, most of them look unrelated to that unfortunate bug. =

It's hard to tell for sure, of course (memory corruption can do pretty =

much anything), but I'm not seeing the 07200720.. pattern at least.

And some of them do seem to be bisected to likely culprits and/or have =

patches that are claimed to have fixed them.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16163
> Subject	: [2.6.35-rc1 Regression] i915: Commit cfecde causes VGA to stay =
off
> Submitter	: David John <davidjon@xenontk.org>
> Date		: 2010-06-02 12:52 (7 days old)
> Message-ID	: <4C065423.3000202@xenontk.org>
> References	: http://marc.info/?l=3Dlinux-kernel&m=3D127548313828613&w=3D2

That has a "reverting the commit fixes it", and a confirmation from Nick =

Bowler.

Eric, Carl: should I just revert that commit? Or do you have a fix?

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16145
> Subject	: Unable to boot after "ACPI: Don't let acpi_pad needlessly mark =
TSC unstable"
> Submitter	: Tom Gundersen <teg@jklm.no>
> Date		: 2010-06-07 13:11 (2 days old)
> Handled-By	: Venkatesh Pallipadi <venki@google.com>

Hmm. This does seem to be a properly bisected commit, but at the same time =

it looks from the bugzilla like it's just pure luck on that machine that =

the acpi_pad driver happened to mark TSC unstable - so while the commit =

bisected is the real one, it's not the "deeper reason" for the problem.

Venki, any updates?

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16129
> Subject	: BUG: using smp_processor_id() in preemptible [00000000] code: j=
bd2/sda2
> Submitter	: Jan Kreuzer <kontrollator@gmx.de>
> Date		: 2010-06-05 06:15 (4 days old)

This seems to have been introduced by

	commit 7cbaef9c83e58bbd4bdd534b09052b6c5ec457d5
	Author: Ingo Molnar <mingo@elte.hu>
	Date:   Sat Nov 8 17:05:38 2008 +0100

	    sched: optimize sched_clock() a bit
    =

	    sched_clock() uses cycles_2_ns() needlessly - which is an irq-disabling
	    variant of __cycles_2_ns().
    =

	    Most of the time sched_clock() is called with irqs disabled already.
	    The few places that call it with irqs enabled need to be updated.
    =

	    Signed-off-by: Ingo Molnar <mingo@elte.hu>

and this seems to be one of those calling cases that need to be updated.

Ingo? The call trace is:

	BUG: using smp_processor_id() in preemptible [00000000] code: jbd2/sda2-8/=
337
	caller is native_sched_clock+0x3c/0x68
	Pid: 337, comm: jbd2/sda2-8 Not tainted 2.6.35-rc1jan+ #4
	Call Trace:
	[<ffffffff812362c5>] debug_smp_processor_id+0xc9/0xe4
	[<ffffffff8101059d>] native_sched_clock+0x3c/0x68
	[<ffffffff8101043d>] sched_clock+0x9/0xd
	[<ffffffff81212d7a>] blk_rq_init+0x97/0xa3
	[<ffffffff81214d71>] get_request+0x1c4/0x2d0
	[<ffffffff81214ea6>] get_request_wait+0x29/0x1a6
	[<ffffffff81215537>] __make_request+0x338/0x45b
	[<ffffffff812147c2>] generic_make_request+0x2bb/0x330
	[<ffffffff81214909>] submit_bio+0xd2/0xef
	[<ffffffff811413cb>] submit_bh+0xf4/0x116
	[<ffffffff81144853>] block_write_full_page_endio+0x89/0x96
	[<ffffffff81144875>] block_write_full_page+0x15/0x17
	[<ffffffff8119b00a>] ext4_writepage+0x356/0x36b
	[<ffffffff810e1f91>] __writepage+0x1a/0x39
	[<ffffffff810e32a6>] write_cache_pages+0x20d/0x346
	[<ffffffff810e3406>] generic_writepages+0x27/0x29
	[<ffffffff811ca279>] journal_submit_data_buffers+0x110/0x17d
	[<ffffffff811ca986>] jbd2_journal_commit_transaction+0x4cb/0x156d
	[<ffffffff811d0cba>] kjournald2+0x147/0x37a

(from the bugzilla thing)

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16122
> Subject	: 2.6.35-rc1: WARNING at fs/fs-writeback.c:1142 __mark_inode_dirt=
y+0x103/0x170
> Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
> Date		: 2010-06-04 13:18 (5 days old)

Jens?

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16120
> Subject	: Oops: 0000 [#1] SMP, unable to handle kernel NULL pointer deref=
erence at (null)
> Submitter	: Alex Zhavnerchik <alex.vizor@gmail.com>
> Date		: 2010-06-04 09:25 (5 days old)
> Handled-By	: Eric Dumazet <eric.dumazet@gmail.com>

This one seems to have a patch in bugzilla.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16104
> Subject	: Radeon KMS does not start after merge of the new PM-Code
> Submitter	: Jan Kreuzer <kontrollator@gmx.de>
> Date		: 2010-06-02 07:47 (7 days old)

This one also has a patch in Bugzilla, I think Airlie is just waiting to =

calm down his queue and already removed the dependency on the temperature =

code. DaveA?

> Bug-Entry     : http://bugzilla.kernel.org/show_bug.cgi?id=3D16161
> Subject       : [2.6.35-rc1 regression] sysfs: cannot create duplicate fi=
lename ... XVR-600 related?
> Submitter     : Mikael Pettersson <mikpe@it.uu.se>
> Date          : 2010-06-01 19:57 (8 days old)
> Message-ID    : <19461.26166.427857.612983@pilspetsen.it.uu.se>
> References    : http://marc.info/?l=3Dlinux-kernel&m=3D127542227511925&w=
=3D2
>
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16090
> Subject	: sysfs: cannot create duplicate filename
> Submitter	: Tobias <devnull@plzk.org>
> Date		: 2010-06-01 15:59 (8 days old)
> Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>

These two look related. Both are related to that "slot" thing in sysfs =

PCI, but only one of them is marked as Jesse's. Jesse?

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16037
> Subject	: NULL Pointer dereference in __ir_input_register/budget_ci_attach
> Submitter	: Sean Finney <seanius@debian.org>
> Date		: 2010-05-23 19:52 (17 days old)

Perhaps related to commit 13c24497086418010bf4f76378bcae241d7f59cd?

David H=E4rdeman, Mauro Carvalho Chehab added to cc.

				Linus
