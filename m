From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: net_enable_timestamp() can be called from irq
 contexts
Date: Wed, 01 Mar 2017 14:28:39 -0800
Message-ID: <1488407319.9415.315.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+bHh=mzTXw1J8vxbzimrQULss16B=693T4SMcndoNoPPg@mail.gmail.com>
         <CANn89iL8XLopw+grdzMW6_vabiQjKrVL_q-u4-b1XcL_uRAPUw@mail.gmail.com>
         <1488398879.9415.302.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488399119.9415.304.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36185 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753041AbdCBD6L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 22:58:11 -0500
Received: by mail-pg0-f65.google.com with SMTP id 25so7857398pgy.3
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 19:58:11 -0800 (PST)
In-Reply-To: <1488399119.9415.304.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It is now very clear that silly TCP listeners might play with
enabling/disabling timestamping while new children are added
to their accept queue.

Meaning net_enable_timestamp() can be called from BH context
while current state of the static key is not enabled.

Lets play safe and allow all contexts.

The work queue is scheduled only under the problematic cases,
which are the static key enable/disable transition, to not slow down
critical paths.

This extends and improves what we did in commit 5fa8bbda38c6 ("net: use
a work queue to defer net_disable_timestamp() work")

Fixes: b90e5794c5bd ("net: dont call jump_label_dec from irq context")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/core/dev.c |   35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e63bf61b19be029e30ac40443c0e2edb24de4a73..8637b2b71f3d4751366a2ca5ba46579e6a5fa953 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1698,27 +1698,54 @@ EXPORT_SYMBOL_GPL(net_dec_egress_queue);
 static struct static_key netstamp_needed __read_mostly;
 #ifdef HAVE_JUMP_LABEL
 static atomic_t netstamp_needed_deferred;
+static atomic_t netstamp_wanted;
 static void netstamp_clear(struct work_struct *work)
 {
 	int deferred = atomic_xchg(&netstamp_needed_deferred, 0);
+	int wanted;
 
-	while (deferred--)
-		static_key_slow_dec(&netstamp_needed);
+	wanted = atomic_add_return(deferred, &netstamp_wanted);
+	if (wanted > 0)
+		static_key_enable(&netstamp_needed);
+	else
+		static_key_disable(&netstamp_needed);
 }
 static DECLARE_WORK(netstamp_work, netstamp_clear);
 #endif
 
 void net_enable_timestamp(void)
 {
+#ifdef HAVE_JUMP_LABEL
+	int wanted;
+
+	while (1) {
+		wanted = atomic_read(&netstamp_wanted);
+		if (wanted <= 0)
+			break;
+		if (atomic_cmpxchg(&netstamp_wanted, wanted, wanted + 1) == wanted)
+			return;
+	}
+	atomic_inc(&netstamp_needed_deferred);
+	schedule_work(&netstamp_work);
+#else
 	static_key_slow_inc(&netstamp_needed);
+#endif
 }
 EXPORT_SYMBOL(net_enable_timestamp);
 
 void net_disable_timestamp(void)
 {
 #ifdef HAVE_JUMP_LABEL
-	/* net_disable_timestamp() can be called from non process context */
-	atomic_inc(&netstamp_needed_deferred);
+	int wanted;
+
+	while (1) {
+		wanted = atomic_read(&netstamp_wanted);
+		if (wanted <= 1)
+			break;
+		if (atomic_cmpxchg(&netstamp_wanted, wanted, wanted - 1) == wanted)
+			return;
+	}
+	atomic_dec(&netstamp_needed_deferred);
 	schedule_work(&netstamp_work);
 #else
 	static_key_slow_dec(&netstamp_needed);
