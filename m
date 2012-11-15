From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 01/14] net:  Add generic packet offload infrastructure.
Date: Thu, 15 Nov 2012 13:49:10 -0500
Message-ID: <1353005363-6974-2-git-send-email-vyasevic@redhat.com>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43781 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768684Ab2KOSt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 13:49:28 -0500
In-Reply-To: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a new data structure to contain the GRO/GSO callbacks and add
a new registration mechanism.

Singed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h |   14 ++++++++
 net/core/dev.c            |   80 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 94 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8eda02..a896a47 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1511,6 +1511,17 @@ struct packet_type {
 	struct list_head	list;
 };
 
+struct packet_offload {
+	__be16			type;	/* This is really htons(ether_type). */
+	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
+						netdev_features_t features);
+	int			(*gso_send_check)(struct sk_buff *skb);
+	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
+					       struct sk_buff *skb);
+	int			(*gro_complete)(struct sk_buff *skb);
+	struct list_head	list;
+};
+
 #include <linux/notifier.h>
 
 /* netdevice notifier chain. Please remember to update the rtnetlink
@@ -1605,6 +1616,9 @@ extern struct net_device *__dev_getfirstbyhwtype(struct net *net, unsigned short
 extern void		dev_add_pack(struct packet_type *pt);
 extern void		dev_remove_pack(struct packet_type *pt);
 extern void		__dev_remove_pack(struct packet_type *pt);
+extern void		dev_add_offload(struct packet_offload *po);
+extern void		dev_remove_offload(struct packet_offload *po);
+extern void		__dev_remove_offload(struct packet_offload *po);
 
 extern struct net_device	*dev_get_by_flags_rcu(struct net *net, unsigned short flags,
 						      unsigned short mask);
diff --git a/net/core/dev.c b/net/core/dev.c
index 09cb3f6..10967e5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -176,8 +176,10 @@
 #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
 
 static DEFINE_SPINLOCK(ptype_lock);
+static DEFINE_SPINLOCK(offload_lock);
 static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 static struct list_head ptype_all __read_mostly;	/* Taps */
+static struct list_head offload_base __read_mostly;
 
 /*
  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
@@ -470,6 +472,82 @@ void dev_remove_pack(struct packet_type *pt)
 }
 EXPORT_SYMBOL(dev_remove_pack);
 
+
+/**
+ *	dev_add_offload - register offload handlers
+ *	@po: protocol offload declaration
+ *
+ *	Add protocol offload handlers to the networking stack. The passed
+ *	&proto_offload is linked into kernel lists and may not be freed until
+ *	it has been removed from the kernel lists.
+ *
+ *	This call does not sleep therefore it can not
+ *	guarantee all CPU's that are in middle of receiving packets
+ *	will see the new offload handlers (until the next received packet).
+ */
+void dev_add_offload(struct packet_offload *po)
+{
+	struct list_head *head = &offload_base;
+
+	spin_lock(&offload_lock);
+	list_add_rcu(&po->list, head);
+	spin_unlock(&offload_lock);
+}
+EXPORT_SYMBOL(dev_add_offload);
+
+/**
+ *	__dev_remove_offload	 - remove offload handler
+ *	@po: packet offload declaration
+ *
+ *	Remove a protocol offload handler that was previously added to the
+ *	kernel offload handlers by dev_add_offload(). The passed &offload_type
+ *	is removed from the kernel lists and can be freed or reused once this
+ *	function returns.
+ *
+ *      The packet type might still be in use by receivers
+ *	and must not be freed until after all the CPU's have gone
+ *	through a quiescent state.
+ */
+void __dev_remove_offload(struct packet_offload *po)
+{
+	struct list_head *head = &offload_base;
+	struct packet_offload *po1;
+
+	spin_lock(&ptype_lock);
+
+	list_for_each_entry(po1, head, list) {
+		if (po == po1) {
+			list_del_rcu(&po->list);
+			goto out;
+		}
+	}
+
+	pr_warn("dev_remove_offload: %p not found\n", po);
+out:
+	spin_unlock(&ptype_lock);
+}
+EXPORT_SYMBOL(__dev_remove_offload);
+
+/**
+ *	dev_remove_offload	 - remove packet offload handler
+ *	@po: packet offload declaration
+ *
+ *	Remove a packet offload handler that was previously added to the kernel
+ *	offload handlers by dev_add_offload(). The passed &offload_type is
+ *	removed from the kernel lists and can be freed or reused once this
+ *	function returns.
+ *
+ *	This call sleeps to guarantee that no CPU is looking at the packet
+ *	type after return.
+ */
+void dev_remove_offload(struct packet_offload *po)
+{
+	__dev_remove_offload(po);
+
+	synchronize_net();
+}
+EXPORT_SYMBOL(dev_remove_offload);
+
 /******************************************************************************
 
 		      Device Boot-time Settings Routines
@@ -6662,6 +6740,8 @@ static int __init net_dev_init(void)
 	for (i = 0; i < PTYPE_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&ptype_base[i]);
 
+	INIT_LIST_HEAD(&offload_base);
+
 	if (register_pernet_subsys(&netdev_net_ops))
 		goto out;
 
-- 
1.7.7.6
