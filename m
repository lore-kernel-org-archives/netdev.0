From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] Get rid of netdev_nit
Date: Tue, 13 Mar 2007 14:26:35 -0700
Message-ID: <20070313142635.68966970@freekitty>
References: <20070312210817.485320783@linux-foundation.org>
	<20070312210907.509184287@linux-foundation.org>
	<45F63891.6040307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36079 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933630AbXCMV1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 17:27:07 -0400
In-Reply-To: <45F63891.6040307@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It isn't any faster to test a boolean global variable than do a 
simple check for empty list.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/core/dev.c |   18 +++++-------------
 1 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3a8590c..f2ae2c9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -226,12 +226,6 @@ #endif
 *******************************************************************************/
 
 /*
- *	For efficiency
- */
-
-static int netdev_nit;
-
-/*
  *	Add a protocol ID to the list. Now that the input handler is
  *	smarter we can dispense with all the messy stuff that used to be
  *	here.
@@ -265,10 +259,9 @@ void dev_add_pack(struct packet_type *pt
 	int hash;
 
 	spin_lock_bh(&ptype_lock);
-	if (pt->type == htons(ETH_P_ALL)) {
-		netdev_nit++;
+	if (pt->type == htons(ETH_P_ALL))
 		list_add_rcu(&pt->list, &ptype_all);
-	} else {
+	else {
 		hash = ntohs(pt->type) & 15;
 		list_add_rcu(&pt->list, &ptype_base[hash]);
 	}
@@ -295,10 +288,9 @@ void __dev_remove_pack(struct packet_typ
 
 	spin_lock_bh(&ptype_lock);
 
-	if (pt->type == htons(ETH_P_ALL)) {
-		netdev_nit--;
+	if (pt->type == htons(ETH_P_ALL))
 		head = &ptype_all;
-	} else
+	else
 		head = &ptype_base[ntohs(pt->type) & 15];
 
 	list_for_each_entry(pt1, head, list) {
@@ -1333,7 +1325,7 @@ static int dev_gso_segment(struct sk_buf
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	if (likely(!skb->next)) {
-		if (netdev_nit)
+		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
 
 		if (netif_needs_gso(dev, skb)) {
-- 
1.4.1

