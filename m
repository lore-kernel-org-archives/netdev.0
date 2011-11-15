From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCN net-next] net: use jump_label for netstamp_needed
Date: Tue, 15 Nov 2011 15:12:55 +0100
Message-ID: <1321366375.2856.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60300 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880Ab1KOONB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 09:13:01 -0500
Received: by bke11 with SMTP id 11so7168986bke.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 06:12:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netstamp_needed seems a good candidate to jump_label conversion.

This avoids 3 conditional branches per incoming packet in fast path.

No measurable difference, given that these conditional branches are
predicted on modern cpus. Only a small icache reduction, thanks to the
unlikely() stuff.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   32 ++++++++++++++------------------
 1 file changed, 14 insertions(+), 18 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6ba50a1..51f89cd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -137,6 +137,7 @@
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
 #include <linux/net_tstamp.h>
+#include <linux/jump_label.h>
 
 #include "net-sysfs.h"
 
@@ -1449,34 +1450,32 @@ int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 }
 EXPORT_SYMBOL(call_netdevice_notifiers);
 
-/* When > 0 there are consumers of rx skb time stamps */
-static atomic_t netstamp_needed = ATOMIC_INIT(0);
+static struct jump_label_key netstamp_needed __read_mostly;
 
 void net_enable_timestamp(void)
 {
-	atomic_inc(&netstamp_needed);
+	jump_label_inc(&netstamp_needed);
 }
 EXPORT_SYMBOL(net_enable_timestamp);
 
 void net_disable_timestamp(void)
 {
-	atomic_dec(&netstamp_needed);
+	jump_label_dec(&netstamp_needed);
 }
 EXPORT_SYMBOL(net_disable_timestamp);
 
 static inline void net_timestamp_set(struct sk_buff *skb)
 {
-	if (atomic_read(&netstamp_needed))
+	skb->tstamp.tv64 = 0;
+	if (static_branch(&netstamp_needed))
 		__net_timestamp(skb);
-	else
-		skb->tstamp.tv64 = 0;
 }
 
-static inline void net_timestamp_check(struct sk_buff *skb)
-{
-	if (!skb->tstamp.tv64 && atomic_read(&netstamp_needed))
-		__net_timestamp(skb);
-}
+#define net_timestamp_check(COND, SKB)			\
+	if (static_branch(&netstamp_needed)) {		\
+		if ((COND) && !(SKB)->tstamp.tv64)	\
+			__net_timestamp(SKB);		\
+	}						\
 
 static int net_hwtstamp_validate(struct ifreq *ifr)
 {
@@ -2997,8 +2996,7 @@ int netif_rx(struct sk_buff *skb)
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
-	if (netdev_tstamp_prequeue)
-		net_timestamp_check(skb);
+	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
 	trace_netif_rx(skb);
 #ifdef CONFIG_RPS
@@ -3230,8 +3228,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	int ret = NET_RX_DROP;
 	__be16 type;
 
-	if (!netdev_tstamp_prequeue)
-		net_timestamp_check(skb);
+	net_timestamp_check(!netdev_tstamp_prequeue, skb);
 
 	trace_netif_receive_skb(skb);
 
@@ -3362,8 +3359,7 @@ out:
  */
 int netif_receive_skb(struct sk_buff *skb)
 {
-	if (netdev_tstamp_prequeue)
-		net_timestamp_check(skb);
+	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
 	if (skb_defer_rx_timestamp(skb))
 		return NET_RX_SUCCESS;
