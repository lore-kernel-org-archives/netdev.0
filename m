From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Tue, 12 Aug 2008 08:17:07 -0700 (PDT)
Message-ID: <962464.9576.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82108.mail.mud.yahoo.com ([209.191.84.221]:42139 "HELO
	web82108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752191AbYHLPRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 11:17:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BRAIN DAMAGE CONTROL:  the problem is only on my hardware, so no one 
on LKML can play with this hardware directly.  That makes _me_ the weak 
link.

1.  Can someone comment on whether I correctly identified the commit #
causing the issue for me.  Here is the 'git bisect' data from my first
post:

2.6.25, good
2.6.26-rc4, bad
10c993a6b5418cb1026775765ba4c70ffb70853d, bad
334d094504c2fe1c44211ecb49146ae6bca8c321, bad
eddeb0e2d863e3941d8768e70cb50c6120e61fa0, bad
77ad386e596c6b0930cc2e09e3cce485e3ee7f72, bad
ede1389f8ab4f3a1343e567133fa9720a054a3aa, bad
c048fdfe6178e082be918d4062c86d9764979112, bad
f73920cd63d316008738427a0df2caab6cc88ad7, bad
04aaa7ba096c707a8df337b29303f1a5a65f0462, good
8fa6878ffc6366f490e99a1ab31127fb599657c9, good
1180e01de50c0c7683c6648251f32957bc2d7850, good
1e934dda0c77c8ad13fdda02074f2cfcea118a56, bad
322850af8d93735f67b8ebf84bb1350639be3f34, good
3def3d6ddf43dbe20c00c3cbc38dfacc8586998f, bad
700efc1b9f6afe34caae231b87d129ad8ffb559f, good

I concluded that 3def3d... was causing the problem for me, but I didn't
actually pipe or redirect the output message from 'git bisect' when it
stated that.  Does that conclusion look OK?



2.  I have not tried different versions of gcc.  I did not think of
doing so because (a) I use the same version of gcc on all 3 machines,
(b) the kernel builds without error on all 3 machines, and (c) the
kernel runs on 1 machine ("desktop") but freezes on the other 2 
[which share the same mboard model as each other, but are different 
from the "desktop" mboard].  If gcc was bad, wouldn't the kernels
freeze on all the machines; and wouldn't the Debian BTS be full of
reports about kernel freezes with the recently released 2.6.26 line?

$ gcc -v
Using built-in specs.
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Debian 4.3.1-8'
--with-bugurl=file:///usr/share/doc/gcc-4.3/README.Bugs
--enable-languages=c,c++,fortran,objc,obj-c++ --prefix=/usr
--enable-shared --with-system-zlib --libexecdir=/usr/lib
--without-included-gettext --enable-threads=posix --enable-nls
--with-gxx-include-dir=/usr/include/c++/4.3 --program-suffix=-4.3
--enable-clocale=gnu --enable-libstdcxx-debug --enable-objc-gc
--enable-mpfr --enable-cld --enable-checking=release
--build=x86_64-linux-gnu --host=x86_64-linux-gnu
--target=x86_64-linux-gnu
Thread model: posix
gcc version 4.3.1 (Debian 4.3.1-8) 


3.  I keep wanting to play with source code, but I keep repressing the
urge because I _know_ that I do not know what I'm doing.  I keep seeing
code that I want to alter, test, or otherwise play with.  For example:

A)  The commit above touches arch/x86/kernel/e820_64.c (now e820.c) in the
e820_reserve_resources() function this way:

@@ -245,21 +244,7 @@ 
         res->start = e820.map[i].addr;
         res->end = res->start + e820.map[i].size - 1;
         res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
-        request_resource(&iomem_resource, res);
-        if (e820.map[i].type == E820_RAM) {
-            /*
-             * We don't know which RAM region contains kernel data,
-             * so we try it repeatedly and let the resource manager
-             * test it.
-             */
-            request_resource(res, code_resource);
-            request_resource(res, data_resource);
-            request_resource(res, bss_resource);
-#ifdef CONFIG_KEXEC
-            if (crashk_res.start != crashk_res.end)
-                request_resource(res, &crashk_res);
-#endif
-        }
+        insert_resource(&iomem_resource, res);
     }
 }

I keep wondering whether my hardware needed something with the 
if(e820...) block that was removed (that the rest of the world does
not need).


B)  Since the commit mostly involved changes that add insert_resource()
calls, I look that that function in kernel/resource.c, and saw this
section:

    for (next = first; ; next = next->sibling) {
        /* Partial overlap? Bad, and unfixable */
        if (next->start < new->start || next->end > new->end)
            goto out;
        if (!next->sibling)
            break;
        if (next->sibling->start > new->end)
            break;
    }

Maybe the "partial overlap" is something that should never occur, and
occurs so rarely that most folks are never bitten.  Except me?


Chanting, "Every day, and in every way, I'm getting better and better..."
Dave W.
