From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: [PATCH RFC 2/4] ARM: kgdb: Disable preemption before re-enabling
 interrupts
Date: Wed, 7 Jul 2010 21:13:20 +0400
Message-ID: <20100707171320.GB20015@oksana.dev.rtsoft.ru>
References: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wessel <jason.wessel@windriver.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: kgdb-bugreport@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41397 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208Ab0GGRNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 13:13:51 -0400
Received: by mail-wy0-f174.google.com with SMTP id 23so3418903wyf.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 10:13:51 -0700 (PDT)
Content-Disposition: attachment
In-Reply-To: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to disable preemption before enabling local IRQs because
local_irq_enable() makes it possible for the kernel to reschedule,
so the kernel might hit a breakpoint causing itself to re-enter
KGDB and die.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 arch/arm/kernel/kgdb.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/arch/arm/kernel/kgdb.c b/arch/arm/kernel/kgdb.c
index 5c61100..6ece654 100644
--- a/arch/arm/kernel/kgdb.c
+++ b/arch/arm/kernel/kgdb.c
@@ -167,9 +167,17 @@ static void kgdb_call_nmi_hook(void *ignored)
 
 void kgdb_roundup_cpus(unsigned long flags)
 {
+	/*
+	 * We have to disable preemption before enabling local
+	 * IRQs because local_irq_enable() makes it possible for
+	 * the kernel to reschedule, so the kernel might hit a
+	 * breakpoint causing itself to re-enter KGDB and die.
+	 */
+	preempt_disable();
        local_irq_enable();
        smp_call_function(kgdb_call_nmi_hook, NULL, 0);
        local_irq_disable();
+	preempt_enable();
 }
 
 #ifdef CONFIG_SMP
-- 
1.7.0.5

