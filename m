From: Fan Du <fan.du@windriver.com>
Subject: [PATCH 1/3] hrtimer: Add notifer when clock_was_set was called
Date: Thu, 15 Aug 2013 15:50:41 +0800
Message-ID: <1376553043-19007-2-git-send-email-fan.du@windriver.com>
References: <1376553043-19007-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <herbert@gondor.hengli.com.au>, <dborkman@redhat.com>,
	<netdev@vger.kernel.org>
To: <tglx@linutronix.de>, <davem@davemloft.net>,
	<steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42761 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab3HOHvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 03:51:10 -0400
In-Reply-To: <1376553043-19007-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When clock_was_set is called in case of system wall time change
or host resume from suspend state, use this notifier for places
where interested in this action, e.g Ipsec SA lifetime management.

Signed-off-by: Fan Du <fan.du@windriver.com>

v3:
  -Beautify notifier with register/unregister API exported for other subsystem.
---
 include/linux/hrtimer.h |    3 +++
 kernel/hrtimer.c        |   19 +++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/linux/hrtimer.h b/include/linux/hrtimer.h
index d19a5c2..f0404e4 100644
--- a/include/linux/hrtimer.h
+++ b/include/linux/hrtimer.h
@@ -461,4 +461,7 @@ extern u64 ktime_divns(const ktime_t kt, s64 div);
 /* Show pending timers: */
 extern void sysrq_timer_list_show(void);
 
+extern int register_clock_change_notifier(struct notifier_block *nb);
+extern int unregister_clock_change_notifier(struct notifier_block *nb);
+
 #endif
diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index 383319b..c6e6405 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -755,6 +755,24 @@ static inline void retrigger_next_event(void *arg) { }
 
 #endif /* CONFIG_HIGH_RES_TIMERS */
 
+static ATOMIC_NOTIFIER_HEAD(clock_change_notifier_list);
+static int call_clock_change_notifiers(void)
+{
+	return atomic_notifier_call_chain(&clock_change_notifier_list, 0, 0);
+}
+
+int register_clock_change_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&clock_change_notifier_list, nb);
+}
+EXPORT_SYMBOL_GPL(register_clock_change_notifier);
+
+int unregister_clock_change_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&clock_change_notifier_list, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_clock_change_notifier);
+
 /*
  * Clock realtime was set
  *
@@ -773,6 +791,7 @@ void clock_was_set(void)
 	on_each_cpu(retrigger_next_event, NULL, 1);
 #endif
 	timerfd_clock_was_set();
+	call_clock_change_notifiers();
 }
 
 /*
-- 
1.7.9.5
