From: Andy Isaacson <adi@hexapodia.org>
Subject: [PATCH 1/2] factor duplicated code out of __show_regs into show_regs_common
Date: Tue, 8 Dec 2009 00:29:42 -0800
Message-ID: <20091208082942.GA27174@hexapodia.org>
References: <4B1DC4F0.9050708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Hancock <hancockrwd@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Richard Zidlicky <rz@linux-m68k.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from straum.hexapodia.org ([64.81.70.185]:11839 "EHLO
	straum.hexapodia.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbZLHI3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 03:29:36 -0500
Content-Disposition: inline
In-Reply-To: <4B1DC4F0.9050708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unify x86_32 and x86_64 implementations of __show_regs header,
standardizing on the x86_64 format string in the process.  Also,
32-bit will now call print_modules.

Signed-off-by: Andy Isaacson <adi@hexapodia.org>
---

I cast about for a good place to stick the show_regs_common prototype;
suggestions appreciated.

Compile-tested on 32-bit and 64-bit.

 arch/x86/include/asm/system.h |    1 +
 arch/x86/kernel/process.c     |   18 ++++++++++++++++++
 arch/x86/kernel/process_32.c  |   14 +-------------
 arch/x86/kernel/process_64.c  |   16 ++--------------
 4 files changed, 22 insertions(+), 27 deletions(-)

diff --git a/arch/x86/include/asm/system.h b/arch/x86/include/asm/system.h
index 022a843..ecb544e 100644
--- a/arch/x86/include/asm/system.h
+++ b/arch/x86/include/asm/system.h
@@ -23,6 +23,7 @@ struct task_struct *__switch_to(struct task_struct *prev,
 struct tss_struct;
 void __switch_to_xtra(struct task_struct *prev_p, struct task_struct *next_p,
 		      struct tss_struct *tss);
+extern void show_regs_common(void);
 
 #ifdef CONFIG_X86_32
 
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 744508e..a93f319 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -9,6 +9,8 @@
 #include <linux/pm.h>
 #include <linux/clockchips.h>
 #include <linux/random.h>
+#include <linux/dmi.h>
+#include <linux/utsname.h>
 #include <trace/events/power.h>
 #include <linux/hw_breakpoint.h>
 #include <asm/system.h>
@@ -89,6 +91,22 @@ void exit_thread(void)
 	}
 }
 
+void show_regs_common(void)
+{
+	const char *board;
+
+	board = dmi_get_system_info(DMI_PRODUCT_NAME);
+	if (!board)
+		board = "";
+
+	printk("\n");
+	printk(KERN_INFO "Pid: %d, comm: %.20s %s %s %.*s %s\n",
+		current->pid, current->comm, print_tainted(),
+		init_utsname()->release,
+		(int)strcspn(init_utsname()->version, " "),
+		init_utsname()->version, board);
+}
+
 void flush_thread(void)
 {
 	struct task_struct *tsk = current;
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 075580b..120b887 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -23,7 +23,6 @@
 #include <linux/vmalloc.h>
 #include <linux/user.h>
 #include <linux/interrupt.h>
-#include <linux/utsname.h>
 #include <linux/delay.h>
 #include <linux/reboot.h>
 #include <linux/init.h>
@@ -35,7 +34,6 @@
 #include <linux/tick.h>
 #include <linux/percpu.h>
 #include <linux/prctl.h>
-#include <linux/dmi.h>
 #include <linux/ftrace.h>
 #include <linux/uaccess.h>
 #include <linux/io.h>
@@ -128,7 +126,6 @@ void __show_regs(struct pt_regs *regs, int all)
 	unsigned long d0, d1, d2, d3, d6, d7;
 	unsigned long sp;
 	unsigned short ss, gs;
-	const char *board;
 
 	if (user_mode_vm(regs)) {
 		sp = regs->sp;
@@ -140,16 +137,7 @@ void __show_regs(struct pt_regs *regs, int all)
 		savesegment(gs, gs);
 	}
 
-	printk("\n");
-
-	board = dmi_get_system_info(DMI_PRODUCT_NAME);
-	if (!board)
-		board = "";
-	printk("Pid: %d, comm: %s %s (%s %.*s) %s\n",
-			task_pid_nr(current), current->comm,
-			print_tainted(), init_utsname()->release,
-			(int)strcspn(init_utsname()->version, " "),
-			init_utsname()->version, board);
+	show_regs_common();
 
 	printk("EIP: %04x:[<%08lx>] EFLAGS: %08lx CPU: %d\n",
 			(u16)regs->cs, regs->ip, regs->flags,
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index a98fe88..d0570b9 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -26,7 +26,6 @@
 #include <linux/slab.h>
 #include <linux/user.h>
 #include <linux/interrupt.h>
-#include <linux/utsname.h>
 #include <linux/delay.h>
 #include <linux/module.h>
 #include <linux/ptrace.h>
@@ -38,7 +37,6 @@
 #include <linux/uaccess.h>
 #include <linux/io.h>
 #include <linux/ftrace.h>
-#include <linux/dmi.h>
 
 #include <asm/pgtable.h>
 #include <asm/system.h>
@@ -163,18 +161,8 @@ void __show_regs(struct pt_regs *regs, int all)
 	unsigned long d0, d1, d2, d3, d6, d7;
 	unsigned int fsindex, gsindex;
 	unsigned int ds, cs, es;
-	const char *board;
-
-	printk("\n");
-	print_modules();
-	board = dmi_get_system_info(DMI_PRODUCT_NAME);
-	if (!board)
-		board = "";
-	printk(KERN_INFO "Pid: %d, comm: %.20s %s %s %.*s %s\n",
-		current->pid, current->comm, print_tainted(),
-		init_utsname()->release,
-		(int)strcspn(init_utsname()->version, " "),
-		init_utsname()->version, board);
+
+	show_regs_common();
 	printk(KERN_INFO "RIP: %04lx:[<%016lx>] ", regs->cs & 0xffff, regs->ip);
 	printk_address(regs->ip, 1);
 	printk(KERN_INFO "RSP: %04lx:%016lx  EFLAGS: %08lx\n", regs->ss,
-- 
1.6.5.3

