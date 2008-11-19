From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] softirq: Fix warnings triggered by netconsole
Date: Wed, 19 Nov 2008 08:41:26 +0000
Message-ID: <20081119084125.GB6699@ff.dom.local>
References: <87y6zwwy5c.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Ferenc Wagner <wferi@niif.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:37544 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbYKSIlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 03:41:31 -0500
Received: by ug-out-1314.google.com with SMTP id 39so449492ugf.37
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 00:41:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87y6zwwy5c.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider netconsole case as special in local_bh_enable()/_disable().
This patch skips in_irq() and irqs_disabled() warnings for NETPOLL
configs when it's safe wrt. do_softirq().

Reported-by: Ferenc Wagner <wferi@niif.hu>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
[apply on top of my first softirq patch in this thread]

diff -Nurp a/kernel/softirq.c b/kernel/softirq.c
--- a/kernel/softirq.c	2008-11-19 07:33:23.000000000 +0000
+++ b/kernel/softirq.c	2008-11-19 07:26:28.000000000 +0000
@@ -76,7 +76,12 @@ static void __local_bh_disable(unsigned 
 {
 	unsigned long flags;
 
+#ifdef CONFIG_NETPOLL
+	if (!softirq_count())
+		WARN_ON_ONCE(in_irq());
+#else
 	WARN_ON_ONCE(in_irq());
+#endif
 
 	raw_local_irq_save(flags);
 	add_preempt_count(SOFTIRQ_OFFSET);
@@ -138,7 +143,16 @@ static inline void _local_bh_enable_ip(u
 #ifdef CONFIG_TRACE_IRQFLAGS
 	unsigned long flags;
 #endif
+#ifdef CONFIG_NETPOLL
+	/*
+	 * Special-case - netconsole runs network code with all interrupts
+	 * disabled. Warn only if it can be really dangerous:
+	 */
+	if (softirq_count() == SOFTIRQ_OFFSET)
+		WARN_ON_ONCE(in_irq() || irqs_disabled());
+#else
 	WARN_ON_ONCE(in_irq() || irqs_disabled());
+#endif
 #ifdef CONFIG_TRACE_IRQFLAGS
 	local_irq_save(flags);
 #endif
