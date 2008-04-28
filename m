From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] ARCH 2.6.25.y: Fix 32-bit x86 MSI-X allocation leakage
Date: Mon, 28 Apr 2008 11:56:22 -0700
Message-ID: <20080428185622.11638.29287.stgit@scrappy.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stable@kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17191 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935196AbYD1S6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 14:58:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resend now that this patch is in -upstream.

This bug was introduced in the 2.6.24 i386/x86_64 tree merge, where
MSI-X vector allocation will eventually fail.  The cause is the new
bit array tracking used vectors is not getting cleared properly on
IRQ destruction on the 32-bit APIC code.

This can be seen easily using the ixgbe 10 GbE driver on multi-core
systems by simply loading and unloading the driver a few times.
Depending on the number of available vectors on the host system, the
MSI-X allocation will eventually fail, and the driver will only be
able to use legacy interrupts.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 arch/x86/kernel/io_apic_32.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/arch/x86/kernel/io_apic_32.c b/arch/x86/kernel/io_apic_32.c
index 4ca5486..f239b30 100644
--- a/arch/x86/kernel/io_apic_32.c
+++ b/arch/x86/kernel/io_apic_32.c
@@ -2477,6 +2477,7 @@ void destroy_irq(unsigned int irq)
 	dynamic_irq_cleanup(irq);
 
 	spin_lock_irqsave(&vector_lock, flags);
+	clear_bit(irq_vector[irq], used_vectors);
 	irq_vector[irq] = 0;
 	spin_unlock_irqrestore(&vector_lock, flags);
 }

