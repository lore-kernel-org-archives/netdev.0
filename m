From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/4] Make and use skb_get_queue_mapping
Date: Fri, 19 Oct 2007 13:02:31 +0400
Message-ID: <471872A7.7070101@openvz.org>
References: <471871E5.7060900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35527 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753155AbXJSJCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 05:02:40 -0400
In-Reply-To: <471871E5.7060900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the helper for getting the field, symmetrical to
the "set" one. Return 0 if CONFIG_NETDEVICES_MULTIQUEUE=n

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index ed53aaa..ae41973 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -471,7 +471,7 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	len = max(skb->len, ETH_ZLEN);
-	queue = skb->queue_mapping;
+	queue = skb_get_queue_mapping(skb);
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netif_stop_subqueue(dev, queue);
 #else
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f93f22b..580ed1f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1770,6 +1771,15 @@ static inline void skb_set_queue_mapping(struct sk_buff *skb, u16 queue_mapping)
 #endif
 }
 
+static inline u16 skb_get_queue_mapping(struct sk_buff *skb)
+{
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	return skb->queue_mapping;
+#else
+	return 0;
+#endif
+}
+
 static inline void skb_copy_queue_mapping(struct sk_buff *to, const struct sk_buff *from)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index be57cf3..421281d 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -266,7 +266,7 @@ static int teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
 	int busy;
 	int nores;
 	int len = skb->len;
-	int subq = skb->queue_mapping;
+	int subq = skb_get_queue_mapping(skb);
 	struct sk_buff *skb_res = NULL;
 
 	start = master->slaves;

