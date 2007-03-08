From: David Miller <davem@davemloft.net>
Subject: TCP RB oops fixed
Date: Wed, 07 Mar 2007 21:32:50 -0800 (PST)
Message-ID: <20070307.213250.74747956.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, ilpo.jarvinen@helsinki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752227AbXCHFcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 00:32:50 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I just checked in a fix for the TSO oops with RB-tree to
net-2.6.22 as follows:

commit 7de509de7c166598b0873dc9ef4c98424307f6b5
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Mar 7 21:31:17 2007 -0800

    [TCP]: Fix bug in tcp_rb_insert.
    
    We should advance rb_parent inside of the while() loop
    body not in the loop test, otherwise rb_parent is always
    NULL. :-/
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2599d98..b94debb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1252,8 +1252,11 @@ static inline void tcp_rb_insert(struct sk_buff *skb, struct rb_root *root)
 
 	rb_link = &root->rb_node;
 	rb_parent = NULL;
-	while ((rb_parent = *rb_link) != NULL) {
-		struct sk_buff *tmp = rb_entry(rb_parent,struct sk_buff,rb);
+	while (*rb_link) {
+		struct sk_buff *tmp;
+
+		rb_parent = *rb_link;
+		tmp = rb_entry(rb_parent,struct sk_buff,rb);
 		if (TCP_SKB_CB(tmp)->end_seq > seq) {
 			BUG_ON(TCP_SKB_CB(tmp)->seq <= seq);
 			rb_link = &rb_parent->rb_left;
