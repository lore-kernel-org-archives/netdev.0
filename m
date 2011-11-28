From: igorm@etf.rs
Subject: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Mon, 28 Nov 2011 21:23:16 +0100
Message-ID: <1322511796-6908-2-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1322511796-6908-1-git-send-email-igorm@etf.rs>
Cc: eric.dumazet@gmail.com, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:46644 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753931Ab1K1UXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 15:23:22 -0500
In-Reply-To: <1322511796-6908-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Problem with setting netstamp_needed as jump_label_key is that
it inc/dec, functions net_enable_timestamp/net_disable_timestamp,
are called from interrupts.

That can cause DEADLOCK, because jump_label_{inc, dec} are using mutex locking,
that may sleep.

Signed-off-by: Igor Maravic <igorm@etf.rs>

:100644 100644 d1f1071... 4d88cac... M	net/core/dev.c

diff --git a/net/core/dev.c b/net/core/dev.c
index d1f1071..4d88cac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1442,29 +1442,29 @@ int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 }
 EXPORT_SYMBOL(call_netdevice_notifiers);
 
-static struct jump_label_key netstamp_needed __read_mostly;
+static atomic_t netstamp_needed = ATOMIC_INIT(0);
 
 void net_enable_timestamp(void)
 {
-	jump_label_inc(&netstamp_needed);
+	atomic_inc(&netstamp_needed);
 }
 EXPORT_SYMBOL(net_enable_timestamp);
 
 void net_disable_timestamp(void)
 {
-	jump_label_dec(&netstamp_needed);
+	atomic_dec(&netstamp_needed);
 }
 EXPORT_SYMBOL(net_disable_timestamp);
 
 static inline void net_timestamp_set(struct sk_buff *skb)
 {
 	skb->tstamp.tv64 = 0;
-	if (static_branch(&netstamp_needed))
+	if (atomic_read(&netstamp_needed))
 		__net_timestamp(skb);
 }
 
 #define net_timestamp_check(COND, SKB)			\
-	if (static_branch(&netstamp_needed)) {		\
+	if (atomic_read(&netstamp_needed)) {		\
 		if ((COND) && !(SKB)->tstamp.tv64)	\
 			__net_timestamp(SKB);		\
 	}						\
-- 
1.7.5.4
