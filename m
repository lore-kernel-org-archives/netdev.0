From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCN net-next-2.6] net: dev_add_pack() & __dev_remove_pack()
 changes
Date: Thu, 02 Sep 2010 15:53:46 +0200
Message-ID: <1283435626.2454.764.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33879 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966Ab0IBNxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 09:53:51 -0400
Received: by eyb6 with SMTP id 6so245581eyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 06:53:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a small helper ptype_head() to get the head to manipulate

dev_add_pack() & __dev_remove_pack() can use a spinlock without
blocking BH, since softirq use RCU, and these functions are run from
process context only.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d8c43e7..efd318d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -371,6 +371,14 @@ static inline void netdev_set_addr_lockdep_class(struct net_device *dev)
  *							--ANK (980803)
  */
 
+static inline struct list_head *ptype_head(const struct packet_type *pt)
+{
+	if (pt->type == htons(ETH_P_ALL))
+		return &ptype_all;
+	else
+		return &ptype_base[ntohs(pt->type) & PTYPE_HASH_MASK];
+}
+
 /**
  *	dev_add_pack - add packet handler
  *	@pt: packet type declaration
@@ -386,16 +394,11 @@ static inline void netdev_set_addr_lockdep_class(struct net_device *dev)
 
 void dev_add_pack(struct packet_type *pt)
 {
-	int hash;
+	struct list_head *head = ptype_head(pt);
 
-	spin_lock_bh(&ptype_lock);
-	if (pt->type == htons(ETH_P_ALL))
-		list_add_rcu(&pt->list, &ptype_all);
-	else {
-		hash = ntohs(pt->type) & PTYPE_HASH_MASK;
-		list_add_rcu(&pt->list, &ptype_base[hash]);
-	}
-	spin_unlock_bh(&ptype_lock);
+	spin_lock(&ptype_lock);
+	list_add_rcu(&pt->list, head);
+	spin_unlock(&ptype_lock);
 }
 EXPORT_SYMBOL(dev_add_pack);
 
@@ -414,15 +417,10 @@ EXPORT_SYMBOL(dev_add_pack);
  */
 void __dev_remove_pack(struct packet_type *pt)
 {
-	struct list_head *head;
+	struct list_head *head = ptype_head(pt);
 	struct packet_type *pt1;
 
-	spin_lock_bh(&ptype_lock);
-
-	if (pt->type == htons(ETH_P_ALL))
-		head = &ptype_all;
-	else
-		head = &ptype_base[ntohs(pt->type) & PTYPE_HASH_MASK];
+	spin_lock(&ptype_lock);
 
 	list_for_each_entry(pt1, head, list) {
 		if (pt == pt1) {
@@ -433,7 +431,7 @@ void __dev_remove_pack(struct packet_type *pt)
 
 	printk(KERN_WARNING "dev_remove_pack: %p not found.\n", pt);
 out:
-	spin_unlock_bh(&ptype_lock);
+	spin_unlock(&ptype_lock);
 }
 EXPORT_SYMBOL(__dev_remove_pack);
 


