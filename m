From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Sat, 23 Aug 2008 08:42:33 -0700 (PDT)
Message-ID: <982729.41105.qm@web82107.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>,
	Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82107.mail.mud.yahoo.com ([209.191.84.220]:33270 "HELO
	web82107.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751597AbYHWPme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 11:42:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> could you try the debug patch below ontop of latest tip/master:
> 
>   http://people.redhat.com/mingo/tip.git/README

Thanks Ingo.

I've been building your 'tip/master' tree daily (Just In Case) since 
Aug. 11, when you first asked me to try it!  ;)


> the patch forcibly ignores resource conflicts and reports them. This 
> will likely break some system - but if your hpet troubles are due to 
> resource conflicts then this patch would make the kernel boot up fine on 
> your system by default, with a working hpet.
> 
> You should also be getting a printout and a warning in the dmesg in that 
> case.

No offense... but this patch does something Bad.  [BTW, if you send patches
for me to try in the future, could you make them attachments?  I have not
replaced my old email system with the new one which uses my newer "server"
machines, so I have been temporarily forced to use my ISP's _broken_ web
interface for email.  Not only does that web client break threading in
LKML inboxes -- sorry folks! -- it messes up the whitespace in patches, so
I have to apply them manually, unless they are provided as attachments.]

It built OK, but when I rebooted it hung _extremely_ early.  All I got was

- 2 lines of GRUB output
- kernel boot parameters (maybe also from GRUB)
- "Decompressing Linux... Parsing ELF... done."
- "Booting the kernel"

... and there it hung.

I had forgotten to turn on debugging parameters, so I applied my own reduced
version of Yinghai's debugging patch for resource.c, and enabled 80x50 text
mode and set "loglevel=4", hoping I could tell you more about where the
kernel was hanging with your new patch.

Rebooting with those changes, the output was identical to the above.  The
kernel freezes before any calls of insert_resource() or request_resource().

I tried a third reboot, with "debug initcall_debug"... but the results
were the same.  The kernel hangs almost immediately with the patch you
sent.


[In case my own changes are suspect, I am providing the diff for resource.c
against the original tip/master version -- but this only shows the changes
made for the second and third reboots.  The first reboot was with a 
tip/master kernel using only the patch you sent me applied.]

$ git diff kernel/resource.c
diff --git a/kernel/resource.c b/kernel/resource.c
index f5b518e..167f385 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -156,6 +156,7 @@ static struct resource * __request_resource(struct resource *root, struct resour
     for (;;) {
         tmp = *p;
         if (!tmp || tmp->start > end) {
+insert:
             new->sibling = tmp;
             *p = new;
             new->parent = root;
@@ -164,7 +165,10 @@ static struct resource * __request_resource(struct resource *root, struct resour
         p = &tmp->sibling;
         if (tmp->end < start)
             continue;
-        return tmp;
+        printk("ignoring resource conflict between %s/{%p..%p} and %s/{%p..%p}\n", new->name, 
+               (void *)new->start, (void *)new->end, tmp->name, (void *)tmp->start, (void *)tmp->end);
+        WARN_ON(1);
+        goto insert;
     }
 }
 
@@ -197,10 +201,20 @@ static int __release_resource(struct resource *old)
 int request_resource(struct resource *root, struct resource *new)
 {
     struct resource *conflict;
+     resource_size_t  dstart, dend;
+     char has_conflict;
 
     write_lock(&resource_lock);
     conflict = __request_resource(root, new);
     write_unlock(&resource_lock);
+ 
+     dstart = new->start - root->start;
+     dend = root->end - new->end;
+     has_conflict = conflict ? '!' : ' ';
+ 
+     printk(KERN_ERR "R:%-12.12s%8llx-%-16llx(%c%-12.12s-%-6llx+%-6llx)\n", new->name, new->start, new->end,
+            has_conflict, root->name, dstart, dend);
+ 
     return conflict ? -EBUSY : 0;
 }
 
@@ -382,11 +396,15 @@ int insert_resource(struct resource *parent, struct resource *new)
 
     write_lock(&resource_lock);
 
+     printk(KERN_ERR "I:%-12.12s%8llx-%-16llx(P=%-12.12s)... ", new->name, new->start, new->end, parent->name);
+ 
     for (;; parent = first) {
          result = 0;
         first = __request_resource(parent, new);
-        if (!first)
-            goto out;
+         if (!first) {
+                 printk(KERN_ERR "good(P=%-12.12s)\n", parent->name);
+              goto out;
+         }
 
         result = -EBUSY;
         if (first == parent)
@@ -414,9 +432,13 @@ int insert_resource(struct resource *parent, struct resource *new)
     new->sibling = next->sibling;
     new->child = first;
 
+     printk(KERN_ERR "in(P=%-12.12s)... ", parent->name);
+ 
     next->sibling = NULL;
-    for (next = first; next; next = next->sibling)
-        next->parent = new;
+     for (next = first; next; next = next->sibling) {
+          next->parent = new;
+         printk(KERN_ERR "ch=%-12.12s\n", next->name);
+     }
 
     if (parent->child == first) {
         parent->child = new;
