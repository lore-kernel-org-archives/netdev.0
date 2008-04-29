From: Greg KH <gregkh@suse.de>
Subject: [03/12] x86: Fix 32-bit x86 MSI-X allocation leakage
Date: Tue, 29 Apr 2008 11:49:29 -0700
Message-ID: <20080429184929.GD24199@suse.de>
References: <20080429184543.308594866@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41248 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761910AbYD2Sup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 14:50:45 -0400
Content-Disposition: inline; filename="x86-fix-32-bit-x86-msi-x-allocation-leakage.patch"
In-Reply-To: <20080429184911.GA24199@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.24-stable review patch.  If anyone has any objections, please let us
know.

------------------

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

commit 9d9ad4b51d2b29b5bbeb4011f5e76f7538119cf9 upstream

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
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 arch/x86/kernel/io_apic_32.c |    1 +
 1 file changed, 1 insertion(+)

--- a/arch/x86/kernel/io_apic_32.c
+++ b/arch/x86/kernel/io_apic_32.c
@@ -2478,6 +2478,7 @@ void destroy_irq(unsigned int irq)
 	dynamic_irq_cleanup(irq);
 
 	spin_lock_irqsave(&vector_lock, flags);
+	clear_bit(irq_vector[irq], used_vectors);
 	irq_vector[irq] = 0;
 	spin_unlock_irqrestore(&vector_lock, flags);
 }

-- 
