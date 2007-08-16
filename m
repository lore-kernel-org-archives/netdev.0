From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH] i386: Fix a couple busy loops in
 mach_wakecpu.h:wait_for_init_deassert()
Date: Thu, 16 Aug 2007 06:09:25 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708160606580.24380@enigma.security.iitk.ac.in>
References: <46C2350A.1010807@redhat.com> <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
 <20070815081841.GA16551@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Chris Snook <csnook@redhat.com>, clameter@sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, davem@davemloft.net, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58260 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761951AbXHPA0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 20:26:50 -0400
In-Reply-To: <20070815081841.GA16551@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 15 Aug 2007, Heiko Carstens wrote:

> [...]
> Btw.: we still have
> 
> include/asm-i386/mach-es7000/mach_wakecpu.h:  while (!atomic_read(deassert));
> include/asm-i386/mach-default/mach_wakecpu.h: while (!atomic_read(deassert));
> 
> Looks like they need to be fixed as well.


[PATCH] i386: Fix a couple busy loops in mach_wakecpu.h:wait_for_init_deassert()

Use cpu_relax() in the busy loops, as atomic_read() doesn't automatically
imply volatility for i386 and x86_64. x86_64 doesn't have this issue because
it open-codes the while loop in smpboot.c:smp_callin() itself that already
uses cpu_relax().

For i386, however, smpboot.c:smp_callin() calls wait_for_init_deassert()
which is buggy for mach-default and mach-es7000 cases.

[ I test-built a kernel -- smp_callin() itself got inlined in its only
  callsite, smpboot.c:start_secondary() -- and the relevant piece of
  code disassembles to the following:

0xc1019704 <start_secondary+12>:        mov    0xc144c4c8,%eax
0xc1019709 <start_secondary+17>:        test   %eax,%eax
0xc101970b <start_secondary+19>:        je     0xc1019709 <start_secondary+17>

  init_deasserted (at 0xc144c4c8) gets fetched into %eax only once and
  then we loop over the test of the stale value in the register only,
  so these look like real bugs to me. With the fix below, this becomes:

0xc1019706 <start_secondary+14>:        pause
0xc1019708 <start_secondary+16>:        cmpl   $0x0,0xc144c4c8
0xc101970f <start_secondary+23>:        je     0xc1019706 <start_secondary+14>

  which looks nice and healthy. ]

Thanks to Heiko Carstens for noticing this.

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 include/asm-i386/mach-default/mach_wakecpu.h |    3 ++-
 include/asm-i386/mach-es7000/mach_wakecpu.h  |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/asm-i386/mach-default/mach_wakecpu.h b/include/asm-i386/mach-default/mach_wakecpu.h
index 673b85c..3ebb178 100644
--- a/include/asm-i386/mach-default/mach_wakecpu.h
+++ b/include/asm-i386/mach-default/mach_wakecpu.h
@@ -15,7 +15,8 @@
 
 static inline void wait_for_init_deassert(atomic_t *deassert)
 {
-	while (!atomic_read(deassert));
+	while (!atomic_read(deassert))
+		cpu_relax();
 	return;
 }
 
diff --git a/include/asm-i386/mach-es7000/mach_wakecpu.h b/include/asm-i386/mach-es7000/mach_wakecpu.h
index efc903b..84ff583 100644
--- a/include/asm-i386/mach-es7000/mach_wakecpu.h
+++ b/include/asm-i386/mach-es7000/mach_wakecpu.h
@@ -31,7 +31,8 @@ wakeup_secondary_cpu(int phys_apicid, unsigned long start_eip)
 static inline void wait_for_init_deassert(atomic_t *deassert)
 {
 #ifdef WAKE_SECONDARY_VIA_INIT
-	while (!atomic_read(deassert));
+	while (!atomic_read(deassert))
+		cpu_relax();
 #endif
 	return;
 }
