From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 18:00:06 +0100
Message-ID: <20041205170006.GI647@xi.wantstofly.org>
References: <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <20041205151545.GC647@xi.wantstofly.org> <Pine.LNX.4.58.0412051616090.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051622380.29474@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@pobox.com>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412051622380.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 05, 2004 at 04:30:47PM +0100, Martin Josefsson wrote:

> > I verified that I get the same results on a small whimpy 82540EM
> > that runs at 32/66 as well. Just about to see what I get at 32/33
> > with that card.
> 
> Just tested the 82540EM at 32/33 and it's a big diffrence.
> 
> 60      350229
> 64      247037
> 68      219643
> 72      218205
> 76      216786
> 80      215386
> 84      214003
> 88      212638
> 92      211291
> 96      210004
> 100     208647
> 104     182461
> 108     181468
> 112     180453
> 116     179482
> 120     185472
> 124     188336
> 128     153743

With or without prefetching? My 82540 in 32/33 mode gets on baseline
2.6.9:

60      431967
61      431311
62      431927
63      427827
64      427482

And with Scott's notxints patch:

60      514496
61      514493
62      514754
63      504629
64      504123


> Sorry, forgot to answer your other questions, I'm a bit excited at the
> moment :)

Makes sense :)


> The 64/66 bus on this motherboard is directly connected to the
> northbridge.

Your lspci output seems to suggest there is another PCI bridge in
between (00:10.0)

Basically on my box, it's CPU - MCH - P64H2 - e1000, where MCH is the
'Memory Controller Hub' and P64H2 the PCI-X bridge chip.


> I have no idea how expensive an MMIO read is on this machine, do you have
> an relatively easy way to find out?

A dirty way, yes ;-)  Open up e1000_osdep.h and do:

-#define E1000_READ_REG(a, reg) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)))
+#define E1000_READ_REG(a, reg) ({ \
+    unsigned long s, e, d, v; \
+\
+    (a)->mmio_reads++; \
+    rdtsc(s, d); \
+    v = readl((a)->hw_addr + \
+        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)); \
+    rdtsc(e, d); \
+    e -= s; \
+    printk(KERN_INFO "e1000: MMIO read took %ld clocks\n", e); \
+    printk(KERN_INFO "e1000: in process %d(%s)\n", current->pid, current->comm); \
+    dump_stack(); \
+    v; \
+})

You might want to disable the stack dump of course.


--L
