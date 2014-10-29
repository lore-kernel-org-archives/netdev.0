From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce napi_schedule_irqoff()
Date: Tue, 28 Oct 2014 18:05:13 -0700
Message-ID: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:38453 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbaJ2BFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 21:05:22 -0400
Received: by mail-pa0-f53.google.com with SMTP id kx10so1983835pab.12
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 18:05:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

napi_schedule() can be called from any context and has to mask hard
irqs.

Add a variant that can only be called from hard interrupts handlers
or when irqs are already masked.

Many NIC drivers can use it from their hard IRQ handler instead of
generic variant.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |   13 +++++++++++++
 net/core/dev.c            |   15 ++++++++++++++-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 74fd5d37f15a472239c1c63cebe7ce9e59fc4c90..c85e065122460e9f077bcb6788018be38e1d7ddf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -386,6 +386,7 @@ typedef enum rx_handler_result rx_handler_result_t;
 typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
 
 void __napi_schedule(struct napi_struct *n);
+void __napi_schedule_irqoff(struct napi_struct *n);
 
 static inline bool napi_disable_pending(struct napi_struct *n)
 {
@@ -420,6 +421,18 @@ static inline void napi_schedule(struct napi_struct *n)
 		__napi_schedule(n);
 }
 
+/**
+ *	napi_schedule_irqoff - schedule NAPI poll
+ *	@n: napi context
+ *
+ * Variant of napi_schedule(), assuming hard irqs are masked.
+ */
+static inline void napi_schedule_irqoff(struct napi_struct *n)
+{
+	if (napi_schedule_prep(n))
+		__napi_schedule_irqoff(n);
+}
+
 /* Try to reschedule poll. Called by dev->poll() after napi_complete().  */
 static inline bool napi_reschedule(struct napi_struct *napi)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index b793e3521a3631319bf4d0e7c17c0c9a933331da..759940cdf89635d58778502276d9914e47f837f9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4372,7 +4372,8 @@ static int process_backlog(struct napi_struct *napi, int quota)
  * __napi_schedule - schedule for receive
  * @n: entry to schedule
  *
- * The entry's receive function will be scheduled to run
+ * The entry's receive function will be scheduled to run.
+ * Consider using __napi_schedule_irqoff() if hard irqs are masked.
  */
 void __napi_schedule(struct napi_struct *n)
 {
@@ -4384,6 +4385,18 @@ void __napi_schedule(struct napi_struct *n)
 }
 EXPORT_SYMBOL(__napi_schedule);
 
+/**
+ * __napi_schedule_irqoff - schedule for receive
+ * @n: entry to schedule
+ *
+ * Variant of __napi_schedule() assuming hard irqs are masked
+ */
+void __napi_schedule_irqoff(struct napi_struct *n)
+{
+	____napi_schedule(this_cpu_ptr(&softnet_data), n);
+}
+EXPORT_SYMBOL(__napi_schedule_irqoff);
+
 void __napi_complete(struct napi_struct *n)
 {
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
