From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Tue, 29 Nov 2011 13:04:14 -0500
Message-ID: <20111129180414.GA11459@phenom.dumpdata.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
	<20111122135412.GA29905@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
	Florian Mickler <florian@mickler.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>, tglx@linutronix.de, mingo@redhat.com,
	hpa@zytor.com, x86@kernel.org, borislav.petkov@amd.com
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111122135412.GA29905@phenom.dumpdata.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2011 at 08:54:12AM -0500, Konrad Rzeszutek Wilk wrote:
> > Subject    : Regression in 3.1 causes Xen to use wrong idle routine
> > Submitter  : Stefan Bader <stefan.bader@canonical.com>
> > Date       : 2011-10-26 10:24
> > Message-ID : 4EA7DFD1.9060608@canonical.com
> > References : http://marc.info/?l=linux-acpi&m=131962467924564&w=2
> 
> The patch mentioned in http://mid.gmane.org/20111115144004.GE22675@phenom.dumpdata.com 
> should do it. But the patch needs an Ack from ACPI/x86 folks.

This patch (mentioned in the URL above) fixes the issue. Could it be
applied to the x86 tree for 3.2 or get an Ack, please?

>From 4f10ec7a7b9ff24657696aa98f25bcecde247373 Mon Sep 17 00:00:00 2001
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Mon, 21 Nov 2011 18:02:02 -0500
Subject: [PATCH] xen/pm_idle: Make pm_idle be default_idle under Xen.

This patch:

commit d91ee5863b71e8c90eaf6035bff3078a85e2e7b5
Author: Len Brown <len.brown@intel.com>
Date:   Fri Apr 1 18:28:35 2011 -0400

    cpuidle: replace xen access to x86 pm_idle and default_idle

    ..scribble on pm_idle and access default_idle,
   have it simply disable_cpuidle() so acpi_idle will not load and
   architecture default HLT will be used.

idea was to have one call - disable_cpuidle() which would make
pm_idle not be molested by other code. It disallows cpuidle_idle_call
and acpi_idle_call to not set pm_idle (which is excellent). But the
amd_e400_idle and mwait_idle can still setup pm_idle which we really
do not want. In case of mwait_idle we can hit some instances where:

Brought up 2 CPUs
invalid opcode: 0000 [#1] SMP
CPU 1
Modules linked in:

Pid: 0, comm: swapper Not tainted 3.1.0-0.rc6.git0.3.fc16.x86_64 #1
RIP: e030:[<ffffffff81015d1d>]  [<ffffffff81015d1d>] mwait_idle+0x6f/0xb4
RSP: e02b:ffff8801d28ddf10  EFLAGS: 00010082
RAX: ffff8801d28dc010 RBX: ffff8801d28ddfd8 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000001
RBP: ffff8801d28ddf10 R08: 0000000000000000 R09: 0000000000000001
R10: 0000000000000001 R11: ffff8801d28ddfd8 R12: ffffffff81b590d0
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8801dff81000(0000) knlGS:0000000000000000
CS:  e033 DS: 002b ES: 002b CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001a05000 CR4: 0000000000002660
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000000
Process swapper (pid: 0, threadinfo ffff8801d28dc000, task ffff8801d28cae60)
Stack:
 ffff8801d28ddf40 ffffffff8100e2ed ffff8801dff8e390 c136dfe72feab515
 0000000000000000 0000000000000000 ffff8801d28ddf50 ffffffff8149ee78
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8100e2ed>] cpu_idle+0xae/0xe8
 [<ffffffff8149ee78>] cpu_bringup_and_idle+0xe/0x10
RIP  [<ffffffff81015d1d>] mwait_idle+0x6f/0xb4
 RSP <ffff8801d28ddf10>

RH BZ #739499 and Ubuntu #881076

In case of amd_e400_idle we don't get so spectacular crashes, but
we do end up making an MSR which is trapped in the hypervisor,
and then follow it up with a yield hypercall. Meaning we end up
going to hypervisor twice instead of just once.

Lets make pm_idle be default_idle to take care of that.

Reported-by: Stefan Bader <stefan.bader@canonical.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 arch/x86/include/asm/system.h |    1 +
 arch/x86/kernel/process.c     |    8 ++++++++
 arch/x86/xen/setup.c          |    2 +-
 3 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/system.h b/arch/x86/include/asm/system.h
index c2ff2a1..2d2f01c 100644
--- a/arch/x86/include/asm/system.h
+++ b/arch/x86/include/asm/system.h
@@ -401,6 +401,7 @@ extern unsigned long arch_align_stack(unsigned long sp);
 extern void free_init_pages(char *what, unsigned long begin, unsigned long end);
 
 void default_idle(void);
+bool set_pm_idle_to_default(void);
 
 void stop_this_cpu(void *dummy);
 
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 1f7f8c8..336b299 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -404,6 +404,14 @@ void default_idle(void)
 EXPORT_SYMBOL(default_idle);
 #endif
 
+bool set_pm_idle_to_default()
+{
+	if (!pm_idle) {
+		pm_idle = default_idle;
+		return true;
+	}
+	return false;
+}
 void stop_this_cpu(void *dummy)
 {
 	local_irq_disable();
diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 46d6d21..7506181 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -448,6 +448,6 @@ void __init xen_arch_setup(void)
 #endif
 	disable_cpuidle();
 	boot_option_idle_override = IDLE_HALT;
-
+	WARN_ON(!set_pm_idle_to_default());
 	fiddle_vdso();
 }
-- 
1.7.7.3
