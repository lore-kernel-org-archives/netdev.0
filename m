From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET] printk: implement extended console support
Date: Wed, 29 Apr 2015 10:45:01 -0400
Message-ID: <1430318704-32374-1-git-send-email-tj@kernel.org>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: pmladek@suse.cz, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is v2 of printk extended console support.  v1 was part
of "printk, netconsole: implement reliable netconsole" patchset [1].
The biggest change is dropping of cont buffer handling as hinted by
Petr's hint.  This made it unnecessary to change LOG_NOCONS handling
and made the actual extended console support a lot simpler as now each
printk invocation always maps to a single log entry.

The kernel keeps quite a bit of metadata for each printk message in
its log buffer, all of which are accessible through /dev/kmsg;
however, when the messages are transmitted to consoles, a lot of
metadata is lost along with dictionary for structured logging.

Allowing consoles access to full log message information can be useful
for multiple reasons.  The consumer of the console output can identify
the orginating facility, make use of structured logging, determine
whether any message got lost if the medium isn't reliable and so on.
This will be further discussed in the netconsole patchset which will
follow soon.

Thanks to /dev/kmsg, printk already implements most of logic necessary
for extended console support.  The header is well defined and the
formatting code is already there.  The only possible complication is
handling of cont buffer.

This is dealt with by simply disabling in-kernel KERN_CONT
concatenation when extended consoles are registered.  This makes
message fragments consume more memory as each gets assigned a separate
log entry, but this greatly simplifies extended console support and
provided that /dev/kmsg and extended consumers perform trivial
concatenation directed by the <contflag> field, the end results are
the same.  In the long term, we might want to drop in-kernel
concatenation entirely.

Note that currently neither dmesg nor journald implements <contflag>
handling but this is trivial to add and this patchset doesn't change
the kernel behavior when no external console is registered.

This patchset contains the following three patches.

0001-printk-guard-the-amount-written-per-line-by-devkmsg_.patch
0002-printk-factor-out-message-formatting-from-devkmsg_re.patch
0003-printk-implement-support-for-extended-console-driver.patch

0001-0002 are straight-forward prep patches.  0003 implements the
extended console support.

The patches are also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-printk-ext-console

diffstat follows.  Thanks.

 include/linux/console.h |    1
 include/linux/printk.h  |    2
 kernel/printk/printk.c  |  213 ++++++++++++++++++++++++++++++++----------------
 3 files changed, 146 insertions(+), 70 deletions(-)

--
tejun

[1] http://lkml.kernel.org/g/1429225433-11946-1-git-send-email-tj@kernel.org
