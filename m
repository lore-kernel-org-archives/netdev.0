From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Wed, 20 Aug 2008 09:44:40 -0700 (PDT)
Message-ID: <513656.76811.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82108.mail.mud.yahoo.com ([209.191.84.221]:29940 "HELO
	web82108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752689AbYHTQol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 12:44:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > >> > This is true if he reverted just the 3def3d6d... commit, but if he
> > >> > also reverts the similar, and immediately following, 1e934dda...
> > >> > commit, then his 2.6.26 kernel runs fine.
> > >>
> > >> interesting,
> > >>
> > >> David, can you try only comment out
> > >>
> > >> late_initcall(lapic_insert_resource);
> > >
> > > i.e. the patch below?
> > >
> > > what's your theory, what could be the reason for David's lockups?
> > 
> > could be insert_resource related.
> > 1. revert patch that change back insert_resource doesn't work
> > 2. insert_resource for lapic address moved to late after ....
> > 
> > need to add debug printout for insert_resource/request_resource to 
> > make sure thing going well
> 
> but what can happen if it does not "go well"? The resource list is 
> basically there to make sure we dont overlap resources. But is there a 
> real danger here for any overlap?
> 
> And insert_resource() differs from request_resource() in that 
> insert_resource() allows "complete overlap". David has done printks of 
> all resources in this thread - can you see anything suspicious in there?


Clarification:  the resource-related outputs I have posted here so far
have been either from kernels without the regression (2.6.25 series, or
the v2.6.26 kernel with 2 reverts) or kernels _with_ the regression but
made to boot with "hpet=disable".  Those outputs were 'cat /proc/iomem'.

Any other output I have posted here, involving insertion of printk's to
see diagnostic data just before the lockups, has not included resource-
related information.  This is for two reasons:

1.  It is hard to fit the entire contents of the iomem_resource tree on
the little 80x25 VGA screen!

2.  The data I do get has to be hand-transcribed, decreasing the 
reliability a lot.

3.  It results mostly from my own personal experiments, trying to
understand what the kernel code is doing and what it is supposed to be
doing.  You folks already know those things, so I assumed that most of
the data I produced would be irrelevant -- and when I asked if anyone
wanted to see it, there were no replies.


I fought on Monday with the idea of producing the equivalent of
'cat /proc/iomem', but on a hanging kernel just before it hangs.  The
output format suffered as I tried to squeeze it all on one 80x25
screen, but I _did_ succeed:

===== BEGIN OUTPUT ===================
Number of resources handled by insert_resource(): 12
       0-ffffffffffffffff       PCI mem        0-9f3ff               System RAM
   9f400-9ffff                 reserved    f0000-fffff                 reserved
  100000-77fdffff            System RAM   200000-56ff31             kernel code
  56ff32-6d8fff             kernel data   76a000-7ac907              kernel bss
77fe0000-77fe2fff          ACPI non-vol 77fe3000-77feffff           ACPI Tables
77ff0000-77ffffff              reserved 78000000-7fffffff             pnp 00:0d
80000000-800003ff          0000:00:14.0 d8000000-dfffffff          PCI Bus 0000
d8000000-dfffffff          0000:01:05.0 e0000000-efffffff              reserved
fdc00000-fdcfffff          PCI Bus 0000 fdcff000-fcdff0ff          0000:02:05.0
fdd00000-fdefffff          PCI Bus 0000 fdd00000-fddfffff          0000:01:05.0
fdee0000-fdeeffff          0000:01:05.0 fdefc000-fdefffff          0000:01:05.2
fdf00000-fdffffff          PCI Bus 0000 fdf00000-fdf1ffff          0000:02:05.0
fe020000-fe023fff          0000:00:14.2 fe029000-fe0290ff          0000:00:13.5
fe02a000-fe02afff          0000:00:13.4 fe02b000-fe02bfff          0000:00:13.3
fe02c000-fe02cfff          0000:00:13.2 fe02d000-fe02dfff          0000:00:13.1
fe02e000-fe02efff          0000:00:13.0 fe02f000-fe02feff          0000:00:12.0
fec00000-ffffffff              reserved
===== END OUTPUT ===================

Please beware that my recursion follows 'struct resource *' children first,
then siblings only after the entire child subtree is exhausted.

The only resource names that I see truncated are the "PCI Bus 0000" entries,
but those can be matched with the 'cat /proc/iomem' data I posted earlier;
the address ranges are similar to those of a working kernel:

===== v2.6.25 NON-REGRESSION KERNEL OUTPUT =====
$ cat /proc/iomem
00000000-0009f3ff : System RAM
0009f400-0009ffff : reserved
000f0000-000fffff : reserved
00100000-77fdffff : System RAM
  00200000-0056ca21 : Kernel code
  0056ca22-006ce3d7 : Kernel data
  00753000-0079a3c7 : Kernel bss
77fe0000-77fe2fff : ACPI Non-volatile Storage
77fe3000-77feffff : ACPI Tables
77ff0000-77ffffff : reserved
78000000-7fffffff : pnp 00:0d
d8000000-dfffffff : PCI Bus #01
  d8000000-dfffffff : 0000:01:05.0
    d8000000-d8ffffff : uvesafb
e0000000-efffffff : PCI MMCONFIG 0
  e0000000-efffffff : reserved
fdc00000-fdcfffff : PCI Bus #02
  fdcff000-fdcff0ff : 0000:02:05.0
    fdcff000-fdcff0ff : r8169
fdd00000-fdefffff : PCI Bus #01
  fdd00000-fddfffff : 0000:01:05.0
  fdee0000-fdeeffff : 0000:01:05.0
  fdefc000-fdefffff : 0000:01:05.2
    fdefc000-fdefffff : ICH HD audio
fdf00000-fdffffff : PCI Bus #02
fe020000-fe023fff : 0000:00:14.2
  fe020000-fe023fff : ICH HD audio
fe029000-fe0290ff : 0000:00:13.5
  fe029000-fe0290ff : ehci_hcd
fe02a000-fe02afff : 0000:00:13.4
  fe02a000-fe02afff : ohci_hcd
fe02b000-fe02bfff : 0000:00:13.3
  fe02b000-fe02bfff : ohci_hcd
fe02c000-fe02cfff : 0000:00:13.2
  fe02c000-fe02cfff : ohci_hcd
fe02d000-fe02dfff : 0000:00:13.1
  fe02d000-fe02dfff : ohci_hcd
fe02e000-fe02efff : 0000:00:13.0
  fe02e000-fe02efff : ohci_hcd
fe02f000-fe02f3ff : 0000:00:12.0
  fe02f000-fe02f3ff : ahci
fec00000-fec00fff : IOAPIC 0
  fec00000-fec00fff : pnp 00:0d
fed00000-fed003ff : HPET 0
  fed00000-fed003ff : 0000:00:14.0
fee00000-fee00fff : Local APIC
fff80000-fffeffff : pnp 00:0d
ffff0000-ffffffff : pnp 00:0d
===============================================

I see now that much is missing in the hanging kernel's output.  It may be
hanging before all the resources are added.

[I have a dual core CPU.  If the missing things are already supposed to be 
there at this point, when inet_init() is running, could one core be hung 
while the other core runs inet_init() until it hits synchronize_rcu()?  
I'm sure my question is silly:  I don't even know whether a SMP kernel 
boots in SMP mode, or when it switches to SMP if it doesn't start that 
way!]


The screenful of 80x25 output above was produced with the following code:
=========================================================================
diff --git a/kernel/resource.c b/kernel/resource.c
index f5b518e..d2c62d6 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -375,11 +375,16 @@ EXPORT_SYMBOL(allocate_resource);
  * resource is inserted and the conflicting resources become children of
  * the new resource.
  */
+
+extern unsigned dw_count;
+
 int insert_resource(struct resource *parent, struct resource *new)
 {
     int result;
     struct resource *first, *next;
 
+    static unsigned int num_calls = 0;
+
     write_lock(&resource_lock);
 
     for (;; parent = first) {
@@ -394,16 +399,19 @@ int insert_resource(struct resource *parent, struct resource *new)
 
         if ((first->start > new->start) || (first->end < new->end))
             break;
+
         if ((first->start == new->start) && (first->end == new->end))
             break;
     }
 
     for (next = first; ; next = next->sibling) {
         /* Partial overlap? Bad, and unfixable */
-        if (next->start < new->start || next->end > new->end)
+            if (next->start < new->start || next->end > new->end)
             goto out;
+
         if (!next->sibling)
             break;
+
         if (next->sibling->start > new->end)
             break;
     }
@@ -429,6 +437,9 @@ int insert_resource(struct resource *parent, struct resource *new)
 
  out:
     write_unlock(&resource_lock);
+
+    dw_count = ++num_calls;
+
     return result;
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 600bb23..b6f57c2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -127,6 +127,8 @@
 #include <linux/jhash.h>
 #include <linux/random.h>
 
+#include <linux/ioport.h>
+
 #include "net-sysfs.h"
 
 /*
@@ -4304,9 +4306,29 @@ void free_netdev(struct net_device *dev)
     put_device(&dev->dev);
 }
 
+unsigned dw_count;
+
+void dw_print_res (struct resource *r)
+{
+        printk ("%9llx-%-16llx%14.12s", r->start, r->end, r->name);
+}
+
+void dw_recurse_res (struct resource *r)
+{
+        if (!r) return;
+
+    dw_print_res (r);
+    dw_recurse_res (r->child);
+    dw_recurse_res (r->sibling);
+}
+
 /* Synchronize with packet receive processing. */
 void synchronize_net(void)
 {
     might_sleep();
+
+    printk ("Number of resources handled by insert_resource(): %u\n", dw_count);
+    dw_recurse_res (&iomem_resource);
+
     synchronize_rcu();
 }
=========================================================================


HTH,
Dave W.
