From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netpoll: more efficient locking
Date: Wed, 16 Nov 2016 14:54:50 -0800
Message-ID: <1479336890.8455.225.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33962 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422751AbcKPWyw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 17:54:52 -0500
Received: by mail-pf0-f196.google.com with SMTP id y68so10513333pfb.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 14:54:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Callers of netpoll_poll_lock() own NAPI_STATE_SCHED

Callers of netpoll_poll_unlock() have BH blocked between
the NAPI_STATE_SCHED being cleared and poll_lock is released.

We can avoid the spinlock which has no contention, and use cmpxchg()
on poll_owner which we need to set anyway.

This removes a possible lockdep violation after the cited commit,
since sk_busy_loop() re-enables BH before calling busy_poll_stop()

Fixes: 217f69743681 ("net: busy-poll: allow preemption in sk_busy_loop()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    1 -
 include/linux/netpoll.h   |   13 +++++++------
 net/core/dev.c            |    1 -
 net/core/netpoll.c        |    6 +++---
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bcddf951ccee..e84800edd249 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -316,7 +316,6 @@ struct napi_struct {
 	unsigned int		gro_count;
 	int			(*poll)(struct napi_struct *, int);
 #ifdef CONFIG_NETPOLL
-	spinlock_t		poll_lock;
 	int			poll_owner;
 #endif
 	struct net_device	*dev;
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index b25ee9ffdbe6..1828900c9411 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -78,8 +78,11 @@ static inline void *netpoll_poll_lock(struct napi_struct *napi)
 	struct net_device *dev = napi->dev;
 
 	if (dev && dev->npinfo) {
-		spin_lock(&napi->poll_lock);
-		napi->poll_owner = smp_processor_id();
+		int owner = smp_processor_id();
+
+		while (cmpxchg(&napi->poll_owner, -1, owner) != -1)
+			cpu_relax();
+
 		return napi;
 	}
 	return NULL;
@@ -89,10 +92,8 @@ static inline void netpoll_poll_unlock(void *have)
 {
 	struct napi_struct *napi = have;
 
-	if (napi) {
-		napi->poll_owner = -1;
-		spin_unlock(&napi->poll_lock);
-	}
+	if (napi)
+		smp_store_release(&napi->poll_owner, -1);
 }
 
 static inline bool netpoll_tx_running(struct net_device *dev)
diff --git a/net/core/dev.c b/net/core/dev.c
index edba9efeb2e9..f71b34ab57a5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5143,7 +5143,6 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 	list_add(&napi->dev_list, &dev->napi_list);
 	napi->dev = dev;
 #ifdef CONFIG_NETPOLL
-	spin_lock_init(&napi->poll_lock);
 	napi->poll_owner = -1;
 #endif
 	set_bit(NAPI_STATE_SCHED, &napi->state);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 53599bd0c82d..9424673009c1 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -171,12 +171,12 @@ static void poll_one_napi(struct napi_struct *napi)
 static void poll_napi(struct net_device *dev)
 {
 	struct napi_struct *napi;
+	int cpu = smp_processor_id();
 
 	list_for_each_entry(napi, &dev->napi_list, dev_list) {
-		if (napi->poll_owner != smp_processor_id() &&
-		    spin_trylock(&napi->poll_lock)) {
+		if (cmpxchg(&napi->poll_owner, -1, cpu) == -1) {
 			poll_one_napi(napi);
-			spin_unlock(&napi->poll_lock);
+			smp_store_release(&napi->poll_owner, -1);
 		}
 	}
 }
