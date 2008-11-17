From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] softirq: Use local_irq_save() in local_bh_enable()
Date: Mon, 17 Nov 2008 13:35:48 +0000
Message-ID: <20081117133548.GC6345@ff.dom.local>
References: <87y6zwwy5c.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Ferenc Wagner <wferi@niif.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:17530 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbYKQNf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 08:35:59 -0500
Received: by rv-out-0506.google.com with SMTP id k40so2436305rvb.1
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 05:35:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87y6zwwy5c.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This report: http://marc.info/?l=linux-netdev&m=122599341430090&w=2
shows local_bh_enable() is used in the wrong context (irqs disabled).
It happens when a usual network receive path is called by netconsole,
which simply turns off irqs around this all. Probably this is wrong,
but it worked like this long time, and it's not trivial to fix this.

Anyway, a commit 0f476b6d91a1395bda6464e653ce66ea9bea7167 "softirq:
remove irqs_disabled warning from local_bh_enable" can break things
after changing from local_irq_save() to local_irq_disable(). Before
this commit there was only a warning, now a lockup is possible, so
it could be treated as a regression. This patch reverts the change
in irqs.

Reported-by: Ferenc Wagner <wferi@niif.hu>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 kernel/softirq.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/kernel/softirq.c b/kernel/softirq.c
index e7c69a7..756c928 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -135,9 +135,12 @@ EXPORT_SYMBOL(_local_bh_enable);
 
 static inline void _local_bh_enable_ip(unsigned long ip)
 {
+#ifdef CONFIG_TRACE_IRQFLAGS
+	unsigned long flags;
+#endif
 	WARN_ON_ONCE(in_irq() || irqs_disabled());
 #ifdef CONFIG_TRACE_IRQFLAGS
-	local_irq_disable();
+	local_irq_save(flags);
 #endif
 	/*
 	 * Are softirqs going to be turned on now:
@@ -155,7 +158,7 @@ static inline void _local_bh_enable_ip(unsigned long ip)
 
 	dec_preempt_count();
 #ifdef CONFIG_TRACE_IRQFLAGS
-	local_irq_enable();
+	local_irq_restore(flags);
 #endif
 	preempt_check_resched();
 }
