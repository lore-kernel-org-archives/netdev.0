From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH] Re: Bad network performance over 2Gbps
Date: Thu, 17 Apr 2008 10:37:58 -0700
Message-ID: <48078AF6.2020003@intel.com>
References: <1208282804.23631.27.camel@localhost>	 <175f5a0f0804151315x1e192fc7p7dac1e84fd154211@mail.gmail.com>	 <48051173.5030802@intel.com>  <48051734.1000107@redhat.com> <1208426550.6049.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Anton Titov <a.titov@host.bg>, Chris Snook <csnook@redhat.com>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28112 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755671AbYDQRjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 13:39:04 -0400
In-Reply-To: <1208426550.6049.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Titov wrote:
> On Tue, 2008-04-15 at 16:59 -0400, Chris Snook wrote:
>> Still, I think you're on to something here.  Disabling NAPI and instead 
>> tuning the cards' interrupt coalescing settings might allow irqbalance 
>> to do a better job than it is currently.
> 
> Disabling NAPI allowed me to push as much as 3.5Gbit out of the same
> server with ~ 20% of time CPUs doing software interrupts.

yes, I really don't see this is such an amazing discovery - the in-kernel
irqbalance code is totally wrong for network interrupts (and probably for most
interrupts).

on your system with 6 network interrupts it blows chunks and it's not NAPI that is
the issue - NAPI will work just fine on it's own. By disabling NAPI and reverting
to the in-driver irq moderation code you've effectively put the in-kernel
irqbalance code to the sideline and this is what makes it work again.

It's not the right solution.

We keep seing this exact issue pop up everywhere - especially with e1000(e)
datacenter users - this code _has_ to go or be fixed. Since there is a perfectly
viable solution, I strongly suggest disabling it.

This is not the first time I've sent this patch out in some form...

Auke


---
[X86] IRQBALANCE: Mark as BROKEN and disable by default

The IRQBALANCE option causes interrupts to bounce all around on SMP systems
quickly burying the CPU in migration cost and cache misses. Mainly affected are
network interrupts and this results in one CPU pegged in softirqd completely.

Disable this option and provide documentation to a better solution (userspace
irqbalance daemon does overall the best job to begin with and only manual setting
of smp_affinity will beat it).

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

---

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 6c70fed..956aa22 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1026,13 +1026,17 @@ config EFI
   	platforms.

 config IRQBALANCE
-	def_bool y
+	def_bool n
 	prompt "Enable kernel irq balancing"
-	depends on X86_32 && SMP && X86_IO_APIC
+	depends on X86_32 && SMP && X86_IO_APIC && BROKEN
 	help
 	  The default yes will allow the kernel to do irq load balancing.
 	  Saying no will keep the kernel from doing irq load balancing.

+	  This option is known to cause performance issues on SMP
+	  systems. The preferred method is to use the userspace
+	  'irqbalance' daemon instead. See http://irqbalance.org/.
+
 config SECCOMP
 	def_bool y
 	prompt "Enable seccomp to safely compute untrusted bytecode"
