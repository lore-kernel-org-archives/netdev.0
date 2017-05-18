From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH v4 net-next 3/7] net: add function to retrieve original skb device using NAPI ID
Date: Thu, 18 May 2017 15:06:52 +0200
Message-ID: <20170518130656.24163-4-mlichvar@redhat.com>
References: <20170518130656.24163-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60956 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756134AbdERNHC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 09:07:02 -0400
In-Reply-To: <20170518130656.24163-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit b68581778cd0 ("net: Make skb->skb_iif always track
skb->dev") skbs don't have the original index of the interface which
received the packet. This information is now needed for a new control
message related to hardware timestamping.

Instead of adding a new field to skb, we can find the device by the NAPI
ID if it is available, i.e. CONFIG_NET_RX_BUSY_POLL is enabled and the
driver is using NAPI. Add dev_get_by_napi_id() and also skb_napi_id() to
hide the CONFIG_NET_RX_BUSY_POLL ifdef.

CC: Richard Cochran <richardcochran@gmail.com>
Suggested-by: Willem de Bruijn <willemb@google.com>
Acked-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 include/linux/netdevice.h |  1 +
 include/linux/skbuff.h    |  9 +++++++++
 net/core/dev.c            | 26 ++++++++++++++++++++++++++
 3 files changed, 36 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3f39d27..b6c36d5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2456,6 +2456,7 @@ static inline int dev_recursion_level(void)
 struct net_device *dev_get_by_index(struct net *net, int ifindex);
 struct net_device *__dev_get_by_index(struct net *net, int ifindex);
 struct net_device *dev_get_by_index_rcu(struct net *net, int ifindex);
+struct net_device *dev_get_by_napi_id(unsigned int napi_id);
 int netdev_get_name(struct net *net, char *name, int ifindex);
 int dev_restart(struct net_device *dev);
 int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7c0cb2c..1f8028c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -855,6 +855,15 @@ static inline bool skb_pkt_type_ok(u32 ptype)
 	return ptype <= PACKET_OTHERHOST;
 }
 
+static inline unsigned int skb_napi_id(const struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	return skb->napi_id;
+#else
+	return 0;
+#endif
+}
+
 void kfree_skb(struct sk_buff *skb);
 void kfree_skb_list(struct sk_buff *segs);
 void skb_tx_error(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index acd594c..6d3c452 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -162,6 +162,7 @@ static int netif_rx_internal(struct sk_buff *skb);
 static int call_netdevice_notifiers_info(unsigned long val,
 					 struct net_device *dev,
 					 struct netdev_notifier_info *info);
+static struct napi_struct *napi_by_id(unsigned int napi_id);
 
 /*
  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
@@ -866,6 +867,31 @@ struct net_device *dev_get_by_index(struct net *net, int ifindex)
 EXPORT_SYMBOL(dev_get_by_index);
 
 /**
+ *	dev_get_by_napi_id - find a device by napi_id
+ *	@napi_id: ID of the NAPI struct
+ *
+ *	Search for an interface by NAPI ID. Returns %NULL if the device
+ *	is not found or a pointer to the device. The device has not had
+ *	its reference counter increased so the caller must be careful
+ *	about locking. The caller must hold RCU lock.
+ */
+
+struct net_device *dev_get_by_napi_id(unsigned int napi_id)
+{
+	struct napi_struct *napi;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	if (napi_id < MIN_NAPI_ID)
+		return NULL;
+
+	napi = napi_by_id(napi_id);
+
+	return napi ? napi->dev : NULL;
+}
+EXPORT_SYMBOL(dev_get_by_napi_id);
+
+/**
  *	netdev_get_name - get a netdevice name, knowing its ifindex.
  *	@net: network namespace
  *	@name: a pointer to the buffer where the name will be stored.
-- 
2.9.3
