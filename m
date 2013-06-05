From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] net: remove last caller of skb_tail_offset() and itself
Date: Wed,  5 Jun 2013 20:14:10 +0800
Message-ID: <1370434450-15811-1-git-send-email-amwang@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkmann@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752446Ab3FEMO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 08:14:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Similar to the following commits:

commit 00f97da17a0c8d656d0c9 (netpoll: fix position of network header)
commit 525cebedb32a87fa48584 (pktgen: Fix position of ip and udp header)

using skb_tail_offset() seems not correct since the offset
is based on head pointer.

With the last caller removed, skb_tail_offset() can be killed
finally.

Cc: Thomas Graf <tgraf@suug.ch>
Cc: Daniel Borkmann <dborkmann@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b999790..fd42776 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1392,10 +1392,6 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
 	skb->tail += offset;
 }
 
-static inline unsigned long skb_tail_offset(const struct sk_buff *skb)
-{
-	return skb->tail;
-}
 #else /* NET_SKBUFF_DATA_USES_OFFSET */
 static inline unsigned char *skb_tail_pointer(const struct sk_buff *skb)
 {
@@ -1412,10 +1408,6 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
 	skb->tail = skb->data + offset;
 }
 
-static inline unsigned long skb_tail_offset(const struct sk_buff *skb)
-{
-	return skb->tail - skb->head;
-}
 #endif /* NET_SKBUFF_DATA_USES_OFFSET */
 
 /*
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index df97f0a..132a096 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -945,7 +945,6 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	struct igmpmsg *msg;
 	struct sock *mroute_sk;
 	int ret;
-	unsigned long tail_offset;
 
 #ifdef CONFIG_IP_PIMSM
 	if (assert == IGMPMSG_WHOLEPKT)
@@ -981,12 +980,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 
 	/* Copy the IP header */
 
-	tail_offset = skb_tail_offset(skb);
-	if (tail_offset > 0xffff) {
-		kfree_skb(skb);
-		return -EINVAL;
-	}
-	skb_set_network_header(skb, tail_offset);
+	skb_set_network_header(skb, skb->len);
 	skb_put(skb, ihl);
 	skb_copy_to_linear_data(skb, pkt->data, ihl);
 	ip_hdr(skb)->protocol = 0;	/* Flag to the kernel this is a route add */
