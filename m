From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] ARCH: Fix 32-bit x86 MSI-X allocation leakage
Date: Fri, 25 Apr 2008 17:58:52 -0700
Message-ID: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7807 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934604AbYD1R1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 13:27:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug was introduced in the 2.6.24 i386/x86_64 tree merge, where
MSI-X vector allocation will eventually fail.  The cause is the new
bit array tracking used vectors is not getting cleared properly on
IRQ destruction on the 32-bit APIC code.

This can be seen easily using the ixgbe 10 GbE driver on multi-core
systems by simply loading and unloading the driver a few times.
Depending on the number of available vectors on the host system, the
MSI-X allocation will eventually fail, and the driver will only be
able to use legacy interrupts.

I am generating the same patch for both stable trees for 2.6.24 and
2.6.25.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 arch/x86/kernel/io_apic_32.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/arch/x86/kernel/io_apic_32.c b/arch/x86/kernel/io_apic_32.c
index 2e2f420..77798b1 100644
--- a/arch/x86/kernel/io_apic_32.c
+++ b/arch/x86/kernel/io_apic_32.c
@@ -2444,6 +2444,7 @@ void destroy_irq(unsigned int irq)
 	dynamic_irq_cleanup(irq);
 
 	spin_lock_irqsave(&vector_lock, flags);
+	clear_bit(irq_vector[irq], used_vectors);
 	irq_vector[irq] = 0;
 	spin_unlock_irqrestore(&vector_lock, flags);
 }

