From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- experimental revert for 2.6.27 failed
Date: Tue, 12 Aug 2008 17:00:10 -0700 (PDT)
Message-ID: <940473.79639.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82108.mail.mud.yahoo.com ([209.191.84.221]:39692 "HELO
	web82108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752626AbYHMAAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 20:00:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SUMMARY

1.  Ran 'git remote update', then built kernels for origin/master
(Linus' linux-2.6 tree) and tip/master.  Both froze.

2.  Attempted a revert against tip/master, but the files involved
changed quite a bit.  I _was_ able to build the kernel successfully,
but it froze.  There have simply been too many changes since Feb. 22
for my naive approach to work.

3.  When the revert failed, I panicked:  I thought that I might
truly have made a mistake with the original 'git bisect' process
I carried out.  After retracing the last few iterations of the
process -- building and checking the last 3 kernels -- I found
that the information I posted here WAS correct:  the problem
commit # was the one I had found the first time.

4.  To see if I am totally incompetent, I used git to checkout the
version of the sources at the problem commit, and then reverted
those changes (same method used in step 2).  The kernel built
and ran just fine:  no freeze, no need for "hpet=disabled".


DETAILS

Here is some git output showing the changes I made.  My approach was
extremely naive, but since I have very little or no understanding of
the code itself, no other approach was possible for me:

====== BEGIN git OUTPUT ==========

$ git show
commit e10eb6518a3a08598344d477137cbdd25e85571d
Merge: b4141ac... 45fc3c4...
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Aug 12 19:43:39 2008 +0200

    Merge branch 'linus'

$ git diff
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 9af8907..131d6f7 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1267,7 +1267,9 @@ static inline const char *e820_type_to_string(int e820_type)
 /*
  * Mark e820 reserved areas as busy for the resource manager.
  */
-void __init e820_reserve_resources(void)
+/* void __init e820_reserve_resources(void) */
+void __init e820_reserve_resources(struct resource *code_resource,
+        struct resource *data_resource, struct resource *bss_resource)
 {
     int i;
     struct resource *res;
@@ -1287,7 +1289,22 @@ void __init e820_reserve_resources(void)
         res->end = end;
 
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
+        /* insert_resource(&iomem_resource, res); */
         res++;
     }
 
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 59f07e1..5972d13 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -517,7 +517,7 @@ static void __init reserve_crashkernel(void)
 
     crashk_res.start = crash_base;
     crashk_res.end   = crash_base + crash_size - 1;
-    insert_resource(&iomem_resource, &crashk_res);
+    /* insert_resource(&iomem_resource, &crashk_res); */
 }
 #else
 static void __init reserve_crashkernel(void)
@@ -700,9 +700,9 @@ void __init setup_arch(char **cmdline_p)
 #endif
 
     /* after parse_early_param, so could debug it */
-    insert_resource(&iomem_resource, &code_resource);
-    insert_resource(&iomem_resource, &data_resource);
-    insert_resource(&iomem_resource, &bss_resource);
+    /* insert_resource(&iomem_resource, &code_resource); */
+    /* insert_resource(&iomem_resource, &data_resource); */
+    /* insert_resource(&iomem_resource, &bss_resource); */
 
     if (efi_enabled)
         efi_init();
@@ -865,7 +865,7 @@ void __init setup_arch(char **cmdline_p)
 
     kvm_guest_init();
 
-    e820_reserve_resources();
+    e820_reserve_resources(&code_resource, &data_resource, &bss_resource);
     e820_mark_nosave_regions(max_low_pfn);
 
 #ifdef CONFIG_X86_32
diff --git a/include/asm-x86/e820.h b/include/asm-x86/e820.h
index f52daf1..57f0c67 100644
--- a/include/asm-x86/e820.h
+++ b/include/asm-x86/e820.h
@@ -47,6 +47,8 @@
 /* reserved RAM used by kernel itself */
 #define E820_RESERVED_KERN        128
 
+#include <linux/ioport.h>
+
 #ifndef __ASSEMBLY__
 struct e820entry {
     __u64 addr;    /* start of memory segment */
@@ -120,7 +122,8 @@ extern void e820_register_active_regions(int nid, unsigned long start_pfn,
                      unsigned long end_pfn);
 extern u64 e820_hole_size(u64 start, u64 end);
 extern void finish_e820_parsing(void);
-extern void e820_reserve_resources(void);
+extern void e820_reserve_resources(struct resource *code_resource,
+        struct resource *data_resource, struct resource *bss_resource);
 extern void setup_memory_map(void);
 extern char *default_machine_specific_memory_setup(void);
 extern char *machine_specific_memory_setup(void);
====== END git OUTPUT ==========


The #include of linux/ioport.h was not part of the problem commit, but
the changes since Feb. 22 were such that I was forced to add that line
myself to make it possible to build.

In many cases the lines near the changes in this attempted revert were
quite different from those in the diff from the problem commit, so there
was very little chance for me to succeed, I suspect.


For my own peace of mind, I went back to the bisecting to verify that the
commit I have previously identified was really correct.  Results:

==========
$ git checkout 1e934dda0c77c8ad13fdda02074f2cfcea118a56
Previous HEAD position was e10eb65... Merge branch 'linus'
Checking out files: 100% (17901/17901), done.
HEAD is now at 1e934dd... x86: insert_resorce for lapic addr after e820_reserve_resources

$ git bisect start
$ git bisect bad
$ git checkout 322850af8d93735f67b8ebf84bb1350639be3f34
Previous HEAD position was 1e934dd... x86: insert_resorce for lapic addr after e820_reserve_resources
HEAD is now at 322850a... x86: make amd quad core 8 socket system not be clustered_box, #2

$ git bisect good
Bisecting: 1 revisions left to test after this
[3def3d6ddf43dbe20c00c3cbc38dfacc8586998f] x86: clean up e820_reserve_resources on 64-bit

$ git bisect bad
Bisecting: 0 revisions left to test after this
[700efc1b9f6afe34caae231b87d129ad8ffb559f] x86: introduce kernel/head32.c
dawitbro@fileserver:~/sandbox/git-kernel/linux-2.6$ git bisect good
3def3d6ddf43dbe20c00c3cbc38dfacc8586998f is first bad commit
commit 3def3d6ddf43dbe20c00c3cbc38dfacc8586998f
Author: Yinghai Lu <Yinghai.Lu@Sun.COM>
Date:   Fri Feb 22 17:07:16 2008 -0800

    x86: clean up e820_reserve_resources on 64-bit
    
    e820_resource_resources could use insert_resource instead of request_resource
    also move code_resource, data_resource, bss_resource, and crashk_res
    out of e820_reserve_resources.
    
    Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

:040000 040000 79fea1b27a7affdf269cd55f633d495d1cac9513 abcad2c76947ba30fa0c94e0a9dcabd5d8666d28 M    arch
:040000 040000 5d0b70980ad3692c9fa75ab67a3a43f1aa7807ce a5714997f2337541581dee96f19b7fe86c7941dc M    include
==========

I cannot describe how much relief I felt upon seeing that.

Since my main goal was to troubleshoot the Debian 2.6.26 stock kernel, my
next experiments will be to see if I can get a reversion to work against
any version in the 2.6.26-rc* line, and hopefully the 2.6.26 release 
itself.


DW
