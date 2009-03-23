From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: 2.6.29-rc8-git5: Reported regressions from 2.6.28
Date: Mon, 23 Mar 2009 08:57:38 +0800
Message-ID: <20090323005738.GB6003@localhost>
References: <GPBuLTara4J.A.3kH.TZTxJB@chimera> <20090321200534.GA30238@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Nick Piggin <npiggin@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090321200534.GA30238@elte.hu>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 22, 2009 at 04:05:34AM +0800, Ingo Molnar wrote:
> 
> * Rafael J. Wysocki <rjw@sisk.pl> wrote:
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12809
> > Subject		: iozone regression with 2.6.29-rc6
> > Submitter	: Lin Ming <ming.m.lin@intel.com>
> > Date		: 2009-02-27 9:13 (23 days old)
> > First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1cf6e7d83bf334cc5916137862c920a97aabc018
> > References	: http://marc.info/?l=linux-kernel&m=123572630504360&w=4
> > 		  http://lkml.org/lkml/2009/3/14/265
> > Handled-By	: Wu Fengguang <fengguang.wu@intel.com>
> 
> I think this was tracked back to the effective halving of 
> dirty_ratio by 1cf6e7d83 ("mm: task dirty accounting fix") and 
> doubling the ratio fixed the iozone regression.

Yes, exactly. The patch for fixing this regression is trivial.

However it may be better to revert 1cf6e7d83 for 2.6.29,
and merge 1cf6e7d83 together with this patch for 2.6.30-rc1.
This allows a larger window for testing out the possible impacts
on other workloads.
 
Thanks,
Fengguang
---
writeback: double the dirty thresholds

Enlarge default dirty ratios from 5/10 to 10/20.
This fixes [Bug #12809] iozone regression with 2.6.29-rc6.

The iozone benchmarks are performed on a 1200M file, with 8GB ram.

iozone -i 0 -i 1 -i 2 -i 3 -i 4 -r 4k -s 64k -s 512m -s 1200m -b tmp.xls
iozone -B -r 4k -s 64k -s 512m -s 1200m -b tmp.xls

The performance regression is triggered by commit 1cf6e7d83bf3(mm: task
dirty accounting fix), which makes more correct/thorough dirty accounting.

The default 5/10 dirty ratios were picked (a) with the old dirty
logic and (b) largely at random and (c) designed to be aggressive. In
particular, that (a) means that having fixed some of the dirty accounting,
maybe the real bug is now that it was always too aggressive, just hidden
by an accounting issue.

The enlarged 10/20 dirty ratios are just about enough to fix the regression.

Cc: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Reported-by: "Lin, Ming M" <ming.m.lin@intel.com>
Tested-by: "Lin, Ming M" <ming.m.lin@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- mm.orig/mm/page-writeback.c
+++ mm/mm/page-writeback.c
@@ -66,7 +66,7 @@ static inline long sync_writeback_pages(
 /*
  * Start background writeback (via pdflush) at this percentage
  */
-int dirty_background_ratio = 5;
+int dirty_background_ratio = 10;
 
 /*
  * dirty_background_bytes starts at 0 (disabled) so that it is a function of
@@ -83,7 +83,7 @@ int vm_highmem_is_dirtyable;
 /*
  * The generator of dirty data starts writeback at this percentage
  */
-int vm_dirty_ratio = 10;
+int vm_dirty_ratio = 20;
 
 /*
  * vm_dirty_bytes starts at 0 (disabled) so that it is a function of
