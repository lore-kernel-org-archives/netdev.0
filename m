From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH 2/2] x86: get more exact nr_irqs
Date: Sun, 03 Jan 2010 22:58:21 -0800
Message-ID: <4B41918D.3000605@kernel.org>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	 <4B398ECD.1080506@kernel.org> <4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com> <4B415E73.1050801@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:34169 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869Ab0ADG7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 01:59:45 -0500
In-Reply-To: <4B415E73.1050801@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



first check with NR_VECTORS - FIRST_EXTERNAL_VECTOR - 0x20
aka minus exceptions and system vectors.

NR_CPUS = 512, and nr_cpu_ids = 128
will have NR_IRQS = 256 + 512 * 64 = 33024

assume we have 20 intel ixgbe 6 port cards (with sriov and ixgbevf)
	20 * 6 * 64 * 3 = 23040

first will get:
	128 * (256 - 64) = 24576
then with nr_irqs_gsi will get
	(120 + 8 * 128 + 120 * 256) = 31864

so 24576 will be used for nr_irqs.

24576 * 8 = 196608 bytes will be used for irq_desc_ptrs[]

before this patch:
    have nr_irqs = 120 + 8 * 128 + 120 * 64 = 8824
	and irq_desc_ptrs[] is 70592

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 arch/x86/kernel/apic/io_apic.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

Index: linux-2.6/arch/x86/kernel/apic/io_apic.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/apic/io_apic.c
+++ linux-2.6/arch/x86/kernel/apic/io_apic.c
@@ -3833,15 +3833,20 @@ int __init arch_probe_nr_irqs(void)
 {
 	int nr;
 
-	if (nr_irqs > (NR_VECTORS * nr_cpu_ids))
-		nr_irqs = NR_VECTORS * nr_cpu_ids;
+	/* 0x20 for ipi etc system vectors */
+	nr = NR_VECTORS - FIRST_EXTERNAL_VECTOR - 0x20;
+
+	nr *= nr_cpu_ids;
+
+	if (nr < nr_irqs)
+		nr_irqs = nr;
 
 	nr = nr_irqs_gsi + 8 * nr_cpu_ids;
 #if defined(CONFIG_PCI_MSI) || defined(CONFIG_HT_IRQ)
 	/*
 	 * for MSI and HT dyn irq
 	 */
-	nr += nr_irqs_gsi * 64;
+	nr += nr_irqs_gsi * 256;
 #endif
 	if (nr < nr_irqs)
 		nr_irqs = nr;
