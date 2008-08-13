From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- revert for 2.6.26-rc1 failed
Date: Wed, 13 Aug 2008 08:41:01 -0700 (PDT)
Message-ID: <737832.54450.qm@web82101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82101.mail.mud.yahoo.com ([209.191.84.214]:31934 "HELO
	web82101.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750877AbYHMPlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 11:41:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Yinghai, please note that I did not request a patch to revert the
problem commit.  I was merely experimenting -- on my own time, so
you folks would not have to bother -- to see if I could make it
work.  I should have made that more clear!  Having said that, I am
glad to test changes of any kind on my machine:  reverts, code for
debugging or info, experiments, etc.]


I have two agendas here:

1.  A selfish interest in seeing future kernels work properly on
my "server" machines.  (I did not request a revert because I'm 
not yet convinced that the commit which introduced the problem
was broken.  That commit certainly is NOT broken on 1 of my 3
machines, and on none of your machines.  It may just expose
breakage elsewhere.)

2.  To provide a patch for Debian against the 2.6.26 line, in case
they get flooded with bug reports when their next stable release
happens.  (Such a flood is unlikely since no one here has the same
problem, and the users of Debian unstable haven't filed similar bug
reports in the last 2 weeks.  But, just in case...)


Pursuing #2 above, my first experiment was to attempt a revert for
2.6.26-rc1.  The files involved are much more similar to those in 
the problem commit, so performing the revert was much easier than
what I tried with 2.6.27-rc3.  I hoped to inch my way forward from
2.6.26-rc1 to 2.6.26, and end up with a patch useful for the Debian
Kernel Team.

Assuming I didn't botch the revert -- and I successfully carried
out this revert yesterday using the git version where the lockup
first occured -- it looks like there were enough changes between
Feb. 22 and May 3 that the simple, naive sort of revert that I
can do already cannot work.  The kernel freezes at boot, in spite
of the changes.


I will continue to try to work on identifying the first commit for
which my naive revert process will not work.  If I play a game 
where revertible = "good" and nonrevertible = "bad", I can use 
'git bisect' to locate the place where it no longer works.  I 
already have a "good" (3def3d6d...) and a "bad" (v2.6.26-rc1) by 
those rules.

If this process succeeds, it could provide evidence about why
reverting in 2.6.27 is not working.


====== DETAILS ==================

$ git show
commit 2ddcca36c8bcfa251724fe342c8327451988be0d
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sat May 3 11:59:44 2008 -0700

    Linux 2.6.26-rc1

diff --git a/Makefile b/Makefile
index 5cf8258..4492984 100644
--- a/Makefile
+++ b/Makefile
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 6
-SUBLEVEL = 25
-EXTRAVERSION =
+SUBLEVEL = 26
+EXTRAVERSION = -rc1
 NAME = Funky Weasel is Jiggy wit it
 
 # *DOCUMENTATION*

$ git diff
diff --git a/arch/x86/kernel/e820_64.c b/arch/x86/kernel/e820_64.c
index 124480c..e168fa0 100644
--- a/arch/x86/kernel/e820_64.c
+++ b/arch/x86/kernel/e820_64.c
@@ -325,7 +325,8 @@ unsigned long __init e820_end_of_ram(void)
 /*
  * Mark e820 reserved areas as busy for the resource manager.
  */
-void __init e820_reserve_resources(void)
+void __init e820_reserve_resources(struct resource *code_resource,
+        struct resource *data_resource, struct resource *bss_resource)
 {
     int i;
     struct resource *res;
@@ -341,7 +342,21 @@ void __init e820_reserve_resources(void)
         res->start = e820.map[i].addr;
         res->end = res->start + e820.map[i].size - 1;
         res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
-        insert_resource(&iomem_resource, res);
+        request_resource(&iomem_resource, res);
+        if (e820.map[i].type == E820_RAM) {
+            /*
+             * We don't know which RAM region contains kernel data,
+             * so we try it repeatedly and let the resource manager
+             * test it.
+             */
+            request_resource(res, code_resource);
+            request_resource(res, data_resource);
+            request_resource(res, bss_resource);
+#ifdef CONFIG_KEXEC
+            if (crashk_res.start != crashk_res.end)
+                request_resource(res, &crashk_res);
+#endif
+        }
         res++;
     }
 }
diff --git a/arch/x86/kernel/setup_64.c b/arch/x86/kernel/setup_64.c
index 22c14e2..368c672 100644
--- a/arch/x86/kernel/setup_64.c
+++ b/arch/x86/kernel/setup_64.c
@@ -254,7 +254,6 @@ static void __init reserve_crashkernel(void)
                 (unsigned long)(total_mem >> 20));
         crashk_res.start = crash_base;
         crashk_res.end   = crash_base + crash_size - 1;
-        insert_resource(&iomem_resource, &crashk_res);
     }
 }
 #else
@@ -365,11 +364,6 @@ void __init setup_arch(char **cmdline_p)
 
     finish_e820_parsing();
 
-    /* after parse_early_param, so could debug it */
-    insert_resource(&iomem_resource, &code_resource);
-    insert_resource(&iomem_resource, &data_resource);
-    insert_resource(&iomem_resource, &bss_resource);
-
     early_gart_iommu_check();
 
     e820_register_active_regions(0, 0, -1UL);
@@ -512,7 +506,7 @@ void __init setup_arch(char **cmdline_p)
     /*
      * We trust e820 completely. No explicit ROM probing in memory.
      */
-    e820_reserve_resources();
+    e820_reserve_resources(&code_resource, &data_resource, &bss_resource);
     e820_mark_nosave_regions();
 
     /* request I/O space for devices used on all i[345]86 PCs */
diff --git a/include/asm-x86/e820_64.h b/include/asm-x86/e820_64.h
index 71c4d68..10d6288 100644
--- a/include/asm-x86/e820_64.h
+++ b/include/asm-x86/e820_64.h
@@ -26,7 +26,8 @@ extern void update_memory_range(u64 start, u64 size, unsigned old_type,
 extern void setup_memory_region(void);
 extern void contig_e820_setup(void);
 extern unsigned long e820_end_of_ram(void);
-extern void e820_reserve_resources(void);
+extern void e820_reserve_resources(struct resource *code_resource,
+        struct resource *data_resource, struct resource *bss_resource);
 extern void e820_mark_nosave_regions(void);
 extern int e820_any_mapped(unsigned long start, unsigned long end,
                unsigned type);
